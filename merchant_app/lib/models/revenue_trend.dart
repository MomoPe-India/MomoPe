/// Revenue Trend Model for Line Charts
class RevenueTrend {
  final List<double> dailyValues;
  final List<String> labels;
  final double totalRevenue;
  final double averageDaily;
  final DateTime periodStart;
  final DateTime periodEnd;

  const RevenueTrend({
    required this.dailyValues,
    required this.labels,
    required this.totalRevenue,
    required this.averageDaily,
    required this.periodStart,
    required this.periodEnd,
  });

  factory RevenueTrend.fromJson(Map<String, dynamic> json) {
    return RevenueTrend(
      dailyValues: (json['daily_values'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      labels: (json['labels'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      averageDaily: (json['average_daily'] as num).toDouble(),
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
    );
  }

  factory RevenueTrend.empty() {
    final now = DateTime.now();
    return RevenueTrend(
      dailyValues: List.filled(7, 0.0),
      labels: List.generate(
        7,
        (i) => DateTime.now().subtract(Duration(days: 6 - i)).toString().split(' ')[0],
      ),
      totalRevenue: 0.0,
      averageDaily: 0.0,
      periodStart: now.subtract(const Duration(days: 6)),
      periodEnd: now,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daily_values': dailyValues,
      'labels': labels,
      'total_revenue': totalRevenue,
      'average_daily': averageDaily,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
    };
  }

  /// Get maximum value for chart scaling
  double get maxValue => dailyValues.isEmpty ? 0 : dailyValues.reduce((a, b) => a > b ? a : b);

  /// Get minimum value for chart scaling
  double get minValue => dailyValues.isEmpty ? 0 : dailyValues.reduce((a, b) => a < b ? a : b);

  /// Check if trend is positive (last > first)
  bool get isPositiveTrend => dailyValues.isEmpty ? false : dailyValues.last > dailyValues.first;
}
