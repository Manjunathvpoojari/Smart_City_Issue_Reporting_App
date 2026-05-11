import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const ScAppBar(title: 'Notifications', subtitle: '3 new updates'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: const [
                NotifCard(
                  leftColor: AppColors.blue,
                  emoji: '🔵',
                  title: 'Status Updated',
                  body: 'Your Pothole report is now In Progress',
                  time: '2 hours ago',
                ),
                NotifCard(
                  leftColor: AppColors.green,
                  emoji: '✅',
                  title: 'Issue Resolved',
                  body: 'Lighting — Nazarbad has been resolved',
                  time: 'Yesterday · Admin note: Bulb replaced',
                ),
                NotifCard(
                  leftColor: AppColors.accent,
                  emoji: '📋',
                  title: 'Report Received',
                  body: 'Drainage report submitted successfully',
                  time: '3 days ago',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
