import 'package:flutter/material.dart';
import 'dart:math' as math;

class MushafVerseMarkerPainter extends CustomPainter {
  final Color color;

  MushafVerseMarkerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw an 8-pointed star (Islamic Star)
    final path = Path();
    for (int i = 0; i < 8; i++) {
      double angle = (i * 45) * math.pi / 180;
      double outerRadius = radius;
      double innerRadius = radius * 0.75;

      double x1 = center.dx + outerRadius * math.cos(angle);
      double y1 = center.dy + outerRadius * math.sin(angle);

      double nextAngle = angle + (22.5 * math.pi / 180);
      double x2 = center.dx + innerRadius * math.cos(nextAngle);
      double y2 = center.dy + innerRadius * math.sin(nextAngle);

      if (i == 0) {
        path.moveTo(x1, y1);
      } else {
        path.lineTo(x1, y1);
      }
      path.lineTo(x2, y2);
    }
    path.close();
    canvas.drawPath(path, paint);

    // Draw inner circle
    canvas.drawCircle(center, radius * 0.55, paint..strokeWidth = 0.8);

    // Draw outer dots for decoration
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 8; i++) {
      double angle = (i * 45) * math.pi / 180;
      canvas.drawCircle(
        Offset(
          center.dx + radius * 0.85 * math.cos(angle),
          center.dy + radius * 0.85 * math.sin(angle),
        ),
        1.2,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
