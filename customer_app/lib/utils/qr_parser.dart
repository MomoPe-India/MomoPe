import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

/// QR Code format for MomoPe merchant QR codes
/// 
/// Expected JSON structure:
/// ```json
/// {
///   "type": "momope_merchant",
///   "merchant_id": "uuid-here",
///   "version": "1.0"
/// }
/// ```
class MerchantQRParser {
  /// Parse QR code data and return merchant details from Supabase
  /// 
  /// Returns null if:
  /// - QR code is not valid JSON
  /// - QR code is not a MomoPe merchant QR
  /// - Merchant ID is not found in database
  /// - Merchant is not active/operational
  static Future<Map<String, dynamic>?> parseMerchantQR(String qrData) async {
    try {
      // Parse JSON
      final Map<String, dynamic> qrJson = jsonDecode(qrData);
      
      // Validate QR type
      if (qrJson['type'] != 'momope_merchant') {
        return null; // Not a MomoPe merchant QR
      }
      
      // Extract merchant ID
      final String? merchantId = qrJson['merchant_id'];
      if (merchantId == null || merchantId.isEmpty) {
        return null; // Invalid merchant ID
      }
      
      // Fetch merchant from Supabase
      final merchant = await _fetchMerchantById(merchantId);
      return merchant;
      
    } on FormatException catch (_) {
      // Invalid JSON
      return null;
    } catch (e) {
      // Other errors (network, database, etc.)
      print('Error parsing merchant QR: $e');
      return null;
    }
  }
  
  /// Fetch merchant details from Supabase by ID
  static Future<Map<String, dynamic>?> _fetchMerchantById(String merchantId) async {
    try {
      final response = await Supabase.instance.client
        .from('merchants')
        .select()
        .eq('id', merchantId)
        .eq('status', 'active')
        .eq('is_operational', true)
        .maybeSingle();
      
      return response;
    } catch (e) {
      print('Error fetching merchant: $e');
      return null;
    }
  }
  
  /// Generate a test QR code for development/testing
  /// 
  /// This creates a valid MomoPe merchant QR JSON string
  /// that can be encoded into a QR code for testing
  static String generateTestQR(String merchantId) {
    final qrData = {
      'type': 'momope_merchant',
      'merchant_id': merchantId,
      'version': '1.0',
    };
    
    return jsonEncode(qrData);
  }
  
  /// Validate QR format without fetching from database
  /// 
  /// Useful for quick validation before network call
  static bool isValidMomopeQR(String qrData) {
    try {
      final qrJson = jsonDecode(qrData);
      return qrJson['type'] == 'momope_merchant' && 
             qrJson['merchant_id'] != null &&
             qrJson['merchant_id'].toString().isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
