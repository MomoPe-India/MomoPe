// lib/features/auth/services/fcm_service.dart
//
// Registers the device FCM token in the `fcm_tokens` table.
// Called after successful PIN setup (new merchant) and PIN verify (returning merchant).

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FcmService {
  const FcmService._();

  /// Call this once after the user is fully authenticated (PIN verified or set).
  /// Requests notification permission, gets the FCM token, and upserts it into
  /// the `fcm_tokens` table with the current Firebase UID.
  static Future<void> registerToken() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // Request permission
      final messaging = FirebaseMessaging.instance;
      final settings  = await messaging.requestPermission(
        alert: true, badge: true, sound: true);
      
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('[FCM] Permission denied');
        return;
      }

      // Get token
      final token = await messaging.getToken();
      if (token == null) {
        debugPrint('[FCM] No token returned');
        return;
      }
      debugPrint('[FCM] Registering token for merchant UID: $uid');

      // Use SECURITY DEFINER RPC — direct upsert would fail because the
      // fcm_tokens RLS WITH CHECK rejects inserts without a Supabase session.
      await Supabase.instance.client.rpc('register_fcm_token', params: {
        'firebase_uid': uid,
        'p_token':      token,
        'p_platform':   defaultTargetPlatform.name.toLowerCase(),
      });

      debugPrint('[FCM] Merchant token registered successfully');
    } catch (e) {
      debugPrint('[FCM] Token registration failed: $e');
    }
  }
}
