// lib/features/referral/screens/referral_screen.dart
//
// Dedicated Referral Program Screen.
// Shows:
//   - Referral code card with copy + share
//   - Stats (invited, completed, coins earned)
//   - How it works steps
//   - List of referred users and their status

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final _referralProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;
  try {
    final result = await Supabase.instance.client.rpc(
      'get_customer_home_data',
      params: {'firebase_uid': uid},
    );
    final data = result as Map<String, dynamic>?;
    return data?['referral'] as Map<String, dynamic>?;
  } catch (_) {
    return null;
  }
});

final _referralCodeProvider = FutureProvider<String?>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;
  try {
    final result = await Supabase.instance.client
        .from('users')
        .select('referral_code')
        .eq('firebase_uid', uid)
        .maybeSingle();
    return (result as Map<String, dynamic>?)?['referral_code'] as String?;
  } catch (_) {
    return null;
  }
});

// ── Referral Screen ───────────────────────────────────────────────────────────

class ReferralScreen extends ConsumerWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(_referralProvider);
    final codeAsync  = ref.watch(_referralCodeProvider);

    return Scaffold(
      backgroundColor: context.theme.bg,
      appBar: AppBar(
        backgroundColor: context.theme.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: context.theme.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Refer & Earn',
            style: TextStyle(
                color: context.theme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: context.theme.primary,
        backgroundColor: context.theme.card,
        onRefresh: () async {
          ref.invalidate(_referralProvider);
          ref.invalidate(_referralCodeProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

            // ── Hero Banner ───────────────────────────────────────────────
            _HeroBanner(),

            const SizedBox(height: 24),

            // ── Referral Code Card ─────────────────────────────────────────
            codeAsync.when(
              loading: () => const _CodeSkeleton(),
              error: (_, __) => const SizedBox(),
              data: (code) => code == null
                  ? const SizedBox()
                  : _ReferralCodeCard(code: code),
            ),

            const SizedBox(height: 20),

            // ── Stats Row ─────────────────────────────────────────────────
            statsAsync.when(
              loading: () => const _StatsSkeleton(),
              error: (_, __) => const SizedBox(),
              data: (stats) => _StatsRow(stats: stats ?? {}),
            ),

            const SizedBox(height: 28),

            // ── How it Works ──────────────────────────────────────────────
            Text('How it Works',
                style: TextStyle(
                    color: context.theme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
            const SizedBox(height: 14),
            ..._steps(context),

            const SizedBox(height: 28),

            // ── Terms note ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.theme.surfaceAlt.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '• Referral coins are credited after your friend makes their first qualifying payment.\n'
                '• Each referral can only be counted once.\n'
                '• MomoPe reserves the right to modify this program at any time.',
                style: TextStyle(
                    color: context.theme.textMuted,
                    fontSize: 12,
                    height: 1.6),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  List<Widget> _steps(BuildContext context) {
    final steps = [
      {'icon': Icons.share_rounded,        'title': 'Share your code',   'desc': 'Send your unique referral code to a friend via any app.'},
      {'icon': Icons.person_add_outlined,  'title': 'Friend signs up',   'desc': 'They create a MomoPe account and enter your code.'},
      {'icon': Icons.toll_rounded,         'title': 'Both earn coins',   'desc': 'When they make their first payment, you both get bonus Momo Coins!'},
    ];
    return List.generate(steps.length, (i) {
      final s = steps[i];
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: context.theme.coinGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text('${i + 1}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16)),
              ),
            ),
            if (i < steps.length - 1)
              Container(width: 2, height: 32,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: context.theme.surfaceAlt),
          ]),
          const SizedBox(width: 14),
          Expanded(child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(s['icon']! as IconData, color: context.theme.primary, size: 16),
                const SizedBox(width: 6),
                Text(s['title']! as String,
                    style: TextStyle(
                        color: context.theme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
              ]),
              const SizedBox(height: 2),
              Text(s['desc']! as String,
                  style: TextStyle(
                      color: context.theme.textSecondary, fontSize: 12, height: 1.4)),
            ]),
          )),
        ]),
      );
    });
  }
}

// ── Hero banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: context.theme.coinGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: context.theme.primary.withValues(alpha: 0.35),
              blurRadius: 30,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(children: [
        const Icon(Icons.card_giftcard_rounded,
            color: Colors.white, size: 48),
        const SizedBox(height: 12),
        const Text('Invite & Earn',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text(
          'For every friend who joins and pays\nthrough MomoPe, you both earn Momo Coins.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
        ),
      ]),
    );
  }
}

// ── Referral code card ────────────────────────────────────────────────────────

class _ReferralCodeCard extends StatelessWidget {
  final String code;
  const _ReferralCodeCard({required this.code});

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Referral code copied!'),
        backgroundColor: const Color(0xFF2CB78A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _share() {
    Share.share(
      'Join MomoPe and earn coins on every purchase! 🎉\n\n'
      'Use my referral code: $code\n\n'
      'Download the app and start saving!',
      subject: 'Join MomoPe — use my referral code!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: context.theme.primary.withValues(alpha: 0.25)),
      ),
      child: Column(children: [
        Text('Your Referral Code',
            style: TextStyle(
                color: context.theme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Container(
          padding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          decoration: BoxDecoration(
            color: context.theme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: context.theme.primary.withValues(alpha: 0.20),
                style: BorderStyle.solid),
          ),
          child: Text(
            code,
            style: TextStyle(
              color: context.theme.primary,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 6,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _copy(context),
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Copy'),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.theme.primary,
                side: BorderSide(
                    color: context.theme.primary.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _share,
              icon: const Icon(Icons.share_rounded, size: 16),
              label: const Text('Share'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.theme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total     = (stats['total_referrals']     ?? 0) as int;
    final completed = (stats['completed_referrals'] ?? 0) as int;
    final coins     = (stats['total_coins_earned'] as num?)?.toDouble() ?? 0;

    return Row(children: [
      _StatCard(label: 'Invited',   value: '$total',          icon: Icons.person_add_alt_1_outlined, color: context.theme.primary),
      const SizedBox(width: 10),
      _StatCard(label: 'Converted',  value: '$completed',      icon: Icons.check_circle_outline_rounded, color: context.theme.success),
      const SizedBox(width: 10),
      _StatCard(label: 'Coins',    value: '${coins.toStringAsFixed(0)}', icon: Icons.toll_rounded, color: MomoPeTheme.accent),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: context.theme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: context.theme.surfaceAlt.withValues(alpha: 0.6)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: context.theme.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: context.theme.textMuted, fontSize: 11),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

// ── Skeletons ─────────────────────────────────────────────────────────────────

class _CodeSkeleton extends StatelessWidget {
  const _CodeSkeleton();
  @override
  Widget build(BuildContext context) => Container(
      height: 160,
      decoration: BoxDecoration(
          color: context.theme.surfaceAlt,
          borderRadius: BorderRadius.circular(20)));
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();
  @override
  Widget build(BuildContext context) => Row(children: [
    for (int i = 0; i < 3; i++) ...[
      Expanded(
        child: Container(
          height: 80,
          decoration: BoxDecoration(
              color: context.theme.surfaceAlt,
              borderRadius: BorderRadius.circular(16)),
        ),
      ),
      if (i < 2) const SizedBox(width: 10),
    ],
  ]);
}
