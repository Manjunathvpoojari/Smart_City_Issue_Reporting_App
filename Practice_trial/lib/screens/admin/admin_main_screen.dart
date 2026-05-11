import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'admin_dashboard_screen.dart';
import 'admin_issue_list_screen.dart';
import 'admin_map_screen.dart';
import 'admin_analytics_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});
  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _index = 0;

  final List<Widget> _pages = const [
    AdminDashboardScreen(),
    AdminIssueListScreen(),
    AdminMapScreen(),
    AdminAnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            _navItem(0, '📊', 'Dashboard'),
            _navItem(1, '📋', 'Issues'),
            _navItem(2, '🗺️', 'Map'),
            _navItem(3, '📈', 'Analytics'),
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
                      fontSize: 10,
                      fontWeight: active ? FontWeight.w700 : FontWeight.normal,
                      color: active ? AppColors.accentDark : AppColors.muted)),
            ],
          ),
        ),
      ),
    );
  }
}
