import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/auth_provider.dart';
import '../main/main_screen.dart';
import '../onboarding/referral_entry_screen.dart';
import 'login_screen.dart';

// ─────────────────────────────────────────────────────────────
// Provider: check if the current user is brand-new
//
// A user is "new" if their Supabase account was created within
// the last 60 seconds (i.e., they just signed up).
// We show the ReferralEntryScreen only to new users who don't
// yet have a `referred_by` value set.
// ─────────────────────────────────────────────────────────────
final _isNewUserProvider = FutureProvider.autoDispose<bool>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return false;

  // If account created more than 60 s ago → returning user → skip
  final createdDatetime = DateTime.tryParse(user.createdAt);
  if (createdDatetime == null) return false;

  final age = DateTime.now().toUtc().difference(createdDatetime.toUtc());
  if (age.inSeconds > 60) return false;

  // New user — check if they already have referred_by set
  try {
    final row = await Supabase.instance.client
        .from('users')
        .select('referred_by')
        .eq('id', user.id)
        .maybeSingle();

    if (row == null) return true; // user row not yet created — show screen
    return row['referred_by'] == null;
  } catch (_) {
    return false; // On error, skip onboarding to avoid blocking login
  }
});

/// Wrapper that handles navigation based on auth state.
///
/// Flow:
///   Not signed in → [LoginScreen]
///   Signed in + brand-new → [ReferralEntryScreen]
///   Signed in + returning → [MainScreen]
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (state) {
        // User is NOT authenticated
        if (state.session == null) {
          return const LoginScreen();
        }

        // User IS authenticated — check if new user for onboarding
        final isNewUserAsync = ref.watch(_isNewUserProvider);

        return isNewUserAsync.when(
          data: (isNew) {
            if (isNew) return const ReferralEntryScreen();
            return const MainScreen();
          },
          loading: () => const _SplashLoader(),
          error: (_, __) {
            // On provider error, skip onboarding gracefully
            debugPrint('AuthWrapper: _isNewUserProvider error — skipping onboarding');
            return const MainScreen();
          },
        );
      },
      loading: () => const _SplashLoader(),
      error: (error, stack) {
        debugPrint('Auth state error: $error');
        return const LoginScreen();
      },
    );
  }
}

// ─── Simple full-screen loader used while auth resolves ────────────────────
class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0B0F19),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF00C4A7),
        ),
      ),
    );
  }
}
