import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/widgets/widgets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/transaction.dart';
import '../qr_scanner/qr_scanner_screen.dart';
import 'transaction_detail_screen.dart';

// State providers
final transactionFilterProvider =
    StateProvider<TransactionStatus>((ref) => TransactionStatus.all);
final transactionSearchProvider = StateProvider<String>((ref) => '');

// Mock transactions provider (replace with real Supabase stream later)
final transactionsProvider = Provider<List<Transaction>>((ref) {
  final filter = ref.watch(transactionFilterProvider);
  final search = ref.watch(transactionSearchProvider);

  // Mock data
  final now = DateTime.now();
  List<Transaction> transactions = [
    Transaction(
      id: '1',
      customerId: 'user1',
      merchantId: 'merchant1',
      merchantName: 'Reliance Fresh',
      merchantCategory: 'Grocery & Retail',
      amount: 1250,
      coinsEarned: 125,
      status: TransactionStatus.success,
      createdAt: now.subtract(const Duration(hours: 2)),
    ),
    Transaction(
      id: '2',
      customerId: 'user1',
      merchantId: 'merchant2',
      merchantName: 'DMart',
      merchantCategory: 'Supermarket',
      amount: 850,
      coinsEarned: 85,
      status: TransactionStatus.success,
      createdAt: now.subtract(const Duration(days: 1, hours: 3)),
    ),
    Transaction(
      id: '3',
      customerId: 'user1',
      merchantId: 'merchant3',
      merchantName: 'Big Bazaar',
      merchantCategory: 'Department Store',
      amount: 2000,
      coinsEarned: 200,
      status: TransactionStatus.success,
      createdAt: now.subtract(const Duration(days: 3)),
    ),
    Transaction(
      id: '4',
      customerId: 'user1',
      merchantId: 'merchant4',
      merchantName: 'Cafe Coffee Day',
      merchantCategory: 'Cafe',
      amount: 450,
      coinsEarned: 45,
      status: TransactionStatus.pending,
      createdAt: now.subtract(const Duration(days: 7)),
    ),
    Transaction(
      id: '5',
      customerId: 'user1',
      merchantId: 'merchant5',
      merchantName: 'Dominos Pizza',
      merchantCategory: 'Food & Dining',
      amount: 600,
      coinsEarned: 0,
      status: TransactionStatus.failed,
      createdAt: now.subtract(const Duration(days: 15)),
    ),
  ];

  // Apply status filter
  if (filter != TransactionStatus.all) {
    transactions =
        transactions.where((t) => t.status == filter).toList();
  }

  // Apply search filter
  if (search.isNotEmpty) {
    transactions = transactions
        .where((t) =>
            t.merchantName.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }

  return transactions;
});

/// Date grouping enum
enum DateGroup {
  today,
  yesterday,
  thisWeek,
  thisMonth,
  older,
}

/// Premium Transaction History Screen
class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isLoading = false);
  }

  Map<DateGroup, List<Transaction>> _groupByDate(
      List<Transaction> transactions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeekStart = today.subtract(Duration(days: now.weekday - 1));
    final thisMonthStart = DateTime(now.year, now.month, 1);

    Map<DateGroup, List<Transaction>> grouped = {
      DateGroup.today: [],
      DateGroup.yesterday: [],
      DateGroup.thisWeek: [],
      DateGroup.thisMonth: [],
      DateGroup.older: [],
    };

    for (final txn in transactions) {
      final txnDate = DateTime(
        txn.createdAt.year,
        txn.createdAt.month,
        txn.createdAt.day,
      );

      if (txnDate == today) {
        grouped[DateGroup.today]!.add(txn);
      } else if (txnDate == yesterday) {
        grouped[DateGroup.yesterday]!.add(txn);
      } else if (txnDate.isAfter(thisWeekStart)) {
        grouped[DateGroup.thisWeek]!.add(txn);
      } else if (txnDate.isAfter(thisMonthStart)) {
        grouped[DateGroup.thisMonth]!.add(txn);
      } else {
        grouped[DateGroup.older]!.add(txn);
      }
    }

    // Remove empty groups
    grouped.removeWhere((key, value) => value.isEmpty);

    return grouped;
  }

  String _getGroupTitle(DateGroup group) {
    switch (group) {
      case DateGroup.today:
        return 'TODAY';
      case DateGroup.yesterday:
        return 'YESTERDAY';
      case DateGroup.thisWeek:
        return 'THIS WEEK';
      case DateGroup.thisMonth:
        return 'THIS MONTH';
      case DateGroup.older:
        return 'OLDER';
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.primaryTeal,
        child: _isLoading
            ? _buildLoadingSkeleton()
            : transactions.isEmpty
                ? _buildEmptyState()
                : Column(
                    children: [
                      _buildSearchBar(),
                      _buildFilterChips(),
                      const SizedBox(height: 8),
                      Expanded(child: _buildTransactionList(transactions)),
                    ],
                  ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          ref.read(transactionSearchProvider.notifier).state = value;
        },
        decoration: InputDecoration(
          hintText: 'Search merchants...',
          hintStyle: TextStyle(color: AppColors.neutral500),
          prefixIcon: Icon(Icons.search, color: AppColors.neutral600),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(transactionSearchProvider.notifier).state = '';
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final currentFilter = ref.watch(transactionFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip('All', TransactionStatus.all, currentFilter),
          const SizedBox(width: 8),
          _buildFilterChip('Success', TransactionStatus.success, currentFilter),
          const SizedBox(width: 8),
          _buildFilterChip('Pending', TransactionStatus.pending, currentFilter),
          const SizedBox(width: 8),
          _buildFilterChip('Failed', TransactionStatus.failed, currentFilter),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    TransactionStatus status,
    TransactionStatus current,
  ) {
    final isSelected = status == current;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        ref.read(transactionFilterProvider.notifier).state = status;
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.primaryTeal,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.neutral700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 14,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primaryTeal : AppColors.neutral300,
          width: 1,
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions) {
    final grouped = _groupByDate(transactions);

    if (grouped.isEmpty) {
      return _buildNoResultsState();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: grouped.length * 2, // Header + items for each group
      itemBuilder: (context, index) {
        final groupIndex = index ~/ 2;
        final isHeader = index.isEven;
        final group = grouped.keys.elementAt(groupIndex);

        if (isHeader) {
          return _buildStickyHeader(_getGroupTitle(group));
        } else {
          final groupTransactions = grouped[group]!;
          return Column(
            children: groupTransactions.map((txn) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _buildTransactionCard(txn),
              );
            }).toList(),
          );
        }
      },
    );
  }

  Widget _buildStickyHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.neutral100,
      child: Text(
        title,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.neutral600,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction txn) {
    return PremiumCard(
      style: PremiumCardStyle.elevated,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TransactionDetailScreen(transaction: txn),
        ),
      ),
      child: Row(
        children: [
          // Merchant Logo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryTealLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.store_rounded,
              color: AppColors.primaryTeal,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Merchant Info + Timestamp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        txn.merchantName,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStatusDot(txn.status),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  txn.merchantCategory,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (txn.status == TransactionStatus.success)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.rewardsGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.rewardsGold.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.stars_rounded,
                              size: 14,
                              color: AppColors.rewardsGold,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${txn.coinsEarned} coins',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.rewardsGoldDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        _getStatusLabel(txn.status),
                        style: AppTypography.bodySmall.copyWith(
                          color: _getStatusColor(txn.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    Text(
                      '₹${txn.amount.toStringAsFixed(0)}',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(txn.createdAt),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDot(TransactionStatus status) {
    Color color;
    if (status == TransactionStatus.success) {
      color = AppColors.successGreen;
    } else if (status == TransactionStatus.pending) {
      color = AppColors.warningAmber;
    } else if (status == TransactionStatus.failed) {
      color = AppColors.errorRed;
    } else {
      color = AppColors.neutral400;
    }

    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  String _getStatusLabel(TransactionStatus status) {
    if (status == TransactionStatus.pending) {
      return 'Pending';
    } else if (status == TransactionStatus.failed) {
      return 'Failed';
    } else {
      return '';
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    if (status == TransactionStatus.pending) {
      return AppColors.warningAmberDark;
    } else if (status == TransactionStatus.failed) {
      return AppColors.errorRedDark;
    } else {
      return AppColors.neutral600;
    }
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${_formatTime(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Widget _buildLoadingSkeleton() {
    return Shimmer.fromColors(
      baseColor: AppColors.neutral200,
      highlightColor: AppColors.neutral100,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: AppColors.neutral400,
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Make your first payment to start earning coins!',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PremiumButton(
              text: 'Scan QR to Pay',
              icon: Icons.qr_code_scanner,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QRScannerScreen(),
                  ),
                );
              },
              style: PremiumButtonStyle.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    final search = ref.watch(transactionSearchProvider);
    final filter = ref.watch(transactionFilterProvider);

    String title;
    String subtitle;
    IconData icon;

    if (search.isNotEmpty) {
      icon = Icons.search_off;
      title = 'No merchants found';
      subtitle = 'Try a different search term';
    } else {
      icon = Icons.filter_alt_off;
      title = 'No ${filter.toString()} transactions';
      subtitle = 'Try changing the filter';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: AppColors.neutral400),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
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
