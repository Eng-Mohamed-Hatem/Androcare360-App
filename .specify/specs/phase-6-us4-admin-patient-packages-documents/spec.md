# Phase 6 - US4: Admin Patient Packages & Document Upload

## 📋 Summary

**Feature**: Admin Patient Packages Management with Document Upload capability

### Purpose
Enable administrators to view, manage, and upload documents for patient packages. Provide comprehensive tracking of service usage and document history while maintaining strict data privacy (notes visibility rules).

### Key Features
- Admin view of patient packages list
- Detailed package inspection with notes and usage statistics
- Document upload with file validation (size, type)
- Atomic updates of service usage via Firestore transactions
- Notes field visibility restricted to admin/doctor only (R2 requirement)
- Best-effort FCM notifications for document uploads

### Scope
- **Use Cases**: GetPatientPackagesForAdmin, UploadPackageDocument, UpdatePackageServiceUsage
- **Providers**: adminPatientPackagesProvider, uploadDocumentProvider
- **UI Components**: AdminPatientPackagesPage, AdminPatientPackageContextView, DocumentUploadBottomSheet
- **Tests**: Unit tests (use cases), Widget tests (UI), Integration tests (manual)

---

## 🎯 User Stories

### US4.1: Admin Views Patient Packages
**As an** admin
**I want to** view all patient packages in a searchable list
**So that** I can monitor package usage and patient status

### US4.2: Admin Opens Package Details
**As an** admin
**I want to** click on a package to see full details
**So that** I can review notes, services used, and usage statistics

### US4.3: Admin Uploads Document
**As an** admin
**I want to** upload documents (PDF/images) to a patient package
**So that** I can provide reference materials and maintain documentation

### US4.4: Document Validation
**As an** admin
**I want to** see clear error messages for invalid files
**So that** I understand upload failures and can correct them

### US4.5: Atomic Usage Updates
**As an** admin
**I want to** see service usage accurately tracked
**So that** I can monitor package consumption in real-time

---

## 🏗️ Architecture

### Clean Architecture Layers

```
lib/features/admin/
├── domain/
│   ├── entities/
│   │   └── patient_package.dart          # Core entity
│   ├── repositories/
│   │   └── patient_package_repository.dart
│   ├── use_cases/
│   │   ├── get_patient_packages_for_admin_use_case.dart
│   │   ├── upload_package_document_use_case.dart
│   │   └── update_package_service_usage_use_case.dart
│   └── parameters/
│       └── get_patient_packages_parameters.dart
├── data/
│   ├── repositories/
│   │   └── patient_package_repository_impl.dart
│   ├── datasources/
│   │   └── patient_package_remote_datasource.dart
│   └── models/
│       ├── patient_package_model.dart
│       └── document_model.dart
└── presentation/
    ├── providers/
    │   ├── admin_patient_packages_provider.dart
    │   └── upload_document_provider.dart
    ├── screens/
    │   └── admin_patient_packages_page.dart
    ├── widgets/
    │   ├── admin_patient_package_context_view.dart
    │   └── document_upload_bottom_sheet.dart
    └── widgets/
        └── package_document_list_item.dart
```

### Data Flow

```
┌─────────────┐
│   Admin UI  │
│ (Page/View) │
└──────┬──────┘
       │ 1. Fetch Packages
       ▼
┌─────────────────────────────────┐
│ GetPatientPackagesForAdmin       │
│     Use Case                     │
└──────┬──────────────────────────┘
       │ 2. Call Repository
       ▼
┌─────────────────────────────────┐
│ PatientPackageRepository         │
│     (Firestore)                  │
└──────┬──────────────────────────┘
       │ 3. Query Firestore
       ▼
┌─────────────────────────────────┐
│ Firestore: patient_packages      │
│     Collection                   │
└─────────────────────────────────┘

┌─────────────┐
│ Admin UI    │
│ (Upload)    │
└──────┬──────┘
       │ 1. Select File
       ▼
┌─────────────────────────────────┐
│ UploadPackageDocument            │
│     Use Case                     │
└──────┬──────────────────────────┘
       │ 2. Validate & Upload
       ▼
┌─────────────────────────────────┐
│ UpdatePackageServiceUsage        │
│     Use Case (Transaction)      │
└──────┬──────────────────────────┘
       │ 3. Firestore Transaction
       ▼
┌─────────────────────────────────┐
│ Firestore: patient_packages      │
│     (Atomic Update)              │
└─────────────────────────────────┘
```

---

## 🔐 Security & Privacy

### Notes Visibility Rule (R2)
**Critical Privacy Requirement**:

| Role | Notes Field Visibility |
|------|------------------------|
| **Admin** | ✅ VISIBLE |
| **Doctor** | ✅ VISIBLE |
| **Patient** | ❌ HIDDEN |
| **Other** | ❌ HIDDEN |

**Implementation**:
- Admin/Doctor endpoints: Include `notes` field in query results
- Patient endpoints: Exclude `notes` field (use separate query)
- Backend/API validation: Check `userType` before exposing notes

### Role-Based Access Control
- **Admin**: Can view all packages, upload documents, see notes
- **Doctor**: Can view patient packages, upload documents, see notes
- **Patient**: Can view package status, but NOT notes
- **Other**: No access

### Data Validation
- File size: ≤ 20 MB
- File types: pdf, jpg, jpeg, png
- All validation failures show Arabic error messages
- Input sanitization to prevent injection attacks

---

## 📊 Data Models

### PatientPackage Entity

```dart
/// Represents a patient package with services and documents.
/// يمثل حزمة مريض مع خدمات ومستندات.
class PatientPackage {
  final String id;
  final String patientId;
  final String packageType;
  final List<PackageService> services;
  final List<PackageServiceUsage> servicesUsage;
  final int usedServicesCount;
  final String? notes;
  final List<PackageDocument> documents;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
}
```

### PackageDocument Entity

```dart
/// Represents a document uploaded to a patient package.
/// يمثل مستند تم رفعه لحزمة مريض.
class PackageDocument {
  final String id;
  final String documentUrl;
  final String fileName;
  final String mimeType;
  final int fileSize;
  final String uploadedBy;
  final DateTime uploadedAt;
  final String? note;
}
```

### PackageService Entity

```dart
/// Represents a service in a patient package.
/// يمثل خدمة في حزمة مريض.
class PackageService {
  final String id;
  final String serviceName;
  final String description;
  final double price;
  final int durationMinutes;
}
```

### PackageServiceUsage Entity

```dart
/// Tracks usage of a specific service in a patient package.
/// يتبع استخدام خدمة معينة في حزمة مريض.
class PackageServiceUsage {
  final String serviceId;
  final DateTime usedAt;
  final String? note;
}
```

---

## 🔄 Workflows

### Workflow 1: View Patient Packages

```
1. Admin navigates to AdminPatientPackagesPage
2. Page initializes adminPatientPackagesProvider
3. Provider calls GetPatientPackagesForAdminUseCase
4. Use Case calls PatientPackageRepository.getPackagesForAdmin(patientId)
5. Repository queries Firestore for package documents
6. Results returned as Right(List<PatientPackageModel>)
7. UI renders package list
8. User taps on a package
9. Navigates to AdminPatientPackageContextView
```

### Workflow 2: Upload Document

```
1. Admin taps "Upload Document" button
2. DocumentUploadBottomSheet opens
3. Admin selects file from file picker
4. File validated:
   - Size ≤ 20 MB? ❌ → Show Arabic error, cancel
   - Type ∈ {pdf, jpg, jpeg, png}? ❌ → Show Arabic error, cancel
   - Valid? ✅ → Proceed
5. UploadPackageDocumentUseCase called
6. UploadDocumentProvider tracks progress
7. Document uploaded to Firebase Storage:
   - Path: /patient_packages/{packageId}/{documentId}
   - Metadata: type, size, uploadedBy, uploadedAt
8. FCM notification sent (best-effort, non-blocking)
9. UpdatePackageServiceUsageUseCase called:
   - Creates new PackageServiceUsage entry
   - Uses Firestore transaction to update:
     * servicesUsage: append new entry
     * usedServicesCount: increment by 1
10. Success → Document added to list
11. Loading state → Success state → Loading state (refresh)
```

### Workflow 3: Notes Visibility Check

```
Admin Flow:
1. Query includes notes field
2. API returns notes in response
3. UI displays notes field

Patient Flow (R2):
1. Query excludes notes field
2. API does NOT include notes in response
3. UI does NOT display notes field
```

---

## ✅ Acceptance Criteria

### Functional Requirements
- [ ] Admin can view all patient packages
- [ ] Admin can tap on a package to see details
- [ ] Admin can upload valid documents (≤ 20 MB, pdf/jpg/png)
- [ ] Admin sees Arabic error messages for invalid files
- [ ] Service usage is updated atomically via transactions
- [ ] Notes field is visible to admin/doctor only
- [ ] Notes field is hidden from patient

### Non-Functional Requirements
- [ ] Upload completes in < 30 seconds (3G network)
- [ ] List refresh takes < 1 second
- [ ] No memory leaks during upload
- [ ] No deprecated API usage
- [ ] All tests pass (unit + widget + integration)

### Security Requirements
- [ ] Role-based access control enforced
- [ ] File size/type validation on client and server
- [ ] Atomic updates prevent data corruption
- [ ] Notes privacy preserved

---

## 🧪 Test Strategy

### Test Matrix

| Component | Test Type | Scenarios |
|-----------|-----------|-----------|
| GetPatientPackagesForAdmin | Unit | Happy path, no packages, invalid ID, network error |
| UploadPackageDocument | Unit | Valid upload, size validation, type validation, errors |
| UpdatePackageServiceUsage | Unit | Atomic update, concurrent updates, failures |
| adminPatientPackagesPage | Widget | List display, empty state, loading, errors |
| AdminPatientPackageContextView | Widget | Details display, notes visibility, interactions |
| DocumentUploadBottomSheet | Widget | File picker, validation, upload progress, cancel |

### Coverage Targets
- **Overall**: ≥ 70%
- **US4 Components**: ≥ 80%
- **Critical Flows**: 100%

---

## 📝 Notes

### Critical Implementation Notes

1. **Firestore Transactions**:
   ```dart
   // MUST use transaction for atomic updates
   await firestore.runTransaction(async (transaction) async {
     final packageRef = firestore.collection('patient_packages').doc(packageId);
     final packageDoc = await transaction.get(packageRef);
     final currentData = packageDoc.data()!;

     final newServicesUsage = [...currentData['servicesUsage'], newEntry];

     transaction.update(packageRef, {
       'servicesUsage': newServicesUsage,
       'usedServicesCount': newServicesUsage.length,
     });
   });
   ```

2. **File Upload**:
   - Use Firebase Storage SDK
   - Validate on client before upload
   - Metadata should include: type, size, uploadedBy, uploadedAt
   - Path: `/patient_packages/{packageId}/{documentId}`

3. **Notes Field**:
   - Admin/Doctor queries: include `notes` field
   - Patient queries: exclude `notes` field
   - DO NOT use `.where('notes', isNotNull)` for patient queries

4. **FCM Best-Effort**:
   - Call FCM but don't await
   - Use `Future<void>` return type
   - Don't block upload completion

### Design Decisions

1. **Atomic Updates**: Prevents race conditions in concurrent access scenarios
2. **File Validation**: Client-side validation for immediate feedback
3. **Notes Visibility**: Strict role-based access for privacy compliance
4. **FCM Best-Effort**: Ensures upload completes even if notification fails

---

## 🔗 Dependencies

### Existing Components
- Patient Package Repository (already implemented in Phase 5)
- Firebase Storage SDK
- FCM Service
- Error Handling (Either<Failure, T>)

### New Dependencies
- File Picker (for document selection)
- Firebase Storage (for upload)
- FCM (for notifications)

### External Integrations
- Firebase Storage
- FCM
- File System (native)

---

## 📚 References

- **Project Constitution**: .specify/memory/constitution.md
- **Elajtech Rules**: docs/important-rules.md
- **Clean Architecture Guidelines**: README.md
- **Test Standards**: CONTRIBUTING.md

---

**Version**: 1.0.0
**Created**: 2026-03-08
**Status**: Ready for Plan Generation
**Author**: OpenCode Agent
