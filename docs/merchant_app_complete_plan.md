# Merchant App - Complete Implementation Plan

**Date:** February 17, 2026  
**Goal:** Build production-ready merchant app per ecosystem requirements  
**Timeline:** 2-3 days

---

## Requirements Analysis (from MOMOPE_ECOSYSTEM.md)

### Core Features Required:

**Home/Dashboard Screen:**
- ✅ QR code (prominent, printable) - **DONE**
- ⚠️ Today's transactions count/value - **TODO**
- ⚠️ Pending settlement amount - **TODO**
- ⚠️ Quick stats (earnings, orders) - **TODO**

**Transaction List:**
- ❌ Real-time updates via Supabase realtime
- ❌ Filter by date/status
- ❌ Transaction details (gross, commission, fiat, coins)
- ❌ Search functionality

**Settlement:**
- ❌ Upcoming settlement schedule
- ❌ Past settlements list
- ❌ Download statements (CSV/PDF)**Profile:**
- ⚠️ Business info - **Partially done (QR screen)**
- ❌ Commission rate (view-only)
- ❌ Bank details
- ❌ Support contact
- ❌ Logout

---

## Current State Assessment

### ✅ Complete:
1. **Registration Screen** - Premium UI with GSTIN/PAN validation
2. **QR Code Display** - Glass morphism, category badges
3. **Bottom Navigation** - Dashboard/QR tabs
4. **Premium Design System** - Unified with customer app
5. **Authentication** - Google Sign-in

### ⚠️ Partial:
1. **Merchant Model** - Has schema, needs methods
2. **Dashboard Screen** - Exists but placeholder
3. **Navigation** - Basic structure

### ❌ Missing:
1. **Transaction History Screen** - Doesn't exist
2. **Transaction Details Screen** - Doesn't exist
3. **Settlement Screen** - Doesn't exist
4. **Profile Screen** - Doesn't exist
5. **Stats/Analytics** - No data providers
6. **Realtime Updates** - Not implemented

---

## Database Schema Review

### Tables Used by Merchant App:

**`merchants`** (primary):
```sql
- id (uuid)
- user_id (uuid, FK to users)
- business_name
- category
- commission_rate (decimal)
- business_address
- gstin, pan
- bank_account_number, ifsc_code, bank_account_holder_name
- kyc_status (pending, approved, rejected)
- is_active, is_operational
- created_at, updated_at
```

**`transactions`** (for merchant dashboard):
```sql
- id (uuid)
- user_id (customer FK)
- merchant_id (FK to merchants)
- gross_amount (bill total)
- coin_amount (coins redeemed)
- fiat_amount (actual paid via PayU)
- rewards_earned (coins given to customer)
- status (pending, success, failed)
- payment_method
- created_at
```

**`commissions`** (for earnings tracking):
```sql
- id (uuid)
- transaction_id (FK)
- merchant_id (FK)
- gross_revenue (commission earned)
- coin_cost (rewards given to customer)
- net_revenue (gross - coin_cost)
- is_settled (boolean)
- settlement_date
- created_at
```

**`merchant_settlements`** (for payouts):
```sql
- id (uuid)
- merchant_id (FK)
- settlement_period_start
- settlement_period_end
- total_transactions_count
- total_gross_revenue
- total_coin_cost
- total_net_revenue
- total_coins_redeemed
- final_settlement_amount (net - coins redeemed value)
- status (pending, processed, paid)
- scheduled_date
- paid_date
- created_at
```

---

## Proposed Changes

### Phase 1: Data Layer (Providers & Services)

**1. Merchant Provider** (`merchant_provider.dart`)

```dart
// Fetch current merchant profile
final merchantProvider = StreamProvider<Merchant?>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return Stream.value(null);
  
  return Supabase.instance.client
    .from('merchants')
    .stream(primaryKey: ['id'])
    .eq('user_id', user.id)
    .map((data) => data.isEmpty ? null : Merchant.fromJson(data.first));
});
```

**2. Merchant Stats Provider** (`merchant_stats_provider.dart`)

```dart
// Today's stats
final todayStatsProvider = FutureProvider<MerchantDayStats>((ref) async {
  final merchant = await ref.watch(merchantProvider.future);
  if (merchant == null) throw 'No merchant';
  
  // Query today's transactions
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  
  final response = await Supabase.instance.client
    .rpc('get_merchant_daily_stats', params: {
      'merchant_uuid': merchant.id,
      'stats_date': startOfDay.toIso8601String(),
    });
  
  return MerchantDayStats.fromJson(response);
});
```

**3. Transactions Provider** (`merchant_transactions_provider.dart`)

```dart
// Realtime transaction stream
final merchantTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return Stream.value([]);
  
  return Supabase.instance.client
    .from('transactions')
    .stream(primaryKey: ['id'])
    .eq('merchant_id', merchantId)
    .order('created_at', ascending: false)
    .map((data) => data.map((json) => Transaction.fromJson(json)).toList());
});
```

**4. Settlements Provider** (`merchant_settlements_provider.dart`)

```dart
// Settlement history
final settlementsProvider = FutureProvider<List<MerchantSettlement>>((ref) async {
  final merchant = await ref.watch(merchantProvider.future);
  
  final response = await Supabase.instance.client
    .from('merchant_settlements')
    .select()
    .eq('merchant_id', merchant!.id)
    .order('created_at', ascending: false);
  
  return response.map((json) => MerchantSettlement.fromJson(json)).toList();
});
```

---

### Phase 2: New Models

**1. MerchantDayStats** (`models/merchant_day_stats.dart`)

```dart
class MerchantDayStats {
  final int transactionCount;
  final double totalRevenue;      // Gross commission
  final double netRevenue;         // After rewards
  final double pendingSettlement;
  final int customersServed;
  
  // Constructor, fromJson, toJson
}
```

**2. MerchantSettlement** (`models/merchant_settlement.dart`)

```dart
class MerchantSettlement {
  final String id;
  final String merchantId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int transactionCount;
  final double totalGrossRevenue;
  final double totalCoinCost;
  final double totalNetRevenue;
  final double finalSettlementAmount;
  final String status; // pending, processed, paid
  final DateTime? scheduledDate;
  final DateTime? paidDate;
  
  // Constructor, fromJson, toJson
}
```

**3. Transaction Model Enhancement** (already exists, verify fields)

---

### Phase 3: Screen Implementations

**1. Enhanced Dashboard Screen** (`merchant_dashboard_screen.dart`)

**Layout:**
```
┌──────────────────────────────────────┐
│  [Premium Gradient Header]          │
│  Today's Earnings: ₹2,450           │
│  15 Orders • 12 Customers           │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  📊 Stats Cards (Row of 3)          │
│  ┌──────┐ ┌──────┐ ┌──────┐        │
│  │Gross │ │ Net  │ │Pending│        │
│  │₹3,500│ │₹3,150│ │₹8,900│        │
│  └──────┘ └──────┘ └──────┘        │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  📅 Upcoming Settlement              │
│  ₹8,900 • Feb 20, 2026 (T+3)        │
│  [View Details →]                    │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  📝 Recent Transactions              │
│  [Transaction Card 1]                │
│  [Transaction Card 2]                │
│  [Transaction Card 3]                │
│  [View All →]                        │
└──────────────────────────────────────┘
```

**Features:**
- Premium cards with gradient accents
- Real-time stats updates
- Navigation to transaction details
- Pull-to-refresh

**2. Transaction History Screen** (`merchant_transaction_history_screen.dart`)

**Layout:**
```
┌──────────────────────────────────────┐
│  Transactions                [Filter]│
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  Date Tabs: Today | Week | Month    │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  [Transaction List - Grouped by Date]│
│  February 17, 2026                   │
│    [TransactionCard]                 │
│    [TransactionCard]                 │
│  February 16, 2026                   │
│    [TransactionCard]                 │
└──────────────────────────────────────┘
```

**Features:**
- Realtime subscription to transactions table
- Filter by status (all, success, failed)
- Date range selection
- Group by date
- Tap to view details
- Empty state with illustration

**3. Transaction Detail Screen** (`merchant_transaction_detail_screen.dart`)

**Layout:**
```
┌──────────────────────────────────────┐
│  [Status Banner - Success/Failed]    │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  Customer Info                       │
│  Phone: +91 98765 43210             │
│  Date: Feb 17, 2:45 PM              │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  Payment Breakdown                   │
│  Gross Amount         ₹1,000        │
│  Coins Redeemed       - ₹200        │
│  Fiat Paid           ₹800           │
│  ─────────────────────────────────  │
│  Your Commission (20%) ₹200         │
│  Rewards Given        - ₹80         │
│  Net Earnings         ₹120         │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  Transaction ID: abc123...           │
│  Payment Method: UPI                 │
│  Status: Success                     │
└──────────────────────────────────────┘
```

**Features:**
- Color-coded status
- Complete financial breakdown
- Copyable transaction ID
- Share receipt option

**4. Settlement Screen** (`merchant_settlement_screen.dart`)

**Layout:**
```
┌──────────────────────────────────────┐
│  Next Settlement                     │
│  ₹8,900 • Feb 20, 2026 (in 3 days) │
│  18 transactions                     │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  Settlement History                  │
│  ┌────────────────────────────────┐ │
│  │ Feb 13-17 • Paid ✅           │ │
│  │ ₹6,540 • 24 transactions      │ │
│  │ Paid on: Feb 18, 2026          │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │ Feb 6-12 • Paid ✅            │ │
│  │ ₹5,230 • 19 transactions      │ │
│  └────────────────────────────────┘ │
└──────────────────────────────────────┘
```

**Features:**
- Upcoming settlement countdown
- Settlement history list- Status badges (pending, processed, paid)
- Download CSV button (future)

**5. Profile Screen** (`merchant_profile_screen.dart`)

**Layout:**
```
┌──────────────────────────────────────┐
│  [Business Header - Gradient]        │
│  Green Cafe                          │
│  Food & Beverage • 25% commission   │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  📋 Business Details                 │
│  Address, GSTIN, PAN                 │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  💳 Banking (if added)               │
│  HDFC Bank • ****4567                │
│  [Update Banking]                    │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  ⚙️ Settings                         │
│  Support, Terms, Privacy, Logout     │
└──────────────────────────────────────┘
```

**Features:**
- View-only business info
- Edit banking details
- Logout with confirmation
- Support contact

---

### Phase 4: Database Functions (Supabase RPC)

**1. Get Merchant Daily Stats**

```sql
CREATE OR REPLACE FUNCTION get_merchant_daily_stats(
  merchant_uuid UUID,
  stats_date DATE
)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'transaction_count', COUNT(t.id),
    'total_revenue', COALESCE(SUM(c.gross_revenue), 0),
    'net_revenue', COALESCE(SUM(c.net_revenue), 0),
    'pending_settlement', (
      SELECT COALESCE(SUM(c2.net_revenue), 0)
      FROM commissions c2
      WHERE c2.merchant_id = merchant_uuid
        AND c2.is_settled = false
    ),
    'customers_served', COUNT(DISTINCT t.user_id)
  ) INTO result
  FROM transactions t
  LEFT JOIN commissions c ON c.transaction_id = t.id
  WHERE t.merchant_id = merchant_uuid
    AND DATE(t.created_at) = stats_date
    AND t.status = 'success';
  
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**2. Get Merchant Transaction Summary**

```sql
CREATE OR REPLACE FUNCTION get_merchant_transaction_summary(
  merchant_uuid UUID,
  start_date TIMESTAMPTZ,
  end_date TIMESTAMPTZ
)
RETURNS TABLE(
  date DATE,
  transaction_count BIGINT,
  total_gross NUMERIC,
  total_net NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    DATE(t.created_at) as date,
    COUNT(t.id)::BIGINT as transaction_count,
    COALESCE(SUM(c.gross_revenue), 0)::NUMERIC as total_gross,
    COALESCE(SUM(c.net_revenue), 0)::NUMERIC as total_net
  FROM transactions t
  LEFT JOIN commissions c ON c.transaction_id = t.id
  WHERE t.merchant_id = merchant_uuid
    AND t.created_at >= start_date
    AND t.created_at < end_date
    AND t.status = 'success'
  GROUP BY DATE(t.created_at)
  ORDER BY DATE(t.created_at) DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

### Phase 5: Navigation Updates

**Update BottomNavigationBar:**

```dart
bottomNavigationBar: BottomNavigationBar(
  currentIndex: _currentIndex,
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_rounded),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.qr_code_rounded),
      label: 'QR Code',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.receipt_long_rounded),
      label: 'Transactions',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.account_balance_wallet_rounded),
      label: 'Settlement',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ],
)
```

---

## File Structure (After Implementation)

```
merchant_app/lib/
├── core/
│   ├── theme/ (existing - shared design system)
│   └── widgets/ (existing - premium components)
├── models/
│   ├── merchant.dart (existing - enhanced)
│   ├── merchant_day_stats.dart (NEW)
│   ├── merchant_settlement.dart (NEW)
│   └── transaction.dart (NEW - copied from customer app)
├── providers/
│   ├── auth_provider.dart (existing)
│   ├── merchant_provider.dart (NEW)
│   ├── merchant_stats_provider.dart (NEW)
│   ├── merchant_transactions_provider.dart (NEW)
│   └── merchant_settlements_provider.dart (NEW)
├── screens/
│   ├── auth/ (existing)
│   ├── registration/ (existing - premium UI)
│   ├── home/
│   │   └── merchant_home_screen.dart (existing - QR display)
│   ├── dashboard/
│   │   └── merchant_dashboard_screen.dart (ENHANCED)
│   ├── transactions/
│   │   ├── merchant_transaction_history_screen.dart (NEW)
│   │   └── merchant_transaction_detail_screen.dart (NEW)
│   ├── settlements/
│   │   └── merchant_settlement_screen.dart (NEW)
│   └── profile/
│       └── merchant_profile_screen.dart (NEW)
└── main.dart (existing)
```

---

## User Review Required

> [!WARNING]
> **Database Functions**
> The SQL functions (`get_merchant_daily_stats`, `get_merchant_transaction_summary`) need to be executed in Supabase SQL Editor before the app can fetch stats. Should I proceed with these or would you prefer a different approach for data aggregation?

> [!IMPORTANT]
> **Settlement Logic**
> Merchant settlements are currently manual (admin-initiated). The app will display settlement data but won't trigger payouts. Is this acceptable for MVP, or should we build an automated settlement scheduler?

> [!NOTE]
> **Realtime Subscriptions**
> The transaction list will use Supabase realtime to auto-update when new transactions come in. This requires enabling realtime on the `transactions` table. Confirm if this is already enabled.

---

## Verification Plan

### 1. Database Setup Verification

**Prerequisites:**
- Ensure `merchants`, `transactions`, `commissions`, `merchant_settlements` tables exist
- Execute SQL functions in Supabase SQL Editor

**Test:**
```bash
# Via Supabase Dashboard → SQL Editor
SELECT get_merchant_daily_stats(
  '<merchant-uuid>'::UUID,
  CURRENT_DATE
);
```

**Expected Result:** JSON with today's stats

---

### 2. Provider Tests (Manual)

**Test merchant_provider:**
1. Sign in as merchant account
2. Verify merchant profile loads
3. Check realtime updates (change business name in Supabase)

**Test stats_provider:**
1. Navigate to dashboard
2. Verify today's stats display correctly
3. Create a test transaction in database
4. Verify stats update

---

### 3. Screen Flow Tests (Manual on Device)

**Dashboard Flow:**
1. Open merchant app
2. Sign in with Google
3. Navigate to Dashboard tab
4. **Verify:**
   - Today's earnings card shows correct amount
   - Transaction count matches database
   - Stats cards display properly
   - Pull-to-refresh works

**Transaction History Flow:**
1. Navigate to Transactions tab
2. **Verify:**
   - Transaction list loads
   - Grouped by date correctly
   - Tap transaction → detail screen opens
   - Filter by status works
   - Realtime: Add transaction in DB → auto-appears

**Transaction Detail:**
1. Tap a transaction from list
2. **Verify:**
   - All fields displayed correctly
   - Commission breakdown accurate
   - Status banner color-coded
   - Can copy transaction ID

**Settlement Flow:**
1. Navigate to Settlement tab
2. **Verify:**
   - Next settlement shows correct date
   - Amount matches pending commissions
   - Settlement history displays
   - Status badges correct

**Profile Flow:**
1. Navigate to Profile tab
2. **Verify:**
   - Business info accurate
   - Commission rate display-only
   - Banking details (if added)
   - Logout confirmation works

---

### 4. Edge Case Testing

**No transactions yet:**
- Verify empty states display
- Verify zero stats don't crash

**Failed transactions:**
- Verify status badge shows "Failed"
- Verify not included in earnings

**Pending settlements:**
- Verify countdown accurate
- Verify amount calculation correct

---

### 5. Performance Testing

**Realtime Subscription:**
- Monitor memory usage with long connection
- Verify no memory leaks after 10+ updates

**Large Transaction List:**
- Test with 100+ transactions
- Verify smooth scrolling
- Verify pagination (if implemented)

---

### 6. Build Verification

**Command:**
```bash
cd c:\DRAGON\MomoPe\merchant_app
flutter run -d <android-device>
```

**Expected Result:**
- ✅ Builds without errors
- ✅ All screens accessible via bottom nav
- ✅ No runtime exceptions

---

## Timeline

**Day 1 (4-5 hours):**
- Phase 1: Data layer (providers)
- Phase 2: New models
- Phase 3.1: Enhanced dashboard screen

**Day 2 (4-5 hours):**
- Phase 3.2: Transaction history screen
- Phase 3.3: Transaction detail screen
- Phase 3.4: Settlement screen

**Day 3 (3-4 hours):**
- Phase 3.5: Profile screen
- Phase 4: Database functions (SQL)
- Phase 5: Navigation updates
- Verification testing

---

## Success Criteria

**Functional:**
- ✅ Merchant can view today's earnings in real-time
- ✅ Merchant can see all transactions with filters
- ✅ Merchant can view transaction details
- ✅ Merchant can track settlement status
- ✅ Merchant can view/edit profile
- ✅ Realtime updates work correctly

**Technical:**
- ✅ Zero hardcoded values (use design tokens)
- ✅ Premium MomoPe brand consistency
- ✅ Proper error handling
- ✅ Loading states for all async operations
- ✅ Clean code architecture (providers/screens separation)

**UX:**
- ✅ Smooth navigation
- ✅ Pull-to-refresh on dashboards
- ✅ Empty states with helpful messages
- ✅ Success/error feedback for actions

---

## Out of Scope (Future Phases)

- Analytics dashboard (peak hours, demographics)
- CSV/PDF export
- Promotional offers management
- Multi-outlet support
- Push notifications
- In-app support chat

---

## Next Steps

1. **Get User Approval** on this plan
2. **Execute SQL Scripts** in Supabase
3. **Phase 1:** Build data layer
4. **Phase 2-3:** Build screens
5. **Phase 4-5:** Polish and verify
6. **User Testing:** Deploy to test device

Ready to proceed?
