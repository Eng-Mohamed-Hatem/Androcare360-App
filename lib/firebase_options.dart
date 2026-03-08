// File generated based on google-services.json and Firebase Console
// For full configuration, run: flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'run flutterfire configure to add macos support.',
        );
      case TargetPlatform.windows:
        return android; // Use Android config for Windows desktop testing
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'run flutterfire configure to add linux support.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Web configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCCAvjopqHF0_1e3_NuoH6wNJCof8ReptU',
    appId: '1:375824242048:web:8bbdea84f709a608ea5d65',
    messagingSenderId: '375824242048',
    projectId: 'elajtech-fc804',
    authDomain: 'elajtech-fc804.firebaseapp.com',
    storageBucket: 'elajtech-fc804.firebasestorage.app',
    measurementId: 'G-M32DG8WG25',
  );

  // Android configuration
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB9LzRlJtQuzv8Z5DiY2bLvRuW8eB49P2Y',
    appId: '1:375824242048:android:1db0ad1ed58dd565ea5d65',
    messagingSenderId: '375824242048',
    projectId: 'elajtech-fc804',
    storageBucket: 'elajtech-fc804.firebasestorage.app',
  );

  // iOS configuration - update these values when you add iOS app to Firebase
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB9LzRlJtQuzv8Z5DiY2bLvRuW8eB49P2Y',
    appId: '1:375824242048:android:1db0ad1ed58dd565ea5d65',
    messagingSenderId: '375824242048',
    projectId: 'elajtech-fc804',
    storageBucket: 'elajtech-fc804.firebasestorage.app',
    iosBundleId: 'com.example.elajtech',
  );
}
