import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme.dart';
import '../../models/issue_model.dart';
import '../../providers/issue_provider.dart';
import '../../providers/upvote_provider.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/upvote_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

class CityIssuesScreen extends ConsumerStatefulWidget {
  const CityIssuesScreen({super.key});

  @override
  ConsumerState<CityIssuesScreen> createState() => _CityIssuesScreenState();
}

class _CityIssuesScreenState extends ConsumerState<CityIssuesScreen> {
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  bool _sortByUpvotes = false;

  @override
  void initState() {
    super.initState();
    // Pre-load the user's voted issue IDs once when screen opens
    // so every IssueCard knows immediately if it's voted or not
    ref.read(myUpvotedIssueIdsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final issuesAsync = ref.watch(allIssuesStreamProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(l10n.allCityIssues),
        actions: [
          // Sort toggle
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _sortByUpvotes = !_sortByUpvotes),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _sortByUpvotes
                      ? Colors.white.withOpacity(0.25)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _sortByUpvotes
                          ? Icons.arrow_upward_rounded
                          : Icons.access_time_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _sortByUpvotes ? 'Top Voted' : 'Newest',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: issuesAsync.when(
        loading: () => LoadingWidget(message: l10n.loadingIssues),
        error: (e, _) => ErrorRetryWidget(
          message: l10n.failedToLoad,
          onRetry: () => ref.invalidate(allIssuesStreamProvider),
        ),
        data: (allIssues) {
          // ── Apply filters ──────────────────────────────
          var filtered = allIssues.where((i) {
            final catMatch =
                _selectedCategory == 'All' || i.category == _selectedCategory;
            final statusMatch =
                _selectedStatus == 'All' || i.status == _selectedStatus;
            return catMatch && statusMatch;
          }).toList();

          // ── Apply sort ─────────────────────────────────
          if (_sortByUpvotes) {
            filtered.sort((a, b) => b.upvotes.compareTo(a.upvotes));
          }

          return Column(
            children: [
              // ── Filter bar ─────────────────────────────
              _buildFilterBar(allIssues),
              const Divider(height: 1),

              // ── Stats strip ────────────────────────────
              _buildStatsStrip(allIssues),
              const Divider(height: 1),

              // ── Issue list ─────────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? EmptyState(
                        emoji: '🏙️',
                        title: l10n.noIssuesFound,
                        subtitle: 'No issues match the selected filters.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _VotableIssueCard(
                          issue: filtered[i],
                          rank: _sortByUpvotes && filtered[i].upvotes > 0
                              ? i + 1
                              : null,
                          onTap: () => context.push('/issue/${filtered[i].id}',
                              extra: filtered[i]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(List<IssueModel> issues) {
    return Container(
      color: AppTheme.cardBg,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category chips
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['All', ...AppConstants.categories].map((cat) {
                final sel = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: sel ? AppTheme.primary : AppTheme.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel ? AppTheme.primary : AppTheme.border,
                        ),
                      ),
                      child: Text(
                        cat == 'All'
                            ? 'All'
                            : '${AppConstants.categoryIcons[cat]} $cat',
                        style: TextStyle(
                          color: sel ? Colors.white : AppTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Status chips
          SizedBox(
            height: 28,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                'All',
                AppConstants.statusPending,
                AppConstants.statusInProgress,
                AppConstants.statusResolved,
              ].map((s) {
                final sel = _selectedStatus == s;
                final color =
                    s == 'All' ? AppTheme.primary : AppTheme.statusColor(s);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedStatus = s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color:
                            sel ? color.withOpacity(0.12) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel ? color : AppTheme.border,
                        ),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          color: sel ? color : AppTheme.textSecondary,
                          fontSize: 10,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsStrip(List<IssueModel> issues) {
    final total = issues.length;
    final pending = issues.where((i) => i.status == 'Pending').length;
    final inProgress = issues.where((i) => i.status == 'In Progress').length;
    final resolved = issues.where((i) => i.status == 'Resolved').length;
    final totalVotes = issues.fold<int>(0, (sum, i) => sum + i.upvotes);

    return Container(
      color: AppTheme.cardBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _StripStat(label: 'Total', value: '$total', color: AppTheme.primary),
          _divider(),
          _StripStat(
              label: 'Pending',
              value: '$pending',
              color: AppTheme.pendingColor),
          _divider(),
          _StripStat(
              label: 'Active',
              value: '$inProgress',
              color: AppTheme.inProgressColor),
          _divider(),
          _StripStat(
              label: 'Resolved',
              value: '$resolved',
              color: AppTheme.resolvedColor),
          _divider(),
          _StripStat(
              label: 'Votes',
              value: '$totalVotes',
              color: const Color(0xFF6366F1)),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: AppTheme.border,
      );
}

// ── Strip stat ─────────────────────────────────────────────────────────────

class _StripStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StripStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 16, fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 9)),
        ],
      ),
    );
  }
}

// ── Votable Issue Card ─────────────────────────────────────────────────────
// Like IssueCard but with a prominent upvote section and rank badge.
// Used only in CityIssuesScreen so it doesn't affect MyReports layout.

class _VotableIssueCard extends ConsumerWidget {
  final IssueModel issue;
  final int? rank;
  final VoidCallback onTap;

  const _VotableIssueCard({
    required this.issue,
    required this.onTap,
    this.rank,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: issue.upvotes >= 10
                ? const Color(0xFF6366F1).withOpacity(0.3)
                : AppTheme.border,
            width: issue.upvotes >= 10 ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ─────────────────────────────────────
            if (issue.imageUrl != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                child: CachedNetworkImage(
                  imageUrl: issue.imageUrl!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Shimmer.fromColors(
                    baseColor: AppTheme.border,
                    highlightColor: AppTheme.cardBg,
                    child: Container(height: 140, color: AppTheme.border),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 140,
                    color: AppTheme.accentLight,
                    child: const Center(
                      child: Icon(Icons.image_not_supported_outlined,
                          color: AppTheme.primary, size: 32),
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title row ──────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rank badge when sorted by upvotes
                      if (rank != null) ...[
                        Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.only(right: 8, top: 1),
                          decoration: BoxDecoration(
                            color: _rankColor(rank!).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$rank',
                              style: TextStyle(
                                color: _rankColor(rank!),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                      Expanded(
                        child: Text(
                          issue.title,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(status: issue.status, small: true),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // ── Description ────────────────────────
                  Text(
                    issue.description,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // ── Meta row ───────────────────────────
                  Row(
                    children: [
                      CategoryChip(category: issue.category, small: true),
                      const SizedBox(width: 8),
                      const Icon(Icons.access_time_rounded,
                          size: 11, color: AppTheme.textMuted),
                      const SizedBox(width: 3),
                      Text(
                        timeago.format(issue.createdAt),
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  // ── Upvote row ─────────────────────────
                  // GestureDetector wrapper stops the card
                  // onTap from firing when tapping the vote button
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        behavior: HitTestBehavior.opaque,
                        child: UpvoteButton(
                          issue: issue,
                          compact: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      PriorityBadge(upvotes: issue.upvotes, small: true),
                      const Spacer(),
                      // Reporter name — transparency
                      if (issue.reporterName != null) ...[
                        const Icon(Icons.person_outline_rounded,
                            size: 11, color: AppTheme.textMuted),
                        const SizedBox(width: 3),
                        Text(
                          issue.reporterName!,
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFD97706);
      case 2:
        return const Color(0xFF6B7280);
      case 3:
        return const Color(0xFFB45309);
      default:
        return AppTheme.textMuted;
    }
  }
}
