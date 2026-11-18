import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Nested pentagon mark taken from the theme artwork.
class PentagonMark extends StatelessWidget {
  const PentagonMark({
    super.key,
    this.size = 200,
    this.progress = 1,
    this.rotation = 0,
    this.color = Colors.white,
  });

  final double size;
  final double progress;
  final double rotation;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PentagonPainter(progress, rotation, color),
      ),
    );
  }
}

class _PentagonPainter extends CustomPainter {
  _PentagonPainter(this.progress, this.rotation, this.color);
  final double progress;
  final double rotation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    const layers = 7;
    for (var i = 0; i < layers; i++) {
      final t = ((progress * layers) - i).clamp(0.0, 1.0).toDouble();
      if (t <= 0) continue;
      final r = radius * math.pow(0.8, i).toDouble() * (0.7 + 0.3 * t);
      final angle = rotation + i * 0.21;
      final path = Path();
      for (var k = 0; k < 5; k++) {
        final a = angle - math.pi / 2 + k * 2 * math.pi / 5;
        final p = center + Offset(math.cos(a), math.sin(a)) * r;
        if (k == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..strokeJoin = StrokeJoin.round
        ..color = color.withAlpha((255 * t).round());
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PentagonPainter old) =>
      old.progress != progress || old.rotation != rotation || old.color != color;
}
