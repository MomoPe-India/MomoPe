// lib/features/auth/screens/pin_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';
import '../../../core/constants.dart';
import '../services/pin_service.dart';

class MerchantPinSetupScreen extends ConsumerStatefulWidget {
  const MerchantPinSetupScreen({super.key});
  @override
  ConsumerState<MerchantPinSetupScreen> createState() => _MerchantPinSetupState();
}

class _MerchantPinSetupState extends ConsumerState<MerchantPinSetupScreen> {
  final _enteredDigits = <String>[];
  final _pinService    = PinService();
  String? _validationError;

  void _onDigit(String d) {
    if (_enteredDigits.length >= AppConstants.pinLength) return;
    setState(() {
      _enteredDigits.add(d);
      _validationError = null;
    });
    if (_enteredDigits.length == AppConstants.pinLength) {
      final pin = _enteredDigits.join();
      final error = _pinService.validatePin(pin);
      if (error != null) {
        setState(() {
          _validationError = error;
          _enteredDigits.clear();
        });
      } else {
        context.push('/pin-confirm', extra: pin);
        setState(() => _enteredDigits.clear());
      }
    }
  }

  void _onBackspace() {
    if (_enteredDigits.isEmpty) return;
    setState(() => _enteredDigits.removeLast());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Text('Set your Business PIN',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('4-digit PIN • Keep your business account secure',
              style: TextStyle(color: MerchantTheme.textSecondary),
              textAlign: TextAlign.center),
            if (_validationError != null) ...[
              const SizedBox(height: 12),
              Text(_validationError!,
                style: const TextStyle(color: MerchantTheme.error, fontSize: 13)),
            ],
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(AppConstants.pinLength, (i) {
                final filled = i < _enteredDigits.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? MerchantTheme.primary : MerchantTheme.surfaceAlt,
                    border: Border.all(
                      color: filled ? MerchantTheme.primary : MerchantTheme.textMuted,
                      width: 1.5),
                  ),
                );
              }),
            ),
            const Spacer(),
            _buildNumpad(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          for (final row in [
            ['1', '2', '3'], ['4', '5', '6'], ['7', '8', '9'], ['', '0', '⌫'],
          ])
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: row.map((d) {
                if (d.isEmpty) return const SizedBox(width: 72);
                return _Pad(label: d, onTap: () => d == '⌫' ? _onBackspace() : _onDigit(d));
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _Pad extends StatelessWidget {
  final String label; final VoidCallback onTap;
  const _Pad({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 72, height: 72,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: MerchantTheme.surfaceAlt, borderRadius: BorderRadius.circular(36)),
      child: Center(child: Text(label,
        style: TextStyle(
          fontSize: label == '⌫' ? 20 : 26, fontWeight: FontWeight.w600, color: MerchantTheme.textPrimary))),
    ),
  );
}
