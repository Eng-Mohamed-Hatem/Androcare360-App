import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/core/models/paginated_result.dart';
import 'package:elajtech/core/services/call_monitoring_service.dart';
import 'package:elajtech/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/notifications/domain/repositories/notification_repository.dart';
import 'package:elajtech/features/patient/appointments/presentation/widgets/reschedule_appointment_sheet.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:elajtech/shared/models/notification_model.dart';
import 'package:elajtech/shared/providers/appointments_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/user_fixtures.dart';
import '../../../mocks/mock_auth_repository.dart';
import '../../../mocks/mocks.mocks.dart';

class _TestCallMonitoringService extends CallMonitoringService {
  _TestCallMonitoringService() : super(MockFirebaseFirestore());

  @override
  Future<void> logJoinMeetingTap({
    required String appointmentId,
    required String userId,
    required String outcome,
  }) async {}

  @override
  Future<void> logRescheduleSubmitted({
    required String appointmentId,
    required String userId,
    required DateTime originalDateTime,
    required DateTime newDateTime,
    required String outcome,
  }) async {}
}

class _FakeAppointmentRepository implements AppointmentRepository {
  bool hasConflict = false;
  bool shouldFailSave = false;

  @override
  Future<Either<Failure, Unit>> saveAppointment(
    AppointmentModel appointment,
  ) async {
    if (shouldFailSave) {
      return const Left(ServerFailure('save failed'));
    }
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> bookAppointment(
    AppointmentModel appointment,
  ) async => const Right(unit);

  @override
  Future<Either<Failure, List<AppointmentModel>>> getAppointmentsForPatient(
    String patientId,
  ) async => const Right([]);

  @override
  Future<Either<Failure, PaginatedResult<AppointmentModel>>>
  getAppointmentsForPatientPage(
    String patientId, {
    int limit = 10,
  }) async =>
      const Right(PaginatedResult<AppointmentModel>(items: [], hasMore: false));

  @override
  Future<Either<Failure, List<AppointmentModel>>> getAppointmentsForDoctor(
    String doctorId,
  ) async => const Right([]);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>>
  getDoctorAppointmentsViaCloudFunction({
    required String doctorId,
    required DateTime date,
  }) async => const Right([]);

  @override
  Future<Either<Failure, bool>> checkAppointmentConflict({
    required String patientId,
    required AppointmentModel newAppointment,
  }) async => Right(hasConflict);

  @override
  Future<Either<Failure, List<AppointmentModel>>>
  getActiveAppointmentsForPatient(String patientId) async => const Right([]);

  @override
  Future<Either<Failure, List<AppointmentModel>>> getActiveAppointmentsForDate(
    DateTime date,
  ) async => const Right([]);

  @override
  Stream<List<AppointmentModel>> watchAppointmentsForPatient(
    String patientId,
  ) => Stream.value(<AppointmentModel>[]);
}

class _FakeNotificationRepository implements NotificationRepository {
  @override
  Future<Either<Failure, Unit>> saveNotification(
    NotificationModel notification,
  ) async => const Right(unit);

  @override
  Future<Either<Failure, List<NotificationModel>>> getNotificationsForUser(
    String userId,
  ) async => const Right([]);

  @override
  Stream<List<NotificationModel>> getNotificationsStream(String userId) =>
      const Stream.empty();

  @override
  Future<Either<Failure, Unit>> markAllNotificationsAsRead(
    String userId,
  ) async => const Right(unit);
}

class _TestAppointmentsNotifier extends AppointmentsNotifier {
  _TestAppointmentsNotifier(this.repo)
    : super(repo, _FakeNotificationRepository());

  final _FakeAppointmentRepository repo;
}

void main() {
  late _FakeAppointmentRepository appointmentRepo;
  late _TestAppointmentsNotifier appointmentsNotifier;

  setUp(() async {
    appointmentRepo = _FakeAppointmentRepository();
    appointmentsNotifier = _TestAppointmentsNotifier(appointmentRepo);

    if (getIt.isRegistered<CallMonitoringService>()) {
      await getIt.unregister<CallMonitoringService>();
    }
    getIt.registerSingleton<CallMonitoringService>(
      _TestCallMonitoringService(),
    );
  });

  tearDown(() async {
    if (getIt.isRegistered<CallMonitoringService>()) {
      await getIt.unregister<CallMonitoringService>();
    }
  });

  AppointmentModel makeAppointment() {
    final futureDate = DateTime.now().add(const Duration(days: 2));
    return AppointmentModel(
      id: 'apt_1',
      patientId: 'patient_test_001',
      patientName: 'Test Patient',
      patientPhone: '+966500000002',
      doctorId: 'doctor_1',
      doctorName: 'Dr. Test',
      specialization: 'Andrology',
      appointmentDate: futureDate,
      timeSlot: '10:00 ص',
      type: AppointmentType.video,
      status: AppointmentStatus.confirmed,
      fee: 0,
      createdAt: DateTime(2026),
    );
  }

  Future<void> pumpSheet(
    WidgetTester tester, {
    required AppointmentModel appointment,
    required void Function(DateTime newDateTime) onRescheduled,
  }) async {
    final patient = UserFixtures.createPatient();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) {
            return AuthNotifier(
              MockAuthRepository(currentUser: patient),
            )..state = AuthState(user: patient, isAuthenticated: true);
          }),
          appointmentsProvider.overrideWith((ref) => appointmentsNotifier),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  unawaited(
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => RescheduleAppointmentSheet(
                        appointment: appointment,
                        onRescheduled: onRescheduled,
                      ),
                    ),
                  );
                },
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();
  }

  Future<void> selectTomorrowAndFirstSlot(WidgetTester tester) async {
    final calendar = tester.widget<CalendarDatePicker>(
      find.byType(CalendarDatePicker),
    );
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    calendar.onDateChanged(tomorrow);
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('08:00 ص').first,
      200,
      scrollable: scrollable,
    );
    final slotFinder = find
        .ancestor(
          of: find.text('08:00 ص').first,
          matching: find.byType(GestureDetector),
        )
        .first;
    final slotTile = tester.widget<GestureDetector>(slotFinder);
    slotTile.onTap!.call();
    await tester.pumpAndSettle();
  }

  Future<void> confirmReschedule(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.text('تأكيد إعادة الجدولة'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNotNull);
    button.onPressed!.call();
    await tester.pumpAndSettle();
  }

  group('RescheduleAppointmentSheet', () {
    testWidgets('shows calendar and initial slot grid', (tester) async {
      await pumpSheet(
        tester,
        appointment: makeAppointment(),
        onRescheduled: (_) {},
      );

      expect(find.byType(CalendarDatePicker), findsOneWidget);
      expect(find.text('اختر وقتاً'), findsOneWidget);
      await selectTomorrowAndFirstSlot(tester);
      expect(find.text('08:00 ص'), findsOneWidget);
    });

    testWidgets('shows conflict error inline', (tester) async {
      appointmentRepo.hasConflict = true;

      await pumpSheet(
        tester,
        appointment: makeAppointment(),
        onRescheduled: (_) {},
      );

      await selectTomorrowAndFirstSlot(tester);
      await confirmReschedule(tester);
      await tester.pumpAndSettle();

      expect(find.text('هذا الموعد محجوز، اختر وقتاً آخر'), findsOneWidget);
      expect(find.byType(RescheduleAppointmentSheet), findsOneWidget);
    });

    testWidgets('success closes sheet and triggers callback', (tester) async {
      DateTime? rescheduledTo;

      await pumpSheet(
        tester,
        appointment: makeAppointment(),
        onRescheduled: (newDateTime) {
          rescheduledTo = newDateTime;
        },
      );

      await selectTomorrowAndFirstSlot(tester);
      await confirmReschedule(tester);

      expect(rescheduledTo, isNotNull);
      expect(find.byType(RescheduleAppointmentSheet), findsNothing);
    });
  });
}
