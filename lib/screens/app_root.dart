import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'home/main_shell.dart';
import 'onboarding_screen.dart';
import 'splash_screen.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  static const _seenKey = 'onboarding_seen';
  bool _splashDone = false;
  bool _onboardingSeen = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Always show onboarding - commented out the seen check
    // var seen = false;
    // try {
    //   final prefs = await SharedPreferences.getInstance();
    //   seen = prefs.getBool(_seenKey) ?? false;
    // } catch (_) {}
    await Future<void>.delayed(const Duration(milliseconds: 5000));
    if (!mounted) return;
    setState(() {
      _onboardingSeen = false; // Always show onboarding
      _splashDone = true;
    });
  }

  Future<void> _finishOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_seenKey, true);
    } catch (_) {}
    if (!mounted) return;
    setState(() => _onboardingSeen = true);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    Widget child;
    if (!_splashDone || !auth.initialized) {
      child = const SplashScreen(key: ValueKey('splash'));
    } else if (auth.isSignedIn) {
      child = const MainShell(key: ValueKey('shell'));
    } else if (!_onboardingSeen) {
      child = OnboardingScreen(
        key: const ValueKey('onboarding'),
        onFinished: _finishOnboarding,
      );
    } else {
      child = const LoginScreen(key: ValueKey('login'));
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      child: child,
    );
  }
}
