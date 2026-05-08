import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/issue_model.dart';
// ignore: unused_import
import '../providers/auth_provider.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_issue_detail_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/issue_detail/issue_detail_screen.dart';
import '../screens/my_reports/my_reports_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/report/report_issue_screen.dart';
import '../screens/splash/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Listen to auth state so router refreshes on login/logout
  final notifier = _AuthNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuth = session != null;
      final loc = state.matchedLocation;

      if (loc == '/splash') return null;
      if (!isAuth && loc != '/login') return '/login';
      if (isAuth && loc == '/login') return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(
              path: '/report', builder: (_, __) => const ReportIssueScreen()),
          GoRoute(
              path: '/my-reports', builder: (_, __) => const MyReportsScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/issue/:id',
        builder: (context, state) {
          final issue = state.extra as IssueModel;
          return IssueDetailScreen(issue: issue);
        },
      ),
      GoRoute(path: '/admin', builder: (_, __) => const AdminDashboardScreen()),
      GoRoute(
        path: '/admin/issue/:id',
        builder: (context, state) {
          final issue = state.extra as IssueModel;
          return AdminIssueDetailScreen(issue: issue);
        },
      ),
    ],
  );
});

// Listens to Supabase auth state and notifies GoRouter to re-evaluate redirect
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(Ref ref) {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      notifyListeners();
    });
  }
}

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedIndex = 0;

  final _tabs = ['/home', '/my-reports', '/profile'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          context.go(_tabs[index]);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'My Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
