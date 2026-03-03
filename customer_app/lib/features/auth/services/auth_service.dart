// lib/features/auth/services/auth_service.dart
//
// AuthService is a Riverpod singleton — use ref.read(authServiceProvider) in widgets.
// NEVER instantiate AuthService() directly.
//
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../../../core/constants.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => 'AuthException: $message';
}

class AuthService {
  AuthService({
    FirebaseAuth? firebaseAuth,
    SupabaseClient? supabase,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _db   = supabase   ?? Supabase.instance.client;

  final FirebaseAuth _auth;
  final SupabaseClient _db;

  String? _verificationId;
  int _resendAttempts = 0;

  // ── Getters ────────────────────────────────────────────────────────────────
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Step 1: Send OTP ──────────────────────────────────────────────────────
  Future<void> sendOtp(String phone) async {
    if (_resendAttempts >= AppConstants.maxOtpResendAttempts) {
      throw const AuthException('Too many OTP attempts. Try again in 10 minutes.');
    }
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+91$phone',
        timeout: const Duration(seconds: AppConstants.otpTimeoutSeconds),
        verificationCompleted: (credential) async {
          debugPrint('[AuthService] Auto-verified for $phone');
        },
        verificationFailed: (e) {
          final msg = switch (e.code) {
            'invalid-phone-number' => 'Invalid phone number. Enter 10 digits.',
            'too-many-requests'    => 'Too many requests. Try later.',
            'quota-exceeded'       => 'SMS quota exceeded. Try later.',
            _                      => 'OTP send failed: ${e.message}',
          };
          throw AuthException(msg);
        },
        codeSent: (verificationId, resendToken) {
          _verificationId = verificationId;
          _resendAttempts++;
          debugPrint('[AuthService] verificationId stored: $verificationId');
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId ??= verificationId;
        },
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'OTP send failed');
    }
  }

  // ── Step 2: Verify OTP ────────────────────────────────────────────────────
  Future<User> verifyOtp(String smsCode) async {
    if (_verificationId == null) {
      throw const AuthException('No OTP session. Please request OTP first.');
    }
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      final result = await _auth.signInWithCredential(credential);
      final user = result.user;
      if (user == null) throw const AuthException('Sign-in returned null user');
      debugPrint('[AuthService] OTP verified, Firebase UID: ${user.uid}');
      _resendAttempts = 0;
      return user;
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'invalid-verification-code' => 'Wrong OTP. Please try again.',
        'session-expired'           => 'OTP expired. Request a new one.',
        _                           => e.message ?? 'OTP verification failed',
      };
      throw AuthException(msg);
    }
  }

  // ── Fetch user profile via Edge Function ────────────────────────────────────
  // Calls the `get-profile` Edge Function which verifies the Firebase token
  // server-side using Google's tokeninfo endpoint and returns the profile
  // via the Supabase service role (bypasses RLS entirely).
  Future<Map<String, dynamic>?> fetchUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('[AuthService] fetchUserProfile: no Firebase user');
      return null;
    }

    try {
      // Always get a fresh ID token to avoid expiry issues
      final idToken = await user.getIdToken(true);
      debugPrint('[AuthService] Fetching profile for UID: ${user.uid}');

      final response = await http.post(
        Uri.parse('${AppConstants.supabaseUrl}/functions/v1/get-profile'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
          'apikey': AppConstants.supabaseAnonKey,
        },
      );

      if (response.statusCode == 401) {
        debugPrint('[AuthService] get-profile: 401 invalid token');
        throw const AuthException('Session expired. Please sign in again.');
      }

      if (response.statusCode != 200) {
        debugPrint('[AuthService] get-profile: ${response.statusCode} ${response.body}');
        throw AuthException('Profile fetch failed: ${response.body}');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final profile = body['profile'];
      debugPrint('[AuthService] Profile: ${profile == null ? "null (new user)" : "found"}');
      return profile as Map<String, dynamic>?;
    } on AuthException {
      rethrow;
    } catch (e) {
      debugPrint('[AuthService] fetchUserProfile error: $e');
      throw AuthException('Profile fetch failed: $e');
    }
  }

  // ── Create user profile (new user registration via RPC) ───────────────────
  // The `create_user_profile` RPC is SECURITY DEFINER — bypasses RLS.
  // But we still need a valid Supabase session. We use the anon key here
  // because `create_user_profile` is SECURITY DEFINER and doesn't check RLS.
  Future<void> createUserProfile({
    required String firebaseUid,
    required String phone,
    required String name,
    String? referralCodeUsed,
  }) async {
    try {
      await _db.rpc('create_user_profile', params: {
        'firebase_uid':       firebaseUid,
        'phone':              phone,
        'name':               name,
        'referral_code_used': referralCodeUsed,
      });
      debugPrint('[AuthService] Profile created for UID: $firebaseUid');
    } on PostgrestException catch (e) {
      throw AuthException('Profile creation failed: ${e.message}');
    }
  }

  // ── Sign out ───────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    _verificationId = null;
    _resendAttempts = 0;
    await _auth.signOut();
    debugPrint('[AuthService] Signed out');
  }

  // ── Fresh ID token ─────────────────────────────────────────────────────────
  Future<String?> getIdToken() async =>
      await _auth.currentUser?.getIdToken(true);
}
