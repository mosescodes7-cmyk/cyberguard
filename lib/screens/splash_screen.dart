import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../widgets/gradient_background.dart';
import '../widgets/pentagon_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5000),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final logo = math.min(size.shortestSide * 0.6, 280.0);
    return Scaffold(
      body: GradientBackground(
        gradient: AppGradients.hero,
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final t = Curves.easeOutCubic.transform(_c.value);
              final text = Curves.easeIn.transform(((_c.value - 0.5) / 0.5).clamp(0.0, 1.0));
              return Column(
                children: [
                  const Spacer(flex: 3),
                  PentagonMark(size: logo, progress: t, rotation: _c.value * 0.6),
                  const SizedBox(height: 36),
                  Opacity(
                    opacity: text,
                    child: Column(
                      children: [
                        Text(
                          AppConfig.appName,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppConfig.tagline,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            color: AppColors.muted,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 3),
                  Opacity(
                    opacity: text,
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 28),
                      child: Column(
                        children: [
                          Text(
                            'Mbarara City',
                            style: TextStyle(color: AppColors.muted, fontSize: 13, letterSpacing: 1),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Developed by',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'AINEMBABAZI LAUBEN',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '23/BIT/013/UMR',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'METROPOLITAN INTERNATIONAL',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            'UNIVERSITY',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
