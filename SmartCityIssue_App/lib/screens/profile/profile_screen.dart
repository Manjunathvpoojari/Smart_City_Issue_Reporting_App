import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/issue_provider.dart';
import '../../widgets/app_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final issuesAsync = ref.watch(myIssuesStreamProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Profile')),
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
              // ── AVATAR + INFO ──────────────────────────────
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.secondary],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
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
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      profile.name,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    if (profile.isAdmin)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.secondary.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_rounded,
                                size: 13, color: AppTheme.secondary),
                            SizedBox(width: 5),
                            Text(
                              'Admin',
                              style: TextStyle(
                                color: AppTheme.secondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── STATS ──────────────────────────────────────
              Row(
                children: [
                  _StatCard(
                      label: 'Reported', value: '${issues.length}', icon: '📍'),
                  const SizedBox(width: 12),
                  _StatCard(label: 'Resolved', value: '$resolved', icon: '✅'),
                  const SizedBox(width: 12),
                  _StatCard(label: 'Pending', value: '$pending', icon: '⏳'),
                ],
              ),
              const SizedBox(height: 24),

              // ── MENU ITEMS ─────────────────────────────────
              _MenuItem(
                icon: Icons.list_alt_rounded,
                label: 'My Reports',
                onTap: () => context.go('/my-reports'),
              ),
              if (profile.isAdmin)
                _MenuItem(
                  icon: Icons.admin_panel_settings_rounded,
                  label: 'Admin Dashboard',
                  color: AppTheme.secondary,
                  onTap: () => context.go('/admin'),
                ),
              _MenuItem(
                icon: Icons.info_outline_rounded,
                label: 'App Version',
                trailing: Text(
                  AppConstants.appVersion,
                  style: const TextStyle(color: AppTheme.textMuted),
                ),
                onTap: () {},
              ),
              const SizedBox(height: 12),

              // ── SIGN OUT ───────────────────────────────────
              _MenuItem(
                icon: Icons.logout_rounded,
                label: 'Sign Out',
                color: AppTheme.error,
                onTap: () => _signOut(context, ref),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    // Capture navigator before async gap
    // ignore: unused_local_variable
    final navigator = Navigator.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sign Out',
          style: TextStyle(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
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
            child:
                const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Sign out from Supabase
      await ref.read(authServiceProvider).signOut();
      // _AuthNotifier in router.dart listens to auth state change
      // and automatically redirects to /login — no manual navigation needed
    }
  }
}

// ── STAT CARD ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── MENU ITEM ─────────────────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: color ?? AppTheme.textSecondary,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: color ?? AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        trailing: trailing ??
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
