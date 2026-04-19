/// Firebase Emulator helper utilities for integration testing
///
/// Provides utilities for setting up and managing Firebase emulator
/// connections during integration tests. This ensures tests run against
/// local emulators instead of production Firebase services.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../fixtures/user_fixtures.dart';
import '../fixtures/appointment_fixtures.dart';

/// Firebase Emulator configuration and utilities
class FirebaseEmulatorHelper {
  /// Firestore emulator host
  static const String firestoreHost = 'localhost';

  /// Firestore emulator port
  static const int firestorePort = 8080;

  /// Auth emulator host
  static const String authHost = 'localhost';

  /// Auth emulator port
  static const int authPort = 9099;

  /// Functions emulator host (europe-west1 region)
  static const String functionsHost = 'localhost';

  /// Functions emulator port
  static const int functionsPort = 5001;

  /// Database ID for elajtech project
  static const String databaseId = 'elajtech';

  /// Sets up Firebase emulator connections
  ///
  /// This must be called before any Firebase operations in integration tests.
  /// It configures Firestore, Auth, and Functions to use local emulators.
  ///
  /// Example:
  /// ```dart
  /// await FirebaseEmulatorHelper.setupEmulator();
  /// ```
  static Future<void> setupEmulator() async {
    try {
      // Initialize Firebase if not already initialized
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // Connect to Firestore emulator with elajtech database
      FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: databaseId,
      ).useFirestoreEmulator(firestoreHost, firestorePort);

      // Connect to Auth emulator
      await FirebaseAuth.instance.useAuthEmulator(authHost, authPort);

      if (kDebugMode) {
        debugPrint('✅ Firebase Emulator connected successfully');
        debugPrint(
          '   Firestore: $firestoreHost:$firestorePort (db: $databaseId)',
        );
        debugPrint('   Auth: $authHost:$authPort');
        debugPrint('   Functions: $functionsHost:$functionsPort');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to setup Firebase Emulator: $e');
      }
      rethrow;
    }
  }

  /// Clears all data from Firestore emulator
  ///
  /// This should be called before each test to ensure a clean state.
  /// It deletes all documents from all collections.
  ///
  /// Example:
  /// ```dart
  /// await FirebaseEmulatorHelper.clearFirestore();
  /// ```
  static Future<void> clearFirestore() async {
    try {
      final firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: databaseId,
      );

      // List of collections to clear
      final collections = [
        'users',
        'appointments',
        'call_logs',
        'nutrition_emrs',
        'physiotherapy_emrs',
        'notifications',
        'chat_messages',
      ];

      for (final collection in collections) {
        final snapshot = await firestore.collection(collection).get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }

      if (kDebugMode) {
        debugPrint('✅ Firestore emulator cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to clear Firestore: $e');
      }
      rethrow;
    }
  }

  /// Seeds test data into Firestore emulator
  ///
  /// Creates test users, appointments, and other necessary data
  /// for integration tests.
  ///
  /// Example:
  /// ```dart
  /// await FirebaseEmulatorHelper.seedTestData();
  /// ```
  static Future<void> seedTestData() async {
    try {
      final firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: databaseId,
      );

      // Seed test users
      final doctor = UserFixtures.createDoctor();
      await firestore.collection('users').doc(doctor.id).set(doctor.toJson());

      final patient = UserFixtures.createPatient();
      await firestore.collection('users').doc(patient.id).set(patient.toJson());

      final physioDoctor = UserFixtures.createPhysiotherapyDoctor();
      await firestore
          .collection('users')
          .doc(physioDoctor.id)
          .set(physioDoctor.toJson());

      // Seed test appointments
      final pendingAppointment = AppointmentFixtures.createPendingAppointment();
      await firestore
          .collection('appointments')
          .doc(pendingAppointment.id)
          .set(pendingAppointment.toJson());

      final confirmedAppointment =
          AppointmentFixtures.createConfirmedAppointment();
      await firestore
          .collection('appointments')
          .doc(confirmedAppointment.id)
          .set(confirmedAppointment.toJson());

      if (kDebugMode) {
        debugPrint('✅ Test data seeded successfully');
        debugPrint('   Users: ${doctor.id}, ${patient.id}, ${physioDoctor.id}');
        debugPrint(
          '   Appointments: ${pendingAppointment.id}, ${confirmedAppointment.id}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to seed test data: $e');
      }
      rethrow;
    }
  }

  /// Creates a test user in Auth emulator
  ///
  /// Parameters:
  /// - [email]: User email
  /// - [password]: User password
  /// - [uid]: Optional custom UID
  ///
  /// Returns the created User
  static Future<User?> createTestUser({
    required String email,
    required String password,
    String? uid,
  }) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

      if (kDebugMode) {
        debugPrint('✅ Test user created: $email');
      }

      return userCredential.user;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to create test user: $e');
      }
      rethrow;
    }
  }

  /// Signs in a test user
  ///
  /// Parameters:
  /// - [email]: User email
  /// - [password]: User password
  ///
  /// Returns the signed-in User
  static Future<User?> signInTestUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: email,
            password: password,
          );

      if (kDebugMode) {
        debugPrint('✅ Test user signed in: $email');
      }

      return userCredential.user;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to sign in test user: $e');
      }
      rethrow;
    }
  }

  /// Signs out the current user
  static Future<void> signOutTestUser() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (kDebugMode) {
        debugPrint('✅ Test user signed out');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to sign out test user: $e');
      }
      rethrow;
    }
  }

  /// Gets a document from Firestore
  ///
  /// Parameters:
  /// - [collection]: Collection name
  /// - [docId]: Document ID
  ///
  /// Returns the document data as Map or null if not found
  static Future<Map<String, dynamic>?> getDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      final firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: databaseId,
      );

      final doc = await firestore.collection(collection).doc(docId).get();
      return doc.data();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to get document: $e');
      }
      rethrow;
    }
  }

  /// Gets all documents from a collection
  ///
  /// Parameters:
  /// - [collection]: Collection name
  ///
  /// Returns list of document data
  static Future<List<Map<String, dynamic>>> getCollection({
    required String collection,
  }) async {
    try {
      final firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: databaseId,
      );

      final snapshot = await firestore.collection(collection).get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to get collection: $e');
      }
      rethrow;
    }
  }

  /// Verifies a document exists in Firestore
  ///
  /// Parameters:
  /// - [collection]: Collection name
  /// - [docId]: Document ID
  ///
  /// Returns true if document exists
  static Future<bool> documentExists({
    required String collection,
    required String docId,
  }) async {
    try {
      final firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: databaseId,
      );

      final doc = await firestore.collection(collection).doc(docId).get();
      return doc.exists;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to check document existence: $e');
      }
      rethrow;
    }
  }

  /// Waits for a document to exist in Firestore
  ///
  /// Useful for testing async operations that create documents
  ///
  /// Parameters:
  /// - [collection]: Collection name
  /// - [docId]: Document ID
  /// - [timeout]: Maximum wait time (defaults to 10 seconds)
  ///
  /// Returns true if document exists within timeout
  static Future<bool> waitForDocument({
    required String collection,
    required String docId,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final endTime = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(endTime)) {
      if (await documentExists(collection: collection, docId: docId)) {
        return true;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    return false;
  }

  /// Cleans up after tests
  ///
  /// Clears Firestore and signs out user
  static Future<void> cleanup() async {
    await clearFirestore();
    await signOutTestUser();

    if (kDebugMode) {
      debugPrint('✅ Test cleanup completed');
    }
  }
}
