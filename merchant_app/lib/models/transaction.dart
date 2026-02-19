/// Transaction Model (Merchant App)
/// Represents a customer payment transaction
class Transaction {
  final String id;
  final String userId;       // Customer ID
  final String merchantId;
  final double grossAmount;  // Bill total
  final double coinAmount;   // Coins redeemed by customer
  final double fiatAmount;   // Actual paid via PayU
  final int rewardsEarned;   // Coins given to customer
  final String status;       // pending, success, failed
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Optional merchant commission data (if joined)
  final double? commissionRate;
  final double? grossRevenue;
  final double? netRevenue;

  const Transaction({
    required this.id,
    required this.userId,
    required this.merchantId,
    required this.grossAmount,
    required this.coinAmount,
    required this.fiatAmount,
    required this.rewardsEarned,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
    this.updatedAt,
    this.commissionRate,
    this.grossRevenue,
    this.netRevenue,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      merchantId: json['merchant_id'] as String,
      grossAmount: (json['gross_amount'] as num?)?.toDouble() ?? 0.0,
      coinAmount: (json['coin_amount'] as num?)?.toDouble() ?? 0.0,
      fiatAmount: (json['fiat_amount'] as num?)?.toDouble() ?? 0.0,
      rewardsEarned: json['rewards_earned'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] as String? ?? 'unknown',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      commissionRate: json['commission_rate'] != null
          ? (json['commission_rate'] as num).toDouble()
          : null,
      grossRevenue: json['gross_revenue'] != null
          ? (json['gross_revenue'] as num).toDouble()
          : null,
      netRevenue: json['net_revenue'] != null
          ? (json['net_revenue'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'merchant_id': merchantId,
      'gross_amount': grossAmount,
      'coin_amount': coinAmount,
      'fiat_amount': fiatAmount,
      'rewards_earned': rewardsEarned,
      'status': status,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      if (commissionRate != null) 'commission_rate': commissionRate,
      if (grossRevenue != null) 'gross_revenue': grossRevenue,
      if (netRevenue != null) 'net_revenue': netRevenue,
    };
  }

  /// Check if transaction is successful
  bool get isSuccess => status == 'success';

  /// Check if transaction is pending
  bool get isPending => status == 'pending';

  /// Check if transaction failed
  bool get isFailed => status == 'failed';

  /// Get formatted date string
  String getFormattedDate() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      return 'Today ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  @override
  String toString() {
    return 'Transaction(₹$grossAmount, $status, ${createdAt.toString().split(' ')[0]})';
  }
}
