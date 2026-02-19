import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/merchant.dart';

/// Merchant Profile Provider
/// Streams the current merchant's profile from Supabase
/// Auto-updates on database changes
final merchantProvider = StreamProvider<Merchant?>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  
  if (user == null) {
    return Stream.value(null);
  }

  return Supabase.instance.client
      .from('merchants')
      .stream(primaryKey: ['id'])
      .eq('user_id', user.id)
      .map((data) {
        if (data.isEmpty) return null;
        return Merchant.fromJson(data.first);
      });
});

/// Merchant ID Provider (derived from merchant profile)
/// Returns the merchant ID for use in other queries
final merchantIdProvider = Provider<String?>((ref) {
  final merchantAsync = ref.watch(merchantProvider);
  return merchantAsync.when(
    data: (merchant) => merchant?.id,
    loading: () => null,
    error: (_, __) => null,
  );
});
