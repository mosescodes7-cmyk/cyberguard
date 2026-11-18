import 'package:flutter/material.dart';

import '../core/theme.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    required this.child,
    this.gradient = AppGradients.screen,
  });

  final Widget child;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      // Transparent Material lets InkWell splashes show above the gradient.
      child: Material(
        type: MaterialType.transparency,
        child: SizedBox.expand(child: child),
      ),
    );
  }
}
