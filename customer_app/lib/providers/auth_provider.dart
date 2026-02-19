import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Auth state stream provider (from Supabase)
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (state) => state.session?.user,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// User email provider
final userEmailProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.email;
});

/// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});
