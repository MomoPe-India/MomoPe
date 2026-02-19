import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_design_tokens.dart';
import '../theme/app_typography.dart';

/// Premium button component with haptic feedback and animations
/// Inspired by world-class fintech apps (Revolut, N26)
class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final PremiumButtonStyle style;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const PremiumButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.style = PremiumButtonStyle.primary,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDesignTokens.durationFast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: AppDesignTokens.curveSnappy),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
      HapticFeedback.mediumImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: 56,
          decoration: _getDecoration(),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: null, // Handled by GestureDetector
              borderRadius: AppDesignTokens.radiusButton,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(_getLoadingColor()),
          ),
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.icon,
            size: 20,
            color: _getTextColor(),
          ),
          const SizedBox(width: 8),
          Text(
            widget.text,
            style: AppTypography.button.copyWith(color: _getTextColor()),
          ),
        ],
      );
    }

    return Center(
      child: Text(
        widget.text,
        style: AppTypography.button.copyWith(color: _getTextColor()),
      ),
    );
  }

  BoxDecoration _getDecoration() {
    final isDisabled = widget.onPressed == null;

    switch (widget.style) {
      case PremiumButtonStyle.primary:
        return BoxDecoration(
          gradient: isDisabled ? null : AppColors.primaryGradient,
          color: isDisabled ? AppColors.neutral400 : null,
          borderRadius: AppDesignTokens.radiusButton,
          boxShadow: isDisabled || widget.isLoading
              ? null
              : AppDesignTokens.elevation2,
        );

      case PremiumButtonStyle.secondary:
        return BoxDecoration(
          color: isDisabled
              ? AppColors.neutral200
              : AppColors.primaryTealExtraLight,
          borderRadius: AppDesignTokens.radiusButton,
          border: Border.all(
            color: isDisabled ? AppColors.neutral400 : AppColors.primaryTeal,
            width: 2,
          ),
        );

      case PremiumButtonStyle.tertiary:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: AppDesignTokens.radiusButton,
        );

      case PremiumButtonStyle.danger:
        return BoxDecoration(
          color: isDisabled ? AppColors.neutral400 : AppColors.errorRed,
          borderRadius: AppDesignTokens.radiusButton,
          boxShadow:
              isDisabled || widget.isLoading ? null : AppDesignTokens.elevation2,
        );
    }
  }

  Color _getTextColor() {
    final isDisabled = widget.onPressed == null;

    if (isDisabled) {
      return AppColors.neutral600;
    }

    switch (widget.style) {
      case PremiumButtonStyle.primary:
      case PremiumButtonStyle.danger:
        return Colors.white;
      case PremiumButtonStyle.secondary:
        return AppColors.primaryTeal;
      case PremiumButtonStyle.tertiary:
        return AppColors.primaryTeal;
    }
  }

  Color _getLoadingColor() {
    switch (widget.style) {
      case PremiumButtonStyle.primary:
      case PremiumButtonStyle.danger:
        return Colors.white;
      case PremiumButtonStyle.secondary:
      case PremiumButtonStyle.tertiary:
        return AppColors.primaryTeal;
    }
  }
}

enum PremiumButtonStyle {
  primary,   // Teal gradient, white text
  secondary, // Outlined teal, teal text
  tertiary,  // Text only, teal text
  danger,    // Red background, white text
}
