// lib/features/auth/screens/referral_code_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme.dart';
import '../../../shared/widgets/momope_button.dart';

class ReferralCodeScreen extends ConsumerStatefulWidget {
  const ReferralCodeScreen({super.key});
  @override
  ConsumerState<ReferralCodeScreen> createState() => _ReferralCodeScreenState();
}

class _ReferralCodeScreenState extends ConsumerState<ReferralCodeScreen> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _apply() async {
    final code = _ctrl.text.trim().toUpperCase();
    if (code.isEmpty) { _skip(); return; }
    setState(() { _loading = true; _error = null; });
    try {
      // Validate referral code exists
      final data = await Supabase.instance.client
          .from('users')
          .select('id')
          .eq('referral_code', code)
          .maybeSingle();
      if (data == null) {
        setState(() => _error = 'Referral code not found');
        return;
      }
      // Apply: update referred_by via RPC (idempotent)
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await Supabase.instance.client.rpc('create_user_profile', params: {
        'firebase_uid':       uid,
        'phone':              FirebaseAuth.instance.currentUser!.phoneNumber?.replaceFirst('+91', '') ?? '',
        'name':               '',        // already set; ON CONFLICT DO NOTHING
        'referral_code_used': code,
      });
      if (mounted) context.go('/pin-setup');
    } on PostgrestException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _skip() => context.go('/pin-setup');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text('Have a referral code?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Enter it to earn bonus coins when you make your first payment.',
                style: TextStyle(color: context.theme.textSecondary)),
              const SizedBox(height: 40),
              TextField(
                controller: _ctrl,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Referral code (optional)',
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 32),
              MomoPeButton(label: 'Apply & Continue', onPressed: _apply, isLoading: _loading),
              const SizedBox(height: 12),
              Center(child: TextButton(onPressed: _skip, child: const Text('Skip for now'))),
            ],
          ),
        ),
      ),
    );
  }
}
