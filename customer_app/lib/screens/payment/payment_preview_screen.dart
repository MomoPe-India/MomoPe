import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/coin_balance_provider.dart';
import '../../providers/payment_provider.dart';
import '../../services/payment_service.dart';
import 'payment_success_screen.dart';
import 'payment_failure_screen.dart';

class PaymentPreviewScreen extends ConsumerStatefulWidget {
  final String merchantId;

  const PaymentPreviewScreen({
    super.key,
    required this.merchantId,
  });

  @override
  ConsumerState<PaymentPreviewScreen> createState() =>
      _PaymentPreviewScreenState();
}

class _PaymentPreviewScreenState extends ConsumerState<PaymentPreviewScreen> {
  final TextEditingController _amountController = TextEditingController();
  double _enteredAmount = 0;
  double _coinRedemptionPercentage = 0.0; // 0.0 to 0.8 (0% to 80%)

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Calculate maximum coins user can redeem (80% of payment)
  int _calculateMaxRedeemableCoins(int availableCoins) {
    if (_enteredAmount <= 0) return 0;
    final maxByRule = (_enteredAmount * 0.8).floor();
    return maxByRule > availableCoins ? availableCoins : maxByRule;
  }

  // Calculate actual coins to use based on slider position
  int _calculateCoinsToUse(int availableCoins) {
    final maxRedeemable = _calculateMaxRedeemableCoins(availableCoins);
    return (maxRedeemable * _coinRedemptionPercentage).floor();
  }

  double _calculateFiatAmount(int availableCoins) {
    final coinsUsed = _calculateCoinsToUse(availableCoins);
    return _enteredAmount - coinsUsed;
  }

  int _calculateCoinsEarned(int availableCoins) {
    final fiatSpent = _calculateFiatAmount(availableCoins);
    // TODO: Fetch actual reward percentage from backend (up to 10%)
    // For now using max 10%, but should be dynamic based on:
    // - Merchant reward tier
    // - Transaction eligibility
    // - Campaign bonuses
    const rewardPercentage = 0.10; // Placeholder: max rate
    return (fiatSpent * rewardPercentage).floor();
  }

  void _showCoinMechanicsInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Color(0xFF2CB78A)),
            const SizedBox(width: 12),
            Text(
              'How MomoCoins Work',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              '💰 Earn Coins',
              'Get up to 10% back in MomoCoins on eligible payments',
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              '🎯 Use Coins',
              'Redeem up to 80% of your payment using coins',
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              '🔄 Keep Earning',
              'The more you pay, the more coins you earn',
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F7F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tips_and_updates,
                      color: Color(0xFF2CB78A), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '1 coin = ₹1 value',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF131B26),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it!',
              style: GoogleFonts.inter(
                color: const Color(0xFF2CB78A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF131B26),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch coin balance from provider
    final coinBalanceAsync = ref.watch(coinBalanceProvider);

    return coinBalanceAsync.when(
      data: (coinBalance) {
        final availableCoins = coinBalance?.availableCoins ?? 0;
        final maxRedeemable = _calculateMaxRedeemableCoins(availableCoins);
        final coinsUsed = _calculateCoinsToUse(availableCoins);
        final fiatAmount = _calculateFiatAmount(availableCoins);
        final coinsEarned = _calculateCoinsEarned(availableCoins);
        final hasCoins = availableCoins > 0;

        return _buildPaymentScreen(
          context,
          availableCoins: availableCoins,
          maxRedeemable: maxRedeemable,
          coinsUsed: coinsUsed,
          fiatAmount: fiatAmount,
          coinsEarned: coinsEarned,
          hasCoins: hasCoins,
        );
      },
      loading: () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF131B26)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Payment Preview',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF131B26),
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2CB78A),
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF131B26)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Payment Preview',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF131B26),
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load balance',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.refresh(coinBalanceProvider),
                child: Text(
                  'Retry',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF2CB78A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentScreen(
    BuildContext context, {
    required int availableCoins,
    required int maxRedeemable,
    required int coinsUsed,
    required double fiatAmount,
    required int coinsEarned,
    required bool hasCoins,
  }) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF131B26)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment Preview',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF131B26),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Merchant info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2CB78A), Color(0xFF2DBCAF)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.store,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Merchant',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF131B26),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${widget.merchantId}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Amount input
            Text(
              'Enter Amount',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF131B26),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF131B26),
              ),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6B7280),
                ),
                hintText: '0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2CB78A),
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _enteredAmount = double.tryParse(value) ?? 0;
                });
              },
            ),

            const SizedBox(height: 32),

            // Coin redemption section with slider
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F7F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF2CB78A).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Color(0xFFFDB022),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Use MomoCoins',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF131B26),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Color(0xFF2CB78A),
                        ),
                        onPressed: _showCoinMechanicsInfo,
                        tooltip: 'How MomoCoins work',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Available: ',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        '$availableCoins coins',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: hasCoins
                              ? const Color(0xFF2CB78A)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                      if (_enteredAmount > 0 && maxRedeemable > 0)
                        Text(
                          ' (Max: $maxRedeemable)',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                    ],
                  ),

                  // Educational message for new users
                  if (!hasCoins) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            size: 18,
                            color: Color(0xFF2CB78A),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Complete this payment to earn your first coins! Get up to 10% back on eligible payments.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF374151),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Slider for coin redemption
                  if (_enteredAmount > 0) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          'Use: ',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF131B26),
                          ),
                        ),
                        Text(
                          '$coinsUsed coins',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2CB78A),
                          ),
                        ),
                        if (maxRedeemable > 0)
                          Text(
                            ' ≈ ${(_coinRedemptionPercentage * 100).toInt()}%',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF2CB78A),
                        inactiveTrackColor: const Color(0xFFD1D5DB),
                        thumbColor: const Color(0xFF2CB78A),
                        overlayColor: const Color(0xFF2CB78A).withOpacity(0.2),
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10,
                        ),
                      ),
                      child: Slider(
                        value: _coinRedemptionPercentage,
                        min: 0.0,
                        max: maxRedeemable > 0 ? 1.0 : 0.0,
                        divisions: maxRedeemable > 0 ? 20 : 1,
                        onChanged: maxRedeemable > 0
                            ? (value) {
                                setState(() {
                                  _coinRedemptionPercentage = value;
                                });
                              }
                            : null,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '0',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        Text(
                          maxRedeemable > 0 ? '$maxRedeemable coins' : 'No coins',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                    if (maxRedeemable > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 14,
                              color: Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'You can use up to 80% of payment in coins',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),

            if (_enteredAmount > 0) ...[
              const SizedBox(height: 32),

              // Payment breakdown
              Text(
                'Payment Breakdown',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF131B26),
                ),
              ),

              const SizedBox(height: 16),

              _buildBreakdownRow(
                  'Total Amount', '₹${_enteredAmount.toStringAsFixed(2)}'),
              if (coinsUsed > 0) ...[
                const SizedBox(height: 12),
                _buildBreakdownRow(
                  'Coins Redeemed',
                  '- ₹$coinsUsed',
                  valueColor: const Color(0xFF10B981),
                ),
              ],
              const Divider(height: 32),
              _buildBreakdownRow(
                'Pay with Card/UPI',
                '₹${fiatAmount.toStringAsFixed(2)}',
                isBold: true,
              ),
              const SizedBox(height: 16),

              // Earnings highlight
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFDB022).withOpacity(0.1),
                      const Color(0xFFFDB022).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFDB022).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.celebration,
                      color: Color(0xFFFDB022),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'You\'ll Earn',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$coinsEarned MomoCoins',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFD97706),
                            ),
                          ),
                          Text(
                            'Up to 10% cashback on ₹${fiatAmount.toStringAsFixed(0)}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),

            // Pay button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _enteredAmount > 0
                    ? () async {
                        final paymentService = ref.read(paymentServiceProvider);
                        
                        // Show loading dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF2CB78A),
                            ),
                          ),
                        );

                        try {
                          final result = await paymentService.initiatePayment(
                            merchantId: widget.merchantId,
                            grossAmount: _enteredAmount,
                            fiatAmount: fiatAmount,
                            coinsToRedeem: coinsUsed,
                          );

                          // Close loading dialog
                          if (context.mounted) {
                            Navigator.pop(context);
                          }

                          // Navigate based on result
                          if (context.mounted) {
                            if (result.status == PaymentStatus.success) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentSuccessScreen(
                                    transactionId: result.transactionId,
                                    amountPaid: fiatAmount,
                                    coinsEarned: coinsEarned,
                                  ),
                                ),
                              );
                            } else if (result.status == PaymentStatus.failure) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentFailureScreen(
                                    transactionId: result.transactionId,
                                    errorMessage: result.errorMessage ?? 'Payment failed',
                                  ),
                                ),
                              );
                            } else {
                              // Cancelled - just close dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Payment cancelled',
                                    style: GoogleFonts.inter(),
                                  ),
                                  backgroundColor: const Color(0xFF6B7280),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          // Close loading dialog
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                          
                          // Show error
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error: $e',
                                  style: GoogleFonts.inter(),
                                ),
                                backgroundColor: const Color(0xFFEF4444),
                              ),
                            );
                          }
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2CB78A),
                  disabledBackgroundColor: const Color(0xFFE5E7EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Proceed to Pay ₹${fiatAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value,
      {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: const Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            color: valueColor ?? const Color(0xFF131B26),
          ),
        ),
      ],
    );
  }
}
