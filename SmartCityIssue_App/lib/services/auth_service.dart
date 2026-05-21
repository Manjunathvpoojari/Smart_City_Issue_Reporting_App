import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

class AuthService {
  final _client = SupabaseService.client;

  /// Sign in with Google OAuth
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : 'io.supabase.smart_city://login-callback',
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Get or create user profile in public.users table
  Future<UserModel?> getOrCreateProfile() async {
    final user = SupabaseService.currentUser;
    if (user == null) return null;

    try {
      // Try fetching existing profile
      final res = await _client
          .from(AppConstants.usersTable)
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (res != null) {
        return UserModel.fromJson(res);
      }

      // Create new profile
      final newProfile = {
        'id': user.id,
        'name': user.userMetadata?['full_name'] ??
            user.email?.split('@').first ??
            'User',
        'email': user.email ?? '',
        'role': AppConstants.roleCitizen,
        'created_at': DateTime.now().toIso8601String(),
      };

      final created = await _client
          .from(AppConstants.usersTable)
          .insert(newProfile)
          .select()
          .single();

      return UserModel.fromJson(created);
    } catch (e) {
      debugPrint('Error getOrCreateProfile: $e');
      return null;
    }
  }

  /// Update FCM token for push notifications
  Future<void> updateFcmToken(String token) async {
    final userId = SupabaseService.userId;
    if (userId == null) return;

    await _client
        .from(AppConstants.usersTable)
        .update({'fcm_token': token}).eq('id', userId);
  }

  /// Auth state stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
