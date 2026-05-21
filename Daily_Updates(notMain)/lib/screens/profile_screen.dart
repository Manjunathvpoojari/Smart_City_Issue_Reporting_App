import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const ScAppBar(title: 'Profile'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Avatar
                  Container(
                    width: 80, height: 80,
                    decoration: const BoxDecoration(
                        color: AppColors.accentLight, shape: BoxShape.circle),
                    child: const Center(
                      child: Text('RK',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accent)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Ravi Kumar',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text('ravi.kumar@gmail.com',
                      style: TextStyle(fontSize: 13, color: AppColors.muted)),
                  const SizedBox(height: 22),

                  // Stats
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _stat('4', 'Reports'),
                        _stat('1', 'Resolved'),
                        _stat('2', 'Pending'),
                        _stat('1', 'Progress'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  _menuItem('📍', 'My Location', 'Vijayanagar, Mysuru'),
                  _menuItem('🔔', 'Notifications', 'Enabled'),
                  _menuItem('🌐', 'Language', 'English'),
                  _menuItem('ℹ️', 'About SmartCity', ''),
                  const SizedBox(height: 22),

                  GestureDetector(
                    onTap: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.dangerLight,
                        border: Border.all(
                            color: AppColors.danger.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Logout',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.danger)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String num, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(num,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent)),
          Text(label,
              style: const TextStyle(fontSize: 10, color: AppColors.muted)),
        ],
      ),
    );
  }

  Widget _menuItem(String icon, String title, String sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600))),
          if (sub.isNotEmpty)
            Text(sub,
                style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
        ],
      ),
    );
  }
}
