# Merchant Analytics Dashboard - Implementation Plan

**Date**: February 17, 2026  
**Goal**: Add comprehensive analytics screen with revenue charts, performance metrics, and customer insights

---

## User Review Required

> [!IMPORTANT]
> **Breaking Change**: Adding 6th tab to navigation
> - Current: 5 tabs (Dashboard, QR, Transactions, Settlement, Profile)
> - New: 6 tabs (Dashboard, QR, Transactions, **Analytics**, Settlement, Profile)
> - Analytics will be positioned between Transactions and Settlement for logical flow

---

## Proposed Changes

### Component 1: Data Layer

#### [NEW] [analytics_provider.dart](file:///c:/DRAGON/MomoPe/merchant_app/lib/providers/analytics_provider.dart)
Provider for analytics data with 3 main streams:
- `revenueTrendProvider`: Daily revenue data for charts (7-day/30-day)
- `performanceMetricsProvider`: Growth %, peak hours, payment breakdown
- `customerInsightsProvider`: Repeat rate, avg basket, top customers
- Time period selector (7-day, 30-day, custom range)
- **Fallback**: Manual calculation if RPC doesn't exist yet

#### [NEW] Models (3 files)
- [`revenue_trend.dart`](file:///c:/DRAGON/MomoPe/merchant_app/lib/models/revenue_trend.dart): Chart data with daily values, labels, totals
- [`performance_metrics.dart`](file:///c:/DRAGON/MomoPe/merchant_app/lib/models/performance_metrics.dart): Growth metrics, peak hour, payment mix
- [`customer_insights.dart`](file:///c:/DRAGON/MomoPe/merchant_app/lib/models/customer_insights.dart): Customer stats, repeat rate, top customers

---

### Component 2: Analytics Screen

#### [NEW] [merchant_analytics_screen.dart](file:///c:/DRAGON/MomoPe/merchant_app/lib/screens/analytics/)
Main analytics screen with **3 tabs**:

**Tab 1: Revenue Overview**
- Period selector chips (7-day / 30-day / Custom)
- Revenue line chart using `fl_chart`
- Total revenue card with gradient
- Average daily revenue
- Trend indicator (↑ positive / ↓ negative)

**Tab 2: Performance**
- Week-over-week growth card with percentage
- Peak hour indicator with time display
- Payment method pie chart (Cash vs Coins distribution)
- Hourly distribution bar chart
-Transaction count breakdown

**Tab 3: Customers**
- Total vs repeat customers
- Repeat customer rate percentage
- Average basket size
- Average order value
- Top 5 customers list (masked IDs)

**UI Features**:
- Premium gradient headers
- Pull-to-refresh for all tabs
- Loading states with shimmer
- Empty states with helpful messages
- Responsive charts with touch interactions

---

### Component 3: Chart Widgets

#### [NEW] [revenue_line_chart.dart](file:///c:/DRAGON/MomoPe/merchant_app/lib/widgets/charts/)
Line chart for revenue trend:
- Uses `fl_chart` LineChart widget
- Teal gradient fill under line
- Touch tooltips showing exact values
- Date labels on X-axis
- Auto-scaling Y-axis

#### [NEW] [payment_pie_chart.dart](file:///c:/DRAGON/MomoPe/merchant_app/lib/widgets/charts/)
Pie chart for payment methods:
- Teal for cash payments
- Gold for coin redemptions
- Touch to show percentage
- Legend with color indicators

#### [NEW] [hourly_bar_chart.dart](file:///c:/DRAGON/MomoPe/merchant_app/lib/widgets/charts/)
Bar chart for hourly distribution:
- 24-hour view (0-23)
- Peak hour highlighted
- Gradient bars (teal)
- Touch tooltips

---

### Component 4: Database Functions

#### [NEW] [merchant_analytics_functions.sql](file:///c:/DRAGON/MomoPe/merchant_app/sql/)
3 PostgreSQL RPC functions:

**1. get_merchant_revenue_trend**
```sql
Parameters: merchant_uuid, start_date, end_date
Returns: { daily_values: [], labels: [], total_revenue, average_daily }
```
- Aggregates transactions by date
- Fills missing dates with 0
- Returns JSON with chart-ready data

**2. get_merchant_performance_metrics**
```sql
Parameters: merchant_uuid, period_days
Returns: { week_over_week_growth, peak_hour, payment_breakdown, ... }
```
- Calculates growth vs previous period
- Finds hour with max revenue
- Groups by payment method

**3. get_merchant_customer_insights**
```sql
Parameters: merchant_uuid, period_days
Returns: { total_customers, repeat_rate, top_customers: [], ... }
```
- Counts unique customers
- Identifies repeat customers (>1 order)
- Calculates average basket/order
- Lists top 5 by spend

---

### Component 5: Navigation Update

#### [MODIFY] [merchant_home_screen.dart:15-70](file:///c:/DRAGON/MomoPe/merchant_app/lib/screens/home/merchant_home_screen.dart#L15-L70)
Update navigation from 5 to 6 tabs:
```dart
final List<Widget> _screens = [
  MerchantDashboardScreen(),
  QRCodeScreen(),
  MerchantTransactionHistoryScreen(),
  MerchantAnalyticsScreen(),  // NEW
  MerchantSettlementScreen(),
  MerchantProfileScreen(),
];

// Add Analytics tab
BottomNavigationBarItem(
  icon: Icon(Icons.analytics_rounded),
  label: 'Analytics',
),
```

---

## Verification Plan

### Automated Tests
None currently exist for this feature. This is a new visual/UI component.

### Manual Verification

**Step 1: Build & Run**
```cmd
cd c:\DRAGON\MomoPe\merchant_app
flutter run
```
Expected: App builds successfully without errors

**Step 2: Navigate to Analytics**
1. Log in as merchant
2. Tap "Analytics" tab in bottom navigation (4th tab)
3. Expected: Analytics screen loads with 3 tabs

**Step 3: Verify Revenue Chart**
1. On "Revenue" tab, verify:
   - Line chart displays with last 7 days
   - Total revenue shows correct amount
   - Can switch between 7-day/30-day periods
   - Chart animates on period change
2. Expected: Smooth chart interactions, no crashes

**Step 4: Verify Performance Metrics**
1. Switch to "Performance" tab
2. Verify:
   - Growth percentage shows (may be 0% if no data)
   - Peak hour displays (e.g., "2 PM")
   - Payment method chart shows distribution
3. Expected: All metrics render correctly

**Step 5: Verify Customer Insights**
1. Switch to "Customers" tab
2. Verify:
   - Total customer count
   - Repeat customer rate
   - Average values display
   - Top customers list (if any transactions)
3. Expected: Insights load without errors

**Step 6: Empty State**
1. Test with merchant who has no transactions
2. Expected: Friendly empty state messages, no errors

**Step 7: SQL Functions**
1. Open Supabase SQL Editor
2. Execute `merchant_analytics_functions.sql`
3. Expected: "Success. No rows returned"
4. Restart app and verify charts populate with real data

---

## Implementation Notes

### Graceful Degradation
- If SQL functions not deployed yet: Uses fallback manual calculation
- If no data: Shows empty state with suggestions
- If chart library errors: Shows text-based summary

### Performance Considerations
- Charts render max 30 data points (days)
- Debounced period switching (300ms)
- Cached provider results (auto-invalidate on refresh)

### Design System
- Uses existing `PremiumCard`, `AppColors`, `AppTypography`
- Chart colors: Primary teal gradient, gold accent
- Consistent spacing and padding

---

## Post-Implementation

**Once complete**:
1. Deploy SQL functions to Supabase
2. Test with real merchant data
3. Monitor performance on device
4. Collect merchant feedback for v2 enhancements

**Future enhancements**:
- Export charts as images
- PDF report generation
- Email weekly summaries
- Custom date range picker
- Comparison view (this week vs last week)
