// lib/features/home/screens/merchant_home_screen.dart
//
// Key features:
// - Shows merchant QR code (UUID as QR)
// - Today's revenue, transaction count, coins redeemed
// - Operational toggle (go on/off duty)
// - Quick KYC status banner

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';

// ── Data providers ────────────────────────────────────────────────────────────
// Use SECURITY DEFINER RPC — no Supabase session exists (Firebase auth only).
// Direct table queries would fail on RLS auth.uid() UUID cast.

final _homeDataProvider = FutureProvider((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;
  final result = await Supabase.instance.client.rpc(
    'get_merchant_home_data',
    params: {'firebase_uid': uid},
  );
  return result as Map<String, dynamic>?;
});

// ── Screen ────────────────────────────────────────────────────────────────────
class MerchantHomeScreen extends ConsumerWidget {
  const MerchantHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(_homeDataProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(_homeDataProvider),
        child: asyncData.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.error_outline, color: MerchantTheme.error, size: 48),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('$e', style: const TextStyle(color: MerchantTheme.error), textAlign: TextAlign.center),
              ),
            ]),
          ),
          data: (data) {
            final merchant = data?['merchant'] as Map<String, dynamic>?;
            if (merchant == null) return _NoKycState();

            final kycStatus = merchant['kyc_status'] as String? ?? 'pending';
            final stats     = data?['stats'] as Map<String, dynamic>? ?? {};

            return CustomScrollView(slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: MerchantTheme.bg,
                title: Row(children: [
                  const Icon(Icons.store, color: MerchantTheme.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    merchant['business_name'] as String? ?? 'My Store',
                    overflow: TextOverflow.ellipsis)),
                ]),
                actions: [
                  if (kycStatus == 'approved')
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Row(children: [
                        Text(
                          merchant['is_operational'] == true ? 'Open' : 'Closed',
                          style: TextStyle(
                            color: merchant['is_operational'] == true
                                ? MerchantTheme.success : MerchantTheme.error,
                            fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                        const SizedBox(width: 6),
                        Switch.adaptive(
                          value: merchant['is_operational'] == true,
                          activeColor: MerchantTheme.success,
                          onChanged: (v) async {
                            final uid = FirebaseAuth.instance.currentUser?.uid;
                            if (uid == null) return;
                            await Supabase.instance.client.rpc(
                              'set_merchant_operational',
                              params: {'firebase_uid': uid, 'p_operational': v},
                            );
                            ref.invalidate(_homeDataProvider);
                          },
                        ),
                      ]),
                    ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(delegate: SliverChildListDelegate([

                  // KYC Status Banner
                  if (kycStatus != 'approved') _KycBanner(
                    status: kycStatus,
                    rejectionReason: merchant['kyc_rejection_reason'] as String?,
                  ),

                  // QR Code + Stats (only when KYC approved)
                  if (kycStatus == 'approved') ...[
                    _QrCard(
                      merchantId: merchant['id'] as String,
                      businessName: merchant['business_name'] as String,
                    ),
                    const SizedBox(height: 20),
                    _StatsRow(
                      total: (stats['total'] as num?)?.toDouble() ?? 0.0,
                      count: (stats['count'] as num?)?.toInt() ?? 0,
                      coins: (stats['coins'] as num?)?.toDouble() ?? 0.0,
                    ),
                  ],

                ])),
              ),
            ]);
          },
        ),
      ),
    );
  }
}

// ── Subwidgets ────────────────────────────────────────────────────────────────

class _NoKycState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.store_outlined, size: 64, color: MerchantTheme.textMuted),
      const SizedBox(height: 16),
      const Text('Welcome to MomoPe Business',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      const Text('Complete KYC to start accepting payments',
          style: TextStyle(color: MerchantTheme.textSecondary)),
      const SizedBox(height: 24),
      ElevatedButton.icon(
        onPressed: () => context.go('/kyc'),   // GoRouter, not Navigator
        icon: const Icon(Icons.verified),
        label: const Text('Begin KYC'),
      ),
    ]));
  }
}

class _KycBanner extends StatelessWidget {
  final String status;
  final String? rejectionReason;
  const _KycBanner({required this.status, this.rejectionReason});
  @override
  Widget build(BuildContext context) {
    final isPending = status == 'pending';
    final color  = isPending
        ? MerchantTheme.primary.withValues(alpha: 0.2)
        : MerchantTheme.error.withValues(alpha: 0.15);
    final border = isPending ? MerchantTheme.primary : MerchantTheme.error;
    final icon   = isPending ? Icons.hourglass_empty : Icons.error_outline;
    final text   = isPending
        ? 'KYC is under review. You\'ll be notified on approval.'
        : 'KYC Rejected: ${rejectionReason ?? 'Please resubmit.'}';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border.withValues(alpha: 0.4))),
      child: Row(children: [
        Icon(icon, color: border, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(text,
            style: TextStyle(color: border, fontSize: 13, fontWeight: FontWeight.w500))),
      ]),
    );
  }
}

class _QrCard extends StatelessWidget {
  final String merchantId, businessName;
  const _QrCard({required this.merchantId, required this.businessName});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: MerchantTheme.card, borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        const Text('Your Payment QR',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 4),
        const Text('Customers scan this to pay',
            style: TextStyle(color: MerchantTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: QrImageView(data: merchantId, size: 180, version: QrVersions.auto),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: MerchantTheme.primary.withValues(alpha: 0.15),
              foregroundColor: MerchantTheme.primary, elevation: 0),
          onPressed: () => Share.share(
              'Pay at $businessName using MomoPe: merchant_id=$merchantId'),
          icon: const Icon(Icons.share, size: 18),
          label: const Text('Share QR'),
        ),
      ]),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final double total, coins;
  final int count;
  const _StatsRow({required this.total, required this.count, required this.coins});
  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.##');
    return Row(children: [
      Expanded(child: _StatCard(label: "Today's Revenue", value: '₹${fmt.format(total)}', icon: Icons.currency_rupee)),
      const SizedBox(width: 12),
      Expanded(child: _StatCard(label: 'Transactions', value: '$count', icon: Icons.receipt_long)),
      const SizedBox(width: 12),
      Expanded(child: _StatCard(label: 'Coins Used', value: '${coins.toStringAsFixed(0)}', icon: Icons.toll)),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final String label, value; final IconData icon;
  const _StatCard({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    decoration: BoxDecoration(color: MerchantTheme.card, borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: MerchantTheme.primary, size: 18),
      const SizedBox(height: 8),
      Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: MerchantTheme.textSecondary, fontSize: 10)),
    ]),
  );
}
