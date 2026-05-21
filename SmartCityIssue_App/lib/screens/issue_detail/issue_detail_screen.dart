import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/issue_model.dart';
import '../../models/status_history_model.dart';
import '../../services/issue_service.dart';
import '../../widgets/app_widgets.dart';

class IssueDetailScreen extends ConsumerStatefulWidget {
  final IssueModel issue;
  const IssueDetailScreen({super.key, required this.issue});

  @override
  ConsumerState<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends ConsumerState<IssueDetailScreen> {
  List<StatusHistoryModel> _history = [];
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await IssueService().getStatusHistory(widget.issue.id);
    if (mounted) setState(() { _history = history; _loadingHistory = false; });
  }

  @override
  Widget build(BuildContext context) {
    final issue = widget.issue;
    final statusColor = AppTheme.statusColor(issue.status);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // Hero image app bar
          SliverAppBar(
            expandedHeight: issue.imageUrl != null ? 260 : 120,
            pinned: true,
            backgroundColor: AppTheme.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: issue.imageUrl != null
                  ? CachedNetworkImage(imageUrl: issue.imageUrl!, fit: BoxFit.cover)
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [statusColor.withOpacity(0.3), AppTheme.surface],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          AppConstants.categoryIcons[issue.category] ?? '📌',
                          style: const TextStyle(fontSize: 64),
                        ),
                      ),
                    ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(issue.title, style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w800,
                        )),
                      ),
                      const SizedBox(width: 12),
                      StatusBadge(status: issue.status),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      CategoryChip(category: issue.category),
                      const SizedBox(width: 10),
                      const Icon(Icons.access_time_rounded, size: 13, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd MMM yyyy, hh:mm a').format(issue.createdAt),
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  _sectionTitle('Description'),
                  const SizedBox(height: 8),
                  Text(issue.description, style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 14, height: 1.6,
                  )),
                  const SizedBox(height: 20),

                  // Admin note
                  if (issue.adminNote != null && issue.adminNote!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.success.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.success, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Admin Note', style: TextStyle(
                                  color: AppTheme.success, fontWeight: FontWeight.w700, fontSize: 12,
                                )),
                                const SizedBox(height: 4),
                                Text(issue.adminNote!, style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 13, height: 1.5,
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Map
                  _sectionTitle('Location'),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      height: 180,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(issue.latitude, issue.longitude),
                          initialZoom: 15,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.smartcity.app',
                          ),
                          MarkerLayer(markers: [
                            Marker(
                              point: LatLng(issue.latitude, issue.longitude),
                              child: const Icon(Icons.location_pin, color: AppTheme.error, size: 36),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Status timeline
                  _sectionTitle('Status History'),
                  const SizedBox(height: 12),
                  if (_loadingHistory)
                    const Center(child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2))
                  else if (_history.isEmpty)
                    const Text('No status updates yet.', style: TextStyle(color: AppTheme.textMuted, fontSize: 13))
                  else
                    ..._history.asMap().entries.map((entry) {
                      final h = entry.value;
                      final isLast = entry.key == _history.length - 1;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 14, height: 14,
                                decoration: BoxDecoration(
                                  color: AppTheme.statusColor(h.newStatus),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              if (!isLast)
                                Container(width: 2, height: 40, color: AppTheme.border),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${h.oldStatus} → ${h.newStatus}',
                                    style: TextStyle(
                                      color: AppTheme.statusColor(h.newStatus),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'By ${h.adminName ?? 'Admin'} · ${DateFormat('dd MMM, hh:mm a').format(h.changedAt)}',
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title, style: const TextStyle(
    color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700,
  ));
}
