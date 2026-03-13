// test/unit/features/packages/domain/get_patient_packages_usecase_test.dart
//
// Unit tests for [GetPatientPackagesUseCase] — T042.
// Covers: happy path, empty list, network error, expiry re-derivation,
// and R2 assertion (notes == null on all returned entities).

import 'package:dartz/dartz.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart';
import 'package:elajtech/features/packages/domain/repositories/patient_package_repository.dart';
import 'package:elajtech/features/packages/domain/usecases/get_patient_packages_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_patient_packages_usecase_test.mocks.dart';

@GenerateMocks([PatientPackageRepository])
void main() {
  late MockPatientPackageRepository mockRepo;
  late GetPatientPackagesUseCase useCase;

  const patientId = 'uid_patient_001';
  final now = DateTime(2026, 3, 7, 12);

  // Helper to build a PatientPackageEntity
  PatientPackageEntity makeEntity({
    String id = 'pp_001',
    PatientPackageStatus status = PatientPackageStatus.active,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    String? notes,
  }) {
    final pDate = purchaseDate ?? now.subtract(const Duration(days: 10));
    final eDate = expiryDate ?? now.add(const Duration(days: 80));
    return PatientPackageEntity(
      id: id,
      patientId: patientId,
      packageId: 'pkg_001',
      packageName: 'Test Package',
      clinicId: 'andrology',
      category: PackageCategory.andrologyInfertilityProstate,
      status: status,
      purchaseDate: pDate,
      expiryDate: eDate,
      totalServicesCount: 3,
      usedServicesCount: 0,
      createdAt: pDate,
      updatedAt: pDate,
      notes: notes,
    );
  }

  setUp(() {
    mockRepo = MockPatientPackageRepository();
    useCase = GetPatientPackagesUseCase(mockRepo);
  });

  group('GetPatientPackagesUseCase', () {
    // ── T042-a: happy path ───────────────────────────────────────────────────
    test(
      'happy path: returns Right with list sorted by purchaseDate DESC',
      () async {
        final older = makeEntity(
          purchaseDate: now.subtract(const Duration(days: 30)),
          expiryDate: now.add(const Duration(days: 60)),
        );
        final newer = makeEntity(
          id: 'pp_002',
          purchaseDate: now.subtract(const Duration(days: 5)),
          expiryDate: now.add(const Duration(days: 85)),
        );

        when(
          mockRepo.getPatientPackages(patientId: patientId),
        ).thenAnswer((_) async => Right([older, newer]));

        final result = await useCase(patientId: patientId, now: now);

        expect(result.isRight(), isTrue);
        result.fold((_) => fail('Expected right'), (list) {
          expect(list.length, 2);
          // Newer purchase should be first (DESC order)
          expect(list[0].id, 'pp_002');
          expect(list[1].id, 'pp_001');
        });
      },
    );

    // ── T042-b: empty list ────────────────────────────────────────────────────
    test(
      'empty list: returns Right([]) when patient has no packages',
      () async {
        when(
          mockRepo.getPatientPackages(patientId: patientId),
        ).thenAnswer((_) async => const Right([]));

        final result = await useCase(patientId: patientId, now: now);

        expect(result.isRight(), isTrue);
        result.fold((_) => fail('Expected right'), (list) {
          expect(list, isEmpty);
        });
      },
    );

    // ── T042-c: network error ─────────────────────────────────────────────────
    test(
      'network error: returns Left(NetworkFailure) on repository error',
      () async {
        when(
          mockRepo.getPatientPackages(patientId: patientId),
        ).thenAnswer((_) async => const Left(NetworkFailure()));

        final result = await useCase(patientId: patientId, now: now);

        expect(result.isLeft(), isTrue);
        result.fold(
          (f) => expect(f, isA<NetworkFailure>()),
          (_) => fail('Expected failure'),
        );
      },
    );

    // ── T042-d: expiry re-derivation ─────────────────────────────────────────
    test(
      'expiry re-derivation: ACTIVE entity with expiryDate < now is returned '
      'with status EXPIRED',
      () async {
        // Entity from repo has ACTIVE status but expiryDate is in the past
        final expiredEntity = makeEntity(
          id: 'pp_expired',
          expiryDate: now.subtract(const Duration(days: 1)), // in the past
        );

        when(
          mockRepo.getPatientPackages(patientId: patientId),
        ).thenAnswer((_) async => Right([expiredEntity]));

        final result = await useCase(patientId: patientId, now: now);

        expect(result.isRight(), isTrue);
        result.fold((_) => fail('Expected right'), (list) {
          expect(list.length, 1);
          // Use case must re-derive status as EXPIRED
          expect(list[0].status, PatientPackageStatus.expired);
        });
      },
    );

    // ── T042-e: R2 assertion — notes always null ──────────────────────────────
    test(
      'R2: notes field is null on every returned entity even when repo '
      'provides non-null notes',
      () async {
        // Simulate a repo that (wrongly) returns notes — use case must strip it
        final entityWithNotes = makeEntity(notes: 'ملاحظات داخلية للطبيب');

        when(
          mockRepo.getPatientPackages(patientId: patientId),
        ).thenAnswer((_) async => Right([entityWithNotes]));

        final result = await useCase(patientId: patientId, now: now);

        expect(result.isRight(), isTrue);
        result.fold((_) => fail('Expected right'), (list) {
          for (final entity in list) {
            expect(
              entity.notes,
              isNull,
              reason: 'R2: notes must never be exposed to patient',
            );
          }
        });
      },
    );
  });
}
