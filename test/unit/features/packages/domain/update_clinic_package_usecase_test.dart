import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/package_service_item.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart';
import 'package:elajtech/features/packages/domain/repositories/package_repository.dart';
import 'package:elajtech/features/packages/domain/usecases/update_clinic_package_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'update_clinic_package_usecase_test.mocks.dart';

@GenerateMocks([PackageRepository])
void main() {
  late UpdateClinicPackageUseCase usecase;
  late MockPackageRepository mockRepository;

  setUp(() {
    mockRepository = MockPackageRepository();
    usecase = UpdateClinicPackageUseCase();
  });

  const tClinicId = 'andrology';
  const tPackageId = 'pkg-123';
  final tLoadedAt = DateTime(2025);
  final tParams = UpdatePackageParams(
    clinicId: tClinicId,
    packageId: tPackageId,
    loadedAt: tLoadedAt,
    category: PackageCategory.andrologyInfertilityProstate,
    name: 'باقة رجالية معدلة',
    shortDescription: 'وصف قصير',
    services: [
      const PackageServiceItem(
        serviceId: '1',
        serviceType: ServiceType.lab,
        displayName: 'فحص دم',
      ),
    ],
    validityDays: 30,
    price: 100,
    currency: 'EGP',
    type: PackageType.both,
    status: PackageStatus.active,
    displayOrder: 1,
    isFeatured: true,
  );

  final tCurrentEntity = PackageEntity.fromType(
    id: tPackageId,
    clinicId: tClinicId,
    category: PackageCategory.andrologyInfertilityProstate,
    name: 'باقة رجالية',
    shortDescription: 'وصف',
    services: const [
      PackageServiceItem(
        serviceId: '1',
        serviceType: ServiceType.lab,
        displayName: 'فحص دم',
      ),
    ],
    validityDays: 30,
    price: 100,
    currency: 'EGP',
    type: PackageType.both,
    status: PackageStatus.active,
    displayOrder: 1,
    isFeatured: true,
    createdAt: DateTime(2024),
    updatedAt: tLoadedAt, // matches
  );

  test(
    'should return unit when update is valid and updatedAt matches',
    () async {
      // arrange
      when(
        mockRepository.getPackageById(
          clinicId: tClinicId,
          packageId: tPackageId,
        ),
      ).thenAnswer((_) async => Right<Failure, PackageEntity>(tCurrentEntity));
      when(
        mockRepository.updatePackage(any),
      ).thenAnswer((_) async => const Right<Failure, Unit>(unit));

      // act
      final result = await usecase(repository: mockRepository, params: tParams);

      // assert
      expect(result, const Right<Failure, Unit>(unit));
      final captured = verify(
        mockRepository.updatePackage(captureAny),
      ).captured;
      final updatedEntity = captured.first as PackageEntity;
      expect(updatedEntity.name, 'باقة رجالية معدلة');
      expect(updatedEntity.includesVideoConsultation, isTrue); // recomputed
      expect(
        updatedEntity.updatedAt.isAfter(tLoadedAt),
        isTrue,
      ); // updated > old
    },
  );

  test(
    'should return StaleDataFailure when loadedAt is null (immediate guard)',
    () async {
      // arrange
      const invalidParams = UpdatePackageParams(
        clinicId: tClinicId,
        packageId: tPackageId,
        loadedAt: null, // NULL
        category: PackageCategory.andrologyInfertilityProstate,
        name: 'باقة رجالية معدلة',
        shortDescription: 'وصف قصير',
        services: [],
        validityDays: 30,
        price: 100,
        currency: 'EGP',
        type: PackageType.both,
        status: PackageStatus.active,
        displayOrder: 1,
        isFeatured: true,
      );

      // act
      final result = await usecase(
        repository: mockRepository,
        params: invalidParams,
      );

      // assert
      expect(result, const Left<Failure, Unit>(StaleDataFailure()));
      verifyNever(
        mockRepository.getPackageById(
          clinicId: anyNamed('clinicId'),
          packageId: anyNamed('packageId'),
        ),
      );
    },
  );

  test(
    'should return StaleDataFailure when loadedAt does not match Firestore updatedAt',
    () async {
      // arrange
      final tMismatchEntity = PackageEntity.fromType(
        id: tPackageId,
        clinicId: tClinicId,
        category: PackageCategory.andrologyInfertilityProstate,
        name: 'باقة رجالية',
        shortDescription: 'وصف',
        services: const [],
        validityDays: 30,
        price: 100,
        currency: 'EGP',
        type: PackageType.both,
        status: PackageStatus.active,
        displayOrder: 1,
        isFeatured: true,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2025, 1, 2), // Different from tLoadedAt
      );
      when(
        mockRepository.getPackageById(
          clinicId: tClinicId,
          packageId: tPackageId,
        ),
      ).thenAnswer((_) async => Right(tMismatchEntity));

      // act
      final result = await usecase(repository: mockRepository, params: tParams);

      // assert
      expect(result, const Left<Failure, Unit>(StaleDataFailure()));
      verifyNever(mockRepository.updatePackage(any));
    },
  );
}
