import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/shared_widgets.dart';

class AdminMapScreen extends StatelessWidget {
  const AdminMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const AdminAppBar(title: 'Issue Map', subtitle: 'All city issues'),
          Expanded(
            child: Column(
              children: [
                // Legend
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(children: [
                    _legendPill(AppColors.red, 'Pending'),
                    const SizedBox(width: 16),
                    _legendPill(AppColors.blue, 'In Progress'),
                    const SizedBox(width: 16),
                    _legendPill(AppColors.green, 'Resolved'),
                  ]),
                ),
                Expanded(
                  child: const MapPlaceholder(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendPill(Color color, String label) {
    return Row(children: [
      Container(width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
    ]);
  }
}
