import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter/services.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.secondaryNavy,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.secondaryNavy,
                AppColors.secondaryNavyDark,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative shapes
              Positioned(
                top: -100,
                right: -100,
                child: CircleAvatar(
                  radius: 200,
                  backgroundColor: AppColors.primaryTeal.withOpacity(0.05),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -50,
                child: CircleAvatar(
                  radius: 150,
                  backgroundColor: AppColors.rewardsGold.withOpacity(0.03),
                ),
              ),
              
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo/Icon with Glow
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withOpacity(0.1),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryTeal.withOpacity(0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.store_rounded,
                          color: AppColors.primaryTeal,
                          size: 60,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Title
                      Text(
                        'MomoPe',
                        style: AppTypography.displayMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                        ),
                      ),
                      Text(
                        'MERCHANT',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4.0,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Subtitle
                      Text(
                        'Join India\'s most rewarding payment\nnetwork for businesses.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.7),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 80),

                      // Google Sign-In Button (Custom Premium)
                      PremiumButton(
                        text: 'Sign in with Google',
                        onPressed: () async {
                          try {
                            await authService.signInWithGoogle();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Sign in failed: $e'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppColors.errorRed,
                                ),
                              );
                            }
                          }
                        },
                        style: PremiumButtonStyle.primary,
                      ),
                      
                      const SizedBox(height: 32),

                      // Terms
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'By continuing, you agree to MomoPe\'s Terms of Service and Privacy Policy.',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white.withOpacity(0.4),
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
