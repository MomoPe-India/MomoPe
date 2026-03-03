-- Migration: 007_merchant_discovery_rpcs.sql
-- Date: 2026-03-02
-- Purpose: 
--   1. get_nearby_merchants(lat, lon) — location-based discovery
--   2. Update get_customer_home_data to include featured_merchants

-- ── 1. Nearby Merchants ────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION get_nearby_merchants(lat FLOAT, lon FLOAT)
RETURNS JSONB AS $$
  SELECT COALESCE(jsonb_agg(sub ORDER BY sub.distance_km), '[]'::jsonb)
  FROM (
    SELECT 
      id,
      business_name,
      category,
      latitude,
      longitude,
      ROUND(
        (6371 * acos(
          LEAST(1.0, cos(radians(lat)) * cos(radians(latitude)) *
          cos(radians(longitude) - radians(lon)) +
          sin(radians(lat)) * sin(radians(latitude)))
        ))::numeric, 2
      )::float AS distance_km
    FROM merchants
    WHERE kyc_status = 'approved' 
      AND is_active = true
      AND latitude IS NOT NULL 
      AND longitude IS NOT NULL
    ORDER BY distance_km
    LIMIT 5
  ) sub
$$ LANGUAGE sql SECURITY DEFINER;

-- ── 2. Update get_customer_home_data to include featured_merchants ─────────────

CREATE OR REPLACE FUNCTION get_customer_home_data(firebase_uid TEXT)
RETURNS JSONB AS $$
DECLARE
  v_balance JSONB;
  v_today_earnings DECIMAL(10,2);
  v_expiring DECIMAL(10,2);
  v_referral JSONB;
  v_recent_txns JSONB;
  v_featured_merchants JSONB;
BEGIN
  -- 1. Balance
  SELECT jsonb_build_object(
    'available_coins', COALESCE(available_coins, 0),
    'locked_coins', COALESCE(locked_coins, 0),
    'total_coins', COALESCE(total_coins, 0)
  ) INTO v_balance
  FROM momo_coin_balances
  WHERE user_id = firebase_uid;

  IF v_balance IS NULL THEN
    v_balance := jsonb_build_object('available_coins', 0, 'locked_coins', 0, 'total_coins', 0);
  END IF;

  -- 2. Today's Earnings
  SELECT COALESCE(SUM(amount), 0) INTO v_today_earnings
  FROM coin_transactions
  WHERE user_id = firebase_uid 
    AND amount > 0 
    AND created_at::date = CURRENT_DATE;

  -- 3. Expiring Coins (within 7 days)
  SELECT COALESCE(SUM(amount), 0) INTO v_expiring
  FROM coin_batches
  WHERE user_id = firebase_uid
    AND is_expired = false
    AND expiry_date <= CURRENT_DATE + INTERVAL '7 days'
    AND amount > 0;

  -- 4. Referral Stats
  SELECT jsonb_build_object(
    'referral_code', u.referral_code,
    'total_referrals', COALESCE(rs.total_referrals, 0),
    'completed_referrals', COALESCE(rs.completed_referrals, 0),
    'total_coins_earned', COALESCE(rs.total_coins_earned, 0)
  ) INTO v_referral
  FROM users u
  LEFT JOIN referral_stats rs ON rs.user_id = u.id
  WHERE u.id = firebase_uid;

  -- 5. Recent Transactions (last 3)
  SELECT COALESCE(jsonb_agg(
    jsonb_build_object(
      'id', t.id,
      'merchant_name', m.business_name,
      'fiat_amount', t.fiat_amount,
      'coins_applied', t.coins_applied,
      'status', t.status,
      'created_at', t.created_at,
      'coins_earned', (
         SELECT COALESCE(SUM(amount), 0) 
         FROM coin_transactions ct 
         WHERE ct.transaction_id = t.id AND ct.amount > 0
      )
    ) ORDER BY t.created_at DESC
  ), '[]'::jsonb) INTO v_recent_txns
  FROM (
    SELECT * FROM transactions 
    WHERE user_id = firebase_uid 
    ORDER BY created_at DESC 
    LIMIT 3
  ) t
  JOIN merchants m ON t.merchant_id = m.id;

  -- 6. Featured Merchants (latest 3 approved, active)
  SELECT COALESCE(jsonb_agg(
    jsonb_build_object(
      'id', id,
      'business_name', business_name,
      'category', category,
      'latitude', latitude,
      'longitude', longitude
    ) ORDER BY created_at DESC
  ), '[]'::jsonb) INTO v_featured_merchants
  FROM (
    SELECT id, business_name, category, latitude, longitude, created_at
    FROM merchants
    WHERE kyc_status = 'approved' AND is_active = true
    ORDER BY created_at DESC
    LIMIT 3
  ) fm;

  RETURN jsonb_build_object(
    'balance', v_balance,
    'today_earnings', v_today_earnings,
    'expiring', v_expiring,
    'referral', v_referral,
    'recent_transactions', v_recent_txns,
    'featured_merchants', v_featured_merchants
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
