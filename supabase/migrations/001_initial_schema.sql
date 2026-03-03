-- Migration: 001_initial_schema.sql
-- Date: 2026-02-26
-- Author: MomoPe Team
-- Purpose: Create all core tables, indexes, constraints, triggers, and views
-- Rollback: See individual DROP statements at bottom of this file

-- =========================================================
-- Extensions
-- =========================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";   -- bcrypt verify_pin (Approach B)
CREATE EXTENSION IF NOT EXISTS "pg_cron";    -- daily coin expiry job

-- =========================================================
-- 1. users
-- =========================================================
CREATE TABLE IF NOT EXISTS users (
  -- Identity (Firebase UID — NOT a UUID)
  id                    VARCHAR(128)  PRIMARY KEY,      -- Firebase UID (e.g., "abc123XYZ")

  -- Profile
  name                  VARCHAR(100),
  phone                 VARCHAR(15)   UNIQUE NOT NULL,  -- 10-digit only, no +91
  role                  VARCHAR(20)   NOT NULL DEFAULT 'customer',

  -- PIN Authentication (PhonePe-style)
  pin_hash              TEXT,                           -- bcrypt hash; NULL = not set yet
  pin_failed_attempts   INTEGER       NOT NULL DEFAULT 0,
  pin_locked_until      TIMESTAMPTZ,                   -- NULL = not locked

  -- Referral
  referral_code         VARCHAR(10)   UNIQUE,
  referred_by           VARCHAR(128)  REFERENCES users(id),

  -- Metadata
  created_at            TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

  CONSTRAINT valid_role   CHECK (role IN ('customer', 'merchant', 'admin')),
  CONSTRAINT valid_phone  CHECK (phone ~ '^\d{10}$')   -- exactly 10 digits
);

CREATE INDEX IF NOT EXISTS idx_users_phone    ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_referral ON users(referral_code);
CREATE INDEX IF NOT EXISTS idx_users_role     ON users(role);

-- =========================================================
-- 2. momo_coin_balances
-- =========================================================
CREATE TABLE IF NOT EXISTS momo_coin_balances (
  id               UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          VARCHAR(128)   UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  total_coins      DECIMAL(10,2)  NOT NULL DEFAULT 0,
  available_coins  DECIMAL(10,2)  NOT NULL DEFAULT 0,
  locked_coins     DECIMAL(10,2)  NOT NULL DEFAULT 0,
  updated_at       TIMESTAMPTZ    NOT NULL DEFAULT NOW(),

  CONSTRAINT positive_total        CHECK (total_coins    >= 0),
  CONSTRAINT positive_available    CHECK (available_coins >= 0),
  CONSTRAINT positive_locked       CHECK (locked_coins   >= 0),
  CONSTRAINT balance_integrity     CHECK (total_coins = available_coins + locked_coins)
);

-- =========================================================
-- 3. merchants
-- =========================================================
CREATE TABLE IF NOT EXISTS merchants (
  id                        UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                   VARCHAR(128)  UNIQUE NOT NULL REFERENCES users(id),
  business_name             VARCHAR(200)  NOT NULL,
  category                  VARCHAR(50)   NOT NULL,
  commission_rate           DECIMAL(5,4)  NOT NULL DEFAULT 0.20,

  -- KYC
  gstin                     VARCHAR(15),
  pan                       VARCHAR(10),
  business_address          TEXT,
  kyc_status                VARCHAR(20)   NOT NULL DEFAULT 'pending',
  kyc_rejection_reason      TEXT,

  -- Bank (fiat settlement)
  bank_account_number       VARCHAR(20),
  ifsc_code                 VARCHAR(11),
  bank_account_holder_name  VARCHAR(100),

  -- Location
  latitude                  DECIMAL(10,8),
  longitude                 DECIMAL(11,8),

  -- Flags
  is_active                 BOOLEAN       NOT NULL DEFAULT true,
  is_operational            BOOLEAN       NOT NULL DEFAULT true,

  created_at                TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at                TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

  CONSTRAINT valid_commission  CHECK (commission_rate >= 0.15 AND commission_rate <= 0.50),
  CONSTRAINT valid_category    CHECK (category IN ('grocery', 'food_beverage', 'retail', 'services', 'other')),
  CONSTRAINT valid_kyc_status  CHECK (kyc_status IN ('pending', 'approved', 'rejected'))
);

CREATE INDEX IF NOT EXISTS idx_merchants_user_id  ON merchants(user_id);
CREATE INDEX IF NOT EXISTS idx_merchants_active   ON merchants(is_active, kyc_status)   WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_merchants_location ON merchants(latitude, longitude)      WHERE is_active = true;

-- =========================================================
-- 4. transactions
-- =========================================================
CREATE TABLE IF NOT EXISTS transactions (
  id               UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          VARCHAR(128)   NOT NULL REFERENCES users(id),
  merchant_id      UUID           NOT NULL REFERENCES merchants(id),

  -- Amounts
  gross_amount     DECIMAL(10,2)  NOT NULL,                     -- total bill
  fiat_amount      DECIMAL(10,2)  NOT NULL,                     -- paid via PayU
  coins_applied    DECIMAL(10,2)  NOT NULL DEFAULT 0,           -- coins redeemed

  -- PayU
  payu_txnid       VARCHAR(100)   UNIQUE,
  payu_mihpayid    VARCHAR(100),

  -- Status
  status           VARCHAR(20)    NOT NULL DEFAULT 'initiated',

  created_at       TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
  completed_at     TIMESTAMPTZ,
  settled_at       TIMESTAMPTZ,

  CONSTRAINT positive_gross    CHECK (gross_amount  >  0),
  CONSTRAINT positive_fiat     CHECK (fiat_amount   >= 0),
  CONSTRAINT positive_coins    CHECK (coins_applied >= 0),
  CONSTRAINT amount_integrity  CHECK (gross_amount = fiat_amount + coins_applied),
  CONSTRAINT valid_status      CHECK (status IN ('initiated', 'pending', 'success', 'failed', 'refunded'))
);

CREATE INDEX IF NOT EXISTS idx_txn_user     ON transactions(user_id,      created_at DESC);
CREATE INDEX IF NOT EXISTS idx_txn_merchant ON transactions(merchant_id,  created_at DESC);
CREATE INDEX IF NOT EXISTS idx_txn_status   ON transactions(status,       created_at DESC);
CREATE INDEX IF NOT EXISTS idx_txn_payu     ON transactions(payu_txnid);

-- =========================================================
-- 5. commissions
-- =========================================================
CREATE TABLE IF NOT EXISTS commissions (
  id                    UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id        UUID           UNIQUE NOT NULL REFERENCES transactions(id),
  merchant_id           UUID           NOT NULL REFERENCES merchants(id),

  total_commission      DECIMAL(10,2)  NOT NULL,   -- gross_amount × commission_rate
  reward_cost           DECIMAL(10,2)  NOT NULL,   -- coins_awarded × 1 (1 coin = ₹1)
  net_revenue           DECIMAL(10,2)  NOT NULL,   -- total_commission - reward_cost

  is_settled            BOOLEAN        NOT NULL DEFAULT false,
  settlement_batch_id   UUID,

  created_at            TIMESTAMPTZ    NOT NULL DEFAULT NOW(),

  CONSTRAINT valid_commission_math CHECK (net_revenue = total_commission - reward_cost)
);

CREATE INDEX IF NOT EXISTS idx_comm_merchant  ON commissions(merchant_id);
CREATE INDEX IF NOT EXISTS idx_comm_unsettled ON commissions(is_settled, created_at) WHERE is_settled = false;

-- =========================================================
-- 6. coin_batches
-- =========================================================
CREATE TABLE IF NOT EXISTS coin_batches (
  id               UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          VARCHAR(128)   NOT NULL REFERENCES users(id),
  transaction_id   UUID           REFERENCES transactions(id),

  amount           DECIMAL(10,2)  NOT NULL,           -- current remaining
  original_amount  DECIMAL(10,2)  NOT NULL,           -- immutable original

  source           VARCHAR(50)    NOT NULL,
  expiry_date      DATE           NOT NULL,            -- created_at::date + 90 days
  is_expired       BOOLEAN        NOT NULL DEFAULT false,

  created_at       TIMESTAMPTZ    NOT NULL DEFAULT NOW(),

  CONSTRAINT positive_amount CHECK (amount >= 0),
  CONSTRAINT valid_source    CHECK (source IN ('earn', 'bonus', 'refund', 'referral_reward', 'admin_adjustment'))
);

CREATE INDEX IF NOT EXISTS idx_batches_fifo   ON coin_batches(user_id, created_at ASC) WHERE is_expired = false AND amount > 0;
CREATE INDEX IF NOT EXISTS idx_batches_expiry ON coin_batches(expiry_date)             WHERE is_expired = false;

-- =========================================================
-- 7. coin_transactions  (immutable audit log — never UPDATE or DELETE)
-- =========================================================
CREATE TABLE IF NOT EXISTS coin_transactions (
  id               UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          VARCHAR(128)   NOT NULL REFERENCES users(id),
  transaction_id   UUID           REFERENCES transactions(id),
  batch_id         UUID           REFERENCES coin_batches(id),

  type             VARCHAR(20)    NOT NULL,
  amount           DECIMAL(10,2)  NOT NULL,   -- positive = credit, negative = debit
  description      TEXT,

  created_at       TIMESTAMPTZ    NOT NULL DEFAULT NOW(),

  CONSTRAINT valid_coin_type CHECK (type IN ('earn', 'redeem', 'expire', 'bonus', 'refund', 'referral_reward', 'admin_adjustment'))
);

CREATE INDEX IF NOT EXISTS idx_coin_txn_user ON coin_transactions(user_id, created_at DESC);

-- =========================================================
-- 8. referrals
-- =========================================================
CREATE TABLE IF NOT EXISTS referrals (
  id                      UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  referrer_id             VARCHAR(128)  NOT NULL REFERENCES users(id),
  referee_id              VARCHAR(128)  NOT NULL REFERENCES users(id),

  status                  VARCHAR(20)   NOT NULL DEFAULT 'pending',

  referrer_coins_awarded  DECIMAL(10,2) NOT NULL DEFAULT 0,
  referee_coins_awarded   DECIMAL(10,2) NOT NULL DEFAULT 0,
  reward_transaction_id   UUID          REFERENCES transactions(id),

  created_at              TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  completed_at            TIMESTAMPTZ,

  CONSTRAINT unique_referee   UNIQUE (referee_id),
  CONSTRAINT different_users  CHECK  (referrer_id != referee_id),
  CONSTRAINT valid_ref_status CHECK  (status IN ('pending', 'completed', 'invalid'))
);

-- =========================================================
-- 9. app_config  (runtime business rules — avoids re-deploys)
-- =========================================================
CREATE TABLE IF NOT EXISTS app_config (
  key        VARCHAR(100) PRIMARY KEY,
  value      TEXT         NOT NULL,
  description TEXT,
  updated_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- Seed with defaults
INSERT INTO app_config (key, value, description) VALUES
  ('referral_referrer_coins',  '50',    'Coins awarded to referrer on referee first transaction'),
  ('referral_referee_coins',   '25',    'Coins awarded to referee on their first transaction'),
  ('coverage_ratio_minimum',   '60',    'Minimum coverage ratio % (alert if below)'),
  ('reserve_pool_balance',     '0',     'Manual reserve pool balance in INR (updated by admin)')
ON CONFLICT DO NOTHING;

-- =========================================================
-- 10. referral_stats VIEW
-- =========================================================
CREATE OR REPLACE VIEW referral_stats AS
SELECT
  r.referrer_id                                        AS user_id,
  COUNT(*)                                             AS total_referrals,
  COUNT(*) FILTER (WHERE r.status = 'completed')       AS completed_referrals,
  COALESCE(SUM(r.referrer_coins_awarded), 0)           AS total_coins_earned
FROM referrals r
GROUP BY r.referrer_id;

-- =========================================================
-- Triggers
-- =========================================================

-- Auto-create coin balance row when user is inserted
CREATE OR REPLACE FUNCTION on_user_created()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO momo_coin_balances (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_on_user_created ON users;
CREATE TRIGGER trg_on_user_created
  AFTER INSERT ON users
  FOR EACH ROW EXECUTE FUNCTION on_user_created();

-- Auto-update updated_at on users
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_users_updated_at ON users;
CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_merchants_updated_at ON merchants;
CREATE TRIGGER trg_merchants_updated_at
  BEFORE UPDATE ON merchants
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_balances_updated_at ON momo_coin_balances;
CREATE TRIGGER trg_balances_updated_at
  BEFORE UPDATE ON momo_coin_balances
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- ROLLBACK (for reference)
-- =========================================================
-- DROP VIEW IF EXISTS referral_stats;
-- DROP TABLE IF EXISTS referrals, coin_transactions, coin_batches, commissions, transactions, merchants, momo_coin_balances, app_config, users CASCADE;
-- DROP EXTENSION IF EXISTS pg_cron;
-- DROP EXTENSION IF EXISTS pgcrypto;
