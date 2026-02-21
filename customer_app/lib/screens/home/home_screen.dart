import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/widgets/widgets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/coin_balance_provider.dart';
import '../../models/transaction.dart';
import '../qr_scanner/qr_scanner_screen.dart';
import '../profile/profile_screen.dart';
import '../transactions/transaction_history_screen.dart';
import '../../providers/merchant_provider.dart';
import '../../widgets/premium_qr_scan_card.dart';
import '../../features/referral/screens/referral_screen.dart';

/// Premium home screen with modern fintech design
/// Features: Gradient coin balance card, primary scan action, recent transactions
class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onProfileTap;
  const HomeScreen({super.key, this.onProfileTap});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<Map<String, dynamic>> _recentTransactions = [];
  bool _isLoadingTransactions = false;

  @override
  void initState() {
    super.initState();
    _loadRecentTransactions();
  }

  Future<void> _loadRecentTransactions() async {
    setState(() => _isLoadingTransactions = true);
    
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('transactions')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(3);

      if (mounted) {
        setState(() {
          _recentTransactions = List<Map<String, dynamic>>.from(response);
          _isLoadingTransactions = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      if (mounted) {
        setState(() => _isLoadingTransactions = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final coinBalanceAsync = ref.watch(coinBalanceProvider);
    
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(coinBalanceProvider);
            await _loadRecentTransactions();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: AppSpacing.screenPaddingAll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header - Greeting
                  _buildGreeting(user),
                  const SizedBox(height: 24),
                  
                  // Coin Balance Card (Gradient)
                  _buildCoinBalanceCard(coinBalanceAsync),
                  const SizedBox(height: 20),
                  
                  // Premium QR Scan Card (Dark Navy)
                  PremiumQRScanCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QRScannerScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Quick Actions Card
                  _buildQuickActionsSection(),
                  const SizedBox(height: 20),
                  
                  // Referral Stats Card (live data)
                  _buildReferralStatsCard(),
                  const SizedBox(height: 24),
                  
                  // Nearby Merchants
                  _buildNearbyMerchantsSection(),
                  const SizedBox(height: 24),
                  
                  // Recent Activity Section
                  _buildRecentActivitySection(),
                  const SizedBox(height: 16),
                  
                  // Recent Transactions
                  _buildRecentTransactions(),
                  
                  // Bottom padding for floating nav bar (70 height + 20 margin + 10 buffer)
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(User? user) {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
    } else if (hour >= 17) {
      greeting = 'Good Evening';
    }

    final displayName = user?.userMetadata?['full_name'] ?? 
                       user?.userMetadata?['name'] ?? 
                       'Customer';
    final firstName = displayName.split(' ').first;
    final firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'M';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.neutral500,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Hello, $firstName!',
                style: AppTypography.displaySmall.copyWith(
                  color: AppColors.neutral900,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          GestureDetector(
          onTap: () {
            if (widget.onProfileTap != null) {
              widget.onProfileTap!();
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            }
          },
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryTeal.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  firstInitial,
                  style: AppTypography.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinBalanceCard(AsyncValue<CoinBalance?> coinBalanceAsync) {
    return coinBalanceAsync.when(
      data: (balanceData) {
        final balance = balanceData?.availableCoins ?? 0;
        final weeklyEarnings = 50; 

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryTeal.withOpacity(0.2),
                blurRadius: 25,
                offset: const Offset(0, 12),
                spreadRadius: -5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // Mesh Gradient Background
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.0, 0.4, 0.9],
                      colors: [
                        Color(0xFF0F766E), // Dark Teal
                        AppColors.primaryTeal, 
                        Color(0xFF2DD4BF), // Light Teal
                      ],
                    ),
                  ),
                ),
                
                // Decorative Glass Circle
                Positioned(
                  right: -30,
                  top: -30,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.wallet_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'AVAILABLE COINS',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Coin breakdown coming soon!')),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'History',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            balance.toString(),
                            style: AppTypography.displayMedium.copyWith(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'COINS',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '₹${balance.toDouble().toStringAsFixed(0)}',
                            style: AppTypography.titleLarge.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (weeklyEarnings > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.trending_up_rounded, color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+$weeklyEarnings',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        height: 240,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0D9488),
              const Color(0xFF14B8A6),
              const Color(0xFF06B6D4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
      error: (error, stack) => Container(
        height: 240,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.errorRed.withOpacity(0.3)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: AppColors.errorRed),
              const SizedBox(height: 8),
              Text(
                'Error loading balance',
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanQRButton() {
    return PremiumButton(
      text: 'Scan QR to Pay',
      icon: Icons.qr_code_scanner_rounded,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const QRScannerScreen(),
          ),
        );
      },
      style: PremiumButtonStyle.primary,
      width: double.infinity,
    );
  }

  Widget _buildRecentActivitySection() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR TRANSACTIONS',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.neutral500,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Recent Activity',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.neutral900,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          if (_recentTransactions.isNotEmpty)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionHistoryScreen(),
                  ),
                );
              },
              child: Text(
                'View All',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    if (_isLoadingTransactions) {
      return Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PremiumCard(
              child: SizedBox(
                height: 60,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryTeal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_recentTransactions.isEmpty) {
      return PremiumCard(
        child: SizedBox(
          height: 150,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: AppColors.neutral400,
                ),
                const SizedBox(height: 12),
                Text(
                  'No transactions yet',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Scan a QR code to make your first payment',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: _recentTransactions.map((txn) {
        final status = txn['status'] as String? ?? 'pending';
        TransactionStatus txnStatus;
        
        if (status == 'completed') {
          txnStatus = TransactionStatus.success;
        } else if (status == 'failed') {
          txnStatus = TransactionStatus.failed;
        } else {
          txnStatus = TransactionStatus.pending;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TransactionCard(
            merchantName: txn['merchant_name'] as String? ?? 'Unknown Merchant',
            timestamp: _formatTimestamp(txn['created_at']),
            amount: (txn['fiat_amount'] as num?)?.toDouble() ?? 0.0,
            coinsEarned: txn['coins_earned'] as int? ?? 0,
            status: txnStatus,
            onTap: () {
              // Navigate to transaction details
              // TODO: Convert map to Transaction model and navigate
              // For now, this is a placeholder
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaction detail screen available - needs model conversion'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Recently';
    
    try {
      final dateTime = DateTime.parse(timestamp.toString());
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  Widget _buildReferralStatsCard() {
    final statsAsync = ref.watch(referralStatsProvider);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ReferralScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.neutral200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon with Gradient Glow
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            // Stats
            Expanded(
              child: statsAsync.when(
                loading: () => Text(
                  'Invite Friends, Earn Rewards',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.neutral900,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                error: (_, __) => Text(
                  'Invite Friends & Family',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.neutral900,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                data: (stats) {
                  final invited = stats['friends_invited'] ?? 0;
                  final coins   = stats['coins_earned_from_referrals'] ?? 0;
                  if (invited == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Invite & Earn',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.neutral900,
                            fontWeight: FontWeight.w900,
                          )),
                        const SizedBox(height: 2),
                        Text('Get 50 Coins for every referral',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.neutral500,
                            fontWeight: FontWeight.w700,
                          )),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$invited Success Invitations',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.neutral900,
                          fontWeight: FontWeight.w900,
                        )),
                      const SizedBox(height: 2),
                      Text('You earned $coins coins total',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.w900,
                        )),
                    ],
                  );
                },
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.neutral300, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMinimalAction(
            icon: Icons.local_offer_rounded,
            label: 'Offers',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Special offers coming soon!')),
              );
            },
          ),
          _buildMinimalAction(
            icon: Icons.store_rounded,
            label: 'Merchants',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tap Explore tab!')),
              );
            },
          ),
          _buildMinimalAction(
            icon: Icons.card_giftcard_rounded,
            label: 'Rewards',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rewards coming soon!')),
              );
            },
          ),
          _buildMinimalAction(
            icon: Icons.person_add_rounded,
            label: 'Invite',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReferralScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Minimal action widget - No cards, teal icons, darker labels
  Widget _buildMinimalAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryTeal,
                  size: 24,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.neutral800,
                  letterSpacing: 0.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Horizontal action card for Quick Actions (icon on top, label below)
  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return PremiumCard(
      style: PremiumCardStyle.elevated,
      onTap: onTap,
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Legacy row-style action card (not used)
  Widget _buildActionRowCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return PremiumCard(
      style: PremiumCardStyle.elevated,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            // Icon with background
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Label
            Expanded(
              child: Text(
                label,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
              ),
            ),
            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.neutral400,
            ),
          ],
        ),
      ),
    );
  }

  /// Legacy grid-style action button (kept for reference but not used)
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyMerchantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEARBY REWARDS',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.neutral500,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Explore Merchants',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.neutral900,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tap Explore tab for all merchants!')),
                );
              },
              child: Text(
                'See All',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // TODO: Replace with real Supabase data
        _buildMerchantsList(),
      ],
    );
  }

  Widget _buildMerchantsList() {
    final merchantsAsync = ref.watch(nearbyMerchantsProvider);

    return merchantsAsync.when(
      data: (merchants) {
        if (merchants.isEmpty) {
          return PremiumCard(
            style: PremiumCardStyle.elevated,
            child: Padding(
              padding: AppSpacing.paddingAll16,
              child: Center(
                child: Text(
                  'No rewards available yet',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ),
            ),
          );
        }

        // Horizontal carousel
        return SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: merchants.take(5).length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final merchant = merchants.elementAt(index);
              return Padding(
                padding: EdgeInsets.only(
                  right: index < merchants.length - 1 ? 12 : 0,
                ),
                child: _buildCompactMerchantCard(merchant),
              );
            },
          ),
        );
      },
      loading: () => SizedBox(
        height: 150,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primaryTeal,
            ),
          ),
        ),
      ),
      error: (error, stack) => PremiumCard(
        style: PremiumCardStyle.elevated,
        child: Padding(
          padding: AppSpacing.paddingAll16,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: AppColors.errorRed),
                const SizedBox(height: 8),
                Text(
                  'Error loading rewards',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Compact horizontal merchant card for carousel
  Widget _buildCompactMerchantCard(Merchant merchant) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.72; // 72% of screen width
    
    // Get category-based gradient and icon
    final categoryStyle = _getCategoryStyle(merchant.category);

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${merchant.name} details coming soon!')),
        );
      },
      child: Container(
        width: cardWidth,
        height: 150,
        decoration: BoxDecoration(
          gradient: categoryStyle['gradient'] as LinearGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral900.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Faint watermark icon (background)
            Positioned(
              top: 20,
              right: 20,
              child: Icon(
                categoryStyle['icon'] as IconData,
                size: 70,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
            
            // Small reward badge (top-right, if exists)
            if (merchant.rewardsPercentage != null)
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryTeal.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${merchant.rewardsPercentage}%',
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            
            // Bottom content area
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.85),
                      Colors.white.withOpacity(0.95),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Merchant name
                    Text(
                      merchant.name,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.neutral900,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 7),
                    
                    // Distance & rating inline
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 13,
                          color: AppColors.neutral600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '0.8 km',
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.neutral600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '•',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.neutral400,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.star,
                          size: 13,
                          color: AppColors.rewardsGold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '4.3',
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get category-based gradient and icon
  Map<String, dynamic> _getCategoryStyle(String category) {
    final categoryLower = category.toLowerCase();
    
    // Food & Beverage - Soft warm teal
    if (categoryLower.contains('food') || categoryLower.contains('beverage') || 
        categoryLower.contains('restaurant') || categoryLower.contains('cafe')) {
      return {
        'gradient': LinearGradient(
          colors: [
            const Color(0xFFE0F2F1), // Very light teal
            const Color(0xFFB2DFDB), // Soft teal
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'icon': Icons.restaurant_rounded,
      };
    }
    
    // Shopping - Light cool blue
    if (categoryLower.contains('shop') || categoryLower.contains('retail') || 
        categoryLower.contains('store')) {
      return {
        'gradient': LinearGradient(
          colors: [
            const Color(0xFFE3F2FD), // Very light blue
            const Color(0xFFBBDEFB), // Soft blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'icon': Icons.shopping_bag_rounded,
      };
    }
    
    // Services - Muted slate blue
    if (categoryLower.contains('service') || categoryLower.contains('salon') || 
        categoryLower.contains('spa')) {
      return {
        'gradient': LinearGradient(
          colors: [
            const Color(0xFFECEFF1), // Very light slate
            const Color(0xFFCFD8DC), // Soft slate
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'icon': Icons.spa_rounded,
      };
    }
    
    // Entertainment - Soft purple-teal
    if (categoryLower.contains('entertainment') || categoryLower.contains('movie') || 
        categoryLower.contains('cinema')) {
      return {
        'gradient': LinearGradient(
          colors: [
            const Color(0xFFF3E5F5), // Very light purple
            const Color(0xFFE1BEE7), // Soft purple
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'icon': Icons.movie_rounded,
      };
    }
    
    // Healthcare - Calm aqua
    if (categoryLower.contains('health') || categoryLower.contains('pharmacy') || 
        categoryLower.contains('medical')) {
      return {
        'gradient': LinearGradient(
          colors: [
            const Color(0xFFE0F7FA), // Very light cyan
            const Color(0xFFB2EBF2), // Soft cyan
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'icon': Icons.local_hospital_rounded,
      };
    }
    
    // Default - Soft teal gradient (General)
    return {
      'gradient': LinearGradient(
        colors: [
          AppColors.primaryTeal.withOpacity(0.08),
          AppColors.primaryTealLight.withOpacity(0.18),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'icon': Icons.store_rounded,
    };
  }
}
