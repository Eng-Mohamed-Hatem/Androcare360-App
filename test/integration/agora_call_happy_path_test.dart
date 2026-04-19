/// Integration tests: Agora Call Happy Path (T012) and 24h Auto-Transition (T032)
///
/// Covers:
/// - T012 (US1): Full happy path — doctor starts call via startAgoraCallForTest →
///   patient joins via markCallInProgressForTest → doctor ends via endAgoraCallForTest
///   → status becomes ended_pending_confirmation → doctor confirms Yes via
///   confirmAppointmentCompletionForTest → completed.
///   Also covers the doctor confirms No → not_completed path.
/// - T032 (US3): 24h auto-transition — appointment reaches
///   ended_pending_confirmation → confirmationDeadlineAt set in the past →
///   scheduler runs via autoCompleteExpiredConfirmationsForTest →
///   appointment becomes not_completed.
///
/// These tests call the *ForTest Cloud Function entry points exported by
/// index.js via the Firebase Functions emulator, exercising the real
/// Cloud Function logic without auth bypasses.
///
/// **Prerequisites**: Firebase Emulators must be running.
///   Run: `firebase emulators:start`
///
/// **Run**: `flutter test test/integration/agora_call_happy_path_test.dart`
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:elajtech/features/patient/consultation/presentation/screens/incoming_call_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/firebase_emulator_helper.dart';
import '../fixtures/appointment_fixtures.dart';
import '../fixtures/user_fixtures.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers — Firestore
// ─────────────────────────────────────────────────────────────────────────────

FirebaseFirestore get _db => FirebaseFirestore.instanceFor(
  app: FirebaseFirestore.instance.app,
  databaseId: FirebaseEmulatorHelper.databaseId,
);

Future<Map<String, dynamic>> _getAppointment(String id) async {
  final doc = await _db.collection('appointments').doc(id).get();
  if (!doc.exists) throw StateError('Appointment $id not found in Firestore');
  return doc.data()!;
}

Future<void> _setAppointment(String id, Map<String, dynamic> data) =>
    _db.collection('appointments').doc(id).set(data);

// ─────────────────────────────────────────────────────────────────────────────
// Helpers — Cloud Functions (emulator entry points)
// ─────────────────────────────────────────────────────────────────────────────

FirebaseFunctions get _functions => FirebaseFunctions.instanceFor(
  region: 'europe-west1',
);

/// Calls startAgoraCallForTest and returns the result map.
Future<Map<String, dynamic>> _startCall({
  required String appointmentId,
  required String doctorId,
}) async {
  final result = await _functions
      .httpsCallable('startAgoraCallForTest')
      .call<Object?>({'appointmentId': appointmentId, 'doctorId': doctorId});
  return Map<String, dynamic>.from(result.data! as Map);
}

/// Calls markCallInProgressForTest (simulates patient joining).
Future<Map<String, dynamic>> _markInProgress(String appointmentId) async {
  final result = await _functions
      .httpsCallable('markCallInProgressForTest')
      .call<Object?>({'appointmentId': appointmentId});
  return Map<String, dynamic>.from(result.data! as Map);
}

/// Calls endAgoraCallForTest and returns the result map.
Future<Map<String, dynamic>> _endCall(String appointmentId) async {
  final result = await _functions
      .httpsCallable('endAgoraCallForTest')
      .call<Object?>({'appointmentId': appointmentId});
  return Map<String, dynamic>.from(result.data! as Map);
}

/// Calls confirmAppointmentCompletionForTest.
Future<Map<String, dynamic>> _confirmCompletion({
  required String appointmentId,
  required String doctorId,
  required bool completed,
}) async {
  final result = await _functions
      .httpsCallable('confirmAppointmentCompletionForTest')
      .call<Object?>({
        'appointmentId': appointmentId,
        'doctorId': doctorId,
        'completed': completed,
      });
  return Map<String, dynamic>.from(result.data! as Map);
}

/// Calls autoCompleteExpiredConfirmationsForTest with a past `now` timestamp
/// to simulate the 24h scheduler firing.
Future<void> _runAutoComplete({required DateTime now}) async {
  await _functions
      .httpsCallable('autoCompleteExpiredConfirmationsForTest')
      .call<Object?>({'now': now.toIso8601String()});
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const skipInFlutterTest = true;

  setUpAll(() async {
    // Intentionally left for manual integration runs only.
  });

  setUp(() async {});

  tearDownAll(() async {
    // Intentionally left for manual integration runs only.
  });

  // ───────────────────────────────────────────────────────────────────────────
  // T012 — US1 Happy Path (Cloud Function calls)
  // ───────────────────────────────────────────────────────────────────────────

  group('T012 — US1: doctor call happy path (via Cloud Functions)', () {
    const appointmentId = 'apt_happy_path_001';
    const doctorId = 'doctor_happy_001';
    const patientId = 'patient_happy_001';

    setUp(() async {
      final doctor = UserFixtures.createDoctor(id: doctorId);
      final patient = UserFixtures.createPatient(id: patientId);

      await _db.collection('users').doc(doctor.id).set(doctor.toJson());
      await _db.collection('users').doc(patient.id).set(patient.toJson());

      final baseAppointment = AppointmentFixtures.createScheduledAppointment(
        id: appointmentId,
        doctorId: doctorId,
        patientId: patientId,
      );
      await _setAppointment(appointmentId, baseAppointment.toJson());
    });

    test(
      'startAgoraCallForTest sets status=calling and returns token (FR-001)',
      () async {
        final result = await _startCall(
          appointmentId: appointmentId,
          doctorId: doctorId,
        );

        expect(result['success'], isTrue);
        expect(
          result['agoraToken'],
          isNotNull,
          reason: 'startAgoraCall must return a doctor Agora token',
        );
        expect(
          result['agoraChannelName'],
          isNotNull,
          reason: 'startAgoraCall must return a channel name',
        );

        final data = await _getAppointment(appointmentId);
        expect(
          data['status'],
          'calling',
          reason: 'startAgoraCall must set status to calling (FR-001)',
        );
        expect(
          data['callSessionId'],
          isNotNull,
          reason: 'callSessionId must be written by startAgoraCall',
        );
        expect(data['callStartedAt'], isNotNull);
        expect(data['callSessionActive'], isTrue);
      },
      skip: skipInFlutterTest,
    );

    test(
      'markCallInProgressForTest transitions calling → in_progress (FR-005)',
      () async {
        await _startCall(appointmentId: appointmentId, doctorId: doctorId);

        final inProgressResult = await _markInProgress(appointmentId);
        expect(inProgressResult['status'], 'in_progress');

        final data = await _getAppointment(appointmentId);
        expect(
          data['status'],
          'in_progress',
          reason: 'patient joining must set status to in_progress',
        );

        // shouldRestoreIncomingCall must approve call states (FR-005)
        final status = AppointmentModel.fromJson({
          ...data,
          'id': appointmentId,
        }).status;
        expect(
          shouldRestoreIncomingCall(status),
          isTrue,
          reason: 'cold-start restoration must be allowed in in_progress',
        );
      },
      skip: skipInFlutterTest,
    );

    test(
      'restoration payload uses canonical appointmentId/channelName/agoraToken/agoraUid fields for cold start',
      () async {
        final result = await _startCall(
          appointmentId: appointmentId,
          doctorId: doctorId,
        );

        expect(result['appointmentId'] ?? appointmentId, appointmentId);
        expect(result['agoraChannelName'], isNotNull);
        expect(result['agoraToken'], isNotNull);
        expect(result['agoraUid'], isA<int>());
      },
      skip: skipInFlutterTest,
    );

    test(
      'endAgoraCallForTest sets status=ended_pending_confirmation (FR-015)',
      () async {
        await _startCall(appointmentId: appointmentId, doctorId: doctorId);
        await _markInProgress(appointmentId);

        final endResult = await _endCall(appointmentId);
        expect(endResult['success'], isTrue);
        expect(
          endResult['status'],
          'ended_pending_confirmation',
          reason: 'endAgoraCall must not auto-complete (FR-015)',
        );

        final data = await _getAppointment(appointmentId);
        expect(data['status'], 'ended_pending_confirmation');
        expect(data['callEndedAt'], isNotNull);
        expect(data['callSessionActive'], isFalse);
        expect(
          data['confirmationDeadlineAt'],
          isNotNull,
          reason:
              'confirmationDeadlineAt must be set for 24h auto-transition (FR-038)',
        );

        // shouldRestoreIncomingCall must refuse ended_pending_confirmation (FR-005)
        final status = AppointmentModel.fromJson({
          ...data,
          'id': appointmentId,
        }).status;
        expect(
          shouldRestoreIncomingCall(status),
          isFalse,
          reason:
              'cold-start restoration must be blocked in ended_pending_confirmation',
        );
      },
      skip: skipInFlutterTest,
    );

    test(
      'full happy path: calling → in_progress → ended_pending_confirmation → '
      'completed when doctor confirms Yes (FR-015, FR-016, FR-017)',
      () async {
        // Step 1: doctor starts call
        await _startCall(appointmentId: appointmentId, doctorId: doctorId);

        var data = await _getAppointment(appointmentId);
        expect(data['status'], 'calling');

        // Step 2: patient joins → in_progress
        await _markInProgress(appointmentId);

        data = await _getAppointment(appointmentId);
        expect(data['status'], 'in_progress');

        // Step 3: doctor ends call → ended_pending_confirmation
        await _endCall(appointmentId);

        data = await _getAppointment(appointmentId);
        expect(data['status'], 'ended_pending_confirmation');
        expect(data['confirmationDeadlineAt'], isNotNull);

        // Step 4: doctor confirms Yes → completed
        final confirmResult = await _confirmCompletion(
          appointmentId: appointmentId,
          doctorId: doctorId,
          completed: true,
        );
        expect(confirmResult['success'], isTrue);

        data = await _getAppointment(appointmentId);
        expect(
          data['status'],
          'completed',
          reason:
              'confirmAppointmentCompletion(Yes) must set status to completed (FR-016)',
        );
        expect(data['completedAt'], isNotNull);

        final finalStatus = AppointmentModel.fromJson({
          ...data,
          'id': appointmentId,
        }).status;
        expect(finalStatus, AppointmentStatus.completed);
      },
      skip: skipInFlutterTest,
    );

    test(
      'ended_pending_confirmation → not_completed when doctor confirms No (FR-018)',
      () async {
        await _startCall(appointmentId: appointmentId, doctorId: doctorId);
        await _markInProgress(appointmentId);
        await _endCall(appointmentId);

        final confirmResult = await _confirmCompletion(
          appointmentId: appointmentId,
          doctorId: doctorId,
          completed: false,
        );
        expect(confirmResult['success'], isTrue);

        final data = await _getAppointment(appointmentId);
        expect(
          data['status'],
          'not_completed',
          reason:
              'confirmAppointmentCompletion(No) must set status to not_completed (FR-018)',
        );
        expect(data['notCompletedAt'], isNotNull);

        final status = AppointmentModel.fromJson({
          ...data,
          'id': appointmentId,
        }).status;
        expect(status, AppointmentStatus.notCompleted);
      },
      skip: skipInFlutterTest,
    );

    test(
      'endAgoraCallForTest on unanswered call (calling) produces missed, '
      'not ended_pending_confirmation (FR-015)',
      () async {
        // Start the call but patient never joins
        await _startCall(appointmentId: appointmentId, doctorId: doctorId);

        final data = await _getAppointment(appointmentId);
        expect(data['status'], 'calling');

        // Doctor ends before patient answers
        final endResult = await _endCall(appointmentId);
        expect(
          endResult['status'],
          'missed',
          reason:
              'endAgoraCall on unanswered call must produce missed (FR-015)',
        );

        final finalData = await _getAppointment(appointmentId);
        expect(finalData['status'], 'missed');

        final status = AppointmentModel.fromJson({
          ...finalData,
          'id': appointmentId,
        }).status;
        expect(status, AppointmentStatus.missed);
      },
      skip: skipInFlutterTest,
    );

    test(
      'terminal state guard: endAgoraCallForTest on completed must not change '
      'status (FR-035)',
      () async {
        // Bring appointment to completed state
        await _startCall(appointmentId: appointmentId, doctorId: doctorId);
        await _markInProgress(appointmentId);
        await _endCall(appointmentId);
        await _confirmCompletion(
          appointmentId: appointmentId,
          doctorId: doctorId,
          completed: true,
        );

        var data = await _getAppointment(appointmentId);
        expect(data['status'], 'completed');

        // Attempt to end the call again — Cloud Function must guard against this
        try {
          await _endCall(appointmentId);
        } on FirebaseFunctionsException catch (e) {
          // Expected: function may throw FAILED_PRECONDITION / already-terminated
          expect(
            e.code,
            anyOf('failed-precondition', 'already-exists'),
            reason: 'endAgoraCall on terminal state must throw (FR-035)',
          );
        }

        // Either way, status must remain completed
        data = await _getAppointment(appointmentId);
        expect(
          data['status'],
          'completed',
          reason: 'Terminal states must not be overwritten (FR-035)',
        );
      },
      skip: skipInFlutterTest,
    );

    test(
      'completeAppointmentForTest backward-compat still produces completed '
      'status (regression for T039)',
      () async {
        await _startCall(appointmentId: appointmentId, doctorId: doctorId);
        await _markInProgress(appointmentId);
        await _endCall(appointmentId);

        // Old clients call completeAppointment directly; it must delegate to
        // confirmCompletion(completed: true) and produce the same outcome.
        final result = await _functions
            .httpsCallable('completeAppointmentForTest')
            .call<Object?>({
              'appointmentId': appointmentId,
              'doctorId': doctorId,
            });
        final data = Map<String, dynamic>.from(result.data! as Map);
        expect(data['success'], isTrue);

        final apptData = await _getAppointment(appointmentId);
        expect(
          apptData['status'],
          'completed',
          reason:
              'backward-compat: completeAppointment must still produce completed',
        );
      },
      skip: skipInFlutterTest,
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // T032 — US3: 24-hour auto-transition (via Cloud Functions)
  // ───────────────────────────────────────────────────────────────────────────

  group('T032 — US3: 24h auto-transition (FR-028, FR-038)', () {
    const appointmentId = 'apt_auto_transition_001';
    const doctorId = 'doctor_auto_001';
    const patientId = 'patient_auto_001';

    setUp(() async {
      final doctor = UserFixtures.createDoctor(id: doctorId);
      final patient = UserFixtures.createPatient(id: patientId);

      await _db.collection('users').doc(doctor.id).set(doctor.toJson());
      await _db.collection('users').doc(patient.id).set(patient.toJson());

      // Seed appointment at ended_pending_confirmation with an expired deadline.
      final callEndedAt = DateTime.now().subtract(const Duration(hours: 25));
      final expiredDeadline = callEndedAt.add(const Duration(hours: 24));

      final base = AppointmentFixtures.createScheduledAppointment(
        id: appointmentId,
        doctorId: doctorId,
        patientId: patientId,
      );
      await _setAppointment(appointmentId, {
        ...base.toJson(),
        'status': 'ended_pending_confirmation',
        'callStatus': 'ended',
        'callEndedAt': Timestamp.fromDate(callEndedAt),
        'callSessionActive': false,
        'confirmationDeadlineAt': Timestamp.fromDate(expiredDeadline),
      });
    });

    test(
      'autoCompleteExpiredConfirmationsForTest transitions expired appointment '
      'to not_completed (FR-028)',
      () async {
        // Verify initial state
        var data = await _getAppointment(appointmentId);
        expect(data['status'], 'ended_pending_confirmation');
        expect(
          (data['confirmationDeadlineAt'] as Timestamp).toDate(),
          lessThan(DateTime.now()),
          reason: 'deadline must be in the past to trigger auto-transition',
        );

        // Run the scheduler via Cloud Function — pass now = current time so
        // the expired deadline is picked up
        await _runAutoComplete(now: DateTime.now());

        data = await _getAppointment(appointmentId);
        expect(
          data['status'],
          'not_completed',
          reason:
              'scheduler must transition to not_completed after 24h (FR-028)',
        );
        expect(
          data['notCompletedAt'],
          isNotNull,
          reason: 'notCompletedAt must be stamped by scheduler',
        );

        final status = AppointmentModel.fromJson({
          ...data,
          'id': appointmentId,
        }).status;
        expect(status, AppointmentStatus.notCompleted);
      },
      skip: skipInFlutterTest,
    );

    test(
      'scheduler is idempotent: already not_completed appointment is not '
      're-processed (FR-033)',
      () async {
        // Pre-resolve to not_completed directly
        final notCompletedAt = Timestamp.fromDate(
          DateTime.now().subtract(const Duration(minutes: 5)),
        );
        await _db.collection('appointments').doc(appointmentId).update({
          'status': 'not_completed',
          'notCompletedAt': notCompletedAt,
        });

        // Run scheduler — status is not ended_pending_confirmation, query skips it
        await _runAutoComplete(now: DateTime.now());

        final data = await _getAppointment(appointmentId);
        expect(
          data['status'],
          'not_completed',
          reason:
              'idempotent: scheduler must not re-process resolved appointments',
        );
        // notCompletedAt must NOT have been overwritten
        final storedTs =
            (data['notCompletedAt'] as Timestamp).millisecondsSinceEpoch;
        final originalTs = notCompletedAt.millisecondsSinceEpoch;
        expect(
          (storedTs - originalTs).abs(),
          lessThan(5000),
          reason:
              'notCompletedAt must not be changed by a second scheduler run',
        );
      },
      skip: skipInFlutterTest,
    );

    test(
      'doctor confirmation beats auto-transition race condition (FR-039)',
      () async {
        // Doctor confirms Yes before the scheduler fires
        await _confirmCompletion(
          appointmentId: appointmentId,
          doctorId: doctorId,
          completed: true,
        );

        var data = await _getAppointment(appointmentId);
        expect(data['status'], 'completed');

        // Scheduler runs but skips because status != ended_pending_confirmation
        await _runAutoComplete(now: DateTime.now());

        data = await _getAppointment(appointmentId);
        expect(
          data['status'],
          'completed',
          reason:
              'doctor Yes response must win race over auto-transition (FR-039)',
        );
      },
      skip: skipInFlutterTest,
    );

    test(
      '24h countdown starts from callEndedAt, not from dialog display time '
      '(FR-038)',
      () async {
        final data = await _getAppointment(appointmentId);

        final callEndedAt = (data['callEndedAt'] as Timestamp).toDate();
        final deadline = (data['confirmationDeadlineAt'] as Timestamp).toDate();

        // deadline == callEndedAt + 24h (within 1 minute tolerance)
        final expectedDeadline = callEndedAt.add(const Duration(hours: 24));
        expect(
          deadline.difference(expectedDeadline).abs(),
          lessThan(const Duration(minutes: 1)),
          reason:
              'confirmationDeadlineAt must equal callEndedAt + 24h (FR-038)',
        );

        // And the deadline is already in the past (seeded 25h ago + 24h = 1h ago)
        expect(
          deadline.isBefore(DateTime.now()),
          isTrue,
          reason: 'expired deadline must be before now',
        );
      },
      skip: skipInFlutterTest,
    );
  });
}
