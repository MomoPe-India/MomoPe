import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../auth/auth_wrapper.dart';

/// Premium splash screen with MomoPe branding
/// Features: Animated logo, brand tagline, smooth transitions
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<Offset> _taglineSlideAnimation;
  late Animation<double> _taglineFadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Set status bar to transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _setupAnimations();
    _navigateToHome();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo scale animation (0.8 -> 1.0)
    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // Logo fade animation
    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Tagline slide animation (from bottom)
    _taglineSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Tagline fade animation
    _taglineFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthWrapper(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryTeal,
              AppColors.primaryTealDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                
                // Animated Logo
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _logoFadeAnimation,
                      child: ScaleTransition(
                        scale: _logoScaleAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: _buildLogo(),
                ),
                
                const SizedBox(height: 32),
                
                // Brand Name
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _logoFadeAnimation,
                      child: child,
                    );
                  },
                  child: Text(
                    'MomoPe',
                    style: AppTypography.displayLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Animated Tagline
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _taglineSlideAnimation,
                      child: FadeTransition(
                        opacity: _taglineFadeAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    'Pay Smart, Earn More',
                    style: AppTypography.titleLarge.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                
                const Spacer(flex: 1),
                
                // Loading Indicator
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _taglineFadeAnimation,
                      child: child,
                    );
                  },
                  child: _buildLoadingDots(),
                ),
                
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Image.asset(
          'assets/images/branding/momope_logo.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            final delay = index * 0.2;
            final animationValue = (value - delay).clamp(0.0, 1.0);
            final scale = 1.0 + (animationValue * 0.5);
            
            return Transform.scale(
              scale: scale,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
          onEnd: () {
            if (mounted) {
              setState(() {});
            }
          },
        );
      }),
    );
  }
}
