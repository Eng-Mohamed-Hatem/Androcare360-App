import 'package:dartz/dartz.dart';
import 'package:elajtech/core/auth/clinic_access_resolver.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart';
import 'package:elajtech/features/packages/domain/repositories/package_repository.dart';
import 'package:elajtech/features/packages/domain/usecases/list_clinic_packages_for_admin_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'list_clinic_packages_for_admin_usecase_test.mocks.dart';

@GenerateMocks([PackageRepository, ClinicAccessResolver])
void main() {
  late ListClinicPackagesForAdminUseCase usecase;
  late MockPackageRepository mockRepository;
  late MockClinicAccessResolver mockAccessResolver;

  setUp(() {
    mockRepository = MockPackageRepository();
    mockAccessResolver = MockClinicAccessResolver();
    usecase = ListClinicPackagesForAdminUseCase(mockAccessResolver);
  });

  const tClinicId = 'andrology';
  final tPackages = [
    PackageEntity.fromType(
      id: '1',
      clinicId: tClinicId,
      category: PackageCategory.andrologyInfertilityProstate,
      name: 'A',
      shortDescription: '',
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
    ),
    PackageEntity.fromType(
      id: '2',
      clinicId: tClinicId,
      category: PackageCategory.physiotherapyRehabilitation,
      name: 'B',
      shortDescription: '',
      services: const [],
      validityDays: 1,
      price: 10,
      currency: 'EGP',
      type: PackageType.both,
      status: PackageStatus.inactive,
      displayOrder: 2,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  test('should return filtered paginated results on happy path', () async {
    when(
      mockAccessResolver.canAccessClinic(tClinicId),
    ).thenAnswer((_) async => true);
    when(
      mockRepository.listClinicPackagesForAdmin(
        clinicId: tClinicId,
        limit: anyNamed('limit'),
      ),
    ).thenAnswer((_) async => Right<Failure, List<PackageEntity>>(tPackages));

    final result = await usecase(
      repository: mockRepository,
      params: const ListClinicPackagesForAdminParams(
        clinicId: tClinicId,
        status: PackageStatus.active,
      ),
    );

    expect(result.isRight(), true);
    final packages = result.getOrElse(() => []);
    expect(packages.length, 1);
    expect(packages.first.id, '1');
  });

  test('should return ClinicUnavailableFailure if not allowed', () async {
    when(
      mockAccessResolver.canAccessClinic(tClinicId),
    ).thenAnswer((_) async => false);

    final result = await usecase(
      repository: mockRepository,
      params: const ListClinicPackagesForAdminParams(clinicId: tClinicId),
    );

    expect(
      result,
      const Left<Failure, List<PackageEntity>>(
        ClinicUnavailableFailure('ليس لديك صلاحية لعرض باقات هذه العيادة.'),
      ),
    );
    verifyNever(mockRepository.listClinicPackagesForAdmin(clinicId: tClinicId));
  });
}
