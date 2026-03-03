# MomoPe — API & Edge Function Contracts

**Version**: 2.0  
**Date**: February 2026  
**Base URL**: `https://wpnngcuoqtvgwhizkrwt.supabase.co/functions/v1`  
**Change from v1.0**: All `Authorization` headers now carry Firebase ID Tokens (not Supabase JWTs). Phone number is the only identity. PIN verification added as an RPC.

---

## Overview

MomoPe's API surface has two layers:

**1. PostgREST Auto-API** — Auto-generated REST endpoints for all tables. RLS enforces access using `auth.uid()` = Firebase UID. All calls must include the Firebase ID Token as the Bearer token.

**2. Edge Functions** — Custom Deno/TypeScript functions for business-critical operations (payment initiation, webhook, expiry, referrals, notifications).

---

## Global Conventions

### Authentication — Firebase JWT

Every API call (except PayU webhook and internal cron functions) must include:
```
Authorization: Bearer <firebase-id-token>
Content-Type: application/json
```

The Firebase ID Token is obtained from:
```dart
final token = await FirebaseAuth.instance.currentUser!.getIdToken(true);
```

Token is RS256-signed by Google. Supabase verifies it via JWKS endpoint:
```
https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com
```

`auth.uid()` in all RLS policies = `sub` claim from the Firebase JWT = Firebase UID.

### Response Envelope

Success:
```json
{ "success": true, "data": { ... } }
```
Error:
```json
{ "success": false, "error": "Human-readable message", "code": "ERROR_CODE" }
```

### Error Codes

| Code | Meaning |
|------|---------|
| `UNAUTHORIZED` | Missing or invalid Firebase JWT |
| `FORBIDDEN` | Valid JWT but insufficient role |
| `NOT_FOUND` | Resource doesn't exist |
| `INVALID_INPUT` | Validation failed |
| `MERCHANT_NOT_APPROVED` | KYC pending or rejected |
| `INSUFFICIENT_BALANCE` | Fewer coins than requested |
| `TRANSACTION_CONFLICT` | Transaction in unexpected state |
| `PAYMENT_HASH_MISMATCH` | PayU webhook HMAC invalid |
| `PIN_LOCKED` | Too many wrong PIN attempts; user is locked |
| `CUSTOMER_ACCOUNT` | Customer tried to log into Merchant App |
| `INTERNAL_ERROR` | Unhandled server error |

---

## Auth RPCs (PostgREST via `supabase.rpc()`)

These are PostgreSQL stored procedures called directly via the Supabase client. No edge function needed.

---

### RPC: `create_user_profile`

Called immediately after Firebase Phone Auth OTP verification, before PIN is set. Creates the user record in `users`.

```dart
await supabase.rpc('create_user_profile', params: {
  'firebase_uid': FirebaseAuth.instance.currentUser!.uid,
  'phone':        '9876543210',   // stripped of +91
  'name':         'Ravi Kumar',
  'referral_code_used': 'MOHAN10' // nullable
});
```

**SQL (SECURITY DEFINER)**:
```sql
CREATE OR REPLACE FUNCTION create_user_profile(
  firebase_uid TEXT,
  phone TEXT,
  name TEXT,
  referral_code_used TEXT DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
  INSERT INTO users (id, phone, name, role, referral_code)
  VALUES (
    firebase_uid,
    phone,
    name,
    'customer',
    generate_referral_code()   -- e.g., "RAVI7X2K"
  )
  ON CONFLICT (id) DO NOTHING;  -- idempotent: safe to call again

  -- Handle referral linkage
  IF referral_code_used IS NOT NULL THEN
    UPDATE users SET referred_by = (
      SELECT id FROM users WHERE referral_code = referral_code_used LIMIT 1
    )
    WHERE id = firebase_uid AND referred_by IS NULL;

    -- Insert referral record if referrer found
    INSERT INTO referrals (referrer_id, referee_id)
    SELECT u.id, firebase_uid
    FROM users u
    WHERE u.referral_code = referral_code_used
    ON CONFLICT (referee_id) DO NOTHING;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

### RPC: `set_pin`

Called after OTP verification (first time) or after forgot-PIN OTP verification.

```dart
await supabase.rpc('set_pin', params: {
  'pin_hash': bcrypt.hashpw(enteredPin, bcrypt.gensalt(logRounds: 10)),
});
```

**Note**: `bcrypt.hashpw` runs on the Flutter device. The hash is transmitted, never the plain PIN.

```sql
CREATE OR REPLACE FUNCTION set_pin(pin_hash TEXT)
RETURNS VOID AS $$
BEGIN
  UPDATE users
  SET pin_hash              = pin_hash,
      pin_failed_attempts   = 0,
      pin_locked_until      = NULL,
      updated_at            = NOW()
  WHERE id = auth.uid();  -- RLS: only own record
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

### RPC: `verify_pin`

Called on every app open (returning user). Returns status and whether force re-OTP is required.

```dart
final result = await supabase.rpc('verify_pin', params: {
  'entered_hash': bcrypt.hashpw(enteredPin, storedSalt),
  // OR: pass the entered pin and let server do full bcrypt.checkpw
});
```

**Important**: Two valid approaches for PIN verification:

**Approach A (Client-side verify — simpler)**:
1. Fetch `pin_hash` from `users` (one query)
2. Client calls `bcrypt.checkpw(entered_pin, pin_hash)` locally
3. Client calls `record_pin_attempt(success: bool)` RPC

**Approach B (Server-side verify — more secure, hash never leaves server)**:
```sql
CREATE OR REPLACE FUNCTION verify_pin(entered_pin TEXT)
RETURNS JSONB AS $$
DECLARE
  v_user users%ROWTYPE;
  v_match BOOLEAN;
BEGIN
  SELECT * INTO v_user FROM users WHERE id = auth.uid();
  
  -- Check lockout
  IF v_user.pin_locked_until IS NOT NULL AND v_user.pin_locked_until > NOW() THEN
    RETURN jsonb_build_object(
      'success', false,
      'code', 'PIN_LOCKED',
      'locked_until', v_user.pin_locked_until
    );
  END IF;
  
  -- Verify PIN (using pgcrypto extension)
  v_match := crypt(entered_pin, v_user.pin_hash) = v_user.pin_hash;
  
  IF v_match THEN
    UPDATE users SET pin_failed_attempts = 0, pin_locked_until = NULL WHERE id = auth.uid();
    RETURN jsonb_build_object('success', true);
  ELSE
    -- Record failure
    UPDATE users
    SET pin_failed_attempts = pin_failed_attempts + 1,
        pin_locked_until = CASE
          WHEN pin_failed_attempts + 1 >= 5 THEN NOW() + INTERVAL '30 seconds'
          ELSE pin_locked_until
        END
    WHERE id = auth.uid();
    
    RETURN jsonb_build_object(
      'success', false,
      'code', CASE WHEN v_user.pin_failed_attempts + 1 >= 10 THEN 'FORCE_OTP' ELSE 'WRONG_PIN' END,
      'attempts', v_user.pin_failed_attempts + 1
    );
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Response (Approach B)**:
```json
{ "success": true }                                        // ✅ correct PIN
{ "success": false, "code": "WRONG_PIN", "attempts": 3 }  // ❌ wrong, continue
{ "success": false, "code": "PIN_LOCKED", "locked_until": "..." } // 🔒 30s lockout
{ "success": false, "code": "FORCE_OTP" }                 // 🚨 10 failures, OTP required
```

> **Recommendation**: Use **Approach B** (server-side). It means `pin_hash` never leaves the database. Implement `pgcrypto` extension (already available in Supabase).

---

### RPC: `submit_merchant_kyc`

Called by the Merchant App after a merchant fills in their KYC form.

```dart
await supabase.rpc('submit_merchant_kyc', params: {
  'business_name': 'Fresh Mart',
  'category': 'grocery',
  'gstin': '29ABCDE1234F1Z5',
  'pan': 'ABCDE1234F',
  'business_address': '12 MG Road, Bangalore',
  'bank_account_number': '1234567890',
  'ifsc_code': 'HDFC0001234',
  'bank_account_holder_name': 'Ravi Kumar',
  'latitude': 12.9716,
  'longitude': 77.5946,
});
```

---

## Edge Function 1: `initiate-payment`

### Endpoint
```
POST /functions/v1/initiate-payment
Authorization: Bearer <firebase-id-token>
Content-Type: application/json
```

### Request Body
```json
{
  "merchant_id":  "uuid-of-merchant",
  "gross_amount": 1000.00,
  "coins_to_use": 800.00
}
```

> **Note**: `user_phone`, `user_name`, and `user_email` are no longer required in the request body. The edge function fetches the phone number from `users` table (already verified via Firebase Phone Auth). This means the customer's phone number flows to PayU automatically — no re-entry.

| Field | Type | Required | Validation |
|-------|------|----------|-----------|
| `merchant_id` | UUID string | ✅ | Must exist, `kyc_status=approved`, `is_active=true` |
| `gross_amount` | number | ✅ | > 0 |
| `coins_to_use` | number | ✅ | ≥ 0, ≤ `calculate_max_redeemable()` |

### Internal Logic
```
1. Verify Firebase JWT (JWKS)         → get Firebase UID
2. Fetch user from DB                 → get phone, name for PayU
3. Validate merchant (active + KYC)
4. Validate coins_to_use ≤ 80% rule
5. fiat_amount = gross_amount - coins_to_use (must be ≥ ₹1)
6. INSERT transactions (status='initiated')
7. Lock coins: available_coins -= n, locked_coins += n
8. Generate PayU hash (HMAC-SHA512)
9. Return PayU params
```

### Success Response
```json
{
  "success": true,
  "data": {
    "transaction_id":  "uuid",
    "payu_txnid":      "MOMO_1234567890_abc",
    "key":             "U1Zax8",
    "amount":          "200.00",
    "productinfo":     "MomoPe Payment",
    "firstname":       "Ravi Kumar",
    "email":           "noreply@momope.com",
    "phone":           "9876543210",
    "hash":            "<sha512-hash>",
    "surl":            "https://...supabase.co/functions/v1/payu-webhook",
    "furl":            "https://...supabase.co/functions/v1/payu-webhook",
    "udf1":            "uuid-of-transaction"
  }
}
```

> **Email**: Since MomoPe is phone-only, a system email (`noreply@momope.com`) is used for PayU's required email field. PayU does not send transactional emails; this is just for their API validation.

---

## Edge Function 2: `payu-webhook`

Receives PayU success/failure callbacks. No JWT — authenticated via HMAC hash.

### Endpoint
```
POST /functions/v1/payu-webhook
Content-Type: application/x-www-form-urlencoded
```

### HMAC Verification (must happen before any DB writes)
```
reverse_hash = SHA512(SALT|status||udf5|udf4|udf3|udf2|udf1|email|firstname|productinfo|amount|txnid|KEY)
```
If `reverse_hash ≠ request.hash` → reject with 403. Log the attempt.

### On Success (`status=success`)
```
1. Verify HMAC hash
2. UPDATE transactions SET status='pending', payu_mihpayid=...
3. Calculate coins_to_award:
   - Fetch user's transaction count
   - Apply tier: 0-1 txns=10%, 2-5=9%, 6-20=8%, 21+=7%
   - Check total liability; reduce 2% if > ₹1,00,000
   - Check gross_amount; add 1% if ≥ ₹5,000
   - coins_to_award = floor(fiat_amount × earn_rate)
4. CALL process_transaction_success(txn_id, mihpayid, coins_to_award)
   → Atomic: redeem FIFO + award coins + insert commission + status='success'
5. Trigger send-notification (async, non-blocking)
6. Return 200
```

### On Failure (`status=failure`)
```
1. Verify HMAC hash
2. UPDATE transactions SET status='failed'
3. Unlock coins: locked_coins -= n, available_coins += n
4. Return 200
```

---

## Edge Function 3: `process-expiry`

Daily cron job. Internal only.

```
POST /functions/v1/process-expiry
(No auth — triggered by pg_cron only)
```

Calls `expire_old_coins()` stored procedure. Returns:
```json
{ "success": true, "data": { "expired_batches": 12, "total_coins_expired": 340.00 } }
```

---

## Edge Function 4: `process-referral`

Called by the Customer App after a user's first successful transaction.

```
POST /functions/v1/process-referral
Authorization: Bearer <firebase-id-token>
Content-Type: application/json

{ "transaction_id": "uuid-of-completed-transaction" }
```

Logic:
1. Verify Firebase JWT
2. Confirm transaction belongs to caller and is `status=success`
3. Confirm this is the user's first-ever successful transaction (count = 1)
4. Find `referrals` record where `referee_id = caller`
5. Call `process_referral_reward()` atomically

Response:
```json
{ "success": true, "data": { "referrer_coins_awarded": 50, "referee_coins_awarded": 25 } }
```

---

## Edge Function 5: `send-notification`

Internal. Called from within `payu-webhook`.

```
POST /functions/v1/send-notification
Content-Type: application/json

{
  "user_id": "firebase-uid",
  "type": "payment_success",
  "data": {
    "transaction_id": "uuid",
    "coins_earned": 20,
    "new_balance": 245
  }
}
```

**Notification Types**:

| type | Recipient | Data |
|------|-----------|------|
| `payment_success` | Customer | coins_earned, new_balance |
| `payment_failure` | Customer | — |
| `new_payment_received` | Merchant | amount |
| `settlement_processed` | Merchant | amount, date |

---

## PostgREST Client Patterns (Flutter)

### Supabase Client Initialization (Firebase JWT mode)
```dart
final supabase = SupabaseClient(
  'https://wpnngcuoqtvgwhizkrwt.supabase.co',
  '<anon-key>',
  accessToken: () async =>
    await FirebaseAuth.instance.currentUser?.getIdToken(true),
);
```

This one-time setup means every Supabase call automatically uses a fresh Firebase JWT. No manual header management needed.

### Common Queries

```dart
// Coin balance
final balance = await supabase
  .from('momo_coin_balances')
  .select()
  .single();

// Discover merchants
final merchants = await supabase
  .from('merchants')
  .select('id, business_name, category, latitude, longitude')
  .eq('kyc_status', 'approved')
  .eq('is_active', true)
  .eq('is_operational', true);

// Transaction history (newest first)
final transactions = await supabase
  .from('transactions')
  .select('*, merchants(business_name)')
  .order('created_at', ascending: false)
  .limit(50);

// Coin transaction history
final coinHistory = await supabase
  .from('coin_transactions')
  .select()
  .order('created_at', ascending: false)
  .limit(100);

// Referral stats for home screen
final referralStats = await supabase
  .from('referral_stats')
  .select()
  .eq('user_id', FirebaseAuth.instance.currentUser!.uid)
  .maybeSingle();

// Check if user has PIN set (to decide registration vs login flow)
final user = await supabase
  .from('users')
  .select('pin_hash, role')  // pin_hash: just check if non-null, don't use value
  .single();
final hasPinSet = user['pin_hash'] != null;

// Merchant: own transactions
final merchantTxns = await supabase
  .from('transactions')
  .select('gross_amount, fiat_amount, coins_applied, status, created_at')
  .order('created_at', ascending: false);
// RLS automatically filters to the merchant's own data
```

---

## Admin Dashboard API (Next.js Server-Side)

Admin calls use **Firebase Admin SDK** for JWT verification + **Supabase Service Role** for DB access.

```typescript
// lib/admin-clients.ts
import { initializeApp, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { createClient } from '@supabase/supabase-js';

// Firebase Admin (for verifying user tokens)
const firebaseAdmin = initializeApp({ credential: cert(serviceAccount) });

// Supabase Admin (service role — bypasses RLS)
const adminSupabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);
```

```typescript
// Verify admin role on every protected request
async function verifyAdmin(req: Request): Promise<string> {
  const token = req.headers.get('Authorization')?.replace('Bearer ', '');
  if (!token) throw new Error('No token');
  
  const decoded = await getAuth().verifyIdToken(token);   // Firebase Admin SDK
  
  const { data: user } = await adminSupabase
    .from('users')
    .select('role')
    .eq('id', decoded.uid)
    .single();
  
  if (user?.role !== 'admin') throw new Error('Not admin');
  return decoded.uid;
}
```

---

## PayU Integration Reference

### Test Credentials
```
Merchant Key:  U1Zax8
Salt:          BaYKhBYXBAmIJ9w9XUb3KZ8gQsj9SHWt
Environment:   Test (PAYU_ENV=0)
```

### Hash Generation (Server-side in Edge Function)
```typescript
const hashInput = [
  merchantKey, txnid, amount, productinfo,
  firstname, email,          // email = "noreply@momope.com" for phone-only users
  udf1, '', '', '', '', '', '', '', '', // udf2-udf10 empty
  salt
].join('|');

const hash = await crypto.subtle.digest('SHA-512', new TextEncoder().encode(hashInput));
```

### Flutter SDK Usage
```dart
PayUCheckoutPro.open(
  context,
  PayUCheckoutProConfig(
    environment: PayUEnvironment.test,
    merchantKey: const String.fromEnvironment('PAYU_KEY'),
    payUSalt:    const String.fromEnvironment('PAYU_SALT'),
    paymentParams: PayUPaymentParams(
      txnId:       response['payu_txnid'],
      amount:      response['amount'],
      productInfo: 'MomoPe Payment',
      firstName:   response['firstname'],
      email:       response['email'],
      phone:       response['phone'],     // ← comes from Firebase Auth (already verified)
      hash:        response['hash'],
      udf1:        response['udf1'],      // transaction_id
    ),
  ),
  payUCheckoutProListener,
);
```

---

*Update this document whenever an edge function or RPC is added, changed, or removed.*
