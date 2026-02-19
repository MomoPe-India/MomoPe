import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Authentication service using Supabase Auth with Google Sign-In
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ✅ Your Real Google Web Client ID
  static const String _googleClientId =
      '361764771429-cfjnr5lvnah3gm92cr8vnp2k2a2pdtij.apps.googleusercontent.com';

  /// Get current authenticated user
  User? get currentUser => _supabase.auth.currentUser;

  bool get isAuthenticated => currentUser != null;

  String? get userEmail => currentUser?.email;

  /// Sign in with Google (Web + Android)
  Future<void> signInWithGoogle() async {
    try {
      print('🔐 Starting Google Sign-In...');

      // ==========================
      // 🌐 WEB LOGIN
      // ==========================
      if (kIsWeb) {
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: '${Uri.base.origin}/auth/callback',
        );
        return;
      }

      // ==========================
      // 📱 ANDROID LOGIN
      // ==========================
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: _googleClientId,
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser =
          await googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Sign in cancelled by user');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null || accessToken == null) {
        throw Exception('Failed to get Google authentication tokens');
      }

      final AuthResponse response =
          await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      print('✅ Signed in: ${response.user?.email}');

      if (response.user != null) {
        await _ensurePublicUserProfile(response.user!);
      }
    } catch (e) {
      print('❌ Google sign-in error: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
      }

      await _supabase.auth.signOut();
      print('👋 Signed out');
    } catch (e) {
      print('❌ Sign out error: $e');
      rethrow;
    }
  }

  /// Ensure public profile + coin balance exists
  Future<void> _ensurePublicUserProfile(User user) async {
    try {
      final String displayName =
          user.userMetadata?['full_name'] ??
              user.userMetadata?['name'] ??
              user.email?.split('@')[0] ??
              'User';

      await _supabase.from('users').upsert({
        'id': user.id,
        'email': user.email,
        'name': displayName,
        'role': 'customer',
      }, onConflict: 'id');

      final balance = await _supabase
          .from('momo_coin_balances')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (balance == null) {
        await _supabase.from('momo_coin_balances').insert({
          'user_id': user.id,
          'total_coins': 0,
          'available_coins': 0,
          'locked_coins': 0,
        });
      }

      print('✅ User profile & balance verified');
    } catch (e) {
      print('⚠️ Profile setup error: $e');
    }
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;
}
