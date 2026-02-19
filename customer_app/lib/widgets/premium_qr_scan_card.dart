import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

/// Premium QR Scan Card with dark navy theme
/// Matches the premium fintech design with icon, title, subtitle, and arrow
class PremiumQRScanCard extends StatelessWidget {
  final VoidCallback onTap;

  const PremiumQRScanCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF131B26), // Dark Navy
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // QR Icon Container
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Scan QR to Pay',
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Instant payments, earn rewards',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
