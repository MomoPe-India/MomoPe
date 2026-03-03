// lib/features/auth/providers/auth_state_provider.dart
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants.dart';
import '../services/auth_service.dart';

// ── Singleton AuthService so verificationId is shared across all screens ─────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ── Auth Status Enum ──────────────────────────────────────────────────────────
enum AuthStatus {
  unknown,
  unauthenticated,
  needsPinSetup,   // Firebase OK, but no profile/PIN yet (new user)
  needsPin,        // Firebase OK, PIN set, but not verified this session
  authenticated,   // Firebase + PIN both verified
}

// ── In-memory PIN verified flag (session-only) ────────────────────────────────
final pinVerifiedProvider = StateProvider<bool>((ref) => false);

// ── AuthState Stream Provider ─────────────────────────────────────────────────
// Drives GoRouter redirects. Rebuilds whenever Firebase auth state changes.
final authStateProvider = StreamProvider<AuthStatus>((ref) async* {
  yield AuthStatus.unknown;

  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    if (user == null) {
      ref.read(pinVerifiedProvider.notifier).state = false;
      yield AuthStatus.unauthenticated;
      continue;
    }

    // Firebase session active — fetch profile via Edge Function
    // (which verifies the Firebase token server-side and bypasses RLS)
    try {
      final idToken  = await user.getIdToken(true);
      final response = await http.post(
        Uri.parse('${AppConstants.supabaseUrl}/functions/v1/get-profile'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type':  'application/json',
          'apikey':        AppConstants.supabaseAnonKey,
        },
      );

      if (response.statusCode != 200) {
        debugPrint('[authStateProvider] get-profile HTTP ${response.statusCode}: ${response.body}');
        yield AuthStatus.unauthenticated;
        continue;
      }

      final body    = jsonDecode(response.body) as Map<String, dynamic>;
      final profile = body['profile'] as Map<String, dynamic>?;

      if (profile == null) {
        // No DB row yet — new user
        yield AuthStatus.needsPinSetup;
        continue;
      }

      final hasPinSet = profile['pin_hash'] != null;
      if (!hasPinSet) {
        yield AuthStatus.needsPinSetup;
      } else {
        final pinVerified = ref.read(pinVerifiedProvider);
        yield pinVerified ? AuthStatus.authenticated : AuthStatus.needsPin;
      }
    } catch (e) {
      debugPrint('[authStateProvider] error: $e');
      yield AuthStatus.unauthenticated;
    }
  }
});

// ── AuthNotifier — manual state updates (PIN verified, sign out) ──────────────
class AuthNotifier extends StateNotifier<AuthStatus> {
  AuthNotifier(this._ref) : super(AuthStatus.unknown);
  final Ref _ref;

  void markPinVerified() {
    _ref.read(pinVerifiedProvider.notifier).state = true;
    state = AuthStatus.authenticated;
  }

  void markNeedsPinSetup() => state = AuthStatus.needsPinSetup;
  void markNeedsPin()      => state = AuthStatus.needsPin;

  Future<void> signOut() async {
    _ref.read(pinVerifiedProvider.notifier).state = false;
    await FirebaseAuth.instance.signOut();
    state = AuthStatus.unauthenticated;
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthStatus>(
  (ref) => AuthNotifier(ref),
);
