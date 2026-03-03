// lib/features/auth/services/pin_service.dart
import 'package:bcrypt/bcrypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants.dart';
import '../../../core/models/models.dart';

class PinException implements Exception {
  final String message;
  const PinException(this.message);
  @override
  String toString() => 'PinException: $message';
}

class PinService {
  PinService({
    SupabaseClient? supabase,
    FirebaseAuth? firebaseAuth,
  })  : _supabase   = supabase      ?? Supabase.instance.client,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final SupabaseClient  _supabase;
  final FirebaseAuth    _firebaseAuth;

  /// Current Firebase UID — required for all DB operations.
  String get _uid {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) throw const PinException('Not signed in. Please sign in again.');
    return uid;
  }

  // ── Validation ──────────────────────────────────────────────────────────────
  String? validatePin(String pin) {
    if (pin.length != AppConstants.pinLength) {
      return 'PIN must be exactly ${AppConstants.pinLength} digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      return 'PIN must contain digits only';
    }
    if (pin.split('').toSet().length == 1) {
      return 'PIN cannot be all the same digit';
    }
    bool isAsc = true;
    for (int i = 1; i < pin.length; i++) {
      if (int.parse(pin[i]) != int.parse(pin[i - 1]) + 1) { isAsc = false; break; }
    }
    if (isAsc) return 'PIN cannot be sequential (e.g. 1234)';
    bool isDesc = true;
    for (int i = 1; i < pin.length; i++) {
      if (int.parse(pin[i]) != int.parse(pin[i - 1]) - 1) { isDesc = false; break; }
    }
    if (isDesc) return 'PIN cannot be sequential (e.g. 4321)';
    return null;
  }

  // ── Hashing ─────────────────────────────────────────────────────────────────
  String hashPin(String pin) =>
      BCrypt.hashpw(pin, BCrypt.gensalt(logRounds: 10));

  // ── Set PIN ─────────────────────────────────────────────────────────────────
  // Hashes PIN on-device, then calls the updated set_pin RPC with the
  // explicit Firebase UID (no longer relies on broken auth.uid()).
  Future<void> setPin(String plainPin) async {
    final error = validatePin(plainPin);
    if (error != null) throw PinException(error);

    final uid  = _uid;
    final hash = hashPin(plainPin);
    debugPrint('[PinService] setPin for UID: $uid');

    try {
      await _supabase.rpc('set_pin', params: {
        'p_user_id': uid,
        'pin_hash':  hash,
      });
      debugPrint('[PinService] PIN saved successfully for UID: $uid');
    } on PostgrestException catch (e) {
      debugPrint('[PinService] setPin PostgrestException: ${e.code} ${e.message}');
      throw PinException('Failed to save PIN: ${e.message}');
    }
  }

  // ── Verify PIN ──────────────────────────────────────────────────────────────
  // Passes Firebase UID explicitly — no longer relies on broken auth.uid().
  Future<PinVerifyResult> verifyPin(String plainPin) async {
    final uid = _uid;
    debugPrint('[PinService] verifyPin for UID: $uid');
    try {
      final result = await _supabase.rpc(
        'verify_pin',
        params: {
          'p_user_id':   uid,
          'entered_pin': plainPin,
        },
      );
      return PinVerifyResult.fromMap(result as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      debugPrint('[PinService] verifyPin PostgrestException: ${e.code} ${e.message}');
      throw PinException('PIN verification failed: ${e.message}');
    }
  }

  // ── Reset (after forgot-PIN OTP) ─────────────────────────────────────────
  Future<void> resetAndSetNewPin(String newPlainPin) async =>
      setPin(newPlainPin);
}
