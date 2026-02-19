import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// QR Code Service
/// Handles download, share, and gallery save operations for QR codes
class QrService {
  /// Generate QR code image as PNG bytes
  /// Returns high-resolution QR image (1024x1024)
  Future<Uint8List?> generateQrImage(String data) async {
    try {
      final painter = QrPainter(
        data: data,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.H,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
        gapless: true,
      );

      final image = await painter.toImage(1024);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error generating QR image: $e');
      return null;
    }
  }

  /// Download QR code to app documents directory
  /// Returns the file path or null if failed
  Future<String?> downloadQr({
    required String merchantId,
    required String merchantName,
  }) async {
    try {
      final qrData = 'momope://merchant/$merchantId';
      final image = await generateQrImage(qrData);
      if (image == null) return null;

      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final qrDir = Directory('${directory.path}/qr_codes');

      // Create directory if it doesn't exist
      if (!await qrDir.exists()) {
        await qrDir.create(recursive: true);
      }

      // Create file with merchant name
      final fileName = '${_sanitizeFileName(merchantName)}_qr.png';
      final file = File('${qrDir.path}/$fileName');

      // Write image to file
      await file.writeAsBytes(image);

      return file.path;
    } catch (e) {
      debugPrint('Error downloading QR: $e');
      return null;
    }
  }

  /// Share QR code via system share sheet
  /// Opens share dialog with WhatsApp, Telegram, Email, etc.
  Future<bool> shareQr({
    required String merchantId,
    required String merchantName,
  }) async {
    try {
      final qrData = 'momope://merchant/$merchantId';
      final image = await generateQrImage(qrData);
      if (image == null) return false;

      // Get temporary directory for sharing
      final tempDir = await getTemporaryDirectory();
      final shareDir = Directory('${tempDir.path}/share');

      // Create directory if it doesn't exist
      if (!await shareDir.exists()) {
        await shareDir.create(recursive: true);
      }

      // Create temporary file
      final file = File('${shareDir.path}/qr_code_share.png');
      await file.writeAsBytes(image);

      // Share via system share sheet
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Scan this QR code to pay at $merchantName\n\nPowered by MomoPe',
        subject: 'MomoPe Payment QR - $merchantName',
      );

      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('Error sharing QR: $e');
      return false;
    }
  }

  /// Save QR code to device photo gallery
  /// Requests storage permission if needed (Android)
  /// Returns true if successful
  Future<bool> saveToGallery({
    required String merchantId,
    required String merchantName,
  }) async {
    try {
      // Request permission for Android
      if (Platform.isAndroid) {
        final permission = await requestStoragePermission();
        if (!permission) {
          return false;
        }
      }

      final qrData = 'momope://merchant/$merchantId';
      final image = await generateQrImage(qrData);
      if (image == null) return false;

      if (Platform.isAndroid) {
        // Get external storage directory
        final directory = await getExternalStorageDirectory();
        if (directory == null) return false;

        // Navigate to Pictures folder (works on most Android versions)
        final picturesPath = directory.path.split('/Android')[0] + '/Pictures/MomoPe';
        final picturesDir = Directory(picturesPath);

        if (!await picturesDir.exists()) {
          await picturesDir.create(recursive: true);
        }

        final fileName = '${_sanitizeFileName(merchantName)}_qr_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File('$picturesPath/$fileName');
        
        await file.writeAsBytes(image);
        
        return true;
      } else {
        // For iOS/other platforms, download to app directory
        final path = await downloadQr(
          merchantId: merchantId,
          merchantName: merchantName,
        );
        return path != null;
      }
    } catch (e) {
      debugPrint('Error saving to gallery: $e');
      return false;
    }
  }

  /// Request storage permission (Android only)
  /// Returns true if permission granted
  Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    try {
      // For Android 13+ (API 33+), use photos permission
      // For Android 10-12 (API 29-32), use scoped storage  
      // For Android 9 and below, need WRITE_EXTERNAL_STORAGE
      
      var status = await Permission.storage.status;
      
      if (status.isGranted) {
        return true;
      }

      // Request permission
      status = await Permission.storage.request();

      if (status.isGranted) {
        return true;
      }

      if (status.isPermanentlyDenied) {
        // Guide user to settings
        await openAppSettings();
      }

      return false;
    } catch (e) {
      debugPrint('Error requesting storage permission: $e');
      return false;
    }
  }

  /// Sanitize filename by removing invalid characters
  String _sanitizeFileName(String name) {
    return name
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }

  /// Dispose resources
  void dispose() {
    // No resources to dispose
  }
}
