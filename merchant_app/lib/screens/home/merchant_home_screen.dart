import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.primaryTeal,
        unselectedItemColor: AppColors.neutral600,
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_rounded),
            label: 'QR Code',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Settlement',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

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
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.errorRed,
              ),
              const SizedBox(height: AppSpacing.space16),
              Text(
                'Merchant not found',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.neutral900,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Premium Header with Gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Column(
                  children: [
                    // App Bar
                    Padding(
                      padding: AppSpacing.paddingAll16,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.store,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.space12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Payment QR Code',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                Text(
                                  _merchant!.businessName,
                                  style: AppTypography.titleLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white),
                            onPressed: () async {
                              final authService = ref.read(authServiceProvider);
                              await authService.signOut();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    
                    // Business Info
                    Padding(
                      padding: AppSpacing.paddingH16,
                      child: Row(
                        children: [
                          // Category Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getCategoryIcon(_merchant!.category),
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _formatCategory(_merchant!.category),
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.space12),
                          // Commission Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.goldGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.percent,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${(_merchant!.commissionRate * 100).toStringAsFixed(0)}%',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space24),
                  ],
                ),
              ),

              // QR Code Card
              Padding(
                padding: AppSpacing.paddingAll24,
                child: Column(
                  children: [
                    PremiumCard(
                      style: PremiumCardStyle.elevated,
                      child: Column(
                        children: [
                          Text(
                            'Show this QR to customers',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'They scan to pay instantly',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.neutral600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space24),
                          
                          // QR Code with Glass Effect
                          Container(
                            padding: AppSpacing.paddingAll24,
                            decoration: BoxDecoration(
                              gradient: AppColors.glassGradient,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.primaryTeal.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: QrImageView(
                              data: 'momope://merchant/${_merchant!.id}',
                              version: QrVersions.auto,
                              size: 240.0,
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
                          
                          const SizedBox(height: AppSpacing.space24),
                          
                          // Merchant ID
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.neutral100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.fingerprint,
                                  size: 18,
                                  color: AppColors.neutral600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'ID: ${_merchant!.id.substring(0, 8)}...',
                                  style: AppTypography.bodySmall.copyWith(
                                    fontFamily: 'monospace',
                                    color: AppColors.neutral700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.download_rounded,
                            label: 'Download',
                            onTap: _isProcessing ? null : _downloadQr,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.share_rounded,
                            label: 'Share',
                            onTap: _isProcessing ? null : _shareQr,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.photo_library_rounded,
                            label: 'Gallery',
                            onTap: _isProcessing ? null : _saveToGallery,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSpacing.space24),
                    
                    // Info Card
                    PremiumCard(
                      style: PremiumCardStyle.outlined,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryTeal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.info_outline,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.space16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quick Tip',
                                  style: AppTypography.titleSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Print this QR and display at your counter for easy payments',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.neutral600,
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
    );
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

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: isDisabled ? null : AppColors.primaryGradient,
            color: isDisabled ? AppColors.neutral300 : null,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isDisabled ? null : [
              BoxShadow(
                color: AppColors.primaryTeal.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isDisabled ? AppColors.neutral500 : Colors.white,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: isDisabled ? AppColors.neutral500 : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
