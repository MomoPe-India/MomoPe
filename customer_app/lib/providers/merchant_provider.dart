import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Model representing a merchant
class Merchant {
  final String id;
  final String name;
  final String category;
  final String? address;
  final String? logoUrl;
  final bool isActive;
  final double? rewardsPercentage;
  final DateTime createdAt;

  Merchant({
    required this.id,
    required this.name,
    required this.category,
    this.address,
    this.logoUrl,
    required this.isActive,
    this.rewardsPercentage,
    required this.createdAt,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Merchant',
      category: json['category'] as String? ?? 'General',
      address: json['address'] as String?,
      logoUrl: json['logo_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      rewardsPercentage: json['rewards_percentage'] != null
          ? (json['rewards_percentage'] as num).toDouble()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'address': address,
      'logo_url': logoUrl,
      'is_active': isActive,
      'rewards_percentage': rewardsPercentage,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Provider to fetch all active merchants
final merchantsProvider = FutureProvider<List<Merchant>>((ref) async {
  try {
    final response = await Supabase.instance.client
        .from('merchants')
        .select()
        .eq('is_active', true)
        .order('name', ascending: true);

    return (response as List)
        .map((json) => Merchant.fromJson(json as Map<String, dynamic>))
        .toList();
  } catch (e) {
    print('Error fetching merchants: $e');
    return [];
  }
});

/// Provider to fetch nearby/featured merchants (limited to 5)
final nearbyMerchantsProvider = FutureProvider<List<Merchant>>((ref) async {
  try {
    final response = await Supabase.instance.client
        .from('merchants')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .limit(5);

    return (response as List)
        .map((json) => Merchant.fromJson(json as Map<String, dynamic>))
        .toList();
  } catch (e) {
    print('Error fetching nearby merchants: $e');
    return [];
  }
});

/// Provider to search merchants by name or category
final merchantSearchProvider = FutureProvider.family<List<Merchant>, String>(
  (ref, query) async {
    if (query.isEmpty) {
      return ref.watch(merchantsProvider).value ?? [];
    }

    try {
      final response = await Supabase.instance.client
          .from('merchants')
          .select()
          .eq('is_active', true)
          .or('name.ilike.%$query%,category.ilike.%$query%')
          .order('name', ascending: true);

      return (response as List)
          .map((json) => Merchant.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error searching merchants: $e');
      return [];
    }
  },
);

/// Provider to filter merchants by category
final merchantsByCategoryProvider =
    FutureProvider.family<List<Merchant>, String>(
  (ref, category) async {
    if (category == 'All') {
      return ref.watch(merchantsProvider).value ?? [];
    }

    try {
      final response = await Supabase.instance.client
          .from('merchants')
          .select()
          .eq('is_active', true)
          .eq('category', category)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => Merchant.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error filtering merchants by category: $e');
      return [];
    }
  },
);

