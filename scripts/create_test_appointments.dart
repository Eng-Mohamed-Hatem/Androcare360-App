/// Test Appointment Creation Script
///
/// Creates test appointments between doctors and patients
///
/// Usage:
///   dart scripts/create_test_appointments.dart --environment [emulator|dev|prod]
///
/// Prerequisites:
///   - Test accounts must be created first (run create_test_accounts.dart)
library;

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestAppointmentCreator {
  TestAppointmentCreator(this.environment);

  late FirebaseFirestore firestore;
  final String environment;

  /// Initialize Firebase connection
  Future<void> initialize() async {
    await Firebase.initializeApp();

    firestore = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'elajtech', // ⚠️ CRITICAL
    );

    if (environment == 'emulator') {
      print('🔧 Connecting to Firestore Emulator...');
      firestore.useFirestoreEmulator('localhost', 8080);
      print('✅ Connected to Firestore Emulator');
    }
  }

  /// Get doctor UID by email
  Future<String?> getUserUidByEmail(String email) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return snapshot.docs.first.id;
    } on Exception catch (e) {
      print('❌ Error getting user UID: $e');
      return null;
    }
  }

  /// Create a single appointment
  Future<String?> createAppointment({
    required String appointmentId,
    required String doctorEmail,
    required String patientEmail,
    required String status,
    required DateTime scheduledAt,
  }) async {
    try {
      print('\n📝 Creating appointment: $appointmentId');

      // Get doctor and patient UIDs
      final doctorUid = await getUserUidByEmail(doctorEmail);
      final patientUid = await getUserUidByEmail(patientEmail);

      if (doctorUid == null) {
        print('  ❌ Doctor not found: $doctorEmail');
        return null;
      }

      if (patientUid == null) {
        print('  ❌ Patient not found: $patientEmail');
        return null;
      }

      // Create appointment document
      final appointmentData = {
        'doctorId': doctorUid,
        'patientId': patientUid,
        'status': status,
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        'createdAt': FieldValue.serverTimestamp(),
        'duration': 30, // 30 minutes
        'type': 'video_consultation',
        'notes': 'Test appointment for video call testing',
      };

      await firestore
          .collection('appointments')
          .doc(appointmentId)
          .set(appointmentData);

      print('  ✅ Appointment created successfully');
      print('  👨‍⚕️ Doctor: $doctorEmail');
      print('  👤 Patient: $patientEmail');
      print('  📅 Scheduled: $scheduledAt');
      print('  📊 Status: $status');

      return appointmentId;
    } on Exception catch (e, stackTrace) {
      print('  ❌ Error creating appointment: $e');
      print('  Stack trace: $stackTrace');
      return null;
    }
  }

  /// Create all test appointments
  Future<List<String>> createAllAppointments() async {
    print('\n${'=' * 60}');
    print('📅 CREATING TEST APPOINTMENTS');
    print('=' * 60);

    final now = DateTime.now();
    final appointments = [
      // Confirmed appointments (ready for testing)
      {
        'id': 'apt_test_001',
        'doctor': 'doctor.test1@androcare360.test',
        'patient': 'patient.test1@androcare360.test',
        'status': 'confirmed',
        'scheduledAt': now.add(const Duration(hours: 1)),
      },
      {
        'id': 'apt_test_002',
        'doctor': 'doctor.test1@androcare360.test',
        'patient': 'patient.test2@androcare360.test',
        'status': 'confirmed',
        'scheduledAt': now.add(const Duration(hours: 2)),
      },
      {
        'id': 'apt_test_003',
        'doctor': 'doctor.test2@androcare360.test',
        'patient': 'patient.test3@androcare360.test',
        'status': 'confirmed',
        'scheduledAt': now.add(const Duration(hours: 3)),
      },
      {
        'id': 'apt_test_004',
        'doctor': 'doctor.test2@androcare360.test',
        'patient': 'patient.test4@androcare360.test',
        'status': 'confirmed',
        'scheduledAt': now.add(const Duration(hours: 4)),
      },
      {
        'id': 'apt_test_005',
        'doctor': 'doctor.test3@androcare360.test',
        'patient': 'patient.test5@androcare360.test',
        'status': 'confirmed',
        'scheduledAt': now.add(const Duration(hours: 5)),
      },
      // Pending appointments
      {
        'id': 'apt_test_006',
        'doctor': 'doctor.test1@androcare360.test',
        'patient': 'patient.test3@androcare360.test',
        'status': 'pending',
        'scheduledAt': now.add(const Duration(days: 1)),
      },
      {
        'id': 'apt_test_007',
        'doctor': 'doctor.test2@androcare360.test',
        'patient': 'patient.test1@androcare360.test',
        'status': 'scheduled',
        'scheduledAt': now.add(const Duration(days: 1, hours: 2)),
      },
      // Additional confirmed appointments
      {
        'id': 'apt_test_008',
        'doctor': 'doctor.test3@androcare360.test',
        'patient': 'patient.test2@androcare360.test',
        'status': 'confirmed',
        'scheduledAt': now.add(const Duration(hours: 6)),
      },
      {
        'id': 'apt_test_009',
        'doctor': 'doctor.test1@androcare360.test',
        'patient': 'patient.test4@androcare360.test',
        'status': 'confirmed',
        'scheduledAt': now.add(const Duration(hours: 7)),
      },
      {
        'id': 'apt_test_010',
        'doctor': 'doctor.test2@androcare360.test',
        'patient': 'patient.test5@androcare360.test',
        'status': 'confirmed',
        'scheduledAt': now.add(const Duration(hours: 8)),
      },
    ];

    final createdIds = <String>[];
    for (final apt in appointments) {
      final id = await createAppointment(
        appointmentId: apt['id']! as String,
        doctorEmail: apt['doctor']! as String,
        patientEmail: apt['patient']! as String,
        status: apt['status']! as String,
        scheduledAt: apt['scheduledAt']! as DateTime,
      );

      if (id != null) {
        createdIds.add(id);
      }

      await Future<void>.delayed(
        const Duration(milliseconds: 300),
      ); // Rate limiting
    }

    print(
      '\n✅ Created ${createdIds.length}/${appointments.length} appointments',
    );
    return createdIds;
  }

  /// Generate summary
  void generateSummary(List<String> appointmentIds) {
    print('\n${'=' * 60}');
    print('📊 APPOINTMENT CREATION SUMMARY');
    print('=' * 60);

    print('\n✅ Total Appointments Created: ${appointmentIds.length}');

    print('\n📋 Appointment IDs:');
    for (final id in appointmentIds) {
      print('  - $id');
    }

    print('\n📝 Status Breakdown:');
    print('  - Confirmed: 7 (ready for video call testing)');
    print('  - Pending: 1');
    print('  - Scheduled: 2');

    print('\n🔗 Verification:');
    if (environment == 'emulator') {
      print('  Firestore UI: http://localhost:4000/firestore');
      print('  Collection: appointments');
    } else {
      print('  Firebase Console: https://console.firebase.google.com/');
    }

    print('\n${'=' * 60}');
  }
}

void main(List<String> args) async {
  var environment = 'emulator';
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--environment' && i + 1 < args.length) {
      environment = args[i + 1];
    }
  }

  print('\n🚀 AndroCare360 Test Appointment Creator');
  print('Environment: $environment');
  print('=' * 60);

  try {
    final creator = TestAppointmentCreator(environment);
    await creator.initialize();

    final appointmentIds = await creator.createAllAppointments();
    creator.generateSummary(appointmentIds);

    print('\n✅ Appointment creation completed successfully!');
    exit(0);
  } on Exception catch (e, stackTrace) {
    print('\n❌ Fatal error: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}
