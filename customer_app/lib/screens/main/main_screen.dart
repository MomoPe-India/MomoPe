import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/notification_service.dart';
import '../home/home_screen.dart';
import '../transactions/transaction_history_screen.dart';
import '../profile/profile_screen.dart';
import '../explore/explore_screen.dart';
import '../qr_scanner/qr_scanner_screen.dart';

/// Main screen with premium 5-tab bottom navigation
/// Tabs: Home | Explore | Scan | Activity | Profile
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize FCM notifications after user is authenticated
    NotificationService().initialize();

    _screens = [
      HomeScreen(onProfileTap: () => setState(() => _currentIndex = 4)),
      const ExploreScreen(),
      const SizedBox.shrink(), // Scan tab handled separately
      const TransactionHistoryScreen(),
      const ProfileScreen(),
    ];
  }

  final List<_NavItem> _navItems = const [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
      label: 'Explore',
    ),
    _NavItem(
      icon: Icons.qr_code_scanner_rounded,
      activeIcon: Icons.qr_code_scanner_rounded,
      label: 'Scan',
    ),
    _NavItem(
      icon: Icons.history_rounded,
      activeIcon: Icons.history,
      label: 'History',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return false;
        }
        // Show exit confirmation on home tab
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit MomoPe?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                  SystemNavigator.pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.errorRed,
                ),
                child: const Text('Exit'),
              ),
            ],
          ),
        ) ?? false;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: (_currentIndex == 4
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark)
            .copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: _buildPremiumBottomNavBar(),
        ),
      ),
    );
  }

  Widget _buildPremiumBottomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          // Sophisticated layered shadows for premium "lift"
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
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
    final isScanTab = index == 2;

    if (isScanTab) {
      return Expanded(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.heavyImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const QRScannerScreen(),
              ),
            );
          },
          child: Transform.translate(
            offset: const Offset(0, -12),
            child: Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  // Active glow effect
                  BoxShadow(
                    color: AppColors.primaryTeal.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _currentIndex = index);
          },
          splashColor: AppColors.primaryTeal.withOpacity(0.1),
          highlightColor: AppColors.primaryTeal.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? item.activeIcon : item.icon,
                  color: isActive ? AppColors.primaryTeal : AppColors.neutral400,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: AppTypography.bodySmall.copyWith(
                    color: isActive ? AppColors.primaryTeal : AppColors.neutral400,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
