// test/unit/features/packages/domain/get_package_details_usecase_test.dart
//
// Unit tests for [GetPackageDetailsUseCase].
// Covers: happy path, PackageNotFoundFailure, ClinicUnavailableFailure.

import 'package:dartz/dartz.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/package_service_item.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart';
import 'package:elajtech/features/packages/domain/repositories/package_repository.dart';
import 'package:elajtech/features/packages/domain/usecases/get_package_details_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_package_details_usecase_test.mocks.dart';

@GenerateMocks([PackageRepository])
void main() {
  late MockPackageRepository mockRepo;
  late GetPackageDetailsUseCase useCase;

  const clinicId = 'andrology';
  const packageId = 'pkg_001';

  final now = DateTime(2026, 3, 7);

  final samplePackage = PackageEntity(
    id: packageId,
    clinicId: clinicId,
    category: PackageCategory.andrologyInfertilityProstate,
    name: 'باقة الخصوبة الأساسية',
    shortDescription: 'وصف مختصر',
    services: const [
      PackageServiceItem(
        serviceId: 'svc1',
        serviceType: ServiceType.lab,
        displayName: 'تحليل السائل المنوي',
      ),
    ],
    validityDays: 90,
    price: 1200,
    currency: 'EGP',
    packageType: PackageType.physicalOnly,
    status: PackageStatus.active,
    displayOrder: 1,
    isFeatured: false,
    createdAt: now,
    updatedAt: now,
    includesVideoConsultation: false,
    includesPhysicalVisit: true,
  );

  setUp(() {
    mockRepo = MockPackageRepository();
    useCase = GetPackageDetailsUseCase(mockRepo);
  });

  group('GetPackageDetailsUseCase', () {
    // ── T029-a: happy path ───────────────────────────────────────────────
    test('returns PackageEntity on success', () async {
      when(
        mockRepo.getPackageById(clinicId: clinicId, packageId: packageId),
      ).thenAnswer((_) async => Right(samplePackage));

      final result = await useCase(clinicId: clinicId, packageId: packageId);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected success'),
        (pkg) {
          expect(pkg.id, packageId);
          expect(pkg.clinicId, clinicId);
          expect(pkg.name, 'باقة الخصوبة الأساسية');
          expect(pkg.price, 1200.0);
        },
      );
    });

    // ── T029-b: PackageNotFoundFailure ───────────────────────────────────
    test(
      'propagates PackageNotFoundFailure when document is missing',
      () async {
        when(
          mockRepo.getPackageById(clinicId: clinicId, packageId: packageId),
        ).thenAnswer((_) async => const Left(PackageNotFoundFailure()));

        final result = await useCase(clinicId: clinicId, packageId: packageId);

        expect(result.isLeft(), isTrue);
        result.fold(
          (f) => expect(f, isA<PackageNotFoundFailure>()),
          (_) => fail('Expected failure'),
        );
      },
    );

    // ── T029-c: ClinicUnavailableFailure ─────────────────────────────────
    test(
      'propagates ClinicUnavailableFailure when clinic is deactivated',
      () async {
        when(
          mockRepo.getPackageById(clinicId: clinicId, packageId: packageId),
        ).thenAnswer((_) async => const Left(ClinicUnavailableFailure()));

        final result = await useCase(clinicId: clinicId, packageId: packageId);

        expect(result.isLeft(), isTrue);
        result.fold(
          (f) => expect(f, isA<ClinicUnavailableFailure>()),
          (_) => fail('Expected failure'),
        );
      },
    );
  });
}
