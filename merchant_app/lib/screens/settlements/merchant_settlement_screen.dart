import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../providers/merchant_settlements_provider.dart';
import '../../providers/merchant_stats_provider.dart';
import '../../models/merchant_settlement.dart';

/// Merchant Settlement Screen
/// Shows upcoming settlements and history
class MerchantSettlementScreen extends ConsumerWidget {
  const MerchantSettlementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextSettlementAsync = ref.watch(nextSettlementProvider);
    final pastSettlementsAsync = ref.watch(pastSettlementsProvider);
    final pendingAmountAsync = ref.watch(pendingSettlementProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.neutral100,
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(settlementsProvider);
            ref.invalidate(pendingSettlementProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Custom Header
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: AppColors.primaryTeal,
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
                  ),
                  title: Text(
                    'Settlement',
                    style: AppTypography.headlineSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                ),
              ),

              SliverPadding(
                padding: AppSpacing.paddingAll20,
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Next Settlement Card
                    _buildNextSettlement(context, nextSettlementAsync, pendingAmountAsync),

                    const SizedBox(height: AppSpacing.space32),

                    // Settlement History Header
                    Text(
                      'SETTLEMENT HISTORY',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.neutral500,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    pastSettlementsAsync.when(
                      data: (settlements) {
                        if (settlements.isEmpty) {
                          return _buildEmptyHistory();
                        }

                        return Column(
                          children: settlements
                              .map((settlement) => _buildSettlementCard(context, settlement))
                              .toList(),
                        );
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, __) => _buildErrorState(error.toString()),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextSettlement(
    BuildContext context,
    AsyncValue nextSettlementAsync,
    AsyncValue<double> pendingAmountAsync,
  ) {
    return pendingAmountAsync.when(
      data: (pendingAmount) {
        if (pendingAmount == 0) {
          return _buildNoSettlementDue();
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00796B), Color(0xFF004D40)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF004D40).withOpacity(0.3),
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
                  right: -30,
                  bottom: -30,
                  child: Icon(
                    Icons.account_balance_rounded,
                    size: 150,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.account_balance_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'NEXT SETTLEMENT',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '₹${pendingAmount.toStringAsFixed(2)}',
                        style: AppTypography.displayMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            color: Colors.white.withOpacity(0.9),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Scheduled in 3 days',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Funds will be transferred to your registered bank account',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildNoSettlementDue() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 40,
                color: AppColors.successGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'All settled!',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No pending settlements at the moment',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.neutral600,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettlementCard(BuildContext context, MerchantSettlement settlement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getStatusColor(settlement.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStatusIcon(settlement.status),
                  color: _getStatusColor(settlement.status),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${settlement.finalSettlementAmount.toStringAsFixed(0)}',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatDate(settlement.periodStart)} - ${_formatDate(settlement.periodEnd)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(settlement.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  settlement.status.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: _getStatusColor(settlement.status),
                    fontWeight: FontWeight.w900,
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: AppColors.neutral200, height: 1),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric(
                '${settlement.transactionCount}',
                'TRANS.',
              ),
              _buildMetric(
                '₹${settlement.totalGrossRevenue.toStringAsFixed(0)}',
                'GROSS',
              ),
              _buildMetric(
                '₹${settlement.totalNetRevenue.toStringAsFixed(0)}',
                'NET',
              ),
            ],
          ),
          if (settlement.paidDate != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    color: AppColors.successGreen,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Paid on ${_formatDate(settlement.paidDate!)}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.successGreen,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetric(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    );
  }

  Widget _buildEmptyHistory() {
    return PremiumCard(
      style: PremiumCardStyle.outlined,
      child: Padding(
        padding: AppSpacing.paddingAll32,
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.history_rounded,
                size: 48,
                color: AppColors.neutral400,
              ),
              const SizedBox(height: AppSpacing.space16),
              Text(
                'No settlement history yet',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return PremiumCard(
      style: PremiumCardStyle.outlined,
      child: Padding(
        padding: AppSpacing.paddingAll32,
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: AppSpacing.space16),
              Text(
                'Failed to load settlements',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid':
      case 'processed':
        return AppColors.successGreen;
      case 'scheduled':
      case 'pending':
        return AppColors.rewardsGold;
      default:
        return AppColors.neutral500;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'paid':
      case 'processed':
        return Icons.check_circle_rounded;
      case 'scheduled':
        return Icons.schedule_rounded;
      case 'pending':
        return Icons.pending_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
