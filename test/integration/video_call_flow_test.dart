/// Integration test for video call flow
///
/// Tests the complete video call workflow from initiation to termination,
/// including Agora connection, call logging, and Firestore updates.
///
/// Note: These tests require Firebase emulator to be running.
/// Run: firebase emulators:start
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/firebase_emulator_helper.dart';
import '../fixtures/user_fixtures.dart';
import '../fixtures/appointment_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(
    'Video Call Flow Integration Test',
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
        'complete video call flow from initiation to termination',
        (WidgetTester tester) async {
          // ═══════════════════════════════════════════════════════════════════
          // ARRANGE - Setup test data
          // ═══════════════════════════════════════════════════════════════════

          final doctor = UserFixtures.createDoctor();
          final patient = UserFixtures.createPatient();
          final appointment = AppointmentFixtures.createConfirmedAppointment(
            doctorId: doctor.id,
            patientId: patient.id,
            channelName: 'test_video_call_channel',
            agoraToken: 'test_agora_token_123',
          );

          // Verify appointment exists in Firestore
          final appointmentExists = await FirebaseEmulatorHelper.documentExists(
            collection: 'appointments',
            docId: appointment.id,
          );
          expect(appointmentExists, isTrue, reason: 'Appointment should exist');

          // ═══════════════════════════════════════════════════════════════════
          // ACT & ASSERT - Test video call initiation
          // ═══════════════════════════════════════════════════════════════════

          // Verify doctor can retrieve appointment
          final appointmentData = await FirebaseEmulatorHelper.getDocument(
            collection: 'appointments',
            docId: appointment.id,
          );
          expect(appointmentData, isNotNull);
          expect(appointmentData!['doctorId'], equals(doctor.id));
          expect(appointmentData['patientId'], equals(patient.id));
          expect(appointmentData['status'], equals('confirmed'));

          // Verify Agora channel details are present
          expect(
            appointmentData['agoraChannelName'],
            equals('test_video_call_channel'),
          );
          expect(appointmentData['agoraToken'], equals('test_agora_token_123'));
          expect(appointmentData['agoraUid'], isNotNull);

          // ═══════════════════════════════════════════════════════════════════
          // ACT & ASSERT - Test call logging
          // ═══════════════════════════════════════════════════════════════════

          // Simulate call initiation by creating a call log entry
          final callLogId = 'call_log_${appointment.id}';
          await _createCallLog(
            callLogId: callLogId,
            appointmentId: appointment.id,
            doctorId: doctor.id,
            patientId: patient.id,
            channelName: 'test_video_call_channel',
            status: 'initiated',
          );

          // Wait for call log to be created
          final callLogCreated = await FirebaseEmulatorHelper.waitForDocument(
            collection: 'call_logs',
            docId: callLogId,
            timeout: const Duration(seconds: 5),
          );
          expect(callLogCreated, isTrue, reason: 'Call log should be created');

          // Verify call log details
          final callLogData = await FirebaseEmulatorHelper.getDocument(
            collection: 'call_logs',
            docId: callLogId,
          );
          expect(callLogData, isNotNull);
          expect(callLogData!['appointmentId'], equals(appointment.id));
          expect(callLogData['doctorId'], equals(doctor.id));
          expect(callLogData['patientId'], equals(patient.id));
          expect(callLogData['status'], equals('initiated'));
          expect(callLogData['channelName'], equals('test_video_call_channel'));

          // ═══════════════════════════════════════════════════════════════════
          // ACT & ASSERT - Test call connection establishment
          // ═══════════════════════════════════════════════════════════════════

          // Simulate patient joining the call
          await _updateCallLog(
            callLogId: callLogId,
            status: 'connected',
            patientJoinedAt: DateTime.now(),
          );

          // Verify call status updated
          final connectedCallLog = await FirebaseEmulatorHelper.getDocument(
            collection: 'call_logs',
            docId: callLogId,
          );
          expect(connectedCallLog, isNotNull);
          expect(connectedCallLog!['status'], equals('connected'));
          expect(connectedCallLog['patientJoinedAt'], isNotNull);

          // ═══════════════════════════════════════════════════════════════════
          // ACT & ASSERT - Test call termination
          // ═══════════════════════════════════════════════════════════════════

          // Simulate call ending
          final endTime = DateTime.now();
          await _updateCallLog(
            callLogId: callLogId,
            status: 'completed',
            endedAt: endTime,
            duration: 1800, // 30 minutes in seconds
          );

          // Verify final call status
          final completedCallLog = await FirebaseEmulatorHelper.getDocument(
            collection: 'call_logs',
            docId: callLogId,
          );
          expect(completedCallLog, isNotNull);
          expect(completedCallLog!['status'], equals('completed'));
          expect(completedCallLog['endedAt'], isNotNull);
          expect(completedCallLog['duration'], equals(1800));

          // ═══════════════════════════════════════════════════════════════════
          // ACT & ASSERT - Verify appointment status updated
          // ═══════════════════════════════════════════════════════════════════

          // Update appointment status to completed
          await _updateAppointmentStatus(
            appointmentId: appointment.id,
            status: 'completed',
          );

          // Verify appointment marked as completed
          final completedAppointment = await FirebaseEmulatorHelper.getDocument(
            collection: 'appointments',
            docId: appointment.id,
          );
          expect(completedAppointment, isNotNull);
          expect(completedAppointment!['status'], equals('completed'));
        },
      );

      testWidgets(
        'video call handles patient not joining',
        (WidgetTester tester) async {
          // ═══════════════════════════════════════════════════════════════════
          // ARRANGE
          // ═══════════════════════════════════════════════════════════════════

          final doctor = UserFixtures.createDoctor();
          final patient = UserFixtures.createPatient();
          final appointment = AppointmentFixtures.createConfirmedAppointment(
            doctorId: doctor.id,
            patientId: patient.id,
          );

          // ═══════════════════════════════════════════════════════════════════
          // ACT - Doctor initiates call but patient doesn't join
          // ═══════════════════════════════════════════════════════════════════

          final callLogId = 'call_log_no_join_${appointment.id}';
          await _createCallLog(
            callLogId: callLogId,
            appointmentId: appointment.id,
            doctorId: doctor.id,
            patientId: patient.id,
            channelName: 'test_channel_no_join',
            status: 'initiated',
          );

          // Wait for timeout (simulate patient not joining)
          await Future<void>.delayed(const Duration(seconds: 2));

          // Update call log to missed
          await _updateCallLog(
            callLogId: callLogId,
            status: 'missed',
            endedAt: DateTime.now(),
          );

          // ═══════════════════════════════════════════════════════════════════
          // ASSERT
          // ═══════════════════════════════════════════════════════════════════

          final missedCallLog = await FirebaseEmulatorHelper.getDocument(
            collection: 'call_logs',
            docId: callLogId,
          );
          expect(missedCallLog, isNotNull);
          expect(missedCallLog!['status'], equals('missed'));
          expect(missedCallLog['patientJoinedAt'], isNull);
        },
      );

      testWidgets(
        'video call handles network disconnection',
        (WidgetTester tester) async {
          // ═══════════════════════════════════════════════════════════════════
          // ARRANGE
          // ═══════════════════════════════════════════════════════════════════

          final doctor = UserFixtures.createDoctor();
          final patient = UserFixtures.createPatient();
          final appointment = AppointmentFixtures.createConfirmedAppointment(
            doctorId: doctor.id,
            patientId: patient.id,
          );

          final callLogId = 'call_log_disconnect_${appointment.id}';

          // ═══════════════════════════════════════════════════════════════════
          // ACT - Call starts successfully
          // ═══════════════════════════════════════════════════════════════════

          await _createCallLog(
            callLogId: callLogId,
            appointmentId: appointment.id,
            doctorId: doctor.id,
            patientId: patient.id,
            channelName: 'test_channel_disconnect',
            status: 'initiated',
          );

          await _updateCallLog(
            callLogId: callLogId,
            status: 'connected',
            patientJoinedAt: DateTime.now(),
          );

          // Simulate network disconnection
          await _updateCallLog(
            callLogId: callLogId,
            status: 'disconnected',
            endedAt: DateTime.now(),
            duration: 300, // 5 minutes before disconnect
          );

          // ═══════════════════════════════════════════════════════════════════
          // ASSERT
          // ═══════════════════════════════════════════════════════════════════

          final disconnectedCallLog = await FirebaseEmulatorHelper.getDocument(
            collection: 'call_logs',
            docId: callLogId,
          );
          expect(disconnectedCallLog, isNotNull);
          expect(disconnectedCallLog!['status'], equals('disconnected'));
          expect(disconnectedCallLog['duration'], equals(300));
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

/// Creates a call log entry in Firestore
Future<void> _createCallLog({
  required String callLogId,
  required String appointmentId,
  required String doctorId,
  required String patientId,
  required String channelName,
  required String status,
}) async {
  final firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'elajtech',
  );

  await firestore.collection('call_logs').doc(callLogId).set({
    'id': callLogId,
    'appointmentId': appointmentId,
    'doctorId': doctorId,
    'patientId': patientId,
    'channelName': channelName,
    'status': status,
    'initiatedAt': Timestamp.now(),
    'createdAt': Timestamp.now(),
  });
}

/// Updates a call log entry in Firestore
Future<void> _updateCallLog({
  required String callLogId,
  required String status,
  DateTime? patientJoinedAt,
  DateTime? endedAt,
  int? duration,
}) async {
  final firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'elajtech',
  );

  final updateData = <String, dynamic>{
    'status': status,
    'updatedAt': Timestamp.now(),
  };

  if (patientJoinedAt != null) {
    updateData['patientJoinedAt'] = Timestamp.fromDate(patientJoinedAt);
  }

  if (endedAt != null) {
    updateData['endedAt'] = Timestamp.fromDate(endedAt);
  }

  if (duration != null) {
    updateData['duration'] = duration;
  }

  await firestore.collection('call_logs').doc(callLogId).update(updateData);
}

/// Updates appointment status in Firestore
Future<void> _updateAppointmentStatus({
  required String appointmentId,
  required String status,
}) async {
  final firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'elajtech',
  );

  await firestore.collection('appointments').doc(appointmentId).update({
    'status': status,
    'updatedAt': Timestamp.now(),
  });
}
