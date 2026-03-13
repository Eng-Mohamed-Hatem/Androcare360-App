import 'package:dartz/dartz.dart';
import 'package:elajtech/core/auth/clinic_access_resolver.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/package_service_item.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart';
import 'package:elajtech/features/packages/domain/repositories/package_repository.dart';
import 'package:elajtech/features/packages/domain/usecases/create_clinic_package_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'create_clinic_package_usecase_test.mocks.dart';

@GenerateMocks([PackageRepository, ClinicAccessResolver])
void main() {
  late CreateClinicPackageUseCase usecase;
  late MockPackageRepository mockRepository;
  late MockClinicAccessResolver mockAccessResolver;

  setUp(() {
    mockRepository = MockPackageRepository();
    mockAccessResolver = MockClinicAccessResolver();
    usecase = CreateClinicPackageUseCase(mockAccessResolver);
  });

  const tClinicId = 'andrology';
  const tParams = CreatePackageParams(
    clinicId: tClinicId,
    category: PackageCategory.andrologyInfertilityProstate,
    name: 'باقة رجالية',
    shortDescription: 'وصف قصير',
    services: [
      PackageServiceItem(
        serviceId: '1',
        serviceType: ServiceType.lab,
        displayName: 'فحص دم',
      ),
    ],
    validityDays: 30,
    price: 100,
    currency: 'SAR',
    type: PackageType.both,
    status: PackageStatus.active,
    isFeatured: true,
  );

  test('should return new packageId when valid and user has access', () async {
    // arrange
    when(
      mockAccessResolver.getAllowedClinics(),
    ).thenAnswer((_) async => [tClinicId]);
    when(
      mockRepository.listClinicPackagesForAdmin(
        clinicId: anyNamed('clinicId'),
        limit: anyNamed('limit'),
      ),
    ).thenAnswer(
      (_) async => const Right<Failure, List<PackageEntity>>(<PackageEntity>[]),
    );
    when(
      mockRepository.createPackage(any),
    ).thenAnswer((_) async => const Right<Failure, String>('new_pkg_id'));

    // act
    final result = await usecase(repository: mockRepository, params: tParams);

    // assert
    expect(result, const Right<Failure, String>('new_pkg_id'));
    // verify derived booleans are computed
    final captured = verify(mockRepository.createPackage(captureAny)).captured;
    final entity = captured.first as PackageEntity;
    expect(entity.includesVideoConsultation, isTrue); // PackageType.both
    expect(entity.includesPhysicalVisit, isTrue);
  });

  test('should return validation failure when name > 200 chars', () async {
    // arrange
    when(
      mockAccessResolver.getAllowedClinics(),
    ).thenAnswer((_) async => [tClinicId]);
    final invalidParams = CreatePackageParams(
      clinicId: tClinicId,
      category: PackageCategory.andrologyInfertilityProstate,
      name: 'A' * 201,
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
      currency: 'SAR',
      type: PackageType.both,
      status: PackageStatus.active,
      isFeatured: true,
    );

    // act
    final result = await usecase(
      repository: mockRepository,
      params: invalidParams,
    );

    // assert
    expect(result.isLeft(), isTrue);
    verifyNever(mockRepository.createPackage(any));
  });

  test(
    'should return ClinicUnavailableFailure when user does not have access',
    () async {
      // arrange
      when(
        mockAccessResolver.getAllowedClinics(),
      ).thenAnswer((_) async => ['other_clinic']);

      // act
      final result = await usecase(repository: mockRepository, params: tParams);

      // assert
      expect(
        result,
        const Left<Failure, String>(
          ClinicUnavailableFailure(
            'ليس لديك صلاحية لإضافة باقة في هذه العيادة.',
          ),
        ),
      );
      verifyNever(mockRepository.createPackage(any));
    },
  );
}
