// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../core/notification_service.dart';
import '../features/auth/providers/auth_state_provider.dart';
import '../features/auth/screens/phone_input_screen.dart';
import '../features/auth/screens/otp_verification_screen.dart';
import '../features/auth/screens/name_entry_screen.dart';
import '../features/auth/screens/referral_code_screen.dart';
import '../features/auth/screens/pin_setup_screen.dart';
import '../features/auth/screens/pin_confirm_screen.dart';
import '../features/auth/screens/pin_entry_screen.dart';
import '../features/auth/screens/forgot_pin_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/explore/screens/explore_screen.dart';
import '../features/alerts/screens/notifications_screen.dart';
import '../features/payment/screens/qr_scanner_screen.dart';
import '../features/transaction/screens/transaction_history_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/payment/screens/payment_screen.dart';
import '../features/payment/screens/payment_result_screen.dart';
import '../features/referral/screens/referral_screen.dart';
import '../shared/widgets/main_scaffold.dart';

class MomoPeCustomerApp extends ConsumerStatefulWidget {
  const MomoPeCustomerApp({super.key});

  @override
  ConsumerState<MomoPeCustomerApp> createState() => _MomoPeCustomerAppState();
}

class _MomoPeCustomerAppState extends ConsumerState<MomoPeCustomerApp> {
  @override
  void initState() {
    super.initState();
    // Init FCM notification handlers after the first render (router ready)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = ref.read(routerProvider);
      NotificationService.init(router);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'MomoPe',
      debugShowCheckedModeBanner: false,
      theme: MomoPeTheme.light,
      darkTheme: MomoPeTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

// ── Router ──────────────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final authStream   = ref.watch(authStateProvider);
  final notifierStatus = ref.watch(authNotifierProvider);

  // Prefer the most privileged status between the stream and notifier.
  // This makes markPinVerified() immediately redirect without waiting for
  // the Firebase auth stream to re-emit (which can take several seconds).
  AuthStatus _effectiveStatus() {
    final streamStatus = authStream.valueOrNull ?? AuthStatus.unknown;
    // If the notifier explicitly says authenticated, trust it immediately
    if (notifierStatus == AuthStatus.authenticated) return AuthStatus.authenticated;
    // If the notifier says unauthenticated (sign out), trust it
    if (notifierStatus == AuthStatus.unauthenticated) return AuthStatus.unauthenticated;
    return streamStatus;
  }

  return GoRouter(
    initialLocation: '/phone',
    redirect: (context, state) {
      final status = _effectiveStatus();
      final loc = state.uri.path;

      switch (status) {
        case AuthStatus.unknown:
          return null; // let splash handle it
        case AuthStatus.unauthenticated:
          if (!loc.startsWith('/phone') && !loc.startsWith('/otp') &&
              !loc.startsWith('/name') && !loc.startsWith('/referral') &&
              !loc.startsWith('/forgot-pin')) {
            return '/phone';
          }
          return null;
        case AuthStatus.needsPinSetup:
          // Allow all new-user onboarding routes to complete naturally.
          // IMPORTANT: /otp must be whitelisted — when OTP verifies, Firebase
          // fires auth state before the screen can navigate to /name.
          // Without this, the router hijacks the navigation to /pin-setup,
          // createUserProfile is never called, and set_pin fails.
          if (!loc.startsWith('/otp') &&
              !loc.startsWith('/name') &&
              !loc.startsWith('/referral') &&
              !loc.startsWith('/pin-setup') &&
              !loc.startsWith('/pin-confirm')) {
            return '/pin-setup';
          }
          return null;
        case AuthStatus.needsPin:
          if (!loc.startsWith('/pin') && !loc.startsWith('/forgot-pin')) {
            return '/pin';
          }
          return null;
        case AuthStatus.authenticated:
          if (loc.startsWith('/phone') || loc.startsWith('/otp') ||
              loc.startsWith('/pin') && !loc.startsWith('/pin-setup') && !loc.startsWith('/pin-confirm')) {
            return '/home';
          }
          return null;
      }
    },
    routes: [
      // Auth flow
      GoRoute(path: '/phone',     builder: (_, __) => const PhoneInputScreen()),
      GoRoute(path: '/otp',       builder: (_, s)  => OtpVerificationScreen(phone: s.extra as String)),
      GoRoute(path: '/name',      builder: (_, __) => const NameEntryScreen()),
      GoRoute(path: '/referral',  builder: (_, __) => const ReferralCodeScreen()),
      GoRoute(path: '/pin-setup', builder: (_, __) => const PinSetupScreen()),
      GoRoute(path: '/pin-confirm', builder: (_, s) => PinConfirmScreen(tempPin: s.extra as String)),
      GoRoute(path: '/pin',       builder: (_, __) => const PinEntryScreen()),
      GoRoute(path: '/forgot-pin', builder: (_, __) => const ForgotPinScreen()),

      // Main app (with bottom nav)
      ShellRoute(
        builder: (_, __, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: '/home',         builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: '/explore',      builder: (_, __) => const ExploreScreen()),
          GoRoute(path: '/offers',       builder: (_, __) => const ExploreScreen()),
          GoRoute(path: '/scan',         builder: (_, __) => const QrScannerScreen()),
          GoRoute(path: '/transactions', builder: (_, __) => const TransactionHistoryScreen()),
          GoRoute(path: '/referrals',    builder: (_, __) => const ReferralScreen()),
          GoRoute(path: '/profile',      builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // Payment flow (full-screen, no bottom nav)
      GoRoute(path: '/payment',
        builder: (_, s) => PaymentScreen(merchantId: s.extra as String)),
      GoRoute(path: '/payment-result',
        builder: (_, s) => PaymentResultScreen(data: s.extra as Map<String, dynamic>)),
    ],
  );
});
