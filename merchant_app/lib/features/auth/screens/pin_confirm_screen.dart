// lib/features/auth/screens/pin_confirm_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';
import '../../../core/constants.dart';
import '../services/pin_service.dart';
import '../services/fcm_service.dart';

class MerchantPinConfirmScreen extends ConsumerStatefulWidget {
  final String tempPin;
  const MerchantPinConfirmScreen({super.key, required this.tempPin});

  @override
  ConsumerState<MerchantPinConfirmScreen> createState() => _MerchantPinConfirmState();
}

class _MerchantPinConfirmState extends ConsumerState<MerchantPinConfirmScreen> {
  final _enteredDigits = <String>[];
  final _pinService    = PinService();
  bool _loading        = false;
  String? _error;

  void _onDigit(String d) {
    if (_enteredDigits.length >= AppConstants.pinLength || _loading) return;
    setState(() { _enteredDigits.add(d); _error = null; });
    if (_enteredDigits.length == AppConstants.pinLength) {
      if (_enteredDigits.join() == widget.tempPin) {
        _savePin();
      } else {
        setState(() {
          _error = 'PINs do not match. Try again.';
          _enteredDigits.clear();
        });
      }
    }
  }

  void _onBackspace() {
    if (_enteredDigits.isEmpty || _loading) return;
    setState(() => _enteredDigits.removeLast());
  }

  Future<void> _savePin() async {
    setState(() => _loading = true);
    try {
      await _pinService.setPin(widget.tempPin);
      if (mounted) {
        // Register FCM token successfully (fire-and-forget)
        FcmService.registerToken();
        
        // Go to home (auth state change will trigger redirect if unified, 
        // but here we use a manual flag like customer app)
        ref.read(merchantPinVerifiedProvider.notifier).state = true;
        context.go('/home');
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; _enteredDigits.clear(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text('Confirm PIN',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Re-enter your 4-digit PIN to confirm',
              style: TextStyle(color: MerchantTheme.textSecondary)),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(_error!, style: const TextStyle(color: MerchantTheme.error), textAlign: TextAlign.center),
              ),
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
            if (_loading) const Padding(padding: EdgeInsets.only(bottom: 100), child: CircularProgressIndicator()),
            if (!_loading) _buildNumpad(),
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
