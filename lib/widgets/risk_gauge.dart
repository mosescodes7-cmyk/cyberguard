import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Circular dial inspired by the time dial in the theme artwork.
class RiskGauge extends StatelessWidget {
  const RiskGauge({
    super.key,
    required this.score,
    required this.color,
    required this.label,
    this.size = 220,
  });

  final int score;
  final Color color;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: score / 100),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _GaugePainter(v, color),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(v * 100).round()}',
                    style: TextStyle(
                      fontSize: size * 0.27,
                      fontWeight: FontWeight.w300,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'risk score',
                    style: TextStyle(
                      fontSize: size * 0.065,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: size * 0.085,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.value, this.color);
  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final stroke = size.width * 0.07;
    final radius = size.width / 2 - stroke * 1.6;

    canvas.drawCircle(
      center,
      radius + stroke * 1.15,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withAlpha(40),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = Colors.white.withAlpha(26),
    );

    final sweep = 2 * math.pi * value;
    if (value > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = color,
      );
    }

    final a = -math.pi / 2 + sweep;
    final knob = center + Offset(math.cos(a), math.sin(a)) * radius;
    canvas.drawCircle(knob, stroke * 0.62, Paint()..color = Colors.white);
    canvas.drawCircle(knob, stroke * 0.3, Paint()..color = color);

    final tick = Paint()
      ..color = color.withAlpha(200)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final ang = i * math.pi / 2;
      final dir = Offset(math.cos(ang), math.sin(ang));
      canvas.drawLine(
        center + dir * (radius + stroke * 1.35),
        center + dir * (radius + stroke * 1.85),
        tick,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.value != value || old.color != color;
}
