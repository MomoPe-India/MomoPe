// lib/core/notification_service.dart
//
// Handles all FCM push notification states for the Merchant app:
//   1. Foreground — show in-app snackbar
//   2. Background tap — route based on payload type
//   3. Terminated tap — route after short delay once widget tree is ready
//
// Merchant notification types:
//   kyc_approved   → dashboard (highlight positive)
//   kyc_rejected   → profile/kyc (show resubmit prompt)
//   settlement     → settlements list
//   new_txn        → transaction history

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationService {
  const NotificationService._();

  static Future<void> init(GoRouter router) async {
    final messaging = FirebaseMessaging.instance;

    // Foreground
    FirebaseMessaging.onMessage.listen((msg) => _handleForeground(msg, router));

    // Background tap
    FirebaseMessaging.onMessageOpenedApp.listen((msg) => _navigate(msg, router));

    // Terminated tap
    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      Future.delayed(const Duration(milliseconds: 500), () => _navigate(initial, router));
    }
  }

  static void _handleForeground(RemoteMessage message, GoRouter router) {
    final notification = message.notification;
    if (notification == null) return;

    final context = router.routerDelegate.navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E1B4B),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 5),
        content: Row(children: [
          const Text('🏪', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (notification.title != null)
                Text(notification.title!,
                  style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              if (notification.body != null)
                Text(notification.body!,
                  style: const TextStyle(color: Color(0xFFBBB8D9), fontSize: 12)),
            ],
          )),
        ]),
        action: SnackBarAction(
          label: 'View',
          textColor: const Color(0xFFA78BFA),
          onPressed: () => _navigate(message, router),
        ),
      ),
    );
  }

  static void _navigate(RemoteMessage message, GoRouter router) {
    final data = message.data;

    // Explicit route override
    if (data['route'] != null && (data['route'] as String).isNotEmpty) {
      router.go(data['route'] as String);
      return;
    }

    final type = data['type'] as String? ?? '';
    switch (type) {
      case 'kyc_approved':
        router.go('/dashboard');
        break;
      case 'kyc_rejected':
        router.go('/profile');
        break;
      case 'settlement':
        router.go('/settlements');
        break;
      case 'new_payment_received':
      case 'new_txn':
      case 'transaction':
        router.go('/transactions');
        break;
      default:
        router.go('/dashboard');
    }
  }
}
