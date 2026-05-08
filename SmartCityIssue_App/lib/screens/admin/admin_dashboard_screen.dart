import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/issue_provider.dart';
import '../../widgets/app_widgets.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(filterProvider);
    final issuesAsync = ref.watch(adminIssuesProvider);
    final countsAsync = ref.watch(issueCountsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings_rounded, color: AppTheme.secondary, size: 22),
            SizedBox(width: 8),
            Text('Admin Dashboard'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(adminIssuesProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats cards
          countsAsync.when(
            loading: () => const SizedBox(height: 80,
                child: Center(child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2))),
            error: (_, __) => const SizedBox.shrink(),
            data: (counts) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  _CountCard(label: 'Total', value: counts['total'] ?? 0, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  _CountCard(label: 'Pending', value: counts['Pending'] ?? 0, color: AppTheme.pendingColor),
                  const SizedBox(width: 8),
                  _CountCard(label: 'In Progress', value: counts['In Progress'] ?? 0, color: AppTheme.inProgressColor),
                  const SizedBox(width: 8),
                  _CountCard(label: 'Resolved', value: counts['Resolved'] ?? 0, color: AppTheme.resolvedColor),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search issues...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref.read(filterProvider.notifier).setSearch('');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => ref.read(filterProvider.notifier).setSearch(v),
            ),
          ),

          const SizedBox(height: 12),

          // Category filter
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['All', ...AppConstants.categories].map((cat) {
                final selected = filter.category == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      cat == 'All' ? 'All' : '${AppConstants.categoryIcons[cat]} $cat',
                      style: TextStyle(
                        color: selected ? Colors.white : AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                      ),
                    ),
                    selected: selected,
                    onSelected: (_) => ref.read(filterProvider.notifier).setCategory(cat),
                    backgroundColor: AppTheme.cardBg,
                    selectedColor: AppTheme.primary,
                    side: BorderSide(color: selected ? AppTheme.primary : AppTheme.border),
                    showCheckmark: false,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }).toList(),
            ),
          ),

          // Status filter
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['All', AppConstants.statusPending, AppConstants.statusInProgress, AppConstants.statusResolved]
                  .map((s) {
                final selected = filter.status == s;
                final color = s == 'All' ? AppTheme.primary : AppTheme.statusColor(s);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(s,
                      style: TextStyle(
                        color: selected ? Colors.white : AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                      ),
                    ),
                    selected: selected,
                    onSelected: (_) => ref.read(filterProvider.notifier).setStatus(s),
                    backgroundColor: AppTheme.cardBg,
                    selectedColor: color,
                    side: BorderSide(color: selected ? color : AppTheme.border),
                    showCheckmark: false,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),
          const Divider(height: 1),

          // Issues list
          Expanded(
            child: issuesAsync.when(
              loading: () => const LoadingWidget(message: 'Loading issues...'),
              error: (e, _) => ErrorRetryWidget(
                message: 'Failed to load issues',
                onRetry: () => ref.invalidate(adminIssuesProvider),
              ),
              data: (issues) {
                if (issues.isEmpty) {
                  return const EmptyState(
                    emoji: '🎉',
                    title: 'No Issues Found',
                    subtitle: 'All civic issues have been resolved, or no issues match your filters.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: issues.length,
                  itemBuilder: (_, i) {
                    final issue = issues[i];
                    return IssueCard(
                      issue: issue,
                      onTap: () => context.push('/admin/issue/${issue.id}', extra: issue),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _CountCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text('$value', style: TextStyle(
            color: color, fontSize: 20, fontWeight: FontWeight.w800,
          )),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
