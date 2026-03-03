// lib/shared/widgets/main_scaffold.dart
//
// Shell scaffold with a clean, fixed full-width bottom navigation bar.
//
// Design:
//   - Fixed to screen bottom edge, edge-to-edge
//   - Active tab: filled icon + brand-green label (no pill/gradient chip)
//   - Centre Pay tab: solid brand-green circle, slightly raised
//   - Inactive tabs: outlined icons, muted grey label
//   - Scale micro-interaction on press (0.90→1.0 in 130 ms)
//   - Subtle top border separator for depth

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';

// ── Navigation item descriptor ────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final bool isCta;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    this.isCta = false,
  });
}

const _kItems = [
  _NavItem(icon: Icons.home_outlined,          activeIcon: Icons.home_rounded,            label: 'Home',    route: '/home'),
  _NavItem(icon: Icons.explore_outlined,       activeIcon: Icons.explore_rounded,         label: 'Explore', route: '/explore'),
  _NavItem(icon: Icons.qr_code_scanner_rounded, activeIcon: Icons.qr_code_scanner_rounded, label: 'Pay',   route: '/scan', isCta: true),
  _NavItem(icon: Icons.receipt_long_outlined,   activeIcon: Icons.receipt_long_rounded,    label: 'History', route: '/transactions'),
  _NavItem(icon: Icons.person_outline_rounded,  activeIcon: Icons.person_rounded,          label: 'Profile', route: '/profile'),
];

// ── Shell scaffold ────────────────────────────────────────────────────────────

class MainScaffold extends ConsumerWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    for (int i = 0; i < _kItems.length; i++) {
      if (loc.startsWith(_kItems[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = _currentIndex(context);
    return Scaffold(
      extendBody: false,
      backgroundColor: context.theme.bg,
      body: child,
      bottomNavigationBar: _BottomBar(
        currentIndex: current,
        onTap: (i) {
          HapticFeedback.selectionClick();
          context.go(_kItems[i].route);
        },
      ),
    );
  }
}

// ── Bottom bar container ──────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? context.theme.surface : context.theme.card,
        border: Border(
          top: BorderSide(
            color: context.theme.surfaceAlt.withValues(alpha: 0.6),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: List.generate(
              _kItems.length,
              (i) => _NavTile(
                item: _kItems[i],
                isActive: currentIndex == i,
                onTap: () => onTap(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Individual nav tile ───────────────────────────────────────────────────────

class _NavTile extends StatefulWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;
  const _NavTile({required this.item, required this.isActive, required this.onTap});

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> with SingleTickerProviderStateMixin {
  late AnimationController _scale;

  @override
  void initState() {
    super.initState();
    _scale = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      lowerBound: 0.90,
      upperBound: 1.0,
    )..value = 1.0;
  }

  @override
  void dispose() { _scale.dispose(); super.dispose(); }

  void _onDown(_) => _scale.reverse();
  void _onUp(_)   => _scale.forward();
  void _onCancel() => _scale.forward();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: _onDown,
        onTapUp: _onUp,
        onTapCancel: _onCancel,
        child: ScaleTransition(
          scale: _scale,
          child: widget.item.isCta
              ? _CtaTab(isActive: widget.isActive)
              : _StdTab(item: widget.item, isActive: widget.isActive),
        ),
      ),
    );
  }
}

// Standard tab — WhatsApp-inspired
class _StdTab extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  const _StdTab({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final iconColor  = isActive ? context.theme.primary : context.theme.textMuted;
    final labelColor = isActive ? context.theme.primary : context.theme.textMuted;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isActive ? item.activeIcon : item.icon,
          size: 22,
          color: iconColor,
        ),
        const SizedBox(height: 2),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: labelColor,
            letterSpacing: 0.1,
            height: 1.0,
          ),
          child: Text(item.label, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

// Centre gradient CTA tab
class _CtaTab extends StatelessWidget {
  final bool isActive;
  const _CtaTab({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: 42,   // was 46 — fits in 56px bar with label
          height: 42,  // was 46
          decoration: BoxDecoration(
            gradient: context.theme.coinGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: context.theme.primary.withValues(
                    alpha: isActive ? 0.45 : 0.22),
                blurRadius: isActive ? 16 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.qr_code_scanner_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 1),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(
            fontSize: 9,   // slightly smaller for CTA to avoid overflow
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: isActive ? context.theme.primary : context.theme.textMuted,
            letterSpacing: 0.1,
            height: 1.0,
          ),
          child: const Text('Pay'),
        ),
      ],
    );
  }
}
