import 'dart:math' as math;
import 'package:flutter/material.dart';

class QiblaDialPainter extends CustomPainter {
  final Color color;
  QiblaDialPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer circle with thicker border
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, paint);

    // Inner decorative circle
    paint.strokeWidth = 1.0;
    canvas.drawCircle(center, radius - 10, paint);

    // Degree markings - more prominent
    for (int i = 0; i < 360; i += 5) {
      final isMajor = i % 30 == 0;
      final angle = (i - 90) * math.pi / 180; // Start from top (N)
      final startRadius = radius - (isMajor ? 20 : 12);

      final start = Offset(
        center.dx + startRadius * math.cos(angle),
        center.dy + startRadius * math.sin(angle),
      );
      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      paint.strokeWidth = isMajor ? 2.5 : 1.2;
      canvas.drawLine(start, end, paint);

      // Draw degree numbers for major marks
      if (isMajor) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '$i',
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final textRadius = radius - 35;
        canvas.save();
        canvas.translate(
          center.dx + textRadius * math.cos(angle),
          center.dy + textRadius * math.sin(angle),
        );
        textPainter.paint(
          canvas,
          Offset(-textPainter.width / 2, -textPainter.height / 2),
        );
        canvas.restore();
      }
    }

    // Cardinal directions - larger and more prominent
    final directions = {0: 'N', 90: 'E', 180: 'S', 270: 'W'};

    directions.forEach((deg, label) {
      final angle = (deg - 90) * math.pi / 180;
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: label == 'N' ? const Color(0xFFFF6B35) : Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 1.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final textRadius = radius - 55;
      canvas.save();
      canvas.translate(
        center.dx + textRadius * math.cos(angle),
        center.dy + textRadius * math.sin(angle),
      );
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QiblaOrnamentPainter extends CustomPainter {
  final Color color;
  QiblaOrnamentPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Elegant scrollwork ornament
    path.moveTo(w * 0.5, h * 0.7);
    path.quadraticBezierTo(w * 0.4, h * 0.3, w * 0.2, h * 0.6);
    path.moveTo(w * 0.5, h * 0.7);
    path.quadraticBezierTo(w * 0.6, h * 0.3, w * 0.8, h * 0.6);

    path.moveTo(w * 0.5, h * 0.5);
    path.quadraticBezierTo(w * 0.3, 0, w * 0.1, h * 0.2);
    path.moveTo(w * 0.5, h * 0.5);
    path.quadraticBezierTo(w * 0.7, 0, w * 0.9, h * 0.2);

    canvas.drawPath(path, paint);

    // Pointer Triangle - more visible
    final trianglePath = Path();
    trianglePath.moveTo(w * 0.45, h);
    trianglePath.lineTo(w * 0.55, h);
    trianglePath.lineTo(w * 0.5, h - 15);
    trianglePath.close();
    canvas.drawPath(
      trianglePath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CompassNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final Paint goldPaint = Paint()
      ..color =
          const Color(0xFFFFD700) // Brighter gold
      ..style = PaintingStyle.fill;

    final Paint blackPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Shadow for depth
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // 1. Draw shadow
    final shadowPath = Path();
    shadowPath.moveTo(w / 2 + 2, 2);
    shadowPath.lineTo(w / 2 + 10, h * 0.35 + 2);
    shadowPath.lineTo(w / 2 + 2, h + 2);
    shadowPath.lineTo(w / 2 - 6, h * 0.35 + 2);
    shadowPath.close();
    canvas.drawPath(shadowPath, shadowPaint);

    // 2. Draw the Main Needle Body - wider and more visible
    final Path needlePath = Path();

    // Top Sharp Tip (above mosque)
    needlePath.moveTo(w / 2, 0);
    needlePath.lineTo(w / 2 + 5, h * 0.15);
    needlePath.lineTo(w / 2 - 5, h * 0.15);
    needlePath.close();

    // Bottom Long Body - wider
    needlePath.moveTo(w / 2 + 8, h * 0.35);
    needlePath.lineTo(w / 2, h);
    needlePath.lineTo(w / 2 - 8, h * 0.35);
    needlePath.close();

    canvas.drawPath(needlePath, goldPaint);

    // 3. Draw the Black Circle behind the Mosque - larger
    canvas.drawCircle(Offset(w / 2, h * 0.25), 22, blackPaint);

    // 4. Draw the Mosque Silhouette - larger and clearer
    final Path mosquePath = Path();
    double mx = w / 2;
    double my = h * 0.25;

    // Base of mosque - wider
    mosquePath.moveTo(mx - 10, my + 10);
    mosquePath.lineTo(mx + 10, my + 10);
    mosquePath.lineTo(mx + 10, my - 3);
    mosquePath.lineTo(mx + 5, my - 3);

    // Right Minaret
    mosquePath.lineTo(mx + 5, my - 12);
    mosquePath.lineTo(mx + 6, my - 12);
    mosquePath.lineTo(mx + 4.5, my - 16);
    mosquePath.lineTo(mx + 3, my - 12);
    mosquePath.lineTo(mx + 4, my - 12);
    mosquePath.lineTo(mx + 4, my - 3);

    // Central Dome
    mosquePath.lineTo(mx - 4, my - 3);
    mosquePath.quadraticBezierTo(mx, my - 10, mx + 4, my - 3);
    mosquePath.moveTo(mx - 4, my - 3);

    // Left Minaret
    mosquePath.lineTo(mx - 4, my - 12);
    mosquePath.lineTo(mx - 3, my - 12);
    mosquePath.lineTo(mx - 4.5, my - 16);
    mosquePath.lineTo(mx - 6, my - 12);
    mosquePath.lineTo(mx - 5, my - 12);
    mosquePath.lineTo(mx - 5, my - 3);
    mosquePath.lineTo(mx - 10, my - 3);
    mosquePath.close();

    canvas.drawPath(mosquePath, goldPaint);

    // 5. Add highlight to needle for 3D effect
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final highlightPath = Path();
    highlightPath.moveTo(w / 2 - 1, 5);
    highlightPath.lineTo(w / 2 - 1, h * 0.3);
    highlightPath.lineTo(w / 2 - 3, h * 0.3);
    highlightPath.lineTo(w / 2 - 3, 5);
    highlightPath.close();
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
