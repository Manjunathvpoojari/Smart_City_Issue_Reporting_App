import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/issue.dart';

// ── App Bar (Citizen - green) ──────────────────────────────
class ScAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final Color bgColor;

  const ScAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.bgColor = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 6,
        bottom: 14,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          if (showBack) ...[
            GestureDetector(
              onTap: onBack ?? () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Admin App Bar ──────────────────────────────────────────
class AdminAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;

  const AdminAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.accentDark,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 6,
        bottom: 14,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          if (showBack) ...[
            GestureDetector(
              onTap: onBack ?? () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Status Badge ───────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (status) {
      case 'Pending':
        bg = AppColors.pendingBg;
        fg = AppColors.pendingColor;
        break;
      case 'In Progress':
        bg = AppColors.progressBg;
        fg = AppColors.progressColor;
        break;
      case 'Resolved':
        bg = AppColors.resolvedBg;
        fg = AppColors.resolvedColor;
        break;
      default:
        bg = AppColors.border;
        fg = AppColors.muted;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

// ── Issue Card ─────────────────────────────────────────────
class IssueCard extends StatelessWidget {
  final Issue issue;
  final VoidCallback? onTap;

  const IssueCard({super.key, required this.issue, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: issue.dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        issue.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${issue.timeAgo} · ${issue.location}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(issue.statusLabel),
              ],
            ),
            if (issue.progressFill != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: issue.progressFill,
                  minHeight: 5,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Map Placeholder — lightweight, NO CustomPaint ──────────
// Uses a simple Stack of positioned Containers. Zero heavy ops.
class MapPlaceholder extends StatelessWidget {
  final bool singlePin;
  const MapPlaceholder({super.key, this.singlePin = false});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return Stack(
          children: [
            // Base green map color
            Container(color: const Color(0xFFC8E6D4)),

            // Main horizontal road
            Positioned(
              top: h * 0.44,
              left: 0,
              right: 0,
              height: h * 0.08,
              child: Container(color: Colors.white.withOpacity(0.55)),
            ),
            // Main vertical road
            Positioned(
              top: 0,
              bottom: 0,
              left: w * 0.47,
              width: w * 0.06,
              child: Container(color: Colors.white.withOpacity(0.55)),
            ),
            // Secondary horizontal roads
            Positioned(
              top: h * 0.19,
              left: 0,
              right: 0,
              height: 3,
              child: Container(color: Colors.white.withOpacity(0.32)),
            ),
            Positioned(
              top: h * 0.74,
              left: 0,
              right: 0,
              height: 3,
              child: Container(color: Colors.white.withOpacity(0.32)),
            ),
            // Secondary vertical roads
            Positioned(
              top: 0,
              bottom: 0,
              left: w * 0.19,
              width: 3,
              child: Container(color: Colors.white.withOpacity(0.32)),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: w * 0.77,
              width: 3,
              child: Container(color: Colors.white.withOpacity(0.32)),
            ),

            // Pins
            if (!singlePin) ...[
              _pin(w, h, AppColors.red, 0.22, 0.38),
              _pin(w, h, AppColors.red, 0.55, 0.20),
              _pin(w, h, AppColors.blue, 0.68, 0.58),
              _pin(w, h, AppColors.green, 0.80, 0.30),
              _pin(w, h, AppColors.red, 0.38, 0.68),
            ] else
              _pin(w, h, AppColors.red, 0.42, 0.48),

            // Map label
            Positioned(
              bottom: 6,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Mysuru',
                  style: TextStyle(fontSize: 9, color: AppColors.muted),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _pin(double w, double h, Color color, double top, double left) {
    return Positioned(
      top: h * top - 7,
      left: w * left - 7,
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Field Label ────────────────────────────────────────────
class FieldLabel extends StatelessWidget {
  final String label;
  const FieldLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.muted,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ── Primary Button ─────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const PrimaryButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── Secondary Button ───────────────────────────────────────
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const SecondaryButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.accentLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}

// ── Input Decoration ───────────────────────────────────────
InputDecoration scInputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
    filled: true,
    fillColor: const Color(0xFFF3F2EE),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
    ),
  );
}

// ── Filter Pills Row ───────────────────────────────────────
class FilterPillsRow extends StatelessWidget {
  final List<String> filters;
  final int selected;
  final ValueChanged<int> onSelect;

  const FilterPillsRow({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: List.generate(filters.length, (i) {
          final active = selected == i;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: active ? AppColors.accent : Colors.white,
                border: Border.all(
                  color: active ? AppColors.accent : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                filters[i],
                style: TextStyle(
                  fontSize: 12,
                  color: active ? Colors.white : AppColors.muted,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Timeline Item ──────────────────────────────────────────
class TimelineItem extends StatelessWidget {
  final Color color;
  final String title;
  final String subtitle;
  final bool isLast;
  final bool faded;

  const TimelineItem({
    super.key,
    required this.color,
    required this.title,
    required this.subtitle,
    this.isLast = false,
    this.faded = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: AppColors.border,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: faded ? AppColors.muted : AppColors.text,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notification Card ──────────────────────────────────────
class NotifCard extends StatelessWidget {
  final Color leftColor;
  final String emoji;
  final String title;
  final String body;
  final String time;

  const NotifCard({
    super.key,
    required this.leftColor,
    required this.emoji,
    required this.title,
    required this.body,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Colored left accent bar
            Container(width: 4, color: leftColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            body,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            time,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
