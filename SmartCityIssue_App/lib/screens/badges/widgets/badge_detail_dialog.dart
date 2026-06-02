import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/badge_model.dart';
import 'badge_progress_widget.dart';

/// Detail dialog shown when tapping a badge card.
/// Displays full badge info, progress, and unlock status.
class BadgeDetailDialog extends StatefulWidget {
  final BadgeModel badge;

  const BadgeDetailDialog({super.key, required this.badge});

  @override
  State<BadgeDetailDialog> createState() => _BadgeDetailDialogState();
}

class _BadgeDetailDialogState extends State<BadgeDetailDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    if (widget.badge.isUnlocked) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badge = widget.badge;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        width: screenWidth * 0.85,
        constraints: const BoxConstraints(maxWidth: 400),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A24) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: badge.isUnlocked
                ? badge.tierGlowColor.withOpacity(0.3)
                : (isDark ? Colors.white.withOpacity(0.08) : Colors.grey[200]!),
            width: 1.5,
          ),
          boxShadow: [
            if (badge.isUnlocked)
              BoxShadow(
                color: badge.tierGlowColor.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Badge Icon ──────────────────────────────────────────
                _buildBadgeIcon(badge, isDark),
                const SizedBox(height: 20),

                // ── Tier Label ──────────────────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        badge.tierGradient[0].withOpacity(0.2),
                        badge.tierGradient[1].withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: badge.tierGlowColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    badge.tierLabel,
                    style: TextStyle(
                      color: badge.tierAccentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Title ───────────────────────────────────────────────
                Text(
                  badge.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1A1A18),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Rarity ──────────────────────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: badge.rarityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: badge.rarityColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    badge.rarityLabel,
                    style: TextStyle(
                      color: badge.rarityColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Description ─────────────────────────────────────────
                Text(
                  badge.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.6)
                        : Colors.black.withOpacity(0.5),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Divider ─────────────────────────────────────────────
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        badge.tierGlowColor.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Requirement ─────────────────────────────────────────
                Row(
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      size: 16,
                      color: badge.tierGlowColor.withOpacity(0.7),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Requirement: ${badge.requirement}',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withOpacity(0.5)
                              : Colors.black.withOpacity(0.45),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Progress / Unlock Date ──────────────────────────────
                if (badge.isUnlocked) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: badge.tierGlowColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: badge.tierGlowColor.withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 18,
                          color: badge.tierGlowColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Unlocked',
                          style: TextStyle(
                            color: badge.tierGlowColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (badge.unlockedAt != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '• ${DateFormat('MMM d, yyyy').format(badge.unlockedAt!)}',
                            style: TextStyle(
                              color: badge.tierGlowColor.withOpacity(0.7),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ] else ...[
                  BadgeProgressWidget(badge: badge, compact: false),
                ],
                const SizedBox(height: 20),

                // ── Close Button ────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.08),
                        ),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withOpacity(0.6)
                            : Colors.black.withOpacity(0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeIcon(BadgeModel badge, bool isDark) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: badge.isUnlocked
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: badge.tierGradient,
                  )
                : LinearGradient(
                    colors: [
                      isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.grey[300]!,
                      isDark
                          ? Colors.white.withOpacity(0.04)
                          : Colors.grey[200]!,
                    ],
                  ),
            boxShadow: badge.isUnlocked
                ? [
                    BoxShadow(
                      color: badge.tierGlowColor
                          .withOpacity(_glowAnimation.value),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            badge.icon,
            color: badge.isUnlocked
                ? Colors.white
                : (isDark ? Colors.white.withOpacity(0.2) : Colors.grey[400]),
            size: 42,
          ),
        );
      },
    );
  }
}

/// Animated builder for glow animation
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) => builder(context, null);
}
