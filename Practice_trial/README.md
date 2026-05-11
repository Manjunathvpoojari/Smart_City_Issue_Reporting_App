# SmartCity — Flutter UI

Smart City Issue Reporting & Civic Engagement App  
UI built from wireframes (Week 2 deliverable).

---

## 📁 lib/ Folder Structure

```
lib/
├── main.dart                          ← App entry point
├── theme/
│   └── app_colors.dart                ← All color constants (matches wireframe CSS vars)
├── models/
│   └── issue.dart                     ← Issue model + SampleData
├── widgets/
│   └── shared_widgets.dart            ← Reusable: AppBar, StatusBadge, IssueCard,
│                                          MapPlaceholder, FilterPills, Timeline, etc.
└── screens/
    ├── login_screen.dart              ← Screen 1: Login (Google + Admin)
    ├── citizen_main_screen.dart       ← Bottom nav shell (Map/Reports/Alerts/Profile)
    ├── home_map_screen.dart           ← Screen 2: Home Map
    ├── report_issue_screen.dart       ← Screen 3: Report Issue
    ├── my_reports_screen.dart         ← Screen 4: My Reports
    ├── issue_detail_screen.dart       ← Screen 5: Issue Detail + Timeline
    ├── notifications_screen.dart      ← Screen 6: Notifications
    ├── profile_screen.dart            ← Screen 7: Profile + Logout
    └── admin/
        ├── admin_main_screen.dart     ← Admin bottom nav shell
        ├── admin_dashboard_screen.dart ← A1: Dashboard (stats + bar chart)
        ├── admin_issue_list_screen.dart ← A2: All Issues List
        ├── admin_manage_issue_screen.dart ← A3: Manage Issue (status + note)
        ├── admin_map_screen.dart      ← Admin Map View
        └── admin_analytics_screen.dart ← Analytics placeholder
```

---

## 🚀 Setup

### 1. Copy lib/ folder
Replace your entire `lib/` folder with this one.

### 2. pubspec.yaml
Replace with the provided `pubspec.yaml`, then run:
```bash
flutter pub get
```

### 3. AndroidManifest.xml
Open `android/app/src/main/AndroidManifest.xml` and paste the contents of  
`android_manifest_permissions.xml` inside the `<manifest>` tag, **before** `<application>`.

### 4. Run
```bash
flutter run
```

---

## 🎨 Color Palette (from wireframe CSS vars)

| Variable         | Hex       | Usage                    |
|------------------|-----------|--------------------------|
| `accent`         | #1D5E3F   | Primary green, app bars  |
| `accentDark`     | #0F3D27   | Admin dark green         |
| `accentLight`    | #E6F4ED   | Light green backgrounds  |
| `bg`             | #F5F4F0   | App background           |
| `border`         | #E2E0D8   | Card borders             |
| `pendingColor`   | #B45309   | Pending badge text       |
| `progressColor`  | #1E40AF   | In Progress badge text   |
| `resolvedColor`  | #166534   | Resolved badge text      |

---

## 📱 Screens

| # | Screen              | Role    |
|---|---------------------|---------|
| 1 | Login               | Both    |
| 2 | Home Map            | Citizen |
| 3 | Report Issue        | Citizen |
| 4 | My Reports          | Citizen |
| 5 | Issue Detail        | Citizen |
| 6 | Notifications       | Citizen |
| 7 | Profile             | Citizen |
| A1| Admin Dashboard     | Admin   |
| A2| Admin Issue List    | Admin   |
| A3| Admin Manage Issue  | Admin   |
| —  | Admin Map View      | Admin   |
| —  | Admin Analytics     | Admin   |

---

## 🔌 Backend (when ready)

Uncomment packages in `pubspec.yaml`:
- **Supabase** → Auth, DB, Realtime
- **google_sign_in** → Google OAuth
- **flutter_map + latlong2** → Replace MapPlaceholder with real OSM map
- **geolocator** → Real GPS in Report screen
- **image_picker** → Real camera/gallery
- **flutter_riverpod** → State management
- **firebase_messaging** → Push notifications
