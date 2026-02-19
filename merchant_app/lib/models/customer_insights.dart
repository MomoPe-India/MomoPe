/// Customer Insights Model
/// Repeat customer rate, average basket size, top customers
class CustomerInsights {
  final int totalCustomers;
  final int repeatCustomers;
  final double repeatCustomerRate; // Percentage
  final double averageBasketSize;
  final double averageOrderValue;
  final int totalOrders;
  final List<TopCustomer> topCustomers;

  const CustomerInsights({
    required this.totalCustomers,
    required this.repeatCustomers,
    required this.repeatCustomerRate,
    required this.averageBasketSize,
    required this.averageOrderValue,
    required this.totalOrders,
    required this.topCustomers,
  });

  factory CustomerInsights.fromJson(Map<String, dynamic> json) {
    return CustomerInsights(
      totalCustomers: json['total_customers'] as int? ?? 0,
      repeatCustomers: json['repeat_customers'] as int? ?? 0,
      repeatCustomerRate: (json['repeat_customer_rate'] as num?)?.toDouble() ?? 0.0,
      averageBasketSize: (json['average_basket_size'] as num?)?.toDouble() ?? 0.0,
      averageOrderValue: (json['average_order_value'] as num?)?.toDouble() ?? 0.0,
      totalOrders: json['total_orders'] as int? ?? 0,
      topCustomers: (json['top_customers'] as List<dynamic>?)
              ?.map((e) => TopCustomer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  factory CustomerInsights.empty() {
    return const CustomerInsights(
      totalCustomers: 0,
      repeatCustomers: 0,
      repeatCustomerRate: 0.0,
      averageBasketSize: 0.0,
      averageOrderValue: 0.0,
      totalOrders: 0,
      topCustomers: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_customers': totalCustomers,
      'repeat_customers': repeatCustomers,
      'repeat_customer_rate': repeatCustomerRate,
      'average_basket_size': averageBasketSize,
      'average_order_value': averageOrderValue,
      'total_orders': totalOrders,
      'top_customers': topCustomers.map((e) => e.toJson()).toList(),
    };
  }

  /// Format repeat rate for display
  String get repeatRateDisplay => '${repeatCustomerRate.toStringAsFixed(1)}%';
}

/// Top Customer Model
class TopCustomer {
  final String customerId;
  final int orderCount;
  final double totalSpent;

  const TopCustomer({
    required this.customerId,
    required this.orderCount,
    required this.totalSpent,
  });

  factory TopCustomer.fromJson(Map<String, dynamic> json) {
    return TopCustomer(
      customerId: json['customer_id'] as String,
      orderCount: json['order_count'] as int,
      totalSpent: (json['total_spent'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'order_count': orderCount,
      'total_spent': totalSpent,
    };
  }

  /// Get masked customer ID for display
  String get maskedId {
    if (customerId.length <= 8) return customerId;
    return '${customerId.substring(0, 4)}...${customerId.substring(customerId.length - 4)}';
  }
}
