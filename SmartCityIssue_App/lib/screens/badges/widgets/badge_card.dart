import 'dart:ui';
import 'package:flutter/material.dart' hide AnimatedBuilder;
import '../../../models/badge_model.dart';
import 'badge_detail_dialog.dart';
import 'badge_progress_widget.dart';

/// A single badge card in the grid.
/// Unlocked badges glow with tier gradients; locked badges are faded & blurred.
class BadgeCard extends StatefulWidget {
  final BadgeModel badge;
  final int index;

  const BadgeCard({
    super.key,
    required this.badge,
    required this.index,
  });

  @override
  State<BadgeCard> createState() => _BadgeCardState();
}

class _BadgeCardState extends State<BadgeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Only animate shimmer for unlocked badges
    if (widget.badge.isUnlocked) {
      Future.delayed(Duration(milliseconds: widget.index * 200), () {
        if (mounted) _shimmerController.repeat();
      });
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badge = widget.badge;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showDetail(context, badge),
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              // Tier glow for unlocked badges
              boxShadow: badge.isUnlocked
                  ? [
                      BoxShadow(
                        color: badge.tierGlowColor.withOpacity(0.3),
                        blurRadius: 16,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: badge.tierGlowColor.withOpacity(0.1),
                        blurRadius: 30,
                        spreadRadius: 4,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Background
                  _buildBackground(badge, isDark),

                  // Shimmer sweep for unlocked
                  if (badge.isUnlocked) _buildShimmer(badge),

                  // Content
                  _buildContent(badge, isDark),

                  // Lock overlay for locked badges
                  if (!badge.isUnlocked) _buildLockOverlay(isDark),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackground(BadgeModel badge, bool isDark) {
    if (badge.isUnlocked) {
      return Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                badge.tierGradient[0].withOpacity(0.15),
                isDark ? const Color(0xFF1A1A24) : Colors.white,
                badge.tierGradient[1].withOpacity(0.08),
              ],
            ),
          ),
        ),
      );
    }

    return Positioned.fill(
      child: Container(
        color: isDark ? const Color(0xFF1A1A24) : const Color(0xFFF5F4F0),
      ),
    );
  }

  Widget _buildShimmer(BadgeModel badge) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, _) {
          return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment(_shimmerAnimation.value - 1, 0),
                end: Alignment(_shimmerAnimation.value, 0),
                colors: [
                  Colors.transparent,
                  badge.tierGlowColor.withOpacity(0.08),
                  Colors.transparent,
                ],
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: Container(color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _buildContent(BadgeModel badge, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Badge icon with gradient circle
          _buildBadgeIcon(badge, isDark),
          const SizedBox(height: 10),

          // Title
          Text(
            badge.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: badge.isUnlocked
                  ? (isDark ? Colors.white : const Color(0xFF1A1A18))
                  : (isDark
                      ? Colors.white.withOpacity(0.4)
                      : Colors.black.withOpacity(0.35)),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),

          // Rarity chip
          _buildRarityChip(badge),
          const SizedBox(height: 6),

          // Progress or unlock date
          if (!badge.isUnlocked)
            BadgeProgressWidget(badge: badge, compact: true)
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 11,
                  color: badge.tierGlowColor,
                ),
                const SizedBox(width: 3),
                Text(
                  'Unlocked',
                  style: TextStyle(
                    color: badge.tierGlowColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBadgeIcon(BadgeModel badge, bool isDark) {
    return Container(
      width: 52,
      height: 52,
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
                  isDark ? Colors.white.withOpacity(0.08) : Colors.grey[300]!,
                  isDark ? Colors.white.withOpacity(0.04) : Colors.grey[200]!,
                ],
              ),
        boxShadow: badge.isUnlocked
            ? [
                BoxShadow(
                  color: badge.tierGlowColor.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Icon(
        badge.icon,
        color: badge.isUnlocked
            ? Colors.white
            : (isDark ? Colors.white.withOpacity(0.2) : Colors.grey[400]),
        size: 26,
      ),
    );
  }

  Widget _buildRarityChip(BadgeModel badge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badge.isUnlocked
            ? badge.rarityColor.withOpacity(0.12)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: badge.isUnlocked
              ? badge.rarityColor.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Text(
        badge.rarityLabel,
        style: TextStyle(
          color: badge.isUnlocked
              ? badge.rarityColor
              : Colors.grey.withOpacity(0.5),
          fontSize: 8,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLockOverlay(bool isDark) {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
          child: Container(
            color: isDark
                ? Colors.black.withOpacity(0.15)
                : Colors.white.withOpacity(0.1),
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, BadgeModel badge) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'BadgeDetail',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => BadgeDetailDialog(badge: badge),
      transitionBuilder: (_, anim, __, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }
}
