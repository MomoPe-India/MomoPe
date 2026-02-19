import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing FIFO (First-In-First-Out) coin redemption
/// 
/// Ensures coins are deducted from oldest batches first, maintaining
/// proper audit trail and balance integrity across coin_batches,
/// coin_transactions, and momo_coin_balances tables.
class CoinRedemptionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Redeem coins using FIFO (First-In-First-Out) logic
  /// 
  /// Deducts coins from oldest non-expired batches first, creates
  /// coin_transaction audit records for each batch used, and updates
  /// the aggregate balance.
  /// 
  /// Returns list of coin_transaction IDs created.
  /// 
  /// Throws:
  /// - Exception if user has insufficient available coins
  /// - Exception if no active batches found (data integrity issue)
  /// - Exception on database errors
  Future<List<String>> redeemCoins({
    required String userId,
    required double coinsToRedeem,
    required String transactionId,
  }) async {
    try {
      print('🪙 Starting FIFO coin redemption...');
      print('   User: $userId');
      print('   Coins to redeem: $coinsToRedeem');
      print('   Transaction: $transactionId');

      // 1. Validate sufficient balance
      final balanceResponse = await _supabase
          .from('momo_coin_balances')
          .select('available_coins')
          .eq('user_id', userId)
          .maybeSingle();

      if (balanceResponse == null) {
        throw Exception('No coin balance record found for user');
      }

      final availableCoins = (balanceResponse['available_coins'] as num).toDouble();

      if (availableCoins < coinsToRedeem) {
        throw Exception(
          'Insufficient coins. Available: $availableCoins, Requested: $coinsToRedeem',
        );
      }

      print('   ✅ Balance validated: $availableCoins available');

      // 2. Fetch active batches (FIFO order: oldest first)
      final batchesResponse = await _supabase
          .from('coin_batches')
          .select('id, amount, created_at')
          .eq('user_id', userId)
          .eq('is_expired', false)
          .gt('amount', 0)
          .order('created_at', ascending: true);

      final batches = List<Map<String, dynamic>>.from(batchesResponse);

      if (batches.isEmpty) {
        throw Exception(
          'No active coin batches found despite available balance. Data integrity issue.',
        );
      }

      print('   📦 Found ${batches.length} active batches');

      // 3. Deduct coins using FIFO
      double remainingToRedeem = coinsToRedeem;
      List<String> coinTransactionIds = [];

      for (int i = 0; i < batches.length; i++) {
        if (remainingToRedeem <= 0) break;

        final batch = batches[i];
        final batchId = batch['id'] as String;
        final batchAmount = (batch['amount'] as num).toDouble();
        final batchCreatedAt = batch['created_at'] as String;

        // Calculate how much to deduct from this batch
        final deductFromBatch =
            remainingToRedeem < batchAmount ? remainingToRedeem : batchAmount;

        print(
          '   🔄 Batch ${i + 1}/${batches.length}: Deducting $deductFromBatch from $batchAmount coins',
        );

        // Update batch amount (new_amount = old_amount - deducted)
        await _supabase
            .from('coin_batches')
            .update({'amount': batchAmount - deductFromBatch})
            .eq('id', batchId);

        // Create coin_transaction audit record
        final coinTxnResponse = await _supabase
            .from('coin_transactions')
            .insert({
              'user_id': userId,
              'transaction_id': transactionId,
              'batch_id': batchId,
              'type': 'redeem',
              'amount': -deductFromBatch, // Negative for redemption
              'description':
                  'Redeemed ${deductFromBatch.toStringAsFixed(2)} coins from batch created at $batchCreatedAt',
            })
            .select('id')
            .single();

        coinTransactionIds.add(coinTxnResponse['id'] as String);

        remainingToRedeem -= deductFromBatch;

        print('   ✅ Batch updated, audit record created');
      }

      print('   💰 Total redeemed: $coinsToRedeem coins from ${coinTransactionIds.length} batches');

      // 4. Update aggregate balance
      await _supabase.from('momo_coin_balances').update({
        'available_coins': availableCoins - coinsToRedeem,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);

      print('   ✅ Balance updated: ${availableCoins - coinsToRedeem} coins remaining');

      return coinTransactionIds;
    } catch (e) {
      print('   ❌ FIFO redemption error: $e');
      rethrow;
    }
  }

  /// Calculate max redeemable coins following 80/20 rule
  /// 
  /// Returns the minimum of:
  /// - 80% of bill amount
  /// - 80% of user's available balance
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

      if (balanceResponse == null) {
        return 0.0; // No balance record = 0 redeemable
      }

      final availableCoins = (balanceResponse['available_coins'] as num).toDouble();

      // Dual cap: min(80% of bill, 80% of balance)
      final maxFromBill = billAmount * 0.8;
      final maxFromBalance = availableCoins * 0.8;

      final maxRedeemable = maxFromBill < maxFromBalance ? maxFromBill : maxFromBalance;

      print('🧮 Max redeemable calculation:');
      print('   Bill: ₹$billAmount');
      print('   Available: $availableCoins coins');
      print('   Max from bill (80%): $maxFromBill');
      print('   Max from balance (80%): $maxFromBalance');
      print('   Result: $maxRedeemable coins');

      return maxRedeemable;
    } catch (e) {
      print('❌ Error calculating max redeemable: $e');
      return 0.0; // Safe fallback
    }
  }

  /// Get user's active coin batches for display/debugging
  /// 
  /// Returns list of batches with amount, expiry date, and age.
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
      print('❌ Error fetching user batches: $e');
      return [];
    }
  }
}
