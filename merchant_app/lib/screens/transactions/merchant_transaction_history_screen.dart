import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../providers/merchant_transactions_provider.dart';
import '../../models/transaction.dart';
import 'merchant_transaction_detail_screen.dart';

/// Merchant Transaction History Screen
/// Shows all transactions with filtering and grouping
class MerchantTransactionHistoryScreen extends ConsumerStatefulWidget {
  const MerchantTransactionHistoryScreen({super.key});

  @override
  ConsumerState<MerchantTransactionHistoryScreen> createState() =>
      _MerchantTransactionHistoryScreenState();
}

class _MerchantTransactionHistoryScreenState
    extends ConsumerState<MerchantTransactionHistoryScreen> {
  String _selectedFilter = 'all';
  String _selectedPeriod = 'today';

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(merchantTransactionsProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          children: [
            // Premium Header
            _buildHeader(context),
          // Filter Chips
          _buildFilterChips(),
          
          const SizedBox(height: AppSpacing.space8),

          // Transactions List
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                final filteredTxns = _filterTransactions(transactions);
                
                if (filteredTxns.isEmpty) {
                  return _buildEmptyState();
                }

                // Group transactions by date
                final groupedTxns = _groupTransactionsByDate(filteredTxns);

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(merchantTransactionsProvider);
                  },
                  child: ListView.builder(
                    padding: AppSpacing.paddingAll16,
                    itemCount: groupedTxns.length,
                    itemBuilder: (context, index) {
                      final dateKey = groupedTxns.keys.elementAt(index);
                      final txnsForDate = groupedTxns[dateKey]!;

                      return _buildDateGroup(dateKey, txnsForDate);
                    },
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
                    const SizedBox(height: 16),
                    PremiumButton(
                      text: 'Retry',
                      onPressed: () {
                        ref.invalidate(merchantTransactionsProvider);
                      },
                      style: PremiumButtonStyle.secondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'TRANSACTIONS',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Filter Chips in Header
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('All Orders', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Successful', 'success'),
                const SizedBox(width: 8),
                _buildFilterChip('Pending', 'pending'),
                const SizedBox(width: 8),
                _buildFilterChip('Failed', 'failed'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected ? AppColors.primaryTeal : Colors.white,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ),
    );
  }

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    var filtered = transactions;

    // Filter by status
    if (_selectedFilter != 'all') {
      filtered = filtered.where((t) => t.status == _selectedFilter).toList();
    }

    // Filter by period
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'today':
        final startOfDay = DateTime(now.year, now.month, now.day);
        filtered = filtered.where((t) => t.createdAt.isAfter(startOfDay)).toList();
        break;
      case 'week':
        final startOfWeek = now.subtract(const Duration(days: 7));
        filtered = filtered.where((t) => t.createdAt.isAfter(startOfWeek)).toList();
        break;
      case 'month':
        final startOfMonth = DateTime(now.year, now.month, 1);
        filtered = filtered.where((t) => t.createdAt.isAfter(startOfMonth)).toList();
        break;
    }

    return filtered;
  }

  Map<String, List<Transaction>> _groupTransactionsByDate(
    List<Transaction> transactions,
  ) {
    final Map<String, List<Transaction>> grouped = {};

    for (final txn in transactions) {
      final dateKey = _getDateKey(txn.createdAt);
      
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(txn);
    }

    return grouped;
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txnDate = DateTime(date.year, date.month, date.day);

    if (txnDate == today) {
      return 'Today';
    } else if (txnDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildDateGroup(String dateLabel, List<Transaction> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.space4,
            bottom: AppSpacing.space8,
            top: AppSpacing.space8,
          ),
          child: Text(
            dateLabel,
            style: AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.neutral500,
              letterSpacing: 1.0,
            ),
          ),
        ),
        ...transactions.map((txn) => _buildTransactionCard(txn)),
        const SizedBox(height: AppSpacing.space8),
      ],
    );
  }

  Widget _buildTransactionCard(Transaction txn) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MerchantTransactionDetailScreen(
              transaction: txn,
            ),
          ),
        );
      },
      child: Container(
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
            // Status Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getStatusColor(txn.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getStatusIcon(txn.status),
                color: _getStatusColor(txn.status),
                size: 18,
              ),
            ),
            
            const SizedBox(width: 16),

            // Transaction Info
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
                  const SizedBox(height: 2),
                  Text(
                    '${_formatTime(txn.createdAt)} • ${txn.paymentMethod.toUpperCase()}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.neutral500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Earnings
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
                if (txn.coinAmount > 0)
                  Text(
                    '${txn.coinAmount.toStringAsFixed(0)} coins',
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
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Color _getStatusColor(String status) {
    switch (status) {
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

  IconData _getStatusIcon(String status) {
    switch (status) {
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.neutral400,
            ),
            const SizedBox(height: AppSpacing.space24),
            Text(
              'No transactions found',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.space8),
            Text(
              'Transactions will appear here once customers make payments',
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
}
