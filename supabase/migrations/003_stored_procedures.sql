-- Migration: 003_stored_procedures.sql
-- Date: 2026-02-26
-- Author: MomoPe Team
-- Purpose: All stored procedures / RPCs for auth, coins, payments, referrals
-- Rollback: DROP FUNCTION <name> for each function below

-- =========================================================
-- UTILITY: generate_referral_code
-- =========================================================
CREATE OR REPLACE FUNCTION generate_referral_code()
RETURNS VARCHAR(10) AS $$
DECLARE
  chars  TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';  -- no 0/O/1/I confusion
  result TEXT := '';
  i      INTEGER;
BEGIN
  FOR i IN 1..8 LOOP
    result := result || substr(chars, floor(random() * length(chars) + 1)::int, 1);
  END LOOP;
  -- Ensure uniqueness by retrying if collision
  IF EXISTS (SELECT 1 FROM users WHERE referral_code = result) THEN
    RETURN generate_referral_code();
  END IF;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =========================================================
-- AUTH: create_user_profile
-- Called after Firebase OTP verification (first-time registration).
-- Idempotent via ON CONFLICT DO NOTHING.
-- =========================================================
CREATE OR REPLACE FUNCTION create_user_profile(
  firebase_uid        TEXT,
  phone               TEXT,
  name                TEXT,
  referral_code_used  TEXT DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
  v_referrer_id VARCHAR(128);
BEGIN
  -- Insert user (idempotent)
  INSERT INTO users (id, phone, name, role, referral_code)
  VALUES (
    firebase_uid,
    phone,
    name,
    'customer',
    generate_referral_code()
  )
  ON CONFLICT (id) DO NOTHING;

  -- Handle referral linkage (only if code provided and not already set)
  IF referral_code_used IS NOT NULL THEN
    SELECT id INTO v_referrer_id
    FROM users
    WHERE referral_code = referral_code_used
    LIMIT 1;

    IF v_referrer_id IS NOT NULL THEN
      -- Link referee → referrer
      UPDATE users
      SET referred_by = v_referrer_id
      WHERE id = firebase_uid AND referred_by IS NULL;

      -- Create referrals record
      INSERT INTO referrals (referrer_id, referee_id)
      VALUES (v_referrer_id, firebase_uid)
      ON CONFLICT (referee_id) DO NOTHING;
    END IF;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =========================================================
-- AUTH: set_pin
-- Called after OTP verification (new user) or forgot-PIN OTP.
-- Resets failure counters.
-- =========================================================
CREATE OR REPLACE FUNCTION set_pin(pin_hash TEXT)
RETURNS VOID AS $$
BEGIN
  UPDATE users
  SET
    pin_hash            = set_pin.pin_hash,
    pin_failed_attempts = 0,
    pin_locked_until    = NULL,
    updated_at          = NOW()
  WHERE id = auth.uid()::text;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =========================================================
-- AUTH: verify_pin  (Approach B — hash never leaves DB)
-- Uses pgcrypto crypt() for bcrypt comparison.
-- Note: Dart bcrypt uses $2b$; pgcrypto uses $2a$.
-- We store the hash as-is from Dart and use crypt() to compare.
-- If prefix mismatch is detected in testing, fall back to RPC
-- that accepts the hash from client and does equality check.
-- =========================================================
CREATE OR REPLACE FUNCTION verify_pin(entered_pin TEXT)
RETURNS JSONB AS $$
DECLARE
  v_user              users%ROWTYPE;
  v_hash_normalized   TEXT;
  v_match             BOOLEAN;
BEGIN
  SELECT * INTO v_user FROM users WHERE id = auth.uid()::text;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'code', 'NOT_FOUND');
  END IF;

  -- Check if locked
  IF v_user.pin_locked_until IS NOT NULL AND v_user.pin_locked_until > NOW() THEN
    RETURN jsonb_build_object(
      'success',      false,
      'code',         'PIN_LOCKED',
      'locked_until', v_user.pin_locked_until
    );
  END IF;

  -- Force OTP after 10 cumulative failures
  IF v_user.pin_failed_attempts >= 10 THEN
    RETURN jsonb_build_object('success', false, 'code', 'FORCE_OTP');
  END IF;

  -- Normalize $2b$ → $2a$ for pgcrypto compatibility (Dart uses $2b$)
  v_hash_normalized := regexp_replace(v_user.pin_hash, '^\$2b\$', '$2a$');
  v_match := (crypt(entered_pin, v_hash_normalized) = v_hash_normalized);

  IF v_match THEN
    UPDATE users
    SET pin_failed_attempts = 0, pin_locked_until = NULL, updated_at = NOW()
    WHERE id = auth.uid()::text;

    RETURN jsonb_build_object('success', true);
  ELSE
    -- Increment failure count
    UPDATE users
    SET
      pin_failed_attempts = pin_failed_attempts + 1,
      pin_locked_until = CASE
        WHEN pin_failed_attempts + 1 >= 5 AND pin_failed_attempts + 1 < 10
          THEN NOW() + INTERVAL '30 seconds'
        ELSE pin_locked_until
      END,
      updated_at = NOW()
    WHERE id = auth.uid()::text;

    RETURN jsonb_build_object(
      'success',  false,
      'code',     CASE
                    WHEN v_user.pin_failed_attempts + 1 >= 10 THEN 'FORCE_OTP'
                    WHEN v_user.pin_failed_attempts + 1 >= 5  THEN 'PIN_LOCKED'
                    ELSE 'WRONG_PIN'
                  END,
      'attempts', v_user.pin_failed_attempts + 1
    );
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =========================================================
-- AUTH: record_pin_failure  (standalone — for Approach A client-side verify)
-- =========================================================
CREATE OR REPLACE FUNCTION record_pin_failure(p_user_id VARCHAR)
RETURNS JSONB AS $$
DECLARE
  v_attempts INTEGER;
BEGIN
  UPDATE users
  SET
    pin_failed_attempts = pin_failed_attempts + 1,
    pin_locked_until = CASE
      WHEN pin_failed_attempts + 1 >= 5 AND pin_failed_attempts + 1 < 10
        THEN NOW() + INTERVAL '30 seconds'
      ELSE pin_locked_until
    END,
    updated_at = NOW()
  WHERE id = p_user_id
  RETURNING pin_failed_attempts INTO v_attempts;

  RETURN jsonb_build_object(
    'attempts', v_attempts,
    'code', CASE
      WHEN v_attempts >= 10 THEN 'FORCE_OTP'
      WHEN v_attempts >= 5  THEN 'PIN_LOCKED'
      ELSE 'WRONG_PIN'
    END
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =========================================================
-- AUTH: reset_pin_failures (called after successful OTP re-verify)
-- =========================================================
CREATE OR REPLACE FUNCTION reset_pin_failures(p_user_id VARCHAR)
RETURNS VOID AS $$
BEGIN
  UPDATE users
  SET pin_failed_attempts = 0, pin_locked_until = NULL, updated_at = NOW()
  WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =========================================================
-- MERCHANT: submit_merchant_kyc
-- =========================================================
CREATE OR REPLACE FUNCTION submit_merchant_kyc(
  business_name             TEXT,
  category                  TEXT,
  gstin                     TEXT DEFAULT NULL,
  pan                       TEXT DEFAULT NULL,
  business_address          TEXT DEFAULT NULL,
  bank_account_number       TEXT DEFAULT NULL,
  ifsc_code                 TEXT DEFAULT NULL,
  bank_account_holder_name  TEXT DEFAULT NULL,
  latitude                  DECIMAL DEFAULT NULL,
  longitude                 DECIMAL DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
  INSERT INTO merchants (
    user_id, business_name, category, gstin, pan, business_address,
    bank_account_number, ifsc_code, bank_account_holder_name,
    latitude, longitude, kyc_status
  )
  VALUES (
    auth.uid()::text, business_name, category, gstin, pan, business_address,
    bank_account_number, ifsc_code, bank_account_holder_name,
    latitude, longitude, 'pending'
  )
  ON CONFLICT (user_id) DO UPDATE
    SET business_name             = EXCLUDED.business_name,
        category                  = EXCLUDED.category,
        gstin                     = EXCLUDED.gstin,
        pan                       = EXCLUDED.pan,
        business_address          = EXCLUDED.business_address,
        bank_account_number       = EXCLUDED.bank_account_number,
        ifsc_code                 = EXCLUDED.ifsc_code,
        bank_account_holder_name  = EXCLUDED.bank_account_holder_name,
        latitude                  = EXCLUDED.latitude,
        longitude                 = EXCLUDED.longitude,
        kyc_status                = 'pending',   -- reset to pending on re-submit
        kyc_rejection_reason      = NULL,
        updated_at                = NOW()
  WHERE merchants.kyc_status = 'rejected';  -- only allow re-submit from rejected state
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =========================================================
-- COINS: calculate_max_redeemable (80/20 rule)
-- =========================================================
CREATE OR REPLACE FUNCTION calculate_max_redeemable(
  p_user_id     VARCHAR,
  p_bill_amount DECIMAL
)
RETURNS DECIMAL AS $$
  SELECT LEAST(p_bill_amount * 0.80, available_coins * 0.80)
  FROM momo_coin_balances
  WHERE user_id = p_user_id;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- =========================================================
-- COINS: award_coins
-- Creates a coin batch + audit entry + updates balance.
-- =========================================================
CREATE OR REPLACE FUNCTION award_coins(
  p_user_id       VARCHAR,
  p_amount        DECIMAL,
  p_transaction_id UUID,
  p_source        VARCHAR
)
RETURNS UUID AS $$
DECLARE
  v_batch_id UUID;
BEGIN
  -- Create coin batch (expiry = today + 90 days)
  INSERT INTO coin_batches (user_id, transaction_id, amount, original_amount, source, expiry_date)
  VALUES (p_user_id, p_transaction_id, p_amount, p_amount, p_source, CURRENT_DATE + INTERVAL '90 days')
  RETURNING id INTO v_batch_id;

  -- Audit entry
  INSERT INTO coin_transactions (user_id, transaction_id, batch_id, type, amount, description)
  VALUES (p_user_id, p_transaction_id, v_batch_id, p_source, p_amount, 'Coins awarded: ' || p_source);

  -- Update balance
  UPDATE momo_coin_balances
  SET available_coins = available_coins + p_amount,
      total_coins     = total_coins + p_amount,
      updated_at      = NOW()
  WHERE user_id = p_user_id;

  RETURN v_batch_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =========================================================
-- COINS: redeem_coins_fifo
-- Atomically deducts from oldest non-expired batches (FIFO).
-- =========================================================
CREATE OR REPLACE FUNCTION redeem_coins_fifo(
  p_user_id        VARCHAR,
  p_amount         DECIMAL,
  p_transaction_id UUID
)
RETURNS VOID AS $$
DECLARE
  v_remaining   DECIMAL := p_amount;
  v_batch       RECORD;
  v_deduct      DECIMAL;
BEGIN
  FOR v_batch IN
    SELECT id, amount
    FROM coin_batches
    WHERE user_id = p_user_id
      AND is_expired = false
      AND amount > 0
    ORDER BY created_at ASC  -- FIFO: oldest first
    FOR UPDATE
  LOOP
    EXIT WHEN v_remaining <= 0;

    v_deduct := LEAST(v_batch.amount, v_remaining);

    UPDATE coin_batches
    SET amount = amount - v_deduct
    WHERE id = v_batch.id;

    INSERT INTO coin_transactions (user_id, transaction_id, batch_id, type, amount, description)
    VALUES (p_user_id, p_transaction_id, v_batch.id, 'redeem', -v_deduct, 'Coins redeemed');

    v_remaining := v_remaining - v_deduct;
  END LOOP;

  IF v_remaining > 0 THEN
    RAISE EXCEPTION 'Insufficient coin balance. Remaining needed: %', v_remaining;
  END IF;

  -- Update aggregate balance
  UPDATE momo_coin_balances
  SET locked_coins    = locked_coins - p_amount,
      total_coins     = total_coins - p_amount,
      updated_at      = NOW()
  WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =========================================================
-- PAYMENT: process_transaction_success
-- THE critical function. Atomic. Zero partial state.
-- Called by payu-webhook edge function.
-- =========================================================
CREATE OR REPLACE FUNCTION process_transaction_success(
  p_transaction_id  UUID,
  p_mihpayid        VARCHAR,
  p_coins_to_award  DECIMAL
)
RETURNS VOID AS $$
DECLARE
  v_txn       transactions%ROWTYPE;
  v_merchant  merchants%ROWTYPE;
  v_commission DECIMAL;
  v_reward_cost DECIMAL;
BEGIN
  -- 1. Verify transaction is in 'pending' state (idempotency check)
  SELECT * INTO v_txn FROM transactions WHERE id = p_transaction_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Transaction not found: %', p_transaction_id;
  END IF;
  IF v_txn.status != 'pending' THEN
    RAISE EXCEPTION 'Transaction % is not pending (status: %)', p_transaction_id, v_txn.status;
  END IF;

  -- 2. Get merchant commission rate
  SELECT * INTO v_merchant FROM merchants WHERE id = v_txn.merchant_id;

  -- 3. Redeem coins (FIFO) — only if coins were applied
  IF v_txn.coins_applied > 0 THEN
    PERFORM redeem_coins_fifo(v_txn.user_id, v_txn.coins_applied, p_transaction_id);
  END IF;

  -- 4. Award new coins
  IF p_coins_to_award > 0 THEN
    PERFORM award_coins(v_txn.user_id, p_coins_to_award, p_transaction_id, 'earn');
  END IF;

  -- 5. Insert commission record
  v_commission  := v_txn.gross_amount * v_merchant.commission_rate;
  v_reward_cost := p_coins_to_award;   -- 1 coin = ₹1

  INSERT INTO commissions (transaction_id, merchant_id, total_commission, reward_cost, net_revenue)
  VALUES (p_transaction_id, v_txn.merchant_id, v_commission, v_reward_cost, v_commission - v_reward_cost);

  -- 6. Update transaction status → success
  UPDATE transactions
  SET status        = 'success',
      payu_mihpayid = p_mihpayid,
      completed_at  = NOW()
  WHERE id = p_transaction_id;

  -- Any error above causes full rollback (PostgreSQL transaction semantics)
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =========================================================
-- EXPIRY: expire_old_coins
-- Called daily by process-expiry edge function (pg_cron).
-- =========================================================
CREATE OR REPLACE FUNCTION expire_old_coins()
RETURNS JSONB AS $$
DECLARE
  v_batch       RECORD;
  v_batch_count INTEGER := 0;
  v_coin_total  DECIMAL := 0;
BEGIN
  FOR v_batch IN
    SELECT id, user_id, amount
    FROM coin_batches
    WHERE expiry_date < CURRENT_DATE
      AND is_expired = false
      AND amount > 0
    FOR UPDATE
  LOOP
    -- Mark batch expired
    UPDATE coin_batches SET is_expired = true WHERE id = v_batch.id;

    -- Audit entry
    INSERT INTO coin_transactions (user_id, batch_id, type, amount, description)
    VALUES (v_batch.user_id, v_batch.id, 'expire', -v_batch.amount, 'Coins expired (90-day limit)');

    -- Decrement balance
    UPDATE momo_coin_balances
    SET available_coins = available_coins - v_batch.amount,
        total_coins     = total_coins - v_batch.amount,
        updated_at      = NOW()
    WHERE user_id = v_batch.user_id;

    v_batch_count := v_batch_count + 1;
    v_coin_total  := v_coin_total + v_batch.amount;
  END LOOP;

  RETURN jsonb_build_object(
    'expired_batches',    v_batch_count,
    'total_coins_expired', v_coin_total
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =========================================================
-- REFERRALS: process_referral_reward
-- Atomically awards coins to both referrer and referee.
-- =========================================================
CREATE OR REPLACE FUNCTION process_referral_reward(p_referral_id UUID)
RETURNS VOID AS $$
DECLARE
  v_referral       referrals%ROWTYPE;
  v_referrer_coins DECIMAL;
  v_referee_coins  DECIMAL;
BEGIN
  SELECT * INTO v_referral FROM referrals WHERE id = p_referral_id FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Referral not found: %', p_referral_id;
  END IF;
  IF v_referral.status != 'pending' THEN
    RAISE EXCEPTION 'Referral % already processed (status: %)', p_referral_id, v_referral.status;
  END IF;

  -- Get coin amounts from app_config
  SELECT value::DECIMAL INTO v_referrer_coins FROM app_config WHERE key = 'referral_referrer_coins';
  SELECT value::DECIMAL INTO v_referee_coins  FROM app_config WHERE key = 'referral_referee_coins';

  -- Award referrer
  PERFORM award_coins(v_referral.referrer_id, v_referrer_coins, NULL, 'referral_reward');
  -- Award referee
  PERFORM award_coins(v_referral.referee_id,  v_referee_coins,  NULL, 'referral_reward');

  -- Mark referral completed
  UPDATE referrals
  SET status                 = 'completed',
      referrer_coins_awarded = v_referrer_coins,
      referee_coins_awarded  = v_referee_coins,
      completed_at           = NOW()
  WHERE id = p_referral_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =========================================================
-- ADMIN: get_coverage_ratio
-- Returns (reserve_pool / total_coin_liability) × 100
-- =========================================================
CREATE OR REPLACE FUNCTION get_coverage_ratio()
RETURNS DECIMAL AS $$
DECLARE
  v_reserve      DECIMAL;
  v_liability    DECIMAL;
BEGIN
  SELECT value::DECIMAL INTO v_reserve FROM app_config WHERE key = 'reserve_pool_balance';
  SELECT COALESCE(SUM(total_coins), 0) INTO v_liability FROM momo_coin_balances;

  IF v_liability = 0 THEN RETURN 100; END IF;
  RETURN ROUND((v_reserve / v_liability) * 100, 2);
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- =========================================================
-- ADMIN: admin_adjust_coins
-- Manual credit/debit for fraud remediation or promotions.
-- =========================================================
CREATE OR REPLACE FUNCTION admin_adjust_coins(
  p_user_id    VARCHAR,
  p_amount     DECIMAL,   -- positive = credit, negative = debit
  p_reason     TEXT
)
RETURNS VOID AS $$
BEGIN
  -- Must be admin
  IF NOT is_admin() THEN
    RAISE EXCEPTION 'Unauthorized: admin role required';
  END IF;

  IF p_amount > 0 THEN
    PERFORM award_coins(p_user_id, p_amount, NULL, 'admin_adjustment');
  ELSE
    -- Debit: create audit entry and reduce balance directly
    INSERT INTO coin_transactions (user_id, type, amount, description)
    VALUES (p_user_id, 'admin_adjustment', p_amount, p_reason);

    UPDATE momo_coin_balances
    SET available_coins = GREATEST(0, available_coins + p_amount),
        total_coins     = GREATEST(0, total_coins + p_amount),
        updated_at      = NOW()
    WHERE user_id = p_user_id;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
