import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const Color skyTop = Color(0xFF4766B2);
  static const Color navy = Color(0xFF1D2F66);
  static const Color deep = Color(0xFF0E1A3F);
  static const Color night = Color(0xFF050A1C);
  static const Color black = Color(0xFF02040A);
  static const Color accent = Color(0xFF3FA2FF);
  static const Color ink = Color(0xFF14204A);
  static const Color muted = Color(0xFFA9B6DC);
  static const Color mutedInk = Color(0xFF5C6A94);
  static const Color safe = Color(0xFF22C48A);
  static const Color warn = Color(0xFFFFB020);
  static const Color danger = Color(0xFFFF5A6B);

  static Color alpha(Color c, double opacity) =>
      c.withAlpha((opacity * 255).round().clamp(0, 255).toInt());
}

class AppGradients {
  AppGradients._();
  static const LinearGradient screen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4766B2), Color(0xFF1C2E66), Color(0xFF0A1230)],
    stops: [0.0, 0.45, 1.0],
  );
  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4766B2), Color(0xFF14224F), Color(0xFF02040A)],
    stops: [0.0, 0.55, 1.0],
  );
  static const LinearGradient accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3FA2FF), Color(0xFF2B5FD9)],
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData build() {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.accent,
        surface: AppColors.deep,
        error: AppColors.danger,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.deep,
      textTheme: base.textTheme
          .apply(bodyColor: Colors.white, displayColor: Colors.white),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}
