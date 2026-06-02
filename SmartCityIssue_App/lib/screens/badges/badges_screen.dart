import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/badge_model.dart';
import '../../providers/badge_provider.dart';
import 'widgets/badge_card.dart';
import 'widgets/badge_unlock_dialog.dart';

/// Main Achievements & Badges screen.
/// Premium dashboard layout with gradient header, tier sections, and grid.
class BadgesScreen extends ConsumerStatefulWidget {
  const BadgesScreen({super.key});

  @override
  ConsumerState<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends ConsumerState<BadgesScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
    );
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badges = ref.watch(badgesProvider);
    final earned = ref.watch(earnedBadgesCountProvider);
    final total = ref.watch(totalBadgesCountProvider);
    final goldBadges = ref.watch(goldBadgesProvider);
    final silverBadges = ref.watch(silverBadgesProvider);
    final bronzeBadges = ref.watch(bronzeBadgesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F14) : AppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ───────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            title: const Text('Achievements'),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(earned, total, isDark),
            ),
          ),

          // ── Demo Unlock Button ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _buildDemoUnlockButton(badges, isDark),
            ),
          ),

          // ── Gold Section ──────────────────────────────────────────────
          _buildSectionHeader(
            '🥇 Gold Tier',
            'Legendary achievements for elite contributors',
            const [Color(0xFFFFD700), Color(0xFFFFA500)],
            isDark,
          ),
          _buildBadgeGrid(goldBadges, 0),

          // ── Silver Section ────────────────────────────────────────────
          _buildSectionHeader(
            '🥈 Silver Tier',
            'Epic milestones for dedicated citizens',
            const [Color(0xFFC0C0C0), Color(0xFFE8E8E8)],
            isDark,
          ),
          _buildBadgeGrid(silverBadges, goldBadges.length),

          // ── Bronze Section ────────────────────────────────────────────
          _buildSectionHeader(
            '🥉 Bronze Tier',
            'First steps in your civic journey',
            const [Color(0xFFCD7F32), Color(0xFFD4A04A)],
            isDark,
          ),
          _buildBadgeGrid(bronzeBadges, goldBadges.length + silverBadges.length),

          // Bottom padding
          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(int earned, int total, bool isDark) {
    final progress = total > 0 ? earned / total : 0.0;
    final rank = _getRank(earned);

    return SlideTransition(
      position: _headerSlide,
      child: FadeTransition(
        opacity: _headerFade,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F3D27),
                Color(0xFF1D5E3F),
                Color(0xFF2D7A55),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              child: Row(
                children: [
                  // Left: Text info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          rank,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$earned / $total',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Badges Earned',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right: Circular progress
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background ring
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: 1,
                            strokeWidth: 6,
                            backgroundColor: Colors.transparent,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        // Progress ring
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: progress),
                            duration: const Duration(milliseconds: 1200),
                            curve: Curves.easeOutCubic,
                            builder: (_, value, __) {
                              return CircularProgressIndicator(
                                value: value,
                                strokeWidth: 6,
                                backgroundColor: Colors.transparent,
                                color: const Color(0xFFFFD700),
                                strokeCap: StrokeCap.round,
                              );
                            },
                          ),
                        ),
                        // Percentage text
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TweenAnimationBuilder<int>(
                              tween: IntTween(
                                begin: 0,
                                end: (progress * 100).toInt(),
                              ),
                              duration: const Duration(milliseconds: 1200),
                              builder: (_, value, __) {
                                return Text(
                                  '$value%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                );
                              },
                            ),
                            Text(
                              'Complete',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getRank(int earned) {
    if (earned >= 10) return '👑 LEGEND';
    if (earned >= 7) return '⭐ CHAMPION';
    if (earned >= 4) return '🌟 RISING STAR';
    if (earned >= 1) return '🔥 NEWCOMER';
    return '🌱 BEGINNER';
  }

  // ── Demo Unlock Button ──────────────────────────────────────────────────────

  Widget _buildDemoUnlockButton(List<BadgeModel> badges, bool isDark) {
    // Pick a random unlocked badge to demo, or the first badge
    final unlockedBadges = badges.where((b) => b.isUnlocked).toList();
    final demoBadge = unlockedBadges.isNotEmpty
        ? unlockedBadges[Random().nextInt(unlockedBadges.length)]
        : badges.first.copyWith(isUnlocked: true);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700).withOpacity(isDark ? 0.12 : 0.08),
            const Color(0xFFFFA500).withOpacity(isDark ? 0.06 : 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.celebration_rounded,
              color: Color(0xFFDAA520),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preview Unlock Animation',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tap to see the celebration effect',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.5)
                        : AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => BadgeUnlockDialog.show(context, demoBadge),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                '🎉 Try',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Headers ─────────────────────────────────────────────────────────

  SliverToBoxAdapter _buildSectionHeader(
    String title,
    String subtitle,
    List<Color> gradientColors,
    bool isDark,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Row(
          children: [
            // Gradient accent bar
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.45)
                          : AppTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Badge Grid ──────────────────────────────────────────────────────────────

  SliverPadding _buildBadgeGrid(List<BadgeModel> badges, int indexOffset) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.82,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return _AnimatedBadgeEntry(
              index: index,
              child: BadgeCard(
                badge: badges[index],
                index: indexOffset + index,
              ),
            );
          },
          childCount: badges.length,
        ),
      ),
    );
  }
}

// ── Staggered Fade-In Animation for Grid Items ────────────────────────────────

class _AnimatedBadgeEntry extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedBadgeEntry({required this.index, required this.child});

  @override
  State<_AnimatedBadgeEntry> createState() => _AnimatedBadgeEntryState();
}

class _AnimatedBadgeEntryState extends State<_AnimatedBadgeEntry>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // Staggered delay based on index
    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}
