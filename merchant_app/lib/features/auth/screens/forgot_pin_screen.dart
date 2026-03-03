// lib/features/auth/screens/forgot_pin_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app.dart';

class MerchantForgotPinScreen extends ConsumerStatefulWidget {
  const MerchantForgotPinScreen({super.key});
  @override
  ConsumerState<MerchantForgotPinScreen> createState() => _MerchantForgotPinState();
}

class _MerchantForgotPinState extends ConsumerState<MerchantForgotPinScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Business PIN')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_reset, size: 80, color: MerchantTheme.primary),
            const SizedBox(height: 24),
            const Text('Need to reset your PIN?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            const Text(
              'For security, you need to re-verify your phone number to set a new 4-digit PIN for your business account.',
              textAlign: TextAlign.center,
              style: TextStyle(color: MerchantTheme.textSecondary),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => context.go('/phone'),
              child: const Text('Re-verify Phone Number'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
