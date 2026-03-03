# MomoPe — Implementation Plan: Answers & Decisions

> **Answering**: AI Agent Implementation Plan (February 2026)  
> **Status**: All open questions resolved. Implementation can begin.

---

## ✅ Answers to Open Questions

---

### Q1 — PIN Length: **4 digits**

Go with **4 digits**. PhonePe uses 4. BHIM uses 4. Our users already have the muscle memory. 6 digits adds friction without meaningful security gain — bcrypt at cost=10 makes brute-forcing impossible regardless of length. Mixed-length adds unnecessary branching in validation logic. Settle on 4 everywhere and never revisit.

**Decision: `pin.length == 4` only. Remove all `pin.length != 4 && pin.length != 6` conditionals.**

---

### Q2 — PIN Verification Approach: **Approach A (Client-side)**

Use **Approach A** for MVP. The `$2b$` vs `$2a$` bcrypt prefix incompatibility with PostgreSQL `pgcrypto.crypt()` is a real risk and not worth debugging during the first sprint. We'd need a Deno bcrypt library in an edge function to do this cleanly server-side, which adds a dependency and latency.

**The practical flow for Approach A**:
1. On login, `SELECT pin_hash FROM users WHERE id = auth.uid()` — this is the only time `pin_hash` leaves the server.
2. Flutter calls `BCrypt.checkpw(enteredPin, fetchedHash)` locally.
3. Based on result, call `record_pin_failure(user_id)` or `reset_pin_failures(user_id)` RPC.

**To address Suggestion #5** (pin_hash exposure via SELECT): Add a dedicated column-level RLS or simply create a view that excludes `pin_hash` and point app queries there. At minimum, ensure the Flutter code only reads `pin_hash` during verification and never logs or stores it locally beyond the bcrypt comparison.

**Decision: Approach A. Drop `verify_pin` RPC from `003_stored_procedures.sql`. Keep `set_pin`, `record_pin_failure`, `reset_pin_failures`.**

---

### Q3 — Coin Earn Algorithm: **Pre-compute an estimate in `initiate-payment`, confirm in webhook**

Show the customer coins *before* they pay — this is a key part of the experience. Nobody wants to see "Calculating..." after handing over money.

**The flow**:
- `initiate-payment` pre-computes the earn rate using user tier and transaction value (same algorithm) and returns `coins_estimate` in the response.
- The payment screen shows: **"You'll earn ~20 coins"** (use the tilde `~` to make it an estimate).
- After PayU webhook fires and `process_transaction_success()` completes, the result screen shows the **actual** coins awarded (which should match the estimate 99% of the time).
- If there's a mismatch (edge case: liability threshold was crossed between initiate and webhook), the result screen simply shows the final confirmed number with no mention of the estimate.

**Decision: `initiate-payment` returns an additional field `coins_estimate: number`. Result screen always shows actual from webhook. No "Calculating..." state needed.**

---

### Q4 — Referral Coin Amounts: **Referrer = 50 coins (₹50), Referee = 25 coins (₹25)**

These are the launch amounts. Both are one-time, awarded only on the referee's **first successful transaction** (not on sign-up).

**Rationale**:
- ₹50 is a meaningful reward for the referrer — worth sharing.
- ₹25 gives the new user a head start without being too generous to game.
- The referee must complete an actual transaction to unlock the reward — prevents fake account referral farming.

**Implementation note**: As per Suggestion #2, store these in an `app_config` table so they can be changed without a code deploy:

```sql
INSERT INTO app_config (key, value) VALUES
  ('referral_referrer_coins', '50'),
  ('referral_referee_coins', '25');
```

The `process_referral_reward()` function should read from `app_config` rather than hardcoding these values.

**Decision: Referrer = 50 coins, Referee = 25 coins. Store in `app_config` table (add to Sprint 0 migrations).**

---

### Q5 — Reserve Pool Tracking: **Derive from `commissions` table, no separate table needed for MVP**

The reserve pool does not need its own table at launch. The `get_coverage_ratio()` function can derive everything it needs:

```sql
CREATE OR REPLACE FUNCTION get_coverage_ratio()
RETURNS DECIMAL AS $$
DECLARE
  total_liability DECIMAL;
  reserve_balance DECIMAL;
BEGIN
  -- Total outstanding coin liability = all available + locked coins
  SELECT COALESCE(SUM(available_coins + locked_coins), 0)
  INTO total_liability
  FROM momo_coin_balances;

  -- Reserve = accumulated net revenue (settled + unsettled commissions)
  -- This is MomoPe's earned money available to back coin liability
  SELECT COALESCE(SUM(net_revenue), 0)
  INTO reserve_balance
  FROM commissions;

  IF total_liability = 0 THEN RETURN 100; END IF;
  RETURN ROUND((reserve_balance / total_liability) * 100, 2);
END;
$$ LANGUAGE plpgsql STABLE;
```

The admin dashboard shows this live. When the business matures and we have a dedicated bank account for reserve, we can add a `reserve_pool` table with manual top-up entries. For now, `SUM(commissions.net_revenue)` is the reserve.

**Decision: No `reserve_pool` table at MVP. `get_coverage_ratio()` derives from `commissions`. Revisit in Phase 2 product roadmap.**

---

### Q6 — FCM Token Storage: **Yes, add `fcm_tokens` table in Sprint 0**

Add it now. Notifications are Sprint 5 but the table costs nothing to create early and avoids a migration mid-sprint later.

```sql
-- 004_fcm_tokens.sql
CREATE TABLE fcm_tokens (
  id           UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      VARCHAR(128) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  device_token TEXT         NOT NULL,
  platform     VARCHAR(10)  NOT NULL DEFAULT 'android',  -- 'android' | 'ios'
  created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

  CONSTRAINT valid_platform CHECK (platform IN ('android', 'ios')),
  CONSTRAINT unique_device_token UNIQUE (device_token)  -- one token per device
);

ALTER TABLE fcm_tokens ENABLE ROW LEVEL SECURITY;

-- Users can only upsert their own tokens
CREATE POLICY "fcm_own_access" ON fcm_tokens
  FOR ALL USING (user_id = auth.uid());
```

In Flutter, upsert the FCM token on every login (tokens rotate):
```dart
final token = await FirebaseMessaging.instance.getToken();
await supabase.from('fcm_tokens').upsert({
  'user_id': FirebaseAuth.instance.currentUser!.uid,
  'device_token': token,
  'platform': 'android',
}, onConflict: 'device_token');
```

**Decision: Add `004_fcm_tokens.sql` to Sprint 0 migrations. Unblock Sprint 5.**

---

### Q7 — Settlement Flow: **Manual admin action only for MVP**

For launch, settlements are **fully manual**. The admin dashboard shows all unsettled commission batches. The admin reviews, processes the bank transfer manually (NEFT/IMPS to the merchant's bank account stored in `merchants`), then marks the batch as settled in the dashboard.

**No automated payout pipeline at MVP.** Bank payout automation (via Razorpay Payouts or similar) is Phase 2 roadmap. Attempting to automate this at launch adds compliance complexity (payouts API licensing, reconciliation errors) that we don't need.

**Admin settlement flow (Sprint 4)**:
1. Admin views `settlements` page — lists merchants with unsettled commission totals.
2. Admin manually triggers bank transfer outside the system.
3. Admin clicks "Mark as Settled" → sets `commissions.is_settled = true`, `settlement_batch_id = generated UUID`, `settlements_at = NOW()` for the selected commission records.
4. Merchant app's settlement screen reflects the update.

**Decision: Manual admin settlement only. No payout API integration at MVP. Automated payouts → Phase 2.**

---

## ✅ Responses to Suggestions

| # | Suggestion | Decision |
|---|-----------|----------|
| **1** | Add `pgcrypto` extension check in first migration | ✅ **Accept** — add `CREATE EXTENSION IF NOT EXISTS pgcrypto;` to `001_initial_schema.sql`. Even if we use Approach A now, `pgcrypto` is already available in Supabase; having it enabled is harmless and future-proofs server-side hashing. |
| **2** | `app_config` table for referral amounts, earn rates | ✅ **Accept** — add to Sprint 0 (`001_initial_schema.sql` or a `005_app_config.sql`). Seed with referral amounts (50/25) and keep earn rates there too (`earn_rate_new=10`, `earn_rate_engaged=9`, etc.). The webhook edge function reads config at runtime. |
| **3** | Add `updated_at` trigger on all tables | ✅ **Accept** — create a reusable `set_updated_at()` trigger function once and attach it to `merchants`, `coin_batches`, `fcm_tokens`, and any other tables missing it. Add to `003_stored_procedures.sql`. |
| **4** | Add `fcm_tokens` table now | ✅ **Accept** — answered in Q6 above. |
| **5** | Explicitly exclude `pin_hash` from SELECT policies | ✅ **Accept** — use a column-level approach: the app must only `SELECT pin_hash` in `PinService.verifyPin()` and nowhere else. Add a note in the RLS migration comments. For extra safety, consider creating a `users_safe` view that excludes `pin_hash` and using it for all general user profile reads. |
| **6** | Add `gross_amount` minimum check ≥ ₹1 | ✅ **Accept** — update the transactions constraint: `CONSTRAINT min_gross CHECK (gross_amount >= 1.00)`. PayU's minimum transaction is ₹1. Also add a check in `initiate-payment` edge function before touching the DB. |
| **7** | Test `$2b$` vs `$2a$` bcrypt prefix | ✅ **Noted but moot** — since we chose Approach A (client-side verification), this is no longer a blocker. The Dart `bcrypt` library handles its own hashing and verification consistently. Document this for future reference if Approach B is ever revisited. |

---

## Updated Migration Sequence (Sprint 0)

```
001_initial_schema.sql      ← includes: pgcrypto extension, gross_amount ≥ 1 constraint,
                                        on_user_created trigger, updated_at triggers
002_rls_policies.sql        ← includes: pin_hash column exclusion note, fcm_tokens policy
003_stored_procedures.sql   ← drop verify_pin RPC (Approach A), keep set_pin,
                                record_pin_failure, reset_pin_failures, all coin functions,
                                updated get_coverage_ratio() (from commissions)
004_fcm_tokens.sql
005_app_config.sql          ← referral_referrer_coins=50, referral_referee_coins=25,
                                earn_rate_new=10, earn_rate_engaged=9,
                                earn_rate_regular=8, earn_rate_loyal=7,
                                earn_rate_liability_penalty=2, earn_rate_high_value_bonus=1,
                                earn_liability_threshold=100000
006_pgcron_expiry_job.sql
```

---

## Summary of Key Decisions

| Decision | Choice |
|----------|--------|
| PIN length | **4 digits** |
| PIN verification | **Approach A** (client-side bcrypt) |
| Coin display before payment | **Pre-computed estimate** shown in payment screen |
| Referral — referrer coins | **50 coins (₹50)** |
| Referral — referee coins | **25 coins (₹25)** |
| Referral trigger | **Referee's first successful transaction only** |
| Referral amounts storage | **`app_config` table** (not hardcoded) |
| Reserve pool | **Derived from `SUM(commissions.net_revenue)`** — no separate table |
| FCM tokens | **New `fcm_tokens` table added in Sprint 0** |
| Settlement | **Manual admin action only** — automated payouts in Phase 2 |
| `pgcrypto` extension | **Enable in migration 001** |
| `app_config` table | **Add in Sprint 0** with all earn rates + referral amounts |
| `updated_at` triggers | **Add for all tables** in migration 003 |
| `gross_amount` minimum | **≥ ₹1.00** (DB constraint + edge function check) |

---

*All questions resolved. Sprint 0 can begin.*
