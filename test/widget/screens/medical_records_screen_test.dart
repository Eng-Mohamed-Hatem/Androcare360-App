import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/core/models/paginated_result.dart';
import 'package:elajtech/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/device_requests/domain/repositories/device_request_repository.dart';
import 'package:elajtech/features/lab_requests/domain/repositories/lab_request_repository.dart';
import 'package:elajtech/features/patient/medical_records/presentation/screens/medical_records_screen.dart';
import 'package:elajtech/features/prescriptions/domain/repositories/prescription_repository.dart';
import 'package:elajtech/features/radiology_requests/domain/repositories/radiology_request_repository.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:elajtech/shared/models/device_request_model.dart';
import 'package:elajtech/shared/models/lab_request_model.dart';
import 'package:elajtech/shared/models/prescription_model.dart';
import 'package:elajtech/shared/models/radiology_request_model.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../mocks/mock_auth_repository.dart';

void main() {
  group('MedicalRecordsScreen', () {
    late _FakeAppointmentRepository appointmentRepository;
    late _FakePrescriptionRepository prescriptionRepository;
    late _FakeLabRequestRepository labRequestRepository;
    late _FakeRadiologyRequestRepository radiologyRequestRepository;
    late _FakeDeviceRequestRepository deviceRequestRepository;
    late UserModel mockUser;

    setUp(() async {
      appointmentRepository = _FakeAppointmentRepository();
      prescriptionRepository = _FakePrescriptionRepository();
      labRequestRepository = _FakeLabRequestRepository();
      radiologyRequestRepository = _FakeRadiologyRequestRepository();
      deviceRequestRepository = _FakeDeviceRequestRepository();
      mockUser = UserModel(
        id: 'patient_123',
        fullName: 'Lazy Load Test',
        email: 'patient@test.com',
        phoneNumber: '+966500000000',
        userType: UserType.patient,
        createdAt: DateTime.now(),
      );

      await GetIt.instance.reset();
      GetIt.instance.registerSingleton<AppointmentRepository>(
        appointmentRepository,
      );
      GetIt.instance.registerSingleton<PrescriptionRepository>(
        prescriptionRepository,
      );
      GetIt.instance.registerSingleton<LabRequestRepository>(
        labRequestRepository,
      );
      GetIt.instance.registerSingleton<RadiologyRequestRepository>(
        radiologyRequestRepository,
      );
      GetIt.instance.registerSingleton<DeviceRequestRepository>(
        deviceRequestRepository,
      );
    });

    Widget createTestWidget({int initialIndex = 0}) {
      return ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) {
            return _MockAuthNotifier(mockUser: mockUser)..setUser(mockUser);
          }),
        ],
        child: MaterialApp(
          home: MedicalRecordsScreen(initialIndex: initialIndex),
        ),
      );
    }

    testWidgets('loads only the active tab initially', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(appointmentRepository.patientCalls, greaterThanOrEqualTo(1));
      expect(prescriptionRepository.patientCalls, 0);
      expect(labRequestRepository.patientCalls, 0);
      expect(radiologyRequestRepository.patientCalls, 0);
      expect(deviceRequestRepository.patientCalls, 0);
    });

    testWidgets('loads a deferred tab when the user opens it', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('الوصفات الطبية'));
      await tester.pumpAndSettle();

      expect(prescriptionRepository.patientCalls, 1);
      expect(appointmentRepository.patientCalls, greaterThanOrEqualTo(1));
    });

    testWidgets('respects the requested initial tab', (tester) async {
      await tester.pumpWidget(createTestWidget(initialIndex: 2));
      await tester.pumpAndSettle();

      expect(labRequestRepository.patientCalls, greaterThanOrEqualTo(1));
      expect(appointmentRepository.patientCalls, 0);
      expect(prescriptionRepository.patientCalls, 0);
    });

    testWidgets('shows an error state when loading fails', (tester) async {
      appointmentRepository.shouldFail = true;

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('تعذر تحميل المواعيد'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
    });
  });
}

class _MockAuthNotifier extends AuthNotifier {
  _MockAuthNotifier({UserModel? mockUser})
    : super(MockAuthRepository(currentUser: mockUser));

  void setUser(UserModel user) {
    state = state.copyWith(user: user, isLoading: false);
  }
}

class _FakeAppointmentRepository implements AppointmentRepository {
  int patientCalls = 0;
  bool shouldFail = false;

  @override
  Future<Either<Failure, List<AppointmentModel>>> getAppointmentsForPatient(
    String patientId,
  ) async {
    patientCalls++;
    if (shouldFail) {
      return const Left(ServerFailure('network error'));
    }
    return const Right([]);
  }

  @override
  Future<Either<Failure, PaginatedResult<AppointmentModel>>>
  getAppointmentsForPatientPage(
    String patientId, {
    int limit = 10,
  }) async {
    patientCalls++;
    if (shouldFail) {
      return const Left(ServerFailure('network error'));
    }
    return const Right(PaginatedResult(items: [], hasMore: false));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePrescriptionRepository implements PrescriptionRepository {
  int patientCalls = 0;

  @override
  Future<Either<Failure, List<PrescriptionModel>>> getPrescriptionsForPatient(
    String patientId,
  ) async {
    patientCalls++;
    return const Right([]);
  }

  @override
  Future<Either<Failure, PaginatedResult<PrescriptionModel>>>
  getPrescriptionsForPatientPage(
    String patientId, {
    int limit = 10,
  }) async {
    patientCalls++;
    return const Right(PaginatedResult(items: [], hasMore: false));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeLabRequestRepository implements LabRequestRepository {
  int patientCalls = 0;

  @override
  Future<Either<Failure, List<LabRequestModel>>> getLabRequestsForPatient(
    String patientId,
  ) async {
    patientCalls++;
    return const Right([]);
  }

  @override
  Future<Either<Failure, PaginatedResult<LabRequestModel>>>
  getLabRequestsForPatientPage(
    String patientId, {
    int limit = 10,
  }) async {
    patientCalls++;
    return const Right(PaginatedResult(items: [], hasMore: false));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRadiologyRequestRepository implements RadiologyRequestRepository {
  int patientCalls = 0;

  @override
  Future<Either<Failure, List<RadiologyRequestModel>>>
  getRadiologyRequestsForPatient(String patientId) async {
    patientCalls++;
    return const Right([]);
  }

  @override
  Future<Either<Failure, PaginatedResult<RadiologyRequestModel>>>
  getRadiologyRequestsForPatientPage(
    String patientId, {
    int limit = 10,
  }) async {
    patientCalls++;
    return const Right(PaginatedResult(items: [], hasMore: false));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDeviceRequestRepository implements DeviceRequestRepository {
  int patientCalls = 0;

  @override
  Future<Either<Failure, List<DeviceRequestModel>>> getDeviceRequestsForPatient(
    String patientId,
  ) async {
    patientCalls++;
    return const Right([]);
  }

  @override
  Future<Either<Failure, PaginatedResult<DeviceRequestModel>>>
  getDeviceRequestsForPatientPage(
    String patientId, {
    int limit = 10,
  }) async {
    patientCalls++;
    return const Right(PaginatedResult(items: [], hasMore: false));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
