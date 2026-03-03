// lib/features/auth/screens/otp_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/app.dart';

class MerchantOtpScreen extends ConsumerStatefulWidget {
  final String phone;
  final String verificationId;
  const MerchantOtpScreen({super.key, required this.phone, required this.verificationId});

  @override
  ConsumerState<MerchantOtpScreen> createState() => _MerchantOtpScreenState();
}

class _MerchantOtpScreenState extends ConsumerState<MerchantOtpScreen> {
  final _ctrls = List.generate(6, (_) => TextEditingController());
  bool _loading = false;

  @override
  void dispose() { for (final c in _ctrls) c.dispose(); super.dispose(); }

  Future<void> _verify() async {
    final otp = _ctrls.map((c) => c.text).join();
    if (otp.length != 6) return;
    setState(() => _loading = true);
    try {
      // 1. Verify OTP with Firebase
      final cred = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );
      final result = await FirebaseAuth.instance.signInWithCredential(cred);
      final user = result.user;
      if (user == null || !mounted) return;

      // 2. Get/create merchant profile via SECURITY DEFINER RPC
      //    (bypasses RLS — no Supabase session needed)
      await Supabase.instance.client.rpc('get_or_create_merchant', params: {
        'firebase_uid': user.uid,
        'p_phone': widget.phone,
      });

      // 3. Navigation is handled by GoRouter's redirect (merchantAuthStateProvider
      //    listens to FirebaseAuth.authStateChanges and re-checks the DB)
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: MerchantTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text('Verify Phone',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Enter the 6-digit code sent to +91 ${widget.phone}',
                style: const TextStyle(color: MerchantTheme.textSecondary)),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => SizedBox(
                  width: 48,
                  child: TextField(
                    controller: _ctrls[i],
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                    decoration: const InputDecoration(counterText: '', contentPadding: EdgeInsets.zero),
                    onChanged: (v) {
                      if (v.isNotEmpty && i < 5) FocusScope.of(context).nextFocus();
                      if (v.isEmpty && i > 0) FocusScope.of(context).previousFocus();
                      if (i == 5 && v.isNotEmpty) _verify();
                    },
                  ),
                )),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _loading ? null : _verify,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Verify OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
