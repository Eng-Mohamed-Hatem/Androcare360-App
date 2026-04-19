import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for appointment card action visibility logic.
///
/// These tests mirror the computed-bool logic in AppointmentCardWidget
/// without needing the widget itself. The logic is extracted into pure
/// helper functions below so it can be unit-tested in isolation.
void main() {
  // ── Helpers mirroring AppointmentCardWidget's computed getters ─────────────

  bool isInJoinWindow(AppointmentModel apt, DateTime now) {
    if (apt.status != AppointmentStatus.confirmed) return false;
    return now.isAfter(apt.fullDateTime.subtract(const Duration(minutes: 10)));
  }

  bool canJoinMeeting(AppointmentModel apt, DateTime now) {
    return apt.status == AppointmentStatus.calling ||
        apt.status == AppointmentStatus.inProgress ||
        (apt.status == AppointmentStatus.missed && apt.callSessionActive) ||
        (apt.callStartedAt != null &&
            apt.status != AppointmentStatus.completed) ||
        isInJoinWindow(apt, now);
  }

  bool showWaitingForCall(AppointmentModel apt, DateTime now) {
    return (apt.status == AppointmentStatus.pending ||
            apt.status == AppointmentStatus.confirmed) &&
        !canJoinMeeting(apt, now);
  }

  bool canReschedule(AppointmentModel apt, DateTime now) {
    if (apt.status != AppointmentStatus.pending &&
        apt.status != AppointmentStatus.confirmed) {
      return false;
    }
    return apt.fullDateTime.isAfter(now.add(const Duration(hours: 2)));
  }

  bool showMedicalRecordIcon(AppointmentModel apt) =>
      apt.status == AppointmentStatus.completed;

  // ── Factory helpers ────────────────────────────────────────────────────────

  AppointmentModel makeApt({
    required AppointmentStatus status,
    required DateTime appointmentDate,
    String timeSlot = '10:00',
    bool callSessionActive = false,
    DateTime? callStartedAt,
  }) {
    return AppointmentModel(
      id: 'test_id',
      patientId: 'patient_1',
      patientName: 'Test Patient',
      patientPhone: '+1234567890',
      doctorId: 'doctor_1',
      doctorName: 'Dr. Test',
      specialization: 'Andrology',
      appointmentDate: appointmentDate,
      timeSlot: timeSlot,
      type: AppointmentType.video,
      status: status,
      fee: 0,
      createdAt: DateTime(2026),
      callStartedAt: callStartedAt,
      callSessionActive: callSessionActive,
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // T006 — isInJoinWindow
  // ────────────────────────────────────────────────────────────────────────────
  group('_isInJoinWindow', () {
    test('returns false when status is NOT confirmed', () {
      final now = DateTime(2026, 4, 1, 10);
      // All statuses except confirmed should return false regardless of time
      for (final status in AppointmentStatus.values) {
        if (status == AppointmentStatus.confirmed) continue;
        final apt = makeApt(
          status: status,
          appointmentDate: now.subtract(const Duration(minutes: 5)),
        );
        expect(
          isInJoinWindow(apt, now),
          isFalse,
          reason: 'Status $status should not trigger join window',
        );
      }
    });

    test('returns true when confirmed and now > fullDateTime - 10min', () {
      final apptTime = DateTime(2026, 4, 1, 10);
      final apt = makeApt(
        status: AppointmentStatus.confirmed,
        appointmentDate: apptTime,
      );
      // 9 minutes before start — inside window
      final now = apptTime.subtract(const Duration(minutes: 9));
      expect(isInJoinWindow(apt, now), isTrue);
    });

    test('returns false when confirmed but still more than 10 min away', () {
      final apptTime = DateTime(2026, 4, 1, 10);
      final apt = makeApt(
        status: AppointmentStatus.confirmed,
        appointmentDate: apptTime,
      );
      // 11 minutes before start — outside window
      final now = apptTime.subtract(const Duration(minutes: 11));
      expect(isInJoinWindow(apt, now), isFalse);
    });

    test('boundary: exactly 10 minutes before — outside window', () {
      final apptTime = DateTime(2026, 4, 1, 10);
      final apt = makeApt(
        status: AppointmentStatus.confirmed,
        appointmentDate: apptTime,
      );
      final now = apptTime.subtract(const Duration(minutes: 10));
      // isAfter is strict; exactly 10 min before is NOT after
      expect(isInJoinWindow(apt, now), isFalse);
    });

    test('returns true when now is after appointment start', () {
      final apptTime = DateTime(2026, 4, 1, 10);
      final apt = makeApt(
        status: AppointmentStatus.confirmed,
        appointmentDate: apptTime,
      );
      final now = apptTime.add(const Duration(minutes: 5));
      expect(isInJoinWindow(apt, now), isTrue);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // T006 — canJoinMeeting
  // ────────────────────────────────────────────────────────────────────────────
  group('_canJoinMeeting', () {
    test('returns true for calling status', () {
      final now = DateTime(2026, 4, 1, 10);
      final apt = makeApt(
        status: AppointmentStatus.calling,
        appointmentDate: now,
      );
      expect(canJoinMeeting(apt, now), isTrue);
    });

    test('returns true for inProgress status', () {
      final now = DateTime(2026, 4, 1, 10);
      final apt = makeApt(
        status: AppointmentStatus.inProgress,
        appointmentDate: now,
      );
      expect(canJoinMeeting(apt, now), isTrue);
    });

    test('returns true for missed + callSessionActive', () {
      final now = DateTime(2026, 4, 1, 10);
      final apt = makeApt(
        status: AppointmentStatus.missed,
        appointmentDate: now,
        callSessionActive: true,
      );
      expect(canJoinMeeting(apt, now), isTrue);
    });

    test('returns false for missed without active session', () {
      final now = DateTime(2026, 4, 1, 10);
      final apt = makeApt(
        status: AppointmentStatus.missed,
        appointmentDate: now,
      );
      expect(canJoinMeeting(apt, now), isFalse);
    });

    test(
      'returns true when callStartedAt exists and appointment is not completed',
      () {
        final now = DateTime(2026, 4, 1, 10);
        final apt = makeApt(
          status: AppointmentStatus.confirmed,
          appointmentDate: now,
          callStartedAt: now.subtract(const Duration(minutes: 1)),
        );
        expect(canJoinMeeting(apt, now), isTrue);
      },
    );

    test('returns true for confirmed inside join window', () {
      final apptTime = DateTime(2026, 4, 1, 10);
      final now = apptTime.subtract(const Duration(minutes: 5));
      final apt = makeApt(
        status: AppointmentStatus.confirmed,
        appointmentDate: apptTime,
      );
      expect(canJoinMeeting(apt, now), isTrue);
    });

    test('returns false for confirmed outside join window', () {
      final apptTime = DateTime(2026, 4, 1, 10);
      final now = apptTime.subtract(const Duration(minutes: 30));
      final apt = makeApt(
        status: AppointmentStatus.confirmed,
        appointmentDate: apptTime,
      );
      expect(canJoinMeeting(apt, now), isFalse);
    });

    test('returns false for pending status (never in join window)', () {
      final apptTime = DateTime(2026, 4, 1, 10);
      final now = apptTime.subtract(const Duration(minutes: 5));
      final apt = makeApt(
        status: AppointmentStatus.pending,
        appointmentDate: apptTime,
      );
      expect(canJoinMeeting(apt, now), isFalse);
    });

    test('returns false for all terminal statuses', () {
      final now = DateTime(2026, 4, 1, 10);
      for (final status in [
        AppointmentStatus.completed,
        AppointmentStatus.cancelled,
        AppointmentStatus.declined,
        AppointmentStatus.notCompleted,
        AppointmentStatus.endedPendingConfirmation,
      ]) {
        final apt = makeApt(status: status, appointmentDate: now);
        expect(canJoinMeeting(apt, now), isFalse, reason: 'Status: $status');
      }
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // T006 — showWaitingForCall
  // ────────────────────────────────────────────────────────────────────────────
  group('showWaitingForCall', () {
    test('returns true for pending outside join window', () {
      final now = DateTime(2026, 4, 1, 10);
      final apt = makeApt(
        status: AppointmentStatus.pending,
        appointmentDate: now.add(const Duration(hours: 2)),
        timeSlot: '12:00',
      );
      expect(showWaitingForCall(apt, now), isTrue);
    });

    test('returns true for confirmed outside join window', () {
      final apptTime = DateTime(2026, 4, 1, 10);
      final now = apptTime.subtract(const Duration(minutes: 30));
      final apt = makeApt(
        status: AppointmentStatus.confirmed,
        appointmentDate: apptTime,
      );
      expect(showWaitingForCall(apt, now), isTrue);
    });

    test('returns false for confirmed inside join window', () {
      final apptTime = DateTime(2026, 4, 1, 10);
      final now = apptTime.subtract(const Duration(minutes: 5));
      final apt = makeApt(
        status: AppointmentStatus.confirmed,
        appointmentDate: apptTime,
      );
      expect(showWaitingForCall(apt, now), isFalse);
    });

    test('returns false for all non-pending/confirmed statuses', () {
      final now = DateTime(2026, 4, 1, 10);
      for (final status in AppointmentStatus.values) {
        if (status == AppointmentStatus.pending ||
            status == AppointmentStatus.confirmed) {
          continue;
        }
        final apt = makeApt(status: status, appointmentDate: now);
        expect(
          showWaitingForCall(apt, now),
          isFalse,
          reason: 'Status: $status',
        );
      }
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // T012 — canReschedule
  // ────────────────────────────────────────────────────────────────────────────
  group('_canReschedule', () {
    test('returns true for pending with fullDateTime > now + 2h', () {
      final now = DateTime(2026, 4, 1, 10);
      final apt = makeApt(
        status: AppointmentStatus.pending,
        appointmentDate: now.add(const Duration(hours: 3)),
        timeSlot: '13:00',
      );
      expect(canReschedule(apt, now), isTrue);
    });

    test('returns true for confirmed with fullDateTime > now + 2h', () {
      final now = DateTime(2026, 4, 1, 10);
      final apt = makeApt(
        status: AppointmentStatus.confirmed,
        appointmentDate: now.add(const Duration(hours: 3)),
        timeSlot: '13:00',
      );
      expect(canReschedule(apt, now), isTrue);
    });

    test('returns false when fullDateTime < now + 2h', () {
      final now = DateTime(2026, 4, 1, 10);
      final apt = makeApt(
        status: AppointmentStatus.confirmed,
        appointmentDate: now.add(const Duration(hours: 1)),
        timeSlot: '11:00',
      );
      expect(canReschedule(apt, now), isFalse);
    });

    test('boundary: exactly 2 hours away — not eligible', () {
      final now = DateTime(2026, 4, 1, 10);
      final apptTime = now.add(const Duration(hours: 2));
      final apt = makeApt(
        status: AppointmentStatus.confirmed,
        appointmentDate: apptTime,
        timeSlot: '12:00',
      );
      // isAfter is strict; exactly 2h is NOT after
      expect(canReschedule(apt, now), isFalse);
    });

    test('boundary: 1 minute over 2 hours — eligible', () {
      final now = DateTime(2026, 4, 1, 10);
      final apt = makeApt(
        status: AppointmentStatus.confirmed,
        appointmentDate: now.add(const Duration(hours: 2, minutes: 1)),
        timeSlot: '12:01',
      );
      expect(canReschedule(apt, now), isTrue);
    });

    test('boundary: 1 minute under 2 hours — not eligible', () {
      final now = DateTime(2026, 4, 1, 10);
      final apt = makeApt(
        status: AppointmentStatus.confirmed,
        appointmentDate: now.add(const Duration(hours: 1, minutes: 59)),
        timeSlot: '11:59',
      );
      expect(canReschedule(apt, now), isFalse);
    });

    test('returns false for all non-pending/confirmed statuses', () {
      final now = DateTime(2026, 4, 1, 10);
      for (final status in AppointmentStatus.values) {
        if (status == AppointmentStatus.pending ||
            status == AppointmentStatus.confirmed) {
          continue;
        }
        final apt = makeApt(
          status: status,
          appointmentDate: now.add(const Duration(hours: 5)),
        );
        expect(canReschedule(apt, now), isFalse, reason: 'Status: $status');
      }
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // T019 — showMedicalRecordIcon
  // ────────────────────────────────────────────────────────────────────────────
  group('showMedicalRecordIcon', () {
    test('returns true only for completed status', () {
      final now = DateTime(2026, 4, 1, 10);
      final completed = makeApt(
        status: AppointmentStatus.completed,
        appointmentDate: now,
      );
      expect(showMedicalRecordIcon(completed), isTrue);
    });

    test('returns false for all non-completed statuses', () {
      final now = DateTime(2026, 4, 1, 10);
      for (final status in AppointmentStatus.values) {
        if (status == AppointmentStatus.completed) {
          continue;
        }
        final apt = makeApt(status: status, appointmentDate: now);
        expect(
          showMedicalRecordIcon(apt),
          isFalse,
          reason: 'Status: $status should not show medical record icon',
        );
      }
    });
  });
}
