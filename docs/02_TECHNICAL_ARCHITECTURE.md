# MomoPe — Technical Architecture Document

**Version**: 2.0  
**Date**: February 2026  
**Status**: Pre-Implementation Reference  
**Change from v1.0**: Auth layer fully replaced — Google Sign-In removed. Firebase Phone Auth (OTP) + bcrypt PIN + Supabase Third-Party JWT (JWKS) bridge.

---

## 1. Architecture Overview

MomoPe is a **three-tier architecture**: mobile/web clients → Supabase (BaaS + Edge Functions) → PayU. The critical addition in v2 is the **Firebase ↔ Supabase JWT bridge** via JWKS, which allows Firebase ID tokens to be used directly as Supabase bearer tokens — no intermediary sync function needed.

```
┌──────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                               │
│  Customer App (Flutter)      Merchant App (Flutter)               │
│  Admin Dashboard (Next.js 15)                                     │
└─────────────────────────────┬────────────────────────────────────┘
                              │ HTTPS + Firebase ID Token (JWT)
┌─────────────────────────────▼────────────────────────────────────┐
│                    FIREBASE (momope-production)                    │
│   Phone Auth (OTP via SMS) ─── Issues Firebase ID Token (JWT)     │
│   Firebase ID Token verified by Supabase via JWKS public keys      │
└─────────────────────────────┬────────────────────────────────────┘
                              │ Firebase JWT passed as Bearer token
┌─────────────────────────────▼────────────────────────────────────┐
│              SUPABASE PLATFORM (Mumbai — ap-south-1)              │
│                                                                    │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │  Third-Party Auth (JWKS)                                     │ │
│  │  JWKS URL: googleapis.com/service_accounts/v1/jwk/...        │ │
│  │  auth.uid() = Firebase UID  ← RLS uses this natively         │ │
│  └──────────────────────────────────────────────────────────────┘ │
│                                                                    │
│  ┌─────────────────┐  ┌───────────────────┐  ┌────────────────┐  │
│  │   PostgREST     │  │  Edge Functions   │  │   Realtime     │  │
│  │  (Auto REST)    │  │  (Deno/TypeScript)│  │  (optional)    │  │
│  │   + RLS         │  │                   │  │                │  │
│  └────────┬────────┘  └─────────┬─────────┘  └────────────────┘  │
│           │                     │                                  │
│  ┌────────▼─────────────────────▼────────────────────────────┐    │
│  │               PostgreSQL 15 (Core DB)                      │    │
│  │  users(id=Firebase UID), momo_coin_balances, merchants      │    │
│  │  transactions, commissions, coin_batches, coin_transactions │    │
│  │  referrals  +  RLS (20+ policies)  +  pg_cron              │    │
│  └────────────────────────────────────────────────────────────┘    │
└─────────────────────────────┬────────────────────────────────────┘
                              │ HTTPS (SDK + Webhook)
┌─────────────────────────────▼────────────────────────────────────┐
│                         PAYU GATEWAY                              │
│   CheckoutPro SDK ← Payment Init → Webhook → payu-webhook fn      │
└───────────────────────────────────────────────────────────────────┘
```

---

## 2. Authentication Architecture — The JWKS Bridge

This is the most important architectural decision in the system.

### How it works

```
Firebase Phone Auth issues a signed JWT (RS256).
  └─ JWT header: { "alg": "RS256", "kid": "<key-id>" }
  └─ JWT payload: { "sub": "abc123FirebaseUID", "phone_number": "+919876543210", ... }

Supabase is configured with Firebase's JWKS URL:
  https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com

When Flutter calls supabase.from('users').select() with Firebase JWT as Bearer token:
  Supabase fetches Firebase's public keys from the JWKS URL
  Verifies the JWT signature  ──→  auth.uid() = "abc123FirebaseUID"
  RLS policies fire using this UID  ──→  no custom bridge function needed
```

### Why this is clean
- No `sync-user` edge function needed
- No Firebase Admin SDK on the server
- `auth.uid()` in all RLS policies naturally equals Firebase UID
- `users.id` column stores Firebase UIDs (strings like `"abc123XYZ"`)
- Switching auth providers later only requires a JWKS URL change in Supabase settings

### Supabase Configuration Required
In Supabase Dashboard → Authentication → Third-party Auth:
```
Provider: Custom OIDC / Firebase
JWKS URL: https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com
JWT Issuer: https://securetoken.google.com/<firebase-project-id>
```

### Flutter SDK Usage (Critical Pattern)
```dart
// After Firebase Phone Auth success, get ID token
final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();

// Initialize Supabase client with this token
final supabase = SupabaseClient(
  supabaseUrl,
  supabaseAnonKey,
  accessToken: () async {
    // Always return fresh Firebase token — auto-refreshed
    return await FirebaseAuth.instance.currentUser?.getIdToken(true);
  },
);
```

---

## 3. PIN Architecture

### PIN Storage & Verification

```
[User enters 4/6-digit PIN on device]
         │
         ▼
[Flutter bcrypt.hash(pin, salt)] ← Never sent to server in plain text
         │
         ▼
[HTTPS POST] users.pin_hash = "<bcrypt-hash-string>"
         │
         ▼
[Supabase DB stores hash in users.pin_hash]

─── VERIFICATION (returning user) ───

[User enters PIN]
         │
         ▼
[Fetch users.pin_hash from DB]  ← One Supabase query
         │
         ▼
[Flutter bcrypt.checkpw(entered_pin, pin_hash)]  ← Local comparison
         │
    ┌────┴────┐
  match     no match
    │            │
  ✅ Home    ❌ Attempt counter++
             5 failures → 30s lock
             10 failures → OTP re-verify
```

### PIN Security Rules (enforced client-side before hashing)
```dart
bool isValidPin(String pin) {
  // Rule 1: Must be all digits
  if (!RegExp(r'^\d+$').hasMatch(pin)) return false;
  
  // Rule 2: Not all same digit
  if (pin.split('').toSet().length == 1) return false;
  
  // Rule 3: Not sequential ascending (e.g., 1234)
  bool isAscSeq = true;
  for (int i = 1; i < pin.length; i++) {
    if (int.parse(pin[i]) != int.parse(pin[i-1]) + 1) { isAscSeq = false; break; }
  }
  if (isAscSeq) return false;
  
  // Rule 4: Not sequential descending (e.g., 4321)
  bool isDescSeq = true;
  for (int i = 1; i < pin.length; i++) {
    if (int.parse(pin[i]) != int.parse(pin[i-1]) - 1) { isDescSeq = false; break; }
  }
  if (isDescSeq) return false;
  
  return true;
}
```

### PIN Attempt Lockout (client-side state, backed by DB)
```dart
// Stored in users table (server-side)
pin_failed_attempts  INTEGER  DEFAULT 0
pin_locked_until     TIMESTAMPTZ  NULL

// Logic in PinVerificationService
if (failedAttempts >= 10) → force OTP re-verification
if (failedAttempts >= 5 && failedAttempts < 10) → 30-second lockout
```

---

## 4. Technology Stack

### Mobile Apps (Customer & Merchant)

| Layer | Choice | Version | Notes |
|-------|--------|---------|-------|
| Framework | Flutter | 3.41.1 | |
| Language | Dart | 3.11.0 | |
| State Management | flutter_riverpod | 2.6.1 | |
| **Auth — OTP** | **firebase_auth** | **^5.x** | Phone OTP delivery |
| **Auth — Firebase Core** | **firebase_core** | **^3.x** | Required by firebase_auth |
| **Auth — PIN Hashing** | **bcrypt (dart)** | **latest** | Local PIN hashing |
| **Auth — Biometric (post-MVP)** | **local_auth** | **latest** | Fingerprint/face unlock |
| Database Client | supabase_flutter | latest | Uses Firebase JWT as Bearer |
| Payments | payu_checkoutpro_flutter | latest | |
| QR Scanner | mobile_scanner | 5.2.3 | |
| Charts | fl_chart | 0.66.2 | |
| Internationalization | intl | 0.18.1 | |

**Removed from v1.0**:
- ~~google_sign_in~~ — removed entirely
- ~~share_plus~~ — reassess if referral sharing needs it

**Android Build Config**:
```
Gradle: 8.12
AGP: 8.10.0
Kotlin: 2.1.0
JDK: 21.0.10 LTS (Temurin)
Min SDK: 21 (Android 5.0)
Target SDK: 36
```

---

### Backend (Supabase Cloud — Mumbai)

| Component | Choice | Notes |
|-----------|--------|-------|
| Database | PostgreSQL 15 | Supabase managed |
| Auth | **Supabase Third-Party JWT (JWKS)** | Firebase JWTs verified via JWKS |
| Identity Provider | **Firebase Phone Auth** | OTP via SMS |
| REST API | PostgREST | Auto-generated, RLS-protected |
| Serverless | Deno Edge Functions | 5 deployed functions |
| Cron | pg_cron v1.6.4 | Coin expiry daily job |

**No longer needed**:
- ~~Supabase Native Auth~~ — replaced by JWKS third-party mode
- ~~sync-user edge function~~ — not needed with JWKS bridge

---

### Web Platform

| Layer | Choice | Notes |
|-------|--------|-------|
| Framework | Next.js 15 (App Router) | Admin dashboard |
| Styling | Tailwind CSS | |
| Hosting | Vercel | Separate from momope.com (already live) |
| Admin Auth | Firebase Admin SDK (server-side) | Verify Firebase JWT in Next.js middleware |

**Admin auth pattern** (Next.js middleware):
```typescript
// middleware.ts
import { getAuth } from 'firebase-admin/auth';

export async function middleware(req: NextRequest) {
  const token = req.headers.get('Authorization')?.replace('Bearer ', '');
  const decoded = await getAuth().verifyIdToken(token); // Firebase Admin SDK
  const { data: user } = await adminSupabase
    .from('users')
    .select('role')
    .eq('id', decoded.uid)
    .single();
  
  if (user?.role !== 'admin') return NextResponse.redirect('/unauthorized');
}
```

---

## 5. Data Flow Diagrams

### 5.1 First-Time Registration Flow

```
Flutter App                 Firebase               Supabase DB
    │                          │                       │
    │── Enter phone number ────▶│                       │
    │◀── OTP sent (SMS) ────────│                       │
    │── Enter 6-digit OTP ──────▶│                      │
    │◀── Firebase ID Token ──────│                      │
    │                           │                       │
    │── Enter name ─────────────────────────────────────▶
    │   (optional referral code)│                       │
    │── Set PIN → Confirm PIN   │                       │
    │── bcrypt.hash(pin) ───────│                       │
    │── INSERT users {          │                       │
    │     id: Firebase UID,     │                       │
    │     name, phone, pin_hash │                       │
    │   } (with Firebase JWT) ──────────────────────────▶
    │                           │                  RLS: auth.uid() matches
    │◀── 200 OK ─────────────────────────────────────────
    │── Navigate to Home ────────│                       │
```

### 5.2 Returning User Login Flow

```
Flutter App                 Firebase               Supabase DB
    │                          │                       │
    │── App opens               │                       │
    │── Show PIN screen         │                       │
    │── User enters PIN         │                       │
    │── Fetch pin_hash ─────────────────────────────────▶
    │◀── { pin_hash: "$2b$..." } ────────────────────────
    │── bcrypt.checkpw(pin, hash)│                      │
    │── ✅ match                 │                       │
    │                           │                       │
    │── Firebase token still valid? ──────────────────  │
    │   [if expired] getIdToken(refresh: true) ─────────▶│
    │◀── Fresh Firebase ID Token ──────────────────────  │
    │── Navigate to Home        │                       │
```

### 5.3 Payment Flow (Happy Path)

```
Customer App              initiate-payment Edge Fn        PayU              DB
    │                            │                          │                │
    │── Scan QR → Enter amount   │                          │                │
    │                            │                          │                │
    │── POST /initiate-payment ──▶                          │                │
    │   Authorization: Bearer <Firebase JWT>                │                │
    │                            │── Verify JWT (JWKS) ─────│                │
    │                            │── Validate inputs        │                │
    │                            │── Lock coins ────────────────────────────▶│
    │                            │── Create txn (initiated) ─────────────────▶│
    │                            │── Generate PayU hash ────│                │
    │◀── PayU params + hash ──────│                          │                │
    │                            │                          │                │
    │── Launch CheckoutPro SDK ──────────────────────────────▶               │
    │   (fiat_amount, phone auto-filled from Firebase) ──────▶               │
    │                            │                          │                │
    │                            │◀── Webhook (POST) ────────│                │
    │                            │── HMAC verify ────────────│                │
    │                            │── process_transaction_success() ──────────▶│
    │◀── Realtime update ─────────────────────────────────────────────────── │
    │── Show result screen       │                          │                │
```

### 5.4 Forgot PIN Flow

```
Flutter App                 Firebase               Supabase DB
    │                          │                       │
    │── Tap "Forgot PIN?"       │                       │
    │── Enter phone number ─────▶│                      │
    │◀── OTP sent ──────────────│                       │
    │── Verify OTP ─────────────▶│                      │
    │◀── Firebase ID Token ──────│                      │
    │── Enter new PIN           │                       │
    │── bcrypt.hash(new_pin)    │                       │
    │── UPDATE users SET        │                       │
    │     pin_hash = new_hash,  │                       │
    │     pin_failed_attempts=0 ────────────────────────▶
    │◀── 200 OK ─────────────────────────────────────────
    │── Navigate to Home        │                       │
```

---

## 6. Security Architecture

### 6.1 Authentication Chain

```
Phone Number
    │
    ▼ Firebase Phone Auth (SMS OTP)
Firebase UID + ID Token (RS256 JWT)
    │
    ▼ Supabase JWKS Verification
auth.uid() = Firebase UID ─── RLS policies fire
    │
    ▼
Supabase Data Access (PostgREST)
```

### 6.2 Row-Level Security

All tables use `auth.uid()` which equals Firebase UID:

```sql
-- Users see only their own record
CREATE POLICY "users_self_access" ON users
  FOR ALL USING (id = auth.uid());

-- Users see only their own coin balance
CREATE POLICY "balance_self_access" ON momo_coin_balances
  FOR SELECT USING (user_id = auth.uid());

-- Anyone can discover approved merchants
CREATE POLICY "merchant_public_discovery" ON merchants
  FOR SELECT USING (kyc_status = 'approved' AND is_active = true);

-- Only admins can update any merchant KYC
CREATE POLICY "admin_merchant_update" ON merchants
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
  );
```

### 6.3 PIN Security Chain

```
User input (plain digits)
    │
    ▼ [Client-side validation: no all-same, no sequential]
    │
    ▼ [Client-side] bcrypt.hash(pin, cost=10)
    │
    ▼ [HTTPS] UPDATE users SET pin_hash = hash  (only hash transmitted)
    │
    ▼ [DB] Stored as "$2b$10$..."  ← unrecoverable without the original pin
```

### 6.4 Payment Security

- PayU webhook: HMAC-SHA512 reverse hash verified before any DB writes
- PayU credentials: Supabase secrets (edge functions) + `--dart-define` (Flutter)
- Service Role key: Only in Next.js server-side code, never in Flutter

---

## 7. Edge Functions Reference

| Function | Trigger | Auth Method | Purpose |
|----------|---------|-------------|---------|
| `initiate-payment` | Customer POST | Firebase JWT (manual verify) | Create txn, lock coins, return PayU hash |
| `payu-webhook` | PayU POST | HMAC-SHA512 hash | Verify payment, process transaction atomically |
| `process-expiry` | pg_cron daily 2AM IST | None (internal) | Mark expired coin batches |
| `process-referral` | Customer POST | Firebase JWT (default verify) | Award referral coins on first transaction |
| `send-notification` | Internal (from webhook) | None (internal) | FCM push notifications |

**JWKS verification inside edge functions**:
```typescript
// initiate-payment/index.ts
import { createClient } from '@supabase/supabase-js';

// Pass the Firebase JWT directly to Supabase client
const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  global: {
    headers: { Authorization: req.headers.get('Authorization') ?? '' }
  }
});

// auth.uid() is now the Firebase UID — RLS works automatically
const { data: { user } } = await supabase.auth.getUser();
const firebaseUid = user?.id;
```

---

## 8. Firebase Project Configuration

**Project**: `momope-production`

**Required Firebase Services**:
- ✅ Authentication → Phone Auth (enabled, with test phone numbers for dev)
- ✅ `google-services.json` in both Flutter apps
- ❌ Firebase Firestore — not used (Supabase is the DB)
- ❌ Firebase Hosting — not used (Vercel)
- ❌ Firebase Analytics — not used (Supabase Analytics or Vercel)

**Flutter Firebase Init**:
```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MomoPeApp()));
}
```

**Test Phone Numbers** (Firebase Console → Authentication → Phone → Test phone numbers):
```
+91 9999999999  →  OTP: 123456   (used in dev/testing only)
+91 8888888888  →  OTP: 654321
```

---

## 9. Monorepo Structure

```
c:\DRAGON\MomoPe\
├── customer_app/
│   ├── android/
│   │   └── app/
│   │       ├── google-services.json     ← Firebase config
│   │       └── build.gradle
│   ├── lib/
│   │   ├── main.dart                    ← Firebase.initializeApp()
│   │   ├── screens/
│   │   │   ├── auth/
│   │   │   │   ├── phone_input_screen.dart
│   │   │   │   ├── otp_verification_screen.dart
│   │   │   │   ├── name_entry_screen.dart
│   │   │   │   ├── pin_setup_screen.dart      ← NEW: PhonePe-style
│   │   │   │   └── pin_entry_screen.dart      ← NEW: everyday login
│   │   │   ├── home/
│   │   │   ├── explore/
│   │   │   ├── payment/
│   │   │   ├── transactions/
│   │   │   ├── qr_scanner/
│   │   │   └── profile/
│   │   ├── services/
│   │   │   ├── auth_service.dart              ← Firebase Auth + PIN logic
│   │   │   ├── pin_service.dart               ← NEW: bcrypt hash/verify
│   │   │   ├── payment_service.dart
│   │   │   ├── coin_redemption_service.dart
│   │   │   └── notification_service.dart
│   │   └── providers/
│   └── pubspec.yaml
│
├── merchant_app/
│   ├── android/app/google-services.json
│   └── lib/
│       ├── screens/auth/
│       │   ├── phone_input_screen.dart
│       │   ├── otp_verification_screen.dart
│       │   ├── pin_setup_screen.dart
│       │   └── pin_entry_screen.dart
│       └── ...
│
├── admin/                                     ← Next.js 15, port 3001
│   ├── middleware.ts                          ← Firebase Admin SDK JWT verify
│   └── app/
│
└── supabase/
    ├── functions/
    │   ├── initiate-payment/
    │   ├── payu-webhook/
    │   ├── process-expiry/
    │   ├── process-referral/
    │   └── send-notification/
    └── migrations/
        ├── 001_initial_schema.sql
        ├── ...
        └── 014_pin_lockout_fields.sql         ← NEW: pin_failed_attempts, pin_locked_until
```

---

## 10. Environment Variables

### Local (`.env` — gitignored)
```env
SUPABASE_URL=https://wpnngcuoqtvgwhizkrwt.supabase.co
SUPABASE_ANON_KEY=<from Supabase dashboard>
SUPABASE_SERVICE_ROLE_KEY=<from Supabase dashboard>

# Firebase
FIREBASE_PROJECT_ID=momope-production
FIREBASE_API_KEY=<from Firebase project settings>

# PayU (Test)
PAYU_MERCHANT_KEY=U1Zax8
PAYU_SALT=BaYKhBYXBAmIJ9w9XUb3KZ8gQsj9SHWt
PAYU_CLIENT_ID=<value>
PAYU_CLIENT_SECRET=<value>
```

### Flutter Runtime
```bash
flutter run \
  --dart-define=PAYU_KEY=U1Zax8 \
  --dart-define=PAYU_SALT=<salt> \
  --dart-define=PAYU_ENV=0
# No Google/OAuth defines needed anymore
```

### Supabase Secrets (Production)
```bash
supabase secrets set PAYU_MERCHANT_KEY=U1Zax8
supabase secrets set PAYU_SALT=<salt>
supabase secrets set PAYU_CLIENT_ID=<value>
supabase secrets set PAYU_CLIENT_SECRET=<value>
# Firebase secrets managed via google-services.json, not Supabase secrets
```

---

## 11. Architecture Decision Log

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Auth Provider | Firebase Phone Auth | Free 10k OTPs/month; proven reliability for Indian phone numbers; no Twilio setup needed |
| Auth Bridge | JWKS Third-Party JWT | Zero custom bridge code; `auth.uid()` = Firebase UID natively; RLS unchanged |
| No Google Sign-In | Removed | PhonePe-style phone-first is simpler, more familiar to Indian users; Google accounts add unnecessary complexity |
| PIN Storage | bcrypt (client-side hash) | PIN never leaves device in plain text; bcrypt is irreversible; industry standard |
| PIN Verification | Client-side bcrypt.checkpw | Fast local comparison; no server round-trip for everyday login |
| users.id type | VARCHAR (Firebase UID) | Firebase UIDs are alphanumeric strings, not UUIDs |
| PIN Lockout | DB-backed (pin_failed_attempts) | Survives app reinstalls; server-authoritative |

---

*Update this document after each significant architectural change. v2.0 reflects the complete removal of Google Sign-In and adoption of Firebase Phone Auth + PIN.*
