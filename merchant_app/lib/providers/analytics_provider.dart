import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/revenue_trend.dart';
import '../models/performance_metrics.dart';
import '../models/customer_insights.dart';
import 'merchant_provider.dart';

/// Time period for analytics
enum AnalyticsPeriod {
  sevenDays,
  thirtyDays,
  custom,
}

/// Selected period provider
final selectedPeriodProvider = StateProvider<AnalyticsPeriod>((ref) {
  return AnalyticsPeriod.sevenDays;
});

/// Custom date range provider (for custom period)
final customDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

/// Revenue Trend Provider
/// Fetches daily revenue data for charts
final revenueTrendProvider = FutureProvider<RevenueTrend>((ref) async {
  final merchantId = ref.watch(merchantIdProvider);
  final period = ref.watch(selectedPeriodProvider);
  final customRange = ref.watch(customDateRangeProvider);

  if (merchantId == null) {
    return RevenueTrend.empty();
  }

  // Calculate date range based on period
  final now = DateTime.now();
  DateTime startDate;
  DateTime endDate = now;

  switch (period) {
    case AnalyticsPeriod.sevenDays:
      startDate = now.subtract(const Duration(days: 6)); // Last 7 days including today
      break;
    case AnalyticsPeriod.thirtyDays:
      startDate = now.subtract(const Duration(days: 29)); // Last 30 days
      break;
    case AnalyticsPeriod.custom:
      if (customRange == null) {
        startDate = now.subtract(const Duration(days: 6));
      } else {
        startDate = customRange.start;
        endDate = customRange.end;
      }
      break;
  }

  try {
    final response = await Supabase.instance.client.rpc(
      'get_merchant_revenue_trend',
      params: {
        'merchant_uuid': merchantId,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
      },
    );

    return RevenueTrend.fromJson(response as Map<String, dynamic>);
  } catch (e) {
    // Fallback to manual calculation if RPC doesn't exist
    return _calculateRevenueTrendManually(merchantId, startDate, endDate);
  }
});

/// Performance Metrics Provider
/// Week-over-week growth, peak hours, etc.
final performanceMetricsProvider = FutureProvider<PerformanceMetrics>((ref) async {
  final merchantId = ref.watch(merchantIdProvider);
  final period = ref.watch(selectedPeriodProvider);

  if (merchantId == null) {
    return PerformanceMetrics.empty();
  }

  try {
    final periodDays = period == AnalyticsPeriod.sevenDays ? 7 : 30;
    
    final response = await Supabase.instance.client.rpc(
      'get_merchant_performance_metrics',
      params: {
        'merchant_uuid': merchantId,
        'period_days': periodDays,
      },
    );

    return PerformanceMetrics.fromJson(response as Map<String, dynamic>);
  } catch (e) {
    return PerformanceMetrics.empty();
  }
});

/// Customer Insights Provider
/// Repeat customers, average basket size, etc.
final customerInsightsProvider = FutureProvider<CustomerInsights>((ref) async {
  final merchantId = ref.watch(merchantIdProvider);
  final period = ref.watch(selectedPeriodProvider);

  if (merchantId == null) {
    return CustomerInsights.empty();
  }

  try {
    final periodDays = period == AnalyticsPeriod.sevenDays ? 7 : 30;
    
    final response = await Supabase.instance.client.rpc(
      'get_merchant_customer_insights',
      params: {
        'merchant_uuid': merchantId,
        'period_days': periodDays,
      },
    );

    return CustomerInsights.fromJson(response as Map<String, dynamic>);
  } catch (e) {
    return CustomerInsights.empty();
  }
});

/// Manual fallback calculation for revenue trend
Future<RevenueTrend> _calculateRevenueTrendManually(
  String merchantId,
  DateTime startDate,
  DateTime endDate,
) async {
  try {
    final transactions = await Supabase.instance.client
        .from('transactions')
        .select('created_at, gross_amount')
        .eq('merchant_id', merchantId)
        .eq('status', 'success')
        .gte('created_at', startDate.toIso8601String())
        .lte('created_at', endDate.toIso8601String());

    // Group by date
    final Map<String, double> dailyRevenue = {};
    
    for (final txn in transactions) {
      final date = DateTime.parse(txn['created_at'] as String);
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      dailyRevenue[dateKey] = (dailyRevenue[dateKey] ?? 0.0) + 
          (txn['gross_amount'] as num).toDouble();
    }

    // Fill missing dates with 0
    final days = endDate.difference(startDate).inDays + 1;
    final List<double> values = [];
    final List<String> labels = [];

    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      values.add(dailyRevenue[dateKey] ?? 0.0);
      labels.add(dateKey);
    }

    final total = values.fold<double>(0.0, (sum, val) => sum + val);
    final avg = values.isEmpty ? 0.0 : total / values.length;

    return RevenueTrend(
      dailyValues: values,
      labels: labels,
      totalRevenue: total,
      averageDaily: avg,
      periodStart: startDate,
      periodEnd: endDate,
    );
  } catch (e) {
    return RevenueTrend.empty();
  }
}
