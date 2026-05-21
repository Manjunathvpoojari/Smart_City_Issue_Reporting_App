import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum IssueStatus { pending, inProgress, resolved }

class Issue {
  final String id;
  final String title;
  final String category;
  final String categoryEmoji;
  final String location;
  final String timeAgo;
  final IssueStatus status;
  final double? progressFill;
  final Color dotColor;
  final String? reportedBy;
  final String? date;

  const Issue({
    required this.id,
    required this.title,
    required this.category,
    required this.categoryEmoji,
    required this.location,
    required this.timeAgo,
    required this.status,
    required this.dotColor,
    this.progressFill,
    this.reportedBy,
    this.date,
  });

  String get statusLabel {
    switch (status) {
      case IssueStatus.pending:    return 'Pending';
      case IssueStatus.inProgress: return 'In Progress';
      case IssueStatus.resolved:   return 'Resolved';
    }
  }

  Color get statusColor {
    switch (status) {
      case IssueStatus.pending:    return AppColors.pendingColor;
      case IssueStatus.inProgress: return AppColors.progressColor;
      case IssueStatus.resolved:   return AppColors.resolvedColor;
    }
  }

  Color get statusBg {
    switch (status) {
      case IssueStatus.pending:    return AppColors.pendingBg;
      case IssueStatus.inProgress: return AppColors.progressBg;
      case IssueStatus.resolved:   return AppColors.resolvedBg;
    }
  }
}

// ── Sample data ──────────────────────────────────────────────
class SampleData {
  static final List<Issue> citizenIssues = [
    Issue(
      id: 'ISS-001', title: 'Pothole — Gandhi Circle',
      category: 'Pothole', categoryEmoji: '🕳️',
      location: 'Vijayanagar', timeAgo: '2 days ago',
      status: IssueStatus.pending, dotColor: AppColors.red,
    ),
    Issue(
      id: 'ISS-002', title: 'Garbage — Sayyaji Rao Rd',
      category: 'Garbage', categoryEmoji: '🗑️',
      location: 'City Centre', timeAgo: '3 days ago',
      status: IssueStatus.inProgress, dotColor: AppColors.amber,
      progressFill: 0.6,
    ),
    Issue(
      id: 'ISS-003', title: 'Drainage — KRS Road',
      category: 'Drainage', categoryEmoji: '🚰',
      location: 'Mandya Road', timeAgo: '5 days ago',
      status: IssueStatus.pending, dotColor: AppColors.indigo,
    ),
    Issue(
      id: 'ISS-004', title: 'Lighting — Nazarbad',
      category: 'Lighting', categoryEmoji: '💡',
      location: 'Nazarbad', timeAgo: '8 days ago',
      status: IssueStatus.resolved, dotColor: AppColors.green,
    ),
  ];

  static final List<Issue> adminIssues = [
    Issue(
      id: 'ISS-001', title: 'Pothole — Gandhi Circle',
      category: 'Pothole', categoryEmoji: '🕳️',
      location: 'Vijayanagar', timeAgo: 'May 2',
      status: IssueStatus.pending, dotColor: AppColors.red,
      reportedBy: 'Ravi K.', date: 'May 2',
    ),
    Issue(
      id: 'ISS-002', title: 'Garbage — Sayyaji Rd',
      category: 'Garbage', categoryEmoji: '🗑️',
      location: 'City Centre', timeAgo: 'May 1',
      status: IssueStatus.inProgress, dotColor: AppColors.amber,
      reportedBy: 'Priya M.', date: 'May 1',
    ),
    Issue(
      id: 'ISS-003', title: 'Drainage — KRS Road',
      category: 'Drainage', categoryEmoji: '🚰',
      location: 'Mandya Road', timeAgo: 'Apr 29',
      status: IssueStatus.pending, dotColor: AppColors.indigo,
      reportedBy: 'Suresh T.', date: 'Apr 29',
    ),
    Issue(
      id: 'ISS-004', title: 'Lighting — Nazarbad',
      category: 'Lighting', categoryEmoji: '💡',
      location: 'Nazarbad', timeAgo: 'Apr 28',
      status: IssueStatus.resolved, dotColor: AppColors.green,
      reportedBy: 'Meena R.', date: 'Apr 28',
    ),
  ];
}
