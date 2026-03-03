# MomoPe — Product Requirements Document (PRD)

**Version**: 2.0  
**Date**: February 2026  
**Status**: Pre-Implementation Reference  
**Owner**: Founders — Damerla Mohan, Damerla Mounika  
**Change from v1.0**: Google Sign-In removed entirely. Firebase Phone OTP + PhonePe-style PIN is the only authentication method.

---

## 1. Overview

MomoPe is a **merchant-funded loyalty rewards platform** that sits as an engagement layer on top of payment infrastructure (PayU). It is not a wallet, not a PSP, and not a prepaid instrument. Revenue comes exclusively from merchant commissions. Customers are rewarded with Momo Coins on every eligible transaction.

**Company**: MOMO PE DIGITAL HUB PRIVATE LIMITED (CIN: U63120AP2025PTC118821)  
**Tagline**: "Empowering merchants. Rewarding customers. Building the future of local commerce."

---

## 2. Problem Statement

### For Customers
Traditional loyalty programs are delayed, complex, and siloed. Digital wallets require pre-loading money. Credit cards carry high entry barriers.

### For Merchants
Customer acquisition via digital ads costs ₹500–₹2,000 per customer. There is no affordable, effective retention mechanism for small local businesses. UPI is free but offers zero engagement layer.

### MomoPe's Answer
Instant merchant-funded rewards. No pre-loading. No hidden terms. **Phone number is the only identity** — familiar to every Indian user, zero friction, just like PhonePe.

---

## 3. Product Scope

### What MomoPe IS
- A loyalty rewards platform (coins earned on purchases)
- A technology layer on top of PayU (not the payment processor)
- A commission-based business (revenue = GMV × commission %)

### What MomoPe IS NOT
- Not a wallet (no "Add Money", no stored value)
- Not a PSP (PayU handles all payment processing)
- Not a PPI (coins cannot be cashed out or transferred P2P)
- Not a coin-settlement system (merchants always receive INR, never coins)

---

## 4. Products in Scope

| Product | Platform | Audience | Priority |
|---------|----------|----------|----------|
| Customer App | Android (Flutter) | End consumers | P0 |
| Merchant App | Android (Flutter) | Business owners | P0 |
| Super Admin Dashboard | Web (Next.js 15) | Internal team | P1 |

---

## 5. User Personas

### 5.1 Customer (End Consumer)
Urban/semi-urban shoppers aged 18–45, UPI-savvy. They are accustomed to PhonePe/GPay-style phone-first authentication. Email addresses and passwords are friction for them.

### 5.2 Merchant (Business Owner)
Local business owners in grocery, F&B, retail, services. Phone number is their primary digital identity. May not be tech-literate beyond basic smartphone usage.

### 5.3 Super Admin (Internal MomoPe Team)
Founders and operations team. Same auth system — phone OTP + PIN.

---

## 6. Authentication — PhonePe-Style Experience ⭐

This is the core UX differentiator. Authentication must feel instant, familiar, and PIN-driven. No emails, no passwords, no Google accounts.

### 6.1 First-Time Registration Flow

```
① Enter phone number   →   10-digit Indian mobile number
② Enter OTP            →   6-digit SMS OTP via Firebase Phone Auth (60s timer)
③ Enter name           →   Display name (first & last, optional last)
④ Enter referral code  →   Optional step, skip available
⑤ Set PIN              →   4-digit or 6-digit PIN (design decision at sprint time)
⑥ Confirm PIN          →   Re-enter to confirm
⑦ Home screen          →   ✅ Loyalty loop begins
```

### 6.2 Returning User Flow (Everyday Experience)

```
App opens  →  PIN entry screen appears
             ●●●●  (dots fill as digits typed)
             Auto-submits on last digit
             ✅ Home screen
```

No OTP required for returning users. This is the 99% case. Make it fast.

### 6.3 Forgot PIN Flow

```
"Forgot PIN?" tap  →  Enter phone number  →  OTP verification  →  Set new PIN  →  Confirm PIN  →  Home
```

### 6.4 PIN Rules & Security
- 4 or 6 digits (consistent across the app, decided at implementation sprint)
- Invalid PINs rejected with UI error: all same digits (`0000`, `1111`...), sequential ascending (`1234`, `2345`...), sequential descending (`4321`, `9876`...)
- Stored as **bcrypt hash** (cost ≥ 10) in `users.pin_hash` — never plain text, never in logs
- PIN never transmitted in plain text over any network connection
- Wrong PIN attempts: 5 consecutive failures → 30-second countdown lockout. After 10 total failures → force OTP re-verification flow

### 6.5 PIN Entry UX (Implementation Reference)
- Masked dot display: `● ● ● ●` — each tap fills a dot
- Auto-submits on last digit entry (no "Confirm" button needed)
- Backspace clears last entry
- No copy-paste allowed on the PIN field
- Shake animation + red dots on wrong PIN
- Green fill animation + brief success state on correct PIN before navigating

### 6.6 Session & Background Behaviour
- Firebase ID token: 1-hour lifetime, refreshed silently in background
- App backgrounded > 5 minutes → PIN prompt on resume
- App cold start → always PIN prompt (even if session is valid)
- App force-closed → PIN prompt on reopen

### 6.7 Biometric Unlock (Post-MVP, Optional)
After setting their PIN, users can enable fingerprint or face unlock via device secure enclave (`local_auth` package). MomoPe never receives biometric data. Biometrics are a convenience layer on top of PIN — disabling biometrics always falls back to PIN.

---

## 7. Functional Requirements

### 7.1 Customer App

#### Authentication
- **REQ-C-001**: Phone number is the only identity. No email, no Google Sign-In, no passwords.
- **REQ-C-002**: OTP delivered via Firebase Phone Auth SMS. First 10,000/month are free.
- **REQ-C-003**: OTP screen: 6-digit input, 60-second countdown, "Resend OTP" after expiry. Max 3 resend attempts per session, then 10-minute cooldown.
- **REQ-C-004**: After successful OTP verification, the app checks if user has `pin_hash` set. If not (new user) → Name entry → PIN setup. If yes (returning user with lost session) → new PIN prompt is skipped, user enters existing PIN.
- **REQ-C-005**: All Supabase API calls use Firebase ID token as the `Authorization: Bearer` header.
- **REQ-C-006**: `users.id` = Firebase UID (alphanumeric string). This is the primary key and is what `auth.uid()` returns in Supabase RLS.

#### Home Screen
- **REQ-C-010**: Display current Momo Coin balance prominently.
- **REQ-C-011**: Upcoming expiry warning for coins expiring within 7 days.
- **REQ-C-012**: Referral stats card (referrals made, coins earned from referrals).

#### Merchant Discovery (Explore)
- **REQ-C-020**: List all KYC-approved, active, operational merchants.
- **REQ-C-021**: Show merchant name, category, and distance (if location permission granted).
- **REQ-C-022**: Search merchants by name.

#### Payment Flow
- **REQ-C-030**: Customer scans merchant QR code to initiate payment.
- **REQ-C-031**: Customer enters bill amount.
- **REQ-C-032**: System calculates and displays: `coins_available`, `max_redeemable` (80% rule), `coins_to_use` (user-adjustable slider/input), `fiat_to_pay`.
- **REQ-C-033**: `initiate-payment` edge function called with Firebase JWT. Phone number passed from Firebase Auth (no re-entry needed) — satisfies PayU's customer identity requirement automatically.
- **REQ-C-034**: PayU CheckoutPro SDK handles fiat payment.
- **REQ-C-035**: PayU webhook → `process_transaction_success()` → atomic: redeem coins (FIFO) + award new coins + record commission + update status.
- **REQ-C-036**: Result screen: coins earned, new balance, success/failure state.

#### Coin Rules
- **REQ-C-040**: Coins earned on fiat amount paid only (not coins-redeemed portion).
- **REQ-C-041**: Earn rate 2%–10%, MomoPe algorithm only. Merchants have zero influence.
- **REQ-C-042**: Tier: New (0–1 txns)=10%, Engaged (2–5)=9%, Regular (6–20)=8%, Loyal (21+)=7%.
- **REQ-C-050**: Max redemption = min(bill × 80%, available_balance × 80%). FIFO. 90-day expiry.
- **REQ-C-051**: Coins: non-withdrawable, non-transferable, non-P2P.

#### Transaction History
- **REQ-C-060**: List: date, merchant name, amount, coins earned/redeemed, status.

#### Profile
- **REQ-C-070**: Display name, phone number (masked: `98XXXXX210`), referral code with share.
- **REQ-C-071**: "Change PIN" option — requires current PIN verification, then new PIN setup flow.

#### Referral System
- **REQ-C-080**: Unique `referral_code` generated at registration.
- **REQ-C-081**: Referee enters referral code during onboarding (step 4 of registration).
- **REQ-C-082**: On referee's first successful transaction → referrer and referee both earn bonus coins via `process-referral` edge function.

---

### 7.2 Merchant App

#### Authentication
- **REQ-M-001**: Identical Firebase Phone OTP + PIN system. Merchants log in with their business phone number.
- **REQ-M-002**: After PIN verification, app checks `users.role` server-side. If `role = 'customer'` → `CustomerAccountException` thrown, access denied with a clear error message.
- **REQ-M-003**: Merchants without an approved merchant profile → KYC registration screen shown.

#### KYC Registration
- **REQ-M-010**: Collect: business name, category (grocery / food_beverage / retail / services / other), GSTIN, PAN, business address, bank account number, IFSC, account holder name, GPS coordinates.
- **REQ-M-011**: `kyc_status` flow: `pending → approved | rejected`. Rejection populates `kyc_rejection_reason`.
- **REQ-M-012**: No payments accepted until `kyc_status = 'approved'`.

#### QR Code Display
- **REQ-M-020**: Merchant home screen shows a QR code encoding the merchant's UUID.
- **REQ-M-021**: Customer scanning this QR prefills merchant in the customer payment flow.

#### Dashboard
- **REQ-M-030**: Today's GMV, today's commission, transaction count today.
- **REQ-M-031**: 7-day revenue bar chart.

#### Settlements
- **REQ-M-040**: Settlement list: date, amount, status (pending/processed). INR only.

#### Transaction History
- **REQ-M-050**: All transactions for this merchant (customer anonymized).

---

### 7.3 Super Admin Dashboard

#### Overview
- **REQ-A-001**: Live metrics: total users, total merchants, GMV, commission, coin liability, coverage ratio.

#### Merchant Management
- **REQ-A-010**: List merchants with KYC status filter. Approve/reject KYC. Deactivate/reactivate.

#### User Management
- **REQ-A-020**: List users with role, phone (masked), created date, coin balance.

#### Coin & Settlements
- **REQ-A-030**: Manual coin credit/debit (fraud, promotions). Mark settlements as processed. CSV export.

#### Access
- **REQ-A-040**: Admin role verified via `users.role = 'admin'` lookup by Firebase UID on every protected route.

---

## 8. Non-Functional Requirements

### Security
- PIN stored as bcrypt hash (cost ≥ 10), never plain text anywhere
- Firebase JWT used as sole bearer token for all Supabase API calls (RS256, Google-signed)
- All tables behind RLS; `auth.uid()` = Firebase UID string
- Service Role key only on server-side (Next.js API routes, never in Flutter)
- 5 wrong PINs → 30s lockout; 10 wrong → force OTP re-verify
- PayU webhook verified via HMAC-SHA512 before any DB writes

### Financial Integrity
- `gross_amount = fiat_amount + coins_applied` — DB CHECK constraint
- `net_revenue = total_commission - reward_cost` — DB CHECK constraint
- `total_coins = available_coins + locked_coins` — DB CHECK constraint
- `process_transaction_success()` is atomic — full rollback on any failure
- Coverage ratio ≥ 60% always

### Performance
- OTP delivery < 5 seconds (Firebase SLA)
- PIN hash verification < 100ms (local bcrypt compare)
- Payment initiation API < 2 seconds P95

### Compliance
- Phone number = primary identity (satisfies PayU customer ID requirement)
- KYC (PAN + GSTIN) for all merchants before activation
- 90-day coin expiry clearly shown in UI
- Coins = promotional loyalty units (not PPI)

---

## 9. Business Rules (Critical)

| Rule | Description |
|------|-------------|
| 80/20 Rule | Redeem max 80% of bill or 80% of balance, whichever is lower |
| FIFO Expiry | Oldest coin batches redeemed first; 90-day expiry per batch |
| Commission Floor | Min 15%, Max 50% per merchant |
| Rewards Exclusivity | Merchants have zero control over customer reward % |
| Coin 1:1 Value | 1 Momo Coin = ₹1 always |
| No Coin-to-Merchant | Merchants receive INR only |
| Commission on Gross | Commission = gross_amount × rate (not fiat_amount) |
| Atomic Transactions | Coin award + redemption + commission = one DB transaction |
| PIN Mandatory | No user can access the app without setting a PIN |
| Phone-Only Identity | No email login, no Google, no password |

---

## 10. Success Metrics

| Metric | Target (Month 12) |
|--------|-------------------|
| Monthly Active Users | 10,000 |
| Active Merchants | 150 |
| GMV | ₹10 Cr |
| Net Revenue | ₹1.8 Cr |
| Coverage Ratio | ≥ 60% |
| OTP Delivery Success Rate | > 95% |
| D7 Retention | > 40% |

---

*This PRD is the pre-implementation source of truth. v2.0 replaces Google Sign-In with Firebase Phone OTP + PIN throughout.*
