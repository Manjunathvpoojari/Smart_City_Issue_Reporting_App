import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_map_screen.dart';
import 'my_reports_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'report_issue_screen.dart';

class CitizenMainScreen extends StatefulWidget {
  const CitizenMainScreen({super.key});
  @override
  State<CitizenMainScreen> createState() => _CitizenMainScreenState();
}

class _CitizenMainScreenState extends State<CitizenMainScreen> {
  int _index = 0;

  final List<Widget> _pages = const [
    HomeMapScreen(),
    MyReportsScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ReportIssueScreen())),
              backgroundColor: AppColors.accent,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            _navItem(0, '🗺️', 'Map'),
            _navItem(1, '📋', 'Reports'),
            _navItem(2, '🔔', 'Alerts'),
            _navItem(3, '👤', 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int i, String emoji, String label) {
    final active = _index == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _index = i),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 3),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w700 : FontWeight.normal,
                      color: active ? AppColors.accent : AppColors.muted)),
              if (active)
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  width: 4, height: 4,
                  decoration: const BoxDecoration(
                      color: AppColors.accent, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
