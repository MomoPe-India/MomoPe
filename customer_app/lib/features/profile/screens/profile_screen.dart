// lib/features/profile/screens/profile_screen.dart
//
// MomoPe Profile Screen — Complete overhaul.
// Sections:
//   1. Header: avatar + edit name + masked phone + member since + tier badge
//   2. Coin Summary Card: balance split + next expiry + legal note
//   3. Referral: code + stats + joined-via badge
//   4. Security: Change PIN
//   5. Preferences: Notification toggle (placeholder)
//   6. Account: Terms · Privacy · About · Sign Out

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme.dart';
import '../../auth/providers/auth_state_provider.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final _profileFullProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;
  final result = await Supabase.instance.client.rpc(
    'get_profile_full',
    params: {'firebase_uid': uid},
  );
  return result as Map<String, dynamic>?;
});

// ── Tier Helper ───────────────────────────────────────────────────────────────

class _Tier {
  final String name;
  final String emoji;
  final int earnRate;        // percentage
  final int minTxn;
  final int? maxTxn;         // null = no upper bound

  const _Tier(this.name, this.emoji, this.earnRate, this.minTxn, this.maxTxn);
}

const _tiers = [
  _Tier('New Member',  '🌱', 10,  0,  1),
  _Tier('Engaged',     '⚡', 9,   2,  5),
  _Tier('Regular',     '🥈', 8,   6,  20),
  _Tier('Loyal',       '🏅', 7,   21, null),
];

_Tier _tierFor(int txnCount) {
  for (final t in _tiers.reversed) {
    if (txnCount >= t.minTxn) return t;
  }
  return _tiers.first;
}

/// Progress to next tier as 0.0–1.0. Returns 1.0 for top tier.
double _tierProgress(int txnCount) {
  final tier = _tierFor(txnCount);
  if (tier.maxTxn == null) return 1.0;
  final range = tier.maxTxn! - tier.minTxn + 1;
  final done  = txnCount - tier.minTxn;
  return (done / range).clamp(0.0, 1.0);
}

int? _txnsToNextTier(int txnCount) {
  final tier = _tierFor(txnCount);
  if (tier.maxTxn == null) return null;
  return tier.maxTxn! + 1 - txnCount;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notifEnabled = true;
  bool _notifSaving  = false; // debounce while saving
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _appVersion = 'v${info.version}');
    });
  }

  // ── Load notification pref from already-fetched profile data ─────────────────
  // Called once profile data is available in build().
  void _syncNotifPref(Map<String, dynamic> data) {
    final val = (data['notifications_enabled'] as bool?) ?? true;
    // Only update state if different — avoids rebuild loop
    if (_notifEnabled != val) {
      // Use post-frame to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _notifEnabled = val);
      });
    }
  }

  // ── Persist notification preference to Supabase ───────────────────────────────
  Future<void> _setNotifEnabled(bool value) async {
    if (_notifSaving) return;
    setState(() {
      _notifEnabled = value;
      _notifSaving  = true;
    });
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await Supabase.instance.client
          .from('users')
          .update({'notifications_enabled': value})
          .eq('firebase_uid', uid);
    } catch (e) {
      // Revert on failure
      if (mounted) setState(() => _notifEnabled = !value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not save preference. Try again.'),
            backgroundColor: context.theme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _notifSaving = false);
    }
  }

  // ── helpers ─────────────────────────────────────────────────────────────────

  String _maskPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return phone;
    final local = digits.length == 12 ? digits.substring(2) : digits.substring(digits.length - 10);
    return '${local.substring(0, 2)}XXXXX${local.substring(7)}';
  }

  String _memberSince(String createdAtStr) {
    final dt = DateTime.tryParse(createdAtStr) ?? DateTime.now();
    const months = ['January','February','March','April','May','June',
      'July','August','September','October','November','December'];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  String _formatExpiry(String? dateStr) {
    if (dateStr == null) return '';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return '';
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  // ── edit name ────────────────────────────────────────────────────────────────

  Future<void> _editName(String currentName) async {
    final ctrl = TextEditingController(text: currentName);
    final saved = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.theme.card,
        title: Text('Edit Name',
            style: TextStyle(color: context.theme.textPrimary, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Your full name',
            hintStyle: TextStyle(color: context.theme.textMuted),
          ),
          style: TextStyle(color: context.theme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: context.theme.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: Text('Save', style: TextStyle(color: context.theme.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (saved == null || saved.isEmpty || saved == currentName) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await Supabase.instance.client.rpc(
        'update_user_name',
        params: {'firebase_uid': uid, 'new_name': saved},
      );
      ref.invalidate(_profileFullProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Name updated!'),
            backgroundColor: context.theme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  // ── sign-out ─────────────────────────────────────────────────────────────────

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.theme.card,
        title: const Text('Sign Out?'),
        content: const Text("You'll need to verify your phone number again."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: context.theme.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sign Out', style: TextStyle(color: context.theme.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await ref.read(authNotifierProvider.notifier).signOut();
    }
  }

  // ── build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_profileFullProvider);

    return Scaffold(
      backgroundColor: context.theme.bg,
      appBar: AppBar(
        backgroundColor: context.theme.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text('Profile',
            style: TextStyle(
              color: context.theme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            )),
        centerTitle: true,
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('$e', style: TextStyle(color: context.theme.error))),
        data: (data) {
          if (data == null) {
            return const Center(child: Text('Profile not found'));
          }
          return _buildBody(data);
        },
      ),
    );
  }

  Widget _buildBody(Map<String, dynamic> data) {
    // Sync notification preference from DB value (post-frame to avoid setState-in-build)
    _syncNotifPref(data);

    final user       = data['user'] as Map<String, dynamic>;
    final balance    = data['balance'] as Map<String, dynamic>;
    final referral   = data['referral'] as Map<String, dynamic>;
    final nextExpiry = data['next_expiry'] as Map<String, dynamic>?;
    final txnCount   = (data['transaction_count'] as num?)?.toInt() ?? 0;

    final name         = user['name'] as String? ?? '';
    final phone        = user['phone'] as String? ?? '';
    final referralCode = user['referral_code'] as String?;
    final referredBy   = user['referred_by'] as String?;
    final createdAt    = user['created_at'] as String? ?? '';

    final totalCoins     = (balance['total_coins']     as num?)?.toDouble() ?? 0;
    final availableCoins = (balance['available_coins'] as num?)?.toDouble() ?? 0;
    final lockedCoins    = (balance['locked_coins']    as num?)?.toDouble() ?? 0;

    final totalReferrals     = (referral['total_referrals']     as num?)?.toInt() ?? 0;
    final completedReferrals = (referral['completed_referrals'] as num?)?.toInt() ?? 0;
    final pendingReferrals   = (referral['pending_referrals']   as num?)?.toInt() ?? 0;
    final referralCoins      = (referral['coins_earned']        as num?)?.toDouble() ?? 0;

    final expiryDate   = nextExpiry?['expiry_date']  as String?;
    final expiryAmount = (nextExpiry?['amount']       as num?)?.toDouble() ?? 0;

    final tier      = _tierFor(txnCount);
    final progress  = _tierProgress(txnCount);
    final toNext    = _txnsToNextTier(txnCount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 140),
      children: [

        // ── 1. Header ──────────────────────────────────────────────────────────
        Center(
          child: Column(children: [
            // Avatar + pencil
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: context.theme.coinGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: context.theme.primary.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _editName(name),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: context.theme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.theme.bg, width: 2),
                      ),
                      child: const Icon(Icons.edit_rounded,
                          color: Colors.white, size: 13),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => _editName(name),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  name,
                  style: TextStyle(
                    color: context.theme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.edit_outlined, color: context.theme.textMuted, size: 16),
              ]),
            ),
            const SizedBox(height: 4),
            Text(
              '+91 ${_maskPhone(phone)}',
              style: TextStyle(color: context.theme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              'Member since ${_memberSince(createdAt)}',
              style: TextStyle(color: context.theme.textMuted, fontSize: 12),
            ),

            const SizedBox(height: 14),
            // Tier badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: context.theme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.theme.primary.withValues(alpha: 0.2)),
              ),
              child: Column(children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(tier.emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    '${tier.name}  ·  Earning ${tier.earnRate}% per purchase',
                    style: TextStyle(
                      color: context.theme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ]),
                if (toNext != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: context.theme.primary.withValues(alpha: 0.14),
                      valueColor: AlwaysStoppedAnimation(context.theme.primary),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$toNext more purchase${toNext == 1 ? '' : 's'} to next tier',
                    style: TextStyle(color: context.theme.textMuted, fontSize: 11),
                  ),
                ] else ...[
                  const SizedBox(height: 4),
                  Text('Top tier — maximum loyalty!',
                      style: TextStyle(color: context.theme.textMuted, fontSize: 11)),
                ],
              ]),
            ),
          ]),
        ),

        const SizedBox(height: 28),

        // ── 2. Coin Summary Card ───────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: context.theme.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.theme.surfaceAlt),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: context.theme.coinGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.toll_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Text('Momo Coins',
                  style: TextStyle(
                    color: context.theme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  )),
              const Spacer(),
              Text(
                '${totalCoins.toStringAsFixed(0)} 🪙',
                style: TextStyle(
                  color: context.theme.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              _CoinChip(label: 'Available', value: availableCoins, color: context.theme.success),
              const SizedBox(width: 10),
              _CoinChip(label: 'Locked', value: lockedCoins, color: context.theme.textMuted),
            ]),
            if (expiryDate != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  const Icon(Icons.timer_outlined, color: Colors.orangeAccent, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Next expiry: ${expiryAmount.toStringAsFixed(0)} coins on ${_formatExpiry(expiryDate)}',
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ]),
              ),
            ],
            const SizedBox(height: 12),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info_outline_rounded, size: 13, color: context.theme.textMuted),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Momo Coins can only be redeemed at partner merchants. They cannot be withdrawn or transferred.',
                  style: TextStyle(color: context.theme.textMuted, fontSize: 11, height: 1.4),
                ),
              ),
            ]),
          ]),
        ),

        const SizedBox(height: 20),

        // ── 3. Referral ────────────────────────────────────────────────────────
        _Section(title: 'Referral', children: [
          if (referralCode != null) ...[
            // Code row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Your Code',
                      style: TextStyle(color: context.theme.textMuted, fontSize: 11)),
                  const SizedBox(height: 3),
                  Text(
                    referralCode,
                    style: TextStyle(
                      color: context.theme.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.5,
                    ),
                  ),
                ]),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.copy_rounded, color: context.theme.primary, size: 20),
                  tooltip: 'Copy code',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: referralCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Referral code copied!'),
                        backgroundColor: context.theme.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.share_rounded, color: context.theme.primary, size: 20),
                  tooltip: 'Share',
                  onPressed: () => Share.share(
                    'Join MomoPe and earn Momo Coins on every purchase! 🪙\n'
                    'Use my code $referralCode to get bonus coins.\n'
                    'Download: momope.com',
                  ),
                ),
              ]),
            ),

            // Stats row
            if (totalReferrals > 0) ...[
              Divider(height: 1, color: context.theme.surfaceAlt),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ReferralStat(label: 'Invited', value: '$totalReferrals', icon: '👥'),
                    _ReferralStat(label: 'Completed', value: '$completedReferrals', icon: '✅'),
                    if (pendingReferrals > 0)
                      _ReferralStat(label: 'Pending', value: '$pendingReferrals', icon: '⏳'),
                    _ReferralStat(
                      label: 'Coins Earned',
                      value: referralCoins.toStringAsFixed(0),
                      icon: '🪙',
                    ),
                  ],
                ),
              ),
            ],

            // Joined via referral badge
            if (referredBy != null) ...[
              Divider(height: 1, color: context.theme.surfaceAlt),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(children: [
                  const Text('🎉', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Text(
                    'You joined MomoPe via a referral!',
                    style: TextStyle(
                      color: context.theme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ]),
              ),
            ],
          ],
        ]),

        const SizedBox(height: 20),

        // ── 4. Security ────────────────────────────────────────────────────────
        _Section(title: 'Security', children: [
          _Tile(
            icon: Icons.lock_outline_rounded,
            label: 'Change PIN',
            onTap: () => context.push('/forgot-pin'),
          ),
        ]),

        const SizedBox(height: 20),

        // ── 5. Preferences ─────────────────────────────────────────────────────
        _Section(title: 'Preferences', children: [
          SwitchListTile(
            secondary: Icon(
              _notifEnabled ? Icons.notifications_rounded : Icons.notifications_off_outlined,
              color: _notifEnabled ? context.theme.primary : context.theme.textMuted,
              size: 20,
            ),
            title: Text('Transaction Alerts',
                style: TextStyle(
                  color: context.theme.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                )),
            subtitle: Text(
              _notifEnabled
                  ? 'Push notifications are enabled'
                  : 'Push notifications are disabled',
              style: TextStyle(color: context.theme.textMuted, fontSize: 12),
            ),
            value: _notifEnabled,
            onChanged: _notifSaving ? null : _setNotifEnabled,
            activeThumbColor: context.theme.primary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
        ]),

        const SizedBox(height: 20),

        // ── 6. Account ─────────────────────────────────────────────────────────
        _Section(title: 'Account', children: [
          _Tile(
            icon: Icons.description_outlined,
            label: 'Terms & Conditions',
            onTap: () => launchUrl(
              Uri.parse('https://momope.com/terms'),
              mode: LaunchMode.externalApplication,
            ),
          ),
          Divider(height: 1, color: context.theme.surfaceAlt),
          _Tile(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            onTap: () => launchUrl(
              Uri.parse('https://momope.com/privacy'),
              mode: LaunchMode.externalApplication,
            ),
          ),
          Divider(height: 1, color: context.theme.surfaceAlt),
          _Tile(
            icon: Icons.info_outline_rounded,
            label: 'About MomoPe',
            trailing: Text(
              _appVersion.isEmpty ? '...' : _appVersion,
              style: TextStyle(color: context.theme.textMuted, fontSize: 12),
            ),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'MomoPe',
              applicationVersion: _appVersion,
              applicationLegalese:
                  'MOMOPE DIGITAL HUB PRIVATE LIMITED\n'
                  'CIN: U63120AP2025PTC118821\n\n'
                  '© 2026 MomoPe. All rights reserved.',
            ),
          ),
          Divider(height: 1, color: context.theme.surfaceAlt),
          _Tile(
            icon: Icons.logout_rounded,
            label: 'Sign Out',
            color: context.theme.error,
            onTap: _signOut,
          ),
        ]),
      ],
    );
  }
}

// ── Sub-Widgets ───────────────────────────────────────────────────────────────

class _CoinChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _CoinChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                color: color.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 3),
          Text(
            '${value.toStringAsFixed(0)} 🪙',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ]),
      ),
    );
  }
}

class _ReferralStat extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  const _ReferralStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(icon, style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 4),
      Text(value,
          style: TextStyle(
            color: context.theme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          )),
      Text(label,
          style: TextStyle(color: context.theme.textMuted, fontSize: 11)),
    ]);
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: context.theme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: context.theme.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.theme.surfaceAlt),
            ),
            child: Column(children: children),
          ),
        ],
      );
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Widget? trailing;
  const _Tile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading:  Icon(icon, color: color ?? context.theme.textPrimary, size: 20),
        title: Text(
          label,
          style: TextStyle(
            color: color ?? context.theme.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        trailing: trailing ??
            Icon(Icons.chevron_right_rounded,
                color: context.theme.textMuted, size: 18),
        onTap: onTap,
      );
}
