import 'package:dartz/dartz.dart';
import 'package:elajtech/core/auth/clinic_access_resolver.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart';
import 'package:elajtech/features/packages/domain/repositories/package_repository.dart';
import 'package:elajtech/features/packages/domain/usecases/duplicate_package_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'duplicate_package_usecase_test.mocks.dart';

@GenerateMocks([PackageRepository, ClinicAccessResolver])
void main() {
  late DuplicatePackageUseCase usecase;
  late MockPackageRepository mockRepository;
  late MockClinicAccessResolver mockAccessResolver;

  setUp(() {
    mockRepository = MockPackageRepository();
    mockAccessResolver = MockClinicAccessResolver();
    usecase = DuplicatePackageUseCase(mockAccessResolver);
  });

  const tClinicId = 'andrology';
  const tPackageId = 'pkg-1';

  final tSource = PackageEntity.fromType(
    id: tPackageId,
    clinicId: tClinicId,
    category: PackageCategory.andrologyInfertilityProstate,
    name: 'Original',
    shortDescription: 'desc',
    services: const [],
    validityDays: 1,
    price: 10,
    currency: 'EGP',
    type: PackageType.both,
    status: PackageStatus.active,
    displayOrder: 1,
    isFeatured: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  test(
    'should duplicate package with HIDDEN status and appended name',
    () async {
      when(
        mockAccessResolver.getAllowedClinics(),
      ).thenAnswer((_) async => [tClinicId]);
      when(
        mockRepository.getPackageById(
          clinicId: tClinicId,
          packageId: tPackageId,
        ),
      ).thenAnswer((_) async => Right<Failure, PackageEntity>(tSource));
      when(
        mockRepository.createPackage(any),
      ).thenAnswer((_) async => const Right<Failure, String>('new_pkg'));

      final result = await usecase(
        repository: mockRepository,
        clinicId: tClinicId,
        packageId: tPackageId,
      );

      expect(result, const Right<Failure, String>('new_pkg'));

      final captured = verify(
        mockRepository.createPackage(captureAny),
      ).captured;
      final duplicate = captured.first as PackageEntity;
      expect(duplicate.id, '');
      expect(duplicate.name, 'Original (نسخة)');
      expect(duplicate.status, PackageStatus.hidden);
      expect(duplicate.isFeatured, false);
    },
  );

  test('should return failure if user lacks access', () async {
    when(
      mockAccessResolver.getAllowedClinics(),
    ).thenAnswer((_) async => ['other']);

    final result = await usecase(
      repository: mockRepository,
      clinicId: tClinicId,
      packageId: tPackageId,
    );

    expect(
      result,
      const Left<Failure, String>(
        ClinicUnavailableFailure('ليس لديك صلاحية لإضافة باقة في هذه العيادة.'),
      ),
    );
    verifyNever(
      mockRepository.getPackageById(
        clinicId: anyNamed('clinicId'),
        packageId: anyNamed('packageId'),
      ),
    );
  });
}
