import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../providers/issue_provider.dart';
import '../../widgets/app_widgets.dart';

class MyReportsScreen extends ConsumerWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issuesAsync = ref.watch(myIssuesStreamProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('My Reports')),
      body: issuesAsync.when(
        loading: () => const LoadingWidget(message: 'Loading your reports...'),
        error: (e, _) => ErrorRetryWidget(
          message: 'Failed to load reports',
          onRetry: () => ref.invalidate(myIssuesStreamProvider),
        ),
        data: (issues) {
          if (issues.isEmpty) {
            return EmptyState(
              emoji: '📋',
              title: 'No Reports Yet',
              subtitle: 'Tap the button below to report your first civic issue.',
              action: ElevatedButton.icon(
                onPressed: () => context.go('/report'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Report an Issue'),
              ),
            );
          }

          // Status summary chips
          final pending = issues.where((i) => i.status == 'Pending').length;
          final inProgress = issues.where((i) => i.status == 'In Progress').length;
          final resolved = issues.where((i) => i.status == 'Resolved').length;

          return Column(
            children: [
              // Summary row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _StatChip(label: 'Total', value: '${issues.length}', color: AppTheme.primary),
                    const SizedBox(width: 8),
                    _StatChip(label: 'Pending', value: '$pending', color: AppTheme.pendingColor),
                    const SizedBox(width: 8),
                    _StatChip(label: 'In Progress', value: '$inProgress', color: AppTheme.inProgressColor),
                    const SizedBox(width: 8),
                    _StatChip(label: 'Resolved', value: '$resolved', color: AppTheme.resolvedColor),
                  ],
                ),
              ),
              const Divider(height: 1),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: issues.length,
                  itemBuilder: (_, i) => IssueCard(
                    issue: issues[i],
                    onTap: () => context.push('/issue/${issues[i].id}', extra: issues[i]),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(
              color: color, fontSize: 18, fontWeight: FontWeight.w800,
            )),
            Text(label, style: const TextStyle(
              color: AppTheme.textMuted, fontSize: 10,
            )),
          ],
        ),
      ),
    );
  }
}
