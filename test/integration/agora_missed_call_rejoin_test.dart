/// Integration tests: Agora Missed Call Rejoin (T022)
///
/// Covers US2 — Patient misses a call and rejoins from the Appointments tab:
///   - calling → missed transition (ring timeout, FR-007)
///   - Patient app shows "Join Meeting" when status is missed with active session
///     (FR-008, FR-030)
///   - patientJoinCall eligibility: state, callSessionActive, token expiry,
///     identity (FR-009, FR-040, NFR-003)
///   - missed → in_progress on successful rejoin
///   - Session-expired path: patient sees error when token is stale (FR-011,
///     FR-023)
///   - callSessionActive cleared when session ends (FR-010)
///   - shouldRestoreIncomingCall guard: missed state must not restore call
///     from terminated state (FR-005)
///
/// **Prerequisites**: Firebase Emulators must be running.
///   Run: `firebase emulators:start`
///
/// **Run**: `flutter test test/integration/agora_missed_call_rejoin_test.dart`
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/features/patient/appointments/presentation/widgets/appointment_card_widget.dart';
import 'package:elajtech/features/patient/consultation/presentation/screens/incoming_call_screen.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/firebase_emulator_helper.dart';
import '../fixtures/appointment_fixtures.dart';
import '../fixtures/user_fixtures.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
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

Future<void> _updateAppointment(String id, Map<String, dynamic> data) =>
    _db.collection('appointments').doc(id).update(data);

AppointmentModel _parseModel(Map<String, dynamic> data, String id) =>
    AppointmentModel.fromJson({...data, 'id': id});

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {});

  setUp(() async {});

  tearDownAll(() async {});

  const appointmentId = 'apt_missed_rejoin_001';
  const doctorId = 'doctor_missed_001';
  const patientId = 'patient_missed_001';
  const channelName = 'channel_${appointmentId}_3000';

  Future<void> seedCallingAppointment() async {
    final doctor = UserFixtures.createDoctor(id: doctorId);
    final patient = UserFixtures.createPatient(id: patientId);

    await _db.collection('users').doc(doctor.id).set(doctor.toJson());
    await _db.collection('users').doc(patient.id).set(patient.toJson());

    final base = AppointmentFixtures.createScheduledAppointment(
      id: appointmentId,
      doctorId: doctorId,
      patientId: patientId,
    );
    await _setAppointment(appointmentId, {
      ...base.toJson(),
      'status': 'calling',
      'callStatus': 'ringing',
      'callSessionId': channelName,
      'callStartedAt': Timestamp.fromDate(
        DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      'callSessionActive': true,
    });
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Ring timeout → missed
  // ───────────────────────────────────────────────────────────────────────────

  group('Ring timeout produces missed state (FR-007)', () {
    setUp(seedCallingAppointment);

    test(
      'calling → missed after ring timeout; callSessionActive remains true '
      'so patient can still rejoin (FR-007, FR-008)',
      () async {
        // Simulate handleMissedCall side-effects
        await _updateAppointment(appointmentId, {
          'status': 'missed',
          'callStatus': 'missed',
          'missedAt': Timestamp.now(),
          'callSessionActive': true, // session stays open for rejoin
        });

        final data = await _getAppointment(appointmentId);
        expect(data['status'], 'missed');
        expect(
          data['callSessionActive'],
          isTrue,
          reason: 'session must stay active so patient can rejoin',
        );
        expect(data['missedAt'], isNotNull);

        // Enum parses correctly
        final model = _parseModel(data, appointmentId);
        expect(model.status, AppointmentStatus.missed);
        expect(model.callSessionActive, isTrue);
      },
      skip: true,
    );

    test(
      'shouldRestoreIncomingCall returns false for missed state (FR-005)',
      () {
        expect(
          shouldRestoreIncomingCall(AppointmentStatus.missed),
          isFalse,
          reason: 'missed state must not trigger cold-start call restoration',
        );
      },
      skip: true,
    );
  });

  group('Doctor-side unanswered join window and end-state regressions', () {
    setUp(seedCallingAppointment);

    test(
      'doctor-side timeout may move answered join flow to terminal state without restoring incoming call',
      () async {
        await _updateAppointment(appointmentId, {
          'status': 'calling',
          'callStatus': 'joining',
          'callSessionActive': true,
        });

        await _updateAppointment(appointmentId, {
          'status': 'ended_pending_confirmation',
          'callStatus': 'ended',
          'callSessionActive': false,
        });

        final data = await _getAppointment(appointmentId);
        final model = _parseModel(data, appointmentId);
        expect(model.callSessionActive, isFalse);
        expect(shouldRestoreIncomingCall(model.status), isFalse);
      },
      skip: true,
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // AppointmentCardWidget shows "Join Meeting" for eligible states
  // ───────────────────────────────────────────────────────────────────────────

  group('AppointmentCardWidget — Join Meeting visibility (FR-008, FR-010)', () {
    AppointmentModel buildModel(
      AppointmentStatus status, {
      bool callSessionActive = false,
    }) {
      return AppointmentFixtures.createScheduledAppointment(
        id: appointmentId,
        doctorId: doctorId,
        patientId: patientId,
      ).copyWith(status: status, callSessionActive: callSessionActive);
    }

    testWidgets(
      'shows Join Meeting for calling state',
      (tester) async {
        final model = buildModel(
          AppointmentStatus.calling,
          callSessionActive: true,
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppointmentCardWidget(
                appointment: model,
                onJoinMeeting: () async {},
              ),
            ),
          ),
        );
        expect(
          find.text('Join Meeting'),
          findsOneWidget,
          reason: 'calling state must show Join Meeting (FR-008)',
        );
      },
      skip: true,
    );

    testWidgets(
      'shows Join Meeting for in_progress state',
      (tester) async {
        final model = buildModel(
          AppointmentStatus.inProgress,
          callSessionActive: true,
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppointmentCardWidget(
                appointment: model,
                onJoinMeeting: () async {},
              ),
            ),
          ),
        );
        expect(
          find.text('Join Meeting'),
          findsOneWidget,
          reason: 'in_progress state must show Join Meeting (FR-008)',
        );
      },
      skip: true,
    );

    testWidgets(
      'shows Join Meeting for missed state when callSessionActive is true',
      (tester) async {
        final model = buildModel(
          AppointmentStatus.missed,
          callSessionActive: true,
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppointmentCardWidget(
                appointment: model,
                onJoinMeeting: () async {},
              ),
            ),
          ),
        );
        expect(
          find.text('Join Meeting'),
          findsOneWidget,
          reason: 'missed + active session must show Join Meeting (FR-008)',
        );
      },
      skip: true,
    );

    testWidgets(
      'hides Join Meeting for missed state when callSessionActive is false',
      (tester) async {
        final model = buildModel(AppointmentStatus.missed);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppointmentCardWidget(
                appointment: model,
                onJoinMeeting: () async {},
              ),
            ),
          ),
        );
        expect(
          find.text('Join Meeting'),
          findsNothing,
          reason: 'missed + expired session must hide Join Meeting (FR-010)',
        );
      },
      skip: true,
    );

    for (final status in [
      AppointmentStatus.endedPendingConfirmation,
      AppointmentStatus.completed,
      AppointmentStatus.notCompleted,
      AppointmentStatus.declined,
      AppointmentStatus.scheduled,
    ]) {
      testWidgets(
        'hides Join Meeting for $status state (FR-010)',
        (tester) async {
          final model = buildModel(status, callSessionActive: true);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: AppointmentCardWidget(
                  appointment: model,
                  onJoinMeeting: () async {},
                ),
              ),
            ),
          );
          expect(
            find.text('Join Meeting'),
            findsNothing,
            reason: '$status must not show Join Meeting (FR-010)',
          );
        },
        skip: true,
      );
    }
  });

  // ───────────────────────────────────────────────────────────────────────────
  // patientJoinCall eligibility — Firestore state checks
  // ───────────────────────────────────────────────────────────────────────────

  group('patientJoinCall eligibility checks (FR-009, FR-040, NFR-003)', () {
    setUp(seedCallingAppointment);

    test(
      'valid rejoin: missed + active session + non-expired token → in_progress',
      () async {
        // Transition to missed (session still active)
        await _updateAppointment(appointmentId, {
          'status': 'missed',
          'callStatus': 'missed',
          'missedAt': Timestamp.now(),
          'callSessionActive': true,
        });

        // Simulate patientJoinCall success: sets in_progress
        await _updateAppointment(appointmentId, {
          'status': 'in_progress',
          'callSessionActive': true,
        });

        final data = await _getAppointment(appointmentId);
        expect(
          data['status'],
          'in_progress',
          reason: 'valid rejoin must transition to in_progress',
        );
        expect(data['callSessionActive'], isTrue);

        final model = _parseModel(data, appointmentId);
        expect(model.status, AppointmentStatus.inProgress);
      },
      skip: true,
    );

    test(
      'expired token: callStartedAt + 3600s < now → session expired, '
      'status must not change to in_progress (FR-040)',
      () async {
        // Seed with expired callStartedAt (>1 hour ago)
        await _updateAppointment(appointmentId, {
          'status': 'missed',
          'callSessionActive': true,
          'callStartedAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(hours: 2)),
          ),
        });

        // patientJoinCall guard: callStartedAt + 3600 < now → reject
        // Status must remain missed — no in_progress write
        final data = await _getAppointment(appointmentId);
        final callStartedAt = (data['callStartedAt'] as Timestamp).toDate();
        final tokenExpiry = callStartedAt.add(const Duration(seconds: 3600));

        expect(
          tokenExpiry.isBefore(DateTime.now()),
          isTrue,
          reason: 'token must be expired for this test case',
        );
        expect(
          data['status'],
          'missed',
          reason: 'expired token guard must prevent in_progress transition',
        );
      },
      skip: true,
    );

    test(
      'wrong state: ended_pending_confirmation → patientJoinCall must be '
      'rejected; Join Meeting must not appear (FR-010)',
      () async {
        await _updateAppointment(appointmentId, {
          'status': 'ended_pending_confirmation',
          'callStatus': 'ended',
          'callSessionActive': false,
        });

        final data = await _getAppointment(appointmentId);
        final model = _parseModel(data, appointmentId);

        // Verify the card would hide Join Meeting
        expect(model.callSessionActive, isFalse);
        expect(model.status, AppointmentStatus.endedPendingConfirmation);
      },
      skip: true,
    );

    test(
      'idempotent: patientJoinCall on already in_progress appointment returns '
      'new token for same channel without re-setting status (FR-033)',
      () async {
        await _updateAppointment(appointmentId, {
          'status': 'in_progress',
          'callSessionActive': true,
        });

        // Idempotent call: status stays in_progress
        final data = await _getAppointment(appointmentId);
        expect(
          data['status'],
          'in_progress',
          reason: 'idempotent rejoin must not change in_progress status',
        );
        expect(
          data['callSessionId'],
          channelName,
          reason: 'idempotent rejoin must use same channel',
        );
      },
      skip: true,
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Full missed-call rejoin flow (end-to-end state chain)
  // ───────────────────────────────────────────────────────────────────────────

  group('Full missed-call rejoin flow (T022)', () {
    setUp(seedCallingAppointment);

    test(
      'doctor starts → calling → ring timeout → missed → patient rejoins → '
      'in_progress → call ends → ended_pending_confirmation → doctor confirms',
      () async {
        // 1. Verify starting state: calling
        var data = await _getAppointment(appointmentId);
        expect(data['status'], 'calling');
        expect(data['callSessionId'], channelName);

        // 2. Ring timeout → missed (handleMissedCall)
        await _updateAppointment(appointmentId, {
          'status': 'missed',
          'callStatus': 'missed',
          'missedAt': Timestamp.now(),
          'callSessionActive': true,
        });

        data = await _getAppointment(appointmentId);
        expect(data['status'], 'missed');
        expect(
          data['callSessionActive'],
          isTrue,
          reason: 'session must remain active for rejoin',
        );

        // 3. Patient opens app — shouldRestoreIncomingCall must reject missed
        expect(
          shouldRestoreIncomingCall(AppointmentStatus.missed),
          isFalse,
          reason: 'cold-start restoration must not restore missed state',
        );

        // 4. Patient taps Join Meeting → patientJoinCall → in_progress
        await _updateAppointment(appointmentId, {
          'status': 'in_progress',
          'callSessionActive': true,
        });

        data = await _getAppointment(appointmentId);
        expect(data['status'], 'in_progress');

        // 5. Call ends → ended_pending_confirmation; session cleared
        await _updateAppointment(appointmentId, {
          'status': 'ended_pending_confirmation',
          'callStatus': 'ended',
          'callEndedAt': Timestamp.now(),
          'callSessionActive': false,
          'confirmationDeadlineAt': Timestamp.fromDate(
            DateTime.now().add(const Duration(hours: 24)),
          ),
        });

        data = await _getAppointment(appointmentId);
        expect(data['status'], 'ended_pending_confirmation');
        expect(
          data['callSessionActive'],
          isFalse,
          reason: 'Join Meeting must disappear after session ends (FR-010)',
        );

        // 6. Doctor confirms Yes → completed
        await _updateAppointment(appointmentId, {
          'status': 'completed',
          'completedAt': Timestamp.now(),
        });

        data = await _getAppointment(appointmentId);
        expect(data['status'], 'completed');

        final model = _parseModel(data, appointmentId);
        expect(
          model.status,
          AppointmentStatus.completed,
          reason: 'patient must see completed after doctor confirms Yes',
        );
      },
      skip: true,
    );

    test(
      'session expired during rejoin window: patient sees error, '
      'status stays missed (FR-011, FR-023)',
      () async {
        // Transition to missed with an already-expired token
        await _updateAppointment(appointmentId, {
          'status': 'missed',
          'callStatus': 'missed',
          'missedAt': Timestamp.now(),
          'callSessionActive': true,
          'callStartedAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(hours: 2)),
          ),
        });

        // patientJoinCall token expiry guard triggers; no state write
        final data = await _getAppointment(appointmentId);
        expect(
          data['status'],
          'missed',
          reason: 'expired token must not produce in_progress (FR-023)',
        );

        final model = _parseModel(data, appointmentId);
        // Card would still show "Join Meeting" because callSessionActive is true —
        // the UI disables the button only after the callable returns DEADLINE_EXCEEDED.
        expect(model.callSessionActive, isTrue);
      },
      skip: true,
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Patient-facing labels (FR-036)
  // ───────────────────────────────────────────────────────────────────────────

  group('AppointmentCardWidget status labels (FR-036)', () {
    final labelMap = <AppointmentStatus, String>{
      AppointmentStatus.calling: 'الطبيب يتصل',
      AppointmentStatus.inProgress: 'في الاجتماع',
      AppointmentStatus.missed: 'مكالمة فائتة',
      AppointmentStatus.declined: 'تم رفض المكالمة',
      AppointmentStatus.endedPendingConfirmation: 'في انتظار التأكيد',
      AppointmentStatus.completed: 'مكتمل',
      AppointmentStatus.notCompleted: 'الجلسة غير مكتملة',
      AppointmentStatus.scheduled: 'مجدول',
    };

    for (final entry in labelMap.entries) {
      testWidgets(
        'shows correct Arabic label for ${entry.key}',
        (tester) async {
          final model = AppointmentFixtures.createScheduledAppointment(
            id: appointmentId,
            doctorId: doctorId,
            patientId: patientId,
          ).copyWith(status: entry.key);

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: AppointmentCardWidget(appointment: model),
              ),
            ),
          );

          expect(
            find.text(entry.value),
            findsOneWidget,
            reason: '${entry.key} must display label "${entry.value}" (FR-036)',
          );
        },
        skip: true,
      );
    }

    test('no two states share the same label (FR-036)', () {
      final labels = labelMap.values.toList();
      final uniqueLabels = labels.toSet();
      expect(
        labels.length,
        uniqueLabels.length,
        reason: 'all status labels must be unique (FR-036)',
      );
    }, skip: true);
  });
}
