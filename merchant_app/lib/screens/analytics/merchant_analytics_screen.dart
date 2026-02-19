import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../models/revenue_trend.dart';
import '../../models/performance_metrics.dart';
import '../../models/customer_insights.dart';
import '../../providers/analytics_provider.dart';
import '../../widgets/charts/revenue_line_chart.dart';
import '../../widgets/charts/payment_pie_chart.dart';
import '../../widgets/charts/hourly_bar_chart.dart';

/// Merchant Analytics Screen with Revenue, Performance, and Customer tabs
class MerchantAnalyticsScreen extends ConsumerStatefulWidget {
  const MerchantAnalyticsScreen({super.key});

  @override
  ConsumerState<MerchantAnalyticsScreen> createState() => _MerchantAnalyticsScreenState();
}

class _MerchantAnalyticsScreenState extends ConsumerState<MerchantAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Revenue', icon: Icon(Icons.trending_up, size: 20)),
            Tab(text: 'Performance', icon: Icon(Icons.speed, size: 20)),
            Tab(text: 'Customers', icon: Icon(Icons.people, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RevenueTab(),
          _PerformanceTab(),
          _CustomersTab(),
        ],
      ),
    );
  }
}

/// Revenue Overview Tab
class _RevenueTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenueTrendAsync = ref.watch(revenueTrendProvider);
    final selectedPeriod = ref.watch(selectedPeriodProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(revenueTrendProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.paddingAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            _buildPeriodSelector(ref, selectedPeriod),
            const SizedBox(height: AppSpacing.space16),

            // Loading/Error/Data
            revenueTrendAsync.when(
              data: (trend) => _buildRevenueContent(trend),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, __) => _buildErrorState(error.toString()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(WidgetRef ref, AnalyticsPeriod selected) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _periodChip(
            label: '7 Days',
            isSelected: selected == AnalyticsPeriod.sevenDays,
            onTap: () => ref.read(selectedPeriodProvider.notifier).state = AnalyticsPeriod.sevenDays,
          ),
          const SizedBox(width: AppSpacing.space8),
          _periodChip(
            label: '30 Days',
            isSelected: selected == AnalyticsPeriod.thirtyDays,
            onTap: () => ref.read(selectedPeriodProvider.notifier).state = AnalyticsPeriod.thirtyDays,
          ),
          const SizedBox(width: AppSpacing.space8),
          _periodChip(
            label: 'Custom',
            isSelected: selected == AnalyticsPeriod.custom,
            onTap: () => ref.read(selectedPeriodProvider.notifier).state = AnalyticsPeriod.custom,
          ),
        ],
      ),
    );
  }

  Widget _periodChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.neutral200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.neutral400,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.neutral700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueContent(RevenueTrend trend) {
    if (trend.totalRevenue == 0) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total Revenue Card
        Container(
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: AppSpacing.paddingAll20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      trend.isPositiveTrend ? Icons.trending_up : Icons.trending_down,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Total Revenue',
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '₹${trend.totalRevenue.toStringAsFixed(2)}',
                  style: AppTypography.displaySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Avg ₹${trend.averageDaily.toStringAsFixed(0)}/day',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.space24),

        // Chart Title
        Text(
          'Revenue Trend',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.space12),

        // Line Chart
        PremiumCard(
          style: PremiumCardStyle.elevated,
          child: Padding(
            padding: AppSpacing.paddingAll16,
            child: SizedBox(
              height: 250,
              child: RevenueLineChart(trend: trend),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: AppColors.neutral400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Revenue Data',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.neutral600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start accepting payments to see your revenue analytics',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading analytics', style: AppTypography.titleMedium),
            const SizedBox(height: 8),
            Text(error, style: AppTypography.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// Performance Metrics Tab
class _PerformanceTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(performanceMetricsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(performanceMetricsProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.paddingAll16,
        child: metricsAsync.when(
          data: (metrics) => _buildPerformanceContent(metrics),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, __) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  Widget _buildPerformanceContent(PerformanceMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Growth Card
        Container(
          decoration: BoxDecoration(
            gradient: metrics.isGrowthPositive ? AppColors.primaryGradient : null,
            color: metrics.isGrowthPositive ? null : AppColors.neutral200,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: AppSpacing.paddingAll20,
            child: Row(
              children: [
                Icon(
                  metrics.isGrowthPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: metrics.isGrowthPositive ? Colors.white : AppColors.neutral600,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Week-over-Week Growth',
                        style: AppTypography.bodyMedium.copyWith(
                          color: metrics.isGrowthPositive ? Colors.white : AppColors.neutral700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        metrics.growthDisplay,
                        style: AppTypography.headlineMedium.copyWith(
                          color: metrics.isGrowthPositive ? Colors.white : AppColors.neutral700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.space16),

        // Peak Hour Card
        PremiumCard(
          style: PremiumCardStyle.elevated,
          child: Padding(
            padding: AppSpacing.paddingAll20,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTealExtraLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.access_time,
                    color: AppColors.primaryTeal,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Peak Hour',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        metrics.peakHourDisplay,
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₹${metrics.peakHourRevenue.toStringAsFixed(0)} revenue',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.space24),

        // Payment Method Breakdown
        if (metrics.paymentMethodBreakdown.isNotEmpty) ...[
          Text(
            'Payment Methods',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.space12),
          PremiumCard(
            style: PremiumCardStyle.elevated,
            child: Padding(
              padding: AppSpacing.paddingAll16,
              child: SizedBox(
                height: 200,
                child: PaymentPieChart(metrics: metrics),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Customer Insights Tab
class _CustomersTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(customerInsightsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(customerInsightsProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.paddingAll16,
        child: insightsAsync.when(
          data: (insights) => _buildCustomersContent(insights),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, __) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  Widget _buildCustomersContent(CustomerInsights insights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats Grid
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Customers',
                insights.totalCustomers.toString(),
                Icons.people,
                AppColors.primaryTeal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Repeat Customers',
                insights.repeatCustomers.toString(),
                Icons.repeat,
               AppColors.primaryTeal,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.space12),

        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Repeat Rate',
                insights.repeatRateDisplay,
                Icons.trending_up,
                AppColors.successGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Avg Order',
                '₹${insights.averageOrderValue.toStringAsFixed(0)}',
                Icons.shopping_cart,
                AppColors.primaryTeal,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.space24),

        // Top Customers
        if (insights.topCustomers.isNotEmpty) ...[
          Text(
            'Top Customers',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.space12),
          PremiumCard(
            style: PremiumCardStyle.elevated,
            child: Column(
              children: insights.topCustomers.asMap().entries.map((entry) {
                final index = entry.key;
                final customer = entry.value;
                return Column(
                  children: [
                    if (index > 0) const Divider(height: 1),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryTealExtraLight,
                        child: Text(
                          '${index + 1}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        customer.maskedId,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text('${customer.orderCount} orders'),
                      trailing: Text(
                        '₹${customer.totalSpent.toStringAsFixed(0)}',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return PremiumCard(
      style: PremiumCardStyle.elevated,
      child: Padding(
        padding: AppSpacing.paddingAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
