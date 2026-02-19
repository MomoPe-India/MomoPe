import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_design_tokens.dart';
import '../theme/app_typography.dart';

/// Banking-grade input field with validation animations
/// Premium text field for fintech experience
class PremiumTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final int? maxLength;
  final int? maxLines;
  final bool autofocus;

  const PremiumTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onEditingComplete,
    this.validator,
    this.inputFormatters,
    this.enabled = true,
    this.maxLength,
    this.maxLines = 1,
    this.autofocus = false,
  });

  @override
  State<PremiumTextField> createState() => _PremiumTextFieldState();
}

class _PremiumTextFieldState extends State<PremiumTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasError = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shakeController.reverse();
        }
      });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PremiumTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != null && widget.errorText != oldWidget.errorText) {
      _hasError = true;
      _shakeController.forward(from: 0);
      HapticFeedback.lightImpact();
    } else if (widget.errorText == null) {
      _hasError = false;
    }
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value * (_hasError ? 1 : 0), 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: AppDesignTokens.durationNormal,
                curve: AppDesignTokens.curveSmooth,
                decoration: BoxDecoration(
                  color: widget.enabled
                      ? AppColors.neutral200
                      : AppColors.neutral300,
                  borderRadius: AppDesignTokens.radius12,
                  border: Border.all(
                    color: _getBorderColor(),
                    width: _isFocused ? 2 : 0,
                  ),
                ),
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  autofocus: widget.autofocus,
                  maxLength: widget.maxLength,
                  maxLines: widget.maxLines,
                  inputFormatters: widget.inputFormatters,
                  onChanged: widget.onChanged,
                  onEditingComplete: widget.onEditingComplete,
                  style: AppTypography.bodyLarge,
                  decoration: InputDecoration(
                    labelText: widget.labelText,
                    hintText: widget.hintText,
                    prefixIcon: widget.prefixIcon,
                    suffixIcon: _buildSuffixIcon(),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    counterText: '',
                  ),
                ),
              ),
              if (widget.errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 14,
                        color: AppColors.errorRed,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.errorText!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.errorRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (widget.helperText != null && widget.errorText == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 16),
                  child: Text(
                    widget.helperText!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.errorText != null) {
      return Icon(
        Icons.error,
        color: AppColors.errorRed,
        size: 20,
      );
    }
    
    if (_isFocused && widget.controller?.text.isNotEmpty == true) {
      return Icon(
        Icons.check_circle,
        color: AppColors.successGreen,
        size: 20,
      );
    }
    
    return widget.suffixIcon;
  }

  Color _getBorderColor() {
    if (!widget.enabled) {
      return Colors.transparent;
    }
    if (widget.errorText != null) {
      return AppColors.errorRed;
    }
    if (_isFocused) {
      return AppColors.primaryTeal;
    }
    return Colors.transparent;
  }
}

/// Amount input field with currency formatting
class AmountTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? errorText;
  final ValueChanged<double>? onChanged;
  final double? maxAmount;

  const AmountTextField({
    super.key,
    this.controller,
    this.labelText,
    this.errorText,
    this.onChanged,
    this.maxAmount,
  });

  @override
  State<AmountTextField> createState() => _AmountTextFieldState();
}

class _AmountTextFieldState extends State<AmountTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_formatAmount);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _formatAmount() {
    // Remove non-numeric characters and format
    final text = _controller.text.replaceAll(RegExp(r'[^0-9.]'), '');
    if (text.isNotEmpty) {
      final amount = double.tryParse(text) ?? 0;
      widget.onChanged?.call(amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumTextField(
      controller: _controller,
      labelText: widget.labelText ?? 'Amount',
      hintText: '₹ 0.00',
      errorText: widget.errorText,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      prefixIcon: Icon(
        Icons.currency_rupee,
        color: AppColors.neutral600,
        size: 20,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
    );
  }
}
