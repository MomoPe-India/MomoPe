// lib/features/auth/screens/pin_entry_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';
import '../../../core/constants.dart';
import '../../../core/models/models.dart';
import '../services/pin_service.dart';
import '../services/fcm_service.dart';

class MerchantPinEntryScreen extends ConsumerStatefulWidget {
  const MerchantPinEntryScreen({super.key});
  @override
  ConsumerState<MerchantPinEntryScreen> createState() => _MerchantPinEntryState();
}

class _MerchantPinEntryState extends ConsumerState<MerchantPinEntryScreen> with SingleTickerProviderStateMixin {
  final _pinService = PinService();
  final _enteredDigits = <String>[];
  bool _loading = false;
  bool _isError = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _shakeAnimation = Tween<double>(begin: 0, end: 24).animate(CurvedAnimation(parent: _shakeController, curve: Curves.elasticInOut));
  }

  @override
  void dispose() { _shakeController.dispose(); super.dispose(); }

  void _onDigitTap(String digit) {
    if (_enteredDigits.length >= AppConstants.pinLength || _loading) return;
    setState(() { _enteredDigits.add(digit); _isError = false; });
    if (_enteredDigits.length == AppConstants.pinLength) _submitPin();
  }

  void _onBackspace() {
    if (_enteredDigits.isEmpty || _loading) return;
    setState(() => _enteredDigits.removeLast());
  }

  Future<void> _submitPin() async {
    setState(() => _loading = true);
    final pin = _enteredDigits.join();
    try {
      final result = await _pinService.verifyPin(pin);
      if (!mounted) return;

      if (result.status == PinVerifyStatus.success) {
        FcmService.registerToken();
        ref.read(merchantPinVerifiedProvider.notifier).state = true;
        context.go('/home');
      } else {
        _triggerError();
        if (result.status == PinVerifyStatus.locked) {
          _showError('Account locked. Try again later.');
        } else if (result.status == PinVerifyStatus.forceOtp) {
          context.go('/forgot-pin');
        }
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() { _loading = false; _enteredDigits.clear(); });
    }
  }

  void _triggerError() {
    setState(() => _isError = true);
    _shakeController.forward(from: 0);
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: MerchantTheme.error));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Text('Welcome back', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Enter your Business PIN', style: TextStyle(color: MerchantTheme.textSecondary)),
            const SizedBox(height: 48),
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) => Transform.translate(
                offset: Offset(_shakeAnimation.value * ((_shakeController.value * 10).round().isOdd ? 1 : -1), 0),
                child: child),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(AppConstants.pinLength, (i) {
                  final filled = i < _enteredDigits.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isError ? MerchantTheme.error : (filled ? MerchantTheme.primary : MerchantTheme.surfaceAlt),
                      border: Border.all(color: _isError ? MerchantTheme.error : (filled ? MerchantTheme.primary : MerchantTheme.textMuted), width: 1.5),
                    ),
                  );
                }),
              ),
            ),
            const Spacer(),
            if (_loading) const CircularProgressIndicator(),
            if (!_loading) _buildNumpad(),
            const SizedBox(height: 8),
            TextButton(onPressed: () => context.push('/forgot-pin'), child: const Text('Forgot PIN?')),
            const SizedBox(height: 24),
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
          for (final row in [['1', '2', '3'], ['4', '5', '6'], ['7', '8', '9'], ['', '0', '⌫']])
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: row.map((d) {
                if (d.isEmpty) return const SizedBox(width: 72);
                return _Pad(label: d, onTap: () => d == '⌫' ? _onBackspace() : _onDigitTap(d));
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
      decoration: BoxDecoration(color: MerchantTheme.surfaceAlt, borderRadius: BorderRadius.circular(36)),
      child: Center(child: Text(label, style: TextStyle(fontSize: label == '⌫' ? 20 : 26, fontWeight: FontWeight.w600, color: MerchantTheme.textPrimary))),
    ),
  );
}
