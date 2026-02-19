import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/payment_service.dart';

/// Payment service provider
final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});
