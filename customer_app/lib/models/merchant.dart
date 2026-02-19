/// Merchant model for MomoPe system
class Merchant {
  final String id;
  final String businessName;
  final String? logoUrl;
  final String category;
  final double commissionPercentage;
  final String? upiId;

  Merchant({
    required this.id,
    required this.businessName,
    this.logoUrl,
    required this.category,
    required this.commissionPercentage,
    this.upiId,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: json['id'] as String,
      businessName: json['business_name'] as String,
      logoUrl: json['logo_url'] as String?,
      category: json['category'] as String? ?? 'General',
      commissionPercentage:
          (json['commission_percentage'] as num?)?.toDouble() ?? 2.0,
      upiId: json['upi_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': businessName,
      'logo_url': logoUrl,
      'category': category,
      'commission_percentage': commissionPercentage,
      'upi_id': upiId,
    };
  }

  /// Creates a test merchant for development
  factory Merchant.testMerchant() {
    return Merchant(
      id: 'test-merchant-001',
      businessName: 'Reliance Fresh',
      category: 'Grocery & Retail',
      commissionPercentage: 2.5,
      upiId: 'merchant@paytm',
    );
  }
}
