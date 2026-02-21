import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.neutral100,
        body: Column(
          children: [
            // Custom Gradient Header
            Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryTeal,
                    AppColors.primaryTealDark,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Analytics',
                          style: AppTypography.headlineSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.6),
                    labelStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w800),
                    unselectedLabelStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'Revenue'),
                      Tab(text: 'Performance'),
                      Tab(text: 'Customers'),
                    ],
                  ),
                ],
              ),
            ),
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _RevenueTab(),
                  _PerformanceTab(),
                  _CustomersTab(),
                ],
              ),
            ),
          ],
        ),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? const LinearGradient(
            colors: [AppColors.primaryTeal, AppColors.primaryTealDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primaryTeal.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.neutral200,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: isSelected ? Colors.white : AppColors.neutral700,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
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
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFA500).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white.withOpacity(0.1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL REVENUE',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  trend.isPositiveTrend ? Icons.trending_up : Icons.trending_down,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Healthy',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '₹${trend.totalRevenue.toStringAsFixed(2)}',
                        style: AppTypography.displayMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Avg ₹${trend.averageDaily.toStringAsFixed(0)} per day',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.space32),

        // Chart Header
        Text(
          'REVENUE TREND',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.neutral500,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Financial Overview',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 16),

        // Line Chart
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.neutral200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SizedBox(
            height: 250,
            child: RevenueLineChart(trend: trend),
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
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: metrics.isGrowthPositive 
              ? const LinearGradient(
                  colors: [AppColors.successGreen, Color(0xFF1B8A61)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [AppColors.neutral300, AppColors.neutral400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (metrics.isGrowthPositive ? AppColors.successGreen : AppColors.neutral400).withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    metrics.isGrowthPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WEEKLY GROWTH',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        metrics.growthDisplay,
                        style: AppTypography.headlineSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
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
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.neutral200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.access_time_filled_rounded,
                  color: AppColors.primaryTeal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Peak Hour',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.neutral500,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      metrics.peakHourDisplay,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.neutral900,
                      ),
                    ),
                    Text(
                      '₹${metrics.peakHourRevenue.toStringAsFixed(0)} revenue',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.space24),

        // Payment Method Breakdown
        if (metrics.paymentMethodBreakdown.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.space24),
          Text(
            'PAYMENT METHODS',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.neutral500,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.neutral200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SizedBox(
              height: 200,
              child: PaymentPieChart(metrics: metrics),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.neutral500,
              fontWeight: FontWeight.w800,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
