import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

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
  final _mapController = MapController();
  late TabController _tabCtrl;
  int _touchedPieIndex = -1;

  @override
  void initState() {
    super.initState();
    // 4 tabs: Dashboard | Issues | Map | Analytics
    _tabCtrl = TabController(length: 4, vsync: this);
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
        title: const Row(children: [
          Icon(Icons.admin_panel_settings_rounded,
              color: Colors.white70, size: 20),
          SizedBox(width: 8),
          Text('Admin Dashboard',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
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
              const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(
                icon: Icon(Icons.dashboard_outlined, size: 16),
                text: 'Dashboard'),
            Tab(icon: Icon(Icons.list_alt_outlined, size: 16), text: 'Issues'),
            Tab(icon: Icon(Icons.map_outlined, size: 16), text: 'Issue Map'),
            Tab(
                icon: Icon(Icons.analytics_outlined, size: 16),
                text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildDashboardTab(countsAsync, issuesAsync),
          _buildIssuesTab(filter, issuesAsync),
          _buildMapTab(issuesAsync),
          _buildAnalyticsTab(countsAsync, issuesAsync),
        ],
      ),
    );
  }

  // ── TAB 1: DASHBOARD ──────────────────────────────────────────────────────

  Widget _buildDashboardTab(
    AsyncValue<Map<String, int>> countsAsync,
    AsyncValue<List<IssueModel>> issuesAsync,
  ) {
    return countsAsync.when(
      loading: () => const LoadingWidget(message: 'Loading dashboard...'),
      error: (e, _) => ErrorRetryWidget(
        message: 'Failed to load dashboard',
        onRetry: () => ref.invalidate(issueCountsProvider),
      ),
      data: (counts) {
        final issues = issuesAsync.valueOrNull ?? [];
        final total = counts['total'] ?? 0;
        final pending = counts['Pending'] ?? 0;
        final inProgress = counts['In Progress'] ?? 0;
        final resolved = counts['Resolved'] ?? 0;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Header greeting ────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome, Admin 👋',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16)),
                        SizedBox(height: 4),
                        Text('Shimoga City Corporation',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_city_rounded,
                        color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Summary Cards ──────────────────────────
            Row(children: [
              _DashCard(
                  label: 'Total',
                  value: '$total',
                  icon: Icons.bar_chart_rounded,
                  color: AppTheme.primary),
              const SizedBox(width: 10),
              _DashCard(
                  label: 'Pending',
                  value: '$pending',
                  icon: Icons.hourglass_empty_rounded,
                  color: AppTheme.pendingColor),
              const SizedBox(width: 10),
              _DashCard(
                  label: 'Progress',
                  value: '$inProgress',
                  icon: Icons.autorenew_rounded,
                  color: AppTheme.inProgressColor),
              const SizedBox(width: 10),
              _DashCard(
                  label: 'Resolved',
                  value: '$resolved',
                  icon: Icons.check_circle_rounded,
                  color: AppTheme.resolvedColor),
            ]),
            const SizedBox(height: 16),

            // ── By Category horizontal bars ────────────
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
                  ...AppConstants.categories.map((cat) {
                    final count = issues.where((i) => i.category == cat).length;
                    final maxCount = _maxCategoryCount(issues);
                    final ratio = maxCount > 0 ? count / maxCount : 0.0;
                    final catColors = [
                      Colors.red,
                      Colors.orange,
                      Colors.blue,
                      Colors.green,
                      Colors.purple,
                      Colors.teal,
                      Colors.grey,
                    ];
                    final colorIndex =
                        AppConstants.categories.indexOf(cat) % catColors.length;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(children: [
                        SizedBox(
                          width: 72,
                          child: Text(cat,
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 11),
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: ratio.toDouble(),
                              backgroundColor: AppTheme.border,
                              color: catColors[colorIndex],
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('$count',
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12)),
                      ]),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Quick Action Buttons ───────────────────
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _tabCtrl.animateTo(1),
                  icon: const Icon(Icons.list_alt_rounded, size: 16),
                  label: const Text('View All Issues'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _tabCtrl.animateTo(2),
                  icon: const Icon(Icons.map_rounded, size: 16),
                  label: const Text('Issue Map'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppTheme.primary),
                    foregroundColor: AppTheme.primary,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 80),
          ],
        );
      },
    );
  }

  // ── TAB 2: ISSUES LIST ────────────────────────────────────────────────────

  Widget _buildIssuesTab(
      FilterState filter, AsyncValue<List<IssueModel>> issuesAsync) {
    return Column(children: [
      // Search
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: TextField(
          controller: _searchCtrl,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search issues...',
            prefixIcon: const Icon(Icons.search_rounded,
                color: AppTheme.textMuted, size: 20),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppTheme.textMuted, size: 18),
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
      const SizedBox(height: 10),

      // Status filter
      SizedBox(
        height: 34,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? color.withOpacity(0.12) : AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? color : AppTheme.border),
                  ),
                  child: Text(s,
                      style: TextStyle(
                          color: sel ? color : AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 8),
      const Divider(height: 1),

      // Issue list
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
                subtitle: 'No issues match your current filters.',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: issues.length,
              itemBuilder: (_, i) => IssueCard(
                issue: issues[i],
                onTap: () => context.push('/admin/issue/${issues[i].id}',
                    extra: issues[i]),
              ),
            );
          },
        ),
      ),
    ]);
  }

  // ── TAB 3: ISSUE MAP ──────────────────────────────────────────────────────

  Widget _buildMapTab(AsyncValue<List<IssueModel>> issuesAsync) {
    return issuesAsync.when(
      loading: () => const LoadingWidget(message: 'Loading map...'),
      error: (e, _) => ErrorRetryWidget(
        message: 'Failed to load map',
        onRetry: () => ref.invalidate(adminIssuesProvider),
      ),
      data: (issues) => Column(children: [
        // Legend + count bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: AppTheme.cardBg,
            border: Border(bottom: BorderSide(color: AppTheme.border)),
          ),
          child: Row(children: [
            const Icon(Icons.location_on_rounded,
                size: 14, color: AppTheme.primary),
            const SizedBox(width: 6),
            Text('${issues.length} issues mapped',
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
            const Spacer(),
            _MapDot(color: AppTheme.pendingColor, label: 'Pending'),
            const SizedBox(width: 10),
            _MapDot(color: AppTheme.inProgressColor, label: 'Active'),
            const SizedBox(width: 10),
            _MapDot(color: AppTheme.resolvedColor, label: 'Resolved'),
          ]),
        ),

        // Full-screen map
        Expanded(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(
                  AppConstants.defaultLat, AppConstants.defaultLng),
              initialZoom: AppConstants.defaultZoom,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.smart_city',
              ),
              MarkerLayer(
                markers: issues.map(_buildMarker).toList(),
              ),
            ],
          ),
        ),

        // Bottom bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: AppTheme.cardBg,
            border: Border(top: BorderSide(color: AppTheme.border)),
          ),
          child: Row(children: [
            const Text('Tap a pin to manage the issue',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            const Spacer(),
            GestureDetector(
              onTap: () => _mapController.move(
                const LatLng(AppConstants.defaultLat, AppConstants.defaultLng),
                AppConstants.defaultZoom,
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                ),
                child: const Row(children: [
                  Icon(Icons.my_location_rounded,
                      size: 13, color: AppTheme.primary),
                  SizedBox(width: 4),
                  Text('Reset',
                      style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Marker _buildMarker(IssueModel issue) {
    final color = AppTheme.statusColor(issue.status);
    final bgColor = AppTheme.statusBgColor(issue.status);
    final emoji = AppConstants.categoryIcons[issue.category] ?? '📌';

    return Marker(
      point: LatLng(issue.latitude, issue.longitude),
      width: 44,
      height: 54,
      child: GestureDetector(
        onTap: () => _showIssueSheet(issue),
        child: Column(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2.5),
              boxShadow: [
                BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 18))),
          ),
          Container(
            width: 3,
            height: 10,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2)),
          ),
        ]),
      ),
    );
  }

  void _showIssueSheet(IssueModel issue) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Text(AppConstants.categoryIcons[issue.category] ?? '📌',
                  style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(issue.title,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
              ),
              StatusBadge(status: issue.status),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.person_outline_rounded,
                  size: 13, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Text(issue.reporterName ?? 'Citizen',
                  style:
                      const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              const SizedBox(width: 12),
              const Icon(Icons.category_rounded,
                  size: 13, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Text(issue.category,
                  style:
                      const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ]),
            const SizedBox(height: 8),
            Text(issue.description,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Close'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/admin/issue/${issue.id}', extra: issue);
                  },
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Manage'),
                ),
              ),
            ]),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── TAB 4: ANALYTICS ──────────────────────────────────────────────────────

  Widget _buildAnalyticsTab(
    AsyncValue<Map<String, int>> countsAsync,
    AsyncValue<List<IssueModel>> issuesAsync,
  ) {
    return countsAsync.when(
      loading: () => const LoadingWidget(message: 'Loading analytics...'),
      error: (e, _) => ErrorRetryWidget(
        message: 'Failed to load analytics',
        onRetry: () => ref.invalidate(issueCountsProvider),
      ),
      data: (counts) {
        final issues = issuesAsync.valueOrNull ?? [];
        final total = counts['total'] ?? 0;
        final pending = counts['Pending'] ?? 0;
        final inProgress = counts['In Progress'] ?? 0;
        final resolved = counts['Resolved'] ?? 0;
        final rate =
            total > 0 ? ((resolved / total) * 100).toStringAsFixed(0) : '0';

        // Average resolution time
        final resolvedIssues =
            issues.where((i) => i.status == 'Resolved').toList();
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
        final thisMonth = issues.where((i) {
          return i.createdAt.year == now.year && i.createdAt.month == now.month;
        }).length;

        // Most affected area
        final mostAffectedArea = issues.isNotEmpty ? 'Shimoga City' : 'No data';

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Resolution rate
            _ChartCard(
              title: 'Resolution Rate',
              subtitle: '$rate% of all issues resolved',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: total > 0 ? resolved / total : 0,
                            backgroundColor: AppTheme.border,
                            color: AppTheme.resolvedColor,
                            minHeight: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$rate%',
                        style: const TextStyle(
                          color: AppTheme.resolvedColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _ProgDot(
                        color: AppTheme.resolvedColor,
                        label: 'Resolved: $resolved',
                      ),
                      _ProgDot(
                        color: AppTheme.inProgressColor,
                        label: 'Active: $inProgress',
                      ),
                      _ProgDot(
                        color: AppTheme.pendingColor,
                        label: 'Pending: $pending',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Key Statistics
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
                    iconColor: AppTheme.primary,
                    label: 'Top Category',
                    value: topCategoryCount > 0
                        ? '$topCategory ($topCategoryCount)'
                        : 'None',
                    valueColor: AppTheme.primary,
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
            const SizedBox(height: 16),

            // Status Distribution (Pie Chart)
            if (total > 0)
              _ChartCard(
                title: 'Status Distribution',
                subtitle: 'Tap a slice to highlight',
                child: SizedBox(
                  height: 200,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (event, response) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      response == null ||
                                      response.touchedSection == null) {
                                    _touchedPieIndex = -1;
                                    return;
                                  }
                                  _touchedPieIndex = response
                                      .touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            sections: [
                              _pieSection(
                                value: pending.toDouble(),
                                color: AppTheme.pendingColor,
                                title: '$pending',
                                isTouched: _touchedPieIndex == 0,
                              ),
                              _pieSection(
                                value: inProgress.toDouble(),
                                color: AppTheme.inProgressColor,
                                title: '$inProgress',
                                isTouched: _touchedPieIndex == 1,
                              ),
                              _pieSection(
                                value: resolved.toDouble(),
                                color: AppTheme.resolvedColor,
                                title: '$resolved',
                                isTouched: _touchedPieIndex == 2,
                              ),
                            ],
                            centerSpaceRadius: 42,
                            sectionsSpace: 3,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _PieLeg(
                              color: AppTheme.pendingColor,
                              label: 'Pending',
                              value: '$pending',
                            ),
                            const SizedBox(height: 12),
                            _PieLeg(
                              color: AppTheme.inProgressColor,
                              label: 'In Progress',
                              value: '$inProgress',
                            ),
                            const SizedBox(height: 12),
                            _PieLeg(
                              color: AppTheme.resolvedColor,
                              label: 'Resolved',
                              value: '$resolved',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (total > 0) const SizedBox(height: 16),

            // Status Breakdown
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
                  const Text(
                    'Status Breakdown',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
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
            const SizedBox(height: 16),

            // Weekly Trend
            if (issues.isNotEmpty)
              _ChartCard(
                title: 'Weekly Trend',
                subtitle: 'Issues reported last 7 days',
                child: SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: AppTheme.border,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            getTitlesWidget: (value, meta) {
                              const days = [
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                                'Sun'
                              ];
                              if (value.toInt() < days.length) {
                                return Text(
                                  days[value.toInt()],
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 10,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              if (value == value.roundToDouble()) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 10,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _weeklySpots(issues),
                          isCurved: true,
                          color: AppTheme.primary,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) =>
                                FlDotCirclePainter(
                              radius: 4,
                              color: AppTheme.primary,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.primary.withOpacity(0.08),
                          ),
                        ),
                      ],
                      minX: 0,
                      maxX: 6,
                      minY: 0,
                    ),
                  ),
                ),
              ),
            if (issues.isNotEmpty) const SizedBox(height: 16),

            // Category Performance
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
                  const Text(
                    'Category Performance',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...AppConstants.categories.map((cat) {
                    final catIssues =
                        issues.where((i) => i.category == cat).toList();
                    final catTotal = catIssues.length;
                    if (catTotal == 0) {
                      return const SizedBox.shrink();
                    }

                    final catResolved =
                        catIssues.where((i) => i.status == 'Resolved').length;
                    final catRate = catResolved / catTotal;
                    final icon = AppConstants.categoryIcons[cat] ?? '📌';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Text(
                            icon,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        cat,
                                        style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '$catResolved/$catTotal resolved',
                                      style: const TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: catRate,
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
      },
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  PieChartSectionData _pieSection({
    required double value,
    required Color color,
    required String title,
    required bool isTouched,
  }) =>
      PieChartSectionData(
        value: value == 0 ? 0.001 : value,
        color: color,
        title: value > 0 ? title : '',
        radius: isTouched ? 65 : 55,
        titleStyle: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
      );

  int _maxCategoryCount(List<IssueModel> issues) {
    int max = 0;
    for (final cat in AppConstants.categories) {
      final c = issues.where((i) => i.category == cat).length;
      if (c > max) max = c;
    }
    return max == 0 ? 1 : max;
  }

  List<FlSpot> _weeklySpots(List<IssueModel> issues) {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final count = issues.where((issue) {
        final d = issue.createdAt;
        return d.year == day.year && d.month == day.month && d.day == day.day;
      }).length;
      return FlSpot(i.toDouble(), count.toDouble());
    });
  }
}

// ── Small Reusable Widgets ────────────────────────────────────────────────────

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
  Widget build(BuildContext context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            const Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
        ],
      );
}

class _StatusBreakdownRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
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
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            Text(
              '  (${(pct * 100).toStringAsFixed(0)}%)',
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: AppTheme.border,
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _DashCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _DashCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 15, color: color),
            ),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 20, fontWeight: FontWeight.w800)),
            Text(label,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 9)),
          ]),
        ),
      );
}

class _ChartCard extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  const _ChartCard(
      {required this.title, required this.subtitle, required this.child});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
            const SizedBox(height: 2),
            Text(subtitle,
                style:
                    const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            const SizedBox(height: 14),
            child,
          ],
        ),
      );
}

class _PieLeg extends StatelessWidget {
  final Color color;
  final String label, value;
  const _PieLeg(
      {required this.color, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 13)),
        ]),
      ]);
}

class _ProgDot extends StatelessWidget {
  final Color color;
  final String label;
  const _ProgDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
        ],
      );
}

class _MapDot extends StatelessWidget {
  final Color color;
  final String label;
  const _MapDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
      ]);
}
