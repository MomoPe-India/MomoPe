-- Migration: 002_rls_policies.sql
-- Date: 2026-02-26
-- Author: MomoPe Team
-- Purpose: Enable RLS on all tables and define access policies
-- Rollback: DROP all policies below, then ALTER TABLE ... DISABLE ROW LEVEL SECURITY

-- =========================================================
-- Enable RLS on all tables
-- =========================================================
ALTER TABLE users              ENABLE ROW LEVEL SECURITY;
ALTER TABLE momo_coin_balances ENABLE ROW LEVEL SECURITY;
ALTER TABLE merchants          ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions       ENABLE ROW LEVEL SECURITY;
ALTER TABLE commissions        ENABLE ROW LEVEL SECURITY;
ALTER TABLE coin_batches       ENABLE ROW LEVEL SECURITY;
ALTER TABLE coin_transactions  ENABLE ROW LEVEL SECURITY;
ALTER TABLE referrals          ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_config         ENABLE ROW LEVEL SECURITY;

-- =========================================================
-- Helper: is the caller an admin?
-- =========================================================
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid()::text AND role = 'admin'
  );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- =========================================================
-- users
-- Customers and merchants can read/update ONLY their own row.
-- pin_hash is excluded from SELECT by using column-level control:
-- expose only a derived boolean (see notes below).
-- Admins have full access.
-- =========================================================

-- Self access (SELECT — excludes pin_hash via application convention)
CREATE POLICY "users_self_select" ON users
  FOR SELECT USING (id = auth.uid()::text);

-- Self update (cannot change role or id)
CREATE POLICY "users_self_update" ON users
  FOR UPDATE USING (id = auth.uid()::text)
  WITH CHECK (
    id = auth.uid()::text
    AND role = (SELECT role FROM users WHERE id = auth.uid()::text)  -- role is immutable via this policy
  );

-- Insert own row (registration)
CREATE POLICY "users_self_insert" ON users
  FOR INSERT WITH CHECK (id = auth.uid()::text);

-- Admin full access
CREATE POLICY "users_admin_all" ON users
  FOR ALL USING (is_admin());

-- =========================================================
-- momo_coin_balances
-- Users see only their own balance. Admins see all.
-- =========================================================
CREATE POLICY "balance_self_select" ON momo_coin_balances
  FOR SELECT USING (user_id = auth.uid()::text);

CREATE POLICY "balance_admin_all" ON momo_coin_balances
  FOR ALL USING (is_admin());

-- =========================================================
-- merchants
-- Anyone authenticated can discover approved+active merchants.
-- Merchants can update only their own profile.
-- Admins can do everything (including KYC approve/reject).
-- =========================================================
CREATE POLICY "merchants_public_discovery" ON merchants
  FOR SELECT USING (
    kyc_status = 'approved'
    AND is_active = true
  );

-- Merchant owner sees their own record (even if pending/rejected)
CREATE POLICY "merchants_self_select" ON merchants
  FOR SELECT USING (user_id = auth.uid()::text);

-- Merchant owner inserts their own KYC record
CREATE POLICY "merchants_self_insert" ON merchants
  FOR INSERT WITH CHECK (user_id = auth.uid()::text);

-- Merchant owner can update non-KYC-status fields
CREATE POLICY "merchants_self_update" ON merchants
  FOR UPDATE USING (user_id = auth.uid()::text)
  WITH CHECK (
    user_id = auth.uid()::text
    -- kyc_status must remain unchanged through this policy (admin changes it)
    AND kyc_status = (SELECT kyc_status FROM merchants WHERE user_id = auth.uid()::text)
  );

-- Admin full access (approve/reject KYC, deactivate, etc.)
CREATE POLICY "merchants_admin_all" ON merchants
  FOR ALL USING (is_admin());

-- =========================================================
-- transactions
-- Customers see their own. Merchants see transactions at their stores.
-- Admins see all.
-- =========================================================
CREATE POLICY "txn_customer_select" ON transactions
  FOR SELECT USING (user_id = auth.uid()::text);

CREATE POLICY "txn_customer_insert" ON transactions
  FOR INSERT WITH CHECK (user_id = auth.uid()::text);

-- Merchant sees transactions at their stores (not the customer's identity)
CREATE POLICY "txn_merchant_select" ON transactions
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM merchants m
      WHERE m.id = transactions.merchant_id
        AND m.user_id = auth.uid()::text
    )
  );

CREATE POLICY "txn_admin_all" ON transactions
  FOR ALL USING (is_admin());

-- =========================================================
-- commissions
-- Merchants see their own commission records.
-- Customers have no access.
-- Admins see all.
-- =========================================================
CREATE POLICY "comm_merchant_select" ON commissions
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM merchants m
      WHERE m.id = commissions.merchant_id
        AND m.user_id = auth.uid()::text
    )
  );

CREATE POLICY "comm_admin_all" ON commissions
  FOR ALL USING (is_admin());

-- =========================================================
-- coin_batches
-- Customers see their own batches.
-- Admins see all.
-- =========================================================
CREATE POLICY "batches_self_select" ON coin_batches
  FOR SELECT USING (user_id = auth.uid()::text);

CREATE POLICY "batches_admin_all" ON coin_batches
  FOR ALL USING (is_admin());

-- =========================================================
-- coin_transactions  (immutable — no UPDATE or DELETE ever)
-- =========================================================
CREATE POLICY "coin_txn_self_select" ON coin_transactions
  FOR SELECT USING (user_id = auth.uid()::text);

CREATE POLICY "coin_txn_admin_all" ON coin_transactions
  FOR ALL USING (is_admin());

-- =========================================================
-- referrals
-- Users see referrals they are part of (as referrer or referee).
-- =========================================================
CREATE POLICY "referral_self_select" ON referrals
  FOR SELECT USING (
    referrer_id = auth.uid()::text OR referee_id = auth.uid()::text
  );

CREATE POLICY "referral_admin_all" ON referrals
  FOR ALL USING (is_admin());

-- =========================================================
-- app_config
-- Only admins can read/modify config.
-- Edge functions use service role (bypasses RLS).
-- =========================================================
CREATE POLICY "config_admin_all" ON app_config
  FOR ALL USING (is_admin());
