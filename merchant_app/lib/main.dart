import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/auth_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Supabase Initialization (Using Publishable Key)
  await Supabase.initialize(
    url: 'https://wpnngcuoqtvgwhizkrwt.supabase.co',
    anonKey: 'sb_publishable_4l_Wba3ezOuRjYv-QoTzHA_TBq6sfV6',
  );

  runApp(const ProviderScope(child: MerchantApp()));
}

class MerchantApp extends StatelessWidget {
  const MerchantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MomoPe Merchant - Business Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}
