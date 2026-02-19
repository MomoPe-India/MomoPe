/// Transaction model for MomoPe payment system
class Transaction {
  final String id;
  final String customerId;
  final String merchantId;
  final String merchantName;
  final String merchantCategory;
  final String? merchantLogoUrl;
  final double amount;
  final int coinsEarned;
  final int coinsRedeemed;
  final TransactionStatus status;
  final DateTime createdAt;
  final String? upiTransactionId;

  Transaction({
    required this.id,
    required this.customerId,
    required this.merchantId,
    required this.merchantName,
    required this.merchantCategory,
    this.merchantLogoUrl,
    required this.amount,
    required this.coinsEarned,
    this.coinsRedeemed = 0,
    required this.status,
    required this.createdAt,
    this.upiTransactionId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      merchantId: json['merchant_id'] as String,
      merchantName: json['merchant_name'] as String,
      merchantCategory: json['merchant_category'] as String? ?? 'General',
      merchantLogoUrl: json['merchant_logo_url'] as String?,
      amount: (json['amount'] as num).toDouble(),
      coinsEarned: (json['coins_earned'] as num?)?.toInt() ?? 0,
      coinsRedeemed: (json['coins_redeemed'] as num?)?.toInt() ?? 0,
      status: TransactionStatus.fromString(json['status'] as String?  ?? 'pending'),
      createdAt: DateTime.parse(json['created_at'] as String),
      upiTransactionId: json['upi_transaction_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'merchant_id': merchantId,
      'merchant_name': merchantName,
      'merchant_category': merchantCategory,
      'merchant_logo_url': merchantLogoUrl,
      'amount': amount,
      'coins_earned': coinsEarned,
      'coins_redeemed': coinsRedeemed,
      'status': status.toString(),
      'created_at': createdAt.toIso8601String(),
      'upi_transaction_id': upiTransactionId,
    };
  }
}

/// Transaction status enum
enum TransactionStatus {
  pending,
  success,
  failed,
  all; // Special case for filtering

  static TransactionStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
        return TransactionStatus.success;
      case 'pending':
        return TransactionStatus.pending;
      case 'failed':
        return TransactionStatus.failed;
      default:
        return TransactionStatus.pending;
    }
  }

  @override
  String toString() {
    switch (this) {
      case TransactionStatus.pending:
        return 'pending';
      case TransactionStatus.success:
        return 'success';
      case TransactionStatus.failed:
        return 'failed';
      case TransactionStatus.all:
        return 'all';
    }
  }
}
