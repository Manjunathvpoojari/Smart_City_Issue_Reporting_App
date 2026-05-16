import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/issue_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/app_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final issuesAsync = ref.watch(myIssuesStreamProvider);
    final lang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(lang.t('profile'))),
      body: profileAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorRetryWidget(
          message: 'Failed to load profile',
          onRetry: () => ref.invalidate(userProfileProvider),
        ),
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Profile not loaded',
                      style: TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(userProfileProvider),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final issues = issuesAsync.valueOrNull ?? [];
          final resolved = issues.where((i) => i.status == 'Resolved').length;
          final pending = issues.where((i) => i.status == 'Pending').length;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Avatar ──────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.primaryLight],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          profile.name.isNotEmpty
                              ? profile.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(profile.name,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(profile.email,
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 14)),
                    const SizedBox(height: 10),
                    if (profile.isAdmin)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.primary.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_rounded,
                                size: 13, color: AppTheme.primary),
                            SizedBox(width: 5),
                            Text('Admin',
                                style: TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Stats ────────────────────────────────────
              Row(
                children: [
                  _StatCard(
                      label: lang.t('reported'),
                      value: '${issues.length}',
                      icon: '📍'),
                  const SizedBox(width: 12),
                  _StatCard(
                      label: lang.t('resolved'), value: '$resolved', icon: '✅'),
                  const SizedBox(width: 12),
                  _StatCard(
                      label: lang.t('pending'), value: '$pending', icon: '⏳'),
                ],
              ),
              const SizedBox(height: 24),

              // ── Menu Items ───────────────────────────────
              _MenuItem(
                icon: Icons.list_alt_rounded,
                label: lang.t('my_reports'),
                onTap: () => context.go('/my-reports'),
              ),
              if (profile.isAdmin)
                _MenuItem(
                  icon: Icons.admin_panel_settings_rounded,
                  label: lang.t('admin_dashboard'),
                  color: AppTheme.primary,
                  onTap: () => context.go('/admin'),
                ),

              // ── Language Selector ────────────────────────
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: ListTile(
                  leading: const Icon(Icons.language_rounded,
                      color: AppTheme.textSecondary, size: 22),
                  title: Text(lang.t('language'),
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(lang.flag, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(lang.displayName,
                          style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12)),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppTheme.textMuted),
                    ],
                  ),
                  onTap: () => _showLanguagePicker(context, ref, lang),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              _MenuItem(
                icon: Icons.info_outline_rounded,
                label: lang.t('app_version'),
                trailing: Text(AppConstants.appVersion,
                    style: const TextStyle(color: AppTheme.textMuted)),
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _MenuItem(
                icon: Icons.logout_rounded,
                label: lang.t('sign_out'),
                color: AppTheme.error,
                onTap: () => _signOut(context, ref, lang),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  void _showLanguagePicker(
      BuildContext context, WidgetRef ref, AppLanguage current) {
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
            Text(current.t('select_language'),
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
            const SizedBox(height: 16),
            ...AppLanguage.values.map((language) {
              final isSelected = language == current;
              return GestureDetector(
                onTap: () {
                  ref.read(languageProvider.notifier).setLanguage(language);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppTheme.accentLight : AppTheme.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : AppTheme.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(language.flag, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Text(language.displayName,
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.textPrimary,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w400,
                            fontSize: 15,
                          )),
                      const Spacer(),
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded,
                            color: AppTheme.primary, size: 20),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(
      BuildContext context, WidgetRef ref, AppLanguage lang) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(lang.t('sign_out'),
            style: const TextStyle(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Text(lang.t('sign_out_confirm'),
            style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(lang.t('sign_out'),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(authServiceProvider).signOut();
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, icon;
  const _StatCard(
      {required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
            Text(label,
                style:
                    const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
          ]),
        ),
      );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Widget? trailing;
  const _MenuItem(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.color,
      this.trailing});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: ListTile(
          leading: Icon(icon, color: color ?? AppTheme.textSecondary, size: 22),
          title: Text(label,
              style: TextStyle(
                  color: color ?? AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
          trailing: trailing ??
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textMuted),
          onTap: onTap,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
}
