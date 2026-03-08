import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/notifications/domain/repositories/notification_repository.dart';
import 'package:elajtech/features/packages/domain/entities/package_document_entity.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart';
import 'package:elajtech/features/packages/domain/repositories/package_document_repository.dart';
import 'package:elajtech/features/packages/domain/usecases/upload_package_document_usecase.dart';
import 'package:elajtech/shared/models/notification_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'upload_package_document_usecase_test.mocks.dart';

@GenerateMocks([PackageDocumentRepository, NotificationRepository])
void main() {
  late UploadPackageDocumentUseCase usecase;
  late MockPackageDocumentRepository mockDocumentRepo;
  late MockNotificationRepository mockNotificationRepo;

  setUpAll(() {
    provideDummy<NotificationModel>(
      NotificationModel(
        id: '',
        userId: '',
        title: '',
        body: '',
        type: NotificationType.general,
        createdAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    provideDummy<Either<Failure, Unit>>(const Right<Failure, Unit>(unit));
    mockDocumentRepo = MockPackageDocumentRepository();
    mockNotificationRepo = MockNotificationRepository();
    usecase = UploadPackageDocumentUseCase(
      mockDocumentRepo,
      mockNotificationRepo,
    );
  });

  const tLocalPath = '/path/to/test.pdf';
  const tPatientId = 'patient_1';
  const tPatientPackageId = 'pp_1';
  const tPackageId = 'pkg_1';
  const tClinicId = 'clinic_1';
  const tDocType = DocumentType.labResult;
  const tTitle = 'Blood Test';
  const tUserId = 'doctor_1';
  const tRole = 'doctor';

  final tDocument = PackageDocumentEntity(
    id: 'doc_1',
    patientId: tPatientId,
    patientPackageId: tPatientPackageId,
    packageId: tPackageId,
    clinicId: tClinicId,
    documentType: tDocType,
    title: tTitle,
    fileUrl: 'https://example.com/test.pdf',
    uploadedByUserId: tUserId,
    uploadedByRole: tRole,
    uploadedAt: DateTime.now(),
  );

  test(
    'happy path: should upload doc, return documentId/entity, and send notification best-effort',
    () async {
      // arrange
      when(
        mockDocumentRepo.uploadDocument(
          localFilePath: anyNamed('localFilePath'),
          patientId: anyNamed('patientId'),
          patientPackageId: anyNamed('patientPackageId'),
          packageId: anyNamed('packageId'),
          clinicId: anyNamed('clinicId'),
          documentType: anyNamed('documentType'),
          title: anyNamed('title'),
          uploadedByUserId: anyNamed('uploadedByUserId'),
          uploadedByRole: anyNamed('uploadedByRole'),
          serviceId: anyNamed('serviceId'),
          description: anyNamed('description'),
        ),
      ).thenAnswer(
        (_) async => Right<Failure, PackageDocumentEntity>(tDocument),
      );

      when(
        mockNotificationRepo.saveNotification(any),
      ).thenAnswer((_) async => const Right<Failure, Unit>(unit));

      // act
      final result = await usecase(
        localFilePath: tLocalPath,
        patientId: tPatientId,
        patientPackageId: tPatientPackageId,
        packageId: tPackageId,
        clinicId: tClinicId,
        documentType: tDocType,
        title: tTitle,
        uploadedByUserId: tUserId,
        uploadedByRole: tRole,
      );

      // assert
      expect(result, Right<Failure, PackageDocumentEntity>(tDocument));
      verify(
        mockDocumentRepo.uploadDocument(
          localFilePath: tLocalPath,
          patientId: tPatientId,
          patientPackageId: tPatientPackageId,
          packageId: tPackageId,
          clinicId: tClinicId,
          documentType: tDocType,
          title: tTitle,
          uploadedByUserId: tUserId,
          uploadedByRole: tRole,
        ),
      ).called(1);
      // verify notification was sent
      verify(mockNotificationRepo.saveNotification(any)).called(1);
      verifyNoMoreInteractions(mockDocumentRepo);
      verifyNoMoreInteractions(mockNotificationRepo);
    },
  );

  test('happy path with serviceId != null', () async {
    // arrange
    when(
      mockDocumentRepo.uploadDocument(
        localFilePath: anyNamed('localFilePath'),
        patientId: anyNamed('patientId'),
        patientPackageId: anyNamed('patientPackageId'),
        packageId: anyNamed('packageId'),
        clinicId: anyNamed('clinicId'),
        documentType: anyNamed('documentType'),
        title: anyNamed('title'),
        uploadedByUserId: anyNamed('uploadedByUserId'),
        uploadedByRole: anyNamed('uploadedByRole'),
        serviceId: anyNamed('serviceId'),
        description: anyNamed('description'),
      ),
    ).thenAnswer((_) async => Right<Failure, PackageDocumentEntity>(tDocument));

    when(
      mockNotificationRepo.saveNotification(any),
    ).thenAnswer((_) async => const Right<Failure, Unit>(unit));

    // act
    final result = await usecase(
      localFilePath: tLocalPath,
      patientId: tPatientId,
      patientPackageId: tPatientPackageId,
      packageId: tPackageId,
      clinicId: tClinicId,
      documentType: tDocType,
      title: tTitle,
      uploadedByUserId: tUserId,
      uploadedByRole: tRole,
      serviceId: 'srv_1',
    );

    // assert
    expect(result, Right<Failure, PackageDocumentEntity>(tDocument));
    verify(
      mockDocumentRepo.uploadDocument(
        localFilePath: tLocalPath,
        patientId: tPatientId,
        patientPackageId: tPatientPackageId,
        packageId: tPackageId,
        clinicId: tClinicId,
        documentType: tDocType,
        title: tTitle,
        uploadedByUserId: tUserId,
        uploadedByRole: tRole,
        serviceId: 'srv_1',
      ),
    ).called(1);
  });

  test('UploadFailure on Storage error', () async {
    // arrange
    when(
      mockDocumentRepo.uploadDocument(
        localFilePath: anyNamed('localFilePath'),
        patientId: anyNamed('patientId'),
        patientPackageId: anyNamed('patientPackageId'),
        packageId: anyNamed('packageId'),
        clinicId: anyNamed('clinicId'),
        documentType: anyNamed('documentType'),
        title: anyNamed('title'),
        uploadedByUserId: anyNamed('uploadedByUserId'),
        uploadedByRole: anyNamed('uploadedByRole'),
        serviceId: anyNamed('serviceId'),
        description: anyNamed('description'),
      ),
    ).thenAnswer(
      (_) async => const Left<Failure, PackageDocumentEntity>(
        UploadFailure('Storage failed'),
      ),
    );

    // act
    final result = await usecase(
      localFilePath: tLocalPath,
      patientId: tPatientId,
      patientPackageId: tPatientPackageId,
      packageId: tPackageId,
      clinicId: tClinicId,
      documentType: tDocType,
      title: tTitle,
      uploadedByUserId: tUserId,
      uploadedByRole: tRole,
    );

    // assert
    expect(
      result,
      const Left<Failure, PackageDocumentEntity>(
        UploadFailure('Storage failed'),
      ),
    );
    verifyZeroInteractions(
      mockNotificationRepo,
    ); // notification not sent on failure
  });

  test('UploadFailure on file > 20 MB', () async {
    // arrange
    when(
      mockDocumentRepo.uploadDocument(
        localFilePath: anyNamed('localFilePath'),
        patientId: anyNamed('patientId'),
        patientPackageId: anyNamed('patientPackageId'),
        packageId: anyNamed('packageId'),
        clinicId: anyNamed('clinicId'),
        documentType: anyNamed('documentType'),
        title: anyNamed('title'),
        uploadedByUserId: anyNamed('uploadedByUserId'),
        uploadedByRole: anyNamed('uploadedByRole'),
        serviceId: anyNamed('serviceId'),
        description: anyNamed('description'),
      ),
    ).thenAnswer(
      (_) async => const Left<Failure, PackageDocumentEntity>(
        UploadFailure('File too large'),
      ),
    );

    // act
    final result = await usecase(
      localFilePath: 'huge_file.pdf',
      patientId: tPatientId,
      patientPackageId: tPatientPackageId,
      packageId: tPackageId,
      clinicId: tClinicId,
      documentType: tDocType,
      title: tTitle,
      uploadedByUserId: tUserId,
      uploadedByRole: tRole,
    );

    // assert
    expect(
      result,
      const Left<Failure, PackageDocumentEntity>(
        UploadFailure('File too large'),
      ),
    );
  });

  test('UploadFailure on unsupported type', () async {
    // arrange
    when(
      mockDocumentRepo.uploadDocument(
        localFilePath: anyNamed('localFilePath'),
        patientId: anyNamed('patientId'),
        patientPackageId: anyNamed('patientPackageId'),
        packageId: anyNamed('packageId'),
        clinicId: anyNamed('clinicId'),
        documentType: anyNamed('documentType'),
        title: anyNamed('title'),
        uploadedByUserId: anyNamed('uploadedByUserId'),
        uploadedByRole: anyNamed('uploadedByRole'),
        serviceId: anyNamed('serviceId'),
        description: anyNamed('description'),
      ),
    ).thenAnswer(
      (_) async => const Left<Failure, PackageDocumentEntity>(
        UploadFailure('Unsupported type'),
      ),
    );

    // act
    final result = await usecase(
      localFilePath: 'test.docx',
      patientId: tPatientId,
      patientPackageId: tPatientPackageId,
      packageId: tPackageId,
      clinicId: tClinicId,
      documentType: tDocType,
      title: tTitle,
      uploadedByUserId: tUserId,
      uploadedByRole: tRole,
    );

    // assert
    expect(
      result,
      const Left<Failure, PackageDocumentEntity>(
        UploadFailure('Unsupported type'),
      ),
    );
  });

  test('NetworkFailure on offline', () async {
    // arrange
    when(
      mockDocumentRepo.uploadDocument(
        localFilePath: anyNamed('localFilePath'),
        patientId: anyNamed('patientId'),
        patientPackageId: anyNamed('patientPackageId'),
        packageId: anyNamed('packageId'),
        clinicId: anyNamed('clinicId'),
        documentType: anyNamed('documentType'),
        title: anyNamed('title'),
        uploadedByUserId: anyNamed('uploadedByUserId'),
        uploadedByRole: anyNamed('uploadedByRole'),
        serviceId: anyNamed('serviceId'),
        description: anyNamed('description'),
      ),
    ).thenAnswer(
      (_) async =>
          const Left<Failure, PackageDocumentEntity>(NetworkFailure('Offline')),
    );

    // act
    final result = await usecase(
      localFilePath: tLocalPath,
      patientId: tPatientId,
      patientPackageId: tPatientPackageId,
      packageId: tPackageId,
      clinicId: tClinicId,
      documentType: tDocType,
      title: tTitle,
      uploadedByUserId: tUserId,
      uploadedByRole: tRole,
    );

    // assert
    expect(
      result,
      const Left<Failure, PackageDocumentEntity>(NetworkFailure('Offline')),
    );
  });
}
