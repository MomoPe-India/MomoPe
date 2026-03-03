# MomoPe — Database Schema Reference

**Version**: 2.0  
**Date**: February 2026  
**Database**: PostgreSQL 15 on Supabase (Mumbai)  
**Project Ref**: `wpnngcuoqtvgwhizkrwt`  
**Change from v1.0**: `users.id` is now a `VARCHAR` storing Firebase UID (not a UUID). Added `pin_hash`, `pin_failed_attempts`, `pin_locked_until` to `users`. Removed `user_mappings` dependency. Google Sign-In references removed.

---

## 1. Schema Overview

| # | Table / View | Purpose | RLS |
|---|--------------|---------|-----|
| 1 | `users` | All user profiles. `id` = Firebase UID. Includes PIN hash + lockout fields | ✅ |
| 2 | `momo_coin_balances` | Aggregate coin balance per user | ✅ |
| 3 | `merchants` | Business info, KYC, commission rates | ✅ |
| 4 | `transactions` | Payment records (PayU integration) | ✅ |
| 5 | `commissions` | Revenue ledger per transaction | ✅ |
| 6 | `coin_batches` | FIFO expiry tracking (90-day batches) | ✅ |
| 7 | `coin_transactions` | Immutable audit trail of all coin movements | ✅ |
| 8 | `referrals` | Referrer → Referee relationships | ✅ |
| 9 | `referral_stats` (VIEW) | Aggregated referral metrics per user | ✅ |

> **Note**: `user_mappings` table is fully deprecated and should not be referenced in any new code. It was a Firebase↔Supabase bridge that is no longer needed since Supabase now verifies Firebase JWTs directly via JWKS.

---

## 2. Entity Relationship Diagram

```
users (id=Firebase UID)
  ├──────────────────────────────▶ (1) momo_coin_balances
  ├──────────────────────────────▶ (many) transactions
  ├──────────────────────────────▶ (many) coin_batches
  ├──────────────────────────────▶ (many) coin_transactions
  ├──────────────────────────────▶ (1) merchants  [if merchant role]
  └──────────────────────────────▶ (many) referrals [as referrer or referee]

merchants (1) ─────────────────▶ (many) transactions
transactions (1) ───────────────▶ (1)    commissions
transactions (1) ───────────────▶ (many) coin_transactions
coin_batches (1) ───────────────▶ (many) coin_transactions
```

---

## 3. Table Definitions

### 3.1 `users`

Central identity table. `id` is the Firebase UID — the same value that `auth.uid()` returns in RLS policies.

```sql
CREATE TABLE users (
  -- Identity (Firebase UID — NOT a UUID)
  id                    VARCHAR(128)  PRIMARY KEY,  -- Firebase UID (e.g., "abc123XYZ")
  
  -- Profile
  name                  VARCHAR(100),
  phone                 VARCHAR(15)   UNIQUE NOT NULL,  -- 10-digit Indian mobile, stored as "9876543210"
  role                  VARCHAR(20)   NOT NULL DEFAULT 'customer',
  
  -- PIN Authentication (PhonePe-style)
  pin_hash              TEXT,                           -- bcrypt hash of PIN (NULL until PIN is set)
  pin_failed_attempts   INTEGER       NOT NULL DEFAULT 0,
  pin_locked_until      TIMESTAMPTZ,                   -- NULL = not locked
  
  -- Referral System
  referral_code         VARCHAR(10)   UNIQUE,
  referred_by           VARCHAR(128)  REFERENCES users(id),
  
  -- Metadata
  created_at            TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

  CONSTRAINT valid_role   CHECK (role IN ('customer', 'merchant', 'admin')),
  CONSTRAINT valid_phone  CHECK (phone ~ '^\d{10}$')  -- Exactly 10 digits
);

CREATE INDEX idx_users_phone    ON users(phone);
CREATE INDEX idx_users_referral ON users(referral_code);
CREATE INDEX idx_users_role     ON users(role);
```

**Column Notes**:

| Column | Notes |
|--------|-------|
| `id` | Firebase UID. Set by the app after OTP verification. `auth.uid()` in RLS = this value. |
| `phone` | Stored as 10 digits only, no country code prefix ("+91" stripped client-side). |
| `pin_hash` | bcrypt hash (cost=10). NULL = user hasn't set PIN yet (gated from home screen). |
| `pin_failed_attempts` | Incremented on wrong PIN entry. Reset to 0 on success or OTP re-verify. |
| `pin_locked_until` | Set to `NOW() + 30 seconds` on 5th failure. NULL = not locked. |
| `referral_code` | Auto-generated on INSERT (trigger or app-side, 6-8 alphanumeric chars). |

**Trigger: Initialize coin balance on user creation**:
```sql
CREATE OR REPLACE FUNCTION on_user_created()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO momo_coin_balances (user_id)
  VALUES (NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_on_user_created
  AFTER INSERT ON users
  FOR EACH ROW EXECUTE FUNCTION on_user_created();
```

---

### 3.2 `momo_coin_balances`

Aggregate coin balance. Created automatically via trigger when a user is inserted.

```sql
CREATE TABLE momo_coin_balances (
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
```

**Column Semantics**:
- `available_coins`: Freely redeemable
- `locked_coins`: Temporarily locked during an in-progress PayU payment (anti-double-spend)
- `total_coins`: Always = `available_coins + locked_coins` (DB-enforced constraint)

**Lock/Unlock Flow**:
```
Payment initiated  →  locked_coins += n,  available_coins -= n
Payment success    →  locked_coins -= n,  total_coins -= n  (via FIFO redeem)
Payment failed     →  locked_coins -= n,  available_coins += n  (rollback)
```

---

### 3.3 `merchants`

Business profiles. `user_id` references the merchant owner's Firebase UID.

```sql
CREATE TABLE merchants (
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

  -- Bank details (for fiat settlement)
  bank_account_number       VARCHAR(20),
  ifsc_code                 VARCHAR(11),
  bank_account_holder_name  VARCHAR(100),

  -- Location (merchant discovery)
  latitude                  DECIMAL(10,8),
  longitude                 DECIMAL(11,8),

  -- Flags
  is_active                 BOOLEAN       NOT NULL DEFAULT true,
  is_operational            BOOLEAN       NOT NULL DEFAULT true,

  created_at                TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at                TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

  CONSTRAINT valid_commission CHECK (commission_rate >= 0.15 AND commission_rate <= 0.50),
  CONSTRAINT valid_category   CHECK (category IN ('grocery', 'food_beverage', 'retail', 'services', 'other')),
  CONSTRAINT valid_kyc        CHECK (kyc_status IN ('pending', 'approved', 'rejected'))
);

CREATE INDEX idx_merchants_user_id  ON merchants(user_id);
CREATE INDEX idx_merchants_active   ON merchants(is_active, kyc_status) WHERE is_active = true;
CREATE INDEX idx_merchants_location ON merchants(latitude, longitude)    WHERE is_active = true;
```

**KYC Status Machine**:
```
pending ──[admin approve]──▶ approved
pending ──[admin reject] ──▶ rejected  (kyc_rejection_reason required)
rejected ──[merchant re-submits]──▶ pending
```

---

### 3.4 `transactions`

Every payment attempt through MomoPe.

```sql
CREATE TABLE transactions (
  id               UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          VARCHAR(128)   NOT NULL REFERENCES users(id),
  merchant_id      UUID           NOT NULL REFERENCES merchants(id),

  -- Amounts
  gross_amount     DECIMAL(10,2)  NOT NULL,   -- Total bill value
  fiat_amount      DECIMAL(10,2)  NOT NULL,   -- Paid via PayU
  coins_applied    DECIMAL(10,2)  NOT NULL DEFAULT 0,  -- Coins redeemed

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

CREATE INDEX idx_txn_user      ON transactions(user_id,     created_at DESC);
CREATE INDEX idx_txn_merchant  ON transactions(merchant_id, created_at DESC);
CREATE INDEX idx_txn_status    ON transactions(status,      created_at DESC);
CREATE INDEX idx_txn_payu      ON transactions(payu_txnid);
```

**Status Lifecycle**:
```
initiated ──[PayU SDK opened]─────▶ pending
pending   ──[Webhook: success] ───▶ success  →  process_transaction_success()
pending   ──[Webhook: failure] ───▶ failed   →  coins unlocked, no commission
success   ──[Admin: refund]    ───▶ refunded (exceptional, admin-only)
```

---

### 3.5 `commissions`

Revenue record for each successful transaction.

```sql
CREATE TABLE commissions (
  id                    UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id        UUID           UNIQUE NOT NULL REFERENCES transactions(id),
  merchant_id           UUID           NOT NULL REFERENCES merchants(id),

  total_commission      DECIMAL(10,2)  NOT NULL,   -- gross_amount × commission_rate
  reward_cost           DECIMAL(10,2)  NOT NULL,   -- coins_awarded × 1 (1 coin = ₹1)
  net_revenue           DECIMAL(10,2)  NOT NULL,   -- total_commission - reward_cost

  is_settled            BOOLEAN        NOT NULL DEFAULT false,
  settlement_batch_id   UUID,

  created_at            TIMESTAMPTZ    NOT NULL DEFAULT NOW(),

  CONSTRAINT valid_math CHECK (net_revenue = total_commission - reward_cost)
);

CREATE INDEX idx_comm_merchant  ON commissions(merchant_id);
CREATE INDEX idx_comm_unsettled ON commissions(is_settled, created_at) WHERE is_settled = false;
```

---

### 3.6 `coin_batches`

Each earn event creates one batch. FIFO: oldest batch deducted first on redemption.

```sql
CREATE TABLE coin_batches (
  id               UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          VARCHAR(128)   NOT NULL REFERENCES users(id),
  transaction_id   UUID           REFERENCES transactions(id),

  amount           DECIMAL(10,2)  NOT NULL,   -- Current remaining coins in this batch
  original_amount  DECIMAL(10,2)  NOT NULL,   -- Amount when created (immutable)

  source           VARCHAR(50)    NOT NULL,   -- How coins were earned
  expiry_date      DATE           NOT NULL,   -- created_at::date + 90 days
  is_expired       BOOLEAN        NOT NULL DEFAULT false,

  created_at       TIMESTAMPTZ    NOT NULL DEFAULT NOW(),

  CONSTRAINT positive_amount CHECK (amount >= 0),
  CONSTRAINT valid_source    CHECK (source IN ('earn', 'bonus', 'refund', 'referral_reward', 'admin_adjustment'))
);

CREATE INDEX idx_batches_fifo   ON coin_batches(user_id, created_at ASC) WHERE is_expired = false AND amount > 0;
CREATE INDEX idx_batches_expiry ON coin_batches(expiry_date)             WHERE is_expired = false;
```

---

### 3.7 `coin_transactions`

Immutable audit trail. Append-only. Every single coin movement is recorded here.

```sql
CREATE TABLE coin_transactions (
  id               UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          VARCHAR(128)   NOT NULL REFERENCES users(id),
  transaction_id   UUID           REFERENCES transactions(id),
  batch_id         UUID           REFERENCES coin_batches(id),

  type             VARCHAR(20)    NOT NULL,
  amount           DECIMAL(10,2)  NOT NULL,   -- Positive = credit, Negative = debit
  description      TEXT,

  created_at       TIMESTAMPTZ    NOT NULL DEFAULT NOW(),

  CONSTRAINT valid_type CHECK (type IN ('earn', 'redeem', 'expire', 'bonus', 'refund', 'referral_reward', 'admin_adjustment'))
);

CREATE INDEX idx_coin_txn_user ON coin_transactions(user_id, created_at DESC);
```

**Examples**:

| Event | type | amount |
|-------|------|--------|
| Coins earned on purchase | `earn` | +20.00 |
| Coins redeemed | `redeem` | -800.00 |
| Batch expired | `expire` | -50.00 |
| Referral reward credited | `referral_reward` | +50.00 |
| Admin manual credit | `admin_adjustment` | +100.00 |

> Records are **never updated or deleted**. This is a financial audit log.

---

### 3.8 `referrals`

```sql
CREATE TABLE referrals (
  id                      UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  referrer_id             VARCHAR(128)  NOT NULL REFERENCES users(id),
  referee_id              VARCHAR(128)  NOT NULL REFERENCES users(id),

  status                  VARCHAR(20)   NOT NULL DEFAULT 'pending',

  referrer_coins_awarded  DECIMAL(10,2) NOT NULL DEFAULT 0,
  referee_coins_awarded   DECIMAL(10,2) NOT NULL DEFAULT 0,
  reward_transaction_id   UUID          REFERENCES transactions(id),

  created_at              TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  completed_at            TIMESTAMPTZ,

  CONSTRAINT unique_referee   UNIQUE (referee_id),   -- One referral per person ever
  CONSTRAINT different_users  CHECK  (referrer_id != referee_id),
  CONSTRAINT valid_status     CHECK  (status IN ('pending', 'completed', 'invalid'))
);
```

---

### 3.9 `referral_stats` (VIEW)

```sql
CREATE VIEW referral_stats AS
SELECT
  r.referrer_id                                        AS user_id,
  COUNT(*)                                             AS total_referrals,
  COUNT(*) FILTER (WHERE r.status = 'completed')       AS completed_referrals,
  COALESCE(SUM(r.referrer_coins_awarded), 0)           AS total_coins_earned
FROM referrals r
GROUP BY r.referrer_id;
```

---

## 4. Stored Procedures

### `calculate_max_redeemable(p_user_id VARCHAR, p_bill_amount DECIMAL)`
Returns max coins redeemable (80/20 rule).
```sql
RETURNS DECIMAL AS $$
  SELECT LEAST(p_bill_amount * 0.80, available_coins * 0.80)
  FROM momo_coin_balances
  WHERE user_id = p_user_id;
$$ LANGUAGE sql STABLE;
```

### `redeem_coins_fifo(p_user_id VARCHAR, p_amount DECIMAL, p_transaction_id UUID)`
Atomically deducts coins from oldest non-expired batches first.
- Updates `coin_batches.amount` (FIFO order)
- Inserts `coin_transactions` (type=`redeem`)
- Decrements `momo_coin_balances` (locked_coins → total_coins)

### `award_coins(p_user_id VARCHAR, p_amount DECIMAL, p_transaction_id UUID, p_source VARCHAR)`
Creates a new coin batch (expiry = today + 90 days) and updates balances.
- Inserts `coin_batches`
- Inserts `coin_transactions` (type=`earn` or `referral_reward`)
- Increments `momo_coin_balances.available_coins`

### `process_transaction_success(p_transaction_id UUID, p_mihpayid VARCHAR, p_coins_to_award DECIMAL)`
**The most critical function. Atomic (PostgreSQL transaction). Zero partial state.**
1. Verify transaction is in `pending` status
2. Call `redeem_coins_fifo()` (if `coins_applied > 0`)
3. Call `award_coins()` (with algorithm-computed earn amount)
4. Insert `commissions` record
5. Update `transactions.status = 'success'`, `completed_at = NOW()`
6. Any error → full rollback

### `expire_old_coins()`
Called by `process-expiry` edge function (pg_cron daily):
- Marks `coin_batches WHERE expiry_date < CURRENT_DATE AND is_expired = false`
- Inserts `coin_transactions` (type=`expire`)
- Decrements `momo_coin_balances`

### `record_pin_failure(p_user_id VARCHAR)`
Increments `pin_failed_attempts`. If ≥ 5, sets `pin_locked_until = NOW() + 30 seconds`. If ≥ 10, sets `pin_locked_until = NULL` and returns a signal to force OTP re-verify.

### `reset_pin_failures(p_user_id VARCHAR)`
Sets `pin_failed_attempts = 0`, `pin_locked_until = NULL`.

### `process_referral_reward(p_referral_id UUID)`
Awards coins to referrer and referee atomically, marks referral as `completed`.

### `get_coverage_ratio()`
Returns `(reserve_pool_total / total_coin_liability) × 100`.

---

## 5. RLS Policy Summary

All tables use `auth.uid()` which equals the Firebase UID (a VARCHAR string).

| Table | Customer can | Merchant can | Admin can |
|-------|-------------|--------------|-----------|
| `users` | SELECT/UPDATE own row | SELECT/UPDATE own row | ALL |
| `momo_coin_balances` | SELECT own | — | ALL |
| `merchants` | SELECT approved (discovery) | SELECT/UPDATE own | ALL |
| `transactions` | SELECT/INSERT own | SELECT own merchant's | ALL |
| `commissions` | — | SELECT own merchant's | ALL |
| `coin_batches` | SELECT own | — | ALL |
| `coin_transactions` | SELECT own | — | ALL |
| `referrals` | SELECT own | — | ALL |

**Critical: PIN fields must NOT be readable by the user via standard SELECT**

```sql
-- Users can update their own pin_hash (after OTP verification)
CREATE POLICY "users_update_pin" ON users
  FOR UPDATE USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- BUT: Create a dedicated RPC for PIN verification instead of exposing pin_hash
-- Never expose pin_hash in a SELECT response
```

> Best practice: Use a PostgreSQL RPC (`verify_pin(user_id, pin_hash_from_client)`) that does the comparison server-side and returns only `{success: boolean}`. This prevents `pin_hash` from ever leaving the server.

**Recommended PIN verification RPC**:
```sql
CREATE OR REPLACE FUNCTION verify_pin(p_user_id VARCHAR, p_entered_hash TEXT)
RETURNS BOOLEAN AS $$
  SELECT pin_hash = p_entered_hash
  FROM users
  WHERE id = p_user_id;
$$ LANGUAGE sql STABLE SECURITY DEFINER;
```

*Note: Alternatively, bcrypt comparison can be done client-side after fetching the hash — both approaches are acceptable. Choose based on security preference at implementation time.*

---

## 6. Database Constraints Summary

| Constraint | Table | Rule |
|-----------|-------|------|
| `amount_integrity` | `transactions` | `gross_amount = fiat_amount + coins_applied` |
| `balance_integrity` | `momo_coin_balances` | `total_coins = available_coins + locked_coins` |
| `valid_commission_math` | `commissions` | `net_revenue = total_commission - reward_cost` |
| `valid_commission_rate` | `merchants` | `0.15 ≤ commission_rate ≤ 0.50` |
| `valid_phone` | `users` | `phone ~ '^\d{10}$'` |
| `unique_referee` | `referrals` | One referral record per referee ever |

---

## 7. Migration Naming Convention

```
NNN_description.sql  (zero-padded sequential number)

001_initial_schema.sql
002_add_rls_policies.sql
...
013_kyc_submit_rpc.sql
014_pin_lockout_fields.sql    ← Adds pin_failed_attempts, pin_locked_until to users
015_record_pin_failure_fn.sql ← Stored procedures for PIN lockout management
```

Run with: `supabase db push`

---

## 8. Key Changes from v1.0

| Item | v1.0 | v2.0 |
|------|------|------|
| `users.id` type | `UUID` (Supabase UUID) | `VARCHAR(128)` (Firebase UID) |
| Auth columns | none (handled by Supabase Auth) | `pin_hash`, `pin_failed_attempts`, `pin_locked_until` |
| `user_mappings` | In use (Firebase↔Supabase bridge) | Fully deprecated, not referenced |
| `users.avatar_url` | Present | Removed (no Google Sign-In profile photos) |
| `coin_batches.source` | `earn, bonus, refund, admin_adjustment` | Added `referral_reward` |
| `coin_transactions.type` | Same | Added `referral_reward` |
| Foreign key refs to users | `UUID REFERENCES users(id)` | `VARCHAR(128) REFERENCES users(id)` |

---

*Update this document whenever a new migration is applied or a schema change is made.*
