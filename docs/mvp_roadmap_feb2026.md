# MomoPe Ecosystem Review & MVP Implementation Roadmap

**Date:** February 17, 2026  
**Purpose:** Technical summary + execution plan based on MOMOPE_ECOSYSTEM.md  
**Status:** Planning document for core business logic implementation

---

## Part I: Ecosystem Summary

### Business Model (60-Second Overview)

**What MomoPe Is:**
- Commission-based rewards platform (20-35% merchant commission)
- Customers earn coins (2-10% algorithmic rewards) on transactions
- Coins redeemable up to 80% of future bills
- Merchant-funded loyalty program

**What MomoPe Is NOT:**
- ❌ Not a wallet (no "Add Money")
- ❌ Not a PSP (uses PayU for payment processing)
- ❌ Not a prepaid instrument (coins expire in 90 days)
- ❌ Not peer-to-peer (no coin transfers)

**Why This Matters:** Avoids RBI wallet/PPI licensing requirements.

---

## Part II: Technical Architecture

### Stack Overview

**Mobile Apps** (✅ Production Ready - Feb 17, 2026):
- Flutter 3.41.1 + Dart 3.11.0
- Riverpod for state management
- Google Sign-In authentication
- QR scanner (mobile_scanner 5.2.3)
- Android: Min SDK 21, Target SDK 36

**Backend Infrastructure** (✅ Deployed):
- Supabase PostgreSQL 15.x (Mumbai region)
- Project: `wpnngcuoqtvgwhizkrwt`
- 7 core tables with RLS policies
- Edge Functions (Deno/TypeScript)
- Cron jobs for coin expiry (pg_cron)

**Payment Gateway** (🚧 In Progress):
- PayU Merchant ID: `U1Zax8` (Test Mode)
- No production keys yet - build everything except live payments

### Database Schema (7 Tables)

| Table | Purpose | Status |
|-------|---------|--------|
| `users` | Customer/Merchant/Admin profiles | ✅ Live |
| `user_mappings` | Firebase ↔ Supabase auth bridge | ✅ Live |
| `momo_coin_balances` | Aggregate coin balances | ✅ Live |
| `merchants` | Business info, commission rates | ✅ Live |
| `transactions` | Payment records | ✅ Live |
| `commissions` | Revenue ledger | ✅ Live |
| `coin_batches` | FIFO expiry tracking (90 days) | ✅ Live |
| `coin_transactions` | Complete audit trail | ✅ Live |

---

## Part III: Core Business Logic

### The Coin Economy

**Earning Coins** (Algorithm determines 2-10%):
```
1. User Tier (transaction history):
   - NEW (0-1 txns): 10% acquisition incentive
   - ENGAGED (2-5 txns): 9% habit formation
   - REGULAR (6-20 txns): 8% sustained engagement
   - LOYAL (21+ txns): 7% already retained

2. Platform Liability:
   - If total liability > ₹1,00,000: Reduce by 2%

3. Transaction Value:
   - High-value (≥₹5,000): +1% bonus
   - Micro (<₹100): -2% adjustment

4. Time-Based:
   - Weekend (Sat/Sun): +0.5%
   - Off-peak (10 AM-4 PM): +0.5%

Result: Capped at 10% maximum
```

**Redeeming Coins** (Dual Cap Rule):
```
Max Redeemable = min(
  Bill Amount × 80%,
  User Balance × 80%
)
```

**Coin Expiry:**
- 90 days from earn date
- FIFO tracking via `coin_batches` table
- Daily cron job expires old batches

### Commission Structure

| Category | Default Rate |
|----------|--------------|
| Grocery | 20% |
| Food & Beverage | 25% |
| Retail/Lifestyle | 30% |
| Services | 35% |

**Policy:** Minimum 15% (updated Feb 2026)

---

## Part IV: Customer-Merchant-Admin Flow

### Customer Journey

```
1. DISCOVERY
   ├─ Download app
   ├─ Google Sign-In
   └─ Auto-create user + coin_balance

2. BROWSE
   ├─ View nearby merchants (map/list)
   ├─ See commission rates
   └─ Check coin balance

3. PAYMENT
   ├─ Scan merchant QR code
   ├─ Enter bill amount
   ├─ Select coins to redeem (0-80%)
   ├─ Pay fiat with PayU
   └─ Earn coins (algorithm-determined %)

4. REWARDS
   ├─ Coins credited instantly
   ├─ View transaction history
   ├─ Track expiring coins
   └─ Redeem on next purchase
```

### Merchant Journey

```
1. ONBOARDING
   ├─ Download merchant app
   ├─ Google Sign-In
   ├─ Business KYC (manual approval)
   ├─ Set commission rate (negotiate)
   └─ Receive QR code

2. OPERATIONS
   ├─ Display QR at counter
   ├─ Customer scans + pays
   ├─ View real-time transactions
   └─ Track commission deductions

3. SETTLEMENT
   ├─ T+3 fiat settlement (standard)
   ├─ View settlement schedule
   ├─ Download statements
   └─ Request early settlement (premium)
```

### Admin Workflow

```
1. MERCHANT MANAGEMENT
   ├─ Review KYC applications
   ├─ Approve/reject merchants
   ├─ Set commission rates
   └─ Manage merchant status

2. PLATFORM MONITORING
   ├─ Track total GMV
   ├─ Monitor coin liability
   ├─ Manage reserves
   └─ Process settlements

3. SUPPORT
   ├─ Handle disputes
   ├─ Refund transactions
   └─ Expire coins manually
```

---

## Part V: MVP Priorities (What to Build Now)

### Phase 1: Core Business Logic (CURRENT PRIORITY)

**Payment Flow End-to-End:**
1. ✅ QR code scanning (customer app)
2. ✅ Payment preview screen (amount + coins)
3. 🚧 PayU integration (UI done, API pending production keys)
4. ✅ Coin earning calculation (algorithm)
5. ✅ Transaction record creation
6. ✅ Commission calculation
7. ✅ Coin balance update

**Status:** 85% complete - waiting for PayU production keys

---

**Coin Redemption Logic:**
1. ✅ Fetch user balance
2. ✅ Calculate max redeemable (dual cap)
3. ✅ Apply coins to transaction
4. ❌ **MISSING: Create coin redemption records**
5. ❌ **MISSING: Update coin_batches (FIFO deduction)**

**Priority:** Implement FIFO coin redemption logic

---

**Transaction History:**
1. ✅ Fetch user transactions
2. ✅ Display list with filters
3. ❌ **MISSING: Transaction detail screen**
4. ❌ **MISSING: Download receipt/invoice**

**Priority:** Build transaction detail screen

---

### Phase 2: Customer App Completion

**Profile/Account:**
- Basic profile editing
- Phone/email verification
- KYC status display

**Rewards/Offers:**
- Expiring coins notification
- Merchant discovery (map-based)
- Reward recommendations

**Technical Debt:**
- Error handling improvements
- Offline mode support
- Analytics integration

---

### Phase 3: Merchant App (After Customer App Stable)

**Core Features:**
- Transaction dashboard
- QR code display
- Settlement tracking
- Commission breakdown

**Future:**
- Inventory management
- Promotions/campaigns
- Customer insights

---

### Phase 4: Admin Dashboard (Q2 2026)

**Web Platform** (Next.js + Shadcn UI):
- admin.momope.com
- merchant.momope.com (portal)
- www.momope.com (public site)

---

## Part VI: Recent Updates (February 2026)

### Completed (Not Yet in MOMOPE_ECOSYSTEM.md)

**✅ Premium UI Design System:**
- Brand color palette (teal primary, gold rewards)
- Typography system (Google Fonts - Inter)
- Component library (PremiumCard, PremiumButton)
- Consistent spacing/shadows

**✅ Home Screen UI Polish:**
- Quick Actions (minimal, no background)
- Nearby Rewards carousel (category-based gradients)
- Premium Coins card (multi-tone gradient, earning indicator)
- Recent Activity section

**✅ Navigation:**
- 5-tab bottom navigation
- QR scanner as FAB
- Smooth transitions

**✅ QR Scanner:**
- Full-screen premium design
- Torch toggle
- Gallery scan support

**✅ Transaction History:**
- List view with filters
- Status badges
- Pull-to-refresh

### To Document in MOMOPE_ECOSYSTEM.md

```markdown
## 23. Customer App (Updated February 17, 2026)

### UI/UX Status: ✅ Premium Fintech Design Complete

**Design System:**
- Brand Colors: Teal (#14B8A6), Gold (#F59E0B)
- Typography: Google Fonts (Inter family)
- Component Library: PremiumCard, PremiumButton, TransactionCard
- Navigation: 5-tab bottom nav + QR FAB

**Home Screen:**
- Quick Actions: Minimal design, 4 actions (Offers, Merchants, Rewards, Invite)
- Coins Card: Multi-tone gradient, earning indicator (+X this week), rupee value
- Nearby Rewards: Horizontal carousel, category-based gradients, 2.3 cards visible
- Recent Activity: Transaction list with status badges

**Core Screens:**
- ✅ Splash: Brand identity, auto-login
- ✅ Auth: Google Sign-In
- ✅ Home: Ment above
- ✅ QR Scanner: Full-screen, torch toggle
- ✅ Payment Preview: Amount, coins, fiat breakdown
- ✅ Transaction History: List + filters
- 🚧 Transaction Detail: In progress
- ⏳ Profile: Basic identity display

**Technical:**
- Flutter 3.41.1 stable
- Responsive design (all screen sizes)
- Pull-to-refresh throughout
- Error states implemented
```

---

##Part VII: Implementation Roadmap

### Immediate Next Steps (This Week)

**Priority 1: FIFO Coin Redemption Logic**
- Read coin_batches for user (ORDER BY created_at ASC)
- Deduct from oldest batches first
- Create coin_transactions records
- Update coin_batches remaining_coins
- Handle edge cases (partial batch deduction)

**Priority 2: Transaction Detail Screen**
- Full transaction breakdown
- Merchant info
- Coins earned/redeemed
- Commission display (for merchants)
- Share/download receipt

**Priority 3: Error Handling**
- Network failures
- Payment timeouts
- Insufficient balance errors
- Expired session handling

### Next Week

**Customer App Polish:**
- Profile screen completion
- Expiring coins notification
- Merchant detail view
- Search/filter improvements

**Merchant App:**
- Audit existing implementationRefine dashboard
- Test settlement flow
- Commission tracking

### Month 1 Goals

- ✅ Customer app: 100% feature-complete (minus PayU production)
- ✅ Merchant app: Core features stable
- 🚧 Admin dashboard: Planning/design phase
- 🚧 Public website: Wireframes

---

## Part VIII: Testing Strategy

### Without PayU Production Keys

**Mock Payment Flow:**
```dart
// Simulate successful payment
final mockPaymentSuccess = {
  'status': 'completed',
  'payu_id': 'MOCK_${DateTime.now().millisecondsSinceEpoch}',
  'amount': billAmount,
};

// Test coin earning
// Test commission calculation
// Test transaction recording
```

**What We CAN Test:**
- ✅ QR scanning
- ✅ Payment UI/flow
- ✅ Coin calculations
- ✅ Transaction display
- ✅ Balance updates (with mock data)

**What We CANNOT Test:**
- ❌ Actual PayU API calls
- ❌ Real money transfers
- ❌ Payment gateway failures

**Strategy:** Build complete flow with mock mode toggle

---

## Part IX: Deployment Checklist

### Before Production Launch

**Customer App:**
- [ ] PayU SDK integration (prod keys)
- [ ] Payment flow end-to-end tested
- [ ] Error handling complete
- [ ] Terms & privacy policy links
- [ ] App store assets (screenshots, description)

**Backend:**
- [ ] PayU webhook tested
- [ ] Coin expiry cron verified
- [ ] RLS policies audited
- [ ] Database backups configured
- [ ] Monitoring/alerts setup

**Compliance:**
- [ ] Legal review (T&C, privacy)
- [ ] KYC process defined
- [ ] Settlement agreements signed
- [ ] Insurance/liability coverage

---

## Part X: Success Metrics

### MVP Success Criteria

| Metric | Target (Month 1) |
|--------|------------------|
| Registered Users | 100 |
| Active Merchants | 5 |
| Transactions | 50 |
| GMV Processed | ₹50,000 |
| Coin Liability | < ₹10,000 |
| Commission Earned | ₹10,000 |

### Growth Metrics (Year 1)

| Metric | Q1 | Q2 | Q3 | Q4 |
|--------|-----|-----|-----|-----|
| Users | 500 | 2K | 5K | 10K |
| Merchants | 20 | 50 | 100 | 150 |
| GMV | ₹5L | ₹20L | ₹50L | ₹1Cr |

---

## Conclusion

**Current Status:**
- Customer app: Premium UI complete, core logic 85% done
- Backend: Infrastructure stable, awaiting PayU production keys
- Merchant app: Basic features live, needs refinement

**Immediate Focus:**
1. FIFO coin redemption logic
2. Transaction detail screen
3. Error handling improvements

**Next Phase:**
- Profile/account completion
- Merchant app polish
- Admin dashboard planning

**Timeline:** MVP fully operational (minus live payments) by end of February 2026.
