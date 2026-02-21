import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/widgets/widgets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';
import '../../providers/coin_balance_provider.dart';
import '../auth/login_screen.dart';

/// Premium profile screen
/// Features: User info, account stats, settings menu, logout
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final coinBalanceAsync = ref.watch(coinBalanceProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.neutral100,
        body: CustomScrollView(
          slivers: [
            // Premium Header
            _buildSliverHeader(context, user),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Column(
                  children: [
                    // Account Stats with progress
                    _buildAccountStats(coinBalanceAsync),
                    
                    const SizedBox(height: 32),
                    
                    // Menu Sections
                    _buildMenuSection(context, ref, user),
                    
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context, User? user) {
    final displayName = user?.userMetadata?['full_name'] ?? 
                       user?.userMetadata?['name'] ?? 
                       'MomoPe User';
    final email = user?.email ?? '';

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.secondaryNavy,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondaryNavy,
                    AppColors.secondaryNavyDark,
                  ],
                ),
              ),
            ),
            // Decorative shapes
            Positioned(
              top: -50,
              right: -50,
              child: CircleAvatar(
                radius: 120,
                backgroundColor: AppColors.primaryTeal.withOpacity(0.05),
              ),
            ),
            
            // Profile Info Content
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Glassmorphism Profile Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Avatar with depth
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryTeal.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              displayName.substring(0, 1).toUpperCase(),
                              style: AppTypography.displaySmall.copyWith(
                                color: AppColors.primaryTeal,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Name and Level
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: AppTypography.headlineSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.goldGradient,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.workspace_premium_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'GOLD MEMBER',
                                          style: AppTypography.overline.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                email,
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountStats(AsyncValue<CoinBalance?> coinBalanceAsync) {
    return coinBalanceAsync.when(
      data: (balanceData) {
        final totalCoins = balanceData?.totalCoins ?? 0;
        final availableCoins = balanceData?.availableCoins ?? 0;
        
        return Padding(
          padding: AppSpacing.paddingH16,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.stars_rounded,
                      iconColor: AppColors.rewardsGold,
                      label: 'Total Earned',
                      value: totalCoins.toString(),
                      subtitle: 'Lifetime coins',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.wallet_rounded,
                      iconColor: AppColors.primaryTeal,
                      label: 'Available',
                      value: availableCoins.toString(),
                      subtitle: 'Ready to spend',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress towards next level
              PremiumCard(
                style: PremiumCardStyle.elevated,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Next Level Progress',
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '750/1000',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.75,
                        minHeight: 8,
                        backgroundColor: AppColors.neutral200,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Earn 250 more coins to reach Platinum level',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const ShimmerLoading(height: 120),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String subtitle,
  }) {
    return PremiumCard(
      style: PremiumCardStyle.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 28),
              Icon(Icons.trending_up_rounded, color: AppColors.successGreen.withOpacity(0.5), size: 16),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTypography.amountLarge.copyWith(
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.neutral800,
              fontSize: 13,
            ),
          ),
          Text(
            subtitle,
            style: AppTypography.caption.copyWith(
              color: AppColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, WidgetRef ref, User? user) {
    return Column(
      children: [
        _buildMenuGroup(
          title: 'FINANCIAL',
          items: [
            _MenuItemData(
              icon: Icons.qr_code_rounded,
              title: 'My QR Code',
              subtitle: 'Show your receiving QR',
              iconColor: AppColors.primaryTeal,
              onTap: () => _showComingSoon(context, 'My QR Code'),
            ),
            _MenuItemData(
              icon: Icons.account_balance_rounded,
              title: 'Linked Bank Accounts',
              subtitle: 'Manage your UPI handles',
              iconColor: AppColors.infoBlue,
              onTap: () => _showComingSoon(context, 'Linked Bank Accounts'),
            ),
            _MenuItemData(
              icon: Icons.history_edu_rounded,
              title: 'Transaction Limits',
              subtitle: 'Check your daily limits',
              iconColor: AppColors.accentOrange,
              onTap: () => _showComingSoon(context, 'Transaction Limits'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildMenuGroup(
          title: 'SECURITY & PRIVACY',
          items: [
            _MenuItemData(
              icon: Icons.fingerprint_rounded,
              title: 'Biometric Unlock',
              subtitle: 'Face ID / Fingerprint',
              iconColor: AppColors.successGreen,
              onTap: () => _showComingSoon(context, 'Biometrics'),
            ),
            _MenuItemData(
              icon: Icons.lock_outline_rounded,
              title: 'App PIN',
              subtitle: 'Secure your payments',
              iconColor: AppColors.warningAmber,
              onTap: () => _showComingSoon(context, 'App PIN'),
            ),
            _MenuItemData(
              icon: Icons.privacy_tip_outlined,
              title: 'Data Privacy',
              subtitle: 'Manage what you share',
              iconColor: AppColors.neutral600,
              onTap: () => _showComingSoon(context, 'Privacy settings'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildMenuGroup(
          title: 'PREFERENCES',
          items: [
            _MenuItemData(
              icon: Icons.notifications_active_outlined,
              title: 'Notifications',
              subtitle: 'Alerts & updates',
              iconColor: AppColors.infoBlue,
              onTap: () => _showComingSoon(context, 'Notifications'),
            ),
            _MenuItemData(
              icon: Icons.language_rounded,
              title: 'Language',
              subtitle: 'Choose your preference',
              iconColor: AppColors.neutral600,
              onTap: () => _showComingSoon(context, 'Language'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildMenuGroup(
          title: 'SUPPORT',
          items: [
            _MenuItemData(
              icon: Icons.headset_mic_outlined,
              title: 'Help & Support',
              subtitle: '24/7 technical assistance',
              iconColor: AppColors.primaryTeal,
              onTap: () => _showComingSoon(context, 'Support'),
            ),
            _MenuItemData(
              icon: Icons.info_outline_rounded,
              title: 'About MomoPe',
              subtitle: 'Version 1.0.0',
              iconColor: AppColors.neutral500,
              onTap: () => _showComingSoon(context, 'About'),
            ),
            _MenuItemData(
              icon: Icons.logout_rounded,
              title: 'Logout',
              subtitle: 'Securely sign out',
              iconColor: AppColors.errorRed,
              onTap: () => _handleLogout(context, ref),
              showArrow: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuGroup({
    required String title,
    required List<_MenuItemData> items,
  }) {
    return Padding(
      padding: AppSpacing.paddingH16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              title,
              style: AppTypography.overline.copyWith(
                color: AppColors.neutral500,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          PremiumCard(
            style: PremiumCardStyle.elevated,
            padding: EdgeInsets.zero,
            child: Column(
              children: List.generate(items.length, (index) {
                final item = items[index];
                return Column(
                  children: [
                    _buildMenuItem(item),
                    if (index < items.length - 1)
                      Padding(
                        padding: const EdgeInsets.only(left: 64.0),
                        child: Divider(height: 1, color: AppColors.neutral200),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(_MenuItemData item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      item.subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.showArrow)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.neutral400,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text('$feature coming soon!'),
          ],
        ),
        backgroundColor: AppColors.primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorRed,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await NotificationService().clearFcmToken();
      } catch (e) {
        debugPrint('Error clearing FCM token: $e');
      }

      await Supabase.instance.client.auth.signOut();
      
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;
  final bool showArrow;

  const _MenuItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
    this.showArrow = true,
  });
}

class ShimmerLoading extends StatelessWidget {
  final double height;
  const ShimmerLoading({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: AppSpacing.paddingH16,
      decoration: BoxDecoration(
        color: AppColors.neutral200,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
