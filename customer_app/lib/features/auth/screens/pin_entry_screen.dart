// lib/features/auth/screens/pin_entry_screen.dart
//
// The everyday login screen. PhonePe-style:
// - 4 dots fill as user types
// - Auto-submits on 4th digit
// - Shake + red dots on wrong PIN
// - 30s countdown on lockout
// - Force OTP on 10 failures

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/models/models.dart';
import '../../../core/theme.dart';
import '../providers/auth_state_provider.dart';
import '../services/fcm_service.dart';
import '../services/pin_service.dart';

class PinEntryScreen extends ConsumerStatefulWidget {
  const PinEntryScreen({super.key});

  @override
  ConsumerState<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends ConsumerState<PinEntryScreen>
    with SingleTickerProviderStateMixin {
  final _pinService = PinService();
  final _enteredDigits = <String>[];
  bool _loading = false;
  bool _isError = false;
  DateTime? _lockedUntil;
  Timer? _lockoutTimer;
  int _lockoutSecondsLeft = 0;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 24).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticInOut),
    );
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  void _onDigitTap(String digit) {
    if (_enteredDigits.length >= AppConstants.pinLength) return;
    if (_lockedUntil != null && DateTime.now().isBefore(_lockedUntil!)) return;
    setState(() {
      _enteredDigits.add(digit);
      _isError = false;
    });
    if (_enteredDigits.length == AppConstants.pinLength) {
      _submitPin();
    }
  }

  void _onBackspace() {
    if (_enteredDigits.isEmpty) return;
    setState(() => _enteredDigits.removeLast());
  }

  Future<void> _submitPin() async {
    setState(() => _loading = true);
    final pin = _enteredDigits.join();
    try {
      final result = await _pinService.verifyPin(pin);
      if (!mounted) return;

      switch (result.status) {
        case PinVerifyStatus.success:
          // Register FCM token on login (fire-and-forget)
          FcmService.registerToken();
          ref.read(authNotifierProvider.notifier).markPinVerified();
          context.go('/home');

        case PinVerifyStatus.wrongPin:
          _triggerError();

        case PinVerifyStatus.locked:
          setState(() {
            _lockedUntil = result.lockedUntil;
            _lockoutSecondsLeft = _lockedUntil!.difference(DateTime.now()).inSeconds + 1;
          });
          _startLockoutTimer();
          _triggerError();

        case PinVerifyStatus.forceOtp:
          // Force OTP re-verify
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Too many attempts. Please verify your phone number.'),
              backgroundColor: context.theme.error,
            ),
          );
          context.go('/forgot-pin');

        case PinVerifyStatus.notFound:
          context.go('/phone');
      }
    } on PinException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: context.theme.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _enteredDigits.clear();
        });
      }
    }
  }

  void _triggerError() {
    setState(() => _isError = true);
    _shakeController.forward(from: 0);
  }

  void _startLockoutTimer() {
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _lockoutSecondsLeft--;
        if (_lockoutSecondsLeft <= 0) {
          t.cancel();
          _lockedUntil = null;
          _lockoutSecondsLeft = 0;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = _lockedUntil != null && DateTime.now().isBefore(_lockedUntil!);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Header
            Text('Welcome back',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Enter your PIN',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: context.theme.textSecondary)),
            const SizedBox(height: 48),

            // PIN dots with shake animation
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                final offset = _shakeController.isAnimating
                    ? Offset(_shakeAnimation.value * ((_shakeController.value * 10).round().isOdd ? 1 : -1), 0)
                    : Offset.zero;
                return Transform.translate(offset: offset, child: child);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(AppConstants.pinLength, (i) {
                  final filled = i < _enteredDigits.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isError
                          ? context.theme.error
                          : filled
                              ? context.theme.primary
                              : context.theme.surfaceAlt,
                      border: Border.all(
                        color: _isError
                            ? context.theme.error
                            : filled
                                ? context.theme.primary
                                : context.theme.textMuted,
                        width: 1.5,
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Lockout message
            if (isLocked) ...[
              const SizedBox(height: 20),
              Text('Try again in $_lockoutSecondsLeft s',
                style: TextStyle(color: context.theme.error)),
            ],

            const Spacer(),

            // Numpad
            _buildNumpad(isLocked),
            const SizedBox(height: 8),

            // Forgot PIN
            TextButton(
              onPressed: () => context.push('/forgot-pin'),
              child: const Text('Forgot PIN?'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpad(bool isLocked) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          for (final row in [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
            ['', '0', '⌫'],
          ])
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: row.map((digit) {
                if (digit.isEmpty) return const SizedBox(width: 72);
                return _NumpadKey(
                  label: digit,
                  disabled: isLocked || _loading,
                  onTap: () {
                    if (digit == '⌫') {
                      _onBackspace();
                    } else {
                      _onDigitTap(digit);
                    }
                  },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _NumpadKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool disabled;

  const _NumpadKey({required this.label, required this.onTap, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        width: 72, height: 72,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: context.theme.surfaceAlt,
          borderRadius: BorderRadius.circular(36),
        ),
        child: Center(
          child: Text(label,
            style: TextStyle(
              fontSize: label == '⌫' ? 20 : 26,
              fontWeight: FontWeight.w600,
              color: disabled ? context.theme.textMuted : context.theme.textPrimary,
            )),
        ),
      ),
    );
  }
}
