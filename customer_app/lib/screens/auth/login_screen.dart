import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';

/// Simple login screen with only Google Sign-In for MVP
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithGoogle();
      
      // Navigation handled by AuthWrapper watching auth state
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully signed in!'),
            backgroundColor: Color(0xFF2CB78A),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Text(
                  'MomoPe',
                  style: GoogleFonts.inter(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2CB78A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Tagline
                Text(
                  'Your Digital Wallet for Mom & Pop Shops',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 80),
                
                // Google Sign-In button
                ElevatedButton(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Google icon (using emoji for MVP, replace with asset later)
                            const Text('🔐', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Text(
                              'Continue with Google',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                ),
                
                const SizedBox(height: 40),
                
                // Terms text
                Text(
                  'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
