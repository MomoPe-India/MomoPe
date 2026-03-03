# MomoPe — Developer Setup & Coding Conventions

**Version**: 2.0  
**Date**: February 2026  
**Audience**: Any developer joining the MomoPe project  
**Change from v1.0**: Google Sign-In removed. Firebase Phone Auth (OTP) + PhonePe-style PIN is the full auth system. Firebase JWKS bridge to Supabase replaces Supabase Native Auth.

---

## 1. Prerequisites

| Tool | Version | Purpose | Install |
|------|---------|---------|---------|
| Flutter SDK | 3.41.1 | Mobile development | flutter.dev |
| Dart | 3.11.0 | Bundled with Flutter | — |
| JDK (Temurin) | 21.0.10 LTS | Android build toolchain | adoptium.net |
| Android Studio | Latest | Android SDK + emulator | developer.android.com |
| Node.js | 18+ LTS | Admin dashboard (Next.js) | nodejs.org |
| Supabase CLI | Latest | Migrations + edge functions | supabase.com/docs/guides/cli |
| Firebase CLI | Latest | Firebase project management | firebase.google.com/docs/cli |
| Git | Latest | Version control | git-scm.com |
| VS Code | Latest | Recommended editor | code.visualstudio.com |

### VS Code Extensions
- Flutter + Dart
- ESLint + Prettier
- GitLens

---

## 2. Repository Setup

```bash
git clone <repo-url>
cd MomoPe
```

### Structure
```
MomoPe/
├── customer_app/       # Flutter Customer App
├── merchant_app/       # Flutter Merchant App
├── admin/              # Next.js 15 Admin Dashboard (port 3001)
├── website/            # ✅ Already live at momope.com — not in active development
├── supabase/
│   ├── functions/      # Deno Edge Functions
│   └── migrations/     # SQL migration files
├── .env                # Local secrets — NEVER commit
├── .gitignore
└── README.md
```

---

## 3. First-Time Environment Setup

### Step 1: Create `.env` in repo root
```env
# Supabase
SUPABASE_URL=https://wpnngcuoqtvgwhizkrwt.supabase.co
SUPABASE_ANON_KEY=<Supabase Dashboard → Project Settings → API → anon/public>
SUPABASE_SERVICE_ROLE_KEY=<Supabase Dashboard → Project Settings → API → service_role>

# Firebase
FIREBASE_PROJECT_ID=momope-production
FIREBASE_API_KEY=<Firebase Console → Project Settings → General → Web API Key>
FIREBASE_APP_ID=<Firebase Console → Project Settings → Your Apps>

# PayU (Test mode)
PAYU_MERCHANT_KEY=U1Zax8
PAYU_SALT=BaYKhBYXBAmIJ9w9XUb3KZ8gQsj9SHWt
PAYU_CLIENT_ID=<value>
PAYU_CLIENT_SECRET=<value>
```

> ⚠️ **NEVER commit `.env`**. It is in `.gitignore`. Share secrets only via encrypted channels (1Password, Signal, etc.).

---

### Step 2: Configure Firebase

Firebase is used for Phone Auth OTP only. Follow these steps once per developer machine:

```bash
# Login to Firebase CLI
firebase login

# Verify project access
firebase projects:list
# You should see: momope-production
```

**Download `google-services.json`**:
1. Firebase Console → `momope-production` → Project Settings → Your Apps
2. Download `google-services.json` for Android
3. Place copies in:
   - `customer_app/android/app/google-services.json`
   - `merchant_app/android/app/google-services.json`

> `google-services.json` is gitignored. Every developer needs their own copy.

**Enable Phone Auth in Firebase Console**:
- Firebase Console → Authentication → Sign-in method → Phone → Enable

**Add test phone numbers** (for development without real SMS):
- Firebase Console → Authentication → Sign-in method → Phone → Phone numbers for testing
- `+91 9999999999` → OTP: `123456`
- `+91 8888888888` → OTP: `654321`

---

### Step 3: Configure Supabase JWKS (One-time, done by admin)

This step connects Supabase to Firebase's public keys so Firebase JWTs are accepted:

1. Supabase Dashboard → `wpnngcuoqtvgwhizkrwt` → Authentication → Third-party Auth (or JWKS)
2. Add JWKS URL:
   ```
   https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com
   ```
3. JWT Issuer:
   ```
   https://securetoken.google.com/momope-production
   ```
4. Save. From now on, any Firebase ID Token can be used as a Supabase Bearer token.

---

### Step 4: Link Supabase and Apply Migrations

```bash
supabase login
supabase link --project-ref wpnngcuoqtvgwhizkrwt
supabase db push
```

---

### Step 5: Flutter Setup

```bash
cd customer_app && flutter pub get
cd ../merchant_app && flutter pub get
```

Verify Flutter and Android environment:
```bash
flutter doctor
# All checks should pass. Android toolchain ✓, Flutter ✓
```

---

### Step 6: Admin Dashboard Setup

```bash
cd admin
npm install
cp .env.example .env.local
```

Fill in `admin/.env.local`:
```env
NEXT_PUBLIC_SUPABASE_URL=https://wpnngcuoqtvgwhizkrwt.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=<anon key>
SUPABASE_SERVICE_ROLE_KEY=<service role key>
FIREBASE_PROJECT_ID=momope-production
FIREBASE_ADMIN_PRIVATE_KEY=<from Firebase service account JSON>
FIREBASE_ADMIN_CLIENT_EMAIL=<from Firebase service account JSON>
```

**Firebase Service Account** (for Admin SDK in Next.js):
- Firebase Console → Project Settings → Service accounts → Generate new private key
- Download JSON, extract `private_key` and `client_email`

---

## 4. Running the Apps

### Customer App
```bash
cd customer_app
flutter run \
  --dart-define=PAYU_KEY=U1Zax8 \
  --dart-define=PAYU_SALT=BaYKhBYXBAmIJ9w9XUb3KZ8gQsj9SHWt \
  --dart-define=PAYU_ENV=0
```

Use test phone `+91 9999999999` and OTP `123456` for development.

### Merchant App
```bash
cd merchant_app
flutter run
```
Use test phone `+91 8888888888` and OTP `654321`. Make sure the `users` record for this phone has `role='merchant'`.

### Admin Dashboard
```bash
cd admin
npm run dev
# Open http://localhost:3001
```
Log in with a phone number whose `users.role = 'admin'`.

---

## 5. Deployment

### Deploy Edge Functions
```bash
supabase functions deploy initiate-payment --no-verify-jwt
supabase functions deploy payu-webhook     --no-verify-jwt
supabase functions deploy process-expiry   --no-verify-jwt
supabase functions deploy process-referral
supabase functions deploy send-notification

# Set production secrets
supabase secrets set PAYU_MERCHANT_KEY=U1Zax8
supabase secrets set PAYU_SALT=<salt>
supabase secrets set PAYU_CLIENT_ID=<value>
supabase secrets set PAYU_CLIENT_SECRET=<value>
```

### Admin Dashboard (Vercel — auto on push to `main`)
Ensure Vercel project environment variables are set:
- `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `FIREBASE_PROJECT_ID`, `FIREBASE_ADMIN_PRIVATE_KEY`, `FIREBASE_ADMIN_CLIENT_EMAIL`

### Build APKs
```bash
# Customer App (PayU credentials required)
flutter build apk --release \
  --dart-define=PAYU_KEY=U1Zax8 \
  --dart-define=PAYU_SALT=<salt> \
  --dart-define=PAYU_ENV=1   # 1 = production

# Merchant App
flutter build apk --release
```

---

## 6. Git Workflow

### Branch Strategy
```
main        ← Always deployable. Protected. No direct pushes.
develop     ← Integration branch. All PRs merge here first.
feature/<n> ← Feature branches off develop.
fix/<n>     ← Bug fixes off develop.
hotfix/<n>  ← Emergency fixes off main.
```

### Commit Convention (Conventional Commits)
```
type(scope): short description

Types:  feat | fix | docs | refactor | test | chore | db
Scopes: customer-app | merchant-app | admin | edge-fn | db | infra | auth

Examples:
feat(auth): implement PhonePe-style PIN entry screen
feat(customer-app): add PIN lockout countdown UI
fix(edge-fn): use system email for PayU phone-only users
db: add migration 014 for PIN lockout fields
chore(admin): configure Firebase Admin SDK for middleware
```

### PR Rules
1. All PRs require at least one review.
2. PR title follows conventional commit format.
3. PR description: What changed / Why / How to test.
4. `flutter analyze` must pass with zero issues.
5. `supabase db push` must succeed without errors.

---

## 7. Auth-Specific Coding Conventions

This section is new in v2.0. Auth is the most complex part of the system — follow these patterns exactly.

### 7.1 Firebase Auth Flow (Flutter)

**Service structure — `lib/services/auth_service.dart`**:
```dart
class AuthService {
  final _firebaseAuth = FirebaseAuth.instance;
  final _supabase = Supabase.instance.client;

  // Step 1: Send OTP
  Future<void> sendOtp(String phoneNumber) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: '+91$phoneNumber',
      verificationCompleted: (_) {},         // auto-verify on some devices
      verificationFailed: (e) => throw AuthException(e.message),
      codeSent: (verificationId, _) {
        _verificationId = verificationId;    // store for step 2
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  // Step 2: Verify OTP and get Firebase user
  Future<bool> verifyOtp(String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );
    await _firebaseAuth.signInWithCredential(credential);
    return _firebaseAuth.currentUser != null;
  }

  // Get fresh Firebase ID token (for Supabase calls)
  Future<String?> getIdToken() async =>
    await _firebaseAuth.currentUser?.getIdToken(true);
  
  // Sign out
  Future<void> signOut() async => await _firebaseAuth.signOut();
}
```

### 7.2 Supabase Client Initialization with Firebase JWT

Always initialize Supabase with the `accessToken` callback. Do this once in `main.dart`:

```dart
await Supabase.initialize(
  url: 'https://wpnngcuoqtvgwhizkrwt.supabase.co',
  anonKey: '<anon-key>',
  accessToken: () async {
    // This is called automatically before every Supabase request
    return await FirebaseAuth.instance.currentUser?.getIdToken(true);
  },
);
```

**Do NOT** manually set `Authorization` headers. The `accessToken` callback handles it.

### 7.3 PIN Service (`lib/services/pin_service.dart`)

```dart
import 'package:bcrypt/bcrypt.dart';

class PinService {
  static const _lockoutThreshold = 5;
  static const _forceOtpThreshold = 10;

  /// Hash a PIN before storing/transmitting. Never store plain PIN.
  String hashPin(String pin) {
    return BCrypt.hashpw(pin, BCrypt.gensalt(logRounds: 10));
  }

  /// Validate PIN format before hashing
  bool isValidPin(String pin) {
    if (pin.length != 4 && pin.length != 6) return false;
    if (!RegExp(r'^\d+$').hasMatch(pin)) return false;
    if (pin.split('').toSet().length == 1) return false; // all same
    
    bool asc = true, desc = true;
    for (int i = 1; i < pin.length; i++) {
      if (int.parse(pin[i]) != int.parse(pin[i-1]) + 1) asc = false;
      if (int.parse(pin[i]) != int.parse(pin[i-1]) - 1) desc = false;
    }
    return !asc && !desc;
  }

  /// Store PIN hash via Supabase RPC
  Future<void> setPin(String plainPin) async {
    if (!isValidPin(plainPin)) throw PinException('Invalid PIN format');
    final hash = hashPin(plainPin);
    await Supabase.instance.client.rpc('set_pin', params: {'pin_hash': hash});
  }

  /// Verify PIN via server-side RPC (Approach B — hash never leaves server)
  Future<PinVerifyResult> verifyPin(String plainPin) async {
    final result = await Supabase.instance.client.rpc(
      'verify_pin',
      params: {'entered_pin': plainPin}
    );
    return PinVerifyResult.fromJson(result);
  }
}

enum PinVerifyStatus { success, wrongPin, locked, forceOtp }

class PinVerifyResult {
  final PinVerifyStatus status;
  final DateTime? lockedUntil;
  final int? attempts;
  // ... fromJson constructor
}
```

### 7.4 App Navigation Guard

Every screen except the auth flow must check:
1. Firebase user is signed in (`FirebaseAuth.instance.currentUser != null`)
2. User has `pin_hash` set in DB
3. PIN has been verified this session (in-memory provider flag)

```dart
// providers/auth_state_provider.dart
enum AuthState { unknown, unauthenticated, needsPin, needsPinSetup, authenticated }

final authStateProvider = StreamProvider<AuthState>((ref) async* {
  await for (final _ in FirebaseAuth.instance.authStateChanges()) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { yield AuthState.unauthenticated; continue; }
    
    final userData = await Supabase.instance.client
      .from('users')
      .select('pin_hash')
      .single();
    
    if (userData['pin_hash'] == null) yield AuthState.needsPinSetup;
    else yield AuthState.needsPin;
    // AuthState.authenticated is set by PinService after successful verify
  }
});
```

---

## 8. General Coding Conventions

### Flutter / Dart

**File naming**: `snake_case` for all files.

**Class naming**: `PascalCase`. **Variables/methods**: `camelCase`. **Constants**: `kCamelCase`.

**State management**: Riverpod exclusively. No `setState` in screen widgets.

**Service layer**: All Supabase/Firebase calls go through `lib/services/`. Services return typed domain models, not raw Maps.

**Financial amounts**: Use `double` in Dart. `DECIMAL(10,2)` in PostgreSQL. Format with `intl`:
```dart
NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(amount)
```

**Error handling**: Catch `FirebaseAuthException` and `PostgrestException` explicitly. Never let raw exceptions reach the UI.

---

### TypeScript / Next.js (Admin)

**No `any` types**. Use proper interfaces for all data.

**Server components by default**. Use `'use client'` only for interactive UI.

**Admin DB access**: Always `SUPABASE_SERVICE_ROLE_KEY` server-side. Never `ANON_KEY` for admin operations.

**Firebase Admin JWT verification** on every protected Next.js middleware call (see API Contracts doc).

---

### SQL / Migrations

Every migration file needs a comment header:
```sql
-- Migration: 014_pin_lockout_fields.sql
-- Date: 2026-03-01
-- Author: <name>
-- Purpose: Add PIN failure tracking to users table
-- Rollback: ALTER TABLE users DROP COLUMN pin_failed_attempts, DROP COLUMN pin_locked_until;
```

Every new table needs `ENABLE ROW LEVEL SECURITY` + at least one policy. A table with RLS enabled and no policies = zero access for anyone, including admins.

---

## 9. Common Pitfalls & Rules

| ❌ Don't | ✅ Do |
|---------|-------|
| Store PAYU_SALT in code | `--dart-define` for Flutter, Supabase secrets for edge functions |
| Use Supabase service role key in Flutter | Only in Next.js server-side and edge functions |
| Log or print PIN values at any point | Never log PINs, even hashed ones |
| Store Firebase ID Token in SharedPreferences | FirebaseAuth SDK manages token lifecycle |
| Manually set `Authorization` header for Supabase | Use `accessToken` callback in `Supabase.initialize()` |
| Compare PIN plain text anywhere | Always use bcrypt: hash on client, compare via RPC |
| Use `setState` with Riverpod | Use providers and `ref.invalidate()` |
| Use `int` for money/coins | `double` in Dart, `DECIMAL(10,2)` in DB |
| Skip RLS on new tables | Always `ENABLE ROW LEVEL SECURITY` + policies |
| Apply DB changes without a migration file | Always write and track SQL migration files |
| Allow more than 1 Supabase client instance | Initialize once in `main.dart`, access via `Supabase.instance.client` |
| Expose `pin_hash` in API responses | Only expose `pin_hash != null` (boolean) for setup-check |

---

## 10. Test Accounts Reference

| Role | Phone | OTP | PIN | Notes |
|------|-------|-----|-----|-------|
| Customer | `9999999999` | `123456` | Set at first run | Test customer account |
| Merchant | `8888888888` | `654321` | Set at first run | Must have `role='merchant'` in DB |
| Admin | `7777777777` | `000000` | Set at first run | Must have `role='admin'` in DB |

> Test phone numbers must be registered in Firebase Console → Authentication → Phone → Test phone numbers.

> After DB reset (`supabase db reset`), re-create these accounts via the app's registration flow.

---

## 11. Resources

| Resource | URL |
|----------|-----|
| Supabase Dashboard | https://app.supabase.com/project/wpnngcuoqtvgwhizkrwt |
| Firebase Console | https://console.firebase.google.com/project/momope-production |
| Public Website (live) | https://momope.com |
| Supabase Docs | https://supabase.com/docs |
| Flutter Docs | https://flutter.dev/docs |
| Firebase Phone Auth (Flutter) | https://firebase.google.com/docs/auth/flutter/phone-auth |
| Riverpod Docs | https://riverpod.dev |
| bcrypt (Dart) | https://pub.dev/packages/bcrypt |
| Conventional Commits | https://www.conventionalcommits.org |

---

*Welcome to MomoPe. Phone is identity. PIN is trust. Build accordingly.*
