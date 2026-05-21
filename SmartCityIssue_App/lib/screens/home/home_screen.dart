import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/issue_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/issue_provider.dart';
import '../../widgets/app_widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _mapController = MapController();
  String _selectedCategory = 'All';
  bool _showMap = true; // toggle map/list view

  @override
  Widget build(BuildContext context) {
    final issuesAsync = ref.watch(allIssuesStreamProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: issuesAsync.when(
        loading: () => const LoadingWidget(message: 'Loading city data...'),
        error: (e, _) => ErrorRetryWidget(
          message: 'Failed to load issues',
          onRetry: () => ref.invalidate(allIssuesStreamProvider),
        ),
        data: (issues) {
          final filtered = _selectedCategory == 'All'
              ? issues
              : issues.where((i) => i.category == _selectedCategory).toList();

          final pending = issues.where((i) => i.status == 'Pending').length;
          final inProgress =
              issues.where((i) => i.status == 'In Progress').length;
          final resolved = issues.where((i) => i.status == 'Resolved').length;

          return CustomScrollView(
            slivers: [
              // ── App Bar ───────────────────────────────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: AppTheme.primary,
                expandedHeight: 110,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _greeting(profile?.name),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Row(
                                    children: [
                                      Icon(Icons.location_on_rounded,
                                          size: 12, color: Colors.white70),
                                      SizedBox(width: 3),
                                      Text('Shivamogga, Karnataka',
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isAdmin)
                              GestureDetector(
                                onTap: () => context.go('/admin'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.4)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.admin_panel_settings_rounded,
                                          size: 14, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text('Admin',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(0),
                  child: Container(
                    height: 1,
                    color: AppTheme.primary.withOpacity(0.3),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Stats Row ────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        children: [
                          _StatCard(
                            label: 'Total',
                            value: '${issues.length}',
                            icon: Icons.location_on_rounded,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 10),
                          _StatCard(
                            label: 'Pending',
                            value: '$pending',
                            icon: Icons.hourglass_empty_rounded,
                            color: AppTheme.pendingColor,
                          ),
                          const SizedBox(width: 10),
                          _StatCard(
                            label: 'Active',
                            value: '$inProgress',
                            icon: Icons.autorenew_rounded,
                            color: AppTheme.inProgressColor,
                          ),
                          const SizedBox(width: 10),
                          _StatCard(
                            label: 'Resolved',
                            value: '$resolved',
                            icon: Icons.check_circle_rounded,
                            color: AppTheme.resolvedColor,
                          ),
                        ],
                      ),
                    ),

                    // ── Category Filter ───────────────────────────
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children:
                            ['All', ...AppConstants.categories].map((cat) {
                          final sel = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedCategory = cat),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color:
                                      sel ? AppTheme.primary : AppTheme.cardBg,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: sel
                                        ? AppTheme.primary
                                        : AppTheme.border,
                                  ),
                                ),
                                child: Text(
                                  cat == 'All'
                                      ? 'All'
                                      : '${AppConstants.categoryIcons[cat]} $cat',
                                  style: TextStyle(
                                    color: sel
                                        ? Colors.white
                                        : AppTheme.textSecondary,
                                    fontSize: 12,
                                    fontWeight:
                                        sel ? FontWeight.w700 : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // ── Map / List Toggle ─────────────────────────
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text('City Map',
                              style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                          const Spacer(),
                          _ToggleButton(
                            label: 'Map',
                            icon: Icons.map_rounded,
                            active: _showMap,
                            onTap: () => setState(() => _showMap = true),
                          ),
                          const SizedBox(width: 6),
                          _ToggleButton(
                            label: 'List',
                            icon: Icons.list_rounded,
                            active: !_showMap,
                            onTap: () => setState(() => _showMap = false),
                          ),
                        ],
                      ),
                    ),

                    // ── Map ───────────────────────────────────────
                    const SizedBox(height: 10),
                    if (_showMap)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 240,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.border),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: const LatLng(
                                    AppConstants.defaultLat,
                                    AppConstants.defaultLng),
                                initialZoom: AppConstants.defaultZoom,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName:
                                      'com.example.smart_city',
                                ),
                                MarkerLayer(
                                  markers: filtered
                                      .map((i) => _buildMarker(i))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // ── Map Legend ────────────────────────────────
                    if (_showMap) ...[
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _LegendDot(
                                color: AppTheme.pendingColor, label: 'Pending'),
                            const SizedBox(width: 14),
                            _LegendDot(
                                color: AppTheme.inProgressColor,
                                label: 'In Progress'),
                            const SizedBox(width: 14),
                            _LegendDot(
                                color: AppTheme.resolvedColor,
                                label: 'Resolved'),
                          ],
                        ),
                      ),
                    ],

                    // ── Recent Issues ─────────────────────────────
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text('Recent Issues',
                              style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => context.go('/my-reports'),
                            child: const Text('View all',
                                style: TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: EmptyState(
                          emoji: '🎉',
                          title: 'No Issues Found',
                          subtitle: 'No issues match the selected filter.',
                        ),
                      )
                    else
                      ...filtered.take(5).map((issue) => Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                            child: _IssueListCard(
                              issue: issue,
                              onTap: () => context.push('/issue/${issue.id}',
                                  extra: issue),
                            ),
                          )),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/report'),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Report Issue',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        elevation: 4,
      ),
    );
  }

  Marker _buildMarker(IssueModel issue) {
    final color = AppTheme.statusColor(issue.status);
    final emoji = AppConstants.categoryIcons[issue.category] ?? '📌';
    return Marker(
      point: LatLng(issue.latitude, issue.longitude),
      width: 44,
      height: 54,
      child: GestureDetector(
        onTap: () => context.push('/issue/${issue.id}', extra: issue),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.statusBgColor(issue.status),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2.5),
                boxShadow: [
                  BoxShadow(
                      color: color.withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 3)),
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
          ],
        ),
      ),
    );
  }

  String _greeting(String? name) {
    final hour = DateTime.now().hour;
    final part = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';
    return name != null && name.isNotEmpty
        ? '$part, ${name.split(' ').first} 👋'
        : '$part 👋';
  }
}

// ── Stat Card ──────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 14, color: color),
            ),
            const SizedBox(height: 5),
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 18, fontWeight: FontWeight.w800)),
            Text(label,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

// ── Toggle Button ──────────────────────────────────────────────────────────────

class _ToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: active ? AppTheme.primary : AppTheme.border),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 13,
                color: active ? Colors.white : AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: active ? Colors.white : AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── Map Legend Dot ─────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      ],
    );
  }
}

// ── Issue List Card ────────────────────────────────────────────────────────────

class _IssueListCard extends StatelessWidget {
  final IssueModel issue;
  final VoidCallback onTap;

  const _IssueListCard({required this.issue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.statusColor(issue.status);
    final statusBg = AppTheme.statusBgColor(issue.status);
    final catIcon = AppConstants.categoryIcons[issue.category] ?? '📌';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Category dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$catIcon  ${issue.title}',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    issue.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 11, color: AppTheme.textMuted),
                const SizedBox(width: 3),
                Text(
                  timeago.format(issue.createdAt),
                  style:
                      const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.category_rounded,
                    size: 11, color: AppTheme.textMuted),
                const SizedBox(width: 3),
                Text(
                  issue.category,
                  style:
                      const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                ),
              ],
            ),
            // Progress bar for In Progress items
            if (issue.status == 'In Progress') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.6,
                        backgroundColor: AppTheme.border,
                        color: AppTheme.inProgressColor,
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('60%',
                      style: TextStyle(
                          color: AppTheme.inProgressColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
