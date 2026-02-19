/// Merchant Daily Statistics Model
/// Aggregated stats for a single day
class MerchantDayStats {
  final int transactionCount;
  final double totalRevenue;      // Gross commission earned
  final double netRevenue;         // After rewards paid to customers
  final double pendingSettlement;  // Total unsettled amount
  final int customersServed;       // Unique customer count

  const MerchantDayStats({
    required this.transactionCount,
    required this.totalRevenue,
    required this.netRevenue,
    required this.pendingSettlement,
    required this.customersServed,
  });

  factory MerchantDayStats.fromJson(Map<String, dynamic> json) {
    return MerchantDayStats(
      transactionCount: json['transaction_count'] as int? ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      netRevenue: (json['net_revenue'] as num?)?.toDouble() ?? 0.0,
      pendingSettlement: (json['pending_settlement'] as num?)?.toDouble() ?? 0.0,
      customersServed: json['customers_served'] as int? ?? 0,
    );
  }

  factory MerchantDayStats.empty() {
    return const MerchantDayStats(
      transactionCount: 0,
      totalRevenue: 0.0,
      netRevenue: 0.0,
      pendingSettlement: 0.0,
      customersServed: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_count': transactionCount,
      'total_revenue': totalRevenue,
      'net_revenue': netRevenue,
      'pending_settlement': pendingSettlement,
      'customers_served': customersServed,
    };
  }

  @override
  String toString() {
    return 'MerchantDayStats(txns: $transactionCount, revenue: ₹$netRevenue, customers: $customersServed)';
  }
}
