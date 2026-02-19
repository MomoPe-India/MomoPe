/// Merchant business profile model
/// Matches the `merchants` table schema per MOMOPE_ECOSYSTEM.md
class Merchant {
  final String id;
  final String userId;
  final String businessName;
  final String category;
  final double commissionRate;
  
  // Business details
  final String? gstin;
  final String? pan;
  final String? businessAddress;
  
  // Banking details
  final String? bankAccountNumber;
  final String? ifscCode;
  final String? bankAccountHolderName;
  
  // Location
  final double? latitude;
  final double? longitude;
  
  // Status
  final bool isActive;
  final bool isOperational;
  final String kycStatus; // 'pending', 'approved', 'rejected'
  
  final DateTime createdAt;
  final DateTime updatedAt;

  const Merchant({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.category,
    required this.commissionRate,
    this.gstin,
    this.pan,
    this.businessAddress,
    this.bankAccountNumber,
    this.ifscCode,
    this.bankAccountHolderName,
    this.latitude,
    this.longitude,
    required this.isActive,
    required this.isOperational,
    required this.kycStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      businessName: json['business_name'] as String,
      category: json['category'] as String,
      commissionRate: (json['commission_rate'] as num).toDouble(),
      gstin: json['gstin'] as String?,
      pan: json['pan'] as String?,
      businessAddress: json['business_address'] as String?,
      bankAccountNumber: json['bank_account_number'] as String?,
      ifscCode: json['ifsc_code'] as String?,
      bankAccountHolderName: json['bank_account_holder_name'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      isOperational: json['is_operational'] as bool? ?? true,
      kycStatus: json['kyc_status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'business_name': businessName,
      'category': category,
      'commission_rate': commissionRate,
      'gstin': gstin,
      'pan': pan,
      'business_address': businessAddress,
      'bank_account_number': bankAccountNumber,
      'ifsc_code': ifscCode,
      'bank_account_holder_name': bankAccountHolderName,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': isActive,
      'is_operational': isOperational,
      'kyc_status': kycStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Merchant categories with default commission rates
enum MerchantCategory {
  grocery('grocery', 'Grocery & Retail', 20.0),
  foodBeverage('food_beverage', 'Food & Beverage', 25.0),
  retail('retail', 'Retail/Lifestyle', 30.0),
  services('services', 'Services', 35.0),
  other('other', 'Other', 20.0);

  final String value;
  final String label;
  final double defaultCommissionPercent;

  const MerchantCategory(
    this.value,
    this.label,
    this.defaultCommissionPercent,
  );

  static MerchantCategory fromValue(String value) {
    return MerchantCategory.values.firstWhere(
      (cat) => cat.value == value,
      orElse: () => MerchantCategory.other,
    );
  }
}
