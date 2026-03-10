# Phase 6 - US4: Admin Patient Packages & Document Upload
# Verification & QA Plan

## 📋 Overview

**Feature**: Admin Patient Packages Management with Document Upload capability
**Scope**: Admin-only interface to view patient packages, upload documents, and track service usage
**Verification Phase**: Phase 6

---

## 1️⃣ Test Matrix

### 1.1 Components to Test

| Component | Type | Test Scenarios |
|-----------|------|----------------|
| **GetPatientPackagesForAdminUseCase** | Use Case (Domain) | • Happy path: Fetch packages for valid patient ID<br>• Edge: Patient ID not found<br>• Edge: No packages available<br>• Edge: Invalid patient ID format<br>• Failure: Network timeout during fetch |
| **UploadPackageDocumentUseCase** | Use Case (Domain) | • Happy path: Upload valid PDF/ image<br>• Edge: File > 20 MB<br>• Edge: Invalid file type (txt, doc, exe)<br>• Edge: Empty file<br>• Failure: Network error<br>• Failure: Storage quota exceeded |
| **UpdatePackageServiceUsageUseCase** | Use Case (Domain) | • Happy path: Update usage with transaction<br>• Edge: Multiple concurrent updates<br>• Edge: Update with missing services list<br>• Failure: Transaction conflict<br>• Failure: Firestore write permission denied |
| **adminPatientPackagesProvider** | State Management | • Happy: Load packages on init<br>• Edge: Loading state persistence<br>• Edge: Error state handling<br>• Edge: Auto-refresh after upload |
| **uploadDocumentProvider** | State Management | • Happy: Upload progress tracking<br>• Edge: Cancel during upload<br>• Edge: Multiple uploads<br>• Failure: Upload cancel with error handling |
| **AdminPatientPackagesPage** | Widget (Screen) | • Happy: Display packages list<br>• Edge: Empty state<br>• Edge: Loading skeleton<br>• Edge: Error state with retry<br>• Interaction: Tap on package opens details |
| **AdminPatientPackageContextView** | Widget | • Happy: Display package details<br>• Happy: Show notes field<br>• Happy: Show usage statistics<br>• Edge: Missing notes field (R2 verification)<br>• Edge: Missing services list |
| **DocumentUploadBottomSheet** | Widget | • Happy: Show upload sheet<br>• Happy: File picker selection<br>• Happy: Valid file shows preview<br>• Edge: Invalid file shows error<br>• Edge: Cancel button works<br>• Interaction: Upload button triggers upload |

### 1.2 Test Distribution

```
┌─────────────────────────────────────────────────────────┐
│                    Test Distribution                      │
├─────────────────────────────────────────────────────────┤
│  Unit Tests (Use Cases)         │  6-8 tests            │
│  └─ Domain logic verification   │  └─ Business rules    │
├─────────────────────────────────────────────────────────┤
│  Widget Tests (UI Components)   │  10-15 tests           │
│  └─ Screen and widget coverage  │  └─ User interactions │
├─────────────────────────────────────────────────────────┤
│  Integration Tests (Manual)     │  5-7 scenarios        │
│  └─ Firestore and Storage       │  └─ E2E flows         │
└─────────────────────────────────────────────────────────┘
```

---

## 2️⃣ Automated Checks

### 2.1 Unit Tests

#### Test Files to Create/Update:
```
test/unit/features/admin/domain/use_cases/
├── get_patient_packages_for_admin_use_case_test.dart
├── upload_package_document_use_case_test.dart
└── update_package_service_usage_use_case_test.dart
```

#### Flutter Test Commands:

```bash
# Run all US4 unit tests
flutter test test/unit/features/admin/domain/use_cases/

# Run with verbose output
flutter test test/unit/features/admin/domain/use_cases/ --reporter expanded

# Run specific use case test
flutter test test/unit/features/admin/domain/use_cases/get_patient_packages_for_admin_use_case_test.dart
flutter test test/unit/features/admin/domain/use_cases/upload_package_document_use_case_test.dart
flutter test test/unit/features/admin/domain/use_cases/update_package_service_usage_use_case_test.dart

# Run with coverage
flutter test test/unit/features/admin/domain/use_cases/ --coverage
```

**Test Structure Example**:
```dart
// get_patient_packages_for_admin_use_case_test.dart
group('GetPatientPackagesForAdminUseCase', () {
  late GetPatientPackagesForAdminUseCase useCase;
  late MockPatientPackageRepository mockRepository;

  setUp(() {
    mockRepository = MockPatientPackageRepository();
    useCase = GetPatientPackagesForAdminUseCase(repository: mockRepository);
  });

  test('happy_path_valid_patientId_returns_packages', () async {
    // Arrange
    const patientId = 'patient_123';
    final expectedPackages = [MockPatientPackageModel()];

    when(mockRepository.getPackagesForAdmin(patientId))
      .thenAnswer((_) async => Right(expectedPackages));

    // Act
    final result = await useCase(patientId);

    // Assert
    expect(result.isRight(), true);
    result.fold(
      (failure) => fail('Should return Right'),
      (packages) => expect(packages, equals(expectedPackages)),
    );

    verify(mockRepository.getPackagesForAdmin(patientId));
  });

  test('edge_case_no_packages_returns_empty_list', () async {
    // Implementation for empty packages case
  });

  test('failure_case_network_error_returns_server_failure', () async {
    // Implementation for network failure
  });
});
```

### 2.2 Widget Tests

#### Test Files to Create:
```
test/widget/features/admin/
├── admin_patient_packages_page_test.dart
├── admin_patient_package_context_view_test.dart
└── document_upload_bottom_sheet_test.dart
```

#### Flutter Test Commands:

```bash
# Run all US4 widget tests
flutter test test/widget/features/admin/

# Run with verbose output
flutter test test/widget/features/admin/ --reporter expanded

# Run specific widget test
flutter test test/widget/features/admin/admin_patient_packages_page_test.dart

# Run with golden test snapshots
flutter test test/widget/features/admin/ --update-goldens
```

**Test Structure Example**:
```dart
// admin_patient_packages_page_test.dart
void main() {
  group('AdminPatientPackagesPage', () {
    late MockAdminPatientPackagesProvider mockProvider;

    setUp(() {
      mockProvider = MockAdminPatientPackagesProvider();
      when(mockProvider.packages).thenReturn([]);
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.error).thenReturn(null);
    });

    testWidgets('happy_path_displays_packages_list', (tester) async {
      // Arrange
      const expectedPackages = [MockPatientPackageModel()];
      when(mockProvider.packages).thenReturn(expectedPackages);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminPatientPackagesProvider.overrideWith((ref) => mockProvider),
          ],
          child: const MaterialApp(
            home: AdminPatientPackagesPage(patientId: 'patient_123'),
          ),
        ),
      );

      // Assert
      expect(find.text('patient_packages'), findsOneWidget);
      expect(find.byType(AdminPatientPackageContextView), findsOneWidget);
    });

    testWidgets('edge_case_empty_state_shows_empty_view', (tester) async {
      // Implementation for empty state
    });

    testWidgets('edge_case_loading_shows_skeleton', (tester) async {
      // Implementation for loading state
    });

    testWidgets('failure_case_error_shows_retry_button', (tester) async {
      // Implementation for error state
    });
  });
}
```

### 2.3 Integration & Manual Tests

#### Manual Test Scenarios:
```
test/integration/admin_patient_packages/
├── README.md - Integration test execution guide
├── verify_document_upload_flow_test.dart
└── verify_notes_isolation_test.dart
```

#### Commands:
```bash
# Run integration tests
flutter test test/integration/admin_patient_packages/ --dart-define=INTEGRATION_TEST=true
```

### 2.4 Static Analysis

#### Commands:
```bash
# Run flutter analyze
flutter analyze

# Run with strict warnings
flutter analyze --no-fatal-infos

# Check for specific issues
flutter analyze lib/features/admin/ --no-fatal-infos

# Generate dartdocs for US4 components
flutter pub run dartdoc lib/features/admin/
```

**Expected Output**: No errors, no warnings, no info messages related to US4.

---

## 3️⃣ Firestore & Storage Verification

### 3.1 Firestore Document Verification

#### Test Steps:

1. **Document Structure Check**:
   ```dart
   // Verify patient_package document structure
   final package = await firestore
     .collection('patient_packages')
     .doc('package_123')
     .get();

   final data = package.data()!;

   // Verify fields
   expect(data.containsKey('patientId'), true);
   expect(data.containsKey('notes'), true);
   expect(data.containsKey('servicesUsage'), true);
   expect(data.containsKey('usedServicesCount'), true);
   expect(data.containsKey('documentUrl'), true);
   ```

2. **Notes Field Visibility**:
   - **Admin Flow**: `notes` field MUST be visible
   - **Patient Flow**: `notes` field MUST be hidden (R2 requirement)

3. **servicesUsage Atomic Update**:
   ```dart
   // Verify transaction is used for update
   await firestore.runTransaction(async (transaction) async {
     final packageRef = firestore.collection('patient_packages').doc('package_123');
     final packageDoc = await transaction.get(packageRef);

     final currentData = packageDoc.data()! as Map<String, dynamic>;
     final newServices = [...(currentData['servicesUsage'] as List)];

     transaction.update(packageRef, {
       'servicesUsage': newServices,
       'usedServicesCount': newServices.length,
     });
   });
   ```

#### Verification Commands:

```bash
# Verify documents in Firestore emulator
firebase firestore:export ./firestore-export --project elajtech

# Check document structure manually
# 1. Start Firestore emulator
firebase emulators:start

# 2. In another terminal, run queries
# 3. Check document structure with Firestore console
```

### 3.2 Storage Verification

#### Storage Path Structure:
```
/patient_packages/{packageId}/{documentId}
├── 2026-03-08-abc123.pdf
├── 2026-03-08-def456.jpg
└── 2026-03-08-ghi789.png
```

#### File Validation Rules:
| Rule | Value | Test Method |
|------|-------|-------------|
| **Max Size** | 20 MB | Try upload > 20 MB, expect error |
| **Valid Types** | pdf, jpg, jpeg, png | Test each valid type |
| **Invalid Types** | txt, doc, exe, zip | Test each invalid type |
| **Metadata** | Type, Size, UploadedBy | Verify stored correctly |

#### Verification Steps:

1. **Storage Path Check**:
   ```dart
   final uploadTask = ref.uploadFile(
     '/patient_packages/${packageId}/${documentId}',
     file,
     metadata: SettableMetadata(
       contentType: mimeType,
       customMetadata: {
         'uploadBy': 'admin_123',
         'uploadedAt': Timestamp.now().toString(),
       },
     ),
   );
   ```

2. **FCM Best-Effort Verification**:
   - Verify FCM is called but not awaited
   - Expect `Future<void>` return type
   - Test in offline mode: FCM should fail gracefully

### 3.3 Atomic Transaction Verification

#### Test Scenario: Concurrent Updates

```dart
// Scenario: Two admins update same package simultaneously
// Expected: No data loss, transaction should succeed for one, fail for other

// Test steps:
1. Open package in two admin windows
2. Simultaneously trigger document uploads
3. Verify only one succeeds, other fails with conflict
4. Verify servicesUsage is not corrupted
```

---

## 4️⃣ Manual QA Scenarios

### 4.1 Admin User Flow

#### Scenario 1: View Patient Packages List
```
Steps:
1. Login as admin user
2. Navigate to Patient Packages screen
3. Verify package list is displayed

Expected Results:
✓ List shows all patient packages
✓ Each item shows patient ID and package name
✓ Loading skeleton appears during fetch
✓ Empty state shown if no packages exist
✓ Error message with retry button shown on failure

QA Notes:
- Test with valid patient ID
- Test with invalid patient ID
- Test with network disconnected
```

#### Scenario 2: Open Package Details
```
Steps:
1. Tap on a package in the list
2. Verify package details are displayed

Expected Results:
✓ Package name displayed
✓ Patient ID displayed
✓ Services list shown
✓ Usage statistics visible
✓ Notes field visible (admin-only)
✓ Upload document button available

QA Notes:
- Verify notes field is NOT visible in patient UI (R2)
- Test with package having no notes
- Test with package having long notes
```

#### Scenario 3: Upload Valid Document
```
Steps:
1. Open package details
2. Tap "Upload Document" button
3. Select PDF file (≤ 20 MB)
4. Verify upload progress
5. Verify document appears in list

Expected Results:
✓ Document upload bottom sheet appears
✓ File picker opens
✓ Selected file shows preview
✓ Upload progress bar visible
✓ Document appears in package after completion
✓ Success message shown
✓ Document visible to both admin and patient

File Types to Test:
- PDF (valid)
- JPG (valid)
- PNG (valid)

File Size Limits:
- 1 MB (should succeed)
- 15 MB (should succeed)
- 20 MB (boundary test)
- 21 MB (should fail)

QA Notes:
- Test with different file types
- Test with very small file (1 KB)
- Test with exactly 20 MB file
- Verify file path format
```

#### Scenario 4: Upload Invalid Document
```
Steps:
1. Tap "Upload Document" button
2. Select file > 20 MB or invalid type

Expected Results:
✓ App shows Arabic error message
✓ Error message is clear and specific
✓ Upload is cancelled automatically
✓ No file is uploaded to Storage

Error Messages to Verify:
- "حجم الملف كبير جداً (الحد الأقصى: 20 ميجابايت)" (File too large)
- "نوع الملف غير مدعوم. يرجى اختيار PDF أو صورة" (Invalid file type)

Invalid Types:
- .txt
- .doc
- .exe
- .zip
- .html

QA Notes:
- Verify error message is in Arabic
- Verify error message is user-friendly
- Test error message appears instantly
```

#### Scenario 5: Refresh and Verify
```
Steps:
1. Upload a document
2. Navigate back to package list
3. Tap refresh button
4. Verify document is still visible

Expected Results:
✓ List refreshes successfully
✓ Document remains in the list
✓ No duplicate documents
✓ Loading indicator appears briefly
✓ Error shown if network disconnected

QA Notes:
- Test refresh after successful upload
- Test refresh after failed upload
- Test refresh with offline network
- Test with multiple packages
```

#### Scenario 6: Notes Field Verification (R2)
```
Steps:
1. Open package as admin (should see notes)
2. Navigate to patient view (mock or real patient account)
3. Verify notes are hidden

Expected Results:
✓ Admin view: notes field visible
✓ Patient view: notes field NOT visible
✓ No API calls for notes from patient side
✓ Patient cannot see notes even with correct permissions

QA Notes:
- This is a critical regression test
- Test in both Android and iOS
- Verify notes are not in GraphQL query for patient
- Verify notes are not in JSON response for patient
```

### 4.2 Integration Testing Checklist

```
[ ] Admin can view patient packages list
[ ] Admin can open package details
[ ] Admin can upload valid documents
[ ] Admin can see upload progress
[ ] Admin can verify document appears
[ ] Document is visible to patient
[ ] Invalid files show Arabic error messages
[ ] Files > 20 MB are rejected
[ ] Upload is atomic with Firestore transaction
[ ] servicesUsage is correctly updated
[ ] usedServicesCount matches servicesUsage length
[ ] Notes are visible to admin
[ ] Notes are hidden from patient
[ ] FCM is called (best-effort, non-blocking)
[ ] Offline mode works correctly
[ ] Refresh functionality works
[ ] Error handling is comprehensive
[ ] Loading states are appropriate
[ ] Empty states are displayed
[ ] Retry mechanism works on failure
```

---

## 5️⃣ Exit Criteria for Phase 6

### 5.1 Test Coverage Checklist

```
[ ] All Unit Tests Passing
    - GetPatientPackagesForAdminUseCase: 3-5 tests
    - UploadPackageDocumentUseCase: 4-6 tests
    - UpdatePackageServiceUsageUseCase: 3-5 tests
    - Total: 10-16 unit tests

[ ] All Widget Tests Passing
    - AdminPatientPackagesPage: 4-6 tests
    - AdminPatientPackageContextView: 3-4 tests
    - DocumentUploadBottomSheet: 5-7 tests
    - Total: 12-17 widget tests

[ ] All Integration Tests Passing (Manual)
    - Document upload flow: 1 test
    - Notes isolation verification: 1 test
    - Atomic update verification: 1 test

[ ] Test Coverage Requirements Met
    - Overall coverage: ≥ 70%
    - US4 component coverage: ≥ 80%
    - Critical paths: 100%
```

### 5.2 Code Quality Checklist

```
[ ] No Flutter Analyze Errors
    - No type errors
    - No analyzer warnings
    - No deprecated API warnings
    - No dead code warnings

[ ] No Build Runner Issues
    - All @injectable decorators generated
    - All @freezed classes generated
    - All @JsonSerializable classes generated

[ ] Documentation Complete
    - All public classes have class-level DartDoc
    - All public methods have method-level DartDoc
    - Bilingual comments (Arabic/English)
    - Usage examples provided

[ ] Code follows Clean Architecture
    - Presentation layer: UI separation
    - Domain layer: Business logic
    - Data layer: Repository implementations
    - No circular dependencies
```

### 5.3 Functional Verification Checklist

```
[ ] Firestore Behavior Verified
    - Documents written correctly on upload
    - servicesUsage updated via transactions
    - usedServicesCount matches servicesUsage length
    - Notes field present in admin flows
    - Notes field hidden in patient flows

[ ] Storage Behavior Verified
    - Correct storage paths used
    - File metadata stored correctly
    - File size validation enforced
    - File type validation enforced
    - File deletion works (if implemented)

[ ] FCM Behavior Verified
    - FCM called on document upload
    - FCM is non-blocking (best-effort)
    - FCM handles errors gracefully

[ ] Security Rules Verified
    - Admin can upload documents
    - Patient cannot upload documents
    - Patient cannot see notes field
    - Transaction permissions enforced
```

### 5.4 User Experience Checklist

```
[ ] Loading States
    - Initial load: Skeleton or spinner
    - Upload progress: Progress bar
    - Refresh: Loading indicator
    - All states are smooth

[ ] Error Handling
    - Network errors: Retry button
    - Invalid files: Arabic error message
    - Large files: Arabic error message
    - Storage errors: Clear error message
    - All errors are user-friendly

[ ] Empty States
    - No packages: Empty view with message
    - No documents: Empty view with upload hint
    - All empty states are informative

[ ] Interaction Flow
    - File picker opens correctly
    - Upload progress is visible
    - Upload completes successfully
    - Document appears immediately
    - Navigation between screens is smooth
```

### 5.5 Performance Checklist

```
[ ] Upload Performance
    - 20 MB upload takes < 30 seconds (3G)
    - File preview loads < 2 seconds
    - List refresh takes < 1 second

[ ] Memory Usage
    - Package list uses < 50 MB
    - Upload process uses < 100 MB
    - No memory leaks during long sessions

[ ] Battery Impact
    - Upload uses < 5% battery per 1 MB
    - Background processing is minimal
```

### 5.6 Final Phase 6 Checklist

```
═════════════════════════════════════════════════════════════
                    PHASE 6 EXIT CRITERIA
═════════════════════════════════════════════════════════════

✅ All Tests Passing
    ✓ 10-16 unit tests passing
    ✓ 12-17 widget tests passing
    ✓ 3 integration tests passing (manual)

✅ Code Quality
    ✓ No flutter analyze errors
    ✓ No deprecated API warnings
    ✓ Full documentation coverage

✅ Functional Requirements
    ✓ Admin can view packages
    ✓ Admin can upload documents
    ✓ Documents visible to both admin and patient
    ✓ Notes visible to admin, hidden from patient
    ✓ Atomic transactions for usage updates

✅ Security & Rules
    ✓ Firestore transactions enforced
    ✓ File size/type validation
    ✓ Role-based access control
    ✓ E.164 phone numbers used (if applicable)
    ✓ Clinic isolation respected (if applicable)

✅ Performance
    ✓ Upload < 30 seconds (3G)
    ✓ List refresh < 1 second
    ✓ No memory leaks

═════════════════════════════════════════════════════════════
                    PHASE 6 READY FOR MERGE
═════════════════════════════════════════════════════════════
```

---

## 📝 Notes

### Critical Rules to Remember:

1. **Notes Isolation (R2)**:
   - Admin/Doctor in US4: `notes` field MUST be visible
   - Patient-facing flows: `notes` field MUST be hidden
   - This is a critical privacy requirement

2. **Atomic Updates**:
   - `servicesUsage` and `usedServicesCount` MUST be updated via Firestore transactions
   - NO direct `update()` calls
   - Prevents race conditions and data corruption

3. **File Upload Limits**:
   - Max size: 20 MB
   - Valid types: pdf, jpg, jpeg, png
   - Invalid types: txt, doc, exe, zip, etc.
   - All validations must show Arabic error messages

4. **FCM Best-Effort**:
   - FCM is called but NOT awaited
   - Upload should complete even if FCM fails
   - No blocking behavior

5. **Test Persistence**:
   - All 700+ existing tests MUST pass
   - No regression in current test suite

---

**Version**: 1.0.0
**Created**: 2026-03-08
**Author**: OpenCode Agent
**Review Status**: Pending Approval
