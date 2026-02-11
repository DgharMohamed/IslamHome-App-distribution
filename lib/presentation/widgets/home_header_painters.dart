import 'dart:math' as math;
import 'package:flutter/material.dart';

class SkyPainter extends CustomPainter {
  final double animationValue;
  final List<Star> stars;

  SkyPainter(this.animationValue, this.stars);

  @override
  void paint(Canvas canvas, Size size) {
    for (var star in stars) {
      final paint = Paint()
        ..color = star.color.withValues(
          alpha:
              (star.baseOpacity +
                      (math.sin(animationValue * 5 + star.offset) * 0.3))
                  .clamp(0, 1),
        )
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(SkyPainter oldDelegate) => true;
}

class Star {
  final double x;
  final double y;
  final double size;
  final double baseOpacity;
  final double offset;
  final Color color;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.baseOpacity,
    required this.offset,
    this.color = Colors.white,
  });

  static List<Star> generate(int count) {
    final random = math.Random(42);
    return List.generate(count, (index) {
      return Star(
        x: random.nextDouble(),
        y: random.nextDouble() * 0.7, // Only in top 70% of sky
        size: random.nextDouble() * 1.5 + 0.5,
        baseOpacity: random.nextDouble() * 0.4 + 0.2,
        offset: random.nextDouble() * math.pi * 2,
      );
    });
  }
}

class MosqueSilhouettePainter extends CustomPainter {
  final Color color;

  MosqueSilhouettePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Bottom base
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);

    // Silhouette structure
    double w = size.width;
    double h = size.height;

    // Small domes on left
    path.lineTo(w * 0.1, h);
    path.quadraticBezierTo(w * 0.15, h * 0.8, w * 0.2, h);

    // Main dome center
    path.lineTo(w * 0.4, h);
    path.quadraticBezierTo(w * 0.5, h * 0.3, w * 0.6, h);

    // Minaret 1
    path.lineTo(w * 0.7, h);
    path.lineTo(w * 0.7, h * 0.4);
    path.lineTo(w * 0.72, h * 0.35);
    path.lineTo(w * 0.74, h * 0.4);
    path.lineTo(w * 0.74, h);

    // Minaret 2 (far left)
    path.moveTo(w * 0.05, h);
    path.lineTo(w * 0.05, h * 0.5);
    path.lineTo(w * 0.07, h * 0.45);
    path.lineTo(w * 0.09, h * 0.5);
    path.lineTo(w * 0.09, h);

    path.close();
    canvas.drawPath(path, paint);

    // Add subtle glow to main dome edge
    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final glowPath = Path();
    glowPath.moveTo(w * 0.4, h);
    glowPath.quadraticBezierTo(w * 0.5, h * 0.3, w * 0.6, h);
    canvas.drawPath(glowPath, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CrescentMoonPainter extends CustomPainter {
  final Color color;

  CrescentMoonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    path.addOval(Rect.fromCircle(center: center, radius: radius));

    // Cutting oval to create crescent
    final cutPath = Path();
    cutPath.addOval(
      Rect.fromCircle(
        center: center.translate(radius * 0.4, -radius * 0.2),
        radius: radius * 0.9,
      ),
    );

    final finalPath = Path.combine(PathOperation.difference, path, cutPath);
    canvas.drawPath(finalPath, paint);

    // Subtle glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(finalPath, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
