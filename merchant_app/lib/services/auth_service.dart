import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Sign in with Google (Web + Android)
  Future<void> signInWithGoogle() async {
    try {
      print('🔐 Starting Google Sign-In...');

      if (kIsWeb) {
        // 🌐 Web: Use Supabase OAuth redirect
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'http://localhost:3000',
        );
      } else {
        // 🤖 Android: Use native Google Sign-In

        // IMPORTANT:
        // This MUST be your Web application OAuth Client ID
        const webClientId =
            '361764771429-cfjnr5lvnah3gm92cr8vnp2k2a2pdtij.apps.googleusercontent.com';

        final GoogleSignIn googleSignIn = GoogleSignIn(
          serverClientId: webClientId,
        );

        final GoogleSignInAccount? googleUser =
            await googleSignIn.signIn();

        if (googleUser == null) {
          print('❌ Google Sign-In cancelled');
          return;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final accessToken = googleAuth.accessToken;
        final idToken = googleAuth.idToken;

        if (accessToken == null || idToken == null) {
          throw Exception('No Access Token or ID Token found.');
        }

        // 🔐 Send tokens to Supabase
        await _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
      }

      final user = _supabase.auth.currentUser;

      if (user != null) {
        print('✅ Signed in: ${user.email}');
        await _ensurePublicUserProfile(user);
      }
    } catch (e) {
      print('❌ Sign in error: $e');
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

  /// Ensure public profile exists in users table
  Future<void> _ensurePublicUserProfile(User user) async {
    try {
      final String displayName =
          user.userMetadata?['full_name'] ??
          user.userMetadata?['name'] ??
          user.email?.split('@')[0] ??
          'Merchant';

      await _supabase.from('users').upsert(
        {
          'id': user.id,
          'email': user.email,
          'name': displayName,
          'role': 'merchant',
        },
        onConflict: 'id',
      );

      print('✅ Merchant profile verified');
    } catch (e) {
      print('⚠️ Profile setup error: $e');
    }
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;
}
