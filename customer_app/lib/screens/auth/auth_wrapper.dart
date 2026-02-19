import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../main/main_screen.dart';
import 'login_screen.dart';

/// Wrapper that handles navigation based on auth state
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (state) {
        // User is authenticated
        if (state.session != null) {
          return const MainScreen();
        }
        
        // User is not authenticated
        return const LoginScreen();
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2CB78A),
          ),
        ),
      ),
      error: (error, stack) {
        print('Auth state error: $error');
        return const LoginScreen(); // Show login on error
      },
    );
  }
}
