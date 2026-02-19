-- Migration: Firebase Phone Auth → Supabase Native Auth
-- Date: February 15, 2026
-- Purpose: Remove Firebase dependencies and prepare for Email/Password + Google Sign-In

-- ============================================================================
-- STEP 1: BACKUP EXISTING DATA
-- ============================================================================

-- Backup users table
CREATE TABLE IF NOT EXISTS users_backup_20260215 AS 
SELECT * FROM users;

-- Backup user_mappings table
CREATE TABLE IF NOT EXISTS user_mappings_backup_20260215 AS 
SELECT * FROM user_mappings;

COMMENT ON TABLE users_backup_20260215 IS 'Backup before Supabase auth migration';
COMMENT ON TABLE user_mappings_backup_20260215 IS 'Backup before Supabase auth migration';

-- ============================================================================
-- STEP 2: DROP FIREBASE-SPECIFIC TABLE
-- ============================================================================

-- Drop user_mappings table (no longer needed with native Supabase auth)
DROP TABLE IF EXISTS user_mappings CASCADE;

-- ============================================================================
-- STEP 3: UPDATE USERS TABLE SCHEMA
-- ============================================================================

-- Drop Firebase-specific column
ALTER TABLE users DROP COLUMN IF EXISTS firebase_uid CASCADE;

-- Drop phone_number (will re-add via Supabase Phone Auth later if needed)
ALTER TABLE users DROP COLUMN IF EXISTS phone_number CASCADE;

-- Add email column (required for Supabase auth)
ALTER TABLE users ADD COLUMN IF NOT EXISTS email TEXT UNIQUE;

-- Add name column (user-friendly display name)
ALTER TABLE users ADD COLUMN IF NOT EXISTS name TEXT;

-- Add avatar URL (from Google OAuth or uploaded)
ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- Update users table comment
COMMENT ON TABLE users IS 'Public user profiles linked to Supabase auth.users via ID';
COMMENT ON COLUMN users.id IS 'Matches Supabase auth.uid() - UUID from auth.users table';
COMMENT ON COLUMN users.email IS 'User email from Supabase auth';
COMMENT ON COLUMN users.name IS 'Display name (from OAuth or user input)';

-- ============================================================================
-- STEP 4: UPDATE RLS POLICIES
-- ============================================================================

-- Drop old policies
DROP POLICY IF EXISTS "Users can view own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Admins can view all users" ON users;
DROP POLICY IF EXISTS "Admins can insert users" ON users;

-- Recreate with direct auth.uid() (no mapping needed!)
CREATE POLICY "Users can view own profile"
ON users FOR SELECT
USING (id = auth.uid());

CREATE POLICY "Users can update own profile"
ON users FOR UPDATE
USING (id = auth.uid())
WITH CHECK (id = auth.uid() AND role = 'customer'); -- Can't change own role

CREATE POLICY "Users can insert own profile"
ON users FOR INSERT
WITH CHECK (id = auth.uid());

-- Admins can view all
CREATE POLICY "Admins can view all users"
ON users FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Admins can insert/update any user
CREATE POLICY "Admins can insert users"
ON users FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  )
);

CREATE POLICY "Admins can update users"
ON users FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  )
);

-- ============================================================================
-- STEP 5: AUTO-INITIALIZE COIN BALANCE ON USER SIGNUP
-- ============================================================================

-- Function to create coin balance when user is created
CREATE OR REPLACE FUNCTION create_user_balance()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO momo_coin_balances (user_id, total_coins, available_coins, locked_coins)
  VALUES (NEW.id, 0, 0, 0)
  ON CONFLICT (user_id) DO NOTHING;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION create_user_balance IS 'Auto-creates coin balance when user signs up';

-- Trigger to execute function after user insert
DROP TRIGGER IF EXISTS on_user_created ON users;
CREATE TRIGGER on_user_created
  AFTER INSERT ON users
  FOR EACH ROW
  EXECUTE FUNCTION create_user_balance();

-- ============================================================================
-- STEP 6: OPTIONAL - CREATE FUNCTION TO SYNC AUTH.USERS TO PUBLIC.USERS
-- ============================================================================

-- This function can be called via edge function or database webhook
-- to automatically create public user record when Supabase auth user is created
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, name, avatar_url, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', NEW.email),
    NEW.raw_user_meta_data->>'avatar_url',
    'customer'
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    name = COALESCE(EXCLUDED.name, users.name),
    avatar_url = COALESCE(EXCLUDED.avatar_url, users.avatar_url);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger on auth.users table (Supabase internal)
-- This triggers when someone signs up via Supabase auth
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

COMMENT ON FUNCTION handle_new_user IS 'Auto-creates public user profile when Supabase auth user signs up';

-- ============================================================================
-- STEP 7: GRANT PERMISSIONS
-- ============================================================================

-- Ensure authenticated users can insert into users table
GRANT INSERT ON users TO authenticated;
GRANT UPDATE ON users TO authenticated;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check current users (should show email column now)
-- SELECT id, email, name, role, created_at FROM users LIMIT 5;

-- Check coin balances are preserved
-- SELECT user_id, available_coins FROM momo_coin_balances LIMIT 5;

-- Check RLS policies
-- SELECT schemaname, tablename, policyname FROM pg_policies WHERE tablename = 'users';

-- ============================================================================
-- ROLLBACK SCRIPT (if needed)
-- ============================================================================

/*
-- To rollback this migration:

-- Restore users table
DROP TABLE users;
CREATE TABLE users AS SELECT * FROM users_backup_20260215;

-- Restore user_mappings
CREATE TABLE user_mappings AS SELECT * FROM user_mappings_backup_20260215;

-- Drop new trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS on_user_created ON users;
DROP FUNCTION IF EXISTS handle_new_user();
DROP FUNCTION IF EXISTS create_user_balance();

*/
