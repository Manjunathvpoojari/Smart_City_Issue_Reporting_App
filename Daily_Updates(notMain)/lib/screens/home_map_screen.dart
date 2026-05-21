import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';
import '../models/issue.dart';
import 'issue_detail_screen.dart';

class HomeMapScreen extends StatelessWidget {
  const HomeMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const ScAppBar(
            title: 'Mysuru — Issue Map',
            subtitle: '📍 Vijayanagar, Mysuru',
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Map
                  Container(
                    margin: const EdgeInsets.all(12),
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3))
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: const MapPlaceholder(),
                    ),
                  ),

                  // Legend
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        _legendPill(AppColors.red, 'Pending'),
                        const SizedBox(width: 14),
                        _legendPill(AppColors.blue, 'In Progress'),
                        const SizedBox(width: 14),
                        _legendPill(AppColors.green, 'Resolved'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Summary card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nearby Issues (5)',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 14),
                        Row(children: [
                          _statMini('3', 'Pending', AppColors.red),
                          _statMini('1', 'Progress', AppColors.blue),
                          _statMini('1', 'Resolved', AppColors.green),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Recent issues
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Recent Issues',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: SampleData.citizenIssues
                          .map((issue) => IssueCard(
                                issue: issue,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => IssueDetailScreen(issue: issue)),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendPill(Color color, String label) {
    return Row(
      children: [
        Container(
            width: 10, height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.muted)),
      ],
    );
  }

  Widget _statMini(String num, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(num,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w800, color: color)),
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        ],
      ),
    );
  }
}
