-- Migration: Referral System
-- Date: February 20, 2026
-- Purpose: Add referral tracking, auto-code generation, and coin credit logic

-- ============================================================================
-- STEP 1: Add referral columns to users table
-- ============================================================================

ALTER TABLE users
  ADD COLUMN IF NOT EXISTS referral_code TEXT UNIQUE,
  ADD COLUMN IF NOT EXISTS referred_by UUID REFERENCES users(id) ON DELETE SET NULL;

COMMENT ON COLUMN users.referral_code IS 'Unique 8-char referral code (auto-generated on insert)';
COMMENT ON COLUMN users.referred_by IS 'User ID of whoever referred this user at signup';

-- ============================================================================
-- STEP 2: Auto-generate referral code on new user creation
-- ============================================================================

CREATE OR REPLACE FUNCTION generate_referral_code()
RETURNS TRIGGER AS $$
DECLARE
  base_code TEXT;
  final_code TEXT;
  counter INT := 0;
BEGIN
  -- Use first 8 chars of UUID (no dashes), uppercase
  base_code := UPPER(SUBSTRING(REPLACE(NEW.id::text, '-', ''), 1, 8));
  final_code := base_code;

  -- Handle (rare) collision: append counter
  WHILE EXISTS (SELECT 1 FROM users WHERE referral_code = final_code AND id != NEW.id) LOOP
    counter := counter + 1;
    final_code := UPPER(SUBSTRING(REPLACE(NEW.id::text, '-', ''), 1, 6)) || LPAD(counter::text, 2, '0');
  END LOOP;

  NEW.referral_code := final_code;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Backfill existing users who have no referral code
UPDATE users
SET referral_code = UPPER(SUBSTRING(REPLACE(id::text, '-', ''), 1, 8))
WHERE referral_code IS NULL;

DROP TRIGGER IF EXISTS set_referral_code ON users;
CREATE TRIGGER set_referral_code
  BEFORE INSERT ON users
  FOR EACH ROW
  WHEN (NEW.referral_code IS NULL)
  EXECUTE FUNCTION generate_referral_code();

-- ============================================================================
-- STEP 3: Referrals tracking table
-- ============================================================================

CREATE TABLE IF NOT EXISTS referrals (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  referrer_id   UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  referee_id    UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status        TEXT        NOT NULL DEFAULT 'pending',  -- pending | rewarded
  rewarded_at   TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Core duplicate-prevention constraints
  CONSTRAINT unique_referee       UNIQUE (referee_id),   -- one referrer per new user
  CONSTRAINT no_self_referral     CHECK  (referrer_id != referee_id),
  CONSTRAINT valid_referral_status CHECK (status IN ('pending', 'rewarded'))
);

CREATE INDEX IF NOT EXISTS idx_referrals_referrer ON referrals(referrer_id, status);
CREATE INDEX IF NOT EXISTS idx_referrals_referee  ON referrals(referee_id);

COMMENT ON TABLE referrals IS 'Tracks referral relationships and reward status';

-- ============================================================================
-- STEP 4: Row Level Security for referrals
-- ============================================================================

ALTER TABLE referrals ENABLE ROW LEVEL SECURITY;

-- Users can see referrals where they are the referrer (their invited friends list)
CREATE POLICY "Referrers can view own referrals"
  ON referrals FOR SELECT
  USING (auth.uid() = referrer_id);

-- Users can see their own referee record (who referred them)
CREATE POLICY "Referees can view their own record"
  ON referrals FOR SELECT
  USING (auth.uid() = referee_id);

-- Only service-role (edge function) can INSERT/UPDATE — no direct client writes
-- This is enforced by NOT creating insert/update policies for authenticated role.

-- Admins can see all referrals
CREATE POLICY "Admins can view all referrals"
  ON referrals FOR SELECT
  USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
  );

-- ============================================================================
-- STEP 5: Referral stats view (for efficient home-screen stats card)
-- ============================================================================

CREATE OR REPLACE VIEW referral_stats AS
SELECT
  r.referrer_id                                     AS user_id,
  COUNT(*)                                          AS friends_invited,
  COUNT(*) FILTER (WHERE r.status = 'rewarded')     AS friends_rewarded,
  COUNT(*) FILTER (WHERE r.status = 'rewarded') * 50 AS coins_earned_from_referrals
FROM referrals r
GROUP BY r.referrer_id;

COMMENT ON VIEW referral_stats IS 'Aggregated referral stats per user for the home screen stats card';

-- Grant read access to authenticated users (RLS on referrals still enforces row-level)
GRANT SELECT ON referral_stats TO authenticated;

-- ============================================================================
-- STEP 6: Function to process referral reward (called by Edge Function)
-- ============================================================================

CREATE OR REPLACE FUNCTION process_referral_reward(p_referee_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_referral     referrals%ROWTYPE;
  v_expiry_date  DATE := CURRENT_DATE + INTERVAL '90 days';
  v_ref_batch_id UUID;
  v_ee_batch_id  UUID;
BEGIN
  -- 1. Find the pending referral for this referee
  SELECT * INTO v_referral
  FROM referrals
  WHERE referee_id = p_referee_id AND status = 'pending'
  FOR UPDATE;  -- Lock row to prevent concurrent processing

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'reason', 'no_pending_referral');
  END IF;

  -- 2. Credit referrer: 50 coins (coin_batches + coin_transactions + balance)
  INSERT INTO coin_batches (user_id, amount, original_amount, source, expiry_date)
  VALUES (v_referral.referrer_id, 50, 50, 'bonus', v_expiry_date)
  RETURNING id INTO v_ref_batch_id;

  INSERT INTO coin_transactions (user_id, batch_id, type, amount, description)
  VALUES (v_referral.referrer_id, v_ref_batch_id, 'bonus', 50,
          'Referral reward: friend made first payment');

  UPDATE momo_coin_balances
  SET total_coins     = total_coins + 50,
      available_coins = available_coins + 50,
      updated_at      = NOW()
  WHERE user_id = v_referral.referrer_id;

  -- 3. Credit referee: 50 welcome bonus coins
  INSERT INTO coin_batches (user_id, amount, original_amount, source, expiry_date)
  VALUES (p_referee_id, 50, 50, 'bonus', v_expiry_date)
  RETURNING id INTO v_ee_batch_id;

  INSERT INTO coin_transactions (user_id, batch_id, type, amount, description)
  VALUES (p_referee_id, v_ee_batch_id, 'bonus', 50,
          'Welcome bonus: first payment via referral');

  UPDATE momo_coin_balances
  SET total_coins     = total_coins + 50,
      available_coins = available_coins + 50,
      updated_at      = NOW()
  WHERE user_id = p_referee_id;

  -- 4. Mark referral as rewarded (idempotency guard)
  UPDATE referrals
  SET status      = 'rewarded',
      rewarded_at = NOW()
  WHERE id = v_referral.id;

  RETURN jsonb_build_object(
    'success',      true,
    'referrer_id',  v_referral.referrer_id,
    'referee_id',   p_referee_id,
    'coins_each',   50
  );

EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('success', false, 'reason', SQLERRM);
END;
$$;

COMMENT ON FUNCTION process_referral_reward IS
  'Credits 50 coins to both referrer and referee on first qualifying payment. Idempotent.';

-- Only service role can call this directly
REVOKE EXECUTE ON FUNCTION process_referral_reward(UUID) FROM PUBLIC;
GRANT  EXECUTE ON FUNCTION process_referral_reward(UUID) TO service_role;

-- ============================================================================
-- STEP 7: Grants
-- ============================================================================

GRANT SELECT ON referrals TO authenticated;
GRANT SELECT ON users     TO authenticated;  -- For referral code lookup
