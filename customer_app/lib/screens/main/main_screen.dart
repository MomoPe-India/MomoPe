import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
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
  
  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    SizedBox.shrink(), // Scan tab handled separately
    TransactionHistoryScreen(),
    ProfileScreen(),
  ];

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
      child: Scaffold(
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
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
    final isScanTab = index == 2; // Center scan tab

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            if (isScanTab) {
              // Open QR scanner as full screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QRScannerScreen(),
                ),
              );
            } else {
              setState(() => _currentIndex = index);
            }
          },
          splashColor: AppColors.primaryTeal.withOpacity(0.1),
          highlightColor: AppColors.primaryTeal.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? item.activeIcon : item.icon,
                  color: isActive
                      ? AppColors.primaryTeal
                      : AppColors.neutral400,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: AppTypography.bodySmall.copyWith(
                    color: isActive
                        ? AppColors.primaryTeal
                        : AppColors.neutral400,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
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
