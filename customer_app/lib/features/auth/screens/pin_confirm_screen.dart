// lib/features/auth/screens/pin_confirm_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../providers/auth_state_provider.dart';
import '../services/fcm_service.dart';
import '../services/pin_service.dart';

class PinConfirmScreen extends ConsumerStatefulWidget {
  final String tempPin;
  const PinConfirmScreen({super.key, required this.tempPin});
  @override
  ConsumerState<PinConfirmScreen> createState() => _PinConfirmScreenState();
}

class _PinConfirmScreenState extends ConsumerState<PinConfirmScreen> {
  final _enteredDigits = <String>[];
  final _pinService = PinService();
  bool _loading = false;
  bool _mismatch = false;

  void _onDigit(String d) {
    if (_enteredDigits.length >= AppConstants.pinLength || _loading) return;
    setState(() { _enteredDigits.add(d); _mismatch = false; });
    if (_enteredDigits.length == AppConstants.pinLength) _confirm();
  }

  void _onBackspace() {
    if (_enteredDigits.isEmpty) return;
    setState(() => _enteredDigits.removeLast());
  }

  Future<void> _confirm() async {
    final confirmPin = _enteredDigits.join();
    if (confirmPin != widget.tempPin) {
      setState(() { _mismatch = true; _enteredDigits.clear(); });
      return;
    }
    setState(() => _loading = true);
    try {
      await _pinService.setPin(confirmPin);
      if (!mounted) return;
      // Register FCM token after successful PIN setup (fire-and-forget)
      FcmService.registerToken();
      ref.read(authNotifierProvider.notifier).markPinVerified();
      context.go('/home');
    } on PinException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: context.theme.error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Text('Confirm your PIN', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Re-enter your ${AppConstants.pinLength}-digit PIN', style: TextStyle(color: context.theme.textSecondary)),
            if (_mismatch) ...[
              const SizedBox(height: 12),
              Text('PINs don\'t match. Try again.', style: TextStyle(color: context.theme.error)),
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
                    color: _mismatch ? context.theme.error : filled ? context.theme.primary : context.theme.surfaceAlt,
                    border: Border.all(color: _mismatch ? context.theme.error : filled ? context.theme.primary : context.theme.textMuted, width: 1.5),
                  ),
                );
              }),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(children: [
                for (final row in [['1','2','3'],['4','5','6'],['7','8','9'],['','0','⌫']])
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: row.map((d) {
                      if (d.isEmpty) return const SizedBox(width: 72);
                      return GestureDetector(onTap: () => d == '⌫' ? _onBackspace() : _onDigit(d),
                        child: Container(width: 72, height: 72, margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(color: context.theme.surfaceAlt, borderRadius: BorderRadius.circular(36)),
                          child: Center(child: Text(d, style: TextStyle(fontSize: d=='⌫'?20:26, fontWeight: FontWeight.w600)))));
                    }).toList()),
              ]),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
