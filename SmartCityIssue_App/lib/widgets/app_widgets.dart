import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../core/constants.dart';
import '../core/theme.dart';
import '../models/issue_model.dart';

// ── STATUS BADGE ──────────────────────────────────────────────────────────────

class StatusBadge extends StatelessWidget {
  final String status;
  final bool small;
  const StatusBadge({super.key, required this.status, this.small = false});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.statusColor(status);
    final bg = AppTheme.statusBgColor(status);
    final icon = switch (status) {
      'Pending' => Icons.hourglass_empty_rounded,
      'In Progress' => Icons.autorenew_rounded,
      'Resolved' => Icons.check_circle_outline_rounded,
      _ => Icons.info_outline,
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 7 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: small ? 10 : 12, color: color),
          SizedBox(width: small ? 3 : 5),
          Text(status,
              style: TextStyle(
                color: color,
                fontSize: small ? 9 : 11,
                fontWeight: FontWeight.w700,
              )),
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
        horizontal: small ? 7 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: AppTheme.accentLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: TextStyle(fontSize: small ? 11 : 13)),
          SizedBox(width: small ? 3 : 5),
          Text(category,
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: small ? 9 : 11,
                fontWeight: FontWeight.w600,
              )),
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
            if (issue.imageUrl != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                child: CachedNetworkImage(
                  imageUrl: issue.imageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _shimmer(),
                  errorWidget: (_, __, ___) => _placeholder(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(issue.title,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      StatusBadge(status: issue.status, small: true),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(issue.description,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CategoryChip(category: issue.category, small: true),
                      const Spacer(),
                      const Icon(Icons.access_time_rounded,
                          size: 11, color: AppTheme.textMuted),
                      const SizedBox(width: 3),
                      Text(timeago.format(issue.createdAt),
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 11)),
                    ],
                  ),
                  // Progress bar for In Progress
                  if (issue.status == 'In Progress') ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.6,
                        backgroundColor: AppTheme.border,
                        color: AppTheme.inProgressColor,
                        minHeight: 4,
                      ),
                    ),
                  ],
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
        child: Container(height: 150, color: AppTheme.border),
      );

  Widget _placeholder() => Container(
        height: 150,
        color: AppTheme.accentLight,
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined,
              color: AppTheme.primary, size: 36),
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
          const CircularProgressIndicator(
              color: AppTheme.primary, strokeWidth: 3),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13)),
          ],
        ],
      ),
    );
  }
}

// ── EMPTY STATE ───────────────────────────────────────────────────────────────

class EmptyState extends StatelessWidget {
  final String emoji, title, subtitle;
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
            Text(emoji, style: const TextStyle(fontSize: 52)),
            const SizedBox(height: 14),
            Text(title,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 17),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
                textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

// ── ERROR RETRY ───────────────────────────────────────────────────────────────

class ErrorRetryWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorRetryWidget(
      {super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.errorLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wifi_off_rounded,
                color: AppTheme.error, size: 36),
          ),
          const SizedBox(height: 14),
          Text(message, style: const TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ── GRADIENT BUTTON ───────────────────────────────────────────────────────────

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
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primary, AppTheme.primaryLight],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(label,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ],
                ),
        ),
      ),
    );
  }
}
