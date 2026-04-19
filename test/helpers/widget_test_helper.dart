/// Widget test helper utilities
///
/// Provides utilities for setting up widget tests with Firebase mocking
/// and other common test configurations.
library;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sets up Firebase mocks for widget tests
///
/// This must be called in setUpAll() before any widget tests that depend
/// on Firebase services. It configures fake Firebase implementations that
/// don't require actual Firebase connections.
///
/// Example:
/// ```dart
/// setUpAll(() async {
///   setupFirebaseMocks();
/// });
/// ```
void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Setup fake Firebase platform
  setupFirebaseCoreMocks();
}

/// Sets up Firebase Core mocks
///
/// This creates a fake Firebase app that can be used in tests without
/// requiring actual Firebase initialization.
void setupFirebaseCoreMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock MethodChannel for Firebase Core
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/firebase_core'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'Firebase#initializeCore') {
            return <Map<String, dynamic>>[
              <String, dynamic>{
                'name': '[DEFAULT]',
                'options': <String, String>{
                  'apiKey': 'fake-api-key',
                  'appId': 'fake-app-id',
                  'messagingSenderId': 'fake-sender-id',
                  'projectId': 'fake-project-id',
                },
                'pluginConstants': <String, dynamic>{},
              },
            ];
          }
          if (methodCall.method == 'Firebase#initializeApp') {
            final arguments = methodCall.arguments as Map<dynamic, dynamic>?;
            return <String, dynamic>{
              'name': arguments?['appName'] as String?,
              'options': arguments?['options'] as Map<dynamic, dynamic>?,
              'pluginConstants': <String, dynamic>{},
            };
          }
          return null;
        },
      );

  // Mock MethodChannel for Cloud Firestore
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/firebase_firestore'),
        (MethodCall methodCall) async {
          // Return empty responses for Firestore operations
          if (methodCall.method == 'Firestore#settings') {
            return null;
          }
          if (methodCall.method == 'Firestore#enableNetwork') {
            return null;
          }
          if (methodCall.method == 'Firestore#disableNetwork') {
            return null;
          }
          return null;
        },
      );

  // Mock MethodChannel for Firebase Auth
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/firebase_auth'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'Auth#registerIdTokenListener') {
            return <String, dynamic>{
              'user': null, // No user logged in by default
            };
          }
          if (methodCall.method == 'Auth#registerAuthStateListener') {
            return <String, dynamic>{
              'user': null,
            };
          }
          if (methodCall.method == 'Auth#signInWithEmailAndPassword') {
            final arguments =
                methodCall.arguments as Map<Object?, Object?>? ?? const {};
            return <String, dynamic>{
              'user': <String, dynamic>{
                'uid': 'test_user_123',
                'email': arguments['email'] as String?,
                'displayName': 'Test User',
              },
            };
          }
          if (methodCall.method == 'Auth#createUserWithEmailAndPassword') {
            final arguments =
                methodCall.arguments as Map<Object?, Object?>? ?? const {};
            return <String, dynamic>{
              'user': <String, dynamic>{
                'uid': 'test_user_new_123',
                'email': arguments['email'] as String?,
                'displayName': null,
              },
            };
          }
          if (methodCall.method == 'Auth#signOut') {
            return null;
          }
          if (methodCall.method == 'Auth#sendPasswordResetEmail') {
            return null;
          }
          if (methodCall.method == 'User#updateProfile') {
            return null;
          }
          if (methodCall.method == 'Auth#currentUser') {
            return null; // No user by default
          }
          return null;
        },
      );

  // Mock MethodChannel for Agora RTC Engine
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('agora_rtc_engine'),
        (MethodCall methodCall) async {
          // Return mock responses for Agora operations
          if (methodCall.method == 'initialize') {
            return {'result': 0};
          }
          if (methodCall.method == 'joinChannel') {
            return {'result': 0};
          }
          if (methodCall.method == 'leaveChannel') {
            return {'result': 0};
          }
          if (methodCall.method == 'enableVideo') {
            return {'result': 0};
          }
          if (methodCall.method == 'enableAudio') {
            return {'result': 0};
          }
          if (methodCall.method == 'muteLocalAudioStream') {
            return {'result': 0};
          }
          if (methodCall.method == 'muteLocalVideoStream') {
            return {'result': 0};
          }
          if (methodCall.method == 'switchCamera') {
            return {'result': 0};
          }
          if (methodCall.method == 'destroy') {
            return {'result': 0};
          }
          return {'result': 0};
        },
      );

  // Mock MethodChannel for Connectivity Plus
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/connectivity'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'check') {
            return 'wifi';
          }
          if (methodCall.method == 'wifiName') {
            return 'TestWiFi';
          }
          if (methodCall.method == 'wifiBSSID') {
            return '00:00:00:00:00:00';
          }
          if (methodCall.method == 'wifiIPAddress') {
            return '192.168.1.1';
          }
          return null;
        },
      );

  // Mock MethodChannel for Flutter Secure Storage
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'read') {
            return null; // Return null for non-existent keys
          }
          if (methodCall.method == 'write') {
            return null;
          }
          if (methodCall.method == 'delete') {
            return null;
          }
          if (methodCall.method == 'deleteAll') {
            return null;
          }
          if (methodCall.method == 'readAll') {
            return <String, String>{};
          }
          return null;
        },
      );

  // Mock MethodChannel for Device Info Plus
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/device_info'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getDeviceInfo') {
            return <String, dynamic>{
              'model': 'Test Device',
              'manufacturer': 'Test Manufacturer',
              'brand': 'Test Brand',
              'device': 'test_device',
              'hardware': 'test_hardware',
              'isPhysicalDevice': true,
              'androidId': 'test_android_id',
              'systemVersion': '13',
              'version': <String, dynamic>{
                'sdkInt': 33,
                'release': '13',
              },
            };
          }
          return null;
        },
      );

  // Mock MethodChannel for Package Info Plus
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/package_info'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getAll') {
            return <String, dynamic>{
              'appName': 'AndroCare360',
              'packageName': 'com.elajtech.androcare',
              'version': '1.0.0',
              'buildNumber': '1',
            };
          }
          return null;
        },
      );

  // Mock MethodChannel for Flutter CallKit Incoming
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('flutter_callkit_incoming'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'showCallkitIncoming') {
            return null;
          }
          if (methodCall.method == 'endAllCalls') {
            return null;
          }
          if (methodCall.method == 'endCall') {
            return null;
          }
          if (methodCall.method == 'startCall') {
            return null;
          }
          return null;
        },
      );
}

/// Initializes fake Firebase for widget tests
///
/// This creates a fake Firebase app that can be used throughout the test.
/// Call this in setUp() or setUpAll() before running widget tests.
///
/// Example:
/// ```dart
/// setUp() async {
///   await initializeFakeFirebase();
/// });
/// ```
Future<void> initializeFakeFirebase() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  try {
    await Firebase.initializeApp();
  } on Exception {
    // Firebase already initialized, ignore
  }
}

/// Sets up Firebase Auth mock with a specific user
///
/// This allows tests to simulate different logged-in users.
/// Call this before creating widgets that depend on FirebaseAuth.instance.currentUser
///
/// Parameters:
/// - [uid]: The user ID to mock
/// - [email]: The user's email address
/// - [displayName]: The user's display name
///
/// Example:
/// ```dart
/// setUp(() {
///   setupFirebaseAuthMockWithUser(
///     uid: 'doctor_123',
///     email: 'doctor@example.com',
///     displayName: 'Test Doctor',
///   );
/// });
/// ```
void setupFirebaseAuthMockWithUser({
  required String uid,
  String? email,
  String? displayName,
}) {
  TestWidgetsFlutterBinding.ensureInitialized();

  final userData = <String, dynamic>{
    'uid': uid,
    'email': email,
    'displayName': displayName,
  };

  // Mock MethodChannel for Firebase Auth with specific user
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/firebase_auth'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'Auth#registerIdTokenListener') {
            return <String, dynamic>{
              'user': userData,
            };
          }
          if (methodCall.method == 'Auth#registerAuthStateListener') {
            return <String, dynamic>{
              'user': userData,
            };
          }
          if (methodCall.method == 'Auth#currentUser') {
            return userData;
          }
          if (methodCall.method == 'Auth#signInWithEmailAndPassword') {
            return <String, dynamic>{
              'user': userData,
            };
          }
          if (methodCall.method == 'Auth#signOut') {
            return null;
          }
          return null;
        },
      );
}

/// Cleans up Firebase mocks after tests
///
/// Call this in tearDown() or tearDownAll() to clean up test state.
///
/// Example:
/// ```dart
/// tearDown(() {
///   cleanupFirebaseMocks();
/// });
/// ```
void cleanupFirebaseMocks() {
  // Clear method call handlers
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/firebase_core'),
        null,
      );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/firebase_firestore'),
        null,
      );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/firebase_auth'),
        null,
      );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('agora_rtc_engine'),
        null,
      );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/connectivity'),
        null,
      );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        null,
      );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/device_info'),
        null,
      );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/package_info'),
        null,
      );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('flutter_callkit_incoming'),
        null,
      );
}
