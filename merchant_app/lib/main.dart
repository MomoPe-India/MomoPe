import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/supabase_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'screens/merchant_dashboard_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (required before messaging)
  await Firebase.initializeApp();

  // Register background message handler BEFORE runApp
  NotificationService.registerBackgroundHandler();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConstants.url,
    anonKey: SupabaseConstants.anonKey,
  );

  runApp(
    const ProviderScope(
      child: MerchantApp(),
    ),
  );
}

class MerchantApp extends StatelessWidget {
  const MerchantApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: Check for existing session — skip login screen for returning users.
    // Supabase persists the session in secure storage; if a valid session exists,
    // route directly to the dashboard instead of forcing re-login every launch.
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null && !session.isExpired;

    return MaterialApp(
      title: 'MomoPe Merchant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: isLoggedIn ? const MerchantDashboardScreen() : const LoginScreen(),
    );
  }
}

