import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/merchant_day_stats.dart';
import 'merchant_provider.dart';

/// Today's Stats Provider
/// Fetches merchant's daily statistics for today
final todayStatsProvider = FutureProvider<MerchantDayStats>((ref) async {
  final merchantId = ref.watch(merchantIdProvider);
  
  if (merchantId == null) {
    throw Exception('No merchant ID available');
  }

  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);

  try {
    final response = await Supabase.instance.client.rpc(
      'get_merchant_daily_stats',
      params: {
        'merchant_uuid': merchantId,
        'stats_date': startOfDay.toIso8601String().split('T')[0],
      },
    );

    return MerchantDayStats.fromJson(response as Map<String, dynamic>);
  } catch (e) {
    // If RPC function doesn't exist yet, return empty stats
    return MerchantDayStats.empty();
  }
});

/// Merchant Earnings Provider (Derived)
/// Calculates total pending settlement amount
final pendingSettlementProvider = FutureProvider<double>((ref) async {
  final merchantId = ref.watch(merchantIdProvider);
  
  if (merchantId == null) {
    return 0.0;
  }

  try {
    final response = await Supabase.instance.client
        .from('commissions')
        .select('net_revenue')
        .eq('merchant_id', merchantId)
        .eq('is_settled', false);

    double total = 0.0;
    for (final row in response) {
      total += (row['net_revenue'] as num).toDouble();
    }

    return total;
  } catch (e) {
    return 0.0;
  }
});
