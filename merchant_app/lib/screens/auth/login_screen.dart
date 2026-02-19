import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.store,
                  color: Color(0xFF6366F1),
                  size: 50,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'MomoPe Merchant',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Grow your business with rewards',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),

              // Google Sign-In Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await authService.signInWithGoogle();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Sign in failed: $e')),
                        );
                      }
                    }
                  },
                  icon: Image.asset(
                    'assets/google_logo.png',
                    height: 24,
                    width: 24,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.login, color: Colors.white),
                  ),
                  label: Text(
                    'Sign in with Google',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Terms
              Text(
                'By continuing, you agree to MomoPe\'s Terms of Service',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF9CA3AF),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
