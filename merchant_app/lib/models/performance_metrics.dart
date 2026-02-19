/// Performance Metrics Model
/// Week-over-week growth, peak hours, payment mix
class PerformanceMetrics {
  final double weekOverWeekGrowth; // Percentage
  final int peakHour; // Hour of day (0-23)
  final double peakHourRevenue;
  final Map<String, double> paymentMethodBreakdown; // {method: amount}
  final Map<String, int> paymentMethodCounts; // {method: count}
  final double cashPercentage;
  final double coinsPercentage;

  const PerformanceMetrics({
    required this.weekOverWeekGrowth,
    required this.peakHour,
    required this.peakHourRevenue,
    required this.paymentMethodBreakdown,
    required this.paymentMethodCounts,
    required this.cashPercentage,
    required this.coinsPercentage,
  });

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      weekOverWeekGrowth: (json['week_over_week_growth'] as num?)?.toDouble() ?? 0.0,
      peakHour: json['peak_hour'] as int? ?? 12,
      peakHourRevenue: (json['peak_hour_revenue'] as num?)?.toDouble() ?? 0.0,
      paymentMethodBreakdown: (json['payment_method_breakdown'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
          {},
      paymentMethodCounts: (json['payment_method_counts'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
      cashPercentage: (json['cash_percentage'] as num?)?.toDouble() ?? 0.0,
      coinsPercentage: (json['coins_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory PerformanceMetrics.empty() {
    return const PerformanceMetrics(
      weekOverWeekGrowth: 0.0,
      peakHour: 12,
      peakHourRevenue: 0.0,
      paymentMethodBreakdown: {},
      paymentMethodCounts: {},
      cashPercentage: 0.0,
      coinsPercentage: 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week_over_week_growth': weekOverWeekGrowth,
      'peak_hour': peakHour,
      'peak_hour_revenue': peakHourRevenue,
      'payment_method_breakdown': paymentMethodBreakdown,
      'payment_method_counts': paymentMethodCounts,
      'cash_percentage': cashPercentage,
      'coins_percentage': coinsPercentage,
    };
  }

  /// Format growth percentage with sign
  String get growthDisplay {
    if (weekOverWeekGrowth > 0) {
      return '+${weekOverWeekGrowth.toStringAsFixed(1)}%';
    } else if (weekOverWeekGrowth < 0) {
      return '${weekOverWeekGrowth.toStringAsFixed(1)}%';
    }
    return '0.0%';
  }

  /// Check if growth is positive
  bool get isGrowthPositive => weekOverWeekGrowth > 0;

  /// Get peak hour display (12-hour format)
  String get peakHourDisplay {
    if (peakHour == 0) return '12 AM';
    if (peakHour < 12) return '$peakHour AM';
    if (peakHour == 12) return '12 PM';
    return '${peakHour - 12} PM';
  }
}
