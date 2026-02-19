import 'package:flutter/material.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settlement'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(settlementsProvider);
          ref.invalidate(pendingSettlementProvider);
        },
        child: SingleChildScrollView(
          padding: AppSpacing.paddingAll16,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Next Settlement Card
              _buildNextSettlement(context, nextSettlementAsync, pendingAmountAsync),

              const SizedBox(height: AppSpacing.space24),

              // Settlement History
              Text(
                'Settlement History',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.space16),
              
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

        return PremiumCard(
          style: PremiumCardStyle.gradient,
          child: Container(
            padding: AppSpacing.paddingAll20,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space12),
                    Expanded(
                      child: Text(
                        'Next Settlement',
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space20),
                Text(
                  '₹${pendingAmount.toStringAsFixed(0)}',
                  style: AppTypography.displaySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.space12),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.space8),
                    Text(
                      'Scheduled in 3 days (T+3 settlement)',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space16),
                Container(
                  padding: AppSpacing.paddingAll12,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 16,                      ),
                      const SizedBox(width: AppSpacing.space8),
                      Expanded(
                        child: Text(
                          'Funds will be transferred to your registered bank account',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
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
    return PremiumCard(
      style: PremiumCardStyle.outlined,
      child: Padding(
        padding: AppSpacing.paddingAll32,
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 48,
                color: AppColors.successGreen,
              ),
              const SizedBox(height: AppSpacing.space16),
              Text(
                'All settled!',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              Text(
                'No pending settlements at the moment',
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

  Widget _buildSettlementCard(BuildContext context, MerchantSettlement settlement) {
    return PremiumCard(
      style: PremiumCardStyle.elevated,
      child: Padding(
        padding: AppSpacing.paddingAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(settlement.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(settlement.status),
                    color: _getStatusColor(settlement.status),
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${settlement.finalSettlementAmount.toStringAsFixed(0)}',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_formatDate(settlement.periodStart)} - ${_formatDate(settlement.periodEnd)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(settlement.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    settlement.status.toUpperCase(),
                    style: AppTypography.bodySmall.copyWith(
                      color: _getStatusColor(settlement.status),
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space16),
            Divider(color: AppColors.neutral300, height: 1),
            const SizedBox(height: AppSpacing.space12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetric(
                  '${settlement.transactionCount}',
                  'Transactions',
                ),
                _buildMetric(
                  '₹${settlement.totalGrossRevenue.toStringAsFixed(0)}',
                  'Gross',
                ),
                _buildMetric(
                  '₹${settlement.totalNetRevenue.toStringAsFixed(0)}',
                  'Net',
                ),
              ],
            ),
            if (settlement.paidDate != null) ...[
              const SizedBox(height: AppSpacing.space12),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.successGreen,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.space8),
                  Text(
                    'Paid on ${_formatDate(settlement.paidDate!)}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.successGreen,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.neutral600,
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
