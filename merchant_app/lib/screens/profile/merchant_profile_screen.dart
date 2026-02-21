import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../services/notification_service.dart';
import '../../providers/merchant_provider.dart';
import '../../models/merchant.dart';

/// Merchant Profile Screen
/// Shows business info, settings, and logout option
class MerchantProfileScreen extends ConsumerWidget {
  const MerchantProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final merchantAsync = ref.watch(merchantProvider);

    return Scaffold(
      body: merchantAsync.when(
        data: (merchant  ) {
          if (merchant == null) {
            return const Center(child: Text('No merchant profile found'));
          }

          return CustomScrollView(
            slivers: [
              // Premium Header
              _buildHeader(context, merchant),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.paddingAll16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Business Details Section
                      _buildBusinessDetails(merchant),

                      const SizedBox(height: AppSpacing.space24),

                      // Banking Section
                      if (merchant.bankAccountNumber != null)
                        _buildBankingSection(merchant),

                      const SizedBox(height: AppSpacing.space24),

                      // Settings Section
                      _buildSettingsSection(context),

                      const SizedBox(height: AppSpacing.space24),

                      // Logout Button
                      _buildLogoutButton(context),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, __) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Merchant merchant) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.secondaryNavy,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
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
              top: -60,
              right: -60,
              child: CircleAvatar(
                radius: 120,
                backgroundColor: AppColors.primaryTeal.withOpacity(0.08),
              ),
            ),

            // Profile info content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    // Glassmorphism Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryTeal.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              _getCategoryIcon(merchant.category),
                              color: AppColors.primaryTeal,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  merchant.businessName,
                                  style: AppTypography.headlineSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildBadge(
                                      _getCategoryLabel(merchant.category),
                                      Colors.white.withOpacity(0.15),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildBadge(
                                      '${merchant.commissionRate.toStringAsFixed(0)}% RATE',
                                      AppColors.primaryTeal.withOpacity(0.3),
                                      textColor: AppColors.primaryTealLight,
                                    ),
                                  ],
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color bgColor, {Color textColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildBusinessDetails(Merchant merchant) {
    return PremiumCard(
      style: PremiumCardStyle.elevated,
      child: Padding(
        padding: AppSpacing.paddingAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BUSINESS DETAILS',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.neutral500,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.space16),
            
            if (merchant.businessAddress != null)
              _buildDetailRow(
                'Address',
                merchant.businessAddress!,
                Icons.location_on_outlined,
              ),
            
            if (merchant.gstin != null) ...[
              _buildDivider(),
              _buildDetailRow(
                'GSTIN',
                merchant.gstin!,
                Icons.receipt_long_rounded,
              ),
            ],

            if (merchant.pan != null) ...[
              _buildDivider(),
              _buildDetailRow(
                'PAN',
                merchant.pan!,
                Icons.credit_card_rounded,
              ),
            ],

            _buildDivider(),
            _buildDetailRow(
              'Commission Rate',
              '${merchant.commissionRate.toStringAsFixed(0)}%',
              Icons.percent_rounded,
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neutral200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'View Only',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral600,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankingSection(Merchant merchant) {
    final maskedAccount = _maskAccountNumber(merchant.bankAccountNumber!);

    return PremiumCard(
      style: PremiumCardStyle.elevated,
      child: Padding(
        padding: AppSpacing.paddingAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'BANKING DETAILS',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to edit banking screen
                  },
                  child: const Text('Update'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space16),
            
            _buildDetailRow(
              'Account Holder',
              merchant.bankAccountHolderName ?? 'Not provided',
              Icons.person_rounded,
            ),
            _buildDivider(),
            _buildDetailRow(
              'Account Number',
              maskedAccount,
              Icons.account_balance_rounded,
            ),
            _buildDivider(),
            _buildDetailRow(
              'IFSC Code',
              merchant.ifscCode ?? 'Not provided',
              Icons.qr_code_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return PremiumCard(
      style: PremiumCardStyle.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSpacing.paddingAll16,
            child: Text(
              'SETTINGS',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.neutral500,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _buildSettingTile(
            'Support',
            'Get help and contact support',
            Icons.support_agent_rounded,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Support: help@momope.com'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingTile(
            'Terms of Service',
            'Read our terms and conditions',
            Icons.description_rounded,
            () {
              // TODO: Open terms screen
            },
          ),
          const Divider(height: 1),
          _buildSettingTile(
            'Privacy Policy',
            'Learn how we protect your data',
            Icons.privacy_tip_rounded,
            () {
              // TODO: Open privacy screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryTeal),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.neutral600,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: AppColors.neutral400,
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return PremiumButton(
      text: 'Logout',
      icon: Icons.logout_rounded,
      onPressed: () => _showLogoutDialog(context),
      style: PremiumButtonStyle.secondary,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Clear FCM token before signing out
              try {
                await NotificationService().clearFcmToken();
              } catch (e) {
                debugPrint('Error clearing FCM token: $e');
              }

              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                // Navigate to root and let auth state handle showing login screen
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    {Widget? trailing,}
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.neutral600),
        const SizedBox(width: AppSpacing.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.space12),
      child: Divider(color: AppColors.neutral300, height: 1),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'food_beverage':
        return Icons.restaurant_rounded;
      case 'grocery':
        return Icons.shopping_cart_rounded;
      case 'retail':
        return Icons.shopping_bag_rounded;
      case 'services':
        return Icons.build_rounded;
      default:
        return Icons.store_rounded;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'food_beverage':
        return 'Food & Beverage';
      case 'grocery':
        return 'Grocery';
      case 'retail':
        return 'Retail';
      case 'services':
        return 'Services';
      default:
        return 'Other';
    }
  }

  String _maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) return accountNumber;
    final lastFour = accountNumber.substring(accountNumber.length - 4);
    return '****$lastFour';
  }
}
