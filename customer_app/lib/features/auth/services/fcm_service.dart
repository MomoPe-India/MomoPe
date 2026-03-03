// lib/features/auth/services/fcm_service.dart
//
// Registers the device FCM token in the `fcm_tokens` table.
// Called after successful PIN setup (new user) and PIN verify (returning user).
// Uses explicit Firebase UID — no Supabase auth.uid() required.

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

      // Request permission (no-op if already granted/denied)
      final messaging = FirebaseMessaging.instance;
      final settings  = await messaging.requestPermission(
        alert: true, badge: true, sound: true);
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('[FCM] Permission denied — skipping token registration');
        return;
      }

      // Get token
      final token = await messaging.getToken();
      if (token == null) {
        debugPrint('[FCM] No token returned — device may not support FCM');
        return;
      }
      debugPrint('[FCM] Registering token for UID: $uid');

      // Upsert into fcm_tokens (keyed on device_token to avoid duplicates)
      await Supabase.instance.client.from('fcm_tokens').upsert({
        'user_id':      uid,
        'device_token': token,
        'platform':     defaultTargetPlatform.name.toLowerCase(), // 'android' | 'ios'
        'updated_at':   DateTime.now().toIso8601String(),
      }, onConflict: 'device_token');

      debugPrint('[FCM] Token registered successfully');
    } catch (e) {
      // Non-fatal — notifications won't work but login still succeeds
      debugPrint('[FCM] Token registration failed (non-fatal): $e');
    }
  }
}
