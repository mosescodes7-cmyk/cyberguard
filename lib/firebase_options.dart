// Firebase project: final-yearprojects
// Android app: com.example.cyberguard   Web app: registered in the same project.
// Add an iOS app in the Firebase console and run flutterfire configure if you need iOS.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Firebase is not configured for this platform. '
          'Register the app in the Firebase console and run flutterfire configure.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCSqZbIYydwA41-ikzdDzyVGa63Wndtw1A',
    appId: '1:744346933107:web:50aa009de61e1d9c721706',
    messagingSenderId: '744346933107',
    projectId: 'final-yearprojects',
    authDomain: 'final-yearprojects.firebaseapp.com',
    databaseURL: 'https://final-yearprojects-default-rtdb.firebaseio.com',
    storageBucket: 'final-yearprojects.firebasestorage.app',
    measurementId: 'G-R7JYKL5FTW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBcjOHVQLSRlg_Zl5mel0Z2SEi0IYoYo78',
    appId: '1:744346933107:android:4912e9384a89c7f6721706',
    messagingSenderId: '744346933107',
    projectId: 'final-yearprojects',
    databaseURL: 'https://final-yearprojects-default-rtdb.firebaseio.com',
    storageBucket: 'final-yearprojects.firebasestorage.app',
  );
}
