import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/patient/home/data/models/medical_screening_model.dart';
import 'package:elajtech/features/patient/home/domain/repositories/medical_screening_repository.dart';
import 'package:elajtech/features/patient/home/presentation/providers/medical_screening_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'medical_screening_provider_test.mocks.dart';

@GenerateMocks([MedicalScreeningRepository])
void main() {
  late MedicalScreeningNotifier notifier;
  late MockMedicalScreeningRepository mockRepository;

  setUp(() {
    mockRepository = MockMedicalScreeningRepository();
    notifier = MedicalScreeningNotifier(mockRepository);
  });

  const tPatientId = 'patient123';
  const tMedicalScreeningModel = MedicalScreeningModel(
    diabetes: true,
  );

  group('loadData', () {
    test('should set model and isEditMode to false when data exists', () async {
      // arrange
      when(
        mockRepository.getMedicalScreening(tPatientId),
      ).thenAnswer((_) async => const Right(tMedicalScreeningModel));

      // act
      await notifier.loadData(tPatientId);

      // assert
      expect(notifier.state.isLoading, false);
      expect(notifier.state.model, tMedicalScreeningModel);
      expect(notifier.state.isEditMode, false);
      expect(notifier.state.error, null);
    });

    test(
      'should set empty model and isEditMode to true when data is null',
      () async {
        // arrange
        when(
          mockRepository.getMedicalScreening(tPatientId),
        ).thenAnswer((_) async => const Right(null));

        // act
        await notifier.loadData(tPatientId);

        // assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.model, const MedicalScreeningModel());
        expect(notifier.state.isEditMode, true);
        expect(notifier.state.error, null);
      },
    );

    test('should set error when repository returns Failure', () async {
      // arrange
      const tFailure = ServerFailure('Server Error');
      when(
        mockRepository.getMedicalScreening(tPatientId),
      ).thenAnswer((_) async => const Left(tFailure));

      // act
      await notifier.loadData(tPatientId);

      // assert
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, tFailure);
    });
  });

  group('saveData', () {
    test(
      'should set isEditMode to false and isSuccess to true when save is successful',
      () async {
        // arrange
        when(
          mockRepository.saveMedicalScreening(
            tPatientId,
            tMedicalScreeningModel,
          ),
        ).thenAnswer((_) async => const Right(unit));

        // act
        await notifier.saveData(tPatientId, tMedicalScreeningModel);

        // assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.model, tMedicalScreeningModel);
        expect(notifier.state.isEditMode, false);
        expect(notifier.state.isSuccess, true);
        expect(notifier.state.error, null);
      },
    );

    test('should set error when save fails', () async {
      // arrange
      const tFailure = ServerFailure('Save Error');
      when(
        mockRepository.saveMedicalScreening(tPatientId, tMedicalScreeningModel),
      ).thenAnswer((_) async => const Left(tFailure));

      // act
      await notifier.saveData(tPatientId, tMedicalScreeningModel);

      // assert
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, tFailure);
      expect(notifier.state.isSuccess, false);
    });
  });

  group('toggleEditMode', () {
    test('should toggle isEditMode and reset isSuccess and error', () {
      // arrange
      // initial state has isEditMode = true

      // act
      notifier.toggleEditMode();

      // assert
      expect(notifier.state.isEditMode, false);
      expect(notifier.state.isSuccess, false);
      expect(notifier.state.error, null);

      // act again
      notifier.toggleEditMode();

      // assert
      expect(notifier.state.isEditMode, true);
    });
  });
}
