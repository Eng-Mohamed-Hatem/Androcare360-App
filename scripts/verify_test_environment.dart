/// Test Environment Verification Script
///
/// Verifies that all test accounts and appointments are properly configured
///
/// Usage:
///   dart scripts/verify_test_environment.dart --environment [emulator|dev|prod]
library;

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestEnvironmentVerifier {
  TestEnvironmentVerifier(this.environment);

  late FirebaseAuth auth;
  late FirebaseFirestore firestore;
  final String environment;

  int totalChecks = 0;
  int passedChecks = 0;
  int failedChecks = 0;
  int warningChecks = 0;

  Future<void> initialize() async {
    await Firebase.initializeApp();

    auth = FirebaseAuth.instance;
    firestore = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'elajtech',
    );

    if (environment == 'emulator') {
      await auth.useAuthEmulator('localhost', 9099);
      firestore.useFirestoreEmulator('localhost', 8080);
      print('✅ Connected to Firebase Emulator\n');
    }
  }

  Future<bool> verifyAccount(
    String email,
    String password,
    String userType,
  ) async {
    totalChecks++;
    try {
      // Try to sign in
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user!.uid;

      // Check Firestore document
      final doc = await firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        print('  ❌ $email - Firestore document missing');
        failedChecks++;
        await auth.signOut();
        return false;
      }

      final data = doc.data()!;

      // Verify userType matches
      if (data['userType'] != userType) {
        print(
          '  ❌ $email - Wrong userType (expected: $userType, got: ${data['userType']})',
        );
        failedChecks++;
        await auth.signOut();
        return false;
      }

      // Check for FCM token
      if (!data.containsKey('fcmToken') || data['fcmToken'] == null) {
        print('  ⚠️  $email - Missing FCM token');
        warningChecks++;
      }

      print('  ✅ $email');
      passedChecks++;
      await auth.signOut();
      return true;
    } on Exception catch (e) {
      print('  ❌ $email - Error: $e');
      failedChecks++;
      return false;
    }
  }

  Future<void> verifyDoctorAccounts() async {
    print('👨‍⚕️  Verifying Doctor Accounts:');

    await verifyAccount(
      'doctor.test1@androcare360.test',
      'TestDoctor123!',
      'doctor',
    );
    await verifyAccount(
      'doctor.test2@androcare360.test',
      'TestDoctor123!',
      'doctor',
    );
    await verifyAccount(
      'doctor.test3@androcare360.test',
      'TestDoctor123!',
      'doctor',
    );

    print('');
  }

  Future<void> verifyPatientAccounts() async {
    print('👤 Verifying Patient Accounts:');

    await verifyAccount(
      'patient.test1@androcare360.test',
      'TestPatient123!',
      'patient',
    );
    await verifyAccount(
      'patient.test2@androcare360.test',
      'TestPatient123!',
      'patient',
    );
    await verifyAccount(
      'patient.test3@androcare360.test',
      'TestPatient123!',
      'patient',
    );
    await verifyAccount(
      'patient.test4@androcare360.test',
      'TestPatient123!',
      'patient',
    );
    await verifyAccount(
      'patient.test5@androcare360.test',
      'TestPatient123!',
      'patient',
    );

    print('');
  }

  Future<void> verifyAppointments() async {
    print('📅 Verifying Appointments:');

    final expectedAppointments = [
      'apt_test_001',
      'apt_test_002',
      'apt_test_003',
      'apt_test_004',
      'apt_test_005',
      'apt_test_006',
      'apt_test_007',
      'apt_test_008',
      'apt_test_009',
      'apt_test_010',
    ];

    for (final aptId in expectedAppointments) {
      totalChecks++;
      try {
        final doc = await firestore.collection('appointments').doc(aptId).get();

        if (!doc.exists) {
          print('  ❌ $aptId - Not found');
          failedChecks++;
          continue;
        }

        final data = doc.data()!;

        // Verify required fields
        final requiredFields = [
          'doctorId',
          'patientId',
          'status',
          'scheduledAt',
        ];
        final missingFields = <String>[];

        for (final field in requiredFields) {
          if (!data.containsKey(field)) {
            missingFields.add(field);
          }
        }

        if (missingFields.isNotEmpty) {
          print('  ❌ $aptId - Missing fields: ${missingFields.join(", ")}');
          failedChecks++;
          continue;
        }

        // Verify doctor and patient exist
        final doctorId = data['doctorId'] as String?;
        final patientId = data['patientId'] as String?;

        if (doctorId == null || patientId == null) {
          print('  ❌ $aptId - Invalid doctor or patient ID');
          failedChecks++;
          continue;
        }

        final doctorExists = await firestore
            .collection('users')
            .doc(doctorId)
            .get()
            .then((doc) => doc.exists);

        final patientExists = await firestore
            .collection('users')
            .doc(patientId)
            .get()
            .then((doc) => doc.exists);

        if (!doctorExists || !patientExists) {
          print('  ❌ $aptId - Invalid doctor or patient reference');
          failedChecks++;
          continue;
        }

        print('  ✅ $aptId (${data['status']})');
        passedChecks++;
      } on Exception catch (e) {
        print('  ❌ $aptId - Error: $e');
        failedChecks++;
      }
    }

    print('');
  }

  Future<void> verifyFirestoreCollections() async {
    print('🗄️  Verifying Firestore Collections:');

    // Check users collection
    totalChecks++;
    try {
      final usersSnapshot = await firestore.collection('users').limit(10).get();

      if (usersSnapshot.docs.isEmpty) {
        print('  ⚠️  users - Empty collection');
        warningChecks++;
      } else {
        print('  ✅ users - ${usersSnapshot.docs.length} documents found');
        passedChecks++;
      }
    } on Exception catch (e) {
      print('  ❌ users - Error: $e');
      failedChecks++;
    }

    // Check appointments collection
    totalChecks++;
    try {
      final appointmentsSnapshot = await firestore
          .collection('appointments')
          .limit(10)
          .get();

      if (appointmentsSnapshot.docs.isEmpty) {
        print('  ⚠️  appointments - Empty collection');
        warningChecks++;
      } else {
        print(
          '  ✅ appointments - ${appointmentsSnapshot.docs.length} documents found',
        );
        passedChecks++;
      }
    } on Exception catch (e) {
      print('  ❌ appointments - Error: $e');
      failedChecks++;
    }

    // Check call_logs collection exists (may be empty)
    totalChecks++;
    try {
      await firestore.collection('call_logs').limit(1).get();

      print('  ✅ call_logs - Collection accessible');
      passedChecks++;
    } on Exception catch (_) {
      print(
        '  ⚠️  call_logs - Collection not accessible (will be created on first call)',
      );
      warningChecks++;
      passedChecks++; // Not a failure
    }

    print('');
  }

  Future<void> verifyDatabaseConfiguration() async {
    print('⚙️  Verifying Database Configuration:');

    totalChecks++;
    try {
      // Try to read from Firestore to verify database ID is correct
      await firestore.collection('users').limit(1).get();

      print('  ✅ Database ID: elajtech (verified)');
      passedChecks++;
    } on Exception catch (e) {
      print('  ❌ Database configuration error: $e');
      failedChecks++;
    }

    print('');
  }

  void printSummary() {
    print('=' * 60);
    print('📊 VERIFICATION SUMMARY');
    print('=' * 60);
    print('');
    print('Total Checks: $totalChecks');
    print('✅ Passed: $passedChecks');
    print('❌ Failed: $failedChecks');
    print('⚠️  Warnings: $warningChecks');
    print('');

    final percentage = totalChecks > 0
        ? (passedChecks / totalChecks * 100).toStringAsFixed(1)
        : '0.0';
    print('Success Rate: $percentage%');
    print('');

    if (failedChecks == 0 && warningChecks == 0) {
      print('🎉 Perfect! All checks passed. Environment is ready for testing.');
    } else if (failedChecks == 0) {
      print('✅ All critical checks passed. Warnings can be ignored.');
      print('   Environment is ready for testing.');
    } else {
      print('⚠️  Some checks failed. Review errors above.');
      print('');
      print('💡 To fix issues:');
      print(
        '   1. Run: dart scripts/create_test_accounts.dart --environment $environment',
      );
      print(
        '   2. Run: dart scripts/create_test_appointments.dart --environment $environment',
      );
      print('   3. Run this verification script again');
    }

    print('=' * 60);
  }

  Future<void> printDetailedReport() async {
    print('\n📋 DETAILED ENVIRONMENT REPORT');
    print('=' * 60);
    print('');

    // Count actual documents
    final usersCount = await firestore
        .collection('users')
        .get()
        .then((snapshot) => snapshot.docs.length);

    final appointmentsCount = await firestore
        .collection('appointments')
        .get()
        .then((snapshot) => snapshot.docs.length);

    print('📊 Database Statistics:');
    print('  - Users: $usersCount (expected: 8)');
    print('  - Appointments: $appointmentsCount (expected: 10)');
    print('');

    // List all users
    print('👥 User Accounts:');
    final users = await firestore.collection('users').orderBy('userType').get();

    for (final doc in users.docs) {
      final data = doc.data();
      final email = data['email'] ?? 'N/A';
      final userType = data['userType'] ?? 'N/A';
      final fullName = data['fullName'] ?? 'N/A';
      print('  - $email ($userType) - $fullName');
    }
    print('');

    // List all appointments
    print('📅 Appointments:');
    final appointments = await firestore.collection('appointments').get();

    for (final doc in appointments.docs) {
      final data = doc.data();
      final status = data['status'] ?? 'N/A';
      print('  - ${doc.id} ($status)');
    }
    print('');

    print('=' * 60);
  }
}

void main(List<String> args) async {
  var environment = 'emulator';
  var detailed = false;

  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--environment' && i + 1 < args.length) {
      environment = args[i + 1];
    }
    if (args[i] == '--detailed') {
      detailed = true;
    }
  }

  print('\n🔍 AndroCare360 Test Environment Verifier');
  print('Environment: $environment');
  print('=' * 60);
  print('');

  try {
    final verifier = TestEnvironmentVerifier(environment);
    await verifier.initialize();

    await verifier.verifyDatabaseConfiguration();
    await verifier.verifyFirestoreCollections();
    await verifier.verifyDoctorAccounts();
    await verifier.verifyPatientAccounts();
    await verifier.verifyAppointments();

    verifier.printSummary();

    if (detailed) {
      await verifier.printDetailedReport();
    }

    exit(verifier.failedChecks == 0 ? 0 : 1);
  } on Exception catch (e, stackTrace) {
    print('\n❌ Fatal error: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}
