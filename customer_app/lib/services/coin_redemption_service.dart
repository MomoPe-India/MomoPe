import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing FIFO (First-In-First-Out) coin redemption.
///
/// ✅ SECURITY FIX: All redemption logic is now delegated to the
/// `redeem_coins_atomic` Postgres stored procedure, which:
///   - Locks the user's balance row (FOR UPDATE) before deducting
///   - Iterates batches with SKIP LOCKED to prevent deadlocks
///   - Runs all deductions in a single database transaction
///   - Eliminates the race condition where two concurrent requests
///     could redeem the same coins (double-spend)
class CoinRedemptionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Redeem coins using an atomic database stored procedure (FIFO).
  ///
  /// Delegates all FIFO logic to `redeem_coins_atomic` RPC — keeps the
  /// client thin and prevents race conditions inherent in multi-step
  /// client-driven updates.
  ///
  /// Returns a summary map produced by the stored procedure:
  ///   { success, redeemed, remaining_balance, batch_count }
  ///
  /// Throws:
  ///   - Exception if user has insufficient coins (raised in DB)
  ///   - Exception on any database error
  Future<Map<String, dynamic>> redeemCoins({
    required String userId,
    required double coinsToRedeem,
    required String transactionId,
  }) async {
    try {
      debugPrint('🪙 Starting atomic FIFO coin redemption...');
      debugPrint('   User: $userId');
      debugPrint('   Coins to redeem: $coinsToRedeem');
      debugPrint('   Transaction: $transactionId');

      // Single RPC call — everything runs inside a DB transaction.
      // The stored procedure handles locking, FIFO deduction, audit
      // records, and balance update atomically.
      final result = await _supabase.rpc(
        'redeem_coins_atomic',
        params: {
          'p_user_id': userId,
          'p_transaction_id': transactionId,
          'p_coins_to_redeem': coinsToRedeem,
        },
      );

      if (result == null) {
        throw Exception('redeem_coins_atomic returned null — unexpected error');
      }

      final summary = Map<String, dynamic>.from(result as Map);

      debugPrint('   ✅ Redemption complete:');
      debugPrint('      Redeemed: ${summary['redeemed']} coins');
      debugPrint('      Remaining balance: ${summary['remaining_balance']}');
      debugPrint('      Batches used: ${summary['batch_count']}');

      return summary;
    } catch (e) {
      debugPrint('   ❌ Atomic coin redemption error: $e');
      rethrow;
    }
  }

  /// Calculate max redeemable coins following 80/20 rule.
  ///
  /// Returns the minimum of:
  ///   - 80% of bill amount
  ///   - 80% of user's available balance
  ///
  /// This ensures users always pay at least 20% fiat.
  Future<double> calculateMaxRedeemable({
    required String userId,
    required double billAmount,
  }) async {
    try {
      final balanceResponse = await _supabase
          .from('momo_coin_balances')
          .select('available_coins')
          .eq('user_id', userId)
          .maybeSingle();

      if (balanceResponse == null) return 0.0;

      final availableCoins =
          (balanceResponse['available_coins'] as num).toDouble();

      // Dual cap: min(80% of bill, 80% of balance)
      final maxFromBill = billAmount * 0.8;
      final maxFromBalance = availableCoins * 0.8;
      final maxRedeemable =
          maxFromBill < maxFromBalance ? maxFromBill : maxFromBalance;

      debugPrint('🧮 Max redeemable:');
      debugPrint('   Bill: ₹$billAmount, Available: $availableCoins coins');
      debugPrint('   Result: $maxRedeemable coins');

      return maxRedeemable;
    } catch (e) {
      debugPrint('❌ Error calculating max redeemable: $e');
      return 0.0; // Safe fallback
    }
  }

  /// Get user's active coin batches for display/debugging.
  Future<List<Map<String, dynamic>>> getUserBatches(String userId) async {
    try {
      final batches = await _supabase
          .from('coin_batches')
          .select('id, amount, original_amount, source, expiry_date, created_at')
          .eq('user_id', userId)
          .eq('is_expired', false)
          .gt('amount', 0)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(batches);
    } catch (e) {
      debugPrint('❌ Error fetching user batches: $e');
      return [];
    }
  }
}
