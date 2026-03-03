// lib/features/transactions/screens/merchant_transactions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../app/app.dart';

class MerchantTransactionsScreen extends ConsumerWidget {
  const MerchantTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txnsAsync = ref.watch(_merchantTxnProvider);
    final dateFmt = DateFormat('dd MMM, hh:mm a');
    final moneyFmt = NumberFormat('#,##0.##');

    return Scaffold(
      appBar: AppBar(title: const Text('Payments Received')),
      body: txnsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: MerchantTheme.error))),
        data: (txns) {
          if (txns.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.receipt_long, size: 56, color: MerchantTheme.textMuted),
              const SizedBox(height: 12),
              const Text('No payments yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              const Text('Share your QR code to start accepting payments.',
                style: TextStyle(color: MerchantTheme.textSecondary, fontSize: 13)),
            ]));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: txns.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final t = txns[i];
              final statusColor = switch (t['status']) {
                'success' => MerchantTheme.success,
                'failed'  => MerchantTheme.error,
                _         => MerchantTheme.textMuted,
              };
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: MerchantTheme.card, borderRadius: BorderRadius.circular(14)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('₹${moneyFmt.format(t['gross_amount'])}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                      child: Text((t['status'] as String).toUpperCase(),
                          style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700))),
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    Text('Fiat: ₹${moneyFmt.format(t['fiat_amount'])}', style: const TextStyle(color: MerchantTheme.textSecondary, fontSize: 13)),
                    if ((t['coins_applied'] as num) > 0) ...[
                      const Text(' · ', style: TextStyle(color: MerchantTheme.textMuted)),
                      Text('Coins: ${(t['coins_applied'] as num).toStringAsFixed(0)}', style: const TextStyle(color: MerchantTheme.textSecondary, fontSize: 13)),
                    ],
                  ]),
                  const SizedBox(height: 4),
                  Text(dateFmt.format(DateTime.parse(t['created_at'] as String).toLocal()),
                      style: const TextStyle(color: MerchantTheme.textMuted, fontSize: 12)),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}

// SECURITY DEFINER RPC — single call, no UUID/RLS errors, filters by merchant's own transactions.
final _merchantTxnProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return [];
  final data = await Supabase.instance.client.rpc(
    'get_merchant_transactions',
    params: {'firebase_uid': uid},
  );
  final list = data as List? ?? [];
  return list.cast<Map<String, dynamic>>();
});
