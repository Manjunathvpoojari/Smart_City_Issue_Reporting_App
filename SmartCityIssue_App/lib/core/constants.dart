class AppConstants {
  // ──────────────────────────────────────────────
  // TODO: Replace with your actual Supabase project values
  // Get these from: https://supabase.com → your project → Settings → API
  // ──────────────────────────────────────────────
  static const String supabaseUrl = 'https://zkvsezohhoelfdkgoqzr.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InprdnNlem9oaG9lbGZka2dvcXpyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgwMzUxNTMsImV4cCI6MjA5MzYxMTE1M30.HL0pbqjL4TlIKsj1GuYREuDB-hG3NnRO1mHpsXDMb2s';

  // Supabase table names
  static const String usersTable = 'users';
  static const String issuesTable = 'issues';
  static const String statusHistoryTable = 'status_history';

  // Supabase storage bucket
  static const String issueImagesBucket = 'issue-images';

  // Issue categories
  static const List<String> categories = [
    'Pothole',
    'Drainage',
    'Garbage',
    'Street Light',
    'Encroachment',
    'Water Leakage',
    'Other',
  ];

  // Category icons (emoji)
  static const Map<String, String> categoryIcons = {
    'Pothole': '🕳️',
    'Drainage': '🌊',
    'Garbage': '🗑️',
    'Street Light': '💡',
    'Encroachment': '⚠️',
    'Water Leakage': '💧',
    'Other': '📌',
  };

  // Issue statuses
  static const String statusPending = 'Pending';
  static const String statusInProgress = 'In Progress';
  static const String statusResolved = 'Resolved';

  // User roles
  static const String roleAdmin = 'admin';
  static const String roleCitizen = 'citizen';

  // App info
  static const String appName = 'SmartCity';
  static const String appVersion = '1.0.0';

  // Map defaults (Shivamogga, Karnataka)
  static const double defaultLat = 13.9299;
  static const double defaultLng = 75.5681;
  static const double defaultZoom = 13.0;
}
