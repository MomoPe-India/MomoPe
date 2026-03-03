// lib/features/payment/screens/payment_result_screen.dart
//
// Shown immediately after PayU SDK reports success/failure/cancel.
// On success, polls Supabase every 2 s (up to 15 s) to wait for the
// webhook to finish and then shows the real coins-earned value.
//
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme.dart';

class PaymentResultScreen extends StatefulWidget {
  /// `data` comes from `_pendingPaymentData` in payment_screen.dart, merged with status:
  /// {
  ///   "transaction_id": "<uuid>",
  ///   "status": "success" | "failed" | "pending",
  ///   "gross_amount": 100.0,
  ///   "fiat_amount": 100.0,
  ///   "coins_locked": 0.0,
  ///   "merchant_name": "...",
  /// }
  final Map<String, dynamic> data;

  const PaymentResultScreen({super.key, required this.data});

  @override
  State<PaymentResultScreen> createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends State<PaymentResultScreen> {
  // Resolved from DB after webhook fires
  double? _coinsEarned;
  double? _newBalance;
  String  _resolvedStatus = 'initiated';

  Timer?  _pollTimer;
  int     _pollCount = 0;
  static const int _maxPolls = 30; // 30 × 2 s = 60 s max wait

  @override
  void initState() {
    super.initState();
    _resolvedStatus = widget.data['status'] as String? ?? 'initiated';

    // Only poll when PayU SDK reports success — wait for webhook to process
    if (_resolvedStatus == 'success') {
      _startPolling();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // First check immediately, then every 2 s
    _pollOnce();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _pollOnce());
  }

  Future<void> _pollOnce() async {
    if (!mounted) return;
    _pollCount++;

    final txId = widget.data['transaction_id'] as String?;
    if (txId == null || txId.isEmpty) {
      _pollTimer?.cancel();
      return;
    }

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      debugPrint('[PaymentResult] Poll #$_pollCount for txId=$txId uid=$uid');

      // Use the RPC that's already secured by SECURITY DEFINER
      final result = await Supabase.instance.client.rpc(
        'get_transaction_result',
        params: {'p_transaction_id': txId, 'p_user_id': uid},
      );

      debugPrint('[PaymentResult] Poll #$_pollCount raw result: $result');

      if (result != null && result is Map) {
        final status      = result['status'] as String?;
        final coinsEarned = (result['coins_earned'] as num?)?.toDouble();
        final newBalance  = (result['new_balance']  as num?)?.toDouble();

        if (status == 'success' || status == 'failed') {
          _pollTimer?.cancel();
          if (mounted) {
            setState(() {
              _resolvedStatus = status ?? 'failed';
              _coinsEarned    = coinsEarned;
              _newBalance     = newBalance;
            });
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('[PaymentResult] poll error: $e');
    }

    // Give up after max polls — show base success screen without coins
    if (_pollCount >= _maxPolls) {
      _pollTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.##');

    final rawStatus    = widget.data['status'] as String? ?? 'pending';
    // Use resolved (DB) status once available, else fall back to SDK status
    final status       = _resolvedStatus.isNotEmpty ? _resolvedStatus : rawStatus;
    final isSuccess    = status == 'success';
    final isPending    = status == 'pending' || status == 'initiated';

    final grossAmount  = (widget.data['gross_amount'] as num?)?.toDouble() ?? 0;
    final fiatAmount   = (widget.data['fiat_amount']  as num?)?.toDouble() ?? grossAmount;
    final coinsLocked  = (widget.data['coins_locked'] as num?)?.toDouble() ?? 0;
    final coinsEarned  = _coinsEarned;       // null until webhook is confirmed
    final newBalance   = _newBalance;
    final txId         = widget.data['transaction_id'] as String? ?? '';
    final merchantName = widget.data['merchant_name']  as String? ?? 'Merchant';

    // Polling indicator: still waiting?
    final stillWaiting = isSuccess && coinsEarned == null && _pollCount < _maxPolls;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),

                      // ── Status Icon ─────────────────────────────────────────
                      _StatusIcon(isSuccess: isSuccess, isPending: isPending),
                      const SizedBox(height: 24),

                      // ── Status Title ────────────────────────────────────────
                      Text(
                        isPending
                          ? 'Processing…'
                          : isSuccess
                            ? 'Payment Successful!'
                            : 'Payment Failed',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isPending
                            ? context.theme.textSecondary
                            : isSuccess
                              ? context.theme.success
                              : context.theme.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isPending
                          ? 'Your payment is being confirmed'
                          : isSuccess
                            ? 'Paid to $merchantName'
                            : 'Something went wrong. No money was deducted.',
                        style: TextStyle(color: context.theme.textSecondary, fontSize: 15),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 36),

                      // ── Amount Card ─────────────────────────────────────────
                      _DetailCard(children: [
                        _Row('Bill amount',  '₹${fmt.format(grossAmount)}'),
                        if (coinsLocked > 0)
                          _Row('Coins redeemed', '-${coinsLocked.toStringAsFixed(0)}',
                            valueColor: context.theme.success),
                        const Divider(height: 28),
                        _Row('Amount paid', '₹${fmt.format(fiatAmount)}',
                          bold: true, fontSize: 20),
                      ]),

                      if (isSuccess) ...[
                        const SizedBox(height: 16),

                        // ── Coins Earned Card ──────────────────────────────
                        _DetailCard(
                          gradient: context.theme.coinGradient,
                          children: [
                            Row(children: [
                              const Icon(Icons.toll, color: Colors.white70, size: 18),
                              const SizedBox(width: 6),
                              const Text('Momo Coins Earned',
                                style: TextStyle(color: Colors.white70, fontSize: 13)),
                            ]),
                            const SizedBox(height: 8),
                            if (stillWaiting)
                              const Row(children: [
                                SizedBox(width: 16, height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white70)),
                                SizedBox(width: 10),
                                Text('Calculating coins…',
                                  style: TextStyle(color: Colors.white70, fontSize: 20)),
                              ])
                            else
                              Text('+${(coinsEarned ?? 0).toStringAsFixed(0)} coins',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32, fontWeight: FontWeight.w800)),
                            if (newBalance != null) ...[
                              const SizedBox(height: 4),
                              Text('New balance: ${fmt.format(newBalance)} coins',
                                style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            ],
                          ],
                        ),
                      ],

                      const SizedBox(height: 16),

                      // ── Transaction ID ──────────────────────────────────────
                      if (txId.isNotEmpty)
                        _DetailCard(children: [
                          Text('Transaction ID',
                            style: TextStyle(color: context.theme.textSecondary, fontSize: 12)),
                          const SizedBox(height: 4),
                          SelectableText(
                            txId,
                            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                          ),
                        ]),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // ── Bottom CTA ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(children: [
                  if (isPending)
                    OutlinedButton(
                      onPressed: () => context.go('/transactions'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: const Text('View Status in History'),
                    )
                  else
                    ElevatedButton(
                      onPressed: () => context.go('/home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSuccess ? context.theme.primary : context.theme.surfaceAlt,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: Text(isSuccess ? 'Back to Home' : 'Try Again'),
                    ),
                  if (!isPending) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/transactions'),
                      child: const Text('View Transaction History'),
                    ),
                  ],
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _StatusIcon extends StatelessWidget {
  final bool isSuccess, isPending;
  const _StatusIcon({required this.isSuccess, required this.isPending});

  @override
  Widget build(BuildContext context) {
    final color = isPending
      ? context.theme.textSecondary
      : isSuccess ? context.theme.success : context.theme.error;
    final icon  = isPending
      ? Icons.hourglass_top_rounded
      : isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return Container(
      width: 96, height: 96,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 52, color: color),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final List<Widget> children;
  final Gradient? gradient;
  const _DetailCard({required this.children, this.gradient});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: gradient == null ? context.theme.card : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );
}

class _Row extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final bool bold;
  final double fontSize;
  const _Row(this.label, this.value,
    {this.valueColor, this.bold = false, this.fontSize = 14});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(
        color: context.theme.textSecondary, fontSize: fontSize)),
      Text(value, style: TextStyle(
        color: valueColor ?? context.theme.textPrimary,
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
    ]),
  );
}
