import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/widgets.dart';
import '../features/auth/screens/login_screen.dart';
import '../providers/merchant_provider.dart';
import '../providers/merchant_stats_provider.dart';
import '../providers/merchant_transactions_provider.dart';
import '../providers/merchant_settlements_provider.dart';
import '../models/transaction.dart';
import '../services/notification_service.dart';
import 'profile/merchant_profile_screen.dart';
import 'transactions/merchant_transaction_history_screen.dart';

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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String businessName) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primaryTeal,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      actions: [
        IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.white24, Colors.white10],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
          ),
          onPressed: () {
            // Notifications logic
          },
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MerchantProfileScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.rewardsGold, Color(0xFFFFA500)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  businessName.isNotEmpty ? businessName[0].toUpperCase() : 'M',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'BUSINESS DASHBOARD',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            businessName,
                            style: AppTypography.headlineSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFA500).withOpacity(0.4),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                Positioned(
                  right: -30,
                  top: -30,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.white.withOpacity(0.1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TODAY\'S EARNINGS',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '+12% vs yest.',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '₹${stats.netRevenue.toStringAsFixed(2)}',
                        style: AppTypography.displayMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          _buildMetric(
                            '${stats.transactionCount}',
                            'TOTAL ORDERS',
                            Colors.white,
                          ),
                          const SizedBox(width: 40),
                          _buildMetric(
                            '${stats.customersServed}',
                            'UNIQUE CUSTOMERS',
                            Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Failed to load stats')),
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
    return Container(
      padding: const EdgeInsets.all(16),
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.neutral500,
              fontWeight: FontWeight.w800,
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
        ],
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: AppColors.primaryTeal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PENDING SETTLEMENT',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.neutral500,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${pendingAmount.toStringAsFixed(2)}',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.neutral900,
                      ),
                    ),
                    Text(
                      'Next payout in 3 days',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.neutral400,
                size: 14,
              ),
            ],
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
              'RECENT ORDERS',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.neutral500,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const MerchantTransactionHistoryScreen(),
                  ),
                );
              },
              child: Text(
                'View All',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w900,
                ),
              ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: txn.isSuccess
                  ? AppColors.successGreen.withOpacity(0.1)
                  : AppColors.errorRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              txn.isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: txn.isSuccess ? AppColors.successGreen : AppColors.errorRed,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${txn.grossAmount.toStringAsFixed(0)}',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.neutral900,
                  ),
                ),
                Text(
                  txn.getFormattedDate(),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.w600,
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
                  '₹${txn.netRevenue!.toStringAsFixed(2)}',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryTeal,
                  ),
                ),
              Text(
                '${txn.rewardsEarned} coins',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.rewardsGold,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
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
          style: AppTypography.titleLarge.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: AppTypography.labelSmall.copyWith(
            color: color.withOpacity(0.7),
            fontWeight: FontWeight.w800,
            fontSize: 9,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
