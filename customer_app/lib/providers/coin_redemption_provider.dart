import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/coin_redemption_service.dart';

/// Provider for CoinRedemptionService
/// 
/// Use this provider to access FIFO coin redemption functionality
/// throughout the app.
final coinRedemptionServiceProvider = Provider<CoinRedemptionService>((ref) {
  return CoinRedemptionService();
});
