import 'package:supabase_flutter/supabase_flutter.dart';

/// Central access point for Supabase client
class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;
  static Session? get session => auth.currentSession;
  static User? get currentUser => auth.currentUser;
  static bool get isLoggedIn => session != null;
  static String? get userId => currentUser?.id;
}
