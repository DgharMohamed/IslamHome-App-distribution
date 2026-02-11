import 'dart:math';
import 'package:flutter/material.dart';

class AuroraBackground extends StatefulWidget {
  final Widget child;
  const AuroraBackground({super.key, required this.child});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: AuroraPainter(_controller.value),
              size: Size.infinite,
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class AuroraPainter extends CustomPainter {
  final double animationValue;
  AuroraPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Draw base background
    canvas.drawRect(rect, Paint()..color = Colors.black);

    // Draw Aurora Blobs
    _drawBlob(canvas, size, const Color(0xFF1a2a6c), 0.4, 0.0);
    _drawBlob(canvas, size, const Color(0xFFb21f1f), 0.3, 0.3);
    _drawBlob(canvas, size, const Color(0xFFfdbb2d), 0.2, 0.6);
  }

  void _drawBlob(
    Canvas canvas,
    Size size,
    Color color,
    double opacity,
    double offset,
  ) {
    final t = (animationValue + offset) % 1.0;
    final x = size.width * (0.5 + 0.3 * sin(t * 2 * pi));
    final y = size.height * (0.3 + 0.2 * cos(t * 2 * pi));
    final radius = size.width * 0.8;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    canvas.drawCircle(Offset(x, y), radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
