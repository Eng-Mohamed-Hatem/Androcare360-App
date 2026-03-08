/// Integration Test Configuration Helper
///
/// This helper provides utilities for connecting to Firebase Emulators
/// during integration testing.
///
/// **Usage:**
/// ```dart
/// void main() {
///   setUpAll(() async {
///     await IntegrationTestConfig.connectToEmulators();
///   });
///
///   tearDownAll(() async {
///     await IntegrationTestConfig.cleanup();
///   });
/// }
/// ```
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Configuration for Firebase Emulators
class IntegrationTestConfig {
  // Emulator configuration (matches firebase.json)
  static const String _firestoreHost = 'localhost';
  static const int _firestorePort = 8080;

  static const String _authHost = 'localhost';
  static const int _authPort = 9099;

  static const String _functionsHost = 'localhost';
  static const int _functionsPort = 5001;

  static const String _functionsRegion = 'europe-west1';

  static const String _databaseId = 'elajtech';

  static bool _isConnected = false;

  /// Connect to Firebase Emulators
  ///
  /// This method configures Firebase services to use local emulators
  /// instead of production services.
  ///
  /// **CRITICAL**: Must be called before any Firebase operations in tests.
  ///
  /// **IMPORTANT NOTE**: Firebase Emulators do NOT support custom database IDs.
  /// The emulator always uses the default database ID `(default)`.
  /// In production, we use `databaseId: 'elajtech'`, but in tests with emulators,
  /// we must use the default database.
  static Future<void> connectToEmulators() async {
    if (_isConnected) {
      if (kDebugMode) {
        print('✅ Already connected to Firebase Emulators');
      }
      return;
    }

    try {
      // Initialize Firebase if not already initialized
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      if (kDebugMode) {
        print('🔧 [INIT] Connecting to Firebase Emulators...');
      }

      // Connect Firestore to emulator
      // CRITICAL: Must use default database with emulators
      // Emulators do NOT support custom database IDs
      final firestore = FirebaseFirestore.instance;
      firestore.useFirestoreEmulator(_firestoreHost, _firestorePort);

      if (kDebugMode) {
        print(
          '✅ [FIRESTORE] Connected to emulator: $_firestoreHost:$_firestorePort',
        );
        print('🔧 [INIT] Firestore Database ID: (default)');
        print(
          '⚠️  [NOTE] Emulators use (default) database, not $_databaseId',
        );
      }

      // Connect Auth to emulator
      await FirebaseAuth.instance.useAuthEmulator(_authHost, _authPort);

      if (kDebugMode) {
        print('✅ [AUTH] Connected to emulator: $_authHost:$_authPort');
      }

      // Connect Functions to emulator
      final functions = FirebaseFunctions.instanceFor(region: _functionsRegion);
      functions.useFunctionsEmulator(_functionsHost, _functionsPort);

      if (kDebugMode) {
        print(
          '✅ [FUNCTIONS] Connected to emulator: $_functionsHost:$_functionsPort',
        );
        print('   Region: $_functionsRegion');
      }

      _isConnected = true;

      if (kDebugMode) {
        print('🎉 All Firebase services connected to emulators');
        print('');
        print('📋 Configuration Summary:');
        print(
          '   - Firestore: $_firestoreHost:$_firestorePort (default database)',
        );
        print('   - Auth: $_authHost:$_authPort');
        print(
          '   - Functions: $_functionsHost:$_functionsPort ($_functionsRegion)',
        );
        print('');
      }
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error connecting to Firebase Emulators: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  /// Get Firestore instance configured for emulator
  ///
  /// **CRITICAL**: Always use this method to get Firestore instance in tests
  /// to ensure correct emulator configuration.
  ///
  /// **NOTE**: Emulators use the default database `(default)`, not `elajtech`.
  /// This is a limitation of Firebase Emulators.
  static FirebaseFirestore getFirestore() {
    if (!_isConnected) {
      throw StateError(
        'Firebase Emulators not connected. '
        'Call IntegrationTestConfig.connectToEmulators() first.',
      );
    }

    // Return the default Firestore instance (connected to emulator)
    return FirebaseFirestore.instance;
  }

  /// Get Functions instance configured for emulator
  static FirebaseFunctions getFunctions() {
    if (!_isConnected) {
      throw StateError(
        'Firebase Emulators not connected. '
        'Call IntegrationTestConfig.connectToEmulators() first.',
      );
    }

    return FirebaseFunctions.instanceFor(region: _functionsRegion);
  }

  /// Get Auth instance (automatically configured for emulator)
  static FirebaseAuth getAuth() {
    if (!_isConnected) {
      throw StateError(
        'Firebase Emulators not connected. '
        'Call IntegrationTestConfig.connectToEmulators() first.',
      );
    }

    return FirebaseAuth.instance;
  }

  /// Clear all data from Firestore emulator
  ///
  /// Useful for resetting state between tests.
  static Future<void> clearFirestoreData() async {
    if (!_isConnected) {
      throw StateError(
        'Firebase Emulators not connected. '
        'Call IntegrationTestConfig.connectToEmulators() first.',
      );
    }

    try {
      final firestore = getFirestore();

      // Clear common collections
      final collections = [
        'users',
        'appointments',
        'call_logs',
        'emr_records',
        'prescriptions',
        'lab_requests',
        'radiology_requests',
      ];

      for (final collection in collections) {
        final snapshot = await firestore.collection(collection).get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }

      if (kDebugMode) {
        print('🧹 Firestore data cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error clearing Firestore data: $e');
      }
      // Don't rethrow - clearing data is best effort
    }
  }

  /// Sign out all users from Auth emulator
  static Future<void> signOutAllUsers() async {
    if (!_isConnected) {
      throw StateError(
        'Firebase Emulators not connected. '
        'Call IntegrationTestConfig.connectToEmulators() first.',
      );
    }

    try {
      final auth = getAuth();
      if (auth.currentUser != null) {
        await auth.signOut();
        if (kDebugMode) {
          print('🚪 User signed out');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error signing out user: $e');
      }
      // Don't rethrow - sign out is best effort
    }
  }

  /// Cleanup - reset connection state
  ///
  /// Call this in tearDownAll() to reset state.
  static Future<void> cleanup() async {
    await signOutAllUsers();
    await clearFirestoreData();
    _isConnected = false;

    if (kDebugMode) {
      print('✅ Integration test cleanup complete');
    }
  }

  /// Create a test user in Auth emulator
  ///
  /// Returns the created user's UID.
  static Future<String> createTestUser({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (!_isConnected) {
      throw StateError(
        'Firebase Emulators not connected. '
        'Call IntegrationTestConfig.connectToEmulators() first.',
      );
    }

    try {
      final auth = getAuth();
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (displayName != null && userCredential.user != null) {
        await userCredential.user!.updateDisplayName(displayName);
      }

      final uid = userCredential.user!.uid;

      if (kDebugMode) {
        print('👤 Test user created: $email (UID: $uid)');
      }

      return uid;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating test user: $e');
      }
      rethrow;
    }
  }

  /// Sign in a test user
  static Future<User> signInTestUser({
    required String email,
    required String password,
  }) async {
    if (!_isConnected) {
      throw StateError(
        'Firebase Emulators not connected. '
        'Call IntegrationTestConfig.connectToEmulators() first.',
      );
    }

    try {
      final auth = getAuth();
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        print('🔐 Test user signed in: $email');
      }

      return userCredential.user!;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error signing in test user: $e');
      }
      rethrow;
    }
  }

  /// Create a test document in Firestore
  static Future<void> createTestDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    if (!_isConnected) {
      throw StateError(
        'Firebase Emulators not connected. '
        'Call IntegrationTestConfig.connectToEmulators() first.',
      );
    }

    try {
      final firestore = getFirestore();
      await firestore.collection(collection).doc(documentId).set(data);

      if (kDebugMode) {
        print('📄 Test document created: $collection/$documentId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating test document: $e');
      }
      rethrow;
    }
  }

  /// Verify emulators are running
  ///
  /// Returns true if emulators are accessible, false otherwise.
  static Future<bool> verifyEmulatorsRunning() async {
    try {
      // Try to connect to Firestore emulator
      final firestore = FirebaseFirestore.instance;
      firestore.useFirestoreEmulator(_firestoreHost, _firestorePort);

      // Try a simple operation
      await firestore.collection('_test').limit(1).get();

      if (kDebugMode) {
        print('✅ Emulators are running and accessible');
      }

      return true;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('❌ Emulators not accessible: $e');
        print('   Make sure to run: firebase emulators:start');
      }
      return false;
    }
  }
}
