import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_preview/device_preview.dart';
import 'package:device_preview/presets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/constants.dart';
import 'core/keys.dart';
import 'core/theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/app_root.dart';
import 'services/auth_service.dart';
import 'services/cloudinary_service.dart';
import 'services/firestore_service.dart';
import 'services/groq_service.dart';

Future<void> main() async {
  // Enable Device Preview BEFORE initializing the binding
  DevicePreview.enable(enabled: kDebugMode && kIsWeb);
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Initialize Firebase Cloud Messaging for push notifications
  if (!kIsWeb) {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.deep,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  
  // Apply a device preset to see the device frame
  if (kDebugMode && kIsWeb) {
    final controller = DevicePreview.maybeController;
    if (controller != null) {
      await controller.applyPreset(DevicePresets.iPhone16);
    }
  }
  
  runApp(const CyberGuardApp());
}

class CyberGuardApp extends StatelessWidget {
  const CyberGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<GroqService>(create: (_) => GroqService()),
        Provider<CloudinaryService>(create: (_) => CloudinaryService()),
        Provider<ThreatAnalyzer>(
          create: (c) => ThreatAnalyzer(c.read<GroqService>()),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (c) => AuthProvider(c.read<AuthService>()),
        ),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(),
        scaffoldMessengerKey: rootMessengerKey,
        builder: (context, child) {
          return MediaQuery.withClampedTextScaling(
            minScaleFactor: 0.9,
            maxScaleFactor: 1.2,
            child: child!,
          );
        },
        home: const AppRoot(),
      ),
    );
  }
}
