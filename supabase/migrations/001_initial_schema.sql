-- MomoPe Database Schema - Initial Migration
-- Version: 1.0
-- Date: February 15, 2026

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- TABLE: users
-- Purpose: Store all user profiles (customers, merchants, admins)
-- ============================================================================
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  firebase_uid VARCHAR(255) UNIQUE NOT NULL,
  phone_number VARCHAR(20) UNIQUE NOT NULL,
  role VARCHAR(20) NOT NULL DEFAULT 'customer',
  name VARCHAR(100),
  email VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT valid_role CHECK (role IN ('customer', 'merchant', 'admin'))
);

-- ============================================================================
-- TABLE: user_mappings
-- Purpose: Map Firebase UID to Supabase user_id (for dual auth)
-- ============================================================================
CREATE TABLE user_mappings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  firebase_uid VARCHAR(255) UNIQUE NOT NULL,
  supabase_user_id UUID UNIQUE NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- TABLE: momo_coin_balances
-- Purpose: Store aggregate coin balances for each user
-- ============================================================================
CREATE TABLE momo_coin_balances (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE NOT NULL REFERENCES users(id),
  total_coins DECIMAL(10,2) NOT NULL DEFAULT 0,
  available_coins DECIMAL(10,2) NOT NULL DEFAULT 0,
  locked_coins DECIMAL(10,2) NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Constraints to prevent negative balances
  CONSTRAINT positive_total CHECK (total_coins >= 0),
  CONSTRAINT positive_available CHECK (available_coins >= 0),
  CONSTRAINT positive_locked CHECK (locked_coins >= 0),
  CONSTRAINT balance_integrity CHECK (total_coins = available_coins + locked_coins)
);

-- ============================================================================
-- TABLE: merchants
-- Purpose: Store merchant business information
-- ============================================================================
CREATE TABLE merchants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE NOT NULL REFERENCES users(id),
  business_name VARCHAR(200) NOT NULL,
  category VARCHAR(50) NOT NULL,
  commission_rate DECIMAL(5,4) NOT NULL DEFAULT 0.20,
  
  -- Business details
  gstin VARCHAR(15),
  pan VARCHAR(10),
  business_address TEXT,
  
  -- Banking details
  bank_account_number VARCHAR(20),
  ifsc_code VARCHAR(11),
  bank_account_holder_name VARCHAR(100),
  
  -- Location
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  
  -- Status
  is_active BOOLEAN DEFAULT true,
  is_operational BOOLEAN DEFAULT true,
  kyc_status VARCHAR(20) DEFAULT 'pending',
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT valid_commission_rate CHECK (commission_rate >= 0.10 AND commission_rate <= 0.50),
  CONSTRAINT valid_category CHECK (category IN ('grocery', 'food_beverage', 'retail', 'services', 'other')),
  CONSTRAINT valid_kyc_status CHECK (kyc_status IN ('pending', 'approved', 'rejected'))
);

-- ============================================================================
-- TABLE: transactions
-- Purpose: Store all payment transactions
-- ============================================================================
CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id),
  merchant_id UUID NOT NULL REFERENCES merchants(id),
  
  -- Transaction amounts
  gross_amount DECIMAL(10,2) NOT NULL,
  fiat_amount DECIMAL(10,2) NOT NULL,
  coins_applied DECIMAL(10,2) NOT NULL DEFAULT 0,
  
  -- Payment details
  payu_txnid VARCHAR(100) UNIQUE,
  payu_mihpayid VARCHAR(100),
  status VARCHAR(20) NOT NULL DEFAULT 'initiated',
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  settled_at TIMESTAMPTZ,
  
  -- Constraints to ensure transaction integrity
  CONSTRAINT positive_gross CHECK (gross_amount > 0),
  CONSTRAINT positive_fiat CHECK (fiat_amount >= 0),
  CONSTRAINT positive_coins_applied CHECK (coins_applied >= 0),
  CONSTRAINT amount_integrity CHECK (gross_amount = fiat_amount + coins_applied),
  CONSTRAINT valid_status CHECK (status IN ('initiated', 'pending', 'success', 'failed', 'refunded'))
);

-- ============================================================================
-- TABLE: commissions
-- Purpose: Store commission breakdown for each transaction
-- ============================================================================
CREATE TABLE commissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  transaction_id UUID UNIQUE NOT NULL REFERENCES transactions(id),
  merchant_id UUID NOT NULL REFERENCES merchants(id),
  
  -- Commission breakdown
  total_commission DECIMAL(10,2) NOT NULL,
  reward_cost DECIMAL(10,2) NOT NULL,
  net_revenue DECIMAL(10,2) NOT NULL,
  
  -- Settlement tracking
  is_settled BOOLEAN DEFAULT false,
  settlement_batch_id UUID,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT valid_commission_math CHECK (net_revenue = total_commission - reward_cost)
);

-- ============================================================================
-- TABLE: coin_batches
-- Purpose: Track coin batches for FIFO expiry (90 days)
-- ============================================================================
CREATE TABLE coin_batches (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id),
  amount DECIMAL(10,2) NOT NULL,
  original_amount DECIMAL(10,2) NOT NULL,
  source VARCHAR(50) NOT NULL,
  transaction_id UUID REFERENCES transactions(id),
  
  -- Expiry tracking
  expiry_date DATE NOT NULL,
  is_expired BOOLEAN DEFAULT false,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT positive_amount CHECK (amount >= 0),
  CONSTRAINT valid_source CHECK (source IN ('earn', 'bonus', 'refund', 'admin_adjustment'))
);

-- ============================================================================
-- TABLE: coin_transactions
-- Purpose: Audit trail of all coin movements
-- ============================================================================
CREATE TABLE coin_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id),
  transaction_id UUID REFERENCES transactions(id),
  batch_id UUID REFERENCES coin_batches(id),
  
  type VARCHAR(20) NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  description TEXT,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT valid_type CHECK (type IN ('earn', 'redeem', 'expire', 'bonus', 'refund', 'admin_adjustment'))
);

-- ============================================================================
-- INDEXES for Performance Optimization
-- ============================================================================
CREATE INDEX idx_users_firebase_uid ON users(firebase_uid);
CREATE INDEX idx_users_phone ON users(phone_number);
CREATE INDEX idx_merchants_active ON merchants(is_active, is_operational) WHERE is_active = true;
CREATE INDEX idx_merchants_location ON merchants(latitude, longitude) WHERE is_active = true;
CREATE INDEX idx_transactions_user ON transactions(user_id, created_at DESC);
CREATE INDEX idx_transactions_merchant ON transactions(merchant_id, created_at DESC);
CREATE INDEX idx_transactions_status ON transactions(status, created_at DESC);
CREATE INDEX idx_coin_batches_expiry ON coin_batches(user_id, expiry_date, is_expired) WHERE is_expired = false;
CREATE INDEX idx_coin_batches_user_created ON coin_batches(user_id, created_at);
CREATE INDEX idx_coin_transactions_user ON coin_transactions(user_id, created_at DESC);

-- ============================================================================
-- TRIGGERS for automated timestamp updates
-- ============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_merchants_updated_at BEFORE UPDATE ON merchants
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_balances_updated_at BEFORE UPDATE ON momo_coin_balances
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- Initialize admin user (placeholder - update with actual Firebase UID later)
-- ============================================================================
COMMENT ON TABLE users IS 'All user profiles including customers, merchants, and admins';
COMMENT ON TABLE momo_coin_balances IS 'Aggregate coin balances with integrity constraints';
COMMENT ON TABLE merchants IS 'Merchant business information and banking details';
COMMENT ON TABLE transactions IS 'All payment transactions with PayU integration';
COMMENT ON TABLE commissions IS 'Commission breakdown and settlement tracking';
COMMENT ON TABLE coin_batches IS 'FIFO coin expiry tracking (90 days)';
COMMENT ON TABLE coin_transactions IS 'Complete audit trail of coin movements';
