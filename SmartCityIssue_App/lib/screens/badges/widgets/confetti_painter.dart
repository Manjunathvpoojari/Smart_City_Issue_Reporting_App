import 'dart:math';
import 'package:flutter/material.dart';

/// Custom painter that renders animated confetti particles
/// for the badge unlock celebration.
class ConfettiPainter extends CustomPainter {
  final Animation<double> animation;
  final List<_ConfettiParticle> _particles;

  ConfettiPainter({
    required this.animation,
    required int particleCount,
    required Size screenSize,
  })  : _particles = List.generate(
          particleCount,
          (_) => _ConfettiParticle(screenSize),
        ),
        super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;

    for (final particle in _particles) {
      final progress = (t + particle.delay) % 1.0;

      // Physics: gravity + horizontal drift
      final x = particle.startX + particle.driftX * progress * size.width;
      final y = particle.startY +
          progress * size.height * 1.2 +
          particle.gravity * progress * progress * 200;
      final rotation = particle.rotationSpeed * progress * 2 * pi;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      if (opacity <= 0) continue;

      final paint = Paint()
        ..color = particle.color.withOpacity(opacity * 0.9)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      // Draw different shapes
      switch (particle.shape) {
        case 0: // Rectangle
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset.zero,
                width: particle.size,
                height: particle.size * 0.6,
              ),
              const Radius.circular(1),
            ),
            paint,
          );
          break;
        case 1: // Circle
          canvas.drawCircle(Offset.zero, particle.size * 0.4, paint);
          break;
        case 2: // Triangle
          final path = Path()
            ..moveTo(0, -particle.size * 0.5)
            ..lineTo(particle.size * 0.4, particle.size * 0.3)
            ..lineTo(-particle.size * 0.4, particle.size * 0.3)
            ..close();
          canvas.drawPath(path, paint);
          break;
        default: // Star-like
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset.zero,
                width: particle.size * 0.3,
                height: particle.size,
              ),
              const Radius.circular(1),
            ),
            paint,
          );
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => true;
}

class _ConfettiParticle {
  final Color color;
  final double startX;
  final double startY;
  final double driftX;
  final double gravity;
  final double rotationSpeed;
  final double size;
  final double delay;
  final int shape;

  static final Random _rng = Random();
  static const List<Color> _colors = [
    Color(0xFFFFD700), // Gold
    Color(0xFFFF6B6B), // Red
    Color(0xFF4ECDC4), // Teal
    Color(0xFF45B7D1), // Blue
    Color(0xFFF7DC6F), // Yellow
    Color(0xFFBB8FCE), // Purple
    Color(0xFFFF8C00), // Orange
    Color(0xFF82E0AA), // Green
    Color(0xFFFF69B4), // Pink
    Color(0xFF00CED1), // DarkTurquoise
  ];

  _ConfettiParticle(Size screenSize)
      : color = _colors[_rng.nextInt(_colors.length)],
        startX = _rng.nextDouble() * screenSize.width,
        startY = -20.0 - _rng.nextDouble() * 100,
        driftX = (_rng.nextDouble() - 0.5) * 0.4,
        gravity = 0.5 + _rng.nextDouble() * 1.5,
        rotationSpeed = (_rng.nextDouble() - 0.5) * 8,
        size = 5.0 + _rng.nextDouble() * 8,
        delay = _rng.nextDouble() * 0.3,
        shape = _rng.nextInt(4);
}
