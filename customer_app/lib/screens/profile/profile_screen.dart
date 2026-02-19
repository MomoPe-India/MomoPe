import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/widgets/widgets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
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

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              _buildProfileHeader(context, user),
              
              const SizedBox(height: 16),
              
              // Account Stats
              _buildAccountStats(coinBalanceAsync),
              
              const SizedBox(height: 24),
              
              // Menu Items
              _buildMenuSection(context, ref, user),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, User? user) {
    final displayName = user?.userMetadata?['full_name'] ?? 
                       user?.userMetadata?['name'] ?? 
                       'MomoPe User';
    final email = user?.email ?? '';
    final phone = user?.phone ?? user?.userMetadata?['phone'] ?? '';

    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingAll24,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                displayName.substring(0, 1).toUpperCase(),
                style: AppTypography.displayLarge.copyWith(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Name
          Text(
            displayName,
            style: AppTypography.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Contact Info
          if (phone.isNotEmpty)
            Text(
              phone,
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              email,
              style: AppTypography.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Edit Profile Button
          PremiumButton(
            text: 'Edit Profile',
            icon: Icons.edit_outlined,
            onPressed: () {
              // TODO: Navigate to edit profile screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit profile coming soon!')),
              );
            },
            style: PremiumButtonStyle.secondary,
          ),
        ],
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
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.stars_rounded,
                  iconColor: AppColors.rewardsGold,
                  label: 'Total Coins Earned',
                  value: totalCoins.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: AppColors.primaryTeal,
                  label: 'Available',
                  value: availableCoins.toString(),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return PremiumCard(
      style: PremiumCardStyle.elevated,
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.neutral600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, WidgetRef ref, User? user) {
    return Padding(
      padding: AppSpacing.paddingH16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 12),
          
          PremiumCard(
            style: PremiumCardStyle.elevated,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildMenuItem(
                  context: context,
                  icon: Icons.verified_user_outlined,
                  iconColor: AppColors.primaryTeal,
                  title: 'KYC Verification',
                  subtitle: 'Complete verification',
                  onTap: () => _showComingSoon(context, 'KYC verification'),
                ),
                _buildDivider(),
                _buildMenuItem(
                  context: context,
                  icon: Icons.credit_card_outlined,
                  iconColor: AppColors.primaryTeal,
                  title: 'Payment Methods',
                  subtitle: 'Manage UPI & cards',
                  onTap: () => _showComingSoon(context, 'Payment methods'),
                ),
                _buildDivider(),
                _buildMenuItem(
                  context: context,
                  icon: Icons.notifications_outlined,
                  iconColor: AppColors.primaryTeal,
                  title: 'Notifications',
                  subtitle: 'Alerts & updates',
                  onTap: () => _showComingSoon(context, 'Notifications'),
                ),
                _buildDivider(),
                _buildMenuItem(
                  context: context,
                  icon: Icons.card_giftcard_outlined,
                  iconColor: AppColors.rewardsGold,
                  title: 'Referral Program',
                  subtitle: 'Invite & earn rewards',
                  onTap: () => _showComingSoon(context, 'Referral program'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Support',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 12),
          
          PremiumCard(
            style: PremiumCardStyle.elevated,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildMenuItem(
                  context: context,
                  icon: Icons.help_outline,
                  iconColor: AppColors.neutral600,
                  title: 'Help & Support',
                  subtitle: 'FAQs & contact us',
                  onTap: () => _showComingSoon(context, 'Help & support'),
                ),
                _buildDivider(),
                _buildMenuItem(
                  context: context,
                  icon: Icons.settings_outlined,
                  iconColor: AppColors.neutral600,
                  title: 'Settings',
                  subtitle: 'App preferences',
                  onTap: () => _showComingSoon(context, 'Settings'),
                ),
                _buildDivider(),
                _buildMenuItem(
                  context: context,
                  icon: Icons.logout,
                  iconColor: AppColors.errorRed,
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  onTap: () => _handleLogout(context, ref),
                  showArrow: false,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // App Version
          Center(
            child: Text(
              'MomoPe v1.0.0',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.neutral500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.paddingAll16,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              if (showArrow)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.neutral400,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 72),
      child: Divider(
        height: 1,
        color: AppColors.neutral200,
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: AppColors.primaryTeal,
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
