import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

class NotificationService {
  NotificationService._();

  static const _prefKey = 'alerts_enabled';
  static bool _listening = false;

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? true;
  }

  /// Call once after sign in. Topic subscription is not available on web.
  static Future<void> init(GlobalKey<ScaffoldMessengerState> messenger) async {
    if (kIsWeb) return;
    try {
      final fcm = FirebaseMessaging.instance;
      if (await isEnabled()) {
        await fcm.requestPermission();
        await fcm.subscribeToTopic(AppConfig.alertsTopic);
      }
      if (!_listening) {
        _listening = true;
        FirebaseMessaging.onMessage.listen((msg) {
          final n = msg.notification;
          if (n == null) return;
          messenger.currentState?.showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 6),
              content: Text(
                [n.title, n.body].whereType<String>().join('\n'),
              ),
            ),
          );
        });
      }
    } catch (_) {}
  }

  static Future<void> setEnabled(bool on) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, on);
    if (kIsWeb) return;
    try {
      final fcm = FirebaseMessaging.instance;
      if (on) {
        await fcm.requestPermission();
        await fcm.subscribeToTopic(AppConfig.alertsTopic);
      } else {
        await fcm.unsubscribeFromTopic(AppConfig.alertsTopic);
      }
    } catch (_) {}
  }
}
