import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import '../../core/widgets/widgets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/merchant.dart';
import '../home/home_screen.dart';

/// Payment Success Screen with confetti animation
/// Shows transaction summary and coins earned
class PaymentSuccessScreen extends StatefulWidget {
  final Merchant merchant;
  final double amount;
  final int coinsEarned;
  final String transactionId;

  const PaymentSuccessScreen({
    super.key,
    required this.merchant,
    required this.amount,
    required this.coinsEarned,
    required this.transactionId,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _checkmarkController;
  late Animation<double> _checkmarkScale;
  late Animation<double> _checkmarkFade;

  @override
  void initState() {
    super.initState();

    // Confetti controller
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Checkmark animation controller
    _checkmarkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _checkmarkScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _checkmarkController,
        curve: Curves.elasticOut,
      ),
    );

    _checkmarkFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _checkmarkController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Trigger animations
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _confettiController.play();
        _checkmarkController.forward();
        HapticFeedback.heavyImpact();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _checkmarkController.dispose();
    super.dispose();
  }

  void _goToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Padding(
              padding: AppSpacing.screenPaddingAll,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Animated Checkmark
                  _buildAnimatedCheckmark(),
                  const SizedBox(height: 32),

                  // Success Title
                  Text(
                    'Payment Successful!',
                    style: AppTypography.displaySmall.copyWith(
                      color: AppColors.neutral900,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Your payment has been processed',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.neutral600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Transaction Summary Card
                  _buildTransactionSummary(),
                  const SizedBox(height: 24),

                  // Coins Earned Highlight
                  _buildCoinsEarnedCard(),

                  const Spacer(),

                  // Action Buttons
                  PremiumButton(
                    text: 'Back to Home',
                    icon: Icons.home_rounded,
                    onPressed: _goToHome,
                    style: PremiumButtonStyle.primary,
                  ),
                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to transaction details
                      _goToHome();
                    },
                    child: Text(
                      'View Transaction Details',
                      style: AppTypography.button.copyWith(
                        color: AppColors.primaryTeal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              blastDirection: 3.14 / 2, // downward
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.3,
              colors: const [
                AppColors.primaryTeal,
                AppColors.primaryTealLight,
                AppColors.rewardsGold,
                AppColors.accentOrange,
                AppColors.successGreen,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCheckmark() {
    return AnimatedBuilder(
      animation: _checkmarkController,
      builder: (context, child) {
        return Opacity(
          opacity: _checkmarkFade.value,
          child: Transform.scale(
            scale: _checkmarkScale.value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.successGreen,
                    AppColors.successGreen.withOpacity(0.8),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.successGreen.withOpacity(0.3),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 72,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionSummary() {
    final formattedDate = _formatDateTime(DateTime.now());

    return PremiumCard(
      style: PremiumCardStyle.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Merchant name
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryTealLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.store_rounded,
                  color: AppColors.primaryTeal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.merchant.businessName,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.merchant.category,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Divider
          Container(
            height: 1,
            color: AppColors.neutral300,
          ),
          const SizedBox(height: 20),

          // Amount
          _buildDetailRow(
            'Amount Paid',
            '₹${widget.amount.toStringAsFixed(2)}',
            isBold: true,
            valueColor: AppColors.neutral900,
          ),
          const SizedBox(height: 12),

          // Transaction ID
          _buildDetailRow(
            'Transaction ID',
            widget.transactionId,
            isSmall: true,
          ),
          const SizedBox(height: 12),

          // Date & Time
          _buildDetailRow(
            'Date & Time',
            formattedDate,
            isSmall: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCoinsEarnedCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.rewardsGold.withOpacity(0.15),
            AppColors.rewardsGoldLight.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.rewardsGold.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.rewardsGold,
                  AppColors.rewardsGoldDark,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.rewardsGold.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You earned ${widget.coinsEarned} coins!',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.rewardsGoldDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '= ₹${widget.coinsEarned} value',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.neutral700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBold = false,
    bool isSmall = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isSmall
              ? AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral600,
                )
              : AppTypography.bodyMedium.copyWith(
                  color: AppColors.neutral700,
                ),
        ),
        Text(
          value,
          style: isSmall
              ? AppTypography.bodySmall.copyWith(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: valueColor ?? AppColors.neutral700,
                )
              : AppTypography.bodyLarge.copyWith(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: valueColor ?? AppColors.neutral700,
                ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$month $day, $year at $hour:$minute $period';
  }
}
