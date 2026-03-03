// lib/features/auth/screens/phone_input_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';
import '../../../core/constants.dart';

class MerchantPhoneInputScreen extends ConsumerStatefulWidget {
  const MerchantPhoneInputScreen({super.key});
  @override
  ConsumerState<MerchantPhoneInputScreen> createState() => _MerchantPhoneInputState();
}

class _MerchantPhoneInputState extends ConsumerState<MerchantPhoneInputScreen> {
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final phone = _ctrl.text.trim();
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91$phone',
        timeout: const Duration(seconds: AppConstants.otpTimeoutSeconds),
        verificationCompleted: (_) {},
        verificationFailed: (e) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification Failed: ${e.message}'), backgroundColor: MerchantTheme.error));
          setState(() => _loading = false);
        },
        codeSent: (id, _) {
          if (mounted) {
            setState(() => _loading = false);
            context.push('/otp', extra: {'phone': phone, 'verificationId': id});
          }
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: MerchantTheme.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: MerchantTheme.primary, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.store, color: Colors.white, size: 26)),
                const SizedBox(width: 12),
                const Text('MomoPe Business', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 48),
              Text('Merchant Login', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Enter your registered phone number to continue', style: TextStyle(color: MerchantTheme.textSecondary)),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _ctrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  autofocus: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(fontSize: 20, letterSpacing: 4, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(counterText: '', prefixText: '+91  ', hintText: '00000 00000'),
                  validator: (v) => v == null || v.length != 10 ? 'Enter a valid 10-digit number' : null,
                  onFieldSubmitted: (_) => _sendOtp(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _sendOtp,
                child: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Send Verification Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
