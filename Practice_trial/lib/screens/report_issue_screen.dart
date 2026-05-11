import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});
  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  int _selectedCat = 0;
  final _descCtrl =
      TextEditingController(text: 'Large pothole near Gandhi Circle...');

  final List<Map<String, String>> _categories = [
    {'emoji': '🕳️', 'label': 'Pothole'},
    {'emoji': '🚰', 'label': 'Drainage'},
    {'emoji': '🗑️', 'label': 'Garbage'},
    {'emoji': '💡', 'label': 'Lighting'},
    {'emoji': '⚠️', 'label': 'Other'},
  ];

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          ScAppBar(
            title: 'Report an Issue',
            showBack: true,
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo
                  const FieldLabel('PHOTO'),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      height: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5EE),
                        border: Border.all(
                            color: AppColors.accent,
                            width: 1.5,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('📷', style: TextStyle(fontSize: 30)),
                          SizedBox(height: 6),
                          Text('Tap to capture / upload',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Category
                  const FieldLabel('CATEGORY'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_categories.length, (i) {
                      final active = _selectedCat == i;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCat = i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: active ? AppColors.accent : Colors.white,
                            border: Border.all(
                                color: active
                                    ? AppColors.accent
                                    : AppColors.border),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_categories[i]['emoji']} ${_categories[i]['label']}',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: active ? Colors.white : AppColors.muted),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 18),

                  // Description
                  const FieldLabel('DESCRIPTION'),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 13),
                    decoration: scInputDecoration('Describe the issue...'),
                  ),
                  const SizedBox(height: 18),

                  // Location
                  const FieldLabel('LOCATION (AUTO-DETECTED)'),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Text('📍', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Vijayanagar 3rd Stage, Mysuru',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF166534))),
                            Text('12.3052° N, 76.6551° E',
                                style: TextStyle(
                                    fontSize: 11, color: AppColors.muted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  PrimaryButton(
                    label: 'Submit Report',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Report submitted successfully!'),
                          backgroundColor: AppColors.accent,
                        ),
                      );
                      Navigator.pop(context);
                    },
                  ),
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
