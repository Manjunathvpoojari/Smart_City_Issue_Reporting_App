import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Supabase auth state stream
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Current user profile from public.users
final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  // Watch auth state so profile refreshes on login/logout
  final authState = ref.watch(authStateProvider);

  // Only fetch if logged in
  final session = authState.valueOrNull?.session;
  if (session == null) return null;

  final authService = ref.read(authServiceProvider);
  final profile = await authService.getOrCreateProfile();

  // Register FCM token silently
  if (profile != null) {
    try {
      final token = await NotificationService.getToken();
      if (token != null) {
        await authService.updateFcmToken(token);
      }
    } catch (_) {}
  }

  return profile;
});

/// Convenience provider: is current user admin?
final isAdminProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  return profile?.isAdmin ?? false;
});
