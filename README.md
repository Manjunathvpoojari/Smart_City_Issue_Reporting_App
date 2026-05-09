# 🏙️ SmartCity — Issue Reporting & Civic Engagement App
### VTU Internship Project · Flutter + Supabase · 2026

> *A real-world Flutter mobile application enabling citizens to report civic issues, track resolutions in real-time, and help authorities manage urban problems efficiently — built entirely on free infrastructure.*

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Problem Statement](#problem-statement)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Features](#features)
- [Database Design](#database-design)
- [Project Structure](#project-structure)
- [Setup Guide](#setup-guide)
- [Screenshots & Screens](#screens)
- [API & Services](#api--services)
- [Known Issues & Fixes](#known-issues--fixes)
- [Roadmap](#roadmap)
- [Team](#team)

---

## 🎯 Project Overview

**SmartCity** is a Flutter-based mobile application that bridges the gap between citizens and municipal authorities. Citizens can report civic issues like potholes, drainage failures, garbage overflow, and broken streetlights — directly from their smartphone with photo evidence and GPS location. Authorities manage and resolve these issues through a dedicated admin dashboard with real-time updates.

| Attribute | Details |
|---|---|
| **Platform** | Android (Flutter) |
| **Backend** | Supabase (PostgreSQL + Realtime + Storage + Auth) |
| **Maps** | OpenStreetMap via `flutter_map` — 100% Free |
| **Notifications** | Firebase Cloud Messaging (FCM) — Free Tier |
| **Infrastructure Cost** | ₹0 — Zero paid services |
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

**Our solution:** A mobile-first civic engagement platform with photo + GPS reporting, real-time status tracking, push notifications, and an admin management system.

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
| **GPS** | geolocator package | Auto-tag issue location |
| **Notifications** | Firebase Cloud Messaging | Free push notifications |
| **Image Handling** | image_picker + flutter_image_compress | Camera/gallery + compression |

> ✅ **Zero cost guarantee** — No Google Maps billing, no Firebase paid plan, no Supabase upgrade needed for development and demo.

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
| Google Sign-In | One-tap OAuth login via Supabase | ✅ Built |
| Email/Password Login | Manual registration and login | ✅ Built |
| Report Issue | Photo + description + category + auto GPS | ✅ Built |
| Issue Categories | Pothole, Drainage, Garbage, Street Light, Encroachment, Water Leakage, Other | ✅ Built |
| My Reports | List of all submitted issues with live status | ✅ Built |
| Status Tracking | Realtime: Pending → In Progress → Resolved | ✅ Built |
| Issue Detail | Full view with photo, map, status history timeline | ✅ Built |
| Public Map View | All city issues on OpenStreetMap with colored pins | ✅ Built |
| Push Notifications | FCM alert when issue status is updated | ✅ Built |
| Category Filter | Filter map pins by issue category | ✅ Built |
| Upvote Issues | Citizen upvoting for priority | 🔄 Future |
| Multi-language | Kannada, Hindi support | 🔄 Future |

### ⚙️ Admin Features

| Feature | Description | Status |
|---|---|---|
| Admin Login | Role-based access via Supabase RLS | ✅ Built |
| Issue Dashboard | All issues with count cards by status | ✅ Built |
| Filter & Search | Filter by category, status + text search | ✅ Built |
| Status Update | Pending → In Progress → Resolved | ✅ Built |
| Resolution Notes | Admin remarks visible to citizen | ✅ Built |
| View on Map | GPS location of any issue | ✅ Built |
| Status History | Full audit trail of status changes | ✅ Built |
| Analytics Charts | Heatmaps, resolution rates | 🔄 Future |
| Assign to Officer | Field officer assignment | 🔄 Future |

### 🔧 System Features

| Feature | Description | Status |
|---|---|---|
| Row Level Security | RLS policies — citizens see own data only | ✅ Built |
| Realtime Sync | Supabase Realtime subscriptions | ✅ Built |
| Image Compression | Auto-compress before upload (70% quality) | ✅ Built |
| Offline Handling | Graceful error messages | ✅ Built |
| GPS Auto-detect | Auto-fills location on report screen | ✅ Built |
| Auth Guards | GoRouter redirect for unauthenticated users | ✅ Built |
| Auto Profile Create | Trigger creates profile on first Google login | ✅ Built |

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
title        TEXT        Short issue title
description  TEXT        Detailed description (max 300 chars)
category     TEXT        Pothole | Drainage | Garbage | Street Light | ...
image_url    TEXT        Supabase Storage public URL
latitude     FLOAT8      GPS coordinate
longitude    FLOAT8      GPS coordinate
status       TEXT        Pending | In Progress | Resolved
admin_note   TEXT        Resolution remark by admin
upvotes      INT         Default 0
created_at   TIMESTAMP   Submission time
updated_at   TIMESTAMP   Last status change (auto-updated via trigger)
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
users ──────< issues (one user, many issues)
issues ─────< status_history (one issue, many status changes)
users ──────< status_history (one admin, many status changes)
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
lib/
├── main.dart                         # Entry point, Firebase + Supabase init
├── app.dart                          # MaterialApp + GoRouter setup
│
├── core/
│   ├── constants.dart                # Supabase URL, table names, categories
│   ├── theme.dart                    # Colors, text styles, dark theme
│   └── router.dart                   # GoRouter + auth redirect + _AuthNotifier
│
├── models/
│   ├── user_model.dart               # UserModel with isAdmin getter
│   ├── issue_model.dart              # IssueModel with all fields
│   └── status_history_model.dart     # StatusHistoryModel
│
├── services/
│   ├── supabase_service.dart         # Supabase client singleton
│   ├── auth_service.dart             # Google Sign-In, profile creation, FCM token
│   ├── issue_service.dart            # Full CRUD for issues + admin operations
│   ├── storage_service.dart          # Image compression + Supabase Storage upload
│   ├── location_service.dart         # GPS via geolocator + reverse geocoding
│   └── notification_service.dart     # FCM initialization + local notifications
│
├── providers/
│   ├── auth_provider.dart            # Auth state, user profile, isAdmin
│   └── issue_provider.dart           # Issues streams, filter state, admin providers
│
├── widgets/
│   └── app_widgets.dart              # IssueCard, StatusBadge, CategoryChip,
│                                     # LoadingWidget, EmptyState, GradientButton
│
└── screens/
    ├── splash/
    │   └── splash_screen.dart        # Animated splash with auto-login check
    ├── auth/
    │   └── login_screen.dart         # Email/Password + Google Sign-In
    ├── home/
    │   └── home_screen.dart          # OpenStreetMap with issue pins + FAB
    ├── report/
    │   └── report_issue_screen.dart  # Photo + GPS + category + submit
    ├── my_reports/
    │   └── my_reports_screen.dart    # User's issues with status summary
    ├── issue_detail/
    │   └── issue_detail_screen.dart  # Full issue view + status timeline
    ├── profile/
    │   └── profile_screen.dart       # User stats + admin access + sign out
    └── admin/
        ├── admin_dashboard_screen.dart    # All issues + filters + search
        └── admin_issue_detail_screen.dart # Status update + resolution notes
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
git clone https://github.com/manjunathvpoojari/smartcity-app
cd smartcity-app
flutter pub get
```

### Step 2 — Supabase Setup

1. Create project at [supabase.com](https://supabase.com)
2. Go to **SQL Editor** → paste and run `supabase_setup.sql`
3. Go to **Settings → API** → copy Project URL and anon key
4. Paste in `lib/core/constants.dart`:

```dart
static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
static const String supabaseAnonKey = 'YOUR_ANON_KEY';
```

### Step 3 — Google OAuth

1. [Google Cloud Console](https://console.cloud.google.com) → Create Web OAuth Client
2. Add Authorized redirect URI:
   ```
   https://YOUR_PROJECT_ID.supabase.co/auth/v1/callback
   ```
3. Add Authorized JavaScript origin:
   ```
   https://YOUR_PROJECT_ID.supabase.co
   ```
4. Supabase → Authentication → Providers → Google → Enable → paste Client ID + Secret
5. Supabase → Authentication → URL Configuration:
   ```
   Site URL: io.supabase.smart_city://login-callback
   Redirect URLs: io.supabase.smart_city://login-callback
   ```

### Step 4 — Firebase Setup

1. [Firebase Console](https://console.firebase.google.com) → New Project
2. Add Android app → package: `com.example.smart_city`
3. Download `google-services.json` → place in `android/app/`

### Step 5 — Make Admin

After first login, run in Supabase SQL Editor:
```sql
update public.users set role = 'admin' where email = 'your@email.com';
```

### Step 6 — Run

```bash
flutter run                          # Debug on device/emulator
flutter build apk --release          # Release APK
```

---

## 📱 Screens

| Screen | Route | Description |
|---|---|---|
| Splash | `/splash` | Lottie animation + auto auth check |
| Login | `/login` | Email/Password + Google Sign-In |
| Home (Map) | `/home` | OpenStreetMap with live issue pins |
| Report Issue | `/report` | Photo + GPS + category + description |
| My Reports | `/my-reports` | User's issues with status summary cards |
| Issue Detail | `/issue/:id` | Full view + map + status history timeline |
| Profile | `/profile` | Stats + admin access + sign out |
| Admin Dashboard | `/admin` | All issues + filters + count cards |
| Admin Issue Detail | `/admin/issue/:id` | Status update + resolution notes |

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
flutter_image_compress (70% quality, max 800px)
        ↓
uploadBinary() → Supabase Storage bucket: issue-images
        ↓
getPublicUrl() → stored in issues.image_url
```

### Push Notification Flow

```
Admin updates issue status
        ↓
status_history insert → Supabase trigger
        ↓
FCM token from users.fcm_token
        ↓
Push notification → Citizen's device
```

---

## 🐛 Known Issues & Fixes Applied

| Issue | Cause | Fix Applied |
|---|---|---|
| Sign out crash | Wrong Navigator context in dialog | Used `dialogContext` instead of screen `context` |
| Submit report failing | `upvotes` column missing in DB | Added via `alter table` + removed from insert |
| `FileOptions` undefined | Package version mismatch | Replaced with `uploadBinary` without `FileOptions` |
| `CardTheme` type error | Flutter version difference | Changed to `CardThemeData` |
| `flutter_local_notifications` missing | Not in pubspec | Added to dependencies |
| Core library desugaring error | Missing Gradle config | Added `isCoreLibraryDesugaringEnabled = true` |
| Network security config missing | Referenced but not created | Created `res/xml/network_security_config.xml` |
| FCM fails on emulator | No Google Play Services | Silent fail with `try/catch` |
| `upvotes` column missing | SQL ran partially | `alter table add column if not exists upvotes` |
| Profile shows null after navigation | Provider rebuilding without auth check | Fixed `userProfileProvider` to watch auth state |

---

## 🗺️ Roadmap

### Version 1.0 — Current ✅
- Core issue reporting with photo + GPS
- Public map with OpenStreetMap
- Admin dashboard with status management
- Email + Google Sign-In
- Push notifications via FCM
- Real-time status updates

### Version 1.1 — Next 🔄
- Lottie splash animation
- Home screen dashboard with stats
- Admin analytics charts (pie + bar)
- Better issue cards with upvote button
- Profile badges (Bronze/Silver/Gold)
- Notification badge on bottom nav

### Version 2.0 — Future 💭
- AI-based issue categorization from photo
- Issue upvoting and priority scoring
- Multi-language support (Kannada, Hindi)
- Web admin portal
- Field officer assignment
- Government portal integration
- Offline mode with local queue

---


## Theme

This project was built as part of the **VTU Internship Program 2026** and is intended for educational and civic demonstration purposes.

---

*Built with ❤️ using Flutter + Supabase — Zero cost, Real impact.*

> **GitHub:** [github.com/manjunathvpoojari](https://github.com/manjunathvpoojari)  
> **Portfolio:** [manjunathvpoojari.github.io](https://manjunathvpoojari.github.io)