import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/issue_model.dart';
import '../../providers/issue_provider.dart';
import '../../widgets/app_widgets.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabCtrl.dispose();
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
        backgroundColor: AppTheme.primary,
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings_rounded,
                color: Colors.white70, size: 18),
            SizedBox(width: 8),
            Text('Admin'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(adminIssuesProvider);
              ref.invalidate(issueCountsProvider);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(
                icon: Icon(Icons.dashboard_rounded, size: 18),
                text: 'Dashboard'),
            Tab(icon: Icon(Icons.list_alt_rounded, size: 18), text: 'Issues'),
            Tab(
                icon: Icon(Icons.analytics_rounded, size: 18),
                text: 'Analytics'),
          ],
        ),
      ),
      body: issuesAsync.when(
        loading: () => const LoadingWidget(message: 'Loading...'),
        error: (e, _) => ErrorRetryWidget(
          message: 'Failed to load data',
          onRetry: () => ref.invalidate(adminIssuesProvider),
        ),
        data: (issues) => TabBarView(
          controller: _tabCtrl,
          children: [
            _DashboardTab(issues: issues, countsAsync: countsAsync),
            _IssuesTab(
              issues: issues,
              filter: filter,
              ref: ref,
              searchCtrl: _searchCtrl,
            ),
            _AnalyticsTab(issues: issues),
          ],
        ),
      ),
    );
  }
}

// ── TAB 1: DASHBOARD ──────────────────────────────────────────────────────────

class _DashboardTab extends ConsumerWidget {
  final List<IssueModel> issues;
  final AsyncValue<Map<String, int>> countsAsync;

  const _DashboardTab({required this.issues, required this.countsAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return countsAsync.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => ErrorRetryWidget(
        message: 'Failed',
        onRetry: () => ref.invalidate(issueCountsProvider),
      ),
      data: (counts) {
        final total = counts['total'] ?? 0;
        final pending = counts['Pending'] ?? 0;
        final inProgress = counts['In Progress'] ?? 0;
        final resolved = counts['Resolved'] ?? 0;

        // Category counts for horizontal bars
        final categoryCounts = <String, int>{};
        for (final cat in AppConstants.categories) {
          categoryCounts[cat] = issues.where((i) => i.category == cat).length;
        }
        final maxCat = categoryCounts.values.isEmpty
            ? 1
            : categoryCounts.values.reduce((a, b) => a > b ? a : b);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_city_rounded,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('MCC — Shimoga City Corporation',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 11)),
                      Text('$total Active Reports',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Count cards
            Row(
              children: [
                _CountCard(
                    label: 'Total',
                    value: total,
                    color: AppTheme.primary,
                    icon: Icons.bar_chart_rounded),
                const SizedBox(width: 8),
                _CountCard(
                    label: 'Pending',
                    value: pending,
                    color: AppTheme.pendingColor,
                    icon: Icons.hourglass_empty_rounded),
                const SizedBox(width: 8),
                _CountCard(
                    label: 'Progress',
                    value: inProgress,
                    color: AppTheme.inProgressColor,
                    icon: Icons.autorenew_rounded),
                const SizedBox(width: 8),
                _CountCard(
                    label: 'Resolved',
                    value: resolved,
                    color: AppTheme.resolvedColor,
                    icon: Icons.check_circle_rounded),
              ],
            ),
            const SizedBox(height: 20),

            // By Category horizontal bars
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('By Category',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                  const SizedBox(height: 14),
                  ...AppConstants.categories.take(5).map((cat) {
                    final count = categoryCounts[cat] ?? 0;
                    final ratio = maxCat > 0 ? count / maxCat : 0.0;
                    final colors = [
                      Colors.red,
                      Colors.orange,
                      Colors.blue,
                      Colors.green,
                      Colors.grey,
                      Colors.teal,
                      Colors.purple,
                    ];
                    final idx = AppConstants.categories.indexOf(cat);
                    final barColor =
                        idx < colors.length ? colors[idx] : AppTheme.primary;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 70,
                                child: Text(cat,
                                    style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 11)),
                              ),
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: AppTheme.border,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: ratio.clamp(0.0, 1.0),
                                      child: Container(
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: barColor,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('$count',
                                  style: TextStyle(
                                      color: barColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.list_alt_rounded, size: 16),
                    label: const Text('View All Issues'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.map_rounded, size: 16),
                    label: const Text('Issue Map'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
          ],
        );
      },
    );
  }
}

// ── TAB 2: ISSUES LIST ────────────────────────────────────────────────────────

class _IssuesTab extends StatelessWidget {
  final List<IssueModel> issues;
  final FilterState filter;
  final WidgetRef ref;
  final TextEditingController searchCtrl;

  const _IssuesTab({
    required this.issues,
    required this.filter,
    required this.ref,
    required this.searchCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final total = issues.length;
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          color: AppTheme.cardBg,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('All Issues',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    Text('Sort: Newest first · $total total',
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Status filter chips
        Container(
          height: 44,
          color: AppTheme.cardBg,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            children: [
              'All',
              AppConstants.statusPending,
              AppConstants.statusInProgress,
              AppConstants.statusResolved
            ].map((s) {
              final sel = filter.status == s;
              final color =
                  s == 'All' ? AppTheme.primary : AppTheme.statusColor(s);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => ref.read(filterProvider.notifier).setStatus(s),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: sel ? color : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? color : AppTheme.border),
                    ),
                    child: Text(s,
                        style: TextStyle(
                          color: sel ? Colors.white : AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                        )),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 1),

        // Issues list
        Expanded(
          child: issues.isEmpty
              ? const EmptyState(
                  emoji: '🎉',
                  title: 'No Issues Found',
                  subtitle: 'All clear! No issues match the filter.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: issues.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final issue = issues[i];
                    return _IssueListTile(
                      issue: issue,
                      onTap: () => context.push('/admin/issue/${issue.id}',
                          extra: issue),
                      onStatusChange: (newStatus) async {
                        await ref.read(issueServiceProvider).updateIssueStatus(
                              issueId: issue.id,
                              oldStatus: issue.status,
                              newStatus: newStatus,
                            );
                        ref.invalidate(adminIssuesProvider);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ── TAB 3: ANALYTICS ──────────────────────────────────────────────────────────

class _AnalyticsTab extends StatelessWidget {
  final List<IssueModel> issues;

  const _AnalyticsTab({required this.issues});

  @override
  Widget build(BuildContext context) {
    final total = issues.length;
    final resolved = issues.where((i) => i.status == 'Resolved').length;
    final pending = issues.where((i) => i.status == 'Pending').length;
    final inProgress = issues.where((i) => i.status == 'In Progress').length;
    final resolutionRate = total > 0 ? (resolved / total) : 0.0;
    final resolutionPct = (resolutionRate * 100).toStringAsFixed(0);

    // Avg resolution time
    final resolvedIssues = issues.where((i) => i.status == 'Resolved').toList();
    double avgDays = 0;
    if (resolvedIssues.isNotEmpty) {
      final totalDays = resolvedIssues.fold<int>(
        0,
        (sum, i) => sum + i.updatedAt.difference(i.createdAt).inDays.abs(),
      );
      avgDays = totalDays / resolvedIssues.length;
    }

    // Top category
    final categoryCounts = <String, int>{};
    for (final cat in AppConstants.categories) {
      categoryCounts[cat] = issues.where((i) => i.category == cat).length;
    }
    String topCategory = 'None';
    int topCategoryCount = 0;
    categoryCounts.forEach((cat, count) {
      if (count > topCategoryCount) {
        topCategoryCount = count;
        topCategory = cat;
      }
    });

    // Reports this month
    final now = DateTime.now();
    final thisMonth = issues
        .where((i) =>
            i.createdAt.year == now.year && i.createdAt.month == now.month)
        .length;

    // Most affected area (rough location grouping)
    final areaMap = <String, int>{};
    for (final issue in issues) {
      final lat = (issue.latitude * 10).round() / 10;
      final lng = (issue.longitude * 10).round() / 10;
      final key = '${lat}_$lng';
      areaMap[key] = (areaMap[key] ?? 0) + 1;
    }
    String mostAffectedArea = 'Shimoga';
    if (areaMap.isNotEmpty) {
      // Just show "Shimoga City" since all issues are local
      mostAffectedArea = 'Shimoga City';
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        const Text('Issue Resolution Statistics',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 14),

        // Resolution Rate
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Resolution Rate',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                  const Spacer(),
                  Text('$resolutionPct%',
                      style: const TextStyle(
                          color: AppTheme.resolvedColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 18)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: resolutionRate.clamp(0.0, 1.0),
                  backgroundColor: AppTheme.border,
                  color: AppTheme.resolvedColor,
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 8),
              Text('$resolved of $total resolved',
                  style:
                      const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Stat rows — matching screenshot style
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: [
              _StatRow(
                icon: Icons.timer_outlined,
                iconColor: AppTheme.inProgressColor,
                label: 'Avg Resolution Time',
                value: avgDays > 0
                    ? '${avgDays.toStringAsFixed(1)} days'
                    : 'No data yet',
                valueColor: AppTheme.inProgressColor,
                showDivider: true,
              ),
              _StatRow(
                icon: Icons.location_on_rounded,
                iconColor: AppTheme.pendingColor,
                label: 'Most Affected Area',
                value: mostAffectedArea,
                valueColor: AppTheme.pendingColor,
                showDivider: true,
              ),
              _StatRow(
                icon: Icons.emoji_events_rounded,
                iconColor: AppTheme.error,
                label: 'Top Category',
                value: topCategoryCount > 0
                    ? '$topCategory ($topCategoryCount)'
                    : 'None',
                valueColor: AppTheme.error,
                showDivider: true,
              ),
              _StatRow(
                icon: Icons.calendar_month_rounded,
                iconColor: AppTheme.primary,
                label: 'Reports This Month',
                value: '$thisMonth',
                valueColor: AppTheme.primary,
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Status breakdown
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Status Breakdown',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
              const SizedBox(height: 14),
              _StatusBreakdownRow(
                label: 'Resolved',
                count: resolved,
                total: total,
                color: AppTheme.resolvedColor,
              ),
              const SizedBox(height: 10),
              _StatusBreakdownRow(
                label: 'In Progress',
                count: inProgress,
                total: total,
                color: AppTheme.inProgressColor,
              ),
              const SizedBox(height: 10),
              _StatusBreakdownRow(
                label: 'Pending',
                count: pending,
                total: total,
                color: AppTheme.pendingColor,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Category performance
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Category Performance',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
              const SizedBox(height: 14),
              ...AppConstants.categories.map((cat) {
                final catIssues =
                    issues.where((i) => i.category == cat).toList();
                final catResolved =
                    catIssues.where((i) => i.status == 'Resolved').length;
                final catTotal = catIssues.length;
                final catRate = catTotal > 0 ? catResolved / catTotal : 0.0;
                final icon = AppConstants.categoryIcons[cat] ?? '📌';
                if (catTotal == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Text(icon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(cat,
                                    style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                const Spacer(),
                                Text(
                                  '$catResolved/$catTotal resolved',
                                  style: const TextStyle(
                                      color: AppTheme.textMuted, fontSize: 10),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: catRate.clamp(0.0, 1.0),
                                backgroundColor: AppTheme.border,
                                color: AppTheme.resolvedColor,
                                minHeight: 5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ── Stat Row Widget (matching screenshot style) ────────────────────────────────

class _StatRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;
  final bool showDivider;

  const _StatRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
              ),
              Text(value,
                  style: TextStyle(
                      color: valueColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 13)),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}

// ── Status Breakdown Row ───────────────────────────────────────────────────────

class _StatusBreakdownRow extends StatelessWidget {
  final String label;
  final int count, total;
  final Color color;

  const _StatusBreakdownRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? count / total : 0.0;
    return Column(
      children: [
        Row(
          children: [
            Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12)),
            const Spacer(),
            Text('$count',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w800, fontSize: 13)),
            Text(
              '  (${(pct * 100).toStringAsFixed(0)}%)',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct.clamp(0.0, 1.0),
            backgroundColor: AppTheme.border,
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// ── Count Card ────────────────────────────────────────────────────────────────

class _CountCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _CountCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 5),
            Text('$value',
                style: TextStyle(
                    color: color, fontSize: 20, fontWeight: FontWeight.w800)),
            Text(label,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

// ── Issue List Tile (Issues Tab) ───────────────────────────────────────────────

class _IssueListTile extends StatelessWidget {
  final IssueModel issue;
  final VoidCallback onTap;
  final Function(String) onStatusChange;

  const _IssueListTile({
    required this.issue,
    required this.onTap,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.statusColor(issue.status);
    final statusBg = AppTheme.statusBgColor(issue.status);
    final catIcon = AppConstants.categoryIcons[issue.category] ?? '📌';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('$catIcon  ${issue.title}',
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(issue.status,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${issue.category} — ${issue.reporterName ?? 'Unknown'}',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (issue.status != 'Resolved')
                _ActionButton(
                  label: issue.status == 'Pending' ? 'In Progress' : 'Resolve',
                  icon: issue.status == 'Pending'
                      ? Icons.autorenew_rounded
                      : Icons.check_rounded,
                  color: issue.status == 'Pending'
                      ? AppTheme.inProgressColor
                      : AppTheme.resolvedColor,
                  onTap: () => onStatusChange(
                    issue.status == 'Pending' ? 'In Progress' : 'Resolved',
                  ),
                ),
              const SizedBox(width: 8),
              _ActionButton(
                label: 'View',
                icon: Icons.arrow_forward_rounded,
                color: AppTheme.primary,
                onTap: onTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
