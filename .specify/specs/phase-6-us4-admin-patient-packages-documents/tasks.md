# Phase 6 - US4: Admin Patient Packages & Document Upload
# Implementation Tasks

## 📋 Overview
This document breaks down Phase 6 implementation into actionable tasks following the order defined in the plan and checklist.

---

## Task T001: Setup & Infrastructure

**Priority**: HIGH
**Effort**: 2 hours
**Owner**: Development Team

### Description
Prepare the infrastructure and setup for Phase 6 implementation.

### Tasks
- [ ] **T001.1**: Create feature directory structure
  ```bash
  mkdir -p lib/features/admin/domain/entities
  mkdir -p lib/features/admin/domain/repositories
  mkdir -p lib/features/admin/domain/use_cases
  mkdir -p lib/features/admin/data/repositories
  mkdir -p lib/features/admin/data/datasources
  mkdir -p lib/features/admin/data/models
  mkdir -p lib/features/admin/presentation/providers
  mkdir -p lib/features/admin/presentation/screens
  mkdir -p lib/features/admin/presentation/widgets
  mkdir -p lib/features/admin/presentation/widgets/patient_package
  mkdir -p test/unit/features/admin/domain/use_cases
  mkdir -p test/widget/features/admin
  ```

- [ ] **T001.2**: Create entity files
  - `lib/features/admin/domain/entities/patient_package.dart`
  - `lib/features/admin/domain/entities/package_document.dart`
  - `lib/features/admin/domain/entities/package_service.dart`
  - `lib/features/admin/domain/entities/package_service_usage.dart`

- [ ] **T001.3**: Create repository interface
  - `lib/features/admin/domain/repositories/patient_package_repository.dart`

- [ ] **T001.4**: Run build_runner to generate mock classes
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

- [ ] **T001.5**: Verify no deprecation warnings
  ```bash
  flutter analyze lib/features/admin/
  ```

### Acceptance Criteria
- [ ] Directory structure created
- [ ] Entity files created with DartDoc
- [ ] Repository interface created
- [ ] Mocks generated
- [ ] No deprecation warnings

### Dependencies
- None

---

## Task T002: Domain Layer - Entities

**Priority**: HIGH
**Effort**: 3 hours
**Owner**: Development Team

### Description
Implement domain entities with proper serialization support.

### Tasks
- [ ] **T002.1**: Create PatientPackage entity
  - Define fields: id, patientId, packageType, services, servicesUsage, usedServicesCount, notes, documents, createdAt, updatedAt, isActive
  - Implement `fromJson` method
  - Implement `toJson` method
  - Implement `copyWith` method (if needed)
  - Add comprehensive DartDoc in Arabic and English

- [ ] **T002.2**: Create PackageDocument entity
  - Define fields: id, documentUrl, fileName, mimeType, fileSize, uploadedBy, uploadedAt, note
  - Implement `fromJson` and `toJson` methods
  - Implement `copyWith` method
  - Add comprehensive DartDoc

- [ ] **T002.3**: Create PackageService entity
  - Define fields: id, serviceName, description, price, durationMinutes
  - Implement serialization methods
  - Add DartDoc

- [ ] **T002.4**: Create PackageServiceUsage entity
  - Define fields: serviceId, usedAt, note
  - Implement serialization methods
  - Add DartDoc

- [ ] **T002.5**: Add @freezed annotation
  - Add `@freezed` annotation to all entities
  - Run build_runner
  - Verify generated code

### Acceptance Criteria
- [ ] All entities created with @freezed
- [ ] Serialization methods implemented
- [ ] DartDoc in Arabic and English
- [ ] No compilation errors
- [ ] Freezed code generated

### Dependencies
- T001

---

## Task T003: Domain Layer - Repository Interface

**Priority**: HIGH
**Effort**: 1.5 hours
**Owner**: Development Team

### Description
Define the repository interface for patient package operations.

### Tasks
- [ ] **T003.1**: Create repository interface
  - `lib/features/admin/domain/repositories/patient_package_repository.dart`
  - Define method: `Future<Either<Failure, List<PatientPackage>>> getPackagesForAdmin(String patientId)`
  - Define method: `Future<Either<Failure, PackageDocument>> uploadDocument(String packageId, File file, String note)`
  - Define method: `Future<Either<Failure, Unit>> updateServiceUsage(String packageId, PackageServiceUsage usage)`
  - Add comprehensive DartDoc

- [ ] **T003.2**: Add type aliases for Either and Failure
  ```dart
  import 'package:dartz/dartz.dart';
  import 'package:elajtech/core/errors/failures.dart';
  ```

- [ ] **T003.3**: Document error scenarios
  - Document network failures
  - Document validation failures
  - Document permission failures
  - Document transaction failures

### Acceptance Criteria
- [ ] Repository interface created
- [ ] All methods defined
- [ ] Return types are Either<Failure, T>
- [ ] DartDoc in Arabic and English
- [ ] No compilation errors

### Dependencies
- T001, T002

---

## Task T004: Data Layer - Remote Datasource

**Priority**: HIGH
**Effort**: 3 hours
**Owner**: Development Team

### Description
Implement remote data source for Firestore operations.

### Tasks
- [ ] **T004.1**: Create remote datasource interface
  - Define methods for fetching packages
  - Define methods for uploading documents
  - Define methods for updating usage
  - Add comprehensive DartDoc

- [ ] **T004.2**: Create remote datasource implementation
  - Use `databaseId: 'elajtech'` for Firestore
  - Implement `getPackagesForAdmin`:
    - Query `patient_packages` collection
    - Filter by patientId
    - Return list of PatientPackageModel
  - Implement `uploadDocument`:
    - Upload to Storage with metadata
    - Return PackageDocumentModel
  - Implement `updateServiceUsage`:
    - Use Firestore transaction
    - Update servicesUsage array
    - Update usedServicesCount
  - Add diagnostic logging (debugPrint)

- [ ] **T004.3**: Implement transaction logic
  ```dart
  await firestore.runTransaction(async (transaction) async {
    final packageRef = firestore.collection('patient_packages').doc(packageId);
    final packageDoc = await transaction.get(packageRef);

    if (!packageDoc.exists) {
      throw ServerFailure('Package not found');
    }

    final data = packageDoc.data()! as Map<String, dynamic>;
    final servicesUsage = List<dynamic>.from(data['servicesUsage'] ?? []);

    servicesUsage.add(usage.toJson());

    transaction.update(packageRef, {
      'servicesUsage': servicesUsage,
      'usedServicesCount': servicesUsage.length,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  });
  ```

- [ ] **T004.4**: Add error handling
  - Catch FirebaseException
  - Catch StorageException
  - Catch generic exceptions
  - Return appropriate Failure

### Acceptance Criteria
- [ ] Datasource interface created
- [ ] Datasource implementation created
- [ ] Firestore uses databaseId: 'elajtech'
- [ ] Transactions implemented for atomic updates
- [ ] Diagnostic logging added
- [ ] Error handling implemented
- [ ] DartDoc in Arabic and English

### Dependencies
- T001, T003

---

## Task T005: Data Layer - Models

**Priority**: HIGH
**Effort**: 2 hours
**Owner**: Development Team

### Description
Implement data models with JSON serialization.

### Tasks
- [ ] **T005.1**: Create PatientPackageModel
  - Add @JsonSerializable annotation
  - Implement fromJson and toJson
  - Implement fromFirestore method with snapshot validation
  - Add comprehensive DartDoc

- [ ] **T005.2**: Create PackageDocumentModel
  - Add @JsonSerializable annotation
  - Implement fromJson and toJson
  - Add comprehensive DartDoc

- [ ] **T005.3**: Create PackageServiceModel
  - Add @JsonSerializable annotation
  - Implement fromJson and toJson
  - Add comprehensive DartDoc

- [ ] **T005.4**: Create PackageServiceUsageModel
  - Add @JsonSerializable annotation
  - Implement fromJson and toJson
  - Add comprehensive DartDoc

- [ ] **T005.5**: Run build_runner to generate serialization code
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

### Acceptance Criteria
- [ ] All models created with @JsonSerializable
- [ ] Serialization methods implemented
- [ ] Snapshot validation in fromFirestore
- [ ] DartDoc in Arabic and English
- [ ] Build runner completed successfully

### Dependencies
- T002

---

## Task T006: Data Layer - Repository Implementation

**Priority**: HIGH
**Effort**: 3 hours
**Owner**: Development Team

### Description
Implement the repository implementation using remote datasource.

### Tasks
- [ ] **T006.1**: Create repository implementation
  ```dart
  @LazySingleton(as: PatientPackageRepository)
  class PatientPackageRepositoryImpl implements PatientPackageRepository {
    PatientPackageRepositoryImpl(this._remoteDataSource);
    final PatientPackageRemoteDataSource _remoteDataSource;

    @override
    Future<Either<Failure, List<PatientPackage>>> getPackagesForAdmin(String patientId) async {
      try {
        final result = await _remoteDataSource.getPackagesForAdmin(patientId);
        return result.fold(
          (failure) => Left(failure),
          (models) => Right(models.map((model) => model.toDomain()).toList()),
        );
      } on FirebaseException catch (e) {
        return Left(ServerFailure(e.message ?? 'فشل في جلب الحزم'));
      } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }

    @override
    Future<Either<Failure, PackageDocument>> uploadDocument(String packageId, File file, String note) async {
      try {
        final result = await _remoteDataSource.uploadDocument(packageId, file, note);
        return result.fold(
          (failure) => Left(failure),
          (model) => Right(model.toDomain()),
        );
      } on FirebaseException catch (e) {
        return Left(ServerFailure(e.message ?? 'فشل في رفع المستند'));
      } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }

    @override
    Future<Either<Failure, Unit>> updateServiceUsage(String packageId, PackageServiceUsage usage) async {
      try {
        await _remoteDataSource.updateServiceUsage(packageId, usage);
        return const Right(unit);
      } on FirebaseException catch (e) {
        return Left(ServerFailure(e.message ?? 'فشل في تحديث الاستخدام'));
      } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }
  }
  ```

- [ ] **T006.2**: Add dependency injection with @injectable
  - Add @LazySingleton annotation
  - Register in DI container
  - Run build_runner

- [ ] **T006.3**: Add diagnostic logging
  ```dart
  if (kDebugMode) {
    debugPrint('Fetching packages for admin: patientId=$patientId');
    debugPrint('Documents uploaded: packageId=$packageId, fileName=${file.path.split('/').last}');
    debugPrint('Service usage updated: packageId=$packageId, serviceId=${usage.serviceId}');
  }
  ```

- [ ] **T006.4**: Add error handling
  - Handle file size validation
  - Handle file type validation
  - Handle network errors
  - Handle permission errors

### Acceptance Criteria
- [ ] Repository implementation created
- [ ] All methods implemented
- [ ] @injectable annotation added
- [ ] Dependency injection registered
- [ ] Diagnostic logging added
- [ ] Error handling implemented
- [ ] DartDoc in Arabic and English
- [ ] No compilation errors

### Dependencies
- T004, T005

---

## Task T007: Presentation - State Management

**Priority**: HIGH
**Effort**: 4 hours
**Owner**: Development Team

### Description
Implement state management providers for admin patient packages.

### Tasks
- [ ] **T007.1**: Create GetPatientPackagesForAdminUseCase
  - Accept PatientPackageRepository as dependency
  - Implement the use case
  - Add comprehensive DartDoc

- [ ] **T007.2**: Create UploadPackageDocumentUseCase
  - Accept PatientPackageRepository as dependency
  - Implement file validation logic
  - Implement upload logic
  - Add comprehensive DartDoc

- [ ] **T007.3**: Create UpdatePackageServiceUsageUseCase
  - Accept PatientPackageRepository as dependency
  - Implement transaction logic
  - Add comprehensive DartDoc

- [ ] **T007.4**: Create adminPatientPackagesProvider
  - Use AsyncNotifier
  - State: packages, isLoading, error
  - Load packages on initialization
  - Add comprehensive DartDoc
  - Add state management logic
  - Add error handling

- [ ] **T007.5**: Create uploadDocumentProvider
  - Use AsyncNotifier
  - State: uploadProgress, isUploading, error
  - Upload document method
  - Cancel upload method (if needed)
  - Add comprehensive DartDoc
  - Add state management logic
  - Add error handling

- [ ] **T007.6**: Register providers with Riverpod
  - Use @riverpod annotation
  - Register in DI container
  - Run build_runner

### Acceptance Criteria
- [ ] All use cases created
- [ ] All providers created
- [ ] @riverpod annotation added
- [ ] State management logic implemented
- [ ] Error handling implemented
- [ ] DartDoc in Arabic and English
- [ ] No compilation errors

### Dependencies
- T006

---

## Task T008: Presentation - UI Components

**Priority**: HIGH
**Effort**: 8 hours
**Owner**: Development Team

### Description
Implement UI components for admin patient packages.

### Tasks
- [ ] **T008.1**: Create DocumentUploadBottomSheet
  - Accept packageId as parameter
  - Implement file picker integration
  - Implement file validation UI
  - Implement upload progress UI
  - Implement Arabic error messages
  - Add validation logic:
    - Size ≤ 20 MB
    - Type ∈ {pdf, jpg, jpeg, png}
  - Add FCM call (best-effort, non-blocking)
  - Add comprehensive DartDoc

- [ ] **T008.2**: Create PackageDocumentListItem
  - Display document thumbnail (if applicable)
  - Display document name
  - Display document size
  - Display upload date
  - Implement tap to view details
  - Add comprehensive DartDoc

- [ ] **T008.3**: Create AdminPatientPackageContextView
  - Display package name
  - Display patient ID
  - Display services list
  - Display usage statistics
  - Display notes field (admin only)
  - Display documents list
  - Display upload button
  - Add comprehensive DartDoc
  - Implement error handling
  - Implement loading states

- [ ] **T008.4**: Create AdminPatientPackagesPage
  - Accept patientId as parameter
  - Display package list
  - Display loading skeleton
  - Display empty state
  - Display error state with retry
  - Display refresh button
  - Add navigation logic
  - Add comprehensive DartDoc

- [ ] **T008.5**: Implement file picker
  - Use image_picker package
  - Accept pdf and image files
  - Validate file type before selection
  - Validate file size before selection
  - Add comprehensive DartDoc

- [ ] **T008.6**: Implement upload UI
  - Show progress bar
  - Show upload percentage
  - Show success message
  - Show error message
  - Add comprehensive DartDoc

### Acceptance Criteria
- [ ] All UI components created
- [ ] All components have DartDoc
- [ ] Arabic error messages implemented
- [ ] File validation implemented
- [ ] Upload progress shown
- [ ] Loading states implemented
- [ ] Empty states implemented
- [ ] Error handling implemented
- [ ] No deprecated APIs
- [ ] No compilation errors

### Dependencies
- T007

---

## Task T009: Testing - Unit Tests

**Priority**: HIGH
**Effort**: 5 hours
**Owner**: Development Team

### Description
Implement comprehensive unit tests for domain use cases.

### Tasks
- [ ] **T009.1**: Create test file structure
  ```
  test/unit/features/admin/domain/use_cases/
  ├── get_patient_packages_for_admin_use_case_test.dart
  ├── upload_package_document_use_case_test.dart
  └── update_package_service_usage_use_case_test.dart
  ```

- [ ] **T009.2**: Test GetPatientPackagesForAdminUseCase
  - Happy path test
  - Empty packages test
  - Invalid patient ID test
  - Network error test
  - Repository method call verification

- [ ] **T009.3**: Test UploadPackageDocumentUseCase
  - Happy path test with valid file
  - File size validation test (> 20 MB)
  - File type validation test (invalid types)
  - Network error test
  - Validation logic tests

- [ ] **T009.4**: Test UpdatePackageServiceUsageUseCase
  - Happy path test
  - Transaction success test
  - Transaction conflict test
  - Network error test
  - Edge cases test

- [ ] **T009.5**: Add test coverage
  - Aim for ≥ 80% coverage
  - Test happy paths
  - Test edge cases
  - Test failure modes

### Acceptance Criteria
- [ ] All unit tests created
- [ ] All tests passing
- [ ] Coverage ≥ 80%
- [ ] Test naming follows convention
- [ ] No test regressions

### Dependencies
- T006, T007

---

## Task T010: Testing - Widget Tests

**Priority**: HIGH
**Effort**: 6 hours
**Owner**: Development Team

### Description
Implement comprehensive widget tests for UI components.

### Tasks
- [ ] **T010.1**: Create test file structure
  ```
  test/widget/features/admin/
  ├── admin_patient_packages_page_test.dart
  ├── admin_patient_package_context_view_test.dart
  ├── document_upload_bottom_sheet_test.dart
  └── package_document_list_item_test.dart
  ```

- [ ] **T010.2**: Test AdminPatientPackagesPage
  - Happy path test
  - Empty state test
  - Loading state test
  - Error state test with retry
  - Tap to view details test
  - Refresh button test

- [ ] **T010.3**: Test AdminPatientPackageContextView
  - Happy path test
  - Notes field visible test (admin role)
  - Notes field hidden test (patient role)
  - Services list test
  - Usage statistics test
  - Upload button test

- [ ] **T010.4**: Test DocumentUploadBottomSheet
  - Happy path test
  - File picker opening test
  - File preview test
  - File validation test (size)
  - File validation test (type)
  - Upload progress test
  - Upload success test
  - Upload error test
  - Cancel button test

- [ ] **T010.5**: Test PackageDocumentListItem
  - Render test
  - Tap to view test
  - Display content test

- [ ] **T010.6**: Add test coverage
  - Aim for ≥ 80% coverage
  - Test all interactions
  - Test all states
  - Test accessibility

### Acceptance Criteria
- [ ] All widget tests created
- [ ] All tests passing
- [ ] Coverage ≥ 80%
- [ ] Widget interactions tested
- [ ] No test regressions

### Dependencies
- T008

---

## Task T011: Manual Testing

**Priority**: HIGH
**Effort**: 4 hours
**Owner**: Development Team + QA

### Description
Perform manual QA testing for Phase 6 features.

### Tasks
- [ ] **T011.1**: Test admin patient packages viewing
  - Test viewing all packages
  - Test filtering/searching
  - Test package details
  - Test loading states
  - Test error states

- [ ] **T011.2**: Test document upload
  - Test uploading valid files (PDF, JPG, PNG)
  - Test file size validation (> 20 MB)
  - Test file type validation (invalid types)
  - Test upload progress
  - Test upload success
  - Test upload error handling
  - Test error messages in Arabic

- [ ] **T011.3**: Test atomic updates
  - Test transaction success
  - Test transaction conflict
  - Test concurrent updates
  - Test no data loss

- [ ] **T011.4**: Test notes visibility
  - Test notes visible to admin
  - Test notes visible to doctor
  - Test notes hidden from patient
  - Test notes security

- [ ] **T011.5**: Test offline scenarios
  - Test with WiFi
  - Test with Mobile data
  - Test with 3G
  - Test network interruption
  - Test network reconnection

- [ ] **T011.6**: Test file picker
  - Test file picker opening
  - Test valid file selection
  - Test invalid file rejection
  - Test file preview

### Acceptance Criteria
- [ ] All manual test scenarios passing
- [ ] No critical bugs found
- [ ] User experience is smooth
- [ ] Error messages are clear and in Arabic

### Dependencies
- T009, T010

---

## Task T012: Documentation

**Priority**: MEDIUM
**Effort**: 2 hours
**Owner**: Development Team

### Description
Complete all documentation for Phase 6.

### Tasks
- [ ] **T012.1**: Update code documentation
  - Ensure all public classes have DartDoc
  - Ensure all public methods have DartDoc
  - Ensure bilingual comments
  - Ensure usage examples provided

- [ ] **T012.2**: Create API documentation (if needed)
  - Document repository methods
  - Document use case inputs/outputs
  - Document provider methods

- [ ] **T012.3**: Update README (if needed)
  - Document new feature
  - Document new screens
  - Document new use cases

- [ ] **T012.4**: Document security rules
  - Document notes visibility rules
  - Document file validation rules
  - Document atomic update rules

### Acceptance Criteria
- [ ] All code documented
- [ ] All DartDoc complete
- [ ] All documentation in Arabic and English

### Dependencies
- All previous tasks

---

## Task T013: Final Verification

**Priority**: HIGH
**Effort**: 2 hours
**Owner**: Development Team

### Description
Perform final verification before merging.

### Tasks
- [ ] **T013.1**: Run all tests
  ```bash
  flutter test
  flutter test test/unit/features/admin/domain/use_cases/ --coverage
  flutter test test/widget/features/admin/ --coverage
  ```

- [ ] **T013.2**: Run flutter analyze
  ```bash
  flutter analyze
  flutter analyze lib/features/admin/ --no-fatal-infos
  ```

- [ ] **T013.3**: Run build_runner
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

- [ ] **T013.4**: Check for deprecated APIs
  ```bash
  flutter analyze lib/ | grep deprecated_member_use
  ```

- [ ] **T013.5**: Verify Firestore database ID
  ```bash
  grep -r "databaseId.*elajtech" lib/features/admin/
  ```

- [ ] **T013.6**: Verify transaction usage
  ```bash
  grep -r "runTransaction" lib/features/admin/
  ```

- [ ] **T013.7**: Verify file validation
  ```bash
  grep -r "20 MB" lib/features/admin/
  grep -r "pdf\|jpg\|jpeg\|png" lib/features/admin/data/
  ```

- [ ] **T013.8**: Verify notes visibility
  ```bash
  grep -r "notes" lib/features/admin/data/datasources/
  grep -r "notes" lib/features/admin/presentation/
  ```

### Acceptance Criteria
- [ ] All tests passing
- [ ] No flutter analyze errors
- [ ] No deprecated API warnings
- [ ] Database ID rule followed
- [ ] Transaction usage confirmed
- [ ] File validation confirmed
- [ ] Notes visibility confirmed

### Dependencies
- T011, T012

---

## Task T014: Code Review & Merge

**Priority**: HIGH
**Effort**: 1 hour
**Owner**: Development Team + Reviewer

### Description
Prepare code for review and merge.

### Tasks
- [ ] **T014.1**: Create pull request
  - Branch: `feature/phase-6-us4-admin-patient-packages-documents`
  - Include all changes
  - Add comprehensive description

- [ ] **T014.2**: Prepare review artifacts
  - Test results
  - Coverage report
  - Screenshots (if applicable)
  - Migration notes (if any)

- [ ] **T014.3**: Address review comments
  - Review code changes
  - Address all comments
  - Run tests again
  - Update documentation

- [ ] **T014.4**: Merge to main
  - Wait for approval
  - Merge to develop
  - Update CHANGELOG

### Acceptance Criteria
- [ ] Pull request created
- [ ] All review comments addressed
- [ ] All tests passing
- [ ] Merge completed successfully

### Dependencies
- T013

---

## 📊 Task Summary

| Task | Description | Effort | Priority | Dependencies |
|------|-------------|--------|----------|--------------|
| T001 | Setup & Infrastructure | 2h | HIGH | None |
| T002 | Domain Layer - Entities | 3h | HIGH | T001 |
| T003 | Domain Layer - Repository Interface | 1.5h | HIGH | T001, T002 |
| T004 | Data Layer - Remote Datasource | 3h | HIGH | T001, T003 |
| T005 | Data Layer - Models | 2h | HIGH | T002 |
| T006 | Data Layer - Repository Implementation | 3h | HIGH | T004, T005 |
| T007 | Presentation - State Management | 4h | HIGH | T006 |
| T008 | Presentation - UI Components | 8h | HIGH | T007 |
| T009 | Testing - Unit Tests | 5h | HIGH | T006, T007 |
| T010 | Testing - Widget Tests | 6h | HIGH | T008 |
| T011 | Manual Testing | 4h | HIGH | T009, T010 |
| T012 | Documentation | 2h | MEDIUM | All previous |
| T013 | Final Verification | 2h | HIGH | T011, T012 |
| T014 | Code Review & Merge | 1h | HIGH | T013 |

**Total Estimated Effort**: 42.5 hours

---

## 🚀 Execution Order

```
Phase 6 Implementation Sequence:
═════════════════════════════════════════════════════════════
T001 → T002 → T003 → T004 → T005 → T006 → T007 → T008
═════════════════════════════════════════════════════════════
         ↓
═════════════════════════════════════════════════════════════
T009 (Unit Tests) → T010 (Widget Tests)
═════════════════════════════════════════════════════════════
         ↓
═════════════════════════════════════════════════════════════
T011 (Manual Testing) → T012 (Documentation) → T013 (Verification)
═════════════════════════════════════════════════════════════
         ↓
═════════════════════════════════════════════════════════════
T014 (Code Review & Merge)
═════════════════════════════════════════════════════════════
```

---

## ✅ Task Completion Checklist

```
Phase 6 - US4 Implementation Status
═════════════════════════════════════════════════════════════

Domain Layer
    [ ] T001: Setup & Infrastructure
    [ ] T002: Entities
    [ ] T003: Repository Interface

Data Layer
    [ ] T004: Remote Datasource
    [ ] T005: Models
    [ ] T006: Repository Implementation

Presentation Layer
    [ ] T007: State Management
    [ ] T008: UI Components

Testing
    [ ] T009: Unit Tests
    [ ] T010: Widget Tests
    [ ] T011: Manual Testing

Finalization
    [ ] T012: Documentation
    [ ] T013: Final Verification
    [ ] T014: Code Review & Merge

═════════════════════════════════════════════════════════════
Phase 6 Progress: 0/14 Tasks Completed
═════════════════════════════════════════════════════════════
```

---

**Version**: 1.0.0
**Created**: 2026-03-08
**Author**: OpenCode Agent
**Status**: Ready for Implementation
