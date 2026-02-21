import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static void registerBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> initialize() async {
    // 1. Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('[FCM] Permission denied');
      return;
    }

    // 2. Set up local notifications channel (Android)
    const androidChannel = AndroidNotificationChannel(
      'momope_merchant', // id
      'MomoPe Merchant', // name
      description: 'Payment received and settlement notifications',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // 3. Initialize local notifications plugin
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(initSettings);

    // 4. Show notification when app is in foreground
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'momope_merchant',
              'MomoPe Merchant',
              channelDescription: 'Payment received and settlement notifications',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });

    // 5. Save FCM token to merchants table
    await _saveFcmToken();

    // 6. Listen for token refresh
    _messaging.onTokenRefresh.listen(_updateFcmToken);

    debugPrint('[FCM] NotificationService initialized');
  }

  Future<void> _saveFcmToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      await Supabase.instance.client
          .from('merchants')
          .update({'fcm_token': token})
          .eq('user_id', userId);

      debugPrint('[FCM] Merchant token saved for user $userId');
    } catch (e) {
      debugPrint('[FCM] Error saving token: $e');
    }
  }

  Future<void> _updateFcmToken(String token) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      await Supabase.instance.client
          .from('merchants')
          .update({'fcm_token': token})
          .eq('user_id', userId);

      debugPrint('[FCM] Merchant token refreshed');
    } catch (e) {
      debugPrint('[FCM] Error updating token: $e');
    }
  }

  /// ✅ FIX L4: Call this before auth.signOut() to prevent stale push tokens.
  /// Clears the FCM token from the merchants table and invalidates the
  /// device token so no push notifications are delivered after logout.
  Future<void> clearFcmToken() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await Supabase.instance.client
            .from('merchants')
            .update({'fcm_token': null})
            .eq('user_id', userId);
      }
      await _messaging.deleteToken();
      debugPrint('[FCM] Merchant token cleared');
    } catch (e) {
      debugPrint('[FCM] Error clearing token: $e');
    }
  }
}
