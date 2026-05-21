import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/shared_widgets.dart';
import '../../models/issue.dart';

class AdminManageIssueScreen extends StatefulWidget {
  final Issue issue;
  const AdminManageIssueScreen({super.key, required this.issue});
  @override
  State<AdminManageIssueScreen> createState() => _AdminManageIssueScreenState();
}

class _AdminManageIssueScreenState extends State<AdminManageIssueScreen> {
  String _status = 'In Progress';
  late final TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    _status = widget.issue.statusLabel == 'Pending' ? 'In Progress' : widget.issue.statusLabel;
    _noteCtrl = TextEditingController(
        text: 'Crew dispatched. Repair scheduled for May 5...');
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          AdminAppBar(
            title: 'Manage Issue',
            showBack: true,
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Issue image
                  Container(
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFD1FAE5), Color(0xFFA7F3D0)]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(widget.issue.categoryEmoji,
                          style: const TextStyle(fontSize: 44)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(widget.issue.title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(
                    'Reported by ${widget.issue.reportedBy ?? "—"} · ${widget.issue.date ?? "—"} · #${widget.issue.id}',
                    style: const TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                  const SizedBox(height: 10),

                  // Location chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '📍 12.3052° N, 76.6551° E · Vijayanagar',
                      style: TextStyle(fontSize: 11, color: Color(0xFF166534)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status dropdown
                  const FieldLabel('UPDATE STATUS'),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _status,
                        isExpanded: true,
                        items: ['Pending', 'In Progress', 'Resolved']
                            .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s,
                                    style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (v) => setState(() => _status = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Note
                  const FieldLabel('RESOLUTION NOTE'),
                  TextField(
                    controller: _noteCtrl,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 13),
                    decoration: scInputDecoration('Add resolution notes...'),
                  ),
                  const SizedBox(height: 18),

                  PrimaryButton(
                    label: 'Save Changes',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Issue updated successfully!'),
                          backgroundColor: AppColors.accent,
                        ),
                      );
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 10),
                  SecondaryButton(label: 'View on Map', onTap: () {}),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
