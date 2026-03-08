/// Integration test for appointment booking flow
///
/// Tests the complete appointment booking workflow from patient selection
/// to doctor confirmation, including Firestore updates and notifications.
///
/// Note: These tests require Firebase emulator to be running.
/// Run: firebase emulators:start
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/firebase_emulator_helper.dart';
import '../fixtures/user_fixtures.dart';

void main() {
  // ⚠️ INTEGRATION TESTS REQUIRE FIREBASE EMULATOR ⚠️
  // These tests are skipped by default. To run:
  // 1. Install Firebase CLI: npm install -g firebase-tools
  // 2. Start emulator: firebase emulators:start
  // 3. Remove skip parameter below

  TestWidgetsFlutterBinding.ensureInitialized();

  group(
    'Appointment Booking Flow Integration Test',
    () {
      setUp(() async {
        // Setup Firebase emulator
        await FirebaseEmulatorHelper.setupEmulator();

        // Clear any existing data
        await FirebaseEmulatorHelper.clearFirestore();

        // Seed test data
        await FirebaseEmulatorHelper.seedTestData();
      });

      tearDown(() async {
        // Cleanup after each test
        await FirebaseEmulatorHelper.cleanup();
      });

      testWidgets(
        'complete appointment booking flow from patient to doctor confirmation',
        (WidgetTester tester) async {
          // ═══════════════════════════════════════════════════════════════════
          // ARRANGE - Setup test data
          // ═══════════════════════════════════════════════════════════════════

          final doctor = UserFixtures.createDoctor();
          final patient = UserFixtures.createPatient();

          // Verify users exist in Firestore
          final doctorExists = await FirebaseEmulatorHelper.documentExists(
            collection: 'users',
            docId: doctor.id,
          );
          expect(doctorExists, isTrue, reason: 'Doctor should exist');

          final patientExists = await FirebaseEmulatorHelper.documentExists(
            collection: 'users',
            docId: patient.id,
          );
          expect(patientExists, isTrue, reason: 'Patient should exist');

          // ═══════════════════════════════════════════════════════════════════
          // ACT & ASSERT - Patient selects doctor
          // ═══════════════════════════════════════════════════════════════════

          // Retrieve doctor details
          final doctorData = await FirebaseEmulatorHelper.getDocument(
            collection: 'users',
            docId: doctor.id,
          );
          expect(doctorData, isNotNull);
          expect(doctorData!['userType'], equals('doctor'));
          expect(doctorData['specializations'], contains('Nutrition'));

          // ═══════════════════════════════════════════════════════════════════
          // ACT & ASSERT - Patient chooses date/time
          // ═══════════════════════════════════════════════════════════════════

          final appointmentDate = DateTime.now().add(const Duration(days: 2));
          const timeSlot = '10:00 AM';

          // Check if time slot is available (no conflicting appointments)
          final existingAppointments = await _getAppointmentsByDoctorAndDate(
            doctorId: doctor.id,
            date: appointmentDate,
            timeSlot: timeSlot,
          );
          expect(
            existingAppointments,
            isEmpty,
            reason: 'Time slot should be available',
          );

          // ═══════════════════════════════════════════════════════════════════
          // ACT & ASSERT - Create appointment
          // ═══════════════════════════════════════════════════════════════════

          const appointmentId = 'apt_booking_test_001';
          await _createAppointment(
            appointmentId: appointmentId,
            patientId: patient.id,
            patientName: patient.fullName,
            patientPhone: patient.phoneNumber ?? '+966500000000',
            doctorId: doctor.id,
            doctorName: doctor.fullName,
            specialization: (doctor.specializations?.isNotEmpty ?? false)
                ? doctor.specializations!.first
                : 'General',
            appointmentDate: appointmentDate,
            timeSlot: timeSlot,
            fee: 200,
            status: 'pending',
          );

          // Wait for appointment to be created
          final appointmentCreated =
              await FirebaseEmulatorHelper.waitForDocument(
                collection: 'appointments',
                docId: appointmentId,
                timeout: const Duration(seconds: 5),
              );
          expect(
            appointmentCreated,
            isTrue,
            reason: 'Appointment should be created',
          );

          // ═══════════════════════════════════════════════════════════════════
          // ACT & ASSERT - Verify appointment in Firestore
          // ═══════════════════════════════════════════════════════════════════

          final appointmentData = await FirebaseEmulatorHelper.getDocument(
            collection: 'appointments',
            docId: appointmentId,
          );
          expect(appointmentData, isNotNull);
          expect(appointmentData!['patientId'], equals(patient.id));
          expect(appointmentData['doctorId'], equals(doctor.id));
          expect(appointmentData['status'], equals('pending'));
          expect(appointmentData['timeSlot'], equals(timeSlot));
          expect(appointmentData['specialization'], equals('Nutrition'));

          // ═══════════════════════════════════════════════════════════════════
          // ACT & ASSERT - Doctor receives notification
          // ═══════════════════════════════════════════════════════════════════

          // Simulate notification creation
          const notificationId = 'notif_${appointmentId}_doctor';
          await _createNotification(
            notificationId: notificationId,
            userId: doctor.id,
            title: 'New Appointment Request',
            body: 'Patient ${patient.fullName} requested an appointment',
            type: 'appointment_request',
            data: {
              'appointmentId': appointmentId,
              'patientId': patient.id,
            },
          );

          // Verify notification created
          final notificationExists =
              await FirebaseEmulatorHelper.documentExists(
                collection: 'notifications',
                docId: notificationId,
              );
          expect(
            notificationExists,
            isTrue,
            reason: 'Notification should be created',
          );

          final notificationData = await FirebaseEmulatorHelper.getDocument(
            collection: 'notifications',
            docId: notificationId,
          );
          expect(notificationData, isNotNull);
          expect(notificationData!['userId'], equals(doctor.id));
          expect(notificationData['type'], equals('appointment_request'));

          // ═══════════════════════════════════════════════════════════════════
          // ACT & ASSERT - Doctor confirms appointment
          // ═══════════════════════════════════════════════════════════════════

          await _updateAppointmentStatus(
            appointmentId: appointmentId,
            status: 'confirmed',
            agoraChannelName: 'channel_$appointmentId',
            agoraToken: 'token_test_123',
            agoraUid: 12345,
          );

          // Verify appointment status updated
          final confirmedAppointment = await FirebaseEmulatorHelper.getDocument(
            collection: 'appointments',
            docId: appointmentId,
          );
          expect(confirmedAppointment, isNotNull);
          expect(confirmedAppointment!['status'], equals('confirmed'));
          expect(confirmedAppointment['agoraChannelName'], isNotNull);
          expect(confirmedAppointment['agoraToken'], isNotNull);

          // ═══════════════════════════════════════════════════════════════════
          // ACT & ASSERT - Patient receives confirmation notification
          // ═══════════════════════════════════════════════════════════════════

          const patientNotificationId = 'notif_${appointmentId}_patient';
          await _createNotification(
            notificationId: patientNotificationId,
            userId: patient.id,
            title: 'Appointment Confirmed',
            body: 'Dr. ${doctor.fullName} confirmed your appointment',
            type: 'appointment_confirmed',
            data: {
              'appointmentId': appointmentId,
              'doctorId': doctor.id,
            },
          );

          final patientNotificationExists =
              await FirebaseEmulatorHelper.documentExists(
                collection: 'notifications',
                docId: patientNotificationId,
              );
          expect(
            patientNotificationExists,
            isTrue,
            reason: 'Patient notification should be created',
          );

          // ═══════════════════════════════════════════════════════════════════
          // ACT & ASSERT - Verify calendar updates
          // ═══════════════════════════════════════════════════════════════════

          // Get all appointments for the doctor on that date
          final doctorAppointments = await _getAppointmentsByDoctorAndDate(
            doctorId: doctor.id,
            date: appointmentDate,
          );
          expect(
            doctorAppointments.length,
            greaterThanOrEqualTo(1),
            reason: 'Doctor should have at least one appointment',
          );

          // Verify the confirmed appointment is in the list
          final confirmedInList = doctorAppointments.any(
            (apt) => apt['id'] == appointmentId && apt['status'] == 'confirmed',
          );
          expect(
            confirmedInList,
            isTrue,
            reason: 'Confirmed appointment should be in doctor calendar',
          );
        },
      );

      testWidgets(
        'appointment booking handles time slot conflict',
        (WidgetTester tester) async {
          // ═══════════════════════════════════════════════════════════════════
          // ARRANGE
          // ═══════════════════════════════════════════════════════════════════

          final doctor = UserFixtures.createDoctor();
          final patient1 = UserFixtures.createPatient();
          // Second patient would try to book same slot (conflict scenario)

          final appointmentDate = DateTime.now().add(const Duration(days: 1));
          const timeSlot = '02:00 PM';

          // ═══════════════════════════════════════════════════════════════════
          // ACT - First patient books appointment
          // ═══════════════════════════════════════════════════════════════════

          const appointment1Id = 'apt_conflict_test_001';
          await _createAppointment(
            appointmentId: appointment1Id,
            patientId: patient1.id,
            patientName: patient1.fullName,
            patientPhone: patient1.phoneNumber ?? '+966500000001',
            doctorId: doctor.id,
            doctorName: doctor.fullName,
            specialization: 'Nutrition',
            appointmentDate: appointmentDate,
            timeSlot: timeSlot,
            fee: 200,
            status: 'confirmed',
          );

          // ═══════════════════════════════════════════════════════════════════
          // ACT & ASSERT - Second patient tries to book same slot
          // ═══════════════════════════════════════════════════════════════════

          // Check for conflicts
          final conflicts = await _getAppointmentsByDoctorAndDate(
            doctorId: doctor.id,
            date: appointmentDate,
            timeSlot: timeSlot,
          );

          expect(
            conflicts.length,
            greaterThan(0),
            reason: 'Should detect existing appointment',
          );

          // Verify conflict detection prevents double booking
          final hasConflict = conflicts.any(
            (apt) =>
                apt['status'] == 'confirmed' || apt['status'] == 'scheduled',
          );
          expect(
            hasConflict,
            isTrue,
            reason: 'Should detect time slot conflict',
          );
        },
      );

      testWidgets(
        'appointment booking handles cancellation',
        (WidgetTester tester) async {
          // ═══════════════════════════════════════════════════════════════════
          // ARRANGE
          // ═══════════════════════════════════════════════════════════════════

          final doctor = UserFixtures.createDoctor();
          final patient = UserFixtures.createPatient();

          final appointmentDate = DateTime.now().add(const Duration(days: 3));
          const timeSlot = '11:00 AM';

          // ═══════════════════════════════════════════════════════════════════
          // ACT - Create and confirm appointment
          // ═══════════════════════════════════════════════════════════════════

          const appointmentId = 'apt_cancel_test_001';
          await _createAppointment(
            appointmentId: appointmentId,
            patientId: patient.id,
            patientName: patient.fullName,
            patientPhone: patient.phoneNumber ?? '+966500000002',
            doctorId: doctor.id,
            doctorName: doctor.fullName,
            specialization: 'Nutrition',
            appointmentDate: appointmentDate,
            timeSlot: timeSlot,
            fee: 200,
            status: 'confirmed',
          );

          // ═══════════════════════════════════════════════════════════════════
          // ACT - Patient cancels appointment
          // ═══════════════════════════════════════════════════════════════════

          await _updateAppointmentStatus(
            appointmentId: appointmentId,
            status: 'cancelled',
          );

          // ═══════════════════════════════════════════════════════════════════
          // ASSERT
          // ═══════════════════════════════════════════════════════════════════

          final cancelledAppointment = await FirebaseEmulatorHelper.getDocument(
            collection: 'appointments',
            docId: appointmentId,
          );
          expect(cancelledAppointment, isNotNull);
          expect(cancelledAppointment!['status'], equals('cancelled'));

          // Verify time slot is now available again
          final conflicts = await _getAppointmentsByDoctorAndDate(
            doctorId: doctor.id,
            date: appointmentDate,
            timeSlot: timeSlot,
          );

          final activeConflicts = conflicts.where(
            (apt) =>
                apt['status'] != 'cancelled' && apt['status'] != 'completed',
          );
          expect(
            activeConflicts.length,
            equals(0),
            reason: 'Time slot should be available after cancellation',
          );
        },
      );
    },
    skip:
        'Integration tests require Firebase Emulator. Run manually with: firebase emulators:start',
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════

/// Creates an appointment in Firestore
Future<void> _createAppointment({
  required String appointmentId,
  required String patientId,
  required String patientName,
  required String patientPhone,
  required String doctorId,
  required String doctorName,
  required String specialization,
  required DateTime appointmentDate,
  required String timeSlot,
  required double fee,
  required String status,
}) async {
  final firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'elajtech',
  );

  await firestore.collection('appointments').doc(appointmentId).set({
    'id': appointmentId,
    'patientId': patientId,
    'patientName': patientName,
    'patientPhone': patientPhone,
    'doctorId': doctorId,
    'doctorName': doctorName,
    'specialization': specialization,
    'appointmentDate': appointmentDate.toIso8601String(),
    'timeSlot': timeSlot,
    'type': 'video',
    'status': status,
    'fee': fee,
    'createdAt': DateTime.now().toIso8601String(),
    'meetingProvider': 'agora',
  });
}

/// Updates appointment status and optionally adds Agora details
Future<void> _updateAppointmentStatus({
  required String appointmentId,
  required String status,
  String? agoraChannelName,
  String? agoraToken,
  int? agoraUid,
}) async {
  final firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'elajtech',
  );

  final updateData = <String, dynamic>{
    'status': status,
    'updatedAt': Timestamp.now(),
  };

  if (agoraChannelName != null) {
    updateData['agoraChannelName'] = agoraChannelName;
  }

  if (agoraToken != null) {
    updateData['agoraToken'] = agoraToken;
  }

  if (agoraUid != null) {
    updateData['agoraUid'] = agoraUid;
  }

  await firestore
      .collection('appointments')
      .doc(appointmentId)
      .update(
        updateData,
      );
}

/// Gets appointments for a doctor on a specific date and optionally time slot
Future<List<Map<String, dynamic>>> _getAppointmentsByDoctorAndDate({
  required String doctorId,
  required DateTime date,
  String? timeSlot,
}) async {
  final firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'elajtech',
  );

  // Query appointments for the doctor on the specified date
  var query = firestore
      .collection('appointments')
      .where('doctorId', isEqualTo: doctorId)
      .where(
        'appointmentDate',
        isEqualTo: DateTime(date.year, date.month, date.day).toIso8601String(),
      );

  if (timeSlot != null) {
    query = query.where('timeSlot', isEqualTo: timeSlot);
  }

  final snapshot = await query.get();
  return snapshot.docs.map((doc) => doc.data()).toList();
}

/// Creates a notification in Firestore
Future<void> _createNotification({
  required String notificationId,
  required String userId,
  required String title,
  required String body,
  required String type,
  Map<String, dynamic>? data,
}) async {
  final firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'elajtech',
  );

  await firestore.collection('notifications').doc(notificationId).set({
    'id': notificationId,
    'userId': userId,
    'title': title,
    'body': body,
    'type': type,
    'data': data ?? {},
    'read': false,
    'createdAt': Timestamp.now(),
  });
}
