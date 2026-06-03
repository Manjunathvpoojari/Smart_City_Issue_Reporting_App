# 🏙️ SmartCity — Issue Reporting & Civic Engagement App
### VTU Internship Project · Flutter + Supabase · 2026

> *A real-world Flutter mobile application enabling citizens to report civic issues, track resolutions in real-time, and help authorities manage urban problems efficiently — built entirely on free infrastructure.*

---

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Problem Statement](#-problem-statement)
- [Tech Stack](#️-tech-stack)
- [Architecture](#️-architecture)
- [Features](#-features)
- [Database Design](#️-database-design)
- [Project Structure](#-project-structure)
- [Setup Guide](#-setup-guide)
- [Screens](#-screens)
- [API & Services](#-api--services)
- [Known Issues & Fixes](#-known-issues--fixes)
- [Roadmap](#️-roadmap)
- [Team](#-team)

---

## 🎯 Project Overview

**SmartCity** is a Flutter-based mobile application that bridges the gap between citizens and municipal authorities in Shimoga, Karnataka. Citizens can report civic issues like potholes, drainage failures, garbage overflow, and broken streetlights — directly from their smartphone with photo evidence and GPS location. Authorities manage and resolve these issues through a dedicated admin dashboard with real-time updates, analytics charts, and an interactive issue map.

| Attribute | Details |
|---|---|
| **Platform** | Android (Flutter) |
| **Backend** | Supabase (PostgreSQL + Realtime + Storage + Auth) |
| **Maps** | OpenStreetMap via `flutter_map` — 100% Free |
| **Notifications** | Firebase Cloud Messaging (FCM) — Free Tier |
| **Infrastructure Cost** | ₹0 — Zero paid services |
| **Target City** | Shimoga (Shivamogga), Karnataka |
| **Target Users** | Citizens + Municipal Authorities |
| **App Version** | 1.0.0 |

---

## 🚨 Problem Statement

Urban infrastructure in Indian cities faces constant challenges — potholes, broken streetlights, drainage failures, overflowing garbage bins. Despite being widespread, citizens currently have no efficient, unified channel to report them.

**Existing problems:**
- No structured way for citizens to report civic issues
- Zero accountability after a complaint is raised
- Authorities have no organized dashboard to manage issues
- Citizens never know if their complaint was acted upon
- No data-driven approach for municipalities to prioritize repairs

**Our solution:** A mobile-first civic engagement platform with photo + GPS reporting, real-time status tracking, push notifications, admin analytics, and multi-language support.

---

## ⚙️ Tech Stack

| Layer | Technology | Why |
|---|---|---|
| **Frontend** | Flutter 3.x (Dart) | Cross-platform, single codebase |
| **State Management** | Riverpod 2.x | Scalable, clean state architecture |
| **Navigation** | GoRouter 13.x | Declarative routing with auth guards |
| **Authentication** | Supabase Auth + Google OAuth | Free, secure, one-tap login |
| **Database** | Supabase PostgreSQL | Relational DB, free 500MB |
| **Realtime** | Supabase Realtime | Live status updates without polling |
| **File Storage** | Supabase Storage | Issue photos, 1GB free |
| **Maps** | OpenStreetMap + flutter_map | 100% free, no API key needed |
| **GPS** | geolocator + geocoding | Auto-tag + reverse geocode location |
| **Notifications** | Firebase Cloud Messaging | Free push notifications |
| **Image Handling** | image_picker + flutter_image_compress | Camera/gallery + auto compress |
| **Charts** | fl_chart | Pie, line charts for admin analytics |
| **Animation** | lottie | Splash screen animation |
| **Localization** | flutter_localizations + intl | English, Kannada, Hindi support |
| **Secrets** | flutter_dotenv | Secure API key management via .env |

> ✅ **Zero cost guarantee** — No Google Maps billing, no Firebase paid plan, no Supabase upgrade needed.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App (Dart)                    │
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │  Screens │  │Providers │  │ Services │             │
│  │  (UI)    │◄─│(Riverpod)│◄─│(Business)│             │
│  └──────────┘  └──────────┘  └──────────┘             │
│                                    │                    │
└────────────────────────────────────┼────────────────────┘
                                     │
              ┌──────────────────────┼──────────────────┐
              │                      │                  │
     ┌────────▼────────┐  ┌─────────▼──────┐  ┌───────▼──────┐
     │    Supabase     │  │    Firebase    │  │ OpenStreetMap│
     │  PostgreSQL     │  │     FCM        │  │   (Maps)     │
     │  Realtime       │  │ Notifications  │  │  Free Tiles  │
     │  Storage        │  └────────────────┘  └──────────────┘
     │  Auth           │
     └─────────────────┘
```

### State Management Flow

```
User Action → Screen → Riverpod Provider → Service → Supabase
                ▲                                        │
                └────────── State Update ◄───────────────┘
```

---

## ✨ Features

### 👤 Citizen Features

| Feature | Description | Status |
|---|---|---|
| Google Sign-In | One-tap OAuth login via Supabase | 🔸 Working |
| Email/Password Login | Manual registration and login | ✅ Built |
| Report Issue | Photo + description + category + auto GPS | ✅ Built |
| Issue Categories | Pothole, Drainage, Garbage, Street Light, Encroachment, Water Leakage, Other | ✅ Built |
| My Reports | List of all submitted issues with live status + stat chips | ✅ Built |
| Status Tracking | Realtime: Pending → In Progress → Resolved | ✅ Built |
| Issue Detail | Full view with photo, map, admin note, status history timeline | ✅ Built |
| Public Map View | All city issues on OpenStreetMap with colored emoji pins | ✅ Built |
| Map/List Toggle | Switch between map view and list view on home screen | ✅ Built |
| Push Notifications | FCM alert when issue status is updated | ✅ Built |
| Notifications Screen | In-app notification feed with color-coded cards | ✅ Built |
| Category Filter | Filter map pins by issue category | ✅ Built |
| Multi-language | Profile section: English, Kannada, Hindi | 🔸 Partial |
| Upvote Issues | Citizen upvoting for priority | 🔄 Future |

### ⚙️ Admin Features

| Feature | Description | Status |
|---|---|---|
| Admin Login | Role-based access via Supabase RLS | ✅ Built |
| Dashboard Tab | Stats cards + category bars + quick action buttons | ✅ Built |
| Issues Tab | All issues with status filter + text search | ✅ Built |
| Issue Map Tab | OpenStreetMap with all pins + tap pin → manage sheet | ✅ Built |
| Analytics Tab | Resolution rate + pie chart + weekly trend line | ✅ Built |
| Status Update | Pending → In Progress → Resolved | ✅ Built |
| Resolution Notes | Admin remarks visible to citizen | ✅ Built |
| Status History | Full audit trail of all status changes | ✅ Built |
| Avg Resolution Time | Calculated from resolved issue timestamps | ✅ Built |
| Category Performance | Per-category resolution rate bars | ✅ Built |
| Assign to Officer | Field officer assignment | 🔄 Future |

### 🔧 System Features

| Feature | Description | Status |
|---|---|---|
| Row Level Security | RLS policies — citizens see own data only | ✅ Built |
| Realtime Sync | Supabase Realtime subscriptions | ✅ Built |
| Image Compression | Auto-compress 70% quality before upload | ✅ Built |
| Offline Handling | Graceful error messages + retry buttons | ✅ Built |
| GPS Auto-detect | Auto-fills location + reverse geocode address | ✅ Built |
| Auth Guards | GoRouter redirect for unauthenticated users | ✅ Built |
| Auto Profile Create | DB trigger creates profile on first login | ✅ Built |
| Lottie Splash | Animated splash screen with logo | ✅ Built |
| Notification Badge | Red dot on Alerts tab for unread items | ✅ Built |
| Secure .env Config | Supabase keys loaded from .env via flutter_dotenv | ✅ Built |

---

## 🗄️ Database Design

### Tables

#### `users`
```sql
id          UUID        Primary key (from Supabase Auth)
name        TEXT        Full name
email       TEXT        Email address
role        TEXT        citizen | admin
fcm_token   TEXT        For push notifications
created_at  TIMESTAMP   Auto-set on creation
```

#### `issues`
```sql
id           UUID        Primary key
user_id      UUID        FK → users.id
title        TEXT        Short issue title (max 80 chars)
description  TEXT        Detailed description (max 300 chars)
category     TEXT        Pothole | Drainage | Garbage | Street Light | Encroachment | Water Leakage | Other
image_url    TEXT        Supabase Storage public URL
latitude     FLOAT8      GPS coordinate
longitude    FLOAT8      GPS coordinate
status       TEXT        Pending | In Progress | Resolved
admin_note   TEXT        Resolution remark by admin
upvotes      INT         Default 0
created_at   TIMESTAMP   Submission time
updated_at   TIMESTAMP   Last status change (auto-updated by trigger)
```

#### `status_history`
```sql
id          UUID        Primary key
issue_id    UUID        FK → issues.id
old_status  TEXT        Previous status value
new_status  TEXT        Updated status value
changed_by  UUID        FK → users.id (admin who changed it)
changed_at  TIMESTAMP   Timestamp of change
```

### Relationships

```
users ──────< issues         (one user, many issues)
issues ─────< status_history (one issue, many status changes)
users ──────< status_history (one admin, many changes)
```

### RLS Policies Summary

| Table | Citizens | Admins |
|---|---|---|
| `users` | Read/update own profile | Read all |
| `issues` | Insert own, read all | Read all, update all |
| `status_history` | Read all | Read all, insert |
| `storage/issue-images` | Upload, read all | Upload, read all |

---

## 📁 Project Structure

```
SmartCityIssue_App/
├── .env                                  # Supabase credentials (gitignored)
├── l10n.yaml                             # Localization config
├── supabase_setup.sql                    # Run once in Supabase SQL Editor
├── pubspec.yaml
│
└── lib/
    ├── main.dart                         # Entry point — Firebase, Supabase, dotenv init
    ├── app.dart                          # MaterialApp.router + locale + theme
    │
    ├── core/
    │   ├── constants.dart               # Supabase config, categories, GPS defaults (Shimoga)
    │   ├── theme.dart                   # Green color palette, Material 3 theme
    │   ├── router.dart                  # GoRouter + auth redirect + 4-tab MainShell
    │   └── l10n_extension.dart          # BuildContext.l10n shortcut extension
    │
    ├── l10n/                            # Localization ARB files
    │   ├── app_en.arb                   # English strings
    │   ├── app_kn.arb                   # Kannada strings
    │   └── app_hi.arb                   # Hindi strings
    │
    ├── generated/                       # Auto-generated by flutter gen-l10n
    │   └── app_localizations.dart       # DO NOT edit manually
    │
    ├── models/
    │   ├── user_model.dart              # UserModel with isAdmin getter
    │   ├── issue_model.dart             # IssueModel with all fields + copyWith
    │   └── status_history_model.dart    # StatusHistoryModel
    │
    ├── services/
    │   ├── supabase_service.dart        # Supabase client singleton
    │   ├── auth_service.dart            # Google OAuth, email login, profile, FCM token
    │   ├── issue_service.dart           # Full CRUD — citizen + admin operations
    │   ├── storage_service.dart         # Compress + uploadBinary to Supabase Storage
    │   ├── location_service.dart        # GPS permission + coordinates + reverse geocode
    │   └── notification_service.dart   # FCM init + local notifications foreground
    │
    ├── providers/
    │   ├── auth_provider.dart           # Auth stream, userProfile, isAdmin
    │   ├── issue_provider.dart          # Realtime streams, filter state, admin providers
    │   └── language_provider.dart       # AppLanguage enum, LanguageNotifier, Locale mapping
    │
    ├── widgets/
    │   └── app_widgets.dart            # IssueCard, StatusBadge, CategoryChip,
    │                                    # LoadingWidget, EmptyState, ErrorRetryWidget,
    │                                    # GradientButton
    │
    └── screens/
        ├── splash/
        │   └── splash_screen.dart       # Lottie animation + logo + auto auth check
        ├── auth/
        │   └── login_screen.dart        # Email/Password + Google Sign-In + toggle signup
        ├── home/
        │   └── home_screen.dart         # Greeting + stats + map/list toggle + OpenStreetMap
        ├── report/
        │   └── report_issue_screen.dart # Photo picker + GPS + category + submit
        ├── my_reports/
        │   └── my_reports_screen.dart   # Status summary chips + realtime issue list
        ├── issue_detail/
        │   └── issue_detail_screen.dart # Hero image + map + admin note + status timeline
        ├── notifications/
        │   └── notifications_screen.dart # Color-coded notification cards from issue events
        ├── profile/
        │   └── profile_screen.dart      # Stats + language picker + admin access + sign out
        └── admin/
            ├── admin_dashboard_screen.dart    # 4-tab: Dashboard | Issues | Issue Map | Analytics
            └── admin_issue_detail_screen.dart # Status radio + resolution note + save
```

---

## 🚀 Setup Guide

### Prerequisites
- Flutter 3.x SDK
- Android Studio / VS Code
- Supabase account (free)
- Firebase account (free)
- Google Cloud Console account (free)

### Step 1 — Clone & Install

```bash
git clone https://github.com/Manjunathvpoojari/Smart_City_Issue_Reporting_App.git
cd SmartCityIssue_App
flutter pub get
```

### Step 2 — Create `.env` File

Create a `.env` file in the project root:

```env
SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

Get these from: **Supabase → Settings → API → Project URL + anon public key**

> ⚠️ Never commit `.env` to GitHub. It is already in `.gitignore`.

### Step 3 — Supabase Setup

1. Create project at [supabase.com](https://supabase.com)
2. Go to **SQL Editor** → paste and run `supabase_setup.sql`
3. Go to **Storage** → confirm `issue-images` bucket exists and is **Public**

### Step 4 — Google OAuth

1. [Google Cloud Console](https://console.cloud.google.com) → APIs & Services → Credentials → Create **Web OAuth Client**
2. Add **Authorized redirect URI**:
   ```
   https://YOUR_PROJECT_ID.supabase.co/auth/v1/callback
   ```
3. Add **Authorized JavaScript origin**:
   ```
   https://YOUR_PROJECT_ID.supabase.co
   ```
4. Supabase → Authentication → Providers → **Google** → Enable → paste Client ID + Secret
5. Supabase → Authentication → URL Configuration:
   ```
   Site URL:      io.supabase.smart_city://login-callback
   Redirect URLs: io.supabase.smart_city://login-callback
   ```

### Step 5 — Firebase Setup

1. [Firebase Console](https://console.firebase.google.com) → New Project
2. Add Android app → package name: `com.example.smart_city`
3. Download `google-services.json` → place in `android/app/`

### Step 6 — Generate Localization Files

```bash
flutter gen-l10n
```

This generates `lib/generated/app_localizations.dart` from the ARB files. Run this once and again whenever you add new translation keys.

### Step 7 — Make Admin

After signing in for the first time, run in Supabase SQL Editor:

```sql
update public.users set role = 'admin' where email = 'your@email.com';
```

Sign out and sign back in — the Admin Dashboard will appear.

### Step 8 — Run

```bash
flutter run                          # Debug on device/emulator
flutter build apk --release          # Release APK
```

---

## 📱 Screens

| Screen | Route | Description |
|---|---|---|
| Splash | `/splash` | Lottie animation + logo + auto auth check |
| Login | `/login` | Email/Password + Google Sign-In + sign up toggle |
| Home (Map) | `/home` | Greeting + stats + OpenStreetMap with live pins |
| Report Issue | `/report` | Photo + GPS + category + description + submit |
| My Reports | `/my-reports` | Status summary chips + realtime issue list |
| Issue Detail | `/issue/:id` | Full view + mini-map + admin note + status timeline |
| Notifications | `/notifications` | Color-coded notification feed from issue events |
| Profile | `/profile` | Stats + language selector + admin access + sign out |
| Admin Dashboard | `/admin` | 4 tabs: Dashboard, Issues, Issue Map, Analytics |
| Admin Issue Detail | `/admin/issue/:id` | Status radio buttons + resolution note + save |

---

## 🔌 API & Services

### Supabase Realtime Streams

```dart
// Stream citizen's own issues (live updates)
IssueService().streamMyIssues()

// Stream all city issues for map
IssueService().streamAllIssues()
```

### Image Upload Flow

```
User picks image (camera/gallery)
        ↓
flutter_image_compress → 70% quality, max 800×600px
        ↓
uploadBinary() → Supabase Storage → issue-images/issues/{uuid}.jpg
        ↓
getPublicUrl() → stored as issues.image_url
```

### Push Notification Flow

```
Admin updates issue status in AdminIssueDetailScreen
        ↓
IssueService.updateIssueStatus() → updates issues table + inserts status_history
        ↓
FCM token from users.fcm_token
        ↓
Push notification → Citizen's Android device
```

### Language Switch Flow

```
User picks Kannada in Profile
        ↓
languageProvider → AppLanguage.kannada → Locale('kn')
        ↓
app.dart sets locale → Flutter loads app_kn.arb
        ↓
All l10n keys switch to Kannada instantly
```

---

## 🐛 Known Issues & Fixes Applied

| Issue | Cause | Fix Applied |
|---|---|---|
| Sign out crash | Wrong Navigator context in dialog | Used `dialogContext` instead of screen `context` |
| Submit report failing | `upvotes` column missing in DB | `alter table add column if not exists upvotes` + removed from insert |
| `FileOptions` undefined | Package version mismatch | Replaced with `uploadBinary` without `FileOptions` |
| `CardTheme` type error | Flutter version difference | Changed to `CardThemeData` |
| `flutter_local_notifications` missing | Not in pubspec | Added to dependencies |
| Core library desugaring error | Missing Gradle config | Added `isCoreLibraryDesugaringEnabled = true` |
| Network security config missing | Referenced but not created | Created `res/xml/network_security_config.xml` |
| FCM fails on emulator | No Google Play Services | Silent fail with `try/catch` |
| Profile shows null after navigation | Provider rebuilding without auth check | Fixed `userProfileProvider` to watch auth state |
| Google Sign-In 400 error | Site URL not set in Supabase | Changed Site URL from `localhost:3000` to redirect URI |

---

## 🗺️ Roadmap

### Version 1.0 — Current ✅
- Email + Google Sign-In
- Report Issue with photo + GPS + categories
- OpenStreetMap with colored emoji pins by status
- Real-time status tracking via Supabase Realtime
- My Reports screen with stat chips
- Notifications screen with color-coded cards
- Profile with language selector (English, Kannada, Hindi)
- Admin 4-tab dashboard (Dashboard, Issues, Map, Analytics)
- Charts: resolution rate, pie chart, weekly trend line
- Admin Issue Map with tap-to-manage
- Lottie splash animation
- Secure .env config with flutter_dotenv
- ARB localization files ready for all 3 languages

### Version 1.1 — Next 🔄
- Full app-wide language switch (wire ARB to all screens)
- Working FCM push notifications (server-side trigger)
- Profile badges (Bronze/Silver/Gold based on reports)
- Upvote issues for citizen priority scoring

### Version 2.0 — Future 💭
- AI-based issue categorization from photo
- Web admin portal
- Field officer assignment
- Offline mode with local queue and sync
- Government portal integration
- Issue heatmap analytics

---

## 👥 Team

| Member | Role | Modules |
|---|---|---|
| Member 1 | Lead Developer | Supabase setup + Issue submission + GPS | Frontend & Backend Developer |
| Member 2 | Report making | UI polish| 

---

## 📄 License

This project was built as part of the **VTU Internship Program 2026** and is intended for educational and civic demonstration purposes.

---

*Built with ❤️ using Flutter + Supabase — Zero cost, Real impact.*

> **GitHub:** [github.com/Manjunathvpoojari/Smart_City_Issue_Reporting_App](https://github.com/Manjunathvpoojari/Smart_City_Issue_Reporting_App)
> **Portfolio:** [manjunathvpoojari.github.io](https://manjunathvpoojari.github.io)