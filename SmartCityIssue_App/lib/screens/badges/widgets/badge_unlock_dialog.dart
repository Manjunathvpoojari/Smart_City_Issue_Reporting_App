import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/badge_model.dart';
import 'confetti_painter.dart';

/// Premium badge unlock celebration dialog.
/// Shows confetti, glowing badge reveal, scale animation, and achievement text.
class BadgeUnlockDialog extends StatefulWidget {
  final BadgeModel badge;

  const BadgeUnlockDialog({super.key, required this.badge});

  /// Show the unlock celebration as an overlay dialog
  static Future<void> show(BuildContext context, BadgeModel badge) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => BadgeUnlockDialog(badge: badge),
      transitionBuilder: (_, anim, __, child) {
        return FadeTransition(opacity: anim, child: child);
      },
    );
  }

  @override
  State<BadgeUnlockDialog> createState() => _BadgeUnlockDialogState();
}

class _BadgeUnlockDialogState extends State<BadgeUnlockDialog>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _badgeController;
  late AnimationController _textController;
  late AnimationController _glowPulseController;

  late Animation<double> _badgeScale;
  late Animation<double> _badgeRotation;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();

    // Haptic feedback
    HapticFeedback.heavyImpact();

    // Confetti
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    // Badge entrance: scale 0 → 1.15 → 1.0 with a slight rotation
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _badgeScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.15), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.95), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 20),
    ]).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.easeOut),
    );
    _badgeRotation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.easeOut),
    );

    // Text slide in
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    // Glow pulsing loop
    _glowPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _glowPulse = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _glowPulseController, curve: Curves.easeInOut),
    );

    // Sequence the animations
    _startAnimations();
  }

  Future<void> _startAnimations() async {
    _confettiController.repeat();
    await Future.delayed(const Duration(milliseconds: 200));
    _badgeController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();
    _glowPulseController.repeat(reverse: true);
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _badgeController.dispose();
    _textController.dispose();
    _glowPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badge = widget.badge;
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // ── Confetti Layer ─────────────────────────────────────────────────
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: ConfettiPainter(
                animation: _confettiController,
                particleCount: 80,
                screenSize: size,
              ),
            ),
          ),
        ),

        // ── Radial spotlight ──────────────────────────────────────────────
        Center(
          child: AnimatedBuilder(
            animation: _glowPulse,
            builder: (context, _) {
              return Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      badge.tierGlowColor
                          .withOpacity(_glowPulse.value * 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // ── Main Content ──────────────────────────────────────────────────
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // "Achievement Unlocked" label
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: Text(
                      '🎉 ACHIEVEMENT UNLOCKED!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Badge Medal ─────────────────────────────────────────
                AnimatedBuilder(
                  animation: _badgeScale,
                  builder: (context, _) {
                    return Transform.scale(
                      scale: _badgeScale.value,
                      child: Transform.rotate(
                        angle: _badgeRotation.value,
                        child: _buildMedal(badge),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),

                // ── Title ───────────────────────────────────────────────
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: Column(
                      children: [
                        // Tier label
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                badge.tierGradient[0].withOpacity(0.3),
                                badge.tierGradient[1].withOpacity(0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: badge.tierGlowColor.withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            badge.tierLabel,
                            style: TextStyle(
                              color: badge.tierGlowColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Badge title
                        Text(
                          badge.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Description
                        Text(
                          badge.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Rarity
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: badge.rarityColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: badge.rarityColor.withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            badge.rarityLabel,
                            style: TextStyle(
                              color: badge.rarityColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Dismiss Button ──────────────────────────────────────
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: badge.tierGlowColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '🏆  Awesome!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedal(BadgeModel badge) {
    return AnimatedBuilder(
      animation: _glowPulse,
      builder: (context, _) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: badge.tierGradient,
            ),
            boxShadow: [
              BoxShadow(
                color: badge.tierGlowColor.withOpacity(_glowPulse.value),
                blurRadius: 40,
                spreadRadius: 10,
              ),
              BoxShadow(
                color: badge.tierGlowColor.withOpacity(_glowPulse.value * 0.5),
                blurRadius: 60,
                spreadRadius: 20,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Inner ring
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
              // Icon
              Icon(
                badge.icon,
                color: Colors.white,
                size: 50,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Animated builder helper (local to this file)
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
