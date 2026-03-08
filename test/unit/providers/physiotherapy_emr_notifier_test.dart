/// Unit tests for PhysiotherapyEMRNotifier
///
/// Tests cover:
/// - EMR initialization
/// - EMR loading by appointment
/// - Checkbox selection updates
/// - Text field updates
/// - Save operations
/// - View mode management
/// - Error handling
///
/// Target: 85%+ coverage

library;

import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/doctor/medical_records/data/repositories/physiotherapy_emr_repository.dart';
import 'package:elajtech/features/doctor/medical_records/presentation/providers/physiotherapy_emr_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../fixtures/physiotherapy_emr_fixtures.dart';
import 'physiotherapy_emr_notifier_test.mocks.dart';

@GenerateMocks([
  PhysiotherapyEMRRepository,
])
void main() {
  late ProviderContainer container;
  late MockPhysiotherapyEMRRepository mockRepository;

  setUp(() {
    mockRepository = MockPhysiotherapyEMRRepository();

    container = ProviderContainer(
      overrides: [
        physiotherapyEMRRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('PhysiotherapyEMRNotifier - State Initialization', () {
    test('should initialize with empty state', () {
      // Arrange & Act
      final state = container.read(physiotherapyEMRNotifierProvider);

      // Assert
      expect(state.emr, isNull);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.isSaved, false);
      expect(state.isViewMode, false);
    });
  });

  group('PhysiotherapyEMRNotifier - Initialize EMR', () {
    test('should initialize new EMR with empty data', () {
      // Arrange
      const id = 'emr_test_001';
      const patientId = 'patient_test_001';
      const doctorId = 'doctor_test_001';
      const doctorName = 'Dr. Ahmed Ali';
      const appointmentId = 'apt_test_001';
      final visitDate = DateTime.now();

      // Act
      container
          .read(physiotherapyEMRNotifierProvider.notifier)
          .initializeEMR(
            id: id,
            patientId: patientId,
            doctorId: doctorId,
            doctorName: doctorName,
            appointmentId: appointmentId,
            visitDate: visitDate,
          );

      // Assert
      final state = container.read(physiotherapyEMRNotifierProvider);
      expect(state.emr, isNotNull);
      expect(state.emr!.id, id);
      expect(state.emr!.patientId, patientId);
      expect(state.emr!.doctorId, doctorId);
      expect(state.emr!.appointmentId, appointmentId);
      expect(state.emr!.basics, isEmpty);
      expect(state.emr!.painAssessment, isEmpty);
      expect(state.emr!.functionalAssessment, isEmpty);
    });
  });

  group('PhysiotherapyEMRNotifier - Load EMR', () {
    test('should load existing EMR successfully', () async {
      // Arrange
      const appointmentId = 'apt_test_001';
      final emr = PhysiotherapyEMRFixtures.createCompleteEMR();

      when(
        mockRepository.getPhysiotherapyEMRByVisit(appointmentId),
      ).thenAnswer((_) async => Right(emr));

      // Act
      await container
          .read(physiotherapyEMRNotifierProvider.notifier)
          .loadEMRByAppointment(appointmentId);

      // Assert
      final state = container.read(physiotherapyEMRNotifierProvider);
      expect(state.isLoading, false);
      expect(state.emr, equals(emr));
      expect(state.error, isNull);

      verify(
        mockRepository.getPhysiotherapyEMRByVisit(appointmentId),
      ).called(1);
    });

    test('should handle EMR not found', () async {
      // Arrange
      const appointmentId = 'apt_test_001';

      when(
        mockRepository.getPhysiotherapyEMRByVisit(appointmentId),
      ).thenAnswer((_) async => const Right(null));

      // Act
      await container
          .read(physiotherapyEMRNotifierProvider.notifier)
          .loadEMRByAppointment(appointmentId);

      // Assert
      final state = container.read(physiotherapyEMRNotifierProvider);
      expect(state.isLoading, false);
      expect(state.emr, isNull);
      expect(state.error, isNull);
    });

    test('should handle load failure', () async {
      // Arrange
      const appointmentId = 'apt_test_001';
      const errorMessage = 'EMR not found';

      when(
        mockRepository.getPhysiotherapyEMRByVisit(appointmentId),
      ).thenAnswer((_) async => const Left(ServerFailure(errorMessage)));

      // Act
      await container
          .read(physiotherapyEMRNotifierProvider.notifier)
          .loadEMRByAppointment(appointmentId);

      // Assert
      final state = container.read(physiotherapyEMRNotifierProvider);
      expect(state.isLoading, false);
      expect(state.error, errorMessage);
    });
  });

  group('PhysiotherapyEMRNotifier - Checkbox Updates', () {
    test('should add checkbox selection', () {
      // Arrange
      final emr = PhysiotherapyEMRFixtures.createEmptyEMR();
      container.read(physiotherapyEMRNotifierProvider.notifier).state =
          PhysiotherapyEMRState(emr: emr);

      // Act
      container
          .read(physiotherapyEMRNotifierProvider.notifier)
          .updateCheckboxSelection(
            section: 'basics',
            key: 'identityVerified',
            value: 'yes',
            isSelected: true,
          );

      // Assert
      final state = container.read(physiotherapyEMRNotifierProvider);
      expect(state.emr!.basics['identityVerified'], contains('yes'));
    });

    test('should remove checkbox selection', () {
      // Arrange
      final emr = PhysiotherapyEMRFixtures.createEMRWithBasics();
      container.read(physiotherapyEMRNotifierProvider.notifier).state =
          PhysiotherapyEMRState(emr: emr);

      // Act
      container
          .read(physiotherapyEMRNotifierProvider.notifier)
          .updateCheckboxSelection(
            section: 'basics',
            key: 'identityVerified',
            value: 'yes',
            isSelected: false,
          );

      // Assert
      final state = container.read(physiotherapyEMRNotifierProvider);
      expect(state.emr!.basics['identityVerified'], isNot(contains('yes')));
    });

    test('should update painAssessment section', () {
      // Arrange
      final emr = PhysiotherapyEMRFixtures.createEmptyEMR();
      container.read(physiotherapyEMRNotifierProvider.notifier).state =
          PhysiotherapyEMRState(emr: emr);

      // Act
      container
          .read(physiotherapyEMRNotifierProvider.notifier)
          .updateCheckboxSelection(
            section: 'painAssessment',
            key: 'painLocation',
            value: 'lower_back',
            isSelected: true,
          );

      // Assert
      final state = container.read(physiotherapyEMRNotifierProvider);
      expect(
        state.emr!.painAssessment['painLocation'],
        contains('lower_back'),
      );
    });

    test('should update functionalAssessment section', () {
      // Arrange
      final emr = PhysiotherapyEMRFixtures.createEmptyEMR();
      container.read(physiotherapyEMRNotifierProvider.notifier).state =
          PhysiotherapyEMRState(emr: emr);

      // Act
      container
          .read(physiotherapyEMRNotifierProvider.notifier)
          .updateCheckboxSelection(
            section: 'functionalAssessment',
            key: 'mobility',
            value: 'independent',
            isSelected: true,
          );

      // Assert
      final state = container.read(physiotherapyEMRNotifierProvider);
      expect(
        state.emr!.functionalAssessment['mobility'],
        contains('independent'),
      );
    });

    test('should not update when EMR is null', () {
      // Arrange - No EMR initialized

      // Act
      container
          .read(physiotherapyEMRNotifierProvider.notifier)
          .updateCheckboxSelection(
            section: 'basics',
            key: 'identityVerified',
            value: 'yes',
            isSelected: true,
          );

      // Assert
      final state = container.read(physiotherapyEMRNotifierProvider);
      expect(state.emr, isNull);
    });
  });

  group('PhysiotherapyEMRNotifier - Text Field Updates', () {
    test('should update primaryDiagnosis field', () {
      // Arrange
      final emr = PhysiotherapyEMRFixtures.createEmptyEMR();
      container.read(physiotherapyEMRNotifierProvider.notifier).state =
          PhysiotherapyEMRState(emr: emr);

      const diagnosis = 'Lower back pain with muscle spasm';

      // Act
      container
          .read(physiotherapyEMRNotifierProvider.notifier)
          .updateTextField(
            field: 'primaryDiagnosis',
            value: diagnosis,
          );

      // Assert
      final state = container.read(physiotherapyEMRNotifierProvider);
      expect(state.emr!.primaryDiagnosis, diagnosis);
    });

    test('should update managementPlan field', () {
      // Arrange
      final emr = PhysiotherapyEMRFixtures.createEmptyEMR();
      container.read(physiotherapyEMRNotifierProvider.notifier).state =
          PhysiotherapyEMRState(emr: emr);

      const plan = 'Physical therapy 3x per week for 4 weeks';

      // Act
      container
          .read(physiotherapyEMRNotifierProvider.notifier)
          .updateTextField(
            field: 'managementPlan',
            value: plan,
          );

      // Assert
      final state = container.read(physiotherapyEMRNotifierProvider);
      expect(state.emr!.managementPlan, plan);
    });

    test('should not update when EMR is null', () {
      // Arrange - No EMR initialized

      // Act
      container
          .read(physiotherapyEMRNotifierProvider.notifier)
          .updateTextField(
            field: 'primaryDiagnosis',
            value: 'Test diagnosis',
          );

      // Assert
      final state = container.read(physiotherapyEMRNotifierProvider);
      expect(state.emr, isNull);
    });
  });

  group('PhysiotherapyEMRNotifier - Save Operations', () {
    test('should save EMR successfully', () async {
      // Arrange
      final emr = PhysiotherapyEMRFixtures.createCompleteEMR();
      container.read(physiotherapyEMRNotifierProvider.notifier).state =
          PhysiotherapyEMRState(emr: emr);

      when(
        mockRepository.createPhysiotherapyEMR(any),
      ).thenAnswer((_) async => const Right(null));

      // Act
      await container.read(physiotherapyEMRNotifierProvider.notifier).saveEMR();

      // Assert
      final state = container.read(physiotherapyEMRNotifierProvider);
      expect(state.isLoading, false);
      expect(state.isSaved, true);
      expect(state.isViewMode, true);
      expect(state.error, isNull);

      verify(mockRepository.createPhysiotherapyEMR(any)).called(1);
    });

    test('should handle save failure', () async {
      // Arrange
      final emr = PhysiotherapyEMRFixtures.createCompleteEMR();
      container.read(physiotherapyEMRNotifierProvider.notifier).state =
          PhysiotherapyEMRState(emr: emr);

      const errorMessage = 'Save failed';
      when(
        mockRepository.createPhysiotherapyEMR(any),
      ).thenAnswer((_) async => const Left(ServerFailure(errorMessage)));

      // Act
      await container.read(physiotherapyEMRNotifierProvider.notifier).saveEMR();

      // Assert
      final state = container.read(physiotherapyEMRNotifierProvider);
      expect(state.isLoading, false);
      expect(state.isSaved, false);
      expect(state.error, errorMessage);
    });

    test('should not save when EMR is null', () async {
      // Arrange - No EMR initialized

      // Act
      await container.read(physiotherapyEMRNotifierProvider.notifier).saveEMR();

      // Assert
      final state = container.read(physiotherapyEMRNotifierProvider);
      expect(state.error, 'No EMR data to save');
      verifyNever(mockRepository.createPhysiotherapyEMR(any));
    });
  });

  group('PhysiotherapyEMRNotifier - View Mode Management', () {
    test('should set view mode to true', () {
      // Arrange
      final emr = PhysiotherapyEMRFixtures.createCompleteEMR();
      container.read(physiotherapyEMRNotifierProvider.notifier).state =
          PhysiotherapyEMRState(emr: emr);

      // Act
      container
          .read(physiotherapyEMRNotifierProvider.notifier)
          .setViewMode(true);

      // Assert
      final state = container.read(physiotherapyEMRNotifierProvider);
      expect(state.isViewMode, true);
    });

    test('should set view mode to false', () {
      // Arrange
      final emr = PhysiotherapyEMRFixtures.createCompleteEMR();
      container.read(physiotherapyEMRNotifierProvider.notifier).state =
          PhysiotherapyEMRState(emr: emr, isViewMode: true);

      // Act
      container
          .read(physiotherapyEMRNotifierProvider.notifier)
          .setViewMode(false);

      // Assert
      final state = container.read(physiotherapyEMRNotifierProvider);
      expect(state.isViewMode, false);
    });
  });

  group('PhysiotherapyEMRNotifier - State Reset', () {
    test('should reset state to initial values', () {
      // Arrange
      final emr = PhysiotherapyEMRFixtures.createCompleteEMR();
      container
          .read(physiotherapyEMRNotifierProvider.notifier)
          .state = PhysiotherapyEMRState(
        emr: emr,
        isSaved: true,
        isViewMode: true,
      );

      // Act
      container.read(physiotherapyEMRNotifierProvider.notifier).reset();

      // Assert
      final state = container.read(physiotherapyEMRNotifierProvider);
      expect(state.emr, isNull);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.isSaved, false);
      expect(state.isViewMode, false);
    });
  });
}
