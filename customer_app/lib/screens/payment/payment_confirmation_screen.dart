import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/widgets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/merchant.dart';
import 'payment_success_screen.dart';

/// Payment Confirmation Screen
/// Shows merchant details, amount input, and coin preview
class PaymentConfirmationScreen extends ConsumerStatefulWidget {
  final Merchant merchant;

  const PaymentConfirmationScreen({
    super.key,
    required this.merchant,
  });

  @override
  ConsumerState<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState
    extends ConsumerState<PaymentConfirmationScreen> {
  String _amountText = '';
  bool _agreedToTerms = false;
  bool _isProcessing = false;

  double get _amount {
    if (_amountText.isEmpty) return 0;
    return double.tryParse(_amountText) ?? 0;
  }

  bool get _isValidAmount => _amount > 0;
  bool get _canConfirm => _isValidAmount && _agreedToTerms && !_isProcessing;

  int get _coinsPreview {
    // Preview uses maximum 10% rewards
    // Real calculation happens server-side with algorithm
    return (_amount * 0.10).round();
  }

  void _onNumberTap(String number) {
    setState(() {
      if (number == '⌫') {
        if (_amountText.isNotEmpty) {
          _amountText = _amountText.substring(0, _amountText.length - 1);
        }
      } else if (number == '00') {
        if (_amountText.isNotEmpty) {
          _amountText += '00';
        }
      } else {
        // Prevent invalid formats
        if (_amountText.contains('.') && number == '.') return;
        if (_amountText.isEmpty && number == '.') {
          _amountText = '0.';
        } else {
          _amountText += number;
        }
      }
      HapticFeedback.selectionClick();
    });
  }

  Future<void> _confirmPayment() async {
    if (!_canConfirm) return;

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    try {
      // TODO: Integrate with PaymentService
      // final result = await ref.read(paymentServiceProvider).processPayment(
      //   merchantId: widget.merchant.id,
      //   amount: _amount,
      // );

      // For now, simulate success after 2 seconds
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // Navigate to success screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(
              merchant: widget.merchant,
              amount: _amount,
              coinsEarned: _coinsPreview,
              transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: AppBar(
        title: const Text('Confirm Payment'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.neutral900,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPaddingAll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Merchant Profile Card
              _buildMerchantCard(),
              const SizedBox(height: 24),

              // Amount Input Section
              _buildAmountSection(),
              const SizedBox(height: 16),

              // Coin Preview
              if (_isValidAmount) _buildCoinPreview(),
              if (_isValidAmount) const SizedBox(height: 24),

              // Custom Number Pad
              _buildNumberPad(),
              const SizedBox(height: 24),

              // Terms Checkbox
              _buildTermsCheckbox(),
              const SizedBox(height: 16),

              // Confirm Button
              _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMerchantCard() {
    return PremiumCard(
      style: PremiumCardStyle.gradient,
      child: Row(
        children: [
          // Merchant Logo
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: widget.merchant.logoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.merchant.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDefaultLogo(),
                    ),
                  )
                : _buildDefaultLogo(),
          ),
          const SizedBox(width: 16),

          // Merchant Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.merchant.businessName,
                  style: AppTypography.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.merchant.category,
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // Verified Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.successGreen.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'Verified',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultLogo() {
    return Icon(
      Icons.store_rounded,
      color: Colors.white.withOpacity(0.7),
      size: 32,
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Amount',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isValidAmount
                  ? AppColors.primaryTeal
                  : AppColors.neutral300,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '₹',
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.neutral600,
                  fontSize: 32,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _amountText.isEmpty ? '0' : _amountText,
                  style: AppTypography.amountDisplay.copyWith(
                    color: AppColors.neutral900,
                    fontSize: 48,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoinPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.rewardsGold.withOpacity(0.1),
            AppColors.rewardsGoldLight.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.rewardsGold.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.stars_rounded,
            color: AppColors.rewardsGold,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You\'ll earn up to $_coinsPreview coins',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.rewardsGoldDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '≈ 10% rewards on this transaction',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberPad() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildNumberRow(['1', '2', '3']),
          const SizedBox(height: 12),
          _buildNumberRow(['4', '5', '6']),
          const SizedBox(height: 12),
          _buildNumberRow(['7', '8', '9']),
          const SizedBox(height: 12),
          _buildNumberRow(['.', '0', '00']),
          const SizedBox(height: 12),
          _buildNumberButton('⌫', isWide: true, isDelete: true),
        ],
      ),
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      children: numbers.map((number) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildNumberButton(number),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumberButton(
    String number, {
    bool isWide = false,
    bool isDelete = false,
  }) {
    return Material(
      color: isDelete ? AppColors.neutral200 : AppColors.neutral100,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _onNumberTap(number),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          child: Text(
            number,
            style: AppTypography.titleLarge.copyWith(
              color: isDelete ? AppColors.errorRed : AppColors.neutral900,
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => _agreedToTerms = !_agreedToTerms);
          HapticFeedback.selectionClick();
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _agreedToTerms
                      ? AppColors.primaryTeal
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _agreedToTerms
                        ? AppColors.primaryTeal
                        : AppColors.neutral400,
                    width: 2,
                  ),
                ),
                child: _agreedToTerms
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'I agree to pay ',
                    style: AppTypography.bodyMedium,
                    children: [
                      TextSpan(
                        text: '₹${_amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                      const TextSpan(text: ' to '),
                      TextSpan(
                        text: widget.merchant.businessName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return PremiumButton(
      text: _isProcessing ? 'Processing...' : 'Confirm Payment',
      icon: _isProcessing ? null : Icons.arrow_forward,
      onPressed: _canConfirm ? _confirmPayment : null,
      style: PremiumButtonStyle.primary,
      isLoading: _isProcessing,
    );
  }
}
