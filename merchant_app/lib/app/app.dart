// lib/app/app.dart
// App root, theme, auth state, and router — all wired together.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import '../features/auth/screens/phone_input_screen.dart';
import '../features/auth/screens/otp_screen.dart';
import '../features/auth/screens/pin_setup_screen.dart';
import '../features/auth/screens/pin_confirm_screen.dart';
import '../features/auth/screens/pin_entry_screen.dart';
import '../features/auth/screens/forgot_pin_screen.dart';
import '../features/home/screens/merchant_home_screen.dart';
import '../features/kyc/screens/kyc_screen.dart';
import '../features/transactions/screens/merchant_transactions_screen.dart';
import '../features/profile/screens/merchant_profile_screen.dart';
import '../shared/widgets/merchant_scaffold.dart';
import '../core/notification_service.dart';

// ── Design Tokens ────────────────────────────────────────────────────────────

class MerchantTheme {
  static const primary       = Color(0xFF1A73E8);
  static const accent        = Color(0xFF00C48C);
  static const bg            = Color(0xFF0F1117);
  static const surface       = Color(0xFF1A1A27);
  static const card          = Color(0xFF1E1E30);
  static const surfaceAlt    = Color(0xFF22223B);
  static const textPrimary   = Color(0xFFF0F0F5);
  static const textSecondary = Color(0xFF9090B0);
  static const textMuted     = Color(0xFF5A5A7A);
  static const error         = Color(0xFFFF4C4C);
  static const success       = Color(0xFF00C48C);

  static ThemeData get dark {
    final base = ThemeData.dark();
    return base.copyWith(
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: primary, secondary: accent, surface: surface, error: error),
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme)
          .apply(bodyColor: textPrimary, displayColor: textPrimary),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textMuted),
      ),
    );
  }
}

// ── Auth State ────────────────────────────────────────────────────────────────

enum MerchantAuthStatus { unknown, unauthenticated, needsPinSetup, needsPin, authenticated }

/// Tracks whether the user has verified their PIN this session.
final merchantPinVerifiedProvider = StateProvider<bool>((ref) => false);

/// Stream of auth status — drives GoRouter redirect.
final merchantAuthStateProvider = StreamProvider<MerchantAuthStatus>((ref) async* {
  yield MerchantAuthStatus.unknown;

  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    if (user == null) {
      ref.read(merchantPinVerifiedProvider.notifier).state = false;
      yield MerchantAuthStatus.unauthenticated;
      continue;
    }
    try {
      // Use SECURITY DEFINER RPC — bypasses RLS (no Supabase session exists,
      // only Firebase auth. Direct table queries fail on auth.uid()::uuid cast).
      final result = await Supabase.instance.client.rpc(
        'get_or_create_merchant',
        params: {
          'firebase_uid': user.uid,
          'p_phone': user.phoneNumber ?? '',
        },
      ) as Map<String, dynamic>;

      final role      = result['role'] as String? ?? '';
      final hasPinSet = result['has_pin_set'] as bool? ?? false;

      if (role != 'merchant' && role != 'admin') {
        yield MerchantAuthStatus.unauthenticated;
        continue;
      }

      final pinVerified = ref.read(merchantPinVerifiedProvider);
      if (!hasPinSet) {
        yield MerchantAuthStatus.needsPinSetup;
      } else {
        yield pinVerified
            ? MerchantAuthStatus.authenticated
            : MerchantAuthStatus.needsPin;
      }
    } on Exception catch (e) {
      debugPrint('[Auth] Error fetching merchant profile: $e');
      yield MerchantAuthStatus.unauthenticated;
    }
  }
});


// ── Router ────────────────────────────────────────────────────────────────────
// Use listenable + refreshListenable so GoRouter is created ONCE and only
// refreshes its redirect logic when auth state changes. This avoids the
// navigator-key reset that occurs when the router is recreated.

final _routerProvider = Provider<GoRouter>((ref) {
  // Watch auth state so the provider rebuilds and calls router.refresh when it changes.
  // Because GoRouter is created once as a Provider (not StreamProvider), it stays stable.
  final notifier = _AuthNotifier(ref);

  return GoRouter(
    initialLocation: '/phone',
    refreshListenable: notifier,
    redirect: (context, state) {
      final status = ref.read(merchantAuthStateProvider).valueOrNull
          ?? MerchantAuthStatus.unknown;
      final pinVerified = ref.read(merchantPinVerifiedProvider);
      final loc = state.uri.path;

      switch (status) {
        case MerchantAuthStatus.unknown:
          return null;
        case MerchantAuthStatus.unauthenticated:
          if (!loc.startsWith('/phone') &&
              !loc.startsWith('/otp') &&
              !loc.startsWith('/forgot-pin')) return '/phone';
          return null;
        case MerchantAuthStatus.needsPinSetup:
          // PIN was just set this session — auth stream hasn't re-emitted yet.
          // Trust the local pinVerified flag and let the user through.
          if (pinVerified) return null;
          if (!loc.startsWith('/pin-setup') && !loc.startsWith('/pin-confirm')) {
            return '/pin-setup';
          }
          return null;
        case MerchantAuthStatus.needsPin:
          if (pinVerified) return null; // just verified this session
          if (!loc.startsWith('/pin') && !loc.startsWith('/forgot-pin')) return '/pin';
          return null;
        case MerchantAuthStatus.authenticated:
          if (loc.startsWith('/phone') ||
              loc.startsWith('/otp') ||
              loc.startsWith('/pin')) return '/home';
          return null;
      }
    },
    routes: [
      GoRoute(path: '/phone', builder: (_, __) => const MerchantPhoneInputScreen()),
      GoRoute(
        path: '/otp',
        builder: (_, s) {
          final data = s.extra as Map<String, dynamic>;
          return MerchantOtpScreen(
            phone: data['phone'] as String,
            verificationId: data['verificationId'] as String,
          );
        },
      ),
      GoRoute(path: '/pin-setup',  builder: (_, __) => const MerchantPinSetupScreen()),
      GoRoute(
        path: '/pin-confirm',
        builder: (_, s) => MerchantPinConfirmScreen(tempPin: s.extra as String),
      ),
      GoRoute(path: '/pin',        builder: (_, __) => const MerchantPinEntryScreen()),
      GoRoute(path: '/forgot-pin', builder: (_, __) => const MerchantForgotPinScreen()),
      ShellRoute(
        builder: (_, __, child) => MerchantScaffold(child: child),
        routes: [
          GoRoute(path: '/home',         builder: (_, __) => const MerchantHomeScreen()),
          GoRoute(path: '/kyc',          builder: (_, __) => const KycScreen()),
          GoRoute(path: '/transactions', builder: (_, __) => const MerchantTransactionsScreen()),
          GoRoute(path: '/profile',      builder: (_, __) => const MerchantProfileScreen()),
        ],
      ),
    ],
  );
});

// Convenience re-export so existing code still works with merchantRouterProvider.
final merchantRouterProvider = _routerProvider;

/// ChangeNotifier that notifies GoRouter when auth state OR pin-verified flag changes.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(this._ref) {
    // Refresh router on every auth state change
    _ref.listen(merchantAuthStateProvider, (_, __) => notifyListeners());
    // Also refresh when the user verifies/sets their PIN this session,
    // because the auth stream won't re-emit (Firebase auth didn't change).
    _ref.listen(merchantPinVerifiedProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}

// ── App Widget ────────────────────────────────────────────────────────────────

class MomoPeMerchantApp extends ConsumerStatefulWidget {
  const MomoPeMerchantApp({super.key});

  @override
  ConsumerState<MomoPeMerchantApp> createState() => _MomoPeMerchantAppState();
}

class _MomoPeMerchantAppState extends ConsumerState<MomoPeMerchantApp> {
  @override
  void initState() {
    super.initState();
    // Wire FCM notification handlers after the first frame so the router is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = ref.read(merchantRouterProvider);
      NotificationService.init(router);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(merchantRouterProvider);
    return MaterialApp.router(
      title: 'MomoPe Business',
      debugShowCheckedModeBanner: false,
      theme: MerchantTheme.dark,
      routerConfig: router,
    );
  }
}
