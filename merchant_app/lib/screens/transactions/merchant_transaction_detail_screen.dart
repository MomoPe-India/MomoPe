import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../models/transaction.dart';

/// Transaction Detail Screen for Merchants
/// Shows complete breakdown of a transaction
class MerchantTransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const MerchantTransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          children: [
            // Premium Header
            _buildHeader(context),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Status Card with Glassmorphism
                    _buildStatusCard(),

                    Padding(
                      padding: AppSpacing.paddingAll16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Transaction Info
                          _buildInfoSection(),

                          const SizedBox(height: AppSpacing.space24),

                          // Payment Breakdown
                          _buildPaymentBreakdown(),

                          const SizedBox(height: AppSpacing.space24),

                          // Your Earnings
                          if (transaction.grossRevenue != null) _buildEarningsBreakdown(),

                          const SizedBox(height: AppSpacing.space24),

                          // Transaction ID
                          _buildTransactionId(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 20),
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
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'TRANSACTION DETAILS',
            style: AppTypography.labelLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final color = _getStatusColor();
    final icon = _getStatusIcon();
    final message = _getStatusMessage();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.status.toUpperCase(),
                  style: AppTypography.titleLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  message,
                  style: AppTypography.labelSmall.copyWith(
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildInfoSection() {
    return PremiumCard(
      style: PremiumCardStyle.elevated,
      child: Padding(
        padding: AppSpacing.paddingAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TRANSACTION INFO',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.neutral500,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.space16),
            _buildInfoRow(
              'Customer ID',
              transaction.userId.substring(0, 8) + '...',
              Icons.person_outline,
            ),
            _buildDivider(),
            _buildInfoRow(
              'Date & Time',
              _formatDateTime(transaction.createdAt),
              Icons.calendar_today_rounded,
            ),
            _buildDivider(),
            _buildInfoRow(
              'Payment Method',
              transaction.paymentMethod.toUpperCase(),
              Icons.payment_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentBreakdown() {
    return PremiumCard(
      style: PremiumCardStyle.elevated,
      child: Padding(
        padding: AppSpacing.paddingAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PAYMENT BREAKDOWN',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.neutral500,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.space16),
            _buildAmountRow(
              'Bill Amount',
              transaction.grossAmount,
              isTotal: false,
            ),
            _buildDivider(),
            if (transaction.coinAmount > 0) ...[
              _buildAmountRow(
                'Coins Redeemed',
                -transaction.coinAmount,
                isTotal: false,
                color: AppColors.rewardsGold,
              ),
              _buildDivider(),
            ],
            _buildAmountRow(
              'Amount Paid',
              transaction.fiatAmount,
              isTotal: true,
              color: AppColors.primaryTeal,
            ),
            if (transaction.rewardsEarned > 0) ...[
              const SizedBox(height: AppSpacing.space12),
              Container(
                padding: AppSpacing.paddingAll12,
                decoration: BoxDecoration(
                  color: AppColors.rewardsGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      color: AppColors.rewardsGold,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.space8),
                    Expanded(
                      child: Text(
                        'Customer earned ${transaction.rewardsEarned} coins',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.rewardsGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsBreakdown() {
    return PremiumCard(
      style: PremiumCardStyle.gradient,
      child: Container(
        padding: AppSpacing.paddingAll16,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'YOUR EARNINGS',
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.space16),
            _buildAmountRow(
              'Commission (${transaction.commissionRate?.toStringAsFixed(0)}%)',
              transaction.grossRevenue ?? 0,
              isWhite: true,
              isTotal: false,
            ),
            _buildDivider(isWhite: true),
            _buildAmountRow(
              'Rewards Given',
              -(transaction.rewardsEarned.toDouble()),
              isWhite: true,
              isTotal: false,
            ),
            _buildDivider(isWhite: true),
            _buildAmountRow(
              'Net Earnings',
              transaction.netRevenue ?? 0,
              isWhite: true,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionId(BuildContext context) {
    return PremiumCard(
      style: PremiumCardStyle.outlined,
      child: Padding(
        padding: AppSpacing.paddingAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TRANSACTION ID',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.neutral500,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.space8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    transaction.id,
                    style: AppTypography.bodyMedium.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 20),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: transaction.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transaction ID copied'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.neutral600),
        const SizedBox(width: AppSpacing.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow(
    String label,
    double amount,
    {
    bool isTotal = false,
    bool isWhite = false,
    Color? color,
    }
  ) {
    final textColor = isWhite ? Colors.white : (color ?? AppColors.neutral900);
    final sign = amount < 0 ? '- ' : '';
    final absAmount = amount.abs();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTypography.titleMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                )
              : AppTypography.bodyMedium.copyWith(
                  color: textColor.withOpacity(0.8),
                ),
        ),
        Text(
          '$sign₹${absAmount.toStringAsFixed(0)}',
          style: isTotal
              ? AppTypography.titleLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                )
              : AppTypography.bodyLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
        ),
      ],
    );
  }

  Widget _buildDivider({bool isWhite = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space12),
      child: Divider(
        color: isWhite
            ? Colors.white.withOpacity(0.3)
            : AppColors.neutral300,
        height: 1,
      ),
    );
  }

  Color _getStatusColor() {
    switch (transaction.status) {
      case 'success':
        return AppColors.successGreen;
      case 'pending':
        return AppColors.rewardsGold;
      case 'failed':
        return AppColors.errorRed;
      default:
        return AppColors.neutral500;
    }
  }

  IconData _getStatusIcon() {
    switch (transaction.status) {
      case 'success':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.schedule_rounded;
      case 'failed':
        return Icons.cancel_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  String _getStatusMessage() {
    switch (transaction.status) {
      case 'success':
        return 'Payment completed successfully';
      case 'pending':
        return 'Payment is being processed';
      case 'failed':
        return 'Payment failed';
      default:
        return 'Unknown status';
    }
  }

  String _formatDateTime(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final month = months[date.month - 1];
    final day = date.day;
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$month $day, $year at $hour:$minute';
  }
}
