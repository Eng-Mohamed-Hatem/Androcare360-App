// test/unit/features/packages/domain/upload_package_document_usecase_test.dart
//
// Unit tests for [UploadPackageDocumentUseCase] — T072.

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:elajtech/features/notifications/domain/repositories/notification_repository.dart';
import 'package:elajtech/features/packages/domain/entities/package_document_entity.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart';
import 'package:elajtech/features/packages/domain/repositories/package_document_repository.dart';
import 'package:elajtech/features/packages/domain/usecases/upload_package_document_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'upload_package_document_usecase_test.mocks.dart';

@GenerateMocks([PackageDocumentRepository, NotificationRepository])
void main() {
  late MockPackageDocumentRepository mockDocRepo;
  late MockNotificationRepository mockNotifRepo;
  late UploadPackageDocumentUseCase useCase;

  final now = DateTime(2026, 3, 7, 12);

  final dummyEntity = PackageDocumentEntity(
    id: 'doc_123',
    patientId: 'pat_001',
    patientPackageId: 'pp_001',
    packageId: 'pkg_001',
    clinicId: 'andrology',
    documentType: DocumentType.labResult,
    title: 'Test Lab',
    fileUrl: 'path/to/doc.pdf',
    uploadedByUserId: 'dr_001',
    uploadedByRole: 'DOCTOR',
    uploadedAt: now,
  );

  setUp(() {
    mockDocRepo = MockPackageDocumentRepository();
    mockNotifRepo = MockNotificationRepository();
    useCase = UploadPackageDocumentUseCase(mockDocRepo, mockNotifRepo);
  });

  group('UploadPackageDocumentUseCase', () {
    test('a) happy path -> documentId', () async {
      final file = File('test_valid.pdf');
      await file.writeAsBytes([1, 2, 3]);

      when(
        mockDocRepo.uploadDocument(
          localFilePath: anyNamed('localFilePath'),
          patientId: anyNamed('patientId'),
          patientPackageId: anyNamed('patientPackageId'),
          packageId: anyNamed('packageId'),
          clinicId: anyNamed('clinicId'),
          documentType: anyNamed('documentType'),
          title: anyNamed('title'),
          serviceId: anyNamed('serviceId'),
          description: anyNamed('description'),
          uploadedByUserId: anyNamed('uploadedByUserId'),
          uploadedByRole: anyNamed('uploadedByRole'),
        ),
      ).thenAnswer((_) async => Right(dummyEntity));

      when(
        mockNotifRepo.saveNotification(any),
      ).thenAnswer((_) async => const Right(unit));

      final result = await useCase(
        localFilePath: file.path,
        patientId: 'pat_001',
        patientPackageId: 'pp_001',
        packageId: 'pkg_001',
        clinicId: 'andrology',
        documentType: DocumentType.labResult,
        title: 'Test Lab',
        uploadedByUserId: 'dr_001',
        uploadedByRole: 'DOCTOR',
      );

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected right'), (doc) {
        expect(doc.id, 'doc_123');
      });

      verify(mockNotifRepo.saveNotification(any)).called(1);

      if (file.existsSync()) file.deleteSync();
    });

    test('b) UploadFailure on Storage error', () async {
      final file = File('test_error.png');
      await file.writeAsBytes([1]);

      when(
        mockDocRepo.uploadDocument(
          localFilePath: anyNamed('localFilePath'),
          patientId: anyNamed('patientId'),
          patientPackageId: anyNamed('patientPackageId'),
          packageId: anyNamed('packageId'),
          clinicId: anyNamed('clinicId'),
          documentType: anyNamed('documentType'),
          title: anyNamed('title'),
          serviceId: anyNamed('serviceId'),
          description: anyNamed('description'),
          uploadedByUserId: anyNamed('uploadedByUserId'),
          uploadedByRole: anyNamed('uploadedByRole'),
        ),
      ).thenAnswer((_) async => const Left(UploadFailure('Storage error')));

      final result = await useCase(
        localFilePath: file.path,
        patientId: 'pat_001',
        patientPackageId: 'pp_001',
        packageId: 'pkg_001',
        clinicId: 'andrology',
        documentType: DocumentType.labResult,
        title: 'Test Lab',
        uploadedByUserId: 'dr_001',
        uploadedByRole: 'DOCTOR',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<UploadFailure>()),
        (_) => fail('Expected failure'),
      );

      verifyNever(mockNotifRepo.saveNotification(any));

      if (file.existsSync()) file.deleteSync();
    });

    test('c) file > 20 MB -> UploadFailure', () async {
      final file = File('huge.pdf');
      // Create a 21MB file
      await file.writeAsBytes(List<int>.filled(21 * 1024 * 1024, 0));

      final result = await useCase(
        localFilePath: file.path,
        patientId: 'pat_001',
        patientPackageId: 'pp_001',
        packageId: 'pkg_001',
        clinicId: 'andrology',
        documentType: DocumentType.labResult,
        title: 'Test Lab',
        uploadedByUserId: 'dr_001',
        uploadedByRole: 'DOCTOR',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) {
          expect(f, isA<UploadFailure>());
          expect((f as UploadFailure).message, contains('20 MB'));
        },
        (_) => fail('Expected failure'),
      );

      verifyZeroInteractions(mockDocRepo);

      try {
        if (file.existsSync()) file.deleteSync();
      } catch (_) {}
    });

    test('d) unsupported type -> UploadFailure', () async {
      final result = await useCase(
        localFilePath: 'path/to/report.docx',
        patientId: 'pat_001',
        patientPackageId: 'pp_001',
        packageId: 'pkg_001',
        clinicId: 'andrology',
        documentType: DocumentType.other,
        title: 'Test Doc',
        uploadedByUserId: 'dr_001',
        uploadedByRole: 'DOCTOR',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) {
          expect(f, isA<UploadFailure>());
          expect((f as UploadFailure).message, contains('Unsupported'));
        },
        (_) => fail('Expected failure'),
      );

      verifyZeroInteractions(mockDocRepo);
    });

    test('e) serviceId = null is valid', () async {
      final file = File('test_null_service.jpg');
      await file.writeAsBytes([1]);

      when(
        mockDocRepo.uploadDocument(
          localFilePath: anyNamed('localFilePath'),
          patientId: anyNamed('patientId'),
          patientPackageId: anyNamed('patientPackageId'),
          packageId: anyNamed('packageId'),
          clinicId: anyNamed('clinicId'),
          documentType: anyNamed('documentType'),
          title: anyNamed('title'),
          serviceId: anyNamed('serviceId'),
          description: anyNamed('description'),
          uploadedByUserId: anyNamed('uploadedByUserId'),
          uploadedByRole: anyNamed('uploadedByRole'),
        ),
      ).thenAnswer((_) async => Right(dummyEntity));

      when(
        mockNotifRepo.saveNotification(any),
      ).thenAnswer((_) async => const Right(unit));

      final result = await useCase(
        localFilePath: file.path,
        patientId: 'pat_001',
        patientPackageId: 'pp_001',
        packageId: 'pkg_001',
        clinicId: 'andrology',
        documentType: DocumentType.labResult,
        title: 'Test Lab',
        uploadedByUserId: 'dr_001',
        uploadedByRole: 'DOCTOR',
      );

      expect(result.isRight(), isTrue);

      if (file.existsSync()) file.deleteSync();
    });

    test(
      'f) NetworkFailure if offline (repo returns NetworkFailure)',
      () async {
        final file = File('test_offline.pdf');
        await file.writeAsBytes([1]);

        when(
          mockDocRepo.uploadDocument(
            localFilePath: anyNamed('localFilePath'),
            patientId: anyNamed('patientId'),
            patientPackageId: anyNamed('patientPackageId'),
            packageId: anyNamed('packageId'),
            clinicId: anyNamed('clinicId'),
            documentType: anyNamed('documentType'),
            title: anyNamed('title'),
            serviceId: anyNamed('serviceId'),
            description: anyNamed('description'),
            uploadedByUserId: anyNamed('uploadedByUserId'),
            uploadedByRole: anyNamed('uploadedByRole'),
          ),
        ).thenAnswer((_) async => const Left(NetworkFailure()));

        final result = await useCase(
          localFilePath: file.path,
          patientId: 'pat_001',
          patientPackageId: 'pp_001',
          packageId: 'pkg_001',
          clinicId: 'andrology',
          documentType: DocumentType.labResult,
          title: 'Test Lab',
          uploadedByUserId: 'dr_001',
          uploadedByRole: 'DOCTOR',
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (f) => expect(f, isA<NetworkFailure>()),
          (_) => fail('Expected failure'),
        );

        if (file.existsSync()) file.deleteSync();
      },
    );
  });
}
