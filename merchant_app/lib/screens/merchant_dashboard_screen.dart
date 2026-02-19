import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/widgets.dart';
import '../providers/merchant_provider.dart';
import '../providers/merchant_stats_provider.dart';
import '../providers/merchant_transactions_provider.dart';
import '../providers/merchant_settlements_provider.dart';
import '../models/transaction.dart';

/// Enhanced Merchant Dashboard Screen
/// Shows today's earnings, stats, settlement preview, recent transactions
class MerchantDashboardScreen extends ConsumerWidget {
  const MerchantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final merchantAsync = ref.watch(merchantProvider);
    final todayStatsAsync = ref.watch(todayStatsProvider);
    final pendingSettlementAsync = ref.watch(pendingSettlementProvider);
    final todayTransactionsAsync = ref.watch(todayTransactionsProvider);

    return Scaffold(
      body: merchantAsync.when(
        data: (merchant) {
          if (merchant == null) {
            return const Center(
              child: Text('No merchant profile found'),
            );
          }

         return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(todayStatsProvider);
              ref.invalidate(pendingSettlementProvider);
              ref.invalidate(todayTransactionsProvider);
            },
            child: CustomScrollView(
              slivers: [
                // Premium Header with Gradient
                _buildHeader(context, merchant.businessName),

                // Content
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                    Padding(
                      padding: AppSpacing.paddingAll16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Today's Earnings Summary
                          _buildEarningsSummary(context, todayStatsAsync),
                          
                          const SizedBox(height: AppSpacing.space24),

                          // Stats Cards Row
                          _buildStatsCards(context, todayStatsAsync),

                          const SizedBox(height: AppSpacing.space24),

                          // Pending Settlement Preview
                          _buildSettlementPreview(context, pendingSettlementAsync),

                          const SizedBox(height: AppSpacing.space24),

                          // Recent Transactions
                          _buildRecentTransactions(context, todayTransactionsAsync),
                        ],
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String businessName) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: AppSpacing.paddingAll16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.dashboard_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dashboard',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            Text(
                              businessName,
                              style: AppTypography.titleLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsSummary(
    BuildContext context,
    AsyncValue todayStatsAsync,
  ) {
    return todayStatsAsync.when(
      data: (stats) {
        return PremiumCard(
          style: PremiumCardStyle.elevated,
          child: Container(
            padding: AppSpacing.paddingAll20,
            decoration: const BoxDecoration(
              gradient: AppColors.goldGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Earnings',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: AppSpacing.space8),
                Text(
                  '₹${stats.netRevenue.toStringAsFixed(0)}',
                  style: AppTypography.displaySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.space12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetric(
                        '${stats.transactionCount}',
                        'Orders',
                        Colors.white,
                      ),
                    ),
                    Expanded(
                      child: _buildMetric(
                        '${stats.customersServed}',
                        'Customers',
                        Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const PremiumCard(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const PremiumCard(
        child: Center(child: Text('Failed to load stats')),
      ),
    );
  }

  Widget _buildStatsCards(
    BuildContext context,
    AsyncValue todayStatsAsync,
  ) {
    return todayStatsAsync.when(
      data: (stats) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Gross',
                '₹${stats.totalRevenue.toStringAsFixed(0)}',
                Icons.payments_rounded,
                AppColors.primaryTeal,
              ),
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: _buildStatCard(
                'Net',
                '₹${stats.netRevenue.toStringAsFixed(0)}',
                Icons.account_balance_wallet_rounded,
                AppColors.successGreen,
              ),
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: _buildStatCard(
                'Avg Order',
                '₹${stats.transactionCount > 0 ? (stats.totalRevenue / stats.transactionCount).toStringAsFixed(0) : '0'}',
                Icons.receipt_long_rounded,
                AppColors.rewardsGold,
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return PremiumCard(
      style: PremiumCardStyle.outlined,
      child: Padding(
        padding: AppSpacing.paddingAll12,
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: AppSpacing.space8),
            Text(
              value,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
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

  Widget _buildSettlementPreview(
    BuildContext context,
    AsyncValue<double> pendingSettlementAsync,
  ) {
    return pendingSettlementAsync.when(
      data: (pendingAmount) {
        if (pendingAmount == 0) return const SizedBox.shrink();

        return PremiumCard(
          style: PremiumCardStyle.elevated,
          child: Padding(
            padding: AppSpacing.paddingAll16,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.monetization_on_rounded,
                    color: AppColors.primaryTeal,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pending Settlement',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space4),
                      Text(
                        '₹${pendingAmount.toStringAsFixed(0)}',
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space4),
                      Text(
                        'Next payout in 3 days',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.neutral400,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    AsyncValue<List<Transaction>> todayTransactionsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Transactions',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to full transaction history
                // TODO: Implement navigation
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space12),
        todayTransactionsAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return _buildEmptyState();
            }
            
            return Column(
              children: transactions
                  .take(5)
                  .map((txn) => _buildTransactionCard(context, txn))
                  .toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, __) => _buildEmptyState(error: error.toString()),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(BuildContext context, Transaction txn) {
    return PremiumCard(
      style: PremiumCardStyle.outlined,
      child: Padding(
        padding: AppSpacing.paddingAll12,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: txn.isSuccess
                    ? AppColors.successGreen.withOpacity(0.1)
                    : AppColors.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                txn.isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: txn.isSuccess ? AppColors.successGreen : AppColors.errorRed,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${txn.grossAmount.toStringAsFixed(0)}',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    txn.getFormattedDate(),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (txn.netRevenue != null)
                  Text(
                    '₹${txn.netRevenue!.toStringAsFixed(0)}',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                const SizedBox(height: AppSpacing.space4),Text(
                  '${txn.rewardsEarned} coins',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({String? error}) {
    return PremiumCard(
      style: PremiumCardStyle.outlined,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            children: [
              Icon(
                error != null ? Icons.error_outline : Icons.receipt_long_outlined,
                size: 48,
                color: AppColors.neutral400,
              ),
              const SizedBox(height: AppSpacing.space16),
              Text(
                error ?? 'No transactions yet',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.neutral600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTypography.headlineSmall.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
