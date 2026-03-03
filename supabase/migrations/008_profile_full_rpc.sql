-- Migration: 008_profile_full_rpc.sql
-- Date: 2026-03-02
-- Purpose:
--   1. get_profile_full(firebase_uid) — single call for complete Profile Screen data
--   2. update_user_name(firebase_uid, new_name) — edit display name

-- ── 1. get_profile_full ───────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION get_profile_full(firebase_uid TEXT)
RETURNS JSONB AS $$
DECLARE
  v_user          JSONB;
  v_balance       JSONB;
  v_txn_count     INT;
  v_referral      JSONB;
  v_expiry        JSONB;
BEGIN
  -- User profile
  SELECT jsonb_build_object(
    'id',            u.id,
    'name',          u.name,
    'phone',         u.phone,
    'role',          u.role,
    'referral_code', u.referral_code,
    'referred_by',   u.referred_by,
    'created_at',    u.created_at
  ) INTO v_user
  FROM users u
  WHERE u.id = firebase_uid;

  IF v_user IS NULL THEN
    RETURN NULL;
  END IF;

  -- Coin balance
  SELECT jsonb_build_object(
    'total_coins',     COALESCE(total_coins, 0),
    'available_coins', COALESCE(available_coins, 0),
    'locked_coins',    COALESCE(locked_coins, 0)
  ) INTO v_balance
  FROM momo_coin_balances
  WHERE user_id = firebase_uid;

  IF v_balance IS NULL THEN
    v_balance := '{"total_coins":0,"available_coins":0,"locked_coins":0}'::jsonb;
  END IF;

  -- Completed transaction count (for tier calculation)
  SELECT COUNT(*) INTO v_txn_count
  FROM transactions
  WHERE user_id = firebase_uid AND status = 'COMPLETED';

  -- Referral stats
  SELECT jsonb_build_object(
    'total_referrals',     COALESCE(rs.total_referrals, 0),
    'completed_referrals', COALESCE(rs.completed_referrals, 0),
    'pending_referrals',   COALESCE(rs.total_referrals, 0) - COALESCE(rs.completed_referrals, 0),
    'coins_earned',        COALESCE(rs.total_coins_earned, 0)
  ) INTO v_referral
  FROM referral_stats rs
  WHERE rs.user_id = firebase_uid;

  IF v_referral IS NULL THEN
    v_referral := '{"total_referrals":0,"completed_referrals":0,"pending_referrals":0,"coins_earned":0}'::jsonb;
  END IF;

  -- Next expiry (nearest non-expired batch with remaining coins)
  SELECT jsonb_build_object(
    'expiry_date', cb.expiry_date,
    'amount',      cb.amount
  ) INTO v_expiry
  FROM coin_batches cb
  WHERE cb.user_id = firebase_uid
    AND cb.is_expired = false
    AND cb.amount > 0
    AND cb.expiry_date >= CURRENT_DATE
  ORDER BY cb.expiry_date ASC
  LIMIT 1;

  RETURN jsonb_build_object(
    'user',            v_user,
    'balance',         v_balance,
    'transaction_count', v_txn_count,
    'referral',        v_referral,
    'next_expiry',     v_expiry
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── 2. update_user_name ───────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION update_user_name(firebase_uid TEXT, new_name TEXT)
RETURNS VOID AS $$
BEGIN
  UPDATE users
  SET name = TRIM(new_name)
  WHERE id = firebase_uid
    AND TRIM(new_name) != '';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
