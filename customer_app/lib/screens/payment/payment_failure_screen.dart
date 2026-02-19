import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentFailureScreen extends StatelessWidget {
  final String transactionId;
  final String errorMessage;

  const PaymentFailureScreen({
    super.key,
    required this.transactionId,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Failure Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Color(0xFFEF4444),
                  size: 80,
                ),
              ),

              const SizedBox(height: 32),

              // Failure Message
              Text(
                'Payment Failed',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF131B26),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                errorMessage,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Error Details Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF6B7280),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No charges were made to your account',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Reference ID',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          transactionId.substring(0, 8),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF131B26),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Go back to payment preview
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2CB78A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Try Again',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
