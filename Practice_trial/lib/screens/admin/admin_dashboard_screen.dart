import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/shared_widgets.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const AdminAppBar(
            title: 'Dashboard',
            subtitle: 'MCC — Mysuru City Corporation',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  Row(children: [
                    _StatCard('24', 'Total',    AppColors.accent),
                    const SizedBox(width: 8),
                    _StatCard('11', 'Pending',  AppColors.red),
                    const SizedBox(width: 8),
                    _StatCard('8',  'Progress', AppColors.blue),
                    const SizedBox(width: 8),
                    _StatCard('5',  'Resolved', AppColors.green),
                  ]),
                  const SizedBox(height: 18),

                  const Text('By Category',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(children: [
                      _CatBar('Pothole',  0.70, 8, AppColors.red),
                      const SizedBox(height: 10),
                      _CatBar('Garbage',  0.45, 5, AppColors.amber),
                      const SizedBox(height: 10),
                      _CatBar('Drainage', 0.36, 4, AppColors.indigo),
                      const SizedBox(height: 10),
                      _CatBar('Lighting', 0.27, 3, AppColors.green),
                      const SizedBox(height: 10),
                      _CatBar('Other',    0.18, 2, AppColors.slate),
                    ]),
                  ),
                  const SizedBox(height: 18),

                  Row(children: [
                    Expanded(child: PrimaryButton(label: 'View All Issues', onTap: () {})),
                    const SizedBox(width: 10),
                    Expanded(child: SecondaryButton(label: 'Issue Map', onTap: () {})),
                  ]),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String num, label;
  final Color color;
  const _StatCard(this.num, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Text(num,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          Text(label,
              style: const TextStyle(fontSize: 10, color: AppColors.muted)),
        ]),
      ),
    );
  }
}

class _CatBar extends StatelessWidget {
  final String label;
  final double fill;
  final int count;
  final Color color;
  const _CatBar(this.label, this.fill, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
        width: 58,
        child: Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.muted)),
      ),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fill,
            minHeight: 8,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Text('$count',
          style: const TextStyle(fontSize: 11, color: AppColors.muted)),
    ]);
  }
}
