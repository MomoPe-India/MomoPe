import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// QR Parse Result
// ─────────────────────────────────────────────────────────────────────────────
/// Typed result from parseMerchantQR so the UI can show specific error messages
/// instead of a generic "Invalid QR" for every failure reason.
enum QrParseError {
  /// Scanned data is not JSON (wrong QR code entirely)
  notJson,

  /// JSON but missing `type` field or type ≠ 'momope_merchant'
  wrongType,

  /// Missing or empty merchant_id field
  missingMerchantId,

  /// Merchant ID not found in the database
  merchantNotFound,

  /// Merchant exists but is not active / not operational
  merchantInactive,

  /// Network or database error
  networkError,
}

class QrParseResult {
  final Map<String, dynamic>? merchant;
  final QrParseError? error;

  const QrParseResult.success(this.merchant) : error = null;
  const QrParseResult.failure(this.error) : merchant = null;

  bool get isSuccess => merchant != null;

  /// Human-readable error message for display in the UI.
  String get errorMessage {
    switch (error) {
      case QrParseError.notJson:
        return 'This QR code is not a MomoPe merchant code. Please scan a valid MomoPe QR.';
      case QrParseError.wrongType:
        return 'This QR code is not a MomoPe merchant code. Please scan a valid MomoPe QR.';
      case QrParseError.missingMerchantId:
        return 'Invalid QR code — merchant information is missing. Please ask the merchant for a new QR code.';
      case QrParseError.merchantNotFound:
        return 'Merchant not found. This QR code may be outdated or invalid.';
      case QrParseError.merchantInactive:
        return 'This merchant is currently not accepting payments. Please try again later.';
      case QrParseError.networkError:
        return 'Could not verify merchant — please check your internet connection and try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MerchantQRParser
// ─────────────────────────────────────────────────────────────────────────────

/// QR Code format for MomoPe merchant QR codes
///
/// Expected JSON structure:
/// ```json
/// {
///   "type": "momope_merchant",
///   "merchant_id": "uuid-here",
///   "version": "1"
/// }
/// ```
class MerchantQRParser {
  /// Parse QR code data and return a [QrParseResult] with either
  /// the merchant details or a specific [QrParseError] explaining why it failed.
  ///
  /// ✅ FIX C6: Returns typed errors so the UI can show specific messages
  /// instead of a generic "Invalid QR Code" for every failure.
  static Future<QrParseResult> parseMerchantQR(String qrData) async {
    // ── Step 1: Parse JSON ──────────────────────────────────────────────────
    Map<String, dynamic> qrJson;
    try {
      qrJson = jsonDecode(qrData) as Map<String, dynamic>;
    } on FormatException {
      return const QrParseResult.failure(QrParseError.notJson);
    } catch (_) {
      return const QrParseResult.failure(QrParseError.notJson);
    }

    // ── Step 2: Validate type ───────────────────────────────────────────────
    if (qrJson['type'] != 'momope_merchant') {
      return const QrParseResult.failure(QrParseError.wrongType);
    }

    // ── Step 3: Extract merchant ID ─────────────────────────────────────────
    final merchantId = qrJson['merchant_id']?.toString();
    if (merchantId == null || merchantId.isEmpty) {
      return const QrParseResult.failure(QrParseError.missingMerchantId);
    }

    // ── Step 4: Fetch from database ─────────────────────────────────────────
    try {
      final response = await Supabase.instance.client
          .from('merchants')
          .select()
          .eq('id', merchantId)
          .maybeSingle();

      if (response == null) {
        return const QrParseResult.failure(QrParseError.merchantNotFound);
      }

      // Check if merchant is active and operational
      final isActive = response['status'] == 'active';
      final isOperational = response['is_operational'] == true;

      if (!isActive || !isOperational) {
        return const QrParseResult.failure(QrParseError.merchantInactive);
      }

      return QrParseResult.success(response);
    } catch (e) {
      debugPrint('Error fetching merchant: $e');
      return const QrParseResult.failure(QrParseError.networkError);
    }
  }

  /// Generate a test QR code for development/testing.
  static String generateTestQR(String merchantId) {
    return jsonEncode({
      'type': 'momope_merchant',
      'merchant_id': merchantId,
      'version': '1',
    });
  }

  /// Validate QR format without fetching from database.
  /// Useful for quick client-side check before network call.
  static bool isValidMomopeQR(String qrData) {
    try {
      final qrJson = jsonDecode(qrData) as Map<String, dynamic>;
      return qrJson['type'] == 'momope_merchant' &&
          qrJson['merchant_id'] != null &&
          qrJson['merchant_id'].toString().isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
