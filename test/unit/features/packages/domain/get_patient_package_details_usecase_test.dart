// test/unit/features/packages/domain/get_patient_package_details_usecase_test.dart
//
// Unit tests for [GetPatientPackageDetailsUseCase] — T044.
// Covers: happy path (entity + documents), PackageNotFoundFailure, R2 notes assertion.

import 'package:dartz/dartz.dart';
import 'package:elajtech/features/packages/domain/entities/package_document_entity.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart';
import 'package:elajtech/features/packages/domain/repositories/package_document_repository.dart';
import 'package:elajtech/features/packages/domain/repositories/patient_package_repository.dart';
import 'package:elajtech/features/packages/domain/usecases/get_patient_package_details_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_patient_package_details_usecase_test.mocks.dart';

@GenerateMocks([PatientPackageRepository, PackageDocumentRepository])
void main() {
  late MockPatientPackageRepository mockPackageRepo;
  late MockPackageDocumentRepository mockDocumentRepo;
  late GetPatientPackageDetailsUseCase useCase;

  const patientId = 'uid_patient_001';
  const patientPackageId = 'pp_001';
  final now = DateTime(2026, 3, 7, 12);

  final sampleEntity = PatientPackageEntity(
    id: patientPackageId,
    patientId: patientId,
    packageId: 'pkg_001',
    packageName: 'Test Package',
    clinicId: 'andrology',
    category: PackageCategory.andrologyInfertilityProstate,
    status: PatientPackageStatus.active,
    purchaseDate: now.subtract(const Duration(days: 5)),
    expiryDate: now.add(const Duration(days: 85)),
    totalServicesCount: 3,
    usedServicesCount: 0,
    createdAt: now.subtract(const Duration(days: 5)),
    updatedAt: now.subtract(const Duration(days: 5)),
  );

  final sampleDocument = PackageDocumentEntity(
    id: 'doc_001',
    patientId: patientId,
    patientPackageId: patientPackageId,
    packageId: 'pkg_001',
    clinicId: 'andrology',
    documentType: DocumentType.labResult,
    title: 'نتيجة تحليل الهرمونات',
    fileUrl: 'https://storage.googleapis.com/test/doc001.pdf',
    uploadedByUserId: 'doctor_001',
    uploadedByRole: 'DOCTOR',
    uploadedAt: now.subtract(const Duration(days: 2)),
  );

  setUp(() {
    mockPackageRepo = MockPatientPackageRepository();
    mockDocumentRepo = MockPackageDocumentRepository();
    useCase = GetPatientPackageDetailsUseCase(
      patientPackageRepository: mockPackageRepo,
      documentRepository: mockDocumentRepo,
    );
  });

  group('GetPatientPackageDetailsUseCase', () {
    // ── T044-a: happy path ───────────────────────────────────────────────────
    test(
      'happy path: returns Right with entity and documents list',
      () async {
        when(
          mockPackageRepo.getPatientPackageByIdForPatient(
            patientId: patientId,
            patientPackageId: patientPackageId,
          ),
        ).thenAnswer((_) async => Right(sampleEntity));

        when(
          mockDocumentRepo.getDocumentsByPatientPackage(
            patientId: patientId,
            patientPackageId: patientPackageId,
          ),
        ).thenAnswer((_) async => Right([sampleDocument]));

        final result = await useCase(
          patientId: patientId,
          patientPackageId: patientPackageId,
        );

        expect(result.isRight(), isTrue);
        result.fold((_) => fail('Expected right'), (details) {
          expect(details.entity.id, patientPackageId);
          expect(details.documents.length, 1);
          expect(details.documents.first.id, 'doc_001');
        });
      },
    );

    // ── T044-b: PackageNotFoundFailure ────────────────────────────────────────
    test(
      'returns PackageNotFoundFailure when package is not found',
      () async {
        when(
          mockPackageRepo.getPatientPackageByIdForPatient(
            patientId: patientId,
            patientPackageId: patientPackageId,
          ),
        ).thenAnswer((_) async => const Left(PackageNotFoundFailure()));

        final result = await useCase(
          patientId: patientId,
          patientPackageId: patientPackageId,
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (f) => expect(f, isA<PackageNotFoundFailure>()),
          (_) => fail('Expected failure'),
        );

        // Documents should NOT be fetched if entity lookup fails
        verifyNever(
          mockDocumentRepo.getDocumentsByPatientPackage(
            patientId: anyNamed('patientId'),
            patientPackageId: anyNamed('patientPackageId'),
          ),
        );
      },
    );

    // ── T044-c: R2 — notes absent from returned entity ────────────────────────
    test(
      'R2: notes field is null on entity returned to patient',
      () async {
        // Repository correctly returns notes=null (R2 enforced at repo level)
        // but we also verify use case does not re-add it.
        when(
          mockPackageRepo.getPatientPackageByIdForPatient(
            patientId: patientId,
            patientPackageId: patientPackageId,
          ),
        ).thenAnswer((_) async => Right(sampleEntity));

        when(
          mockDocumentRepo.getDocumentsByPatientPackage(
            patientId: patientId,
            patientPackageId: patientPackageId,
          ),
        ).thenAnswer((_) async => const Right([]));

        final result = await useCase(
          patientId: patientId,
          patientPackageId: patientPackageId,
        );

        expect(result.isRight(), isTrue);
        result.fold((_) => fail('Expected right'), (details) {
          expect(
            details.entity.notes,
            isNull,
            reason: 'R2: notes must never be exposed to patient',
          );
        });
      },
    );

    // ── T044-d: empty documents ───────────────────────────────────────────────
    test(
      'returns Right with entity and empty documents list when no documents exist',
      () async {
        when(
          mockPackageRepo.getPatientPackageByIdForPatient(
            patientId: patientId,
            patientPackageId: patientPackageId,
          ),
        ).thenAnswer((_) async => Right(sampleEntity));

        when(
          mockDocumentRepo.getDocumentsByPatientPackage(
            patientId: patientId,
            patientPackageId: patientPackageId,
          ),
        ).thenAnswer((_) async => const Right([]));

        final result = await useCase(
          patientId: patientId,
          patientPackageId: patientPackageId,
        );

        expect(result.isRight(), isTrue);
        result.fold((_) => fail('Expected right'), (details) {
          expect(details.documents, isEmpty);
        });
      },
    );
  });
}
