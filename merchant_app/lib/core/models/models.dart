// lib/core/models/models.dart
// Shared data models for the merchant app.

// ── PIN verification ─────────────────────────────────────────────────────────

enum PinVerifyStatus { success, wrongPin, locked, forceOtp, notFound }

class PinVerifyResult {
  final PinVerifyStatus status;
  final DateTime? lockedUntil;
  final int? attempts;

  const PinVerifyResult({
    required this.status,
    this.lockedUntil,
    this.attempts,
  });

  factory PinVerifyResult.fromMap(Map<String, dynamic> map) {
    final success = map['success'] as bool? ?? false;
    if (success) return const PinVerifyResult(status: PinVerifyStatus.success);

    final code = map['code'] as String? ?? '';
    return PinVerifyResult(
      status: switch (code) {
        'WRONG_PIN'  => PinVerifyStatus.wrongPin,
        'PIN_LOCKED' => PinVerifyStatus.locked,
        'FORCE_OTP'  => PinVerifyStatus.forceOtp,
        'NOT_FOUND'  => PinVerifyStatus.notFound,
        _            => PinVerifyStatus.wrongPin,
      },
      lockedUntil: map['locked_until'] != null
                    ? DateTime.tryParse(map['locked_until'] as String)
                    : null,
      attempts: map['attempts'] as int?,
    );
  }
}

// ── Merchant profile ─────────────────────────────────────────────────────────

class MerchantUserModel {
  final String id;
  final String name;
  final String phone;
  final String role;
  final bool hasPinSet;
  final DateTime createdAt;

  const MerchantUserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.hasPinSet,
    required this.createdAt,
  });

  factory MerchantUserModel.fromMap(Map<String, dynamic> map) {
    return MerchantUserModel(
      id:        map['id'] as String,
      name:      map['name'] as String? ?? '',
      phone:     map['phone'] as String,
      role:      map['role'] as String,
      hasPinSet: map['pin_hash'] != null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
