import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/shared_widgets.dart';
import '../../models/issue.dart';
import 'admin_manage_issue_screen.dart';

class AdminIssueListScreen extends StatefulWidget {
  const AdminIssueListScreen({super.key});
  @override
  State<AdminIssueListScreen> createState() => _AdminIssueListScreenState();
}

class _AdminIssueListScreenState extends State<AdminIssueListScreen> {
  int _filter = 0;
  final _filters = ['All', 'Pending', 'Progress', 'Resolved'];

  List<Issue> get _filtered {
    switch (_filter) {
      case 1:
        return SampleData.adminIssues
            .where((i) => i.status == IssueStatus.pending)
            .toList();
      case 2:
        return SampleData.adminIssues
            .where((i) => i.status == IssueStatus.inProgress)
            .toList();
      case 3:
        return SampleData.adminIssues
            .where((i) => i.status == IssueStatus.resolved)
            .toList();
      default:
        return SampleData.adminIssues;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const AdminAppBar(
            title: 'All Issues',
            subtitle: 'Sort: Newest first · 24 total',
          ),
          FilterPillsRow(
            filters: _filters,
            selected: _filter,
            onSelect: (i) => setState(() => _filter = i),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) {
                final issue = _filtered[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  issue.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${issue.date} · Citizen: ${issue.reportedBy}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(issue.statusLabel),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _ActionBtn(
                            label: issue.status == IssueStatus.pending
                                ? 'In Progress ↗'
                                : 'Resolve ↗',
                          ),
                          const SizedBox(width: 6),
                          _ActionBtn(
                            label: 'View',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AdminManageIssueScreen(issue: issue),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final bool danger;
  final VoidCallback? onTap;
  // ignore: unused_element_parameter
  const _ActionBtn({required this.label, this.danger = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: danger ? AppColors.dangerLight : AppColors.accentLight,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: danger ? AppColors.danger : AppColors.accent,
          ),
        ),
      ),
    );
  }
}
