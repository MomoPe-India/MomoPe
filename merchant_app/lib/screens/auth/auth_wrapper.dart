import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/auth_provider.dart';
import '../home/merchant_home_screen.dart';
import '../registration/merchant_registration_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (state) {
        final session = state.session;

        if (session == null) {
          // Not authenticated
          return const LoginScreen();
        }

        // Authenticated - check if merchant registered
        return FutureBuilder<bool>(
          future: _checkMerchantRegistration(session.user.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final isRegistered = snapshot.data ?? false;

            if (isRegistered) {
              return const MerchantHomeScreen();
            } else {
              return const MerchantRegistrationScreen();
            }
          },
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Auth Error: $error'),
        ),
      ),
    );
  }

  Future<bool> _checkMerchantRegistration(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('merchants')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking merchant registration: $e');
      return false;
    }
  }
}
