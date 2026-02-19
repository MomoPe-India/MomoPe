import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/merchant_settlement.dart';
import 'merchant_provider.dart';

/// Merchant Settlements Provider
/// Fetches settlement history for the merchant
final settlementsProvider = FutureProvider<List<MerchantSettlement>>((ref) async {
  final merchantId = ref.watch(merchantIdProvider);
  
  if (merchantId == null) {
    return [];
  }

  try {
    final response = await Supabase.instance.client
        .from('merchant_settlements')
        .select()
        .eq('merchant_id', merchantId)
        .order('created_at', ascending: false);

    return response.map((json) => MerchantSettlement.fromJson(json)).toList();
  } catch (e) {
    // Table might not exist yet
    return [];
  }
});

/// Next Settlement Provider
/// Gets the next upcoming settlement
final nextSettlementProvider = Provider<AsyncValue<MerchantSettlement?>>((ref) {
  final settlementsAsync = ref.watch(settlementsProvider);
  
  return settlementsAsync.when(
    data: (settlements) {
      // Find first pending or scheduled settlement
      final nextSettlement = settlements.where((s) => 
        s.status == 'pending' || s.status == 'scheduled'
      ).firstOrNull;
      
      return AsyncValue.data(nextSettlement);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Past Settlements Provider
/// Gets completed settlements only
final pastSettlementsProvider = Provider<AsyncValue<List<MerchantSettlement>>>((ref) {
  final settlementsAsync = ref.watch(settlementsProvider);
  
  return settlementsAsync.when(
    data: (settlements) {
      final past = settlements.where((s) => 
        s.status == 'paid' || s.status == 'processed'
      ).toList();
      
      return AsyncValue.data(past);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});
