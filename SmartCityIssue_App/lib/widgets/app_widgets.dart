import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../core/constants.dart';
import '../core/theme.dart';
import '../models/issue_model.dart';

// ── STATUS BADGE ─────────────────────────────────────────────────────────────

class StatusBadge extends StatelessWidget {
  final String status;
  final bool small;
  const StatusBadge({super.key, required this.status, this.small = false});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.statusColor(status);
    final icon = switch (status) {
      'Pending' => Icons.hourglass_empty_rounded,
      'In Progress' => Icons.autorenew_rounded,
      'Resolved' => Icons.check_circle_outline_rounded,
      _ => Icons.info_outline,
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: small ? 10 : 13, color: color),
          SizedBox(width: small ? 4 : 5),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: small ? 10 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── CATEGORY CHIP ─────────────────────────────────────────────────────────────

class CategoryChip extends StatelessWidget {
  final String category;
  final bool small;
  const CategoryChip({super.key, required this.category, this.small = false});

  @override
  Widget build(BuildContext context) {
    final icon = AppConstants.categoryIcons[category] ?? '📌';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: AppTheme.border.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: TextStyle(fontSize: small ? 11 : 13)),
          SizedBox(width: small ? 4 : 5),
          Text(
            category,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: small ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── ISSUE CARD ────────────────────────────────────────────────────────────────

class IssueCard extends StatelessWidget {
  final IssueModel issue;
  final VoidCallback onTap;
  const IssueCard({super.key, required this.issue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (issue.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: CachedNetworkImage(
                  imageUrl: issue.imageUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _shimmer(),
                  errorWidget: (_, __, ___) => _placeholder(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          issue.title,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      StatusBadge(status: issue.status, small: true),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    issue.description,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CategoryChip(category: issue.category, small: true),
                      const Spacer(),
                      const Icon(Icons.access_time_rounded, size: 12, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        timeago.format(issue.createdAt),
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                      ),
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

  Widget _shimmer() => Shimmer.fromColors(
    baseColor: AppTheme.border,
    highlightColor: AppTheme.cardBg,
    child: Container(height: 160, color: AppTheme.border),
  );

  Widget _placeholder() => Container(
    height: 160,
    color: AppTheme.background,
    child: const Center(
      child: Icon(Icons.image_not_supported_outlined, color: AppTheme.textMuted, size: 36),
    ),
  );
}

// ── LOADING WIDGET ────────────────────────────────────────────────────────────

class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.primary),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: const TextStyle(color: AppTheme.textSecondary)),
          ],
        ],
      ),
    );
  }
}

// ── EMPTY STATE ───────────────────────────────────────────────────────────────

class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Widget? action;
  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}

// ── ERROR WIDGET ──────────────────────────────────────────────────────────────

class ErrorRetryWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorRetryWidget({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppTheme.textMuted, size: 48),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ── GRADIENT BUTTON ────────────────────────────────────────────────────────────

class GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
                    Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
        ),
      ),
    );
  }
}
