// lib/core/models/user_model.dart

class UserModel {
  final String id;           // Firebase UID
  final String name;
  final String phone;        // 10-digit, no +91
  final String role;
  final bool hasPinSet;
  final String? referralCode;
  final String? referredBy;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.hasPinSet,
    this.referralCode,
    this.referredBy,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id:           map['id'] as String,
      name:         map['name'] as String? ?? '',
      phone:        map['phone'] as String,
      role:         map['role'] as String,
      // pin_hash is never used client-side; we only check if it's non-null
      hasPinSet:    map['pin_hash'] != null,
      referralCode: map['referral_code'] as String?,
      referredBy:   map['referred_by'] as String?,
      createdAt:    DateTime.parse(map['created_at'] as String),
    );
  }
}

class CoinBalance {
  final double totalCoins;
  final double availableCoins;
  final double lockedCoins;

  const CoinBalance({
    this.totalCoins = 0,
    required this.availableCoins,
    required this.lockedCoins,
  });

  factory CoinBalance.fromMap(Map<String, dynamic> map) {
    return CoinBalance(
      totalCoins:     (map['total_coins'] as num?)?.toDouble() ?? 0,
      availableCoins: (map['available_coins'] as num).toDouble(),
      lockedCoins:    (map['locked_coins'] as num).toDouble(),
    );
  }

  static const empty = CoinBalance(
    availableCoins: 0,
    lockedCoins: 0,
  );
}

class MerchantModel {
  final String id;
  final String businessName;
  final String category;
  final String kycStatus;
  final double? latitude;
  final double? longitude;
  final bool isActive;
  final bool isOperational;

  const MerchantModel({
    required this.id,
    required this.businessName,
    required this.category,
    required this.kycStatus,
    this.latitude,
    this.longitude,
    required this.isActive,
    required this.isOperational,
  });

  factory MerchantModel.fromMap(Map<String, dynamic> map) {
    return MerchantModel(
      id:            map['id'] as String,
      businessName:  map['business_name'] as String,
      category:      map['category'] as String,
      kycStatus:     map['kyc_status'] as String,
      latitude:      (map['latitude'] as num?)?.toDouble(),
      longitude:     (map['longitude'] as num?)?.toDouble(),
      isActive:      map['is_active'] as bool? ?? true,
      isOperational: map['is_operational'] as bool? ?? true,
    );
  }
}

class TransactionModel {
  final String id;
  final String merchantId;
  final String? merchantName;
  final double grossAmount;
  final double fiatAmount;
  final double coinsApplied;
  final double coinsEarned;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;

  const TransactionModel({
    required this.id,
    required this.merchantId,
    this.merchantName,
    required this.grossAmount,
    required this.fiatAmount,
    required this.coinsApplied,
    this.coinsEarned = 0,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    // merchant_name comes directly from get_customer_transactions RPC.
    // For backward-compat, also support nested map['merchants']['business_name'].
    final nestedMerchant = map['merchants'] as Map<String, dynamic>?;
    final merchantName   = map['merchant_name'] as String?
                        ?? nestedMerchant?['business_name'] as String?;
    return TransactionModel(
      id:           map['id'] as String,
      merchantId:   (map['merchant_id'] as String?) ?? '',
      merchantName: merchantName,
      grossAmount:  (map['gross_amount'] as num).toDouble(),
      fiatAmount:   (map['fiat_amount']  as num? ?? map['gross_amount'] as num).toDouble(),
      coinsApplied: (map['coins_applied'] as num? ?? 0).toDouble(),
      coinsEarned:  (map['coins_earned']  as num? ?? 0).toDouble(),
      status:       map['status'] as String,
      createdAt:    DateTime.parse(map['created_at'] as String),
      completedAt:  map['completed_at'] != null
                     ? DateTime.parse(map['completed_at'] as String)
                     : null,
    );
  }
}

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
                    ? DateTime.parse(map['locked_until'] as String)
                    : null,
      attempts: map['attempts'] as int?,
    );
  }
}
