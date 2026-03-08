/// Test Account Creation Script
///
/// Creates test doctor and patient accounts in Firebase Auth and Firestore
///
/// Usage:
///   dart scripts/create_test_accounts.dart --environment [emulator|dev|prod]
///
/// Example:
///   dart scripts/create_test_accounts.dart --environment emulator
library;

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Test account data structure
class TestAccountData {
  TestAccountData({
    required this.email,
    required this.password,
    required this.fullName,
    required this.userType,
    this.specialization,
  });

  final String email;
  final String password;
  final String fullName;
  final String userType;
  final String? specialization;
}

class TestAccountCreator {
  TestAccountCreator(this.environment);

  late FirebaseAuth auth;
  late FirebaseFirestore firestore;
  final String environment;

  /// Initialize Firebase connection
  Future<void> initialize() async {
    await Firebase.initializeApp();

    auth = FirebaseAuth.instance;
    firestore = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'elajtech', // ⚠️ CRITICAL: Custom database ID
    );

    // Connect to emulator if specified
    if (environment == 'emulator') {
      print('🔧 Connecting to Firebase Emulator...');
      await auth.useAuthEmulator('localhost', 9099);
      firestore.useFirestoreEmulator('localhost', 8080);
      print('✅ Connected to Firebase Emulator');
    } else {
      print('🌐 Using Firebase $environment environment');
    }
  }

  /// Create a single test account
  Future<String?> createAccount(TestAccountData data) async {
    try {
      print('\n📝 Creating account: ${data.email}');

      // Step 1: Create Firebase Auth user
      UserCredential userCredential;
      try {
        userCredential = await auth.createUserWithEmailAndPassword(
          email: data.email,
          password: data.password,
        );
        print('  ✅ Firebase Auth user created');
      } catch (e) {
        if (e.toString().contains('email-already-in-use')) {
          print('  ⚠️  Account already exists, skipping Auth creation');
          // Try to sign in to get UID
          userCredential = await auth.signInWithEmailAndPassword(
            email: data.email,
            password: data.password,
          );
        } else {
          rethrow;
        }
      }

      final uid = userCredential.user!.uid;
      print('  📌 UID: $uid');

      // Step 2: Create Firestore user document
      final userData = {
        'email': data.email,
        'fullName': data.fullName,
        'userType': data.userType,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add specialization for doctors
      if (data.specialization != null) {
        userData['specializations'] = [data.specialization!];
      }

      // Add test FCM token
      userData['fcmToken'] = 'test_fcm_${data.userType}_${uid.substring(0, 8)}';

      await firestore.collection('users').doc(uid).set(userData);
      print('  ✅ Firestore document created');

      // Sign out after creation
      await auth.signOut();

      return uid;
    } on Exception catch (e, stackTrace) {
      print('  ❌ Error creating account: $e');
      print('  Stack trace: $stackTrace');
      return null;
    }
  }

  /// Create all test doctor accounts
  Future<List<String>> createDoctorAccounts() async {
    print('\n${'=' * 60}');
    print('👨‍⚕️  CREATING DOCTOR ACCOUNTS');
    print('=' * 60);

    final doctors = [
      TestAccountData(
        email: 'doctor.test1@androcare360.test',
        password: 'TestDoctor123!',
        fullName: 'Dr. Ahmed Hassan',
        userType: 'doctor',
        specialization: 'Nutrition',
      ),
      TestAccountData(
        email: 'doctor.test2@androcare360.test',
        password: 'TestDoctor123!',
        fullName: 'Dr. Sara Mohamed',
        userType: 'doctor',
        specialization: 'Physiotherapy',
      ),
      TestAccountData(
        email: 'doctor.test3@androcare360.test',
        password: 'TestDoctor123!',
        fullName: 'Dr. Khaled Ali',
        userType: 'doctor',
        specialization: 'Internal Medicine',
      ),
    ];

    final createdUids = <String>[];
    for (final doctor in doctors) {
      final uid = await createAccount(doctor);
      if (uid != null) {
        createdUids.add(uid);
      }
      await Future<void>.delayed(
        const Duration(milliseconds: 500),
      ); // Rate limiting
    }

    print(
      '\n✅ Created ${createdUids.length}/${doctors.length} doctor accounts',
    );
    return createdUids;
  }

  /// Create all test patient accounts
  Future<List<String>> createPatientAccounts() async {
    print('\n${'=' * 60}');
    print('👤 CREATING PATIENT ACCOUNTS');
    print('=' * 60);

    final patients = [
      TestAccountData(
        email: 'patient.test1@androcare360.test',
        password: 'TestPatient123!',
        fullName: 'Omar Ibrahim',
        userType: 'patient',
      ),
      TestAccountData(
        email: 'patient.test2@androcare360.test',
        password: 'TestPatient123!',
        fullName: 'Fatima Ahmed',
        userType: 'patient',
      ),
      TestAccountData(
        email: 'patient.test3@androcare360.test',
        password: 'TestPatient123!',
        fullName: 'Ali Hassan',
        userType: 'patient',
      ),
      TestAccountData(
        email: 'patient.test4@androcare360.test',
        password: 'TestPatient123!',
        fullName: 'Layla Mohamed',
        userType: 'patient',
      ),
      TestAccountData(
        email: 'patient.test5@androcare360.test',
        password: 'TestPatient123!',
        fullName: 'Youssef Ali',
        userType: 'patient',
      ),
    ];

    final createdUids = <String>[];
    for (final patient in patients) {
      final uid = await createAccount(patient);
      if (uid != null) {
        createdUids.add(uid);
      }
      await Future<void>.delayed(
        const Duration(milliseconds: 500),
      ); // Rate limiting
    }

    print(
      '\n✅ Created ${createdUids.length}/${patients.length} patient accounts',
    );
    return createdUids;
  }

  /// Generate summary report
  Future<void> generateSummary(
    List<String> doctorUids,
    List<String> patientUids,
  ) async {
    print('\n${'=' * 60}');
    print('📊 ACCOUNT CREATION SUMMARY');
    print('=' * 60);

    print(
      '\n✅ Total Accounts Created: ${doctorUids.length + patientUids.length}',
    );
    print('   - Doctors: ${doctorUids.length}');
    print('   - Patients: ${patientUids.length}');

    print('\n📋 Test Credentials:');
    print('\nDoctor Accounts:');
    print('  Email: doctor.test1@androcare360.test');
    print('  Email: doctor.test2@androcare360.test');
    print('  Email: doctor.test3@androcare360.test');
    print('  Password: TestDoctor123!');

    print('\nPatient Accounts:');
    print('  Email: patient.test1@androcare360.test');
    print('  Email: patient.test2@androcare360.test');
    print('  Email: patient.test3@androcare360.test');
    print('  Email: patient.test4@androcare360.test');
    print('  Email: patient.test5@androcare360.test');
    print('  Password: TestPatient123!');

    print('\n🔗 Quick Verification:');
    if (environment == 'emulator') {
      print('  Firestore UI: http://localhost:4000/firestore');
      print('  Auth UI: http://localhost:4000/auth');
    } else {
      print('  Firebase Console: https://console.firebase.google.com/');
    }

    print('\n${'=' * 60}');
  }
}

/// Main execution
void main(List<String> args) async {
  // Parse arguments
  var environment = 'emulator'; // Default to emulator
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--environment' && i + 1 < args.length) {
      environment = args[i + 1];
    }
  }

  if (!['emulator', 'dev', 'prod'].contains(environment)) {
    print('❌ Invalid environment. Use: emulator, dev, or prod');
    exit(1);
  }

  print('\n🚀 AndroCare360 Test Account Creator');
  print('Environment: $environment');
  print('=' * 60);

  try {
    final creator = TestAccountCreator(environment);
    await creator.initialize();

    // Create accounts
    final doctorUids = await creator.createDoctorAccounts();
    final patientUids = await creator.createPatientAccounts();

    // Generate summary
    await creator.generateSummary(doctorUids, patientUids);

    print('\n✅ Account creation completed successfully!');
    exit(0);
  } on Exception catch (e, stackTrace) {
    print('\n❌ Fatal error: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}
