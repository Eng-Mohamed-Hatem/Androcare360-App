import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/domain/repositories/patient_package_repository.dart';
import 'package:elajtech/features/packages/domain/usecases/get_patient_packages_for_admin_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_patient_packages_for_admin_usecase_test.mocks.dart';

@GenerateMocks([PatientPackageRepository, DocumentSnapshot])
void main() {
  late GetPatientPackagesForAdminUseCase usecase;
  late MockPatientPackageRepository mockRepository;

  setUp(() {
    mockRepository = MockPatientPackageRepository();
    usecase = GetPatientPackagesForAdminUseCase(mockRepository);
  });

  const tPatientId = 'patient_1';
  final tEntity = PatientPackageEntity(
    id: 'pp_1',
    patientId: tPatientId,
    packageId: 'pkg_1',
    clinicId: 'clinic_1',
    category: PackageCategory.andrologyInfertilityProstate,
    status: PatientPackageStatus.active,
    purchaseDate: DateTime.now(),
    expiryDate: DateTime.now().add(const Duration(days: 30)),
    totalServicesCount: 2,
    usedServicesCount: 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    notes: 'Internal admin note', // Notice notes IS present for admin R2
  );

  final tList = [tEntity];
  final tDocSnapshot = MockDocumentSnapshot();

  test(
    'should return paginated list from repository and check notes are included (R2)',
    () async {
      // arrange
      when(
        mockRepository.listPatientPackagesForAdmin(
          patientId: anyNamed('patientId'),
          lastDocument: anyNamed('lastDocument'),
          limit: anyNamed('limit'),
        ),
      ).thenAnswer(
        (_) async => Right<Failure, List<PatientPackageEntity>>(tList),
      );

      // act
      final result = await usecase(
        patientId: tPatientId,
        lastDocument: tDocSnapshot,
        limit: 15,
      );

      // assert
      expect(result, Right<Failure, List<PatientPackageEntity>>(tList));
      verify(
        mockRepository.listPatientPackagesForAdmin(
          patientId: tPatientId,
          lastDocument: tDocSnapshot,
          limit: 15,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);

      // Verify R2 requirement
      final returnedList = result.getOrElse(() => []);
      expect(
        returnedList.first.notes,
        'Internal admin note',
        reason: 'R2 requires notes to be included in admin-facing queries',
      );
    },
  );

  test('should return empty list when repository returns empty', () async {
    // arrange
    when(
      mockRepository.listPatientPackagesForAdmin(
        patientId: anyNamed('patientId'),
        lastDocument: anyNamed('lastDocument'),
        limit: anyNamed('limit'),
      ),
    ).thenAnswer(
      (_) async => const Right<Failure, List<PatientPackageEntity>>([]),
    );

    // act
    final result = await usecase(
      patientId: tPatientId,
    ); // default limit 20

    // assert
    expect(result, const Right<Failure, List<PatientPackageEntity>>([]));
    verify(
      mockRepository.listPatientPackagesForAdmin(
        patientId: tPatientId,
        lastDocument: null,
        limit: 20,
      ),
    ).called(1);
  });
}
