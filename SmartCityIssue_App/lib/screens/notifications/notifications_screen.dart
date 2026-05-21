import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/theme.dart';
import '../../providers/issue_provider.dart';
import '../../models/issue_model.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issuesAsync = ref.watch(myIssuesStreamProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Mark all read',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
          ),
        ],
      ),
      body: issuesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (e, _) => const Center(
          child: Text('Failed to load notifications',
              style: TextStyle(color: AppTheme.textSecondary)),
        ),
        data: (issues) {
          // Generate notification events from issues
          final notifications = _buildNotifications(issues);

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.accentLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_none_rounded,
                        size: 44, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 16),
                  const Text('No Notifications Yet',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  const Text('Submit a report to start receiving updates',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/report'),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Report an Issue'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${notifications.length} updates',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12),
                  ),
                );
              }
              final notif = notifications[i - 1];
              return _NotifCard(notif: notif);
            },
          );
        },
      ),
    );
  }

  List<_NotifItem> _buildNotifications(List<IssueModel> issues) {
    final List<_NotifItem> items = [];

    for (final issue in issues) {
      // Submitted notification
      items.add(_NotifItem(
        icon: '📋',
        title: 'Report Received',
        body: '${issue.category} report submitted successfully',
        subtitle: issue.title,
        time: issue.createdAt,
        borderColor: AppTheme.primary,
        isRead: true,
      ));

      // Status change notifications
      if (issue.status == 'In Progress') {
        items.add(_NotifItem(
          icon: '🔵',
          title: 'Status Updated',
          body: 'Your ${issue.category} report is now In Progress',
          subtitle: issue.title,
          time: issue.updatedAt,
          borderColor: AppTheme.inProgressColor,
          isRead: false,
        ));
      } else if (issue.status == 'Resolved') {
        items.add(_NotifItem(
          icon: '✅',
          title: 'Issue Resolved',
          body: '${issue.category} — ${issue.title} has been resolved',
          subtitle: issue.adminNote ?? 'Resolved by municipal authority',
          time: issue.updatedAt,
          borderColor: AppTheme.resolvedColor,
          isRead: true,
        ));
      }
    }

    // Sort by time descending
    items.sort((a, b) => b.time.compareTo(a.time));
    return items.take(20).toList();
  }
}

class _NotifItem {
  final String icon, title, body, subtitle;
  final DateTime time;
  final Color borderColor;
  final bool isRead;

  const _NotifItem({
    required this.icon,
    required this.title,
    required this.body,
    required this.subtitle,
    required this.time,
    required this.borderColor,
    required this.isRead,
  });
}

class _NotifCard extends StatelessWidget {
  final _NotifItem notif;
  const _NotifCard({required this.notif});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: notif.isRead ? AppTheme.cardBg : AppTheme.accentLight,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left color bar
          Container(
            width: 4,
            height: 80,
            decoration: BoxDecoration(
              color: notif.borderColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Icon
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(notif.icon, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(notif.title,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(notif.body,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 3),
                  Text(notif.subtitle,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 10, color: AppTheme.textMuted),
                      const SizedBox(width: 3),
                      Text(timeago.format(notif.time),
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
