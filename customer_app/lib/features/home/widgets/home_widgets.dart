// lib/features/home/widgets/home_widgets.dart
//
// Reusable widgets for the Home Screen.
// All widgets are fully theme-aware (Light & Dark modes).

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/models.dart';
import '../../../core/theme.dart';

// ── 1. Coin Balance Hero Card ─────────────────────────────────────────────────

class CoinBalanceCard extends StatefulWidget {
  final CoinBalance balance;
  final double todayEarnings;
  const CoinBalanceCard({
    super.key, 
    required this.balance,
    required this.todayEarnings,
  });

  @override
  State<CoinBalanceCard> createState() => _CoinBalanceCardState();
}

class _CoinBalanceCardState extends State<CoinBalanceCard>
    with SingleTickerProviderStateMixin {
  bool _balanceVisible = true;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _countAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn));

    // Dynamic count-up animation for the balance
    _countAnim = Tween<double>(begin: 0, end: widget.balance.availableCoins)
        .animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic));

    _fadeCtrl.forward();
  }

  @override
  void didUpdateWidget(covariant CoinBalanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.balance.availableCoins != widget.balance.availableCoins) {
      _countAnim = Tween<double>(
              begin: oldWidget.balance.availableCoins,
              end: widget.balance.availableCoins)
          .animate(
              CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic));
      _fadeCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _toggleVisibility() {
    setState(() => _balanceVisible = !_balanceVisible);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.##');

    return AnimatedBuilder(
      animation: _fadeCtrl,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnim.value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00C48C),
                  const Color(0xFF00896A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00C48C).withValues(alpha: 0.45),
                  blurRadius: 48,
                  spreadRadius: -6,
                  offset: const Offset(0, 20),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.toll_rounded,
                            color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      const Text('Momo Coins',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2)),
                    ]),
                    GestureDetector(
                      onTap: _toggleVisibility,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _balanceVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Balance amount + ₹ equivalent
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: _balanceVisible
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fmt.format(_countAnim.value),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2.5,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '≈ ₹${fmt.format(_countAnim.value)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.70),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                  secondChild: const Text(
                    '••••',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 10),
                  ),
                ),

                const SizedBox(height: 16),

                // Today badge + locked badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_upward_rounded,
                              color: Colors.white, size: 11),
                          const SizedBox(width: 3),
                          Text(
                            '+${fmt.format(widget.todayEarnings)} today',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    if (widget.balance.lockedCoins > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock_rounded,
                                color: Colors.orangeAccent, size: 11),
                            const SizedBox(width: 3),
                            Text(
                              '${fmt.format(widget.balance.lockedCoins)} locked',
                              style: const TextStyle(
                                  color: Colors.orangeAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 16),

                // Divider
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.18),
                ),

                const SizedBox(height: 14),

                // Available / Locked split row
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: _balanceVisible
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Row(
                    children: [
                      Expanded(child: _buildMiniBalance(
                          fmt.format(widget.balance.availableCoins), 'Available', true)),
                      Container(
                        width: 1, height: 32,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      Expanded(child: _buildMiniBalance(
                          fmt.format(widget.balance.lockedCoins), 'Locked', false)),
                    ],
                  ),
                  secondChild: Row(
                    children: [
                      Expanded(child: _buildMiniBalance('•••', 'Available', true)),
                      Container(
                        width: 1, height: 32,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      Expanded(child: _buildMiniBalance('•••', 'Locked', false)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniBalance(String amount, String label, bool isLeft) {
    return Padding(
      padding: EdgeInsets.only(left: isLeft ? 0 : 20, right: isLeft ? 20 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 2. Quick Action Grid ──────────────────────────────────────────────────────

class QuickActionGrid extends StatelessWidget {
  final List<QuickAction> actions;
  const QuickActionGrid({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((a) => Expanded(
        child: _QuickActionTile(action: a),
      )).toList(),
    );
  }
}

class QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlight; // use brand gradient background

  const QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlight = false,
  });
}

class _QuickActionTile extends StatefulWidget {
  final QuickAction action;
  const _QuickActionTile({required this.action});

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0.95,
        upperBound: 1.0)
      ..value = 1.0;
    _scaleAnim = _scaleCtrl;
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _scaleCtrl.reverse();
  void _onTapUp(_) => _scaleCtrl.forward();
  void _onTapCancel() => _scaleCtrl.forward();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.action.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular icon container with gradient
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    context.theme.primary.withValues(alpha: 0.18),
                    context.theme.primary.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: context.theme.primary.withValues(alpha: 0.15),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.theme.primary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.action.icon,
                color: context.theme.primary,
                size: 26,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              widget.action.label,
              style: TextStyle(
                color: context.theme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.2,
                letterSpacing: 0.1,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ── 3. Expiry Warning Banner ───────────────────────────────────────────────────

class ExpiryWarningBanner extends StatelessWidget {
  final double coins;
  final VoidCallback? onTap;
  const ExpiryWarningBanner({super.key, required this.coins, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.theme.warning.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: context.theme.warning.withValues(alpha: 0.35)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.theme.warning.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.timer_outlined,
                color: context.theme.warning, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                '${coins.toStringAsFixed(0)} coins expiring soon!',
                style: TextStyle(
                    color: context.theme.warning,
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                'Use them before they expire in 7 days',
                style: TextStyle(
                    color: context.theme.warning.withValues(alpha: 0.8),
                    fontSize: 11),
              ),
            ]),
          ),
          Icon(Icons.chevron_right_rounded,
              color: context.theme.warning.withValues(alpha: 0.7), size: 20),
        ]),
      ),
    );
  }
}

// ── 4. Section Header ─────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title,
            style: TextStyle(
                color: context.theme.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2)),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: context.theme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(actionLabel!,
                  style: TextStyle(
                      color: context.theme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
          ),
      ],
    );
  }
}

// ── 5. Referral Info Card ─────────────────────────────────────────────────────

class ReferralCard extends StatelessWidget {
  final Map<String, dynamic> stats;
  final String? referralCode;
  const ReferralCard({super.key, required this.stats, this.referralCode});

  @override
  Widget build(BuildContext context) {
    final total     = (stats['total_referrals']     ?? 0) as int;
    final completed = (stats['completed_referrals'] ?? 0) as int;
    final coins     = (stats['total_coins_earned'] as num?)?.toDouble() ?? 0;
    final fmt = NumberFormat('#,##0.##');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: context.theme.surfaceAlt.withValues(alpha: 0.6)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Title
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.theme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.people_alt_outlined,
                color: context.theme.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Text('Referral Program',
              style: TextStyle(
                  color: context.theme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
        ]),

        const SizedBox(height: 16),

        // Stats row
        Row(
          children: [
            _ReferralStat(
              icon: Icons.person_add_alt_1_outlined,
              value: '$total',
              label: 'Invited',
              color: context.theme.primary,
            ),
            _ReferralDivider(),
            _ReferralStat(
              icon: Icons.check_circle_outline_rounded,
              value: '$completed',
              label: 'Completed',
              color: context.theme.success,
            ),
            _ReferralDivider(),
            _ReferralStat(
              icon: Icons.toll_rounded,
              value: fmt.format(coins),
              label: 'Coins earned',
              color: MomoPeTheme.accent,
            ),
          ],
        ),

        // Referral code chip
        if (referralCode != null) ...[
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(children: [
            Text('Your code: ',
                style: TextStyle(
                    color: context.theme.textSecondary, fontSize: 13)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: context.theme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                referralCode!,
                style: TextStyle(
                    color: context.theme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 1.5),
              ),
            ),
          ]),
        ],
      ]),
    );
  }
}

class _ReferralStat extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _ReferralStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                color: context.theme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                color: context.theme.textMuted, fontSize: 11),
            textAlign: TextAlign.center),
      ]),
    );
  }
}

class _ReferralDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: context.theme.surfaceAlt,
    );
  }
}

// ── 6. Promo / Info Banner ────────────────────────────────────────────────────

class PromoBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Map<String, dynamic>? referralStats;
  final VoidCallback? onTap;
  const PromoBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.referralStats,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.theme.surface,
              context.theme.primary.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.theme.primary.withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: context.theme.primary.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Stack(
          children: [
            // Background Watermark Icon
            Positioned(
              right: -16,
              bottom: -16,
              child: Icon(
                icon,
                size: 100,
                color: context.theme.primary.withValues(alpha: 0.03),
              ),
            ),
            // Content
            Row(children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: context.theme.coinGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: context.theme.primary.withValues(alpha: 0.30),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title,
                      style: TextStyle(
                          color: context.theme.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          color: context.theme.textSecondary, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),
                  // Tiny progress badge gamification
                  Builder(builder: (context) {
                    final int invites = referralStats?['total_referrals'] ?? 0;
                    final double coins = (referralStats?['total_coins_earned'] as num?)?.toDouble() ?? 0.0;
                    final fmt = NumberFormat('#,##0.##');
                    
                    if (invites == 0) {
                      return const SizedBox.shrink();
                    }
                    
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.theme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stars_rounded, color: context.theme.primary, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '$invites friend${invites > 1 ? 's' : ''} invited · ${fmt.format(coins)} coins earned',
                            style: TextStyle(
                                color: context.theme.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    );
                  }),
                ]),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded,
                  color: context.theme.primary.withValues(alpha: 0.6), size: 20),
            ]),
          ],
        ),
      ),
    );
  }
}

// ── 7. Recent Transactions Section ──────────────────────────────────────────────

class RecentTransactionsSection extends StatelessWidget {
  final List<dynamic> transactions;
  const RecentTransactionsSection({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) return const SizedBox.shrink();
    
    final fmt = NumberFormat('#,##0.##');
    
    return Column(
      children: transactions.map((txn) {
        final merchantName = txn['merchant_name'] as String? ?? 'Unknown Merchant';
        final fiatAmount = (txn['fiat_amount'] as num?)?.toDouble() ?? 0.0;
        final coinsApplied = (txn['coins_applied'] as num?)?.toDouble() ?? 0.0;
        final coinsEarned = (txn['coins_earned'] as num?)?.toDouble() ?? 0.0;
        final status = txn['status'] as String? ?? 'PENDING';
        final createdAtStr = txn['created_at'] as String?;
        final date = createdAtStr != null ? DateTime.parse(createdAtStr) : DateTime.now();
        
        // Format date "Feb 28, 14:30"
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final dateStr = '${months[date.month - 1]} ${date.day}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
        
        final bool isFailed = status == 'FAILED';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: context.theme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.theme.surfaceAlt.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.theme.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  color: context.theme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      merchantName,
                      style: TextStyle(
                        color: context.theme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      dateStr,
                      style: TextStyle(
                        color: context.theme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${fmt.format(fiatAmount)}',
                    style: TextStyle(
                      color: context.theme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (coinsEarned > 0)
                    Text(
                      '+${fmt.format(coinsEarned)} coins',
                      style: TextStyle(
                        color: context.theme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  else if (coinsApplied > 0)
                    Text(
                      '-${fmt.format(coinsApplied)} coins',
                      style: TextStyle(
                        color: context.theme.warning,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  else if (isFailed)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.theme.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Failed',
                        style: TextStyle(
                          color: context.theme.error,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              )
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── 8. Skeleton Loader ────────────────────────────────────────────────────────

class HomeSkeleton extends StatefulWidget {
  const HomeSkeleton({super.key});

  @override
  State<HomeSkeleton> createState() => _HomeSkeletonState();
}

class _HomeSkeletonState extends State<HomeSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _shimmerAnim =
        Tween<double>(begin: 0.4, end: 1.0).animate(_shimmerCtrl);
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  Widget _bar({double width = double.infinity, double height = 16, double radius = 8}) {
    return AnimatedBuilder(
      animation: _shimmerAnim,
      builder: (context, _) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.theme.surfaceAlt.withValues(alpha: _shimmerAnim.value),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Balance card skeleton
      Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: context.theme.surfaceAlt,
        ),
      ),
      const SizedBox(height: 24),
      // Quick actions skeleton
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(4, (_) => Column(children: [
          AnimatedBuilder(
            animation: _shimmerAnim,
            builder: (context, _) => Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: context.theme.surfaceAlt.withValues(alpha: _shimmerAnim.value),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _bar(width: 40, height: 10),
        ])),
      ),
      const SizedBox(height: 24),
      _bar(height: 90, radius: 16),
      const SizedBox(height: 12),
      _bar(height: 90, radius: 16),
    ]);
  }
}

// ── 9. Near You — Location-aware Merchant Strip ───────────────────────────────

class NearYouSection extends StatelessWidget {
  /// Merchants pre-sorted by distance from the RPC. Empty = no GPS / permission denied.
  final List<dynamic> merchants;

  /// Pass `null` to indicate permission not yet determined; pass an empty list to show the prompt.
  final bool locationGranted;

  const NearYouSection({
    super.key,
    required this.merchants,
    required this.locationGranted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(title: 'Near You'),
      const SizedBox(height: 14),
      if (!locationGranted)
        _locationPrompt(context)
      else if (merchants.isEmpty)
        _emptyMerchants(context)
      else
        _horizontalStrip(context),
    ]);
  }

  Widget _locationPrompt(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: context.theme.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.theme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.theme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.location_on_outlined, color: context.theme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'Discover merchants near you',
              style: TextStyle(
                color: context.theme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Allow location to see nearby merchants',
              style: TextStyle(color: context.theme.textMuted, fontSize: 12),
            ),
          ]),
        ),
        const SizedBox(width: 8),
        Icon(Icons.chevron_right_rounded, color: context.theme.textMuted, size: 20),
      ]),
    );
  }

  Widget _emptyMerchants(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: context.theme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.theme.surfaceAlt),
      ),
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.theme.primary.withValues(alpha: 0.1),
            ),
            alignment: Alignment.center,
            child: Text('🏙️', style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(height: 12),
          Text(
            'No merchants nearby yet',
            style: TextStyle(
              color: context.theme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'MomoPe merchants in your area will\nappear here as they join.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.theme.textMuted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: context.theme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.theme.primary.withValues(alpha: 0.2)),
            ),
            child: Text(
              'Explore Merchants',
              style: TextStyle(
                color: context.theme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _horizontalStrip(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: merchants.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _NearMerchantCard(merchant: merchants[i]),
      ),
    );
  }
}

class _NearMerchantCard extends StatelessWidget {
  final dynamic merchant;
  const _NearMerchantCard({required this.merchant});

  static const _catLabels = {
    'grocery': 'Grocery',
    'food_beverage': 'Food & Drinks',
    'retail': 'Retail',
    'services': 'Services',
    'other': 'Other',
  };

  static const _catIcons = {
    'grocery': Icons.local_grocery_store_rounded,
    'food_beverage': Icons.restaurant_rounded,
    'retail': Icons.shopping_bag_rounded,
    'services': Icons.handyman_rounded,
    'other': Icons.store_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final name = merchant['business_name'] as String? ?? 'Merchant';
    final category = merchant['category'] as String? ?? 'other';
    final distance = (merchant['distance_km'] as num?)?.toDouble();
    final label = _catLabels[category] ?? 'Other';
    final icon = _catIcons[category] ?? Icons.store_rounded;

    return Container(
      width: 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.theme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.theme.surfaceAlt),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Merchant icon circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.theme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: context.theme.primary, size: 22),
          ),
          // Name
          Text(
            name,
            style: TextStyle(
              color: context.theme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          // Category + distance badges
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              _Badge(label: label, color: context.theme.primary),
              if (distance != null)
                _Badge(
                  label: distance < 1
                      ? '${(distance * 1000).toStringAsFixed(0)} m'
                      : '${distance.toStringAsFixed(1)} km',
                  color: context.theme.textMuted,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ── 10. Featured Merchants — Always-Visible Preview ───────────────────────────

class FeaturedMerchantsSection extends StatelessWidget {
  final List<dynamic> merchants;
  final VoidCallback? onViewAll;

  const FeaturedMerchantsSection({
    super.key,
    required this.merchants,
    this.onViewAll,
  });

  static const _catLabels = {
    'grocery': 'Grocery',
    'food_beverage': 'Food & Drinks',
    'retail': 'Retail',
    'services': 'Services',
    'other': 'Other',
  };

  static const _catIcons = {
    'grocery': Icons.local_grocery_store_rounded,
    'food_beverage': Icons.restaurant_rounded,
    'retail': Icons.shopping_bag_rounded,
    'services': Icons.handyman_rounded,
    'other': Icons.store_rounded,
  };

  @override
  Widget build(BuildContext context) {
    if (merchants.isEmpty) return const SizedBox.shrink();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(
        title: 'Popular in Your Area',
        actionLabel: 'View All',
        onAction: onViewAll,
      ),
      const SizedBox(height: 14),
      ...merchants.map((m) => _FeaturedMerchantRow(
            merchant: m,
            catLabels: _catLabels,
            catIcons: _catIcons,
          )),
    ]);
  }
}

class _FeaturedMerchantRow extends StatelessWidget {
  final dynamic merchant;
  final Map<String, String> catLabels;
  final Map<String, IconData> catIcons;

  const _FeaturedMerchantRow({
    required this.merchant,
    required this.catLabels,
    required this.catIcons,
  });

  @override
  Widget build(BuildContext context) {
    final name = merchant['business_name'] as String? ?? 'Merchant';
    final category = merchant['category'] as String? ?? 'other';
    final label = catLabels[category] ?? 'Other';
    final icon = catIcons[category] ?? Icons.store_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.theme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.theme.surfaceAlt),
      ),
      child: Row(children: [
        // Icon avatar
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.theme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: context.theme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        // Name + category
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              name,
              style: TextStyle(
                color: context.theme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(color: context.theme.textMuted, fontSize: 12),
            ),
          ]),
        ),
        const SizedBox(width: 8),
        // Earn chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: context.theme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.theme.primary.withValues(alpha: 0.2)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text('🪙', style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 3),
            Text(
              'Up to 10%',
              style: TextStyle(
                color: context.theme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ── 7. Scan & Pay Promo Card ───────────────────────────────────────────────────

class ScanAndPayPromoCard extends StatefulWidget {
  final VoidCallback onTap;
  const ScanAndPayPromoCard({super.key, required this.onTap});

  @override
  State<ScanAndPayPromoCard> createState() => _ScanAndPayPromoCardState();
}

class _ScanAndPayPromoCardState extends State<ScanAndPayPromoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scale;

  @override
  void initState() {
    super.initState();
    _scale = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 120),
        lowerBound: 0.97,
        upperBound: 1.0)
      ..value = 1.0;
  }

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _scale.reverse(),
        onTapUp: (_) => _scale.forward(),
        onTapCancel: () => _scale.forward(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.theme.surface,
                context.theme.surfaceAlt,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: context.theme.primary.withValues(alpha: 0.2),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: context.theme.primary.withValues(alpha: 0.18),
                blurRadius: 28,
                spreadRadius: -2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left: gradient-backed QR icon (larger)
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: context.theme.coinGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: context.theme.primary.withValues(alpha: 0.40),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 18),
              // Middle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan. Pay & Earn',
                      style: TextStyle(
                        color: context.theme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Works with any UPI app',
                      style: TextStyle(
                        color: context.theme.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // UPI app brand circles (PhonePe, GPay, Paytm) + coins badge
                    _buildUpiRow(context),
                  ],
                ),
              ),
              // Right: gradient chevron button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: context.theme.coinGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: context.theme.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// A tight overlapping row: PhonePe -> GPay -> Paytm -> +12 brand badge
  Widget _buildUpiRow(BuildContext context) {
    const double size = 28.0;
    const double step = 20.0; // each circle starts 20px right of the previous (overlap by 8px)
    const int total = 4; // 3 UPI apps + 1 badge

    final upiApps = [
      _UpiAppInfo(label: 'P', color: const Color(0xFF5F259F)), // PhonePe
      _UpiAppInfo(label: 'G', color: const Color(0xFF1565C0)), // GPay
      _UpiAppInfo(label: 'T', color: const Color(0xFF00B9F1)), // Paytm
    ];

    Widget _circle({required Color color, Gradient? gradient, required String label}) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: gradient == null ? color : null,
          gradient: gradient,
          shape: BoxShape.circle,
          border: Border.all(color: context.theme.surface, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      );
    }

    final double stackWidth = step * (total - 1) + size;

    return SizedBox(
      width: stackWidth,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < upiApps.length; i++)
            Positioned(
              left: step * i,
              child: _circle(color: upiApps[i].color, label: upiApps[i].label),
            ),
          // +12 brand badge — topmost
          Positioned(
            left: step * 3,
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: context.theme.coinGradient,
                shape: BoxShape.circle,
                border: Border.all(color: context.theme.surface, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: context.theme.primary.withValues(alpha: 0.45),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                '+12',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpiAppInfo {
  final String label;
  final Color color;
  const _UpiAppInfo({required this.label, required this.color});
}

