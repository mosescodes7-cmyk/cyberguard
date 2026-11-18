import 'package:flutter/material.dart';

class Responsive {
  Responsive._();
  static double width(BuildContext c) => MediaQuery.sizeOf(c).width;
  static bool isWide(BuildContext c) => width(c) >= 860;
  static double hPad(BuildContext c) {
    final w = width(c);
    if (w < 360) return 16;
    if (w < 600) return 20;
    return 28;
  }
}

class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 460,
  });
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
