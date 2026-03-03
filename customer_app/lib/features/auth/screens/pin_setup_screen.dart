// lib/features/auth/screens/pin_setup_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../providers/auth_state_provider.dart';
import '../services/pin_service.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});
  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final _enteredDigits = <String>[];
  final _pinService    = PinService();
  String? _validationError;
  bool _checking = true; // guard: checking if profile exists

  @override
  void initState() {
    super.initState();
    _guardProfile();
  }

  /// Safety guard: if profile doesn't exist when this screen loads,
  /// redirect to /name so createUserProfile is called first.
  /// This catches the edge case where the router race condition (Firebase auth
  /// state fires during OTP → needsPinSetup → router navigates here before
  /// the OTP screen can navigate to /name) still slips through.
  Future<void> _guardProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) context.go('/phone');
        return;
      }
      final profile = await ref.read(authServiceProvider).fetchUserProfile();
      if (!mounted) return;
      if (profile == null) {
        // Profile not created yet — must go through name entry first
        context.go('/name');
        return;
      }
    } catch (_) {
      // If the check fails, let the user proceed (set_pin will surface the error)
    }
    if (mounted) setState(() => _checking = false);
  }

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
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Text('Set your PIN',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('${AppConstants.pinLength}-digit PIN • You\'ll use this every time you open the app',
              style: TextStyle(color: context.theme.textSecondary),
              textAlign: TextAlign.center),
            if (_validationError != null) ...[
              const SizedBox(height: 12),
              Text(_validationError!,
                style: TextStyle(color: context.theme.error)),
            ],
            const SizedBox(height: 48),
            // PIN dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(AppConstants.pinLength, (i) {
                final filled = i < _enteredDigits.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? context.theme.primary : context.theme.surfaceAlt,
                    border: Border.all(
                      color: filled ? context.theme.primary : context.theme.textMuted,
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
        color: context.theme.surfaceAlt, borderRadius: BorderRadius.circular(36)),
      child: Center(child: Text(label,
        style: TextStyle(
          fontSize: label == '⌫' ? 20 : 26, fontWeight: FontWeight.w600))),
    ),
  );
}
