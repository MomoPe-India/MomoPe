import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/premium_button.dart';

// ─────────────────────────────────────────────────────────────
// Provider: fetch user's referral stats from Supabase
// ─────────────────────────────────────────────────────────────

final referralStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return {'friends_invited': 0, 'coins_earned_from_referrals': 0};

  final response = await Supabase.instance.client
      .from('referral_stats')
      .select('friends_invited, friends_rewarded, coins_earned_from_referrals')
      .eq('user_id', user.id)
      .maybeSingle();

  return response ?? {'friends_invited': 0, 'friends_rewarded': 0, 'coins_earned_from_referrals': 0};
});

final referralCodeProvider = FutureProvider<String?>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return null;

  final response = await Supabase.instance.client
      .from('users')
      .select('referral_code')
      .eq('id', user.id)
      .single();

  return response['referral_code'] as String?;
});

// ─────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────

class ReferralScreen extends ConsumerWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(referralStatsProvider);
    final codeAsync  = ref.watch(referralCodeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.primaryTeal,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _HeroBanner(),
            ),
            title: const Text(
              'Refer & Earn',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),

          // ── Body Content ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Stats Row ────────────────────────────
                  statsAsync.when(
                    loading: () => const _StatsRowShimmer(),
                    error:   (_, __) => const SizedBox.shrink(),
                    data:    (stats) => _StatsRow(stats: stats),
                  ),
                  const SizedBox(height: 24),

                  // ── How it works ─────────────────────────
                  _SectionLabel(label: 'HOW IT WORKS'),
                  const SizedBox(height: 12),
                  const _HowItWorksCard(),
                  const SizedBox(height: 24),

                  // ── Your Code ────────────────────────────
                  _SectionLabel(label: 'YOUR CODE'),
                  const SizedBox(height: 12),
                  codeAsync.when(
                    loading: () => const _CodeCardShimmer(),
                    error:   (_, __) => const SizedBox.shrink(),
                    data:    (code) => _ReferralCodeCard(code: code ?? '--------'),
                  ),
                  const SizedBox(height: 28),

                  // ── Share Button ──────────────────────────
                  codeAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error:   (_, __) => const SizedBox.shrink(),
                    data:    (code) => _ShareButton(code: code ?? ''),
                  ),
                  const SizedBox(height: 20),

                  // ── Terms ─────────────────────────────────
                  Center(
                    child: TextButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Terms & Conditions coming soon')),
                      ),
                      child: Text(
                        'Terms & Conditions apply',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.neutral500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Hero Banner Widget
// ─────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00C4A7), Color(0xFF0098A0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(top: -30, right: -30, child: _Circle(120, Colors.white.withOpacity(0.07))),
          Positioned(bottom: -20, left: -20, child: _Circle(80, Colors.white.withOpacity(0.07))),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 80, 28, 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Invite friends,\nget rewarded together.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'You + your friend each get 50 Momo Coins',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final Color color;
  const _Circle(this.size, this.color);

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

// ─────────────────────────────────────────────────────────────
// Stats Row
// ─────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    final invited = stats['friends_invited'] ?? 0;
    final coins   = stats['coins_earned_from_referrals'] ?? 0;
    return Row(
      children: [
        Expanded(child: _StatTile(label: 'Friends Invited', value: '$invited', icon: Icons.people_rounded, iconColor: const Color(0xFF6366F1))),
        const SizedBox(width: 12),
        Expanded(child: _StatTile(label: 'Coins Earned', value: '$coins', icon: Icons.monetization_on_rounded, iconColor: AppColors.rewardsGold)),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  const _StatTile({required this.label, required this.value, required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.neutral900)),
              Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsRowShimmer extends StatelessWidget {
  const _StatsRowShimmer();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 70, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)))),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 70, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)))),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// How It Works Card
// ─────────────────────────────────────────────────────────────

class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard();

  @override
  Widget build(BuildContext context) {
    const steps = [
      (icon: Icons.share_rounded,        color: Color(0xFF6366F1), title: 'Share your code',      sub: 'Send it via WhatsApp, SMS, or any app'),
      (icon: Icons.person_add_rounded,   color: Color(0xFF0EA5E9), title: 'Friend signs up',       sub: 'They join MomoPe using your referral code'),
      (icon: Icons.bolt_rounded,         color: AppColors.rewardsGold, title: 'First payment ≥₹100', sub: 'They make their first qualifying payment'),
      (icon: Icons.stars_rounded,        color: Color(0xFF22C55E), title: 'Both earn 50 coins',    sub: 'Credited instantly to both wallets'),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: steps.asMap().entries.map((entry) {
          final i    = entry.key;
          final step = entry.value;
          return Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(color: step.color.withOpacity(0.12), shape: BoxShape.circle),
                    child: Icon(step.icon, color: step.color, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(step.title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.neutral900)),
                        const SizedBox(height: 2),
                        Text(step.sub, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500)),
                      ],
                    ),
                  ),
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(color: AppColors.primaryTeal.withOpacity(0.1), shape: BoxShape.circle),
                    child: Center(child: Text('${i + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryTeal))),
                  ),
                ],
              ),
              if (i < steps.length - 1) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(children: List.generate(3, (_) => Container(width: 2, height: 4, margin: const EdgeInsets.symmetric(vertical: 2), decoration: BoxDecoration(color: AppColors.neutral300, borderRadius: BorderRadius.circular(1))))),
                ),
                const SizedBox(height: 8),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Referral Code Card
// ─────────────────────────────────────────────────────────────

class _ReferralCodeCard extends StatefulWidget {
  final String code;
  const _ReferralCodeCard({required this.code});

  @override
  State<_ReferralCodeCard> createState() => _ReferralCodeCardState();
}

class _ReferralCodeCardState extends State<_ReferralCodeCard> {
  bool _copied = false;

  void _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Code copied to clipboard!'),
        backgroundColor: AppColors.primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Text(
            'YOUR REFERRAL CODE',
            style: AppTypography.labelSmall.copyWith(letterSpacing: 1.5, color: AppColors.neutral500),
          ),
          const SizedBox(height: 16),
          // Code display with dashed border
          GestureDetector(
            onTap: _copy,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              decoration: BoxDecoration(
                color: _copied ? AppColors.primaryTeal.withOpacity(0.08) : AppColors.neutral100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _copied ? AppColors.primaryTeal : AppColors.neutral300,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.code,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6,
                      color: _copied ? AppColors.primaryTeal : AppColors.neutral900,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 16),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _copied ? Icons.check_circle_rounded : Icons.copy_rounded,
                      key: ValueKey(_copied),
                      color: _copied ? AppColors.primaryTeal : AppColors.neutral400,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _copied ? '✓ Copied!' : 'Tap code to copy',
            style: AppTypography.bodySmall.copyWith(
              color: _copied ? AppColors.primaryTeal : AppColors.neutral500,
              fontWeight: _copied ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeCardShimmer extends StatelessWidget {
  const _CodeCardShimmer();

  @override
  Widget build(BuildContext context) => Container(
    height: 130,
    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
  );
}

// ─────────────────────────────────────────────────────────────
// Share Button
// ─────────────────────────────────────────────────────────────

class _ShareButton extends StatelessWidget {
  final String code;
  const _ShareButton({required this.code});

  void _share() {
    if (code.isEmpty) return;
    final message =
        '🎉 Join MomoPe and earn rewards on every UPI payment!\n\n'
        'Use my referral code: *$code*\n\n'
        'We both get 50 Momo Coins when you make your first payment of ₹100+.\n\n'
        '📲 Download: https://momope.com';
    Share.share(message, subject: 'Join MomoPe — Earn Coins!');
  }

  @override
  Widget build(BuildContext context) {
    return PremiumButton(
      text: 'Share & Invite Friends',
      icon: Icons.share_rounded,
      onPressed: _share,
      style: PremiumButtonStyle.primary,
      width: double.infinity,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: AppTypography.labelSmall.copyWith(
      letterSpacing: 1.5,
      color: AppColors.neutral500,
      fontWeight: FontWeight.w600,
    ),
  );
}
