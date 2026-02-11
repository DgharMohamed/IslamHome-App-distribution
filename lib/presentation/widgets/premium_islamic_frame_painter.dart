import 'package:flutter/material.dart';

class PremiumIslamicFramePainter extends CustomPainter {
  final Color color;

  PremiumIslamicFramePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final outerRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final innerRect = Rect.fromLTWH(8, 8, size.width - 16, size.height - 16);

    // Draw main borders
    canvas.drawRRect(
      RRect.fromRectAndRadius(outerRect, const Radius.circular(4)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, const Radius.circular(2)),
      paint,
    );

    // Corner decorations (Abstract Islamic Geometric style)
    final cornerSize = 24.0;
    _drawCornerOrnament(canvas, paint, Offset.zero, cornerSize, 0);
    _drawCornerOrnament(canvas, paint, Offset(size.width, 0), cornerSize, 1);
    _drawCornerOrnament(canvas, paint, Offset(0, size.height), cornerSize, 2);
    _drawCornerOrnament(
      canvas,
      paint,
      Offset(size.width, size.height),
      cornerSize,
      3,
    );

    // Side ornaments
    _drawSideOrnament(canvas, paint, Offset(size.width / 2, 0), true);
    _drawSideOrnament(canvas, paint, Offset(size.width / 2, size.height), true);
    _drawSideOrnament(canvas, paint, Offset(0, size.height / 2), false);
    _drawSideOrnament(
      canvas,
      paint,
      Offset(size.width, size.height / 2),
      false,
    );
  }

  void _drawCornerOrnament(
    Canvas canvas,
    Paint paint,
    Offset center,
    double size,
    int quadrant,
  ) {
    final path = Path();
    double startAngle = 0;
    if (quadrant == 1) startAngle = 90;
    if (quadrant == 2) startAngle = 270;
    if (quadrant == 3) startAngle = 180;

    // Simplified geometric floral motif
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(startAngle * 0.0174533);

    path.moveTo(0, 0);
    path.lineTo(size, 0);
    path.quadraticBezierTo(size * 0.8, size * 0.2, size * 0.5, size * 0.5);
    path.quadraticBezierTo(size * 0.2, size * 0.8, 0, size);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawSideOrnament(
    Canvas canvas,
    Paint paint,
    Offset center,
    bool isHorizontal,
  ) {
    if (isHorizontal) {
      canvas.drawCircle(center, 3, paint..style = PaintingStyle.fill);
      canvas.drawCircle(center, 6, paint..style = PaintingStyle.stroke);
    } else {
      canvas.drawCircle(center, 3, paint..style = PaintingStyle.fill);
      canvas.drawCircle(center, 6, paint..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
