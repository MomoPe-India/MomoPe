// lib/features/profile/screens/merchant_profile_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/app.dart';

class MerchantProfileScreen extends ConsumerWidget {
  const MerchantProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder(
        future: _loadProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data;
          final userName     = data?['name']          as String? ?? 'Merchant';
          final phone        = data?['phone']         as String? ?? '';
          final businessName = data?['business_name'] as String? ?? '';
          final kycStatus    = data?['kyc_status']    as String? ?? 'not_submitted';

          return ListView(padding: const EdgeInsets.all(20), children: [
            Center(child: Column(children: [
              Container(width: 72, height: 72,
                decoration: BoxDecoration(color: MerchantTheme.primary, shape: BoxShape.circle),
                child: Center(child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'M',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)))),
              const SizedBox(height: 12),
              Text(userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(businessName.isNotEmpty ? businessName : 'No business set',
                  style: const TextStyle(color: MerchantTheme.textSecondary)),
              if (phone.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('+91 $phone', style: const TextStyle(color: MerchantTheme.textMuted, fontSize: 13)),
              ],
              const SizedBox(height: 8),
              _KycChip(status: kycStatus),
            ])),

            const SizedBox(height: 32),

            _Section('Account', [
              _Tile(icon: Icons.lock_outline,   label: 'Change PIN', onTap: () => context.push('/forgot-pin')),
            ]),

            const SizedBox(height: 20),

            _Section('Sign Out', [
              _Tile(
                icon: Icons.logout, label: 'Sign Out', color: MerchantTheme.error,
                onTap: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: MerchantTheme.card,
                      title: const Text('Sign Out?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(context, true),
                          child: const Text('Sign Out', style: TextStyle(color: MerchantTheme.error))),
                      ],
                    ),
                  );
                  if (ok == true && context.mounted) {
                    await FirebaseAuth.instance.signOut();
                  }
                },
              ),
            ]),
          ]);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return {};
    // SECURITY DEFINER RPC — avoids UUID/RLS errors without Supabase session
    final data = await Supabase.instance.client.rpc(
      'get_merchant_profile_data',
      params: {'firebase_uid': uid},
    ) as Map<String, dynamic>?;
    return data ?? {};
  }
}

class _KycChip extends StatelessWidget {
  final String status;
  const _KycChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'approved'  => ('KYC Approved ✓',   MerchantTheme.success),
      'pending'   => ('KYC Under Review',  MerchantTheme.primary),
      'rejected'  => ('KYC Rejected',      MerchantTheme.error),
      _           => ('KYC Not Submitted', MerchantTheme.textMuted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8)),
      child: Text(label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _Section extends StatelessWidget {
  final String title; final List<Widget> children;
  const _Section(this.title, this.children);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title.toUpperCase(),
      style: const TextStyle(color: MerchantTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
    const SizedBox(height: 8),
    Container(decoration: BoxDecoration(color: MerchantTheme.card, borderRadius: BorderRadius.circular(14)),
      child: Column(children: children)),
  ]);
}

class _Tile extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap; final Color? color;
  const _Tile({required this.icon, required this.label, required this.onTap, this.color});
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: color ?? MerchantTheme.textPrimary, size: 20),
    title: Text(label, style: TextStyle(color: color ?? MerchantTheme.textPrimary, fontWeight: FontWeight.w500)),
    trailing: const Icon(Icons.chevron_right, color: MerchantTheme.textMuted, size: 18),
    onTap: onTap,
  );
}
