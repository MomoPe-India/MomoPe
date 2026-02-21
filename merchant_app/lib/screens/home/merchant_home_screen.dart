import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../models/merchant.dart';
import '../../providers/auth_provider.dart';
import '../../services/qr_service.dart';
import '../merchant_dashboard_screen.dart';
import '../transactions/merchant_transaction_history_screen.dart';
import '../analytics/merchant_analytics_screen.dart';
import '../settlements/merchant_settlement_screen.dart';
import '../profile/merchant_profile_screen.dart';

class MerchantHomeScreen extends ConsumerStatefulWidget {
  const MerchantHomeScreen({super.key});

  @override
  ConsumerState<MerchantHomeScreen> createState() => _MerchantHomeScreenState();
}

class _MerchantHomeScreenState extends ConsumerState<MerchantHomeScreen> {
  int _currentIndex = 0; // Start with Dashboard

  final List<Widget> _screens = const [
    MerchantDashboardScreen(),
    QRCodeScreen(),
    MerchantTransactionHistoryScreen(),
    MerchantAnalyticsScreen(),
    MerchantSettlementScreen(),
    MerchantProfileScreen(),
  ];

  final List<_MerchantNavItem> _navItems = const [
    _MerchantNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    _MerchantNavItem(
      icon: Icons.qr_code_2_rounded,
      activeIcon: Icons.qr_code_2_rounded,
      label: 'QR Code',
    ),
    _MerchantNavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'Activity',
    ),
    _MerchantNavItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics_rounded,
      label: 'Insights',
    ),
    _MerchantNavItem(
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
      label: 'Settlement',
    ),
    _MerchantNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.neutral100,
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: _buildPremiumBottomNavBar(),
      ),
    );
  }

  Widget _buildPremiumBottomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
              (index) => _buildNavItem(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isActive = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _currentIndex = index);
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isActive ? item.activeIcon : item.icon,
                  key: ValueKey('nav_icon_${index}_$isActive'),
                  color: isActive ? AppColors.primaryTeal : AppColors.neutral400,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: AppTypography.labelSmall.copyWith(
                  color: isActive ? AppColors.primaryTeal : AppColors.neutral400,
                  fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                  fontSize: 9,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MerchantNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _MerchantNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

/// Premium QR Code Screen with MomoPe branding
class QRCodeScreen extends ConsumerStatefulWidget {
  const QRCodeScreen({super.key});

  @override
  ConsumerState<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends ConsumerState<QRCodeScreen> {
  Merchant? _merchant;
  bool _isLoading = true;
  final QrService _qrService = QrService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadMerchantData();
  }

  Future<void> _loadMerchantData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('merchants')
          .select()
          .eq('user_id', user.id)
          .single();

      setState(() {
        _merchant = Merchant.fromJson(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadQr() async {
    if (_merchant == null || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final path = await _qrService.downloadQr(
        merchantId: _merchant!.id,
        merchantName: _merchant!.businessName,
      );

      if (!mounted) return;

      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR code downloaded!\n$path'),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        throw Exception('Failed to download QR code');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _shareQr() async {
    if (_merchant == null || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final success = await _qrService.shareQr(
        merchantId: _merchant!.id,
        merchantName: _merchant!.businessName,
      );

      if (!mounted) return;

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Share cancelled'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing: $e'),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _saveToGallery() async {
    if (_merchant == null || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final success = await _qrService.saveToGallery(
        merchantId: _merchant!.id,
        merchantName: _merchant!.businessName,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR code saved to gallery!'),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission required. Please enable in settings.'),
            backgroundColor: AppColors.warningAmber,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving: $e'),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  void dispose() {
    _qrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.neutral100,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryTeal),
        ),
      );
    }

    if (_merchant == null) {
      return Scaffold(
        backgroundColor: AppColors.neutral100,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.errorRed,
              ),
              const SizedBox(height: AppSpacing.space16),
              Text(
                'Merchant not found',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.neutral900,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.neutral100,
        body: Column(
          children: [
            // Premium Header with Gradient
            Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryTeal,
                    AppColors.primaryTealDark,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                      ),
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PAYMENT QR CODE',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            _merchant!.businessName,
                            style: AppTypography.titleLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                      ),
                      onPressed: () async {
                        final authService = ref.read(authServiceProvider);
                        await authService.signOut();
                      },
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // QR Code Card
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Accept Payments',
                                  style: AppTypography.titleLarge.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.neutral900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Customers scan to pay instantly',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.neutral500,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                
                                // QR Code Container
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: AppColors.primaryTeal.withOpacity(0.15),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryTeal.withOpacity(0.05),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: QrImageView(
                                    data: 'momope://merchant/${_merchant!.id}',
                                    version: QrVersions.auto,
                                    size: 220.0,
                                    backgroundColor: Colors.transparent,
                                    eyeStyle: const QrEyeStyle(
                                      eyeShape: QrEyeShape.square,
                                      color: AppColors.primaryTeal,
                                    ),
                                    dataModuleStyle: const QrDataModuleStyle(
                                      dataModuleShape: QrDataModuleShape.square,
                                      color: AppColors.neutral900,
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 32),
                                
                                // Merchant ID
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.neutral100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.verified_user_rounded,
                                        size: 16,
                                        color: AppColors.primaryTeal,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'MERCHANT ID: ${_merchant!.id.substring(0, 8)}',
                                        style: AppTypography.labelSmall.copyWith(
                                          fontFamily: 'monospace',
                                          color: AppColors.neutral600,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.file_download_outlined,
                                  label: 'Download',
                                  onTap: _isProcessing ? null : _downloadQr,
                                  color: AppColors.primaryTeal,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.share_outlined,
                                  label: 'Share',
                                  onTap: _isProcessing ? null : _shareQr,
                                  color: AppColors.secondaryNavy,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Quick Info
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.neutral200),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.rewardsGold.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.lightbulb_outline_rounded,
                                    color: AppColors.rewardsGold,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'PRO TIP',
                                        style: AppTypography.labelSmall.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.neutral500,
                                        ),
                                      ),
                                      Text(
                                        'Display a printed QR at your counter for 2x faster checkouts.',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.neutral600,
                                          fontWeight: FontWeight.w500,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'grocery':
        return Icons.shopping_cart_rounded;
      case 'food_beverage':
        return Icons.restaurant_rounded;
      case 'retail':
        return Icons.shopping_bag_rounded;
      case 'services':
        return Icons.build_rounded;
      default:
        return Icons.store_rounded;
    }
  }

  String _formatCategory(String category) {
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
}

/// Action Button Widget for QR actions
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isDisabled ? AppColors.neutral200 : color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isDisabled ? null : [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isDisabled ? AppColors.neutral500 : Colors.white,
                size: 26,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: isDisabled ? AppColors.neutral500 : Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
