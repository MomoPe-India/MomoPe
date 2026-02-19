import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:payu_checkoutpro_flutter/payu_checkoutpro_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'coin_redemption_service.dart';

class PaymentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _merchantKey = 'gtKFFx';
  static const String _merchantSalt = 'eCwWELxi';

  Future<PaymentResult> initiatePayment({
    required String merchantId,
    required double grossAmount,
    required double fiatAmount,
    required int coinsToRedeem,
  }) async {
    try {
      print('🔐 Initiating payment...');
      print('   Merchant: $merchantId');
      print('   Gross: ₹$grossAmount');
      print('   Fiat: ₹$fiatAmount');
      print('   Coins: $coinsToRedeem');

      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final txnId = const Uuid().v4();

      await _createTransaction(
        transactionId: txnId,
        userId: user.id,
        merchantId: merchantId,
        grossAmount: grossAmount,
        fiatAmount: fiatAmount,
        coinsApplied: coinsToRedeem.toDouble(),
      );

      print('   Transaction created: $txnId');

      final hash = _generateHash(
        txnId: txnId,
        amount: fiatAmount.toStringAsFixed(2),
        productInfo: 'MomoPe Payment',
        firstName: user.userMetadata?['name'] ?? 'Customer',
        email: user.email ?? 'customer@momope.com',
      );

      final paymentParams = {
        'key': _merchantKey,
        'txnid': txnId,
        'amount': fiatAmount.toStringAsFixed(2),
        'productinfo': 'MomoPe Payment',
        'firstname': user.userMetadata?['name'] ?? 'Customer',
        'email': user.email ?? 'customer@momope.com',
        'phone': user.phone ?? '9999999999',
        'surl': 'https://wpnngcuoqtvgwhizkrwt.supabase.co/functions/v1/payu-webhook',
        'furl': 'https://wpnngcuoqtvgwhizkrwt.supabase.co/functions/v1/payu-webhook',
        'hash': hash,
        'udf1': merchantId,
        'udf2': coinsToRedeem.toString(),
      };

      print('   Launching PayU...');

      if (kIsWeb) {
        throw UnimplementedError('Web payment not yet implemented');
      } else {
        // Mock payment for testing (replace with real PayU SDK when production keys available)
        await Future.delayed(const Duration(seconds: 2));

        final payuMihpayId = 'TEST_${DateTime.now().millisecondsSinceEpoch}';

        // ✅ FIFO Coin Redemption - Deduct coins from oldest batches first
        if (coinsToRedeem > 0) {
          try {
            print('🪙 Initiating FIFO coin redemption...');
            final redemptionService = CoinRedemptionService();
            
            final coinTxnIds = await redemptionService.redeemCoins(
              userId: user.id,
              coinsToRedeem: coinsToRedeem.toDouble(),
              transactionId: txnId,
            );

            print('   ✅ ${coinTxnIds.length} coin_transactions created');
            print('   ✅ Coins redeemed successfully via FIFO');
          } catch (e) {
            print('   ❌ Coin redemption failed: $e');
            // Consider: Should we fail the entire payment or just log the error?
            // For now, we log but don't fail the payment (fiat was already processed)
            // TODO: Implement compensation logic (refund or retry)
          }
        }

        return PaymentResult.success(
          transactionId: txnId,
          payuMihpayId: payuMihpayId,
        );
      }
    } catch (e) {
      print('❌ Payment initiation error: $e');
      rethrow;
    }
  }

  String _generateHash({
    required String txnId,
    required String amount,
    required String productInfo,
    required String firstName,
    required String email,
  }) {
    final hashString =
        '$_merchantKey|$txnId|$amount|$productInfo|$firstName|$email|||||||||||$_merchantSalt';

    final bytes = utf8.encode(hashString);
    final hash = sha512.convert(bytes);

    print('   Hash generated: ${hash.toString().substring(0, 20)}...');
    return hash.toString();
  }

  Future<void> _createTransaction({
    required String transactionId,
    required String userId,
    required String merchantId,
    required double grossAmount,
    required double fiatAmount,
    required double coinsApplied,
  }) async {
    final session = _supabase.auth.currentSession;
    if (session == null) {
      throw Exception('No active session');
    }

    print('   🔐 Calling initiate-payment edge function...');
    print('   📊 Transaction ID: $transactionId');
    print('   💰 Amount: ₹$fiatAmount');
    
    // ✅ COMPREHENSIVE DEBUGGING
    print('   🔑 Session user: ${session.user.id}');
    print('   🔑 Session email: ${session.user.email}');
    print('   ⏰ JWT expires at: ${DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)}');
    print('   ⏰ Current time: ${DateTime.now()}');
    print('   🔑 JWT token (first 100 chars): ${session.accessToken.substring(0, 100)}...');

    // Try with SDK's native invoke method
    try {
      final response = await _supabase.functions.invoke(
        'initiate-payment',
        body: {
          'transactionId': transactionId,
          'merchantId': merchantId,
          'grossAmount': grossAmount,
          'fiatAmount': fiatAmount,
          'coinsApplied': coinsApplied,
        },
      );

      print('   📡 Response status: ${response.status}');
      print('   📡 Response data: ${response.data}');

      if (response.status == 200) {
        print('   ✅ Transaction created successfully!');
      } else {
        print('   ❌ Error: ${response.data}');
        throw Exception('Transaction failed: ${response.data}');
      }
    } catch (e) {
      print('   ❌ Exception calling edge function: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getTransactionStatus(
      String transactionId) async {
    final response = await _supabase
        .from('transactions')
        .select('*')
        .eq('id', transactionId)
        .maybeSingle();

    return response;
  }
}

class PaymentResult {
  final String transactionId;
  final PaymentStatus status;
  final String? payuMihpayId;
  final String? errorMessage;

  PaymentResult._({
    required this.transactionId,
    required this.status,
    this.payuMihpayId,
    this.errorMessage,
  });

  factory PaymentResult.success({
    required String transactionId,
    required String payuMihpayId,
  }) {
    return PaymentResult._(
      transactionId: transactionId,
      status: PaymentStatus.success,
      payuMihpayId: payuMihpayId,
    );
  }

  factory PaymentResult.failure({
    required String transactionId,
    required String errorMessage,
  }) {
    return PaymentResult._(
      transactionId: transactionId,
      status: PaymentStatus.failure,
      errorMessage: errorMessage,
    );
  }

  factory PaymentResult.cancelled({required String transactionId}) {
    return PaymentResult._(
      transactionId: transactionId,
      status: PaymentStatus.cancelled,
    );
  }
}

enum PaymentStatus {
  success,
  failure,
  cancelled,
}
