// lib/shared/widgets/merchant_scaffold.dart
//
// Shell scaffold for the Merchant App with a Floating Pill Bottom Nav.
//
// Mirrors the same floating-pill design language as the Customer App,
// adapted to the Merchant App's 4-tab layout and MerchantTheme colors.
//
// Design:
//   - Floating pill detached from edges (20 px sides, 16 px above safe-area)
//   - Glass blur backdrop in dark mode (merchant app is always dark)
//   - Active tab: tinted pill indicator + bold label
//   - Centre "QR" tab acts as a primary CTA with gradient glow
//   - Scale micro-interaction on press

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart'; // MerchantTheme

// ── Navigation item descriptor ────────────────────────────────────────────────

class _MNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final bool isCta;
  const _MNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    this.isCta = false,
  });
}

const _kMItems = [
  _MNavItem(icon: Icons.store_outlined,         activeIcon: Icons.store_rounded,          label: 'Home',     route: '/home'),
  _MNavItem(icon: Icons.receipt_long_outlined,  activeIcon: Icons.receipt_long_rounded,   label: 'Payments', route: '/transactions'),
  _MNavItem(icon: Icons.qr_code_rounded,        activeIcon: Icons.qr_code_rounded,        label: 'My QR',    route: '/home', isCta: true),
  _MNavItem(icon: Icons.verified_outlined,      activeIcon: Icons.verified_rounded,       label: 'KYC',      route: '/kyc'),
  _MNavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded,         label: 'Profile',  route: '/profile'),
];

// ── Shell scaffold ────────────────────────────────────────────────────────────

class MerchantScaffold extends ConsumerWidget {
  final Widget child;
  const MerchantScaffold({super.key, required this.child});

  int _idx(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    if (loc.startsWith('/home'))         return 0;
    if (loc.startsWith('/transactions')) return 1;
    if (loc.startsWith('/kyc'))          return 3;
    if (loc.startsWith('/profile'))      return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = _idx(context);
    return Scaffold(
      extendBody: true,
      backgroundColor: MerchantTheme.bg,
      body: child,
      bottomNavigationBar: _MerchantPillBar(
        currentIndex: current,
        onTap: (i) {
          HapticFeedback.selectionClick();
          switch (i) {
            case 0: context.go('/home');
            case 1: context.go('/transactions');
            case 2: break; // QR tapped — handled by home screen
            case 3: context.go('/kyc');
            case 4: context.go('/profile');
          }
        },
      ),
    );
  }
}

// ── Floating pill bar ─────────────────────────────────────────────────────────

class _MerchantPillBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _MerchantPillBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              // Dark glass style — merchant app is always dark
              color: MerchantTheme.surface.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: MerchantTheme.surfaceAlt.withValues(alpha: 0.50),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 34,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: MerchantTheme.primary.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: List.generate(
                _kMItems.length,
                (i) => _MNavTile(
                  item: _kMItems[i],
                  isActive: currentIndex == i,
                  onTap: () => onTap(i),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Individual tile ───────────────────────────────────────────────────────────

class _MNavTile extends StatefulWidget {
  final _MNavItem item;
  final bool isActive;
  final VoidCallback onTap;
  const _MNavTile({required this.item, required this.isActive, required this.onTap});

  @override
  State<_MNavTile> createState() => _MNavTileState();
}

class _MNavTileState extends State<_MNavTile> with SingleTickerProviderStateMixin {
  late AnimationController _scale;

  @override
  void initState() {
    super.initState();
    _scale = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 130),
        lowerBound: 0.88,
        upperBound: 1.0)
      ..value = 1.0;
  }

  @override
  void dispose() { _scale.dispose(); super.dispose(); }

  void _down(_) => _scale.reverse();
  void _up(_)   => _scale.forward();
  void _cancel() => _scale.forward();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: _down,
        onTapUp: _up,
        onTapCancel: _cancel,
        child: ScaleTransition(
          scale: _scale,
          child: widget.item.isCta
              ? _MCtaTab(isActive: widget.isActive)
              : _MStdTab(item: widget.item, isActive: widget.isActive),
        ),
      ),
    );
  }
}

class _MStdTab extends StatelessWidget {
  final _MNavItem item;
  final bool isActive;
  const _MStdTab({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
              horizontal: isActive ? 14 : 10, vertical: 4),
          decoration: BoxDecoration(
            color: isActive
                ? MerchantTheme.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            isActive ? item.activeIcon : item.icon,
            size: 22,
            color: isActive
                ? MerchantTheme.primary
                : MerchantTheme.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? MerchantTheme.primary : MerchantTheme.textMuted,
            letterSpacing: 0.1,
            height: 1,
          ),
          child: Text(item.label),
        ),
      ],
    );
  }
}

class _MCtaTab extends StatelessWidget {
  final bool isActive;
  const _MCtaTab({required this.isActive});

  static const _gradient = LinearGradient(
    colors: [Color(0xFF2CB78A), Color(0xFF2DBCAF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutBack,
          width: isActive ? 52 : 48,
          height: isActive ? 52 : 48,
          decoration: BoxDecoration(
            gradient: _gradient,
            borderRadius: BorderRadius.circular(isActive ? 18 : 15),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2CB78A).withValues(
                    alpha: isActive ? 0.55 : 0.25),
                blurRadius: isActive ? 22 : 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(Icons.qr_code_rounded,
              color: Colors.white, size: isActive ? 26 : 24),
        ),
        const SizedBox(height: 2),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? MerchantTheme.primary : MerchantTheme.textMuted,
            letterSpacing: 0.1,
            height: 1,
          ),
          child: const Text('My QR'),
        ),
      ],
    );
  }
}
