import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages here if needed
  debugPrint('Background message: ${message.messageId}');
}

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
      
      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Request permission and set foreground notification options
      final settings = await fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      debugPrint('FCM Permission: ${settings.authorizationStatus}');
      
      // Enable foreground notifications (shows as push notifications even when app is open)
      await fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      
      if (await isEnabled()) {
        await fcm.subscribeToTopic(AppConfig.alertsTopic);
        debugPrint('Subscribed to topic: ${AppConfig.alertsTopic}');
      }
      
      // Handle foreground messages (when app is open)
      if (!_listening) {
        _listening = true;
        FirebaseMessaging.onMessage.listen((msg) {
          final n = msg.notification;
          if (n == null) return;
          
          // Show in-app SnackBar as well for immediate visibility
          messenger.currentState?.showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 6),
              backgroundColor: Colors.orange.shade800,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (n.title != null)
                    Text(
                      n.title!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  if (n.title != null && n.body != null) const SizedBox(height: 4),
                  if (n.body != null) Text(n.body!),
                ],
              ),
            ),
          );
        });
        
        // Handle notification taps (when user clicks notification)
        FirebaseMessaging.onMessageOpenedApp.listen((message) {
          debugPrint('Notification clicked: ${message.messageId}');
          // You can navigate to specific screens here based on message data
        });
      }
    } catch (e) {
      debugPrint('FCM init error: $e');
    }
  }

  static Future<void> setEnabled(bool on) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, on);
    if (kIsWeb) return;
    try {
      final fcm = FirebaseMessaging.instance;
      if (on) {
        await fcm.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        await fcm.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
        await fcm.subscribeToTopic(AppConfig.alertsTopic);
        debugPrint('Enabled notifications and subscribed');
      } else {
        await fcm.unsubscribeFromTopic(AppConfig.alertsTopic);
        debugPrint('Unsubscribed from notifications');
      }
    } catch (e) {
      debugPrint('FCM toggle error: $e');
    }
  }
}
