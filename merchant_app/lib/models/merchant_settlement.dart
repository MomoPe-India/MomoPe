/// Merchant Settlement Model
/// Represents a payout/settlement to merchant
class MerchantSettlement {
  final String id;
  final String merchantId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int transactionCount;
  final double totalGrossRevenue;
  final double totalCoinCost;
  final double totalNetRevenue;
  final double finalSettlementAmount;
  final String status; // pending, scheduled, processed, paid
  final DateTime? scheduledDate;
  final DateTime? paidDate;
  final DateTime createdAt;

  const MerchantSettlement({
    required this.id,
    required this.merchantId,
    required this.periodStart,
    required this.periodEnd,
    required this.transactionCount,
    required this.totalGrossRevenue,
    required this.totalCoinCost,
    required this.totalNetRevenue,
    required this.finalSettlementAmount,
    required this.status,
    this.scheduledDate,
    this.paidDate,
    required this.createdAt,
  });

  factory MerchantSettlement.fromJson(Map<String, dynamic> json) {
    return MerchantSettlement(
      id: json['id'] as String,
      merchantId: json['merchant_id'] as String,
      periodStart: DateTime.parse(json['settlement_period_start'] as String),
      periodEnd: DateTime.parse(json['settlement_period_end'] as String),
      transactionCount: json['total_transactions_count'] as int? ?? 0,
      totalGrossRevenue: (json['total_gross_revenue'] as num?)?.toDouble() ?? 0.0,
      totalCoinCost: (json['total_coin_cost'] as num?)?.toDouble() ?? 0.0,
      totalNetRevenue: (json['total_net_revenue'] as num?)?.toDouble() ?? 0.0,
      finalSettlementAmount: (json['final_settlement_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      scheduledDate: json['scheduled_date'] != null 
          ? DateTime.parse(json['scheduled_date'] as String)
          : null,
      paidDate: json['paid_date'] != null
          ? DateTime.parse(json['paid_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant_id': merchantId,
      'settlement_period_start': periodStart.toIso8601String(),
      'settlement_period_end': periodEnd.toIso8601String(),
      'total_transactions_count': transactionCount,
      'total_gross_revenue': totalGrossRevenue,
      'total_coin_cost': totalCoinCost,
      'total_net_revenue': totalNetRevenue,
      'final_settlement_amount': finalSettlementAmount,
      'status': status,
      'scheduled_date': scheduledDate?.toIso8601String(),
      'paid_date': paidDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Get days until scheduled payout
  int? getDaysUntilPayout() {
    if (scheduledDate == null) return null;
    return scheduledDate!.difference(DateTime.now()).inDays;
  }

  /// Check if settlement is upcoming
  bool get isUpcoming => status == 'pending' || status == 'scheduled';

  /// Check if settlement is completed
  bool get isCompleted => status == 'paid' || status == 'processed';

  @override
  String toString() {
    return 'Settlement(₹$finalSettlementAmount, $status, ${periodStart.toString().split(' ')[0]} to ${periodEnd.toString().split(' ')[0]})';
  }
}
