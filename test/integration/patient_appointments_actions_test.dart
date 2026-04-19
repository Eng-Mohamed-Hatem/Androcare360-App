import 'package:dartz/dartz.dart';
import 'package:elajtech/core/constants/specialty_constants.dart';
import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/core/error/failures.dart' as app_failures;
import 'package:elajtech/core/errors/exceptions.dart';
import 'package:elajtech/core/errors/failures.dart' as emr_failures;
import 'package:elajtech/core/models/paginated_result.dart';
import 'package:elajtech/core/services/call_monitoring_service.dart';
import 'package:elajtech/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/device_requests/domain/repositories/device_request_repository.dart';
import 'package:elajtech/features/emr/domain/repositories/emr_repository.dart';
import 'package:elajtech/features/emr/domain/repositories/internal_medicine_emr_repository.dart';
import 'package:elajtech/features/emr/domain/repositories/physiotherapy_emr_repository.dart';
import 'package:elajtech/features/lab_requests/domain/repositories/lab_request_repository.dart';
import 'package:elajtech/features/medical_records/presentation/screens/appointment_medical_record_screen.dart';
import 'package:elajtech/features/notifications/domain/repositories/notification_repository.dart';
import 'package:elajtech/features/nutrition/domain/entities/nutrition_emr_entity.dart';
import 'package:elajtech/features/nutrition/domain/repositories/nutrition_emr_repository.dart';
import 'package:elajtech/features/patient/appointments/presentation/screens/patient_appointments_screen.dart';
import 'package:elajtech/features/patient/appointments/presentation/widgets/appointment_card_widget.dart';
import 'package:elajtech/features/patient/appointments/presentation/widgets/reschedule_appointment_sheet.dart';
import 'package:elajtech/features/prescriptions/domain/repositories/prescription_repository.dart';
import 'package:elajtech/features/radiology_requests/domain/repositories/radiology_request_repository.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:elajtech/shared/models/device_request_model.dart';
import 'package:elajtech/shared/models/emr_model.dart';
import 'package:elajtech/shared/models/internal_medicine_emr_model.dart';
import 'package:elajtech/shared/models/lab_request_model.dart';
import 'package:elajtech/shared/models/notification_model.dart';
import 'package:elajtech/shared/models/physiotherapy_emr_model.dart';
import 'package:elajtech/shared/models/prescription_model.dart';
import 'package:elajtech/shared/models/radiology_request_model.dart';
import 'package:elajtech/shared/providers/appointments_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/appointment_fixtures.dart';
import '../fixtures/user_fixtures.dart';
import '../mocks/mocks.mocks.dart';
import '../mocks/mock_auth_repository.dart';

class _FakeAppointmentRepository implements AppointmentRepository {
  _FakeAppointmentRepository(this.appointments);

  final List<AppointmentModel> appointments;
  bool hasConflict = false;
  final List<AppointmentModel> savedAppointments = [];

  @override
  Future<Either<app_failures.Failure, Unit>> saveAppointment(
    AppointmentModel appointment,
  ) async {
    savedAppointments.add(appointment);
    return const Right(unit);
  }

  @override
  Future<Either<app_failures.Failure, Unit>> bookAppointment(
    AppointmentModel appointment,
  ) async => const Right(unit);

  @override
  Future<Either<app_failures.Failure, List<AppointmentModel>>>
  getAppointmentsForPatient(String patientId) async => Right(
    appointments
        .where((appointment) => appointment.patientId == patientId)
        .toList(),
  );

  @override
  Future<Either<app_failures.Failure, PaginatedResult<AppointmentModel>>>
  getAppointmentsForPatientPage(String patientId, {int limit = 10}) async {
    final patientAppointments = appointments
        .where((appointment) => appointment.patientId == patientId)
        .toList();
    return Right(
      PaginatedResult<AppointmentModel>(
        items: patientAppointments.take(limit).toList(),
        hasMore: patientAppointments.length > limit,
      ),
    );
  }

  @override
  Future<Either<app_failures.Failure, List<AppointmentModel>>>
  getAppointmentsForDoctor(String doctorId) async => Right(
    appointments
        .where((appointment) => appointment.doctorId == doctorId)
        .toList(),
  );

  @override
  Future<Either<app_failures.Failure, List<Map<String, dynamic>>>>
  getDoctorAppointmentsViaCloudFunction({
    required String doctorId,
    required DateTime date,
  }) async => Right(
    appointments
        .where((appointment) => appointment.doctorId == doctorId)
        .map(
          (appointment) => {
            'id': appointment.id,
            'doctorId': appointment.doctorId,
            'patientId': appointment.patientId,
            'doctorName': appointment.doctorName,
            'status': appointment.status.name,
            'timeSlot': appointment.timeSlot,
            'appointmentTimestamp':
                appointment.fullDateTime.millisecondsSinceEpoch,
          },
        )
        .toList(),
  );

  @override
  Future<Either<app_failures.Failure, bool>> checkAppointmentConflict({
    required String patientId,
    required AppointmentModel newAppointment,
  }) async => Right(hasConflict);

  @override
  Future<Either<app_failures.Failure, List<AppointmentModel>>>
  getActiveAppointmentsForPatient(String patientId) async => const Right([]);

  @override
  Future<Either<app_failures.Failure, List<AppointmentModel>>>
  getActiveAppointmentsForDate(DateTime date) async => const Right([]);

  @override
  Stream<List<AppointmentModel>> watchAppointmentsForPatient(
    String patientId,
  ) => Stream.value(appointments.where((a) => a.patientId == patientId).toList());
}

class _FakeNotificationRepository implements NotificationRepository {
  @override
  Future<Either<app_failures.Failure, Unit>> saveNotification(
    NotificationModel notification,
  ) async => const Right(unit);

  @override
  Future<Either<app_failures.Failure, List<NotificationModel>>>
  getNotificationsForUser(String userId) async => const Right([]);

  @override
  Stream<List<NotificationModel>> getNotificationsStream(String userId) =>
      const Stream.empty();

  @override
  Future<Either<app_failures.Failure, Unit>> markAllNotificationsAsRead(
    String userId,
  ) async => const Right(unit);
}

class _StaticAppointmentsNotifier extends AppointmentsNotifier {
  _StaticAppointmentsNotifier(this._appointments)
    : super(
        _FakeAppointmentRepository(_appointments),
        _FakeNotificationRepository(),
      ) {
    state = _appointments;
  }

  final List<AppointmentModel> _appointments;

  @override
  Future<bool> loadForPatient(String patientId) async {
    state = _appointments
        .where((appointment) => appointment.patientId == patientId)
        .toList();
    return true;
  }
}

class _InteractiveAppointmentsNotifier extends AppointmentsNotifier {
  _InteractiveAppointmentsNotifier(this.repo, this._appointments)
    : super(repo, _FakeNotificationRepository()) {
    state = _appointments;
  }

  final _FakeAppointmentRepository repo;
  final List<AppointmentModel> _appointments;

  @override
  Future<bool> loadForPatient(String patientId) async {
    state = _appointments
        .where((appointment) => appointment.patientId == patientId)
        .toList();
    return true;
  }
}

class _FakePrescriptionRepository implements PrescriptionRepository {
  @override
  Future<Either<app_failures.Failure, Unit>> savePrescription(
    PrescriptionModel prescription,
  ) async => const Right(unit);

  @override
  Future<Either<app_failures.Failure, List<PrescriptionModel>>>
  getPrescriptionsForPatient(String patientId) async => const Right([]);

  @override
  Future<Either<app_failures.Failure, PaginatedResult<PrescriptionModel>>>
  getPrescriptionsForPatientPage(String patientId, {int limit = 10}) async =>
      const Right(
        PaginatedResult<PrescriptionModel>(items: [], hasMore: false),
      );

  @override
  Future<Either<app_failures.Failure, List<PrescriptionModel>>>
  getPrescriptionsByDoctor(String doctorId) async => const Right([]);

  @override
  Future<Either<app_failures.Failure, List<PrescriptionModel>>>
  getPrescriptionsByAppointmentId(String appointmentId) async =>
      const Right([]);
}

class _FakeLabRequestRepository implements LabRequestRepository {
  @override
  Future<Either<app_failures.Failure, void>> saveLabRequest(
    LabRequestModel request,
  ) async => const Right(null);

  @override
  Future<Either<app_failures.Failure, List<LabRequestModel>>>
  getLabRequestsForPatient(String patientId) async => const Right([]);

  @override
  Future<Either<app_failures.Failure, PaginatedResult<LabRequestModel>>>
  getLabRequestsForPatientPage(String patientId, {int limit = 10}) async =>
      const Right(PaginatedResult<LabRequestModel>(items: [], hasMore: false));

  @override
  Future<Either<app_failures.Failure, List<LabRequestModel>>>
  getLabRequestsByAppointmentId(String appointmentId) async => const Right([]);
}

class _FakeRadiologyRequestRepository implements RadiologyRequestRepository {
  @override
  Future<Either<app_failures.Failure, void>> saveRadiologyRequest(
    RadiologyRequestModel request,
  ) async => const Right(null);

  @override
  Future<Either<app_failures.Failure, List<RadiologyRequestModel>>>
  getRadiologyRequestsForPatient(String patientId) async => const Right([]);

  @override
  Future<Either<app_failures.Failure, PaginatedResult<RadiologyRequestModel>>>
  getRadiologyRequestsForPatientPage(
    String patientId, {
    int limit = 10,
  }) async => const Right(
    PaginatedResult<RadiologyRequestModel>(items: [], hasMore: false),
  );

  @override
  Future<Either<app_failures.Failure, List<RadiologyRequestModel>>>
  getRadiologyRequestsByAppointmentId(String appointmentId) async =>
      const Right([]);
}

class _FakeDeviceRequestRepository implements DeviceRequestRepository {
  @override
  Future<Either<app_failures.Failure, void>> saveDeviceRequest(
    DeviceRequestModel request,
  ) async => const Right(null);

  @override
  Future<Either<app_failures.Failure, List<DeviceRequestModel>>>
  getDeviceRequestsForPatient(String patientId) async => const Right([]);

  @override
  Future<Either<app_failures.Failure, PaginatedResult<DeviceRequestModel>>>
  getDeviceRequestsForPatientPage(String patientId, {int limit = 10}) async =>
      const Right(
        PaginatedResult<DeviceRequestModel>(items: [], hasMore: false),
      );

  @override
  Future<Either<app_failures.Failure, List<DeviceRequestModel>>>
  getDeviceRequestsByAppointmentId(String appointmentId) async =>
      const Right([]);
}

class _FakeEMRRepository implements EMRRepository {
  _FakeEMRRepository({this.emr});

  final EMRModel? emr;

  @override
  Future<Either<emr_failures.Failure, Unit>> saveEMR(EMRModel emr) async =>
      const Right(unit);

  @override
  Future<Either<emr_failures.Failure, EMRModel?>> getEMRByAppointmentId(
    String appointmentId,
  ) async => Right(
    emr != null && emr!.appointmentId == appointmentId ? emr : null,
  );
}

class _FakeInternalMedicineEMRRepository
    implements InternalMedicineEMRRepository {
  @override
  Future<Either<emr_failures.Failure, void>> saveEMR(
    InternalMedicineEMRModel emr,
  ) async => const Right(null);

  @override
  Future<Either<emr_failures.Failure, InternalMedicineEMRModel?>>
  getEMRByAppointmentId(String appointmentId) async => const Right(null);

  @override
  Future<Either<emr_failures.Failure, List<InternalMedicineEMRModel>>>
  getEMRByPatientId(String patientId) async => const Right([]);
}

class _FakeNutritionEMRRepository implements NutritionEMRRepository {
  @override
  Future<Either<emr_failures.Failure, void>> saveEMR(
    NutritionEMREntity emr,
  ) async => const Right(null);

  @override
  Future<Either<emr_failures.Failure, NutritionEMREntity?>>
  getEMRByAppointmentId(String appointmentId) async => const Right(null);

  @override
  Future<Either<emr_failures.Failure, List<NutritionEMREntity>>>
  getEMRsByPatientId(String patientId) async => const Right([]);

  @override
  Future<Either<emr_failures.Failure, void>> lockEMR(String emrId) async =>
      const Right(null);

  @override
  Future<Either<emr_failures.Failure, bool>> isAppointmentExpired(
    String appointmentId,
  ) async => const Right(false);

  @override
  Future<Either<emr_failures.Failure, Stream<NutritionEMREntity>>> watchEMR(
    String emrId,
  ) async => const Right(Stream.empty());
}

class _FakePhysiotherapyEMRRepository implements PhysiotherapyEMRRepository {
  @override
  Future<Either<emr_failures.Failure, void>> saveEMR(
    PhysiotherapyEMRModel emr,
  ) async => const Right(null);

  @override
  Future<Either<emr_failures.Failure, PhysiotherapyEMRModel?>>
  getEMRByAppointmentId(String appointmentId) async => const Right(null);

  @override
  Future<Either<emr_failures.Failure, List<PhysiotherapyEMRModel>>>
  getEMRByPatientId(String patientId) async => const Right([]);
}

class _TestNavigatorObserver extends NavigatorObserver {
  int pushCount = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushCount += 1;
    super.didPush(route, previousRoute);
  }
}

class _RecordingCallMonitoringService extends CallMonitoringService {
  _RecordingCallMonitoringService() : super(MockFirebaseFirestore());

  final List<String> joinOutcomes = [];
  final List<String> rescheduleOutcomes = [];

  @override
  Future<void> logJoinMeetingTap({
    required String appointmentId,
    required String userId,
    required String outcome,
  }) async {
    joinOutcomes.add(outcome);
  }

  @override
  Future<void> logRescheduleSubmitted({
    required String appointmentId,
    required String userId,
    required DateTime originalDateTime,
    required DateTime newDateTime,
    required String outcome,
  }) async {
    rescheduleOutcomes.add(outcome);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _RecordingCallMonitoringService callMonitoringService;

  setUp(() async {
    callMonitoringService = _RecordingCallMonitoringService();
    for (final unregister in [
      () => getIt.isRegistered<PrescriptionRepository>()
          ? getIt.unregister<PrescriptionRepository>()
          : null,
      () => getIt.isRegistered<LabRequestRepository>()
          ? getIt.unregister<LabRequestRepository>()
          : null,
      () => getIt.isRegistered<RadiologyRequestRepository>()
          ? getIt.unregister<RadiologyRequestRepository>()
          : null,
      () => getIt.isRegistered<DeviceRequestRepository>()
          ? getIt.unregister<DeviceRequestRepository>()
          : null,
      () => getIt.isRegistered<EMRRepository>()
          ? getIt.unregister<EMRRepository>()
          : null,
      () => getIt.isRegistered<InternalMedicineEMRRepository>()
          ? getIt.unregister<InternalMedicineEMRRepository>()
          : null,
      () => getIt.isRegistered<NutritionEMRRepository>()
          ? getIt.unregister<NutritionEMRRepository>()
          : null,
      () => getIt.isRegistered<PhysiotherapyEMRRepository>()
          ? getIt.unregister<PhysiotherapyEMRRepository>()
          : null,
      () => getIt.isRegistered<CallMonitoringService>()
          ? getIt.unregister<CallMonitoringService>()
          : null,
    ]) {
      await unregister();
    }
    getIt.registerSingleton<CallMonitoringService>(callMonitoringService);
  });

  AppointmentModel completedAppointment() {
    return AppointmentFixtures.createCompletedAppointment(
      patientId: 'patient_test_001',
    ).copyWith(
      doctorName: 'Dr. Completed',
      specialization: SpecialtyConstants.andrologyClinic,
    );
  }

  AppointmentModel missedAppointment() {
    return AppointmentFixtures.createCompletedAppointment(
      id: 'apt_missed_001',
      patientId: 'patient_test_001',
    ).copyWith(
      doctorName: 'Dr. Missed',
      status: AppointmentStatus.missed,
      callSessionActive: false,
      specialization: SpecialtyConstants.andrologyClinic,
    );
  }

  EMRModel existingEmr(String appointmentId) {
    return EMRModel(
      id: 'emr_123',
      patientId: 'patient_test_001',
      appointmentId: appointmentId,
      doctorId: 'doc_101',
      doctorName: 'Dr. Test',
      libidoLevel: 'Normal',
      onsetOfErectileDifficulty: 'Gradual',
      frequencyOfIntercourseAttempts: '2 times/week',
      penetrationSuccess: '100%',
      erectionRigidity: '4',
      nocturnalMorningErections: 'Present',
      ejaculatoryFunction: 'Normal',
      orgasmicSatisfaction: 'Good',
      partnerSatisfaction: 'Good',
      concernAboutPenileSize: 'None',
      opinionAboutPartnerSatisfaction: 'Satisfied',
      pastHomosexualExperience: false,
      interestedInHomosexuality: false,
      historyOfSexualTraumaInChildhood: false,
      historyOfPornoAddiction: false,
      historyOfMasturbationAddiction: false,
      historyOfIllegalSex: false,
      historyOfHavingSTDs: false,
      historyOfPenileTrauma: false,
      historyMedication: false,
      historyOfPenileCurvature: false,
      pde5I: 'None',
      supplements: 'None',
      hormones: 'None',
      previousHormones: 'None',
      previousGeneralLab: 'Normal',
      duplexPenileArteries: 'Normal',
      testicularUS: 'Normal',
      penileUS: 'Normal',
      trus: 'Normal',
      abdominopelvicUS: 'Normal',
      durationOfMarriage: '5 years',
      ageOfWife: '30',
      multipleWives: false,
      durationOfInfertility: 'None',
      infertilityType: 'Primary',
      previousConceptions: true,
      historyOfVaricoceleGenitalSurgery: 'None',
      semenAnalysisSummary: 'Normal',
      hormonalProfile: 'Normal',
      geneticOtherTests: 'None',
      urinaryFrequency: 'Normal',
      stream: 'Normal',
      nocturia: '0',
      strainingOrIncompleteEmptying: false,
      psaLevelDate: 'Normal',
      trusProstatic: 'Normal',
      uroflowmetry: 'Normal',
      generalAppearanceBMI: 'Normal',
      genitalExamination: 'Normal',
      testicularSizeConsistency: 'Normal',
      epididymisVas: 'Normal',
      digitalRectalExamination: 'Normal',
      impressionDiagnosis: 'Healthy',
      recommendedInvestigations: 'None',
      initialTreatmentPlan: 'None',
      followUpInterval: 'None',
      createdAt: DateTime(2024, 3, 10),
    );
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    required List<AppointmentModel> appointments,
    required EMRModel? emr,
    required _TestNavigatorObserver observer,
  }) async {
    final patient = UserFixtures.createPatient(id: 'patient_test_001');
    final appointmentsNotifier = _StaticAppointmentsNotifier(appointments);

    getIt
      ..registerSingleton<PrescriptionRepository>(
        _FakePrescriptionRepository(),
      )
      ..registerSingleton<LabRequestRepository>(_FakeLabRequestRepository())
      ..registerSingleton<RadiologyRequestRepository>(
        _FakeRadiologyRequestRepository(),
      )
      ..registerSingleton<DeviceRequestRepository>(
        _FakeDeviceRequestRepository(),
      )
      ..registerSingleton<EMRRepository>(_FakeEMRRepository(emr: emr))
      ..registerSingleton<InternalMedicineEMRRepository>(
        _FakeInternalMedicineEMRRepository(),
      )
      ..registerSingleton<NutritionEMRRepository>(
        _FakeNutritionEMRRepository(),
      )
      ..registerSingleton<PhysiotherapyEMRRepository>(
        _FakePhysiotherapyEMRRepository(),
      );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) {
            return AuthNotifier(
              MockAuthRepository(currentUser: patient),
            )..state = AuthState(user: patient, isAuthenticated: true);
          }),
          appointmentsProvider.overrideWith((ref) => appointmentsNotifier),
          // Override stream provider to avoid GetIt look-up and provide test data
          patientAppointmentsStreamProvider.overrideWith(
            (ref, patientId) => Stream.value(
              appointments.where((a) => a.patientId == patientId).toList(),
            ),
          ),
        ],
        child: MaterialApp(
          navigatorObservers: [observer],
          home: const PatientAppointmentsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Tab).at(1));
    await tester.pumpAndSettle();
  }

  Future<void> pumpCard(
    WidgetTester tester, {
    required AppointmentModel appointment,
    Future<void> Function()? onJoinMeeting,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: AppointmentCardWidget(
              appointment: appointment,
              onJoinMeeting: onJoinMeeting,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpRescheduleSheet(
    WidgetTester tester, {
    required AppointmentModel appointment,
    required _InteractiveAppointmentsNotifier appointmentsNotifier,
    required void Function(DateTime newDateTime) onRescheduled,
  }) async {
    final patient = UserFixtures.createPatient(id: 'patient_test_001');

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
            body: RescheduleAppointmentSheet(
              appointment: appointment,
              onRescheduled: onRescheduled,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> selectTomorrowAndFirstSlot(WidgetTester tester) async {
    final calendar = tester.widget<CalendarDatePicker>(
      find.byType(CalendarDatePicker),
    );
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    calendar.onDateChanged(tomorrow);
    await tester.pumpAndSettle();

    final slotFinder = find
        .ancestor(
          of: find.text('08:00 ص').first,
          matching: find.byType(GestureDetector),
        )
        .first;
    tester.widget<GestureDetector>(slotFinder).onTap!.call();
    await tester.pumpAndSettle();
  }

  Future<void> confirmReschedule(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.text('تأكيد إعادة الجدولة'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'تأكيد إعادة الجدولة'),
    );
    button.onPressed!.call();
    await tester.pumpAndSettle();
  }

  tearDown(() async {
    for (final unregister in [
      () => getIt.isRegistered<PrescriptionRepository>()
          ? getIt.unregister<PrescriptionRepository>()
          : null,
      () => getIt.isRegistered<LabRequestRepository>()
          ? getIt.unregister<LabRequestRepository>()
          : null,
      () => getIt.isRegistered<RadiologyRequestRepository>()
          ? getIt.unregister<RadiologyRequestRepository>()
          : null,
      () => getIt.isRegistered<DeviceRequestRepository>()
          ? getIt.unregister<DeviceRequestRepository>()
          : null,
      () => getIt.isRegistered<EMRRepository>()
          ? getIt.unregister<EMRRepository>()
          : null,
      () => getIt.isRegistered<InternalMedicineEMRRepository>()
          ? getIt.unregister<InternalMedicineEMRRepository>()
          : null,
      () => getIt.isRegistered<NutritionEMRRepository>()
          ? getIt.unregister<NutritionEMRRepository>()
          : null,
      () => getIt.isRegistered<PhysiotherapyEMRRepository>()
          ? getIt.unregister<PhysiotherapyEMRRepository>()
          : null,
      () => getIt.isRegistered<CallMonitoringService>()
          ? getIt.unregister<CallMonitoringService>()
          : null,
    ]) {
      await unregister();
    }
  });

  group('Patient appointment actions integration', () {
    testWidgets(
      'completed card tap navigates to AppointmentMedicalRecordScreen',
      (
        tester,
      ) async {
        final completed = completedAppointment();
        final observer = _TestNavigatorObserver();

        await pumpScreen(
          tester,
          appointments: [completed, missedAppointment()],
          emr: existingEmr(completed.id),
          observer: observer,
        );

        final basePushCount = observer.pushCount;
        await tester.tap(
          find
              .ancestor(
                of: find.text(completed.doctorName),
                matching: find.byType(InkWell),
              )
              .first,
        );
        await tester.pumpAndSettle();

        expect(observer.pushCount, greaterThan(basePushCount));
        expect(find.byType(AppointmentMedicalRecordScreen), findsOneWidget);
      },
    );

    testWidgets('completed icon tap navigates to same screen', (tester) async {
      final completed = completedAppointment();
      final observer = _TestNavigatorObserver();

      await pumpScreen(
        tester,
        appointments: [completed],
        emr: existingEmr(completed.id),
        observer: observer,
      );

      final basePushCount = observer.pushCount;
      await tester.tap(find.byIcon(Icons.article_outlined));
      await tester.pumpAndSettle();

      expect(observer.pushCount, greaterThan(basePushCount));
      expect(find.byType(AppointmentMedicalRecordScreen), findsOneWidget);
    });

    testWidgets('completed card with no EMR shows SnackBar', (tester) async {
      final completed = completedAppointment();
      final observer = _TestNavigatorObserver();

      await pumpScreen(
        tester,
        appointments: [completed],
        emr: null,
        observer: observer,
      );

      final basePushCount = observer.pushCount;
      await tester.tap(
        find
            .ancestor(
              of: find.text(completed.doctorName),
              matching: find.byType(InkWell),
            )
            .first,
      );
      await tester.pumpAndSettle();

      expect(observer.pushCount, equals(basePushCount));
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('non-completed card does not navigate to EMR', (tester) async {
      final missed = missedAppointment();
      final observer = _TestNavigatorObserver();

      await pumpScreen(
        tester,
        appointments: [missed],
        emr: null,
        observer: observer,
      );

      final basePushCount = observer.pushCount;
      await tester.tap(find.text(missed.doctorName));
      await tester.pumpAndSettle();

      expect(observer.pushCount, equals(basePushCount));
      expect(find.byType(AppointmentMedicalRecordScreen), findsNothing);
    });

    testWidgets('waiting label transitions to join button and logs join outcomes', (
      tester,
    ) async {
      final outsideWindow = DateTime.now().add(const Duration(days: 1));
      // No Agora credentials → showWaitingForCall = true (status confirmed,
      // not in join window, no token/channel).
      await pumpCard(
        tester,
        appointment:
            AppointmentFixtures.createConfirmedAppointment(
              patientId: 'patient_1',
              channelName: '',
              agoraToken: '',
            ).copyWith(
              appointmentDate: outsideWindow,
              timeSlot: '10:00',
            ),
      );

      expect(find.text('في انتظار المكالمة'), findsOneWidget);
      expect(find.text('انضم للاجتماع'), findsNothing);

      final insideWindow = DateTime.now().add(const Duration(minutes: 5));
      await pumpCard(
        tester,
        appointment:
            AppointmentFixtures.createConfirmedAppointment(
              patientId: 'patient_1',
            ).copyWith(
              appointmentDate: insideWindow,
              timeSlot:
                  '${insideWindow.hour}:${insideWindow.minute.toString().padLeft(2, '0')}',
            ),
        onJoinMeeting: () async {},
      );

      expect(find.text('في انتظار المكالمة'), findsNothing);
      expect(find.text('انضم للاجتماع'), findsOneWidget);

      await tester.tap(find.text('انضم للاجتماع'));
      await tester.pumpAndSettle();
      expect(callMonitoringService.joinOutcomes, contains('navigated'));

      callMonitoringService.joinOutcomes.clear();
      await pumpCard(
        tester,
        appointment:
            AppointmentFixtures.createConfirmedAppointment(
              patientId: 'patient_1',
            ).copyWith(
              appointmentDate: insideWindow,
              timeSlot:
                  '${insideWindow.hour}:${insideWindow.minute.toString().padLeft(2, '0')}',
            ),
        onJoinMeeting: () async {
          throw const AgoraException('not found', code: 'NOT_FOUND');
        },
      );

      await tester.tap(find.text('انضم للاجتماع'));
      await tester.pumpAndSettle();
      expect(callMonitoringService.joinOutcomes, contains('session_expired'));
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('reschedule flow updates appointment and logs confirmed', (
      tester,
    ) async {
      final repo = _FakeAppointmentRepository([]);
      final appointment =
          AppointmentFixtures.createConfirmedAppointment(
            patientId: 'patient_test_001',
          ).copyWith(
            appointmentDate: DateTime.now().add(const Duration(days: 2)),
            timeSlot: '10:00 ص',
          );
      final notifier = _InteractiveAppointmentsNotifier(repo, [appointment]);
      DateTime? rescheduledTo;

      await pumpRescheduleSheet(
        tester,
        appointment: appointment,
        appointmentsNotifier: notifier,
        onRescheduled: (newDateTime) {
          rescheduledTo = newDateTime;
        },
      );

      await selectTomorrowAndFirstSlot(tester);
      await confirmReschedule(tester);

      expect(rescheduledTo, isNotNull);
      expect(repo.savedAppointments, isNotEmpty);
      expect(callMonitoringService.rescheduleOutcomes, contains('confirmed'));
    });

    testWidgets('reschedule conflict logs conflict outcome', (tester) async {
      final repo = _FakeAppointmentRepository([])..hasConflict = true;
      final appointment =
          AppointmentFixtures.createConfirmedAppointment(
            patientId: 'patient_test_001',
          ).copyWith(
            appointmentDate: DateTime.now().add(const Duration(days: 2)),
            timeSlot: '10:00 ص',
          );
      final notifier = _InteractiveAppointmentsNotifier(repo, [appointment]);

      await pumpRescheduleSheet(
        tester,
        appointment: appointment,
        appointmentsNotifier: notifier,
        onRescheduled: (_) {},
      );

      await selectTomorrowAndFirstSlot(tester);
      await confirmReschedule(tester);
      await tester.pumpAndSettle();

      expect(find.text('هذا الموعد محجوز، اختر وقتاً آخر'), findsOneWidget);
      expect(callMonitoringService.rescheduleOutcomes, contains('conflict'));
    });
  });
}
