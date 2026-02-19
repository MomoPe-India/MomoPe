import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';

/// Model representing user's coin balance
class CoinBalance {
  final int availableCoins;
  final int totalCoins;
  final int lockedCoins;
  final DateTime? updatedAt;

  CoinBalance({
    required this.availableCoins,
    required this.totalCoins,
    required this.lockedCoins,
    this.updatedAt,
  });

  factory CoinBalance.fromJson(Map<String, dynamic> json) {
    return CoinBalance(
      availableCoins: (json['available_coins'] as num?)?.toInt() ?? 0,
      totalCoins: (json['total_coins'] as num?)?.toInt() ?? 0,
      lockedCoins: (json['locked_coins'] as num?)?.toInt() ?? 0,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Default zero balance for new users
  factory CoinBalance.zero() {
    return CoinBalance(
      availableCoins: 0,
      totalCoins: 0,
      lockedCoins: 0,
      updatedAt: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'available_coins': availableCoins,
      'total_coins': totalCoins,
      'locked_coins': lockedCoins,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// Coin balance provider with real-time updates from Supabase
/// 
/// Returns null when user is not authenticated.
/// Returns CoinBalance.zero() for authenticated users with no balance record.
/// Updates in real-time when balance changes in database.
final coinBalanceProvider = StreamProvider<CoinBalance?>((ref) async* {
  final authService = ref.watch(authServiceProvider);
  final user = authService.currentUser;

  if (user == null) {
    yield null;
    return;
  }

  // Native Supabase Auth: User ID is already the Supabase ID
  // No need to query user_mappings table anymore!
  final supabaseUserId = user.id;

  // Stream coin balance with real-time updates
  yield* Supabase.instance.client
      .from('momo_coin_balances')
      .stream(primaryKey: ['id'])
      .eq('user_id', supabaseUserId)
      .map((data) {
        if (data.isEmpty) {
          // No balance record yet (should be auto-created by trigger)
          return CoinBalance.zero();
        }
        return CoinBalance.fromJson(data.first);
      })
      .handleError((error) {
        // Log error but return zero balance to prevent UI crash
        print('❌ Error fetching coin balance: $error');
        return CoinBalance.zero();
      });
});
