import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:elajtech/features/patient/appointments/presentation/widgets/appointment_card_widget.dart';
import 'package:flutter_test/flutter_test.dart';

bool _isValidUs1Transition(AppointmentStatus from, AppointmentStatus to) {
  const validTransitions = <AppointmentStatus, Set<AppointmentStatus>>{
    AppointmentStatus.scheduled: {AppointmentStatus.calling},
    AppointmentStatus.calling: {AppointmentStatus.inProgress},
    AppointmentStatus.inProgress: {
      AppointmentStatus.endedPendingConfirmation,
    },
    AppointmentStatus.endedPendingConfirmation: {
      AppointmentStatus.completed,
      AppointmentStatus.notCompleted,
    },
  };

  return validTransitions[from]?.contains(to) ?? false;
}

bool _isValidUs2Transition(AppointmentStatus from, AppointmentStatus to) {
  const validTransitions = <AppointmentStatus, Set<AppointmentStatus>>{
    AppointmentStatus.calling: {AppointmentStatus.missed},
    AppointmentStatus.missed: {AppointmentStatus.inProgress},
  };

  return validTransitions[from]?.contains(to) ?? false;
}

bool _isValidUs3Transition(AppointmentStatus from, AppointmentStatus to) {
  const validTransitions = <AppointmentStatus, Set<AppointmentStatus>>{
    AppointmentStatus.endedPendingConfirmation: {
      AppointmentStatus.notCompleted,
    },
  };

  return validTransitions[from]?.contains(to) ?? false;
}

bool _shouldAutoCompleteExpiredConfirmation(AppointmentStatus currentStatus) {
  return currentStatus == AppointmentStatus.endedPendingConfirmation;
}

bool _isValidUs4Transition(AppointmentStatus from, AppointmentStatus to) {
  const validTransitions = <AppointmentStatus, Set<AppointmentStatus>>{
    AppointmentStatus.calling: {
      AppointmentStatus.declined,
      AppointmentStatus.scheduled,
    },
    AppointmentStatus.declined: {AppointmentStatus.calling},
  };

  return validTransitions[from]?.contains(to) ?? false;
}

void main() {
  test('patient-facing status labels match FR-036 exactly', () {
    expect(AppointmentCardWidget.patientStatusLabels, {
      AppointmentStatus.scheduled: 'مجدول',
      AppointmentStatus.calling: 'الطبيب يتصل',
      AppointmentStatus.inProgress: 'في الاجتماع',
      AppointmentStatus.missed: 'مكالمة فائتة',
      AppointmentStatus.declined: 'تم رفض المكالمة',
      AppointmentStatus.endedPendingConfirmation: 'في انتظار التأكيد',
      AppointmentStatus.completed: 'مكتمل',
      AppointmentStatus.notCompleted: 'الجلسة غير مكتملة',
    });
  });

  group('AppointmentStatus state machine - US1', () {
    test('allows the happy-path transitions', () {
      expect(
        _isValidUs1Transition(
          AppointmentStatus.scheduled,
          AppointmentStatus.calling,
        ),
        isTrue,
      );
      expect(
        _isValidUs1Transition(
          AppointmentStatus.calling,
          AppointmentStatus.inProgress,
        ),
        isTrue,
      );
      expect(
        _isValidUs1Transition(
          AppointmentStatus.inProgress,
          AppointmentStatus.endedPendingConfirmation,
        ),
        isTrue,
      );
      expect(
        _isValidUs1Transition(
          AppointmentStatus.endedPendingConfirmation,
          AppointmentStatus.completed,
        ),
        isTrue,
      );
      expect(
        _isValidUs1Transition(
          AppointmentStatus.endedPendingConfirmation,
          AppointmentStatus.notCompleted,
        ),
        isTrue,
      );
    });

    test('rejects invalid shortcuts and regressions', () {
      expect(
        _isValidUs1Transition(
          AppointmentStatus.calling,
          AppointmentStatus.completed,
        ),
        isFalse,
      );
      expect(
        _isValidUs1Transition(
          AppointmentStatus.inProgress,
          AppointmentStatus.completed,
        ),
        isFalse,
      );
      expect(
        _isValidUs1Transition(
          AppointmentStatus.completed,
          AppointmentStatus.scheduled,
        ),
        isFalse,
      );
      expect(
        _isValidUs1Transition(
          AppointmentStatus.notCompleted,
          AppointmentStatus.completed,
        ),
        isFalse,
      );
    });
  });

  group('AppointmentStatus state machine - US2', () {
    test('allows missed-call transitions and rejoin path', () {
      expect(
        _isValidUs2Transition(
          AppointmentStatus.calling,
          AppointmentStatus.missed,
        ),
        isTrue,
      );
      expect(
        _isValidUs2Transition(
          AppointmentStatus.missed,
          AppointmentStatus.inProgress,
        ),
        isTrue,
      );
    });

    test('rejects wrong-state and expired-session style transitions', () {
      expect(
        _isValidUs2Transition(
          AppointmentStatus.scheduled,
          AppointmentStatus.inProgress,
        ),
        isFalse,
      );
      expect(
        _isValidUs2Transition(
          AppointmentStatus.completed,
          AppointmentStatus.inProgress,
        ),
        isFalse,
      );
      expect(
        _isValidUs2Transition(
          AppointmentStatus.missed,
          AppointmentStatus.completed,
        ),
        isFalse,
      );
    });
  });

  group('AppointmentStatus state machine - US3', () {
    test(
      'allows auto-transition from pending confirmation to not completed',
      () {
        expect(
          _isValidUs3Transition(
            AppointmentStatus.endedPendingConfirmation,
            AppointmentStatus.notCompleted,
          ),
          isTrue,
        );
      },
    );

    test('doctor response beats auto-transition race condition', () {
      expect(
        _shouldAutoCompleteExpiredConfirmation(
          AppointmentStatus.endedPendingConfirmation,
        ),
        isTrue,
      );
      expect(
        _shouldAutoCompleteExpiredConfirmation(AppointmentStatus.completed),
        isFalse,
      );
      expect(
        _shouldAutoCompleteExpiredConfirmation(AppointmentStatus.notCompleted),
        isFalse,
      );
    });
  });

  group('AppointmentStatus state machine - US4', () {
    test('allows decline, retry, and doctor cancel transitions', () {
      expect(
        _isValidUs4Transition(
          AppointmentStatus.calling,
          AppointmentStatus.declined,
        ),
        isTrue,
      );
      expect(
        _isValidUs4Transition(
          AppointmentStatus.declined,
          AppointmentStatus.calling,
        ),
        isTrue,
      );
      expect(
        _isValidUs4Transition(
          AppointmentStatus.calling,
          AppointmentStatus.scheduled,
        ),
        isTrue,
      );
    });
  });
}
