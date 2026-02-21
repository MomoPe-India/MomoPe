import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:payu_checkoutpro_flutter/PayUConstantKeys.dart';
import 'package:payu_checkoutpro_flutter/payu_checkoutpro_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'coin_redemption_service.dart';

// ============================================================
// PAYU ENVIRONMENT CONFIGURATION
// ============================================================
// Credentials are injected at build time via --dart-define.
// DO NOT hard-code key or salt here — they must never appear
// in committed source or decompilable release binaries.
//
// Build commands:
//   flutter run  --dart-define=PAYU_KEY=gtKFFx --dart-define=PAYU_SALT=eCwWELxi --dart-define=PAYU_ENV=0
//   flutter build apk --dart-define=PAYU_KEY=<prod_key> --dart-define=PAYU_SALT=<prod_salt> --dart-define=PAYU_ENV=1
// ============================================================

// ignore: do_not_use_environment — credentials injected at build time, not runtime
const String _kPayUKey         = String.fromEnvironment('PAYU_KEY',  defaultValue: '');
const String _kPayUSalt        = String.fromEnvironment('PAYU_SALT', defaultValue: '');
const String _kPayUEnvironment = String.fromEnvironment('PAYU_ENV',  defaultValue: '0');
const String _kWebhookUrl =
    'https://wpnngcuoqtvgwhizkrwt.supabase.co/functions/v1/payu-webhook';

/// PaymentService
///
/// Orchestrates the full payment flow:
/// 1. Creates a transaction record via `initiate-payment` edge function
/// 2. Launches PayU CheckoutPro SDK
/// 3. On success: runs FIFO coin redemption
/// 4. Returns a typed [PaymentResult]
class PaymentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Main entry point — call from PaymentPreviewScreen pay button.
  /// Throws on error; caller should catch and show snackbar.
  Future<PaymentResult> initiatePayment({
    required String merchantId,
    required double grossAmount,
    required double fiatAmount,
    required int coinsToRedeem,
  }) async {
    if (kIsWeb) {
      throw UnimplementedError('Web payment is not supported yet.');
    }

    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final txnId = const Uuid().v4();

    // ─── Step 1: Persist transaction record (status: 'initiated') ────────────
    await _createTransactionRecord(
      transactionId: txnId,
      userId: user.id,
      merchantId: merchantId,
      grossAmount: grossAmount,
      fiatAmount: fiatAmount,
      coinsApplied: coinsToRedeem.toDouble(),
    );

    final userName =
        user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? 'Customer';
    final userEmail = user.email ?? 'customer@momope.com';
    final userPhone = user.phone ?? '9999999999';

    // ─── Step 2: Launch PayU SDK ──────────────────────────────────────────────
    final handler = _PayUPaymentHandler(
      txnId: txnId,
      amount: fiatAmount.toStringAsFixed(2),
      productInfo: 'MomoPe Payment',
      firstName: userName,
      email: userEmail,
      phone: userPhone,
      merchantId: merchantId,
      coinsToRedeem: coinsToRedeem,
    );

    final result = await handler.launch();

    // ─── Step 3: On success — run FIFO coin redemption ────────────────────────
    if (result.status == PaymentStatus.success && coinsToRedeem > 0) {
      try {
        final redemptionService = CoinRedemptionService();
        await redemptionService.redeemCoins(
          userId: user.id,
          coinsToRedeem: coinsToRedeem.toDouble(),
          transactionId: txnId,
        );
      } catch (e) {
        // Coin redemption failure is non-fatal — payment succeeded, log only.
        // TODO: Queue a retry / compensation job if needed.
        debugPrint('⚠️ Coin redemption failed (non-fatal): $e');
      }
    }

    return result;
  }

  // ─── Private: create transaction row via edge function ─────────────────────
  Future<void> _createTransactionRecord({
    required String transactionId,
    required String userId,
    required String merchantId,
    required double grossAmount,
    required double fiatAmount,
    required double coinsApplied,
  }) async {
    debugPrint('📝 Creating transaction record: $transactionId');

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

    if (response.status != 200) {
      throw Exception('Failed to create transaction: ${response.data}');
    }

    debugPrint('✅ Transaction record created successfully');
  }
}

// ============================================================
// _PayUPaymentHandler
//
// Single-use class — implements PayUCheckoutProProtocol.
// Wraps the callback-based SDK in a Completer<PaymentResult>
// so the caller can simply `await handler.launch()`.
// ============================================================
class _PayUPaymentHandler implements PayUCheckoutProProtocol {
  final String txnId;
  final String amount;
  final String productInfo;
  final String firstName;
  final String email;
  final String phone;
  final String merchantId;
  final int coinsToRedeem;

  late final PayUCheckoutProFlutter _sdk;
  final Completer<PaymentResult> _completer = Completer();

  _PayUPaymentHandler({
    required this.txnId,
    required this.amount,
    required this.productInfo,
    required this.firstName,
    required this.email,
    required this.phone,
    required this.merchantId,
    required this.coinsToRedeem,
  }) {
    _sdk = PayUCheckoutProFlutter(this);
  }

  /// Opens the PayU payment sheet and returns the result when done.
  Future<PaymentResult> launch() async {
    // ✅ Guard: fail fast if build-time credentials were not injected.
    // Run with: flutter run --dart-define=PAYU_KEY=... --dart-define=PAYU_SALT=... --dart-define=PAYU_ENV=0
    if (_kPayUKey.isEmpty || _kPayUSalt.isEmpty) {
      throw StateError(
        'PayU credentials missing. Build with:\n'
        '  flutter run --dart-define=PAYU_KEY=<key> --dart-define=PAYU_SALT=<salt> --dart-define=PAYU_ENV=0',
      );
    }

    final paymentParams = {
      PayUPaymentParamKey.key: _kPayUKey,
      PayUPaymentParamKey.transactionId: txnId,
      PayUPaymentParamKey.amount: amount,
      PayUPaymentParamKey.productInfo: productInfo,
      PayUPaymentParamKey.firstName: firstName,
      PayUPaymentParamKey.email: email,
      PayUPaymentParamKey.phone: phone,
      PayUPaymentParamKey.environment: _kPayUEnvironment,
      PayUPaymentParamKey.android_surl: _kWebhookUrl,
      PayUPaymentParamKey.android_furl: _kWebhookUrl,
      PayUPaymentParamKey.ios_surl: _kWebhookUrl,
      PayUPaymentParamKey.ios_furl: _kWebhookUrl,
      PayUPaymentParamKey.additionalParam: {
        PayUAdditionalParamKeys.udf1: merchantId,
        PayUAdditionalParamKeys.udf2: coinsToRedeem.toString(),
      },
    };

    final checkoutConfig = {
      PayUCheckoutProConfigKeys.primaryColor: '#00C4A7', // MomoPe teal
      PayUCheckoutProConfigKeys.secondaryColor: '#0B0F19',
      PayUCheckoutProConfigKeys.merchantName: 'MomoPe',
      PayUCheckoutProConfigKeys.showExitConfirmationOnCheckoutScreen: true,
      PayUCheckoutProConfigKeys.showExitConfirmationOnPaymentScreen: true,
      PayUCheckoutProConfigKeys.merchantSMSPermission: true, // OTP autofill
      PayUCheckoutProConfigKeys.enableSavedCard: true,
    };

    debugPrint('🚀 Launching PayU CheckoutPro SDK...');
    debugPrint('   TxnId: $txnId  |  Amount: ₹$amount  |  Env: $_kPayUEnvironment');

    await _sdk.openCheckoutScreen(
      payUPaymentParams: paymentParams,
      payUCheckoutProConfig: checkoutConfig,
    );

    return _completer.future;
  }

  // ──────────────────────────────────────────────────────────
  // PayUCheckoutProProtocol callbacks
  // ──────────────────────────────────────────────────────────

  /// Called by SDK to request a hash for additional verification steps
  /// (e.g., saved cards lookups). We compute it client-side with our salt.
  @override
  generateHash(Map response) {
    debugPrint('🔐 generateHash called: ${response[PayUHashConstantsKeys.hashName]}');

    final hashString = response[PayUHashConstantsKeys.hashString] as String? ?? '';
    final hashName = response[PayUHashConstantsKeys.hashName] as String? ?? '';

    // Append salt and compute SHA-512
    final fullString = '$hashString$_kPayUSalt';
    final bytes = utf8.encode(fullString);
    final hash = sha512.convert(bytes).toString();

    debugPrint('   Hash computed for: $hashName');

    _sdk.hashGenerated(hash: {hashName: hash});
  }

  @override
  onPaymentSuccess(dynamic response) {
    debugPrint('✅ PayU onPaymentSuccess: $response');

    String? mihpayId;
    if (response is Map) {
      // SDK typically returns a JSON string or a Map
      mihpayId = response['mihpayid']?.toString() ??
          response['payuResponse']?.toString() ??
          'PAYU_${DateTime.now().millisecondsSinceEpoch}';
    }

    if (!_completer.isCompleted) {
      _completer.complete(PaymentResult.success(
        transactionId: txnId,
        payuMihpayId: mihpayId ?? 'PAYU_${DateTime.now().millisecondsSinceEpoch}',
      ));
    }
  }

  @override
  onPaymentFailure(dynamic response) {
    debugPrint('❌ PayU onPaymentFailure: $response');

    String errorMessage = 'Payment failed';
    if (response is Map) {
      errorMessage = response['errorMessage']?.toString() ??
          response['errorMsg']?.toString() ??
          'Payment failed. Please try again.';
    }

    if (!_completer.isCompleted) {
      _completer.complete(PaymentResult.failure(
        transactionId: txnId,
        errorMessage: errorMessage,
      ));
    }
  }

  @override
  onPaymentCancel(Map? response) {
    debugPrint('🚫 PayU onPaymentCancel: $response');

    if (!_completer.isCompleted) {
      _completer.complete(PaymentResult.cancelled(transactionId: txnId));
    }
  }

  @override
  onError(Map? response) {
    debugPrint('💥 PayU onError: $response');

    final message = response?['errorMsg']?.toString() ??
        response?['errorMessage']?.toString() ??
        'An unexpected error occurred';

    if (!_completer.isCompleted) {
      _completer.complete(PaymentResult.failure(
        transactionId: txnId,
        errorMessage: message,
      ));
    }
  }
}

// ============================================================
// PaymentResult
// ============================================================
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

