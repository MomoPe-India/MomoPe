-- MomoPe Business Logic Functions
-- Version: 1.0
-- Date: February 15, 2026

-- ============================================================================
-- FUNCTION: calculate_max_redeemable
-- Purpose: Calculate maximum coins that can be redeemed (80/20 rule)
-- ============================================================================
CREATE OR REPLACE FUNCTION calculate_max_redeemable(
  p_user_id UUID,
  p_bill_amount DECIMAL
)
RETURNS DECIMAL AS $$
DECLARE
  v_balance DECIMAL;
  v_max_from_bill DECIMAL;
  v_max_from_balance DECIMAL;
BEGIN
  -- Get user's available coin balance
  SELECT available_coins INTO v_balance
  FROM momo_coin_balances
  WHERE user_id = p_user_id;
  
  IF v_balance IS NULL THEN
    RETURN 0;
  END IF;
  
  -- Calculate 80% of bill amount
  v_max_from_bill := p_bill_amount * 0.80;
  
  -- Calculate 80% of user balance
  v_max_from_balance := v_balance * 0.80;
  
  -- Return minimum of the two
  RETURN LEAST(v_max_from_bill, v_max_from_balance);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- FUNCTION: redeem_coins_fifo
-- Purpose: Redeem coins from oldest batches first (FIFO)
-- ============================================================================
CREATE OR REPLACE FUNCTION redeem_coins_fifo(
  p_user_id UUID,
  p_coins_to_redeem DECIMAL,
  p_transaction_id UUID
)
RETURNS VOID AS $$
DECLARE
  v_batch RECORD;
  v_remaining DECIMAL := p_coins_to_redeem;
  v_deduct DECIMAL;
BEGIN
  -- Validate redemption amount
  IF p_coins_to_redeem <= 0 THEN
    RAISE EXCEPTION 'Redemption amount must be positive';
  END IF;
  
  -- Lock coin_batches for update (prevent race conditions)
  FOR v_batch IN
    SELECT id, amount
    FROM coin_batches
    WHERE user_id = p_user_id
      AND is_expired = false
      AND amount > 0
    ORDER BY created_at ASC -- FIFO: oldest first
    FOR UPDATE
  LOOP
    EXIT WHEN v_remaining <= 0;
    
    -- Calculate deduction amount
    v_deduct := LEAST(v_batch.amount, v_remaining);
    
    -- Update batch amount
    UPDATE coin_batches
    SET amount = amount - v_deduct
    WHERE id = v_batch.id;
    
    -- Record coin transaction
    INSERT INTO coin_transactions (user_id, transaction_id, batch_id, type, amount)
    VALUES (p_user_id, p_transaction_id, v_batch.id, 'redeem', -v_deduct);
    
    v_remaining := v_remaining - v_deduct;
  END LOOP;
  
  -- Check if sufficient balance existed
  IF v_remaining > 0 THEN
    RAISE EXCEPTION 'Insufficient coin balance. Needed: %, Available: %', 
      p_coins_to_redeem, p_coins_to_redeem - v_remaining;
  END IF;
  
  -- Update aggregate balance
  UPDATE momo_coin_balances
  SET 
    total_coins = total_coins - p_coins_to_redeem,
    available_coins = available_coins - p_coins_to_redeem
  WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- FUNCTION: award_coins
-- Purpose: Award coins to user (create batch, update balance)
-- ============================================================================
CREATE OR REPLACE FUNCTION award_coins(
  p_user_id UUID,
  p_amount DECIMAL,
  p_source VARCHAR,
  p_transaction_id UUID DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
  -- Validate amount
  IF p_amount <= 0 THEN
    RAISE EXCEPTION 'Award amount must be positive';
  END IF;
  
  -- Create coin batch (90-day expiry)
  INSERT INTO coin_batches (
    user_id, 
    amount, 
    original_amount, 
    source, 
    transaction_id, 
    expiry_date
  )
  VALUES (
    p_user_id,
    p_amount,
    p_amount,
    p_source,
    p_transaction_id,
    CURRENT_DATE + INTERVAL '90 days'
  );
  
  -- Record coin transaction
  INSERT INTO coin_transactions (user_id, transaction_id, type, amount)
  VALUES (p_user_id, p_transaction_id, p_source, p_amount);
  
  -- Update aggregate balance
  UPDATE momo_coin_balances
  SET 
    total_coins = total_coins + p_amount,
    available_coins = available_coins + p_amount
  WHERE user_id = p_user_id;
  
  -- Create balance record if doesn't exist
  IF NOT FOUND THEN
    INSERT INTO momo_coin_balances (user_id, total_coins, available_coins, locked_coins)
    VALUES (p_user_id, p_amount, p_amount, 0);
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- FUNCTION: process_transaction_success
-- Purpose: Atomic processing of successful PayU transaction
-- ============================================================================
CREATE OR REPLACE FUNCTION process_transaction_success(
  p_transaction_id UUID,
  p_payu_mihpayid VARCHAR,
  p_total_commission DECIMAL,
  p_reward_cost DECIMAL,
  p_net_revenue DECIMAL,
  p_coins_to_redeem DECIMAL,
  p_coins_to_earn DECIMAL
)
RETURNS VOID AS $$
DECLARE
  v_transaction RECORD;
BEGIN
  -- Fetch transaction
  SELECT * INTO v_transaction
  FROM transactions
  WHERE id = p_transaction_id
  FOR UPDATE;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Transaction not found: %', p_transaction_id;
  END IF;
  
  IF v_transaction.status != 'initiated' THEN
    RAISE EXCEPTION 'Transaction already processed: %', v_transaction.status;
  END IF;
  
  -- 1. Update transaction status
  UPDATE transactions
  SET 
    status = 'success',
    payu_mihpayid = p_payu_mihpayid,
    completed_at = NOW()
  WHERE id = p_transaction_id;
  
  -- 2. Insert commission record
  INSERT INTO commissions (
    transaction_id,
    merchant_id,
    total_commission,
    reward_cost,
    net_revenue
  )
  VALUES (
    p_transaction_id,
    v_transaction.merchant_id,
    p_total_commission,
    p_reward_cost,
    p_net_revenue
  );
  
  -- 3. Redeem coins (if any)
  IF p_coins_to_redeem > 0 THEN
    PERFORM redeem_coins_fifo(
      v_transaction.user_id,
      p_coins_to_redeem,
      p_transaction_id
    );
  END IF;
  
  -- 4. Award new coins (10% of fiat paid)
  IF p_coins_to_earn > 0 THEN
    PERFORM award_coins(
      v_transaction.user_id,
      p_coins_to_earn,
      'earn',
      p_transaction_id
    );
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- FUNCTION: get_coverage_ratio
-- Purpose: Calculate reserve coverage ratio (for treasury dashboard)
-- ============================================================================
CREATE OR REPLACE FUNCTION get_coverage_ratio()
RETURNS DECIMAL AS $$
DECLARE
  v_total_liability DECIMAL;
  v_unsettled_commission DECIMAL;
  v_coverage_ratio DECIMAL;
BEGIN
  -- Total coin liability
  SELECT COALESCE(SUM(total_coins), 0) INTO v_total_liability
  FROM momo_coin_balances;
  
  -- Unsettled commissions (commission pool)
  SELECT COALESCE(SUM(net_revenue), 0) INTO v_unsettled_commission
  FROM commissions
  WHERE is_settled = false;
  
  -- Calculate coverage ratio
  IF v_total_liability = 0 THEN
    RETURN 100.0;
  END IF;
  
  v_coverage_ratio := (v_unsettled_commission / v_total_liability) * 100;
  
  RETURN ROUND(v_coverage_ratio, 2);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- FUNCTION: expire_old_coins
-- Purpose: Mark coin batches older than 90 days as expired
-- ============================================================================
CREATE OR REPLACE FUNCTION expire_old_coins(p_batch_limit INT DEFAULT 1000)
RETURNS INT AS $$
DECLARE
  v_batch RECORD;
  v_count INT := 0;
BEGIN
  FOR v_batch IN
    SELECT id, user_id, amount
    FROM coin_batches
    WHERE expiry_date < CURRENT_DATE
      AND is_expired = false
    LIMIT p_batch_limit
    FOR UPDATE
  LOOP
    -- Mark batch as expired
    UPDATE coin_batches
    SET is_expired = true, amount = 0
    WHERE id = v_batch.id;
    
    -- Record expiry transaction
    INSERT INTO coin_transactions (user_id, batch_id, type, amount, description)
    VALUES (
      v_batch.user_id,
      v_batch.id,
      'expire',
      -v_batch.amount,
      '90-day expiry'
    );
    
    -- Update balance
    UPDATE momo_coin_balances
    SET 
      total_coins = total_coins - v_batch.amount,
      available_coins = available_coins - v_batch.amount
    WHERE user_id = v_batch.user_id;
    
    v_count := v_count + 1;
  END LOOP;
  
  RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- COMMENTS
-- ============================================================================
COMMENT ON FUNCTION calculate_max_redeemable IS 'Calculates max coins that can be redeemed based on 80/20 rule';
COMMENT ON FUNCTION redeem_coins_fifo IS 'Redeems coins from oldest batches first (FIFO)';
COMMENT ON FUNCTION award_coins IS 'Awards coins to user and creates batch with 90-day expiry';
COMMENT ON FUNCTION process_transaction_success IS 'Atomically processes successful PayU transaction';
COMMENT ON FUNCTION get_coverage_ratio IS 'Calculates reserve coverage ratio for treasury monitoring';
COMMENT ON FUNCTION expire_old_coins IS 'Expires coin batches older than 90 days (called by cron)';
