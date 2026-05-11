import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';
import '../models/issue.dart';
import 'issue_detail_screen.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});
  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  int _filter = 0;
  final _filters = ['All (4)', 'Pending (2)', 'Progress (1)', 'Resolved (1)'];

  List<Issue> get _filtered {
    switch (_filter) {
      case 1: return SampleData.citizenIssues
          .where((i) => i.status == IssueStatus.pending).toList();
      case 2: return SampleData.citizenIssues
          .where((i) => i.status == IssueStatus.inProgress).toList();
      case 3: return SampleData.citizenIssues
          .where((i) => i.status == IssueStatus.resolved).toList();
      default: return SampleData.citizenIssues;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const ScAppBar(title: 'My Reports', subtitle: '4 issues submitted'),
          FilterPillsRow(
            filters: _filters,
            selected: _filter,
            onSelect: (i) => setState(() => _filter = i),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _filtered
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
        ],
      ),
    );
  }
}
