// test/unit/features/packages/domain/list_category_packages_usecase_test.dart
//
// Unit tests for [ListCategoryPackagesUseCase].
// Covers: happy path (sorted list), empty list, ClinicUnavailableFailure,
// and network failure.

import 'package:dartz/dartz.dart';

import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/package_service_item.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart';
import 'package:elajtech/features/packages/domain/repositories/package_repository.dart';
import 'package:elajtech/features/packages/domain/usecases/list_category_packages_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'list_category_packages_usecase_test.mocks.dart';

@GenerateMocks([PackageRepository])
void main() {
  late MockPackageRepository mockRepo;
  late ListCategoryPackagesUseCase useCase;

  // ── Common test data ───────────────────────────────────────────────────────

  const clinicId = 'andrology';
  const category = PackageCategory.andrologyInfertilityProstate;

  final now = DateTime(2026, 3, 7);

  PackageEntity makePackage({
    required String id,
    required int displayOrder,
    required bool isFeatured,
    PackageStatus status = PackageStatus.active,
  }) {
    return PackageEntity(
      id: id,
      clinicId: clinicId,
      category: category,
      name: 'باقة $id',
      shortDescription: 'وصف $id',
      services: const [
        PackageServiceItem(
          serviceId: 'svc1',
          serviceType: ServiceType.lab,
          displayName: 'تحليل',
        ),
      ],
      validityDays: 30,
      price: 500,
      currency: 'EGP',
      packageType: PackageType.physicalOnly,
      status: status,
      displayOrder: displayOrder,
      isFeatured: isFeatured,
      createdAt: now,
      updatedAt: now,
      includesVideoConsultation: false,
      includesPhysicalVisit: true,
    );
  }

  setUp(() {
    mockRepo = MockPackageRepository();
    useCase = ListCategoryPackagesUseCase(mockRepo);
  });

  group('ListCategoryPackagesUseCase', () {
    // ── T027-a: happy path — sorted list (featured first) ──────────────────
    test(
      'returns sorted list: featured packages first, then displayOrder asc',
      () async {
        // Arrange — repo returns unsorted list
        final unsorted = [
          makePackage(id: 'pkg_b', displayOrder: 2, isFeatured: false),
          makePackage(id: 'pkg_c', displayOrder: 1, isFeatured: false),
          makePackage(id: 'pkg_a', displayOrder: 3, isFeatured: true),
        ];
        when(
          mockRepo.listCategoryPackages(
            clinicId: clinicId,
            category: category,
          ),
        ).thenAnswer((_) async => Right(unsorted));

        // Act
        final result = await useCase(clinicId: clinicId, category: category);

        // Assert — featured first, then displayOrder ascending
        expect(result.isRight(), isTrue);
        final packages = result.getOrElse(() => []);
        expect(packages.length, 3);
        // featured pkg_a must be first
        expect(packages[0].id, 'pkg_a');
        expect(packages[0].isFeatured, isTrue);
        // non-featured sorted by displayOrder: pkg_c (1) < pkg_b (2)
        expect(packages[1].id, 'pkg_c');
        expect(packages[2].id, 'pkg_b');
      },
    );

    // ── T027-b: empty list ─────────────────────────────────────────────────
    test('returns empty list when repository returns no packages', () async {
      when(
        mockRepo.listCategoryPackages(
          clinicId: clinicId,
          category: category,
        ),
      ).thenAnswer((_) async => const Right([]));

      final result = await useCase(clinicId: clinicId, category: category);

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => []), isEmpty);
    });

    // ── T027-c: ClinicUnavailableFailure ───────────────────────────────────
    test('propagates ClinicUnavailableFailure from repository', () async {
      when(
        mockRepo.listCategoryPackages(
          clinicId: clinicId,
          category: category,
        ),
      ).thenAnswer(
        (_) async => const Left(ClinicUnavailableFailure()),
      );

      final result = await useCase(clinicId: clinicId, category: category);

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ClinicUnavailableFailure>()),
        (_) => fail('Expected failure'),
      );
    });

    // ── T027-d: network failure ────────────────────────────────────────────
    test('propagates NetworkFailure from repository', () async {
      when(
        mockRepo.listCategoryPackages(
          clinicId: clinicId,
          category: category,
        ),
      ).thenAnswer((_) async => const Left(NetworkFailure()));

      final result = await useCase(clinicId: clinicId, category: category);

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('Expected failure'),
      );
    });

    // ── Sorting edge cases ─────────────────────────────────────────────────
    test('when all featured, sorts by displayOrder only', () async {
      final allFeatured = [
        makePackage(id: 'b', displayOrder: 2, isFeatured: true),
        makePackage(id: 'a', displayOrder: 1, isFeatured: true),
      ];
      when(
        mockRepo.listCategoryPackages(
          clinicId: clinicId,
          category: category,
        ),
      ).thenAnswer((_) async => Right(allFeatured));

      final result = await useCase(clinicId: clinicId, category: category);

      final packages = result.getOrElse(() => []);
      expect(packages[0].id, 'a');
      expect(packages[1].id, 'b');
    });
  });
}
