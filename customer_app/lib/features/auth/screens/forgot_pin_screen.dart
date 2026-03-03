// lib/features/auth/screens/forgot_pin_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme.dart';
import '../services/auth_service.dart';
import '../services/pin_service.dart';
import '../providers/auth_state_provider.dart';
import '../../../core/constants.dart';
import '../../../shared/widgets/momope_button.dart';

enum _ForgotPinStep { phone, otp, newPin, confirmPin }

class ForgotPinScreen extends ConsumerStatefulWidget {
  const ForgotPinScreen({super.key});
  @override
  ConsumerState<ForgotPinScreen> createState() => _ForgotPinScreenState();
}

class _ForgotPinScreenState extends ConsumerState<ForgotPinScreen> {
  final _authService = AuthService();
  final _pinService = PinService();
  _ForgotPinStep _step = _ForgotPinStep.phone;

  final _phoneCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrls = List.generate(6, (_) => TextEditingController());
  final _enteredDigits = <String>[];
  String _tempPin = '';
  bool _loading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    for (final c in _otpCtrls) c.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_phoneCtrl.text.trim().length != 10) {
      _showError('Enter a valid 10-digit number');
      return;
    }
    setState(() => _loading = true);
    try {
      await _authService.sendOtp(_phoneCtrl.text.trim());
      setState(() => _step = _ForgotPinStep.otp);
    } on AuthException catch (e) {
      _showError(e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpCtrls.map((c) => c.text).join();
    if (otp.length != 6) { _showError('Enter 6-digit OTP'); return; }
    setState(() => _loading = true);
    try {
      await _authService.verifyOtp(otp);
      setState(() => _step = _ForgotPinStep.newPin);
    } on AuthException catch (e) {
      _showError(e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _onPinDigit(String d) {
    if (_enteredDigits.length >= AppConstants.pinLength) return;
    setState(() => _enteredDigits.add(d));
    if (_enteredDigits.length == AppConstants.pinLength) {
      final pin = _enteredDigits.join();
      final error = _pinService.validatePin(pin);
      if (error != null) {
        _showError(error);
        setState(() => _enteredDigits.clear());
      } else {
        _tempPin = pin;
        setState(() { _enteredDigits.clear(); _step = _ForgotPinStep.confirmPin; });
      }
    }
  }

  Future<void> _onConfirmDigit(String d) async {
    if (_enteredDigits.length >= AppConstants.pinLength) return;
    setState(() => _enteredDigits.add(d));
    if (_enteredDigits.length == AppConstants.pinLength) {
      final pin = _enteredDigits.join();
      if (pin != _tempPin) {
        _showError('PINs don\'t match');
        setState(() => _enteredDigits.clear());
        return;
      }
      setState(() => _loading = true);
      try {
        await _pinService.setPin(pin);
        if (!mounted) return;
        ref.read(authNotifierProvider.notifier).markPinVerified();
        context.go('/home');
      } on PinException catch (e) {
        _showError(e.message);
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: context.theme.error));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset PIN')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: switch (_step) {
            _ForgotPinStep.phone => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Enter your phone number', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 24),
                TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, maxLength: 10,
                  decoration: const InputDecoration(prefixText: '+91  ', counterText: '', hintText: '00000 00000')),
                const SizedBox(height: 24),
                MomoPeButton(label: 'Send OTP', onPressed: _sendOtp, isLoading: _loading),
              ]),
            _ForgotPinStep.otp => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Enter verification code', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) => SizedBox(width: 42,
                    child: TextField(controller: _otpCtrls[i], maxLength: 1, textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(counterText: ''),
                      onChanged: (v) { if (v.isNotEmpty && i < 5) FocusScope.of(context).nextFocus(); }))),
                ),
                const SizedBox(height: 24),
                MomoPeButton(label: 'Verify', onPressed: _verifyOtp, isLoading: _loading),
              ]),
            _ForgotPinStep.newPin => _buildPinPad('Set new PIN', _onPinDigit),
            _ForgotPinStep.confirmPin => _buildPinPad('Confirm new PIN', _onConfirmDigit),
          },
        ),
      ),
    );
  }

  Widget _buildPinPad(String title, Function(String) onDigit) {
    return Column(children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 32),
      Row(mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(AppConstants.pinLength, (i) {
          final filled = i < _enteredDigits.length;
          return Container(margin: const EdgeInsets.symmetric(horizontal: 12), width: 20, height: 20,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: filled ? context.theme.primary : context.theme.surfaceAlt,
              border: Border.all(color: filled ? context.theme.primary : context.theme.textMuted, width: 1.5)));
        })),
      const SizedBox(height: 40),
      ...[ ['1','2','3'],['4','5','6'],['7','8','9'],['','0','⌫'] ].map((row) =>
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((d) => d.isEmpty ? const SizedBox(width: 80) : GestureDetector(
            onTap: () => d == '⌫' ? setState(() => _enteredDigits.isEmpty ? null : _enteredDigits.removeLast()) : onDigit(d),
            child: Container(width: 80, height: 80, margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: context.theme.surfaceAlt, borderRadius: BorderRadius.circular(40)),
              child: Center(child: Text(d, style: TextStyle(fontSize: d=='⌫'?20:26, fontWeight: FontWeight.w600)))
            ))).toList())),
    ]);
  }
}
