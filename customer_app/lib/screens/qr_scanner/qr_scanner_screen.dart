import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/widgets/widgets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/merchant.dart';
import '../../utils/qr_parser.dart';
import '../payment/payment_confirmation_screen.dart';

/// Premium QR Scanner Screen with animated frame
/// Features: Corner animations, haptic feedback, merchant preview
class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  MobileScannerController? _scannerController;
  bool _isScanning = true;
  bool _torchEnabled = false;
  late AnimationController _animationController;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );

    // Scan line animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture barcodeCapture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = barcodeCapture.barcodes;
    if (barcodes.isEmpty) return;

    final String? qrCode = barcodes.first.rawValue;
    if (qrCode == null) return;

    setState(() => _isScanning = false);
    HapticFeedback.mediumImpact();

    // Parse QR code and navigate to payment screen
    _handleQRCode(qrCode);
  }

  Future<void> _handleQRCode(String qrCode) async {
    try {
      // Parse QR code and fetch merchant from Supabase
      final merchantData = await MerchantQRParser.parseMerchantQR(qrCode);
      
      if (merchantData == null) {
        // Invalid QR code or merchant not found
        _showError('Invalid QR Code', 'This is not a valid MomoPe merchant QR code.');
        setState(() => _isScanning = true); // Resume scanning
        return;
      }
      
      // Convert to Merchant model
      final merchant = Merchant.fromJson(merchantData);
      
      // Navigate to payment confirmation
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentConfirmationScreen(
              merchant: merchant,
            ),
          ),
        );
      }
    } catch (e) {
      // Handle errors (network, database, etc.)
      _showError('Error', 'Failed to load merchant details. Please try again.');
      setState(() => _isScanning = true); // Resume scanning
    }
  }
  
  void _showError(String title, String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.errorRed,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleTorch() {
    setState(() => _torchEnabled = !_torchEnabled);
    _scannerController?.toggleTorch();
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (_scannerController != null)
            MobileScanner(
              controller: _scannerController!,
              onDetect: _onDetect,
            ),

          // Overlay with scan area
          _buildOverlay(),

          // Top bar with close button
          _buildTopBar(),

          // Bottom instructions
          _buildBottomInstructions(),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return CustomPaint(
      painter: ScannerOverlayPainter(
        scanLineAnimation: _scanLineAnimation,
      ),
      child: Container(),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: AppSpacing.paddingAll16,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Close button
            Material(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            // Torch button
            Material(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: _toggleTorch,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    _torchEnabled ? Icons.flash_on : Icons.flash_off,
                    color: _torchEnabled ? AppColors.rewardsGold : Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInstructions() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: Container(
          padding: AppSpacing.paddingAll24,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.9),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.qr_code_scanner_rounded,
                color: AppColors.primaryTeal,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'Scan Merchant QR Code',
                style: AppTypography.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Position the QR code within the frame',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for scanner overlay with animated corners
class ScannerOverlayPainter extends CustomPainter {
  final Animation<double> scanLineAnimation;

  ScannerOverlayPainter({required this.scanLineAnimation})
      : super(repaint: scanLineAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = size.width * 0.7;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;
    final Rect scanArea = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    // Draw dimmed overlay outside scan area
    final Path overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanArea, const Radius.circular(24)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black.withOpacity(0.6),
    );

    // Draw animated corners
    _drawCorners(canvas, scanArea);

    // Draw animated scan line
    _drawScanLine(canvas, scanArea);
  }

  void _drawCorners(Canvas canvas, Rect scanArea) {
    final Paint cornerPaint = Paint()
      ..color = AppColors.primaryTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const double cornerLength = 40;

    // Top-left corner
    canvas.drawLine(
      scanArea.topLeft,
      scanArea.topLeft + const Offset(cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      scanArea.topLeft,
      scanArea.topLeft + const Offset(0, cornerLength),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      scanArea.topRight,
      scanArea.topRight + const Offset(-cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      scanArea.topRight,
      scanArea.topRight + const Offset(0, cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      scanArea.bottomLeft,
      scanArea.bottomLeft + const Offset(cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      scanArea.bottomLeft,
      scanArea.bottomLeft + const Offset(0, -cornerLength),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      scanArea.bottomRight,
      scanArea.bottomRight + const Offset(-cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      scanArea.bottomRight,
      scanArea.bottomRight + const Offset(0, -cornerLength),
      cornerPaint,
    );
  }

  void _drawScanLine(Canvas canvas, Rect scanArea) {
    final double lineY = scanArea.top +
        (scanArea.height * scanLineAnimation.value);

    final Paint linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.primaryTeal.withOpacity(0.5),
          AppColors.primaryTeal,
          AppColors.primaryTeal.withOpacity(0.5),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromLTWH(scanArea.left, lineY - 2, scanArea.width, 4),
      );

    canvas.drawRect(
      Rect.fromLTWH(scanArea.left, lineY - 2, scanArea.width, 4),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(ScannerOverlayPainter oldDelegate) => true;
}
