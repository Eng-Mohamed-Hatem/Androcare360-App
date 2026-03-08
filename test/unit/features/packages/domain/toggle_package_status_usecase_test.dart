import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/repositories/package_repository.dart';
import 'package:elajtech/features/packages/domain/usecases/toggle_package_status_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'toggle_package_status_usecase_test.mocks.dart';

@GenerateMocks([PackageRepository])
void main() {
  late TogglePackageStatusUseCase usecase;
  late MockPackageRepository mockRepository;

  setUp(() {
    mockRepository = MockPackageRepository();
    usecase = TogglePackageStatusUseCase();
  });

  const tClinicId = 'andrology';
  const tPackageId = 'pkg-123';

  test('should toggle to INACTIVE', () async {
    when(
      mockRepository.updatePackageStatus(
        clinicId: tClinicId,
        packageId: tPackageId,
        status: PackageStatus.inactive,
      ),
    ).thenAnswer((_) async => const Right<Failure, Unit>(unit));

    final result = await usecase(
      repository: mockRepository,
      clinicId: tClinicId,
      packageId: tPackageId,
      status: PackageStatus.inactive,
    );

    expect(result, const Right<Failure, Unit>(unit));
  });

  test('should toggle to ACTIVE', () async {
    when(
      mockRepository.updatePackageStatus(
        clinicId: tClinicId,
        packageId: tPackageId,
        status: PackageStatus.active,
      ),
    ).thenAnswer((_) async => const Right<Failure, Unit>(unit));

    final result = await usecase(
      repository: mockRepository,
      clinicId: tClinicId,
      packageId: tPackageId,
      status: PackageStatus.active,
    );

    expect(result, const Right<Failure, Unit>(unit));
  });

  test('should toggle to HIDDEN', () async {
    when(
      mockRepository.updatePackageStatus(
        clinicId: tClinicId,
        packageId: tPackageId,
        status: PackageStatus.hidden,
      ),
    ).thenAnswer((_) async => const Right<Failure, Unit>(unit));

    final result = await usecase(
      repository: mockRepository,
      clinicId: tClinicId,
      packageId: tPackageId,
      status: PackageStatus.hidden,
    );

    expect(result, const Right<Failure, Unit>(unit));
  });
}
