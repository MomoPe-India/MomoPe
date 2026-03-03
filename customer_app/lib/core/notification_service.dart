// lib/core/notification_service.dart
//
// Handles all states of FCM push notifications:
//   1. Foreground — app is open: show custom in-app banner
//   2. Background tap — user tapped a notification while app was in background
//   3. Terminated tap — app was launched by tapping a notification
//
// Call NotificationService.init(router) once after GoRouter is ready.

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationService {
  const NotificationService._();

  /// Initialise notification listeners.
  /// Must be called after the widget tree is built (use addPostFrameCallback
  /// or call from a ConsumerStatefulWidget.initState).
  static Future<void> init(GoRouter router) async {
    final messaging = FirebaseMessaging.instance;

    // ── Foreground messages ────────────────────────────────────────────────
    // Android shows no system notification in the foreground by default.
    // We display a custom in-app snack/overlay via the scaffold messenger.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForeground(message, router);
    });

    // ── Background tap ─────────────────────────────────────────────────────
    // Triggered when user taps a notification while app is in background.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _navigateFromPayload(message, router);
    });

    // ── Terminated tap ─────────────────────────────────────────────────────
    // App was launched (or resumed from killed state) via a notification tap.
    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      // Route after a short delay so the widget tree is fully ready.
      Future.delayed(const Duration(milliseconds: 500), () {
        _navigateFromPayload(initial, router);
      });
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static void _handleForeground(RemoteMessage message, GoRouter router) {
    final notification = message.notification;
    if (notification == null) return;

    // Get the root navigator's overlay to show an overlay entry
    final navigatorKey = router.routerDelegate.navigatorKey;
    final context = navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E1B4B),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        content: Row(children: [
          const Text('🪙', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (notification.title != null)
                  Text(notification.title!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
                if (notification.body != null)
                  Text(notification.body!,
                    style: const TextStyle(
                      color: Color(0xFFBBB8D9),
                      fontSize: 12)),
              ],
            ),
          ),
        ]),
        action: SnackBarAction(
          label: 'View',
          textColor: const Color(0xFFA78BFA),
          onPressed: () => _navigateFromPayload(message, router),
        ),
      ),
    );
  }

  /// Navigate to the right screen based on notification `data` payload.
  /// Supported keys:
  ///   route — a Go Router path, e.g. '/transactions' or '/home'
  ///   type  — semantic type: 'transaction' | 'coin_credit' | 'kyc_approved'
  static void _navigateFromPayload(RemoteMessage message, GoRouter router) {
    final data = message.data;

    // Explicit route override (most flexible)
    if (data['route'] != null && (data['route'] as String).isNotEmpty) {
      router.go(data['route'] as String);
      return;
    }

    // Type-based routing — must match what send-notification edge function sends
    final type = data['type'] as String? ?? '';
    switch (type) {
      case 'payment_success':
      case 'payment_failure':
      case 'transaction':
      case 'coin_credit':
      case 'coin_earned':
        router.go('/transactions');
        break;
      case 'coins_expiring':
        router.go('/home');  // home shows coin balance with expiry warning
        break;
      case 'referral_completed':
        router.go('/profile'); // referral code is on profile screen
        break;
      case 'promo':
        router.go('/explore');
        break;
      default:
        router.go('/home');
    }
  }
}
