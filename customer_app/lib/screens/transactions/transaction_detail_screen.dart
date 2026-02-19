import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/widgets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/transaction.dart';

/// Premium Transaction Detail Screen - Digital Receipt
/// Features: Full breakdown, share receipt, merchant info, support
class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Success status indicator
            _buildStatusBanner(),
            const SizedBox(height: 24),
            
            // Merchant info card
            _buildMerchantCard(),
            const SizedBox(height: 16),
            
            // Payment breakdown
            _buildPaymentBreakdown(),
            const SizedBox(height: 16),
            
            // Rewards earned
            if (transaction.coinsEarned > 0) ...[
              _buildRewardsCard(),
              const SizedBox(height: 16),
            ],
            
            // Transaction metadata
            _buildTransactionDetails(),
            const SizedBox(height: 24),
            
            // Action buttons
            _buildActionButtons(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.neutral900),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Receipt',
        style: AppTypography.titleLarge.copyWith(
          color: AppColors.neutral900,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppColors.neutral900),
          onPressed: () => _showOptionsMenu(context),
        ),
      ],
    );
  }

  Widget _buildStatusBanner() {
    final Color statusColor = _getStatusColor();
    final IconData statusIcon = _getStatusIcon();
    final String statusText = _getStatusText();

    return Container(
      padding: AppSpacing.paddingAll20,
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: AppTypography.titleMedium.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(transaction.createdAt),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantCard() {
    return PremiumCard(
      padding: AppSpacing.paddingAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Merchant logo
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.store,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.merchantName,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Grocery & Retail', // TODO: Add category to transaction model
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBreakdown() {
    return PremiumCard(
      padding: AppSpacing.paddingAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Breakdown',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Bill amount
          _buildBreakdownRow(
            'Bill Amount',
            _formatCurrency(transaction.amount),
            isTotal: false,
          ),
          const SizedBox(height: 12),
          
          // Coins applied
          if (transaction.coinsRedeemed > 0) ...[
            _buildBreakdownRow(
              'Coins Applied',
              '-${transaction.coinsRedeemed} coins',
              subtitle: '(₹${transaction.coinsRedeemed})',
              isDiscount: true,
            ),
            const SizedBox(height: 12),
          ],
          
          // Divider
          const Divider(height: 24),
          
          // Final amount paid
          _buildBreakdownRow(
            'You Paid',
            _formatCurrency(transaction.amount - transaction.coinsRedeemed),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    String value, {
    String? subtitle,
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: isTotal
                  ? AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                  : AppTypography.bodyLarge,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ],
        ),
        Text(
          value,
          style: isTotal
              ? AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTeal,
                )
              : AppTypography.titleMedium.copyWith(
                  color: isDiscount ? AppColors.successGreen : AppColors.neutral900,
                  fontWeight: isDiscount ? FontWeight.w600 : FontWeight.normal,
                ),
        ),
      ],
    );
  }

  Widget _buildRewardsCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.rewardsGold.withOpacity(0.1),
            AppColors.rewardsGoldLight.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.rewardsGold.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: AppSpacing.paddingAll16,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.rewardsGold,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rewards Earned',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '+${transaction.coinsEarned} coins',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.rewardsGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${transaction.coinsEarned}',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.rewardsGold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails() {
    return PremiumCard(
      padding: AppSpacing.paddingAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Details',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildDetailRow(
            'Transaction ID',
            transaction.id.length > 12
                ? '${transaction.id.substring(0, 12)}...'
                : transaction.id,
          ),
          const Divider(height: 24),
          
          _buildDetailRow('Status', _getStatusText()),
          const Divider(height: 24),
          
          _buildDetailRow('Payment Method', 'Google Pay'), // TODO: Add to transaction model
          const Divider(height: 24),
          
          _buildDetailRow('Date & Time', _formatDateTime(transaction.createdAt)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Share receipt button
        PremiumButton(
          text: 'Share Receipt',
          icon: Icons.share,
          onPressed: () => _shareReceipt(),
          style: PremiumButtonStyle.primary,
        ),
        const SizedBox(height: 12),
        
        // Report issue button
        PremiumButton(
          text: 'Report Issue',
          icon: Icons.report_problem_outlined,
          onPressed: () => _reportIssue(context),
          style: PremiumButtonStyle.secondary,
        ),
      ],
    );
  }

  // Helper methods
  Color _getStatusColor() {
    if (transaction.status == TransactionStatus.success) {
      return AppColors.successGreen;
    } else if (transaction.status == TransactionStatus.pending) {
      return AppColors.warningAmber;
    } else {
      return AppColors.errorRed;
    }
  }

  IconData _getStatusIcon() {
    if (transaction.status == TransactionStatus.success) {
      return Icons.check_circle;
    } else if (transaction.status == TransactionStatus.pending) {
      return Icons.access_time;
    } else {
      return Icons.error;
    }
  }

  String _getStatusText() {
    if (transaction.status == TransactionStatus.success) {
      return 'Payment Successful';
    } else if (transaction.status == TransactionStatus.pending) {
      return 'Payment Pending';
    } else {
      return 'Payment Failed';
    }
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }

  String _formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('MMM dd, yyyy  •  hh:mm a');
    return formatter.format(dateTime);
  }

  void _shareReceipt() {
    final String receiptText = '''
🧾 MomoPe Receipt

${transaction.merchantName}
${_formatDateTime(transaction.createdAt)}

━━━━━━━━━━━━━━━━━━━━
Bill Amount: ${_formatCurrency(transaction.amount)}
${transaction.coinsRedeemed > 0 ? 'Coins Applied: -${transaction.coinsRedeemed} coins (₹${transaction.coinsRedeemed})' : ''}
━━━━━━━━━━━━━━━━━━━━
You Paid: ${_formatCurrency(transaction.amount - transaction.coinsRedeemed)}

${transaction.coinsEarned > 0 ? '⭐ Rewards Earned: +${transaction.coinsEarned} coins' : ''}

Transaction ID: ${transaction.id}
Status: ${_getStatusText()}

Powered by MomoPe 💚
''';

    Share.share(
      receiptText,
      subject: 'MomoPe Receipt - ${transaction.merchantName}',
    );
    
    HapticFeedback.mediumImpact();
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download PDF'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'PDF download');
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Transaction ID'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: transaction.id));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transaction ID copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
                _reportIssue(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _reportIssue(BuildContext context) {
    // TODO: Navigate to support screen or open support ticket
    _showComingSoon(context, 'Issue reporting');
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.primaryTeal,
      ),
    );
  }
}
