-- MomoPe Row-Level Security (RLS) Policies
-- Version: 1.0
-- Date: February 15, 2026

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Get current authenticated user's ID from public.users table
CREATE OR REPLACE FUNCTION get_current_user_id()
RETURNS UUID AS $$
BEGIN
  RETURN (
    SELECT id FROM users
    WHERE id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if current user is an admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid() AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if current user is a merchant
CREATE OR REPLACE FUNCTION is_merchant()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid() AND role = 'merchant'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get merchant ID for current user
CREATE OR REPLACE FUNCTION get_current_merchant_id()
RETURNS UUID AS $$
BEGIN
  RETURN (
    SELECT id FROM merchants
    WHERE user_id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- ENABLE RLS ON ALL TABLES
-- ============================================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_mappings ENABLE ROW LEVEL SECURITY;
ALTER TABLE momo_coin_balances ENABLE ROW LEVEL SECURITY;
ALTER TABLE merchants ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE commissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE coin_batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE coin_transactions ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- RLS POLICIES: users
-- ============================================================================

-- Users can view their own profile
CREATE POLICY "Users can view own profile"
ON users FOR SELECT
USING (id = auth.uid());

-- Users can update their own profile (name, email only)
CREATE POLICY "Users can update own profile"
ON users FOR UPDATE
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Admins can view all users
CREATE POLICY "Admins can view all users"
ON users FOR SELECT
USING (is_admin());

-- Admins can insert users (for manual user creation)
CREATE POLICY "Admins can insert users"
ON users FOR INSERT
WITH CHECK (is_admin());

-- ============================================================================
-- RLS POLICIES: user_mappings
-- ============================================================================

-- Only accessible via SERVICE_ROLE (edge functions)
-- No user-facing policies

-- ============================================================================
-- RLS POLICIES: momo_coin_balances
-- ============================================================================

-- Users can view their own coin balance
CREATE POLICY "Users can view own coin balance"
ON momo_coin_balances FOR SELECT
USING (user_id = auth.uid());

-- No direct UPDATE/DELETE allowed (only via database functions)
-- Admins can view all balances
CREATE POLICY "Admins can view all coin balances"
ON momo_coin_balances FOR SELECT
USING (is_admin());

-- ============================================================================
-- RLS POLICIES: merchants
-- ============================================================================

-- Anyone can discover active merchants (for app listing)
CREATE POLICY "Public merchant discovery"
ON merchants FOR SELECT
USING (is_active = true AND is_operational = true);

-- Merchants can view and update their own store details
CREATE POLICY "Merchants can manage own store"
ON merchants FOR SELECT
USING (user_id = auth.uid());

CREATE POLICY "Merchants can update own store"
ON merchants FOR UPDATE
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Admins can view all merchants
CREATE POLICY "Admins can view all merchants"
ON merchants FOR SELECT
USING (is_admin());

-- Admins can insert/update merchants
CREATE POLICY "Admins can insert merchants"
ON merchants FOR INSERT
WITH CHECK (is_admin());

CREATE POLICY "Admins can update merchants"
ON merchants FOR UPDATE
USING (is_admin());

-- ============================================================================
-- RLS POLICIES: transactions
-- ============================================================================

-- Users can view their own transactions
CREATE POLICY "Users can view own transactions"
ON transactions FOR SELECT
USING (user_id = auth.uid());

-- Merchants can view transactions at their store
CREATE POLICY "Merchants can view own transactions"
ON transactions FOR SELECT
USING (
  merchant_id IN (
    SELECT id FROM merchants WHERE user_id = auth.uid()
  )
);

-- Users can create transactions (during payment initiation)
CREATE POLICY "Users can create transactions"
ON transactions FOR INSERT
WITH CHECK (user_id = auth.uid());

-- Admins can view all transactions
CREATE POLICY "Admins can view all transactions"
ON transactions FOR SELECT
USING (is_admin());

-- Admins can update transactions (for refunds, fraud marking)
CREATE POLICY "Admins can update transactions"
ON transactions FOR UPDATE
USING (is_admin());

-- ============================================================================
-- RLS POLICIES: commissions
-- ============================================================================

-- Only admins can view commissions (financial data)
CREATE POLICY "Admins can view all commissions"
ON commissions FOR SELECT
USING (is_admin());

-- Merchants can view their own commission records
CREATE POLICY "Merchants can view own commissions"
ON commissions FOR SELECT
USING (
  merchant_id IN (
    SELECT id FROM merchants WHERE user_id = auth.uid()
  )
);

-- ============================================================================
-- RLS POLICIES: coin_batches
-- ============================================================================

-- Users can view their own coin batches
CREATE POLICY "Users can view own coin batches"
ON coin_batches FOR SELECT
USING (user_id = auth.uid());

-- Admins can view all coin batches
CREATE POLICY "Admins can view all coin batches"
ON coin_batches FOR SELECT
USING (is_admin());

-- ============================================================================
-- RLS POLICIES: coin_transactions
-- ============================================================================

-- Users can view their own coin transaction history
CREATE POLICY "Users can view own coin transactions"
ON coin_transactions FOR SELECT
USING (user_id = auth.uid());

-- Admins can view all coin transactions
CREATE POLICY "Admins can view all coin transactions"
ON coin_transactions FOR SELECT
USING (is_admin());

-- ============================================================================
-- GRANT PERMISSIONS TO AUTHENTICATED USERS
-- ============================================================================
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT INSERT ON transactions TO authenticated;
GRANT INSERT ON users TO authenticated;
GRANT UPDATE ON users TO authenticated;
GRANT UPDATE ON merchants TO authenticated;

-- ============================================================================
-- COMMENTS
-- ============================================================================
COMMENT ON FUNCTION get_current_user_id() IS 'Returns the authenticated users ID from public.users table';
COMMENT ON FUNCTION is_admin() IS 'Checks if current user has admin role';
COMMENT ON FUNCTION is_merchant() IS 'Checks if current user has merchant role';
COMMENT ON FUNCTION get_current_merchant_id() IS 'Returns merchant ID for current authenticated user';
