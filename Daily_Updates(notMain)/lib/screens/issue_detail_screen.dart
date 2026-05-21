import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';
import '../models/issue.dart';

class IssueDetailScreen extends StatelessWidget {
  final Issue issue;
  const IssueDetailScreen({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          ScAppBar(
            title: 'Issue Detail',
            showBack: true,
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Issue image
                  Container(
                    width: double.infinity,
                    height: 130,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFD1FAE5), Color(0xFFA7F3D0)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(issue.categoryEmoji,
                          style: const TextStyle(fontSize: 52)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(issue.title,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(issue.statusLabel),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '📍 ${issue.location}, Mysuru · ${issue.timeAgo}',
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),

                  const Divider(height: 24, color: AppColors.border),

                  const FieldLabel('DESCRIPTION'),
                  const Text(
                    'Large pothole near Gandhi Circle junction causing traffic hazards and vehicle damage.',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.muted, height: 1.5),
                  ),
                  const SizedBox(height: 16),

                  const FieldLabel('LOCATION'),
                  Container(
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const MapPlaceholder(singlePin: true),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const FieldLabel('STATUS TIMELINE'),
                  const TimelineItem(
                    color: AppColors.accent,
                    title: 'Submitted',
                    subtitle: 'May 1, 9:15 AM',
                  ),
                  const TimelineItem(
                    color: AppColors.blue,
                    title: 'Under Review',
                    subtitle: 'May 2, 10:30 AM',
                  ),
                  const TimelineItem(
                    color: AppColors.border,
                    title: 'Resolved',
                    subtitle: 'Pending...',
                    isLast: true,
                    faded: true,
                  ),
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
