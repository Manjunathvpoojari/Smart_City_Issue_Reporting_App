import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme.dart';
import '../../services/issue_service.dart';
import '../../services/location_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/app_widgets.dart';

class ReportIssueScreen extends ConsumerStatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  ConsumerState<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends ConsumerState<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  File? _image;
  String _category = AppConstants.categories.first;
  double? _lat;
  double? _lng;
  String? _address;
  bool _loadingLocation = false;
  bool _submitting = false;

  final _picker = ImagePicker();
  final _locationService = LocationService();
  final _storageService = StorageService();
  final _issueService = IssueService();

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() => _loadingLocation = true);
    final result = await _locationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _lat = result?.latitude;
        _lng = result?.longitude;
        _address = result?.address;
        _loadingLocation = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final l10n = context.l10n;
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (picked != null) {
        setState(() => _image = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.failedToLoad}: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
    if (mounted) Navigator.pop(context);
  }

  void _showImagePicker() {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.addPhoto,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded,
                    color: AppTheme.primary),
                title: Text(l10n.camera,
                    style: const TextStyle(color: AppTheme.textPrimary)),
                onTap: () => _pickImage(ImageSource.camera),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded,
                    color: AppTheme.secondary),
                title: Text(l10n.gallery,
                    style: const TextStyle(color: AppTheme.textPrimary)),
                onTap: () => _pickImage(ImageSource.gallery),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) return;

    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.locationUnavailable),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      String? imageUrl;
      if (_image != null) {
        imageUrl = await _storageService.uploadIssueImage(_image!);
      }

      final issue = await _issueService.submitIssue(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _category,
        latitude: _lat!,
        longitude: _lng!,
        imageUrl: imageUrl,
      );

      if (mounted) {
        if (issue != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${l10n.submitSuccess}'),
              backgroundColor: AppTheme.success,
            ),
          );
          context.go('/my-reports');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.submitFailed),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.failedToLoad}: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(l10n.reportIssue),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── PHOTO PICKER ─────────────────────────────────────
            GestureDetector(
              onTap: _showImagePicker,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _image != null ? AppTheme.primary : AppTheme.border,
                  ),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_image!, fit: BoxFit.cover),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => setState(() => _image = null),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close_rounded,
                                      color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                color: AppTheme.primary, size: 28),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.tapToAddPhoto,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.photoRecommended,
                            style: const TextStyle(
                                color: AppTheme.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // ── CATEGORY ─────────────────────────────────────────
            Text(
              l10n.category,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: AppConstants.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = AppConstants.categories[i];
                  final selected = _category == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primary.withOpacity(0.15)
                            : AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? AppTheme.primary : AppTheme.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            AppConstants.categoryIcons[cat] ?? '📌',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat,
                            style: TextStyle(
                              color: selected
                                  ? AppTheme.primary
                                  : AppTheme.textSecondary,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w400,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // ── TITLE ─────────────────────────────────────────────
            TextFormField(
              controller: _titleCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: l10n.issueTitle,
                hintText: l10n.issueTitleHint,
                prefixIcon:
                    const Icon(Icons.title_rounded, color: AppTheme.textMuted),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.issueTitle : null,
              maxLength: 80,
            ),
            const SizedBox(height: 16),

            // ── DESCRIPTION ───────────────────────────────────────
            TextFormField(
              controller: _descCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: l10n.description,
                hintText: l10n.descriptionHint,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 64),
                  child: Icon(Icons.description_rounded,
                      color: AppTheme.textMuted),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              maxLength: 300,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.description : null,
            ),
            const SizedBox(height: 16),

            // ── LOCATION ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _lat != null ? AppTheme.success : AppTheme.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _lat != null
                        ? Icons.location_on_rounded
                        : Icons.location_off_rounded,
                    color: _lat != null ? AppTheme.success : AppTheme.textMuted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _loadingLocation
                        ? Row(children: [
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.detectingLocation,
                              style: const TextStyle(
                                  color: AppTheme.textMuted, fontSize: 13),
                            ),
                          ])
                        : Text(
                            _address ??
                                (_lat != null
                                    ? '${l10n.locationDetected} ✓'
                                    : l10n.locationUnavailable),
                            style: TextStyle(
                              color: _lat != null
                                  ? AppTheme.textPrimary
                                  : AppTheme.textMuted,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                          ),
                  ),
                  if (!_loadingLocation)
                    TextButton(
                      onPressed: _fetchLocation,
                      child: Text(l10n.retryLocation,
                          style: const TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── SUBMIT ────────────────────────────────────────────
            GradientButton(
              label: l10n.submit,
              icon: Icons.send_rounded,
              onPressed: _submitting ? null : _submit,
              isLoading: _submitting,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
