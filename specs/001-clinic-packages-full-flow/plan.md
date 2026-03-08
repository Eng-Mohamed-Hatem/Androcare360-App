# Implementation Plan: Clinic Packages Full Flow

**Branch**: `001-clinic-packages-full-flow` | **Date**: 2026-03-06 | **Spec**: `specs/001-clinic-packages-full-flow/spec.md`  
**Input**: Feature specification from `specs/001-clinic-packages-full-flow/spec.md`

**Note**: This plan is aligned with the Spec Kit lifecycle (specify → clarify → plan → checklist → tasks → analyze → implement).

## Summary

Implement clinic-specific medical packages for patients (Operations → Packages flow + My Packages tab in profile) and an admin Packages dashboard, including the ability to view patient packages and upload package-linked medical documents.  
The implementation will introduce a clear data model for package definitions per clinic, patient package purchases, and documents linked to package services, while respecting Clean Architecture, Clinic Isolation, and Firestore `databaseId = 'elajtech'`.

## Technical Context

**Language/Version**: Dart (project version) + Flutter (stable channel used in AndroCare)  
**Primary Dependencies**: Flutter SDK, Riverpod, dio, firebase_core, cloud_firestore, firebase_storage, flutter_secure_storage, intl, connectivity_plus (R7) (no new external packages expected initially)  
**Storage**: Firestore (`databaseId: 'elajtech'` via `FirebaseFirestore.instanceFor` or injected instance), Firebase Storage (existing project bucket, path pattern: `packageDocuments/{clinicId}/{patientId}/{patientPackageId}/{documentId}/{filename}`), local secure storage, shared_preferences/Hive if already used for auth/profile *(CHK063)*  
**CI/CD Dependency**: Whenever a new `@injectable`, `@lazySingleton`, or `@freezed` class is added or modified, the engineer **must** run `flutter pub run build_runner build --delete-conflicting-outputs` locally **before** pushing, and the CI pipeline must include this step to ensure `injection_container.config.dart` is up to date. *(CHK066)*  
**Testing**: flutter_test, mockito, integration_test, plus existing testing utilities in the project  
**Target Platform**: Android + iOS (same minimum versions as current AndroCare app)  
**Performance Goals**: Category Packages List and My Packages screens must render content within **2 seconds** on a mid-range 4G device (see spec.md §10.1). Firestore queries must use composite indexes as mandatory requirements (see data-model.md); lazy pagination (page size = 20) used for all admin list queries. *(CHK028, CHK049)*  
**Constraints**: Must respect Auth Safety & Firestore rules (no default Firestore instance, no `!` on auth user, safe snapshot parsing), Firestore offline persistence enabled for all patient-facing package reads, proper RTL support, non-blocking UI  
**Datasource split (R5)**: The data layer uses **two separate datasource classes** to respect SRP:
- `FirestorePackageDatasource` (`lib/features/packages/data/datasources/firestore_package_datasource.dart`) — all Firestore reads/writes only.
- `FirebaseStoragePackageDatasource` (`lib/features/packages/data/datasources/firebase_storage_package_datasource.dart`) — document upload/download only (Firebase Storage).
Both are injected as separate `@lazySingleton` dependencies into repository implementations. This keeps each class independently unit-testable.

**Payment adapter layering (R6)**:  
- **Domain layer** (interface): `lib/features/packages/domain/adapters/package_payment_adapter.dart` — abstract class, depended on by `PurchasePackageUseCase`.  
- **Data layer** (implementation): `lib/features/packages/data/adapters/package_payment_adapter_impl.dart` — wraps existing `PaymentService`, annotated `@LazySingleton(as: PackagePaymentAdapter)`.  
Use cases depend **only** on the Domain interface, never on the Data implementation. This satisfies Clean Architecture Principle I.  
**Scale/Scope**:  
- New patient screens: 3 main flows  
  - Operations → Packages categories  
  - Category packages list  
  - My Packages tab (list + details)  
- Admin dashboard: 2 main areas  
  - Packages management  
  - Patient Packages section  
- Domain/Data: ~3–4 new entities, several use cases, and per-clinic repositories for packages

## Constitution Check

*GATE: Must pass before implementation; re-check after detailed design.*

- [ ] **Architecture Check**: Uses Clean Architecture (Presentation/Domain/Data) and SOLID per AndroCare rules.  
- [ ] **State Check**: Uses Riverpod (or approved state management) without leaking complex logic into Widgets.  
- [ ] **Security Check**: Complies with Auth Safety, Firestore mapping rules, and uses `databaseId: 'elajtech'` only.  
- [ ] **Data Safety**: No `!` on auth user, strict Firestore snapshot validation, safe list access (no `.first` بدون فحص).  
- [ ] **UX/UI Check**: Uses existing design system, handles loading/error/empty states, and applies LTR/RTL rules (see spec.md §9.14).  
- [ ] **Testing Check**: Adds Unit + Widget tests for new logic (domain ≥80% coverage, data ≥70%), respects Test Persistence rule, and mocks platform channels if needed (see spec.md §10.4).  
- [ ] **Spec Kit Check**: Feature followed lifecycle: spec → clarify → plan (this file) → checklist → tasks → analyze → implement.
- [ ] **Pagination Check**: All admin list queries use lazy pagination (page size = 20) via Firestore cursor-based `startAfterDocument`. *(CHK049)*
- [ ] **CI/CD Check**: `build_runner` executed before each push; CI pipeline runs `flutter pub run build_runner build --delete-conflicting-outputs` and `flutter analyze` as mandatory steps. *(CHK066)*

## Project Structure

### Documentation (this feature)

```text
specs/001-clinic-packages-full-flow/
├── spec.md          # Functional specification (already written)
├── plan.md          # This implementation plan
├── research.md      # Phase 0 output (later)
├── data-model.md    # Phase 1 data modeling details (later)
├── quickstart.md    # Phase 1 developer quickstart for this feature (later)
├── contracts/       # API / domain contracts (later)
└── tasks.md         # Phase 2 output (/speckit.tasks)

lib/
├── core/
│   ├── routing/
│   ├── theming/
│   ├── widgets/
│   ├── errors/
│   ├── utils/
│   └── services/
│
├── features/
│   ├── auth/
│   ├── appointments/
│   ├── ...existing features...
│   └── packages/
│       ├── presentation/
│       │   ├── pages/
│       │   │   ├── operations_packages_page.dart        # زر الباقات + شاشة الأقسام
│       │   │   ├── category_packages_list_page.dart     # قائمة باقات القسم
│       │   │   ├── package_details_page.dart            # تفاصيل الباقة + شراء/عرض
│       │   │   └── my_packages_page.dart                # تبويب باقاتي في الملف الشخصي
│       │   ├── widgets/
│       │   │   ├── package_card.dart
│       │   │   ├── package_status_badge.dart
│       │   │   └── package_progress_widget.dart
│       │   └── providers/                               # Riverpod providers/controllers
│       │
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── package_entity.dart
│       │   │   ├── patient_package_entity.dart
│       │   │   └── package_document_entity.dart
│       │   ├── usecases/
│       │   │   ├── list_category_packages_usecase.dart
│       │   │   ├── get_package_details_usecase.dart
│       │   │   ├── get_patient_package_details_usecase.dart
│       │   │   ├── purchase_package_usecase.dart
│       │   │   ├── get_patient_packages_usecase.dart
│       │   │   ├── upload_package_document_usecase.dart
│       │   │   ├── duplicate_package_usecase.dart
│       │   │   └── update_package_service_usage_usecase.dart
│       │   └── repositories/
│       │       ├── package_repository.dart              # واجهة عامة مع احترام Clinic Isolation
│       │       └── patient_package_repository.dart
│       │
│       └── data/
│           ├── models/
│           │   ├── package_model.dart
│           │   ├── patient_package_model.dart
│           │   └── package_document_model.dart
│           ├── datasources/
│           │   └── firestore_package_datasource.dart
│           └── repositories/
│               ├── andrology_package_repository_impl.dart
│               ├── physiotherapy_package_repository_impl.dart
│               ├── internal_family_package_repository_impl.dart
│               ├── nutrition_package_repository_impl.dart
│               └── chronic_diseases_package_repository_impl.dart
│
└── main.dart


test/
├── unit/
│   └── features/
│       └── packages/
│           ├── domain/                          # Use case tests (all 10 use cases)
│           │   ├── purchase_package_usecase_test.dart   # Covers: happy path, PackageAlreadyActiveFailure, PaymentFailure, NetworkFailure
│           │   ├── list_category_packages_usecase_test.dart
│           │   ├── get_package_details_usecase_test.dart
│           │   ├── get_patient_packages_usecase_test.dart
│           │   ├── get_patient_package_details_usecase_test.dart
│           │   ├── create_clinic_package_usecase_test.dart
│           │   ├── update_clinic_package_usecase_test.dart
│           │   ├── toggle_package_status_usecase_test.dart
│           │   ├── duplicate_package_usecase_test.dart
│           │   └── upload_package_document_usecase_test.dart
│           └── data/                            # Repository impl + fromFirestore tests
├── widget/
│   └── features/
│       └── packages/
│           ├── patient/
│           │   ├── category_packages_list_page_test.dart   # States: loading, empty, list, error
│           │   ├── package_details_page_test.dart           # Button states: idle, loading, success, already-purchased
│           │   └── my_packages_page_test.dart               # States: no packages, active, expired
│           └── admin/                           # Admin widget tests *(CHK059)*
│               ├── admin_packages_list_page_test.dart       # List, filter, empty, actions
│               ├── create_edit_package_page_test.dart       # Form validation, Arabic error messages
│               └── admin_patient_packages_page_test.dart    # Document upload UI, states
└── integration/
    └── packages_flow_test.dart    # Flows: Operations → Packages → Purchase → My Packages


### Payment Mock Strategy in Tests *(CHK058, R8)*

Since payment integration is deferred and there is no live payment gateway in tests:

1. **Unit tests**: Inject a `MockPaymentService` (via mockito) into `PurchasePackageUseCase`. Two mock configurations:
   - `mockPaymentService.initiatePayment(...)` → returns `Right(PaymentSuccess(transactionId: 'TXN_TEST_001'))` for the happy path.
   - Returns `Left(PaymentFailure())` for the failure path.
2. **Integration tests**: A `FakePaymentService` is registered via DI overrides (Riverpod `overrideWith`) that always returns a configurable `PaymentSuccess` or `PaymentFailure` depending on a test flag. **`FakePaymentService` lives at `test/helpers/fake_payment_service.dart`** and implements the `PackagePaymentAdapter` **domain interface** (not the Data impl). This is created in Phase 2 (T003b) so it is available before any integration test is written (R8).
3. No real payment gateway calls are ever made in the test suite. The payment module interface is mocked at the boundary, not below it.


## Pagination & Caching Strategy *(CHK049, CHK050)*

### Pagination
- All admin list queries (`ListClinicPackagesForAdminUseCase`, `GetPatientPackagesForAdminUseCase`) use **cursor-based Firestore pagination** with a page size of **20 documents**.
- Patient-facing lists (`ListCategoryPackagesUseCase`) load all active packages for a category in a single query (expected < 20 per category). If a category exceeds 50 packages, lazy pagination is introduced.
- The repository returns a `PageResult<T>` wrapper containing the data list and an optional cursor for the next page.

### Caching
- **Firestore offline persistence** is enabled for the Packages feature (Firestore SDK default). No additional caching layer is introduced in this release.
- `DuplicatePackageUseCase`: **Deferred to a future iteration** — no explicit result caching beyond Firestore's built-in offline cache.
- App-level caching (e.g., in-memory via Riverpod state) is limited to the lifecycle of the screen; no shared in-memory cache across screens in this release.

