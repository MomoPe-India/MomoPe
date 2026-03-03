// lib/features/home/screens/home_screen.dart
//
// MomoPe Home Screen — Premium fintech layout.
// Layout order:
//   1. App bar: brand logo + greeting + masked phone + notification bell
//   2. Coin Balance Hero Card (animated, tap-to-toggle visibility)
//   3. Earn rate context line
//   4. ⚠️ Coin Expiry Warning  [conditional]
//   5. Quick Actions (4 equal icons)
//   6. Near You strip [location-gated]
//   7. Popular (Featured) Merchants [always visible]
//   8. Recent Transactions [last 3]
//   9. Refer & Earn Card [full width]

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants.dart';
import '../../../core/models/models.dart';
import '../../../core/theme.dart';
import '../widgets/home_widgets.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final _profileProvider = FutureProvider<UserModel?>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  try {
    final idToken = await user.getIdToken(true);
    final resp = await http.post(
      Uri.parse('${AppConstants.supabaseUrl}/functions/v1/get-profile'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type':  'application/json',
        'apikey':         AppConstants.supabaseAnonKey,
      },
    );
    if (resp.statusCode != 200) return null;
    final body    = jsonDecode(resp.body) as Map<String, dynamic>;
    final profile = body['profile'] as Map<String, dynamic>?;
    if (profile == null) return null;
    return UserModel.fromMap(profile);
  } catch (_) {
    return null;
  }
});

final _homeDataProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;
  try {
    final result = await Supabase.instance.client.rpc(
      'get_customer_home_data',
      params: {'firebase_uid': uid},
    );
    return result as Map<String, dynamic>?;
  } catch (_) {
    return null;
  }
});

// ── Home Screen ───────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _locationGranted = false;
  List<dynamic> _nearbyMerchants = [];
  bool _locationChecked = false;

  @override
  void initState() {
    super.initState();
    _checkLocationAndFetch();
  }

  Future<void> _checkLocationAndFetch() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) setState(() => _locationChecked = true);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 8),
        ),
      );

      final result = await Supabase.instance.client.rpc(
        'get_nearby_merchants',
        params: {'lat': pos.latitude, 'lon': pos.longitude},
      );

      if (mounted) {
        setState(() {
          _locationGranted = true;
          _nearbyMerchants = (result as List?)?.cast<dynamic>() ?? [];
          _locationChecked = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _locationChecked = true);
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(_profileProvider);
    ref.invalidate(_homeDataProvider);
    _checkLocationAndFetch();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(_profileProvider);
    final homeAsync    = ref.watch(_homeDataProvider);

    final firstName = profileAsync.valueOrNull?.name.split(' ').first ?? '';
    final phoneNum  = profileAsync.valueOrNull?.phone ?? '';

    return Scaffold(
      backgroundColor: context.theme.bg,
      body: RefreshIndicator(
        color: context.theme.primary,
        backgroundColor: context.theme.card,
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── App Bar ──────────────────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              floating: false,
              toolbarHeight: 64,
              backgroundColor: context.theme.bg,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              titleSpacing: 0,
              automaticallyImplyLeading: false,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarBrightness:
                    Theme.of(context).brightness == Brightness.dark
                        ? Brightness.dark
                        : Brightness.light,
              ),
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Brand logo — far left
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Greeting text — beside logo
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            firstName.isEmpty ? 'MomoPe' : 'Hi, $firstName 👋',
                            style: TextStyle(
                              color: context.theme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              height: 1.15,
                            ),
                          ),
                          if (firstName.isNotEmpty)
                            Text(
                              'Good ${_greeting()}${phoneNum.isNotEmpty ? ' · ${_maskPhone(phoneNum)}' : ''}',
                              style: TextStyle(
                                color: context.theme.textMuted.withValues(alpha: 0.65),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Notification bell — far right
                    GestureDetector(
                      onTap: () => GoRouter.of(context).go('/notifications'),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.theme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: context.theme.surfaceAlt,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: context.theme.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Content ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: homeAsync.when(
                  loading: () => const HomeSkeleton(),
                  error: (_, __) => _buildContent(
                    balance: CoinBalance.empty,
                    expiring: 0,
                    todayEarnings: 0,
                    referral: {},
                    recentTransactions: [],
                    featuredMerchants: [],
                  ),
                  data: (data) {
                    final balMap   = data?['balance'] as Map<String, dynamic>? ?? {};
                    final expiring = (data?['expiring'] as num?)?.toDouble() ?? 0.0;
                    final todayEarnings = (data?['today_earnings'] as num?)?.toDouble() ?? 0.0;
                    final referral = data?['referral'] as Map<String, dynamic>? ?? {};
                    final recentTransactions = data?['recent_transactions'] as List<dynamic>? ?? [];
                    final featuredMerchants  = data?['featured_merchants']  as List<dynamic>? ?? [];

                    final balance = CoinBalance(
                      totalCoins:     (balMap['total_coins']     as num?)?.toDouble() ?? 0,
                      availableCoins: (balMap['available_coins'] as num?)?.toDouble() ?? 0,
                      lockedCoins:    (balMap['locked_coins']    as num?)?.toDouble() ?? 0,
                    );
                    return _buildContent(
                      balance: balance,
                      expiring: expiring,
                      todayEarnings: todayEarnings,
                      referral: referral,
                      recentTransactions: recentTransactions,
                      featuredMerchants: featuredMerchants,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent({
    required CoinBalance balance,
    required double expiring,
    required double todayEarnings,
    required Map<String, dynamic> referral,
    required List<dynamic> recentTransactions,
    required List<dynamic> featuredMerchants,
  }) {
    final referralCode = referral['referral_code'] as String?;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // 1. Balance Card
      CoinBalanceCard(balance: balance, todayEarnings: todayEarnings),

      const SizedBox(height: 12),

      // Earn rate context line
      Row(
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              color: context.theme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Earning up to 10% on every purchase',
            style: TextStyle(
              color: context.theme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),

      // 2. Expiry Banner (conditional)
      if (expiring > 0) ...[
        const SizedBox(height: 16),
        ExpiryWarningBanner(
          coins: expiring,
          onTap: () => GoRouter.of(context).go('/transactions'),
        ),
      ],

      const SizedBox(height: 24),

      // 3. Scan & Pay Promo Card
      ScanAndPayPromoCard(
        onTap: () => GoRouter.of(context).go('/scan'),
      ),

      const SizedBox(height: 24),

      // 4. Quick Actions (Explore, Offers, History, Refer)
      QuickActionGrid(actions: _buildActions()),

      const SizedBox(height: 28),

      // 4. Near You [location-gated]
      if (_locationChecked) ...[
        NearYouSection(
          merchants: _nearbyMerchants,
          locationGranted: _locationGranted,
        ),
        const SizedBox(height: 28),
      ],

      // 5. Featured Merchants [always visible]
      FeaturedMerchantsSection(
        merchants: featuredMerchants,
        onViewAll: () => GoRouter.of(context).go('/explore'),
      ),
      if (featuredMerchants.isNotEmpty) const SizedBox(height: 28),

      // 6. Recent Transactions
      if (recentTransactions.isNotEmpty) ...[
        SectionHeader(
          title: 'Recent Transactions',
          actionLabel: 'See All',
          onAction: () => GoRouter.of(context).go('/transactions'),
        ),
        const SizedBox(height: 14),
        RecentTransactionsSection(transactions: recentTransactions),
        const SizedBox(height: 28),
      ],

      // Empty state for brand-new users
      if (recentTransactions.isEmpty && featuredMerchants.isEmpty) ...[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: context.theme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.theme.surfaceAlt),
          ),
          child: Column(
            children: [
              Icon(Icons.qr_code_scanner_rounded,
                  size: 48, color: context.theme.primary.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text(
                'Make your first scan\nto start earning Momo Coins!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.theme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
      ],

      // 7. Refer & Earn Card (full width — not peeking)
      _ReferralCard(
        referralCode: referralCode,
        referralStats: referral,
        onTap: () => context.push('/referrals'),
      ),

      // Fixed nav clearance
      const SizedBox(height: 100),
    ]);
  }

  List<QuickAction> _buildActions() => [
    QuickAction(
      icon: Icons.explore_outlined,
      label: 'Explore',
      onTap: () => GoRouter.of(context).go('/explore'),
    ),
    QuickAction(
      icon: Icons.local_offer_outlined,
      label: 'Offers',
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Offers coming soon!'),
            backgroundColor: context.theme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    ),
    QuickAction(
      icon: Icons.receipt_long_outlined,
      label: 'History',
      onTap: () => GoRouter.of(context).go('/transactions'),
    ),
    QuickAction(
      icon: Icons.people_alt_outlined,
      label: 'Refer & Earn',
      onTap: () => context.push('/referrals'),
    ),
  ];

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }

  String _maskPhone(String phone) {
    if (phone.length < 10) return phone;
    return '${phone.substring(0, 2)}XXXXX${phone.substring(7)}';
  }
}

// ── Inline Referral Card ─────────────────────────────────────────────────────
// A standalone, full-width card that is never cut off at the bottom.

class _ReferralCard extends StatelessWidget {
  final String? referralCode;
  final Map<String, dynamic> referralStats;
  final VoidCallback onTap;

  const _ReferralCard({
    required this.referralCode,
    required this.referralStats,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final int invites = referralStats['total_referrals'] ?? 0;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.theme.primary.withValues(alpha: 0.12),
            context.theme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.theme.primary.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: context.theme.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top banner
          GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: context.theme.coinGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: context.theme.primary.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      'Invite friends, earn together!',
                      style: TextStyle(
                        color: context.theme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Both of you earn bonus coins on every purchase.',
                      style: TextStyle(
                        color: context.theme.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    if (invites > 0) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: context.theme.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '🎉 $invites friend${invites > 1 ? 's' : ''} joined',
                          style: TextStyle(
                            color: context.theme.success,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ]),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: context.theme.primary.withValues(alpha: 0.7), size: 22),
              ]),
            ),
          ),

          if (referralCode != null) ...[
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.theme.bg.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: context.theme.primary.withValues(alpha: 0.25)),
              ),
              child: Row(children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your referral code',
                      style: TextStyle(color: context.theme.textMuted, fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      referralCode!,
                      style: TextStyle(
                        color: context.theme.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Copy button
                Material(
                  color: context.theme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      // copy handled in parent
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.copy_rounded, size: 14, color: context.theme.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Copy',
                            style: TextStyle(
                              color: context.theme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Share button
                Material(
                  color: context.theme.primary,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.share_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          const Text(
                            'Share',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}
