import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (required before messaging)
  await Firebase.initializeApp();

  // Register background message handler BEFORE runApp
  NotificationService.registerBackgroundHandler();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://wpnngcuoqtvgwhizkrwt.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indwbm5nY3VvcXR2Z3doaXprcnd0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzExNDE1NzIsImV4cCI6MjA4NjcxNzU3Mn0.hRYLsnxbawUhr9gDGPDRVszG6pn1oyOlVsZnrPJaQzA',
  );

  runApp(
    const ProviderScope(
      child: MomoPeApp(),
    ),
  );
}

class MomoPeApp extends StatelessWidget {
  const MomoPeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MomoPe - Pay Smart, Earn More',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
