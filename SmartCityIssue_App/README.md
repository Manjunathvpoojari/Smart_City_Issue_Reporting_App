# 🏙️ SmartCity — Issue Reporting & Civic Engagement App

A Flutter app for citizens to report civic issues (potholes, drainage, garbage, etc.) with GPS tagging, photo upload, real-time status tracking, and an admin dashboard.

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter 3.x (Dart) |
| State Management | Riverpod |
| Auth | Supabase Auth + Google OAuth |
| Database | Supabase PostgreSQL |
| Realtime | Supabase Realtime |
| Storage | Supabase Storage |
| Maps | OpenStreetMap + flutter_map (FREE) |
| GPS | geolocator package |
| Notifications | Firebase Cloud Messaging |

> ✅ **Zero paid services** — no Google Maps billing, no Firebase paid plan needed.

---

## ⚙️ Setup Instructions

### Step 1 — Create Supabase Project

1. Go to [https://supabase.com](https://supabase.com) → New Project
2. Note down your **Project URL** and **Anon Key** (Settings → API)
3. Open **SQL Editor** → paste the entire content of `supabase_setup.sql` → Run

### Step 2 — Enable Google Auth in Supabase

1. Supabase Dashboard → Authentication → Providers → Google → Enable
2. Add your Google OAuth Client ID and Secret
   - Get these from [Google Cloud Console](https://console.cloud.google.com) → APIs & Services → Credentials
   - Add redirect URI: `io.supabase.smartcity://login-callback`
3. Also add `https://YOUR_PROJECT_ID.supabase.co/auth/v1/callback` as an authorized redirect URI in Google Cloud

### Step 3 — Setup Firebase (for FCM)

1. Go to [https://console.firebase.google.com](https://console.firebase.google.com) → New Project
2. Add Android app → package name: `com.smartcity.app`
3. Download `google-services.json` → place in `android/app/`
4. No paid plan needed — FCM is free

### Step 4 — Configure the App

Open `lib/core/constants.dart` and replace:

```dart
static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### Step 5 — Install Dependencies

```bash
flutter pub get
```

### Step 6 — Run the App

```bash
flutter run
```

---

## 👑 Making a User Admin

After signing in with Google, run this SQL in Supabase SQL Editor:

```sql
update public.users set role = 'admin' where email = 'youremail@gmail.com';
```

Then sign out and sign back in. The Admin Dashboard will appear.

---

## 📁 Project Structure

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # MaterialApp setup
├── core/
│   ├── constants.dart           # App-wide constants
│   ├── theme.dart               # Colors, text styles, themes
│   └── router.dart              # GoRouter navigation
├── models/
│   ├── user_model.dart
│   ├── issue_model.dart
│   └── status_history_model.dart
├── services/
│   ├── supabase_service.dart    # Supabase client singleton
│   ├── auth_service.dart        # Google sign-in, profile
│   ├── issue_service.dart       # CRUD for issues
│   ├── storage_service.dart     # Image upload
│   ├── location_service.dart    # GPS
│   └── notification_service.dart# FCM push notifications
├── providers/
│   ├── auth_provider.dart       # Auth state, user profile
│   └── issue_provider.dart      # Issues, filters, streams
├── widgets/
│   └── app_widgets.dart         # Shared reusable widgets
└── screens/
    ├── splash/                  # Splash screen
    ├── auth/                    # Login screen
    ├── home/                    # Map screen
    ├── report/                  # Report issue screen
    ├── my_reports/              # My reports list
    ├── issue_detail/            # Issue detail (citizen)
    ├── profile/                 # User profile
    └── admin/
        ├── admin_dashboard_screen.dart
        └── admin_issue_detail_screen.dart
```

---

## 🗄️ Database Tables

| Table | Purpose |
|---|---|
| `users` | Stores citizen and admin profiles |
| `issues` | All reported civic issues |
| `status_history` | Audit trail of status changes |

---

## 📱 App Screens

| Screen | Description |
|---|---|
| Splash | Auto-login check |
| Login | Google Sign-In |
| Home (Map) | OpenStreetMap with issue pins |
| Report Issue | Photo + GPS + category + description |
| My Reports | User's submitted issues with status |
| Issue Detail | Full view with status history timeline |
| Profile | User stats + sign out |
| Admin Dashboard | All issues with filters + search |
| Admin Issue Detail | Status update + resolution notes |

---

## 🔔 Push Notifications

Notifications are sent via FCM when an admin updates an issue status.

To trigger server-side FCM from Supabase:
- Use Supabase Edge Functions (free tier)
- Or trigger from admin app directly using the FCM REST API with the citizen's `fcm_token` stored in the `users` table

---

## 📝 Notes

- The app uses **OpenStreetMap** (no API key, no billing)
- Supabase free tier: 500MB DB, 1GB Storage, 50K reads/day — sufficient for internship demo
- Firebase free tier (Spark): FCM is completely free
- Admin users must be set manually via SQL (no admin signup screen by design)

---

## 👥 Team Split

| Member | Module |
|---|---|
| Member 1 | Auth + Supabase setup + Issue submission |
| Member 2 | Map view + Issue listing |
| Member 3 | Admin dashboard + Status management |
| Member 4 | Notifications + Profile + UI polish |

---

## 🚀 Build APK

```bash
flutter build apk --release
```

APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

---

**VTU Internship Project — 2026**
