import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/issue_model.dart';
import '../../providers/issue_provider.dart';
import '../../services/issue_service.dart';
import '../../widgets/app_widgets.dart';

class AdminIssueDetailScreen extends ConsumerStatefulWidget {
  final IssueModel issue;
  const AdminIssueDetailScreen({super.key, required this.issue});

  @override
  ConsumerState<AdminIssueDetailScreen> createState() => _AdminIssueDetailScreenState();
}

class _AdminIssueDetailScreenState extends ConsumerState<AdminIssueDetailScreen> {
  late String _selectedStatus;
  final _noteCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.issue.status;
    _noteCtrl.text = widget.issue.adminNote ?? '';
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveStatus() async {
    if (_selectedStatus == widget.issue.status && _noteCtrl.text.trim() == (widget.issue.adminNote ?? '')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes to save'), backgroundColor: AppTheme.warning),
      );
      return;
    }

    setState(() => _saving = true);
    final success = await IssueService().updateIssueStatus(
      issueId: widget.issue.id,
      oldStatus: widget.issue.status,
      newStatus: _selectedStatus,
      adminNote: _noteCtrl.text.trim(),
    );

    if (mounted) {
      setState(() => _saving = false);
      if (success) {
        ref.invalidate(adminIssuesProvider);
        ref.invalidate(issueCountsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Issue updated successfully'),
              backgroundColor: AppTheme.success),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update. Try again.'),
              backgroundColor: AppTheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final issue = widget.issue;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Issue Detail'),
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _saveStatus,
            icon: _saving
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_rounded, size: 18),
            label: const Text('Save'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Reporter info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (issue.reporterName?.isNotEmpty == true)
                          ? issue.reporterName![0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(issue.reporterName ?? 'Unknown', style: const TextStyle(
                        color: AppTheme.textPrimary, fontWeight: FontWeight.w700,
                      )),
                      Text(issue.reporterEmail ?? '', style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12,
                      )),
                    ],
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(issue.createdAt),
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Issue image
          if (issue.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: issue.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),

          // Title + category
          Text(issue.title, style: const TextStyle(
            color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w800,
          )),
          const SizedBox(height: 8),
          Row(children: [
            CategoryChip(category: issue.category),
            const SizedBox(width: 8),
            const Icon(Icons.access_time_rounded, size: 13, color: AppTheme.textMuted),
            const SizedBox(width: 4),
            Text(
              DateFormat('dd MMM yyyy, hh:mm a').format(issue.createdAt),
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ]),
          const SizedBox(height: 12),
          Text(issue.description, style: const TextStyle(
            color: AppTheme.textSecondary, fontSize: 14, height: 1.6,
          )),
          const SizedBox(height: 20),

          // Mini map
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 160,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(issue.latitude, issue.longitude),
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
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
          const SizedBox(height: 24),

          // Status update section
          const Text('Update Status', style: TextStyle(
            color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700,
          )),
          const SizedBox(height: 12),

          // Status radio buttons
          ...[ AppConstants.statusPending, AppConstants.statusInProgress, AppConstants.statusResolved]
              .map((status) {
            final color = AppTheme.statusColor(status);
            final selected = _selectedStatus == status;
            return GestureDetector(
              onTap: () => setState(() => _selectedStatus = status),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: selected ? color.withOpacity(0.1) : AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: selected ? color : AppTheme.border, width: selected ? 2 : 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                      color: selected ? color : AppTheme.textMuted, size: 20,
                    ),
                    const SizedBox(width: 12),
                    StatusBadge(status: status),
                    if (issue.status == status) ...[
                      const SizedBox(width: 8),
                      const Text('(current)', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    ],
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Resolution note
          TextField(
            controller: _noteCtrl,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Resolution Note (optional)',
              hintText: 'Describe the action taken to resolve this issue...',
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 56),
                child: Icon(Icons.note_rounded, color: AppTheme.textMuted),
              ),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            maxLength: 300,
          ),
          const SizedBox(height: 24),

          GradientButton(
            label: 'Save Changes',
            icon: Icons.save_rounded,
            onPressed: _saveStatus,
            isLoading: _saving,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
