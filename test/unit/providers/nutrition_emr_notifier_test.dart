/// Unit tests for NutritionEMRNotifier
///
/// Tests cover:
/// - EMR loading and initialization
/// - Field updates with optimistic updates
/// - Save operations (auto-save and manual)
/// - Lock management
/// - Audit trail
/// - Completion tracking
/// - Error handling
///
/// Target: 85%+ coverage

library;

import 'package:dartz/dartz.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/nutrition/domain/repositories/nutrition_emr_repository.dart';
import 'package:elajtech/features/nutrition/presentation/state/nutrition_state_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../fixtures/nutrition_emr_fixtures.dart';
import 'nutrition_emr_notifier_test.mocks.dart';

@GenerateMocks([
  NutritionEMRRepository,
])
void main() {
  late ProviderContainer container;
  late MockNutritionEMRRepository mockRepository;

  setUp(() {
    mockRepository = MockNutritionEMRRepository();

    container = ProviderContainer(
      overrides: [
        nutritionEMRRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('NutritionEMRNotifier - State Initialization', () {
    test('should initialize with loading state', () {
      // Arrange & Act
      final state = container.read(nutritionEMRNotifierProvider);

      // Assert
      expect(state.isLoading, true);
      expect(state.isLoaded, false);
      expect(state.hasError, false);
      expect(state.emrOrNull, isNull);
    });
  });

  group('NutritionEMRNotifier - Load EMR', () {
    test('should load existing EMR successfully', () async {
      // Arrange
      const appointmentId = 'apt_test_001';
      const patientId = 'patient_test_001';
      const nutritionistId = 'doctor_test_001';
      const nutritionistName = 'Dr. Ahmed Ali';
      final emr = NutritionEMRFixtures.createCompleteEMR();

      when(
        mockRepository.getEMRByAppointmentId(appointmentId),
      ).thenAnswer((_) async => Right(emr));

      // Act
      await container
          .read(nutritionEMRNotifierProvider.notifier)
          .loadPatientNutritionData(
            appointmentId: appointmentId,
            patientId: patientId,
            nutritionistId: nutritionistId,
            nutritionistName: nutritionistName,
          );

      // Assert
      final state = container.read(nutritionEMRNotifierProvider);
      expect(state.isLoaded, true);
      expect(state.emrOrNull, equals(emr));
      expect(state.hasUnsavedChanges, false);
      expect(state.isLocked, emr.isCurrentlyLocked);

      verify(mockRepository.getEMRByAppointmentId(appointmentId)).called(1);
    });

    test('should create new EMR when none exists', () async {
      // Arrange
      const appointmentId = 'apt_test_001';
      const patientId = 'patient_test_001';
      const nutritionistId = 'doctor_test_001';
      const nutritionistName = 'Dr. Ahmed Ali';

      when(
        mockRepository.getEMRByAppointmentId(appointmentId),
      ).thenAnswer((_) async => const Right(null));

      // Act
      await container
          .read(nutritionEMRNotifierProvider.notifier)
          .loadPatientNutritionData(
            appointmentId: appointmentId,
            patientId: patientId,
            nutritionistId: nutritionistId,
            nutritionistName: nutritionistName,
          );

      // Assert
      final state = container.read(nutritionEMRNotifierProvider);
      expect(state.isLoaded, true);
      expect(state.emrOrNull, isNotNull);
      expect(state.emrOrNull!.appointmentId, appointmentId);
      expect(state.emrOrNull!.patientId, patientId);
      expect(state.emrOrNull!.nutritionistId, nutritionistId);
      expect(state.hasUnsavedChanges, false);
    });

    test('should handle load failure', () async {
      // Arrange
      const appointmentId = 'apt_test_001';
      const patientId = 'patient_test_001';
      const nutritionistId = 'doctor_test_001';
      const nutritionistName = 'Dr. Ahmed Ali';
      const errorMessage = 'EMR not found';

      when(
        mockRepository.getEMRByAppointmentId(appointmentId),
      ).thenAnswer((_) async => const Left(Failure.firestore(errorMessage)));

      // Act
      await container
          .read(nutritionEMRNotifierProvider.notifier)
          .loadPatientNutritionData(
            appointmentId: appointmentId,
            patientId: patientId,
            nutritionistId: nutritionistId,
            nutritionistName: nutritionistName,
          );

      // Assert
      final state = container.read(nutritionEMRNotifierProvider);
      expect(state.hasError, true);
      expect(state.emrOrNull, isNull);
    });
  });

  group('NutritionEMRNotifier - Field Updates', () {
    test('should update field and mark as dirty', () async {
      // Arrange
      const appointmentId = 'apt_test_001';
      const patientId = 'patient_test_001';
      const nutritionistId = 'doctor_test_001';
      const nutritionistName = 'Dr. Ahmed Ali';
      final emr = NutritionEMRFixtures.createCompleteEMR();

      when(
        mockRepository.getEMRByAppointmentId(appointmentId),
      ).thenAnswer((_) async => Right(emr));

      await container
          .read(nutritionEMRNotifierProvider.notifier)
          .loadPatientNutritionData(
            appointmentId: appointmentId,
            patientId: patientId,
            nutritionistId: nutritionistId,
            nutritionistName: nutritionistName,
          );

      // Act
      container
          .read(nutritionEMRNotifierProvider.notifier)
          .updateField(
            fieldName: 'isWeightMeasured',
            value: true,
            userId: nutritionistId,
            userName: nutritionistName,
          );

      // Assert
      final state = container.read(nutritionEMRNotifierProvider);
      expect(state.hasUnsavedChanges, true);
      expect(state.unsavedChangesCount, 1);
      expect(state.emrOrNull!.isWeightMeasured, true);
    });

    test('should add audit trail entry on field update', () async {
      // Arrange
      const appointmentId = 'apt_test_001';
      const patientId = 'patient_test_001';
      const nutritionistId = 'doctor_test_001';
      const nutritionistName = 'Dr. Ahmed Ali';
      final emr = NutritionEMRFixtures.createCompleteEMR();

      when(
        mockRepository.getEMRByAppointmentId(appointmentId),
      ).thenAnswer((_) async => Right(emr));

      await container
          .read(nutritionEMRNotifierProvider.notifier)
          .loadPatientNutritionData(
            appointmentId: appointmentId,
            patientId: patientId,
            nutritionistId: nutritionistId,
            nutritionistName: nutritionistName,
          );

      final initialAuditCount = emr.auditLog.length;

      // Act
      container
          .read(nutritionEMRNotifierProvider.notifier)
          .updateField(
            fieldName: 'isHeightMeasured',
            value: true,
            userId: nutritionistId,
            userName: nutritionistName,
          );

      // Assert
      final state = container.read(nutritionEMRNotifierProvider);
      expect(state.emrOrNull!.auditLog.length, initialAuditCount + 1);
      expect(state.emrOrNull!.auditLog.last.fieldChanged, 'isHeightMeasured');
      expect(state.emrOrNull!.auditLog.last.userId, nutritionistId);
      expect(state.emrOrNull!.auditLog.last.userName, nutritionistName);
    });

    test('should not update when EMR is locked', () async {
      // Arrange
      const appointmentId = 'apt_test_001';
      const patientId = 'patient_test_001';
      const nutritionistId = 'doctor_test_001';
      const nutritionistName = 'Dr. Ahmed Ali';
      final emr = NutritionEMRFixtures.createLockedEMR();

      when(
        mockRepository.getEMRByAppointmentId(appointmentId),
      ).thenAnswer((_) async => Right(emr));

      await container
          .read(nutritionEMRNotifierProvider.notifier)
          .loadPatientNutritionData(
            appointmentId: appointmentId,
            patientId: patientId,
            nutritionistId: nutritionistId,
            nutritionistName: nutritionistName,
          );

      final originalValue = emr.isWeightMeasured;

      // Act
      container
          .read(nutritionEMRNotifierProvider.notifier)
          .updateField(
            fieldName: 'isWeightMeasured',
            value: !originalValue,
            userId: nutritionistId,
            userName: nutritionistName,
          );

      // Assert
      final state = container.read(nutritionEMRNotifierProvider);
      expect(state.emrOrNull!.isWeightMeasured, originalValue);
      expect(state.hasUnsavedChanges, false);
    });
  });

  group('NutritionEMRNotifier - Save Operations', () {
    test('should save EMR successfully', () async {
      // Arrange
      const appointmentId = 'apt_test_001';
      const patientId = 'patient_test_001';
      const nutritionistId = 'doctor_test_001';
      const nutritionistName = 'Dr. Ahmed Ali';
      final emr = NutritionEMRFixtures.createCompleteEMR();

      when(
        mockRepository.getEMRByAppointmentId(appointmentId),
      ).thenAnswer((_) async => Right(emr));
      when(
        mockRepository.saveEMR(any),
      ).thenAnswer((_) async => const Right(null));

      await container
          .read(nutritionEMRNotifierProvider.notifier)
          .loadPatientNutritionData(
            appointmentId: appointmentId,
            patientId: patientId,
            nutritionistId: nutritionistId,
            nutritionistName: nutritionistName,
          );

      // Make a change
      container
          .read(nutritionEMRNotifierProvider.notifier)
          .updateField(
            fieldName: 'isWeightMeasured',
            value: true,
            userId: nutritionistId,
            userName: nutritionistName,
          );

      // Act
      final success = await container
          .read(nutritionEMRNotifierProvider.notifier)
          .saveManually();

      // Assert
      expect(success, true);
      final state = container.read(nutritionEMRNotifierProvider);
      expect(state.hasUnsavedChanges, false);
      expect(state.unsavedChangesCount, 0);

      verify(mockRepository.saveEMR(any)).called(1);
    });

    test('should handle save failure', () async {
      // Arrange
      const appointmentId = 'apt_test_001';
      const patientId = 'patient_test_001';
      const nutritionistId = 'doctor_test_001';
      const nutritionistName = 'Dr. Ahmed Ali';
      final emr = NutritionEMRFixtures.createCompleteEMR();
      const errorMessage = 'Save failed';

      when(
        mockRepository.getEMRByAppointmentId(appointmentId),
      ).thenAnswer((_) async => Right(emr));
      when(
        mockRepository.saveEMR(any),
      ).thenAnswer((_) async => const Left(Failure.firestore(errorMessage)));

      await container
          .read(nutritionEMRNotifierProvider.notifier)
          .loadPatientNutritionData(
            appointmentId: appointmentId,
            patientId: patientId,
            nutritionistId: nutritionistId,
            nutritionistName: nutritionistName,
          );

      container
          .read(nutritionEMRNotifierProvider.notifier)
          .updateField(
            fieldName: 'isWeightMeasured',
            value: true,
            userId: nutritionistId,
            userName: nutritionistName,
          );

      // Act
      final success = await container
          .read(nutritionEMRNotifierProvider.notifier)
          .saveManually();

      // Assert
      expect(success, false);
      final state = container.read(nutritionEMRNotifierProvider);
      expect(state.hasUnsavedChanges, true);
    });
  });

  group('NutritionEMRNotifier - Lock Management', () {
    test('should lock EMR successfully', () async {
      // Arrange
      const appointmentId = 'apt_test_001';
      const patientId = 'patient_test_001';
      const nutritionistId = 'doctor_test_001';
      const nutritionistName = 'Dr. Ahmed Ali';
      final emr = NutritionEMRFixtures.createCompleteEMR();

      when(
        mockRepository.getEMRByAppointmentId(appointmentId),
      ).thenAnswer((_) async => Right(emr));
      when(
        mockRepository.lockEMR(any),
      ).thenAnswer((_) async => const Right(null));

      await container
          .read(nutritionEMRNotifierProvider.notifier)
          .loadPatientNutritionData(
            appointmentId: appointmentId,
            patientId: patientId,
            nutritionistId: nutritionistId,
            nutritionistName: nutritionistName,
          );

      // Act
      final success = await container
          .read(nutritionEMRNotifierProvider.notifier)
          .lock();

      // Assert
      expect(success, true);
      final state = container.read(nutritionEMRNotifierProvider);
      expect(state.isLocked, true);

      verify(mockRepository.lockEMR(any)).called(1);
    });

    test('should not allow updates when locked', () async {
      // Arrange
      const appointmentId = 'apt_test_001';
      const patientId = 'patient_test_001';
      const nutritionistId = 'doctor_test_001';
      const nutritionistName = 'Dr. Ahmed Ali';
      final emr = NutritionEMRFixtures.createLockedEMR();

      when(
        mockRepository.getEMRByAppointmentId(appointmentId),
      ).thenAnswer((_) async => Right(emr));

      await container
          .read(nutritionEMRNotifierProvider.notifier)
          .loadPatientNutritionData(
            appointmentId: appointmentId,
            patientId: patientId,
            nutritionistId: nutritionistId,
            nutritionistName: nutritionistName,
          );

      final originalValue = emr.isWeightMeasured;

      // Act
      container
          .read(nutritionEMRNotifierProvider.notifier)
          .updateField(
            fieldName: 'isWeightMeasured',
            value: !originalValue,
            userId: nutritionistId,
            userName: nutritionistName,
          );

      // Assert
      final state = container.read(nutritionEMRNotifierProvider);
      expect(state.emrOrNull!.isWeightMeasured, originalValue);
      expect(state.hasUnsavedChanges, false);
    });
  });

  group('NutritionEMRNotifier - Completion Tracking', () {
    test('should calculate completion percentage', () async {
      // Arrange
      const appointmentId = 'apt_test_001';
      const patientId = 'patient_test_001';
      const nutritionistId = 'doctor_test_001';
      const nutritionistName = 'Dr. Ahmed Ali';
      final emr = NutritionEMRFixtures.createPartialEMR();

      when(
        mockRepository.getEMRByAppointmentId(appointmentId),
      ).thenAnswer((_) async => Right(emr));

      await container
          .read(nutritionEMRNotifierProvider.notifier)
          .loadPatientNutritionData(
            appointmentId: appointmentId,
            patientId: patientId,
            nutritionistId: nutritionistId,
            nutritionistName: nutritionistName,
          );

      // Act
      final completion = container
          .read(nutritionEMRNotifierProvider.notifier)
          .calculateCompletionPercentage();

      // Assert
      expect(completion, greaterThanOrEqualTo(0));
      expect(completion, lessThanOrEqualTo(100));
    });
  });

  group('NutritionEMRNotifier - Computed Providers', () {
    test('currentNutritionEMRProvider should return EMR when loaded', () async {
      // Arrange
      const appointmentId = 'apt_test_001';
      const patientId = 'patient_test_001';
      const nutritionistId = 'doctor_test_001';
      const nutritionistName = 'Dr. Ahmed Ali';
      final emr = NutritionEMRFixtures.createCompleteEMR();

      when(
        mockRepository.getEMRByAppointmentId(appointmentId),
      ).thenAnswer((_) async => Right(emr));

      await container
          .read(nutritionEMRNotifierProvider.notifier)
          .loadPatientNutritionData(
            appointmentId: appointmentId,
            patientId: patientId,
            nutritionistId: nutritionistId,
            nutritionistName: nutritionistName,
          );

      // Act
      final currentEmr = container.read(currentNutritionEMRProvider);

      // Assert
      expect(currentEmr, equals(emr));
    });

    test('isNutritionEMRLoadingProvider should return loading state', () {
      // Arrange & Act
      final isLoading = container.read(isNutritionEMRLoadingProvider);

      // Assert
      expect(isLoading, true);
    });

    test(
      'hasUnsavedNutritionChangesProvider should track dirty fields',
      () async {
        // Arrange
        const appointmentId = 'apt_test_001';
        const patientId = 'patient_test_001';
        const nutritionistId = 'doctor_test_001';
        const nutritionistName = 'Dr. Ahmed Ali';
        final emr = NutritionEMRFixtures.createCompleteEMR();

        when(
          mockRepository.getEMRByAppointmentId(appointmentId),
        ).thenAnswer((_) async => Right(emr));

        await container
            .read(nutritionEMRNotifierProvider.notifier)
            .loadPatientNutritionData(
              appointmentId: appointmentId,
              patientId: patientId,
              nutritionistId: nutritionistId,
              nutritionistName: nutritionistName,
            );

        // Act - Make a change
        container
            .read(nutritionEMRNotifierProvider.notifier)
            .updateField(
              fieldName: 'isWeightMeasured',
              value: true,
              userId: nutritionistId,
              userName: nutritionistName,
            );

        final hasUnsaved = container.read(hasUnsavedNutritionChangesProvider);

        // Assert
        expect(hasUnsaved, true);
      },
    );
  });
}
