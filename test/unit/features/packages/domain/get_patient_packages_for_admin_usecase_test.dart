// test/unit/features/packages/domain/get_patient_packages_for_admin_usecase_test.dart
//
// Unit tests for [GetPatientPackagesForAdminUseCase] — T070.
// Covers: happy path paginated, empty, and R2 assertion (notes field IS included).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
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
  late MockPatientPackageRepository mockRepo;
  late GetPatientPackagesForAdminUseCase useCase;

  const patientId = 'uid_patient_001';
  final now = DateTime(2026, 3, 7, 12);

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
    useCase = GetPatientPackagesForAdminUseCase(mockRepo);
  });

  group('GetPatientPackagesForAdminUseCase', () {
    // ── T070-a: happy path paginated ─────────────────────────────────────────
    test('happy path: returns Right paginated', () async {
      final p1 = makeEntity(id: 'pp_001', notes: 'admin note 1');
      final p2 = makeEntity(id: 'pp_002');
      final mockDoc = MockDocumentSnapshot<Object?>();
      
      when(mockRepo.listPatientPackagesForAdmin(
        patientId: patientId,
        lastDocument: mockDoc,
        limit: 20,
      )).thenAnswer((_) async => Right([p1, p2]));

      final result = await useCase(
        patientId: patientId, 
        lastDocument: mockDoc,
        limit: 20,
        now: now,
      );

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected right'), (list) {
        expect(list.length, 2);
        expect(list[0].id, 'pp_001');
      });
    });

    // ── T070-b: empty list ───────────────────────────────────────────────────
    test('empty list: returns Right([])', () async {
      when(mockRepo.listPatientPackagesForAdmin(
        patientId: patientId,
        lastDocument: null,
        limit: 20,
      )).thenAnswer((_) async => const Right([]));

      final result = await useCase(patientId: patientId, now: now);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected right'), (list) {
        expect(list, isEmpty);
      });
    });

    // ── T070-c: R2 notes field IS included ────────────────────────────────────
    test('R2: notes field IS included in returned entity (admin-facing)', () async {
      final notesValue = 'ملاحظات هامة جدا للأدمن';
      final entityWithNotes = makeEntity(notes: notesValue);

      when(mockRepo.listPatientPackagesForAdmin(
        patientId: patientId,
        lastDocument: null,
        limit: 20,
      )).thenAnswer((_) async => Right([entityWithNotes]));

      final result = await useCase(patientId: patientId, now: now);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected right'), (list) {
        expect(list.length, 1);
        expect(
          list.first.notes, 
          equals(notesValue),
          reason: 'R2: notes must be visible to admin',
        );
      });
    });

    // ── Expiry re-derivation ─────────────────────────────────────────────────
    test('expiry re-derivation: ACTIVE entity with expiryDate < now is EXPIRED', () async {
      final expiredEntity = makeEntity(
        id: 'pp_expired',
        expiryDate: now.subtract(const Duration(days: 1)),
      );

      when(mockRepo.listPatientPackagesForAdmin(
        patientId: patientId,
        lastDocument: null,
        limit: 20,
      )).thenAnswer((_) async => Right([expiredEntity]));

      final result = await useCase(patientId: patientId, now: now);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected right'), (list) {
        expect(list.length, 1);
        expect(list[0].status, PatientPackageStatus.expired);
      });
    });
  });
}
