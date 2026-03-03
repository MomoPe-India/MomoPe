// lib/features/payment/screens/payment_screen.dart
//
// Customer enters bill amount, adjusts coin slider, then taps Pay.
// Payment flow:
//   1. Calls initiate-payment edge fn → gets PayU params (server-signed hash)
//   2. Launches PayU CheckoutPro SDK via openCheckoutScreen()
//   3. SDK callbacks route to /payment-result with success/failure/pending status.

import 'dart:convert';
import 'package:crypto/crypto.dart';  // SHA-512 for PayU generateHash callback

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:payu_checkoutpro_flutter/payu_checkoutpro_flutter.dart';
import 'package:payu_checkoutpro_flutter/PayUConstantKeys.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/models/models.dart';
import '../../../shared/widgets/momope_button.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String merchantId;
  const PaymentScreen({super.key, required this.merchantId});
  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen>
    implements PayUCheckoutProProtocol {

  // ── State ─────────────────────────────────────────────────────────────────
  final _amountCtrl = TextEditingController();
  double _grossAmount     = 0;
  double _coinsToUse      = 0;
  double _maxRedeemable   = 0;
  double _availableBalance = 0;
  MerchantModel? _merchant;
  bool _loading    = false;
  bool _initiating = false;

  /// PayU SDK instance — created once per payment, stored so hashGenerated() works.
  PayUCheckoutProFlutter? _payuCheckout;

  /// Saved after initiate-payment so SDK callbacks can build the result extra.
  Map<String, dynamic>? _pendingPaymentData;

  final _fmt = NumberFormat('#,##0.##');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  // ── Load merchant + balance ───────────────────────────────────────────────

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final results = await Future.wait([
        Supabase.instance.client.rpc('get_merchant_public',
            params: {'merchant_id': widget.merchantId}),
        Supabase.instance.client.rpc('get_customer_coin_balance',
            params: {'firebase_uid': uid}),
      ]);

      final merchantData = results[0] as Map<String, dynamic>?;
      final balanceData  = results[1] as Map<String, dynamic>?;

      if (merchantData == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Merchant not found or not accepting payments.')));
        return;
      }

      setState(() {
        _merchant         = MerchantModel.fromMap(merchantData);
        _availableBalance = (balanceData?['available_coins'] as num?)?.toDouble() ?? 0.0;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: context.theme.error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Coin slider ───────────────────────────────────────────────────────────

  void _onAmountChanged(String val) {
    final amount = double.tryParse(val) ?? 0;
    setState(() {
      _grossAmount   = amount;
      _maxRedeemable = [
        amount * AppConstants.maxRedemptionPercent,
        _availableBalance,
      ].reduce((a, b) => a < b ? a : b);
      _coinsToUse = _coinsToUse.clamp(0, _maxRedeemable);
    });
  }

  // ── Initiate payment ──────────────────────────────────────────────────────

  Future<void> _initiatePayment() async {
    if (_grossAmount < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter bill amount (min ₹1)')));
      return;
    }
    final fiatAmount = _grossAmount - _coinsToUse;
    if (fiatAmount < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cash portion must be at least ₹1')));
      return;
    }

    setState(() => _initiating = true);
    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken(true);
      final response = await http.post(
        Uri.parse('${AppConstants.supabaseUrl}/functions/v1/initiate-payment'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type':  'application/json',
          'apikey':        AppConstants.supabaseAnonKey,
        },
        body: jsonEncode({
          'merchant_id':  widget.merchantId,
          'gross_amount': _grossAmount,
          'coins_to_use': _coinsToUse,
        }),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        throw Exception(body['error'] ?? 'Payment initiation failed');
      }

      final d = body['data'] as Map<String, dynamic>;
      _pendingPaymentData = d;

      // IMPORTANT: The PayU Flutter plugin explicitly maps these PayUPaymentParamKey
      // constants to the native keys (txnid, productinfo, etc.). If we pass raw
      // string keys, the plugin ignores them, sending nulls to native!
      final payUPaymentParams = <String, dynamic>{
        PayUPaymentParamKey.key:           d['key'],
        PayUPaymentParamKey.transactionId: d['payu_txnid'],
        PayUPaymentParamKey.amount:        d['amount'].toString(),
        PayUPaymentParamKey.productInfo:   d['productinfo'],
        PayUPaymentParamKey.firstName:     d['firstname'],
        PayUPaymentParamKey.email:         d['email'],
        PayUPaymentParamKey.phone:         (d['phone'] ?? '').toString(),
        PayUPaymentParamKey.ios_surl:      d['surl'],
        PayUPaymentParamKey.ios_furl:      d['furl'],
        PayUPaymentParamKey.android_surl:  d['surl'],
        PayUPaymentParamKey.android_furl:  d['furl'],
        PayUPaymentParamKey.environment:   AppConstants.payuEnv.toString(),
        PayUPaymentParamKey.userCredential: d['userCredential'] ?? 'default',
        PayUPaymentParamKey.additionalParam: <String, dynamic>{
          PayUAdditionalParamKeys.udf1:    (d['udf1'] ?? '').toString(),
          "payment": d['payment_hash'],
          "payment_related_details_for_mobile_sdk": d['prd_hash'],
          "vas_for_mobile_sdk": d['vas_hash'],
        },
      };

      final payUCheckoutProConfig = <dynamic, dynamic>{
        PayUCheckoutProConfigKeys.primaryColor:   '#6C63FF', // context.theme.primary hex
        PayUCheckoutProConfigKeys.secondaryColor: '#FFFFFF',
        PayUCheckoutProConfigKeys.merchantName:   'MomoPe',
        PayUCheckoutProConfigKeys.showExitConfirmationOnCheckoutScreen: true,
        PayUCheckoutProConfigKeys.showExitConfirmationOnPaymentScreen:  true,
        PayUCheckoutProConfigKeys.autoSelectOtp:  true,
        // Disable saved cards in initial release (needs hash generation endpoint)
        PayUCheckoutProConfigKeys.enableSavedCard: false,
      };

      // Instantiate SDK with `this` as protocol (required for callbacks)
      _payuCheckout = PayUCheckoutProFlutter(this);
      await _payuCheckout!.openCheckoutScreen(
        payUPaymentParams:    payUPaymentParams,
        payUCheckoutProConfig: payUCheckoutProConfig,
      );

      // SDK is now showing. Callbacks handle all further navigation.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: context.theme.error));
        setState(() => _initiating = false);
      }
    }
  }

  // ── PayUCheckoutProProtocol ───────────────────────────────────────────────

  @override
  generateHash(Map response) {
    // The PayU SDK calls this for EVERY internal API hash it needs
    // (get_sdk_configuration, get_checkout_details, quickPayEvent, etc.).
    // We MUST compute SHA512(hashString + SALT) and call hashGenerated() back.
    final hashStr  = (response[PayUHashConstantsKeys.hashString] as String?) ?? '';
    final hashName = (response[PayUHashConstantsKeys.hashName]   as String?) ?? '';

    if (hashStr.isEmpty || hashName.isEmpty) {
      debugPrint('[PayU] generateHash: empty hashString or hashName — skipping');
      return;
    }

    debugPrint('[PayU] generateHash: $hashName -> raw string requested: $hashStr');

    // PayU format requires a pipe before the salt if it doesn't already have one
    final input = hashStr.endsWith('|') 
        ? '$hashStr${AppConstants.payuSalt}' 
        : '$hashStr|${AppConstants.payuSalt}';

    final bytes  = utf8.encode(input);
    final digest = sha512.convert(bytes);
    final hash   = digest.toString();

    debugPrint('[PayU] generateHash: $hashName -> computed hash (len=${hash.length})');

    // hashGenerated expects {hashName: computedHash}
    _payuCheckout?.hashGenerated(hash: {hashName: hash});
  }

  @override
  onPaymentSuccess(dynamic response) {
    if (!mounted) return;
    // Webhook processes async (~1-3s) — navigate now; transaction history shows final coins.
    context.go('/payment-result', extra: {
      ...(_pendingPaymentData ?? {}),
      'status': 'success',
    });
  }

  @override
  onPaymentFailure(dynamic response) {
    if (!mounted) return;
    context.go('/payment-result', extra: {
      ...(_pendingPaymentData ?? {}),
      'status': 'failed',
    });
  }

  @override
  onPaymentCancel(Map? response) {
    if (!mounted) return;
    setState(() => _initiating = false);
    final txnInitiated = response?[PayUConstants.isTxnInitiated] == true ||
                         response?['isTxnInitiated'] == true;
    if (txnInitiated) {
      // Payment was started but user cancelled — coins remain locked temporarily.
      context.go('/payment-result', extra: {
        ...(_pendingPaymentData ?? {}),
        'status': 'pending',
      });
    }
    // Not initiated → user backed out before paying. Stay on payment screen.
  }

  @override
  onError(Map? response) {
    if (!mounted) return;
    setState(() => _initiating = false);
    final msg = response?['errorMsg'] ?? response?['errorMessage'] ?? 'Unknown error';
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment gateway error: $msg'),
            backgroundColor: context.theme.error));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final fiatAmount = (_grossAmount - _coinsToUse).clamp(0.0, double.infinity);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(_merchant?.businessName ?? 'Payment')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Merchant card ──────────────────────────────────────────────
            if (_merchant != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: context.theme.card,
                    borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                        color: context.theme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.storefront_rounded, color: context.theme.primary, size: 22)),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_merchant!.businessName,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    Text(_merchant!.category.replaceAll('_', ' & '),
                        style: TextStyle(color: context.theme.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                  ]),
                ]),
              ),

            const SizedBox(height: 24),

            // ── Bill amount ────────────────────────────────────────────────
            Text('Bill Amount',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13,
                    color: context.theme.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              decoration: const InputDecoration(
                prefixText: '₹ ',
                prefixStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                hintText: '0',
              ),
              onChanged: _onAmountChanged,
            ),

            // ── Coin slider ────────────────────────────────────────────────
            if (_grossAmount > 0 && _availableBalance > 0) ...[
              const SizedBox(height: 28),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Use Momo Coins',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13,
                        color: context.theme.textSecondary)),
                Text('${_coinsToUse.toStringAsFixed(0)} / ${_fmt.format(_maxRedeemable)} max',
                    style: TextStyle(color: context.theme.accent, fontWeight: FontWeight.w700)),
              ]),
              Slider(
                value: _coinsToUse,
                min: 0,
                max: _maxRedeemable <= 0 ? 1 : _maxRedeemable,
                activeColor: context.theme.accent,
                inactiveColor: context.theme.surfaceAlt,
                onChanged: (v) => setState(() => _coinsToUse = v.roundToDouble()),
              ),
              Text('${_fmt.format(_availableBalance)} coins available',
                  style: TextStyle(fontSize: 13, color: context.theme.textSecondary, fontWeight: FontWeight.w600)),
            ],

            // ── Breakdown card ─────────────────────────────────────────────
            if (_grossAmount > 0) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: context.theme.card,
                    borderRadius: BorderRadius.circular(14)),
                child: Column(children: [
                  _Row('Bill total', '₹${_fmt.format(_grossAmount)}'),
                  if (_coinsToUse > 0)
                    _Row('Coins redeemed', '-₹${_coinsToUse.toStringAsFixed(0)}',
                        highlight: true),
                  const Divider(height: 24),
                  _Row('You pay', '₹${_fmt.format(fiatAmount)}', large: true),
                ]),
              ),
            ],

            const SizedBox(height: 32),

            MomoPeButton(
              label: _grossAmount > 0
                  ? 'Pay ₹${_fmt.format(fiatAmount)}'
                  : 'Enter Amount to Pay',
              onPressed: _initiating ? null : _initiatePayment,
              isLoading: _initiating,
            ),

            if (_initiating)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Center(
                  child: Text('Opening payment gateway…',
                      style: TextStyle(color: context.theme.textMuted, fontSize: 12)),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

// ── Helper ────────────────────────────────────────────────────────────────────

class _Row extends StatelessWidget {
  final String label, value;
  final bool highlight, large;
  const _Row(this.label, this.value, {this.highlight = false, this.large = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label,
          style: TextStyle(
              color: large ? context.theme.textPrimary : context.theme.textSecondary,
              fontSize: large ? 16 : 14,
              fontWeight: large ? FontWeight.w700 : FontWeight.w400)),
      Text(value,
          style: TextStyle(
              color: highlight ? context.theme.success : context.theme.textPrimary,
              fontSize: large ? 20 : 14,
              fontWeight: large ? FontWeight.w800 : FontWeight.w600)),
    ]),
  );
}
