import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_design_tokens.dart';
import '../theme/app_spacing.dart';

/// Premium card component with hover effects and variants
/// Enhanced card design for fintech experience
class PremiumCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final PremiumCardStyle style;
  final EdgeInsetsGeometry? padding;
  final double? elevation;

  const PremiumCard({
    super.key,
    required this.child,
    this.onTap,
    this.style = PremiumCardStyle.standard,
    this.padding,
    this.elevation,
  });

  @override
  State<PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<PremiumCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDesignTokens.durationNormal,
    );
    _elevationAnimation = Tween<double>(begin: 0, end: 4).animate(
      CurvedAnimation(parent: _controller, curve: AppDesignTokens.curveSmooth),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (widget.onTap != null) {
          setState(() => _isHovered = true);
          _controller.forward();
        }
      },
      onExit: (_) {
        if (_isHovered) {
          setState(() => _isHovered = false);
          _controller.reverse();
        }
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _elevationAnimation,
          builder: (context, child) {
            return Container(
              decoration: _getDecoration(),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: AppDesignTokens.radiusCard,
                  child: Padding(
                    padding: widget.padding ?? AppSpacing.paddingAll16,
                    child: widget.child,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  BoxDecoration _getDecoration() {
    switch (widget.style) {
      case PremiumCardStyle.standard:
        return BoxDecoration(
          color: Colors.white,
          borderRadius: AppDesignTokens.radiusCard,
          border: Border.all(
            color: _isHovered
                ? AppColors.primaryTealLight
                : AppColors.neutral300,
            width: 1,
          ),
          boxShadow: _isHovered
              ? AppDesignTokens.elevation2
              : AppDesignTokens.elevation1,
        );

      case PremiumCardStyle.elevated:
        return BoxDecoration(
          color: Colors.white,
          borderRadius: AppDesignTokens.radiusCard,
          boxShadow: _isHovered
              ? AppDesignTokens.elevation3
              : AppDesignTokens.elevation2,
        );

      case PremiumCardStyle.outlined:
        return BoxDecoration(
          color: Colors.white,
          borderRadius: AppDesignTokens.radiusCard,
          border: Border.all(
            color: _isHovered
                ? AppColors.primaryTeal
                : AppColors.neutral300,
            width: _isHovered ? 2 : 1,
          ),
        );

      case PremiumCardStyle.glass:
        return BoxDecoration(
          gradient: AppColors.glassGradient,
          borderRadius: AppDesignTokens.radius16,
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: AppDesignTokens.elevation2,
        );

      case PremiumCardStyle.gradient:
        return BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: AppDesignTokens.radiusCard,
          boxShadow: AppDesignTokens.elevation2,
        );
    }
  }
}

enum PremiumCardStyle {
  standard,  // White with border and subtle shadow
  elevated,  // White with higher elevation
  outlined,  // White with prominent border
  glass,     // Glass morphism effect
  gradient,  // Teal gradient background
}

/// Specialized transaction card for payment history
class TransactionCard extends StatelessWidget {
  final String merchantName;
  final String timestamp;
  final double amount;
  final int coinsEarned;
  final TransactionStatus status;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.merchantName,
    required this.timestamp,
    required this.amount,
    required this.coinsEarned,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      padding: AppSpacing.paddingAll16,
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getStatusColor().withOpacity(0.2),
                  _getStatusColor().withOpacity(0.05),
                ],
              ),
              borderRadius: AppDesignTokens.radius8,
            ),
            child: Icon(
              _getStatusIcon(),
              color: _getStatusColor(),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  merchantName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  timestamp,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral600,
                      ),
                ),
              ],
            ),
          ),
          // Amount & Coins
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${amount.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              if (coinsEarned > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.stars,
                      size: 14,
                      color: AppColors.rewardsGold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+$coinsEarned coins',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.rewardsGold,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case TransactionStatus.success:
        return AppColors.successGreen;
      case TransactionStatus.pending:
        return AppColors.warningAmber;
      case TransactionStatus.failed:
        return AppColors.errorRed;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case TransactionStatus.success:
        return Icons.arrow_upward;
      case TransactionStatus.pending:
        return Icons.schedule;
      case TransactionStatus.failed:
        return Icons.error_outline;
    }
  }
}

enum TransactionStatus {
  success,
  pending,
  failed,
}
