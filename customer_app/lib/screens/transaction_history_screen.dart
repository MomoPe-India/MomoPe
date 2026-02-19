import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        setState(() {
          _error = 'User not authenticated';
          _isLoading = false;
        });
        return;
      }

      final response = await supabase
          .from('transactions')
          .select('''
            id,
            created_at,
            gross_amount,
            fiat_amount,
            coins_applied,
            status,
            merchants (
              business_name,
              category
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        _transactions = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load transactions: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchTransactions,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_transactions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _fetchTransactions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          return _buildTransactionCard(_transactions[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start shopping to see your transaction history',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context); // Go back to home
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan QR Code'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final merchant = transaction['merchants'] as Map<String, dynamic>?;
    final merchantName = merchant?['business_name'] ?? 'Unknown Merchant';
    final category = merchant?['category'] ?? '';
    
    final grossAmount = double.parse(transaction['gross_amount'].toString());
    final fiatAmount = double.parse(transaction['fiat_amount'].toString());
    final coinsApplied = double.parse(transaction['coins_applied'].toString());
    final status = transaction['status'] as String;
    
    final createdAt = DateTime.parse(transaction['created_at']);
    final formattedDate = DateFormat('MMM dd, yyyy • HH:mm').format(createdAt);
    
    // Calculate coins earned (placeholder - will be from DB once webhook runs)
    final coinsEarned = (fiatAmount * 0.1).round(); // Assuming 10% for now

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showTransactionDetails(transaction),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Merchant Icon
                  CircleAvatar(
                    backgroundColor: _getCategoryColor(category),
                    child: Icon(
                      _getCategoryIcon(category),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Merchant Name & Category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          merchantName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (category.isNotEmpty)
                          Text(
                            category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              letterSpacing: 0.5,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Amount
                  Text(
                    '₹${grossAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Divider
              Divider(color: Colors.grey[200], height: 1),
              const SizedBox(height: 12),
              // Details Row
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.payments_outlined,
                      label: 'Paid',
                      value: '₹${fiatAmount.toStringAsFixed(0)}',
                      color: Colors.orange[700]!,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.toll,
                      label: 'Coins Used',
                      value: '${coinsApplied.toStringAsFixed(0)}',
                      color: Colors.blue[700]!,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.stars,
                      label: 'Earned',
                      value: '+$coinsEarned',
                      color: Colors.green[700]!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Footer Row
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  _buildStatusChip(status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'success':
        backgroundColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        icon = Icons.check_circle;
        break;
      case 'pending':
        backgroundColor = Colors.orange[50]!;
        textColor = Colors.orange[700]!;
        icon = Icons.schedule;
        break;
      case 'failed':
        backgroundColor = Colors.red[50]!;
        textColor = Colors.red[700]!;
        icon = Icons.error;
        break;
      default:
        backgroundColor = Colors.grey[200]!;
        textColor = Colors.grey[700]!;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'grocery':
        return Colors.green[600]!;
      case 'food & beverage':
      case 'restaurant':
        return Colors.orange[600]!;
      case 'retail':
        return Colors.purple[600]!;
      case 'services':
        return Colors.blue[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'grocery':
        return Icons.shopping_cart;
      case 'food & beverage':
      case 'restaurant':
        return Icons.restaurant;
      case 'retail':
        return Icons.shopping_bag;
      case 'services':
        return Icons.build;
      default:
        return Icons.store;
    }
  }

  void _showTransactionDetails(Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          final merchant = transaction['merchants'] as Map<String, dynamic>?;
          final merchantName = merchant?['business_name'] ?? 'Unknown';
          final grossAmount = double.parse(transaction['gross_amount'].toString());
          final fiatAmount = double.parse(transaction['fiat_amount'].toString());
          final coinsApplied = double.parse(transaction['coins_applied'].toString());
          
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Transaction Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow('Merchant', merchantName),
                  _buildDetailRow('Transaction ID', transaction['id'].toString().substring(0, 8)),
                  _buildDetailRow('Date', DateFormat('MMM dd, yyyy HH:mm').format(DateTime.parse(transaction['created_at']))),
                  const Divider(height: 32),
                  _buildDetailRow('Gross Amount', '₹${grossAmount.toStringAsFixed(2)}', bold: true),
                  _buildDetailRow('Coins Applied', '-${coinsApplied.toStringAsFixed(0)} coins'),
                  _buildDetailRow('Fiat Paid', '₹${fiatAmount.toStringAsFixed(2)}', bold: true),
                  const Divider(height: 32),
                  _buildDetailRow('Coins Earned', '+${(fiatAmount * 0.1).round()} coins', color: Colors.green),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
