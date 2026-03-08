# Tasks: Clinic Packages Full Flow

**Input**: `specs/001-clinic-packages-full-flow/` — spec.md, plan.md, data-model.md, checklists/full-flow.md  
**Generated**: 2026-03-07 | **Last updated**: 2026-03-07 (post-analyze remediation R1–R13)  
**Total tasks**: 97 | **User stories**: 4 | **Phases**: 7

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Parallelisable (no dependency on incomplete tasks in the same phase)
- **[Story]**: Which user story this task belongs to (US1–US4)
- Exact file paths given for every task

## User Story Index

| ID | Title | Priority | Spec ref |
|---|---|---|---|
| US1 | Patient – Operations → Packages (Browse & Buy) | P1 🎯 MVP | Spec §4.1, §9, §10 |
| US2 | Patient – My Packages tab (list + detail + documents) | P2 | Spec §4.2 |
| US3 | Admin – Packages Management (create, edit, toggle, duplicate, list) | P3 | Spec §4.3, §9.9, §9.12 |
| US4 | Admin – Patient Packages & Documents (view + upload) | P4 | Spec §4.4, §7.11, §9.13 |

---

## Phase 1: Setup & Infrastructure

**Purpose**: Confirm existing project infrastructure, create feature folder skeleton, register failure types, set up routing, and verify deployment prerequisites.

> ⚠️ **R12**: Confirm the router type FIRST (T004 moved before T001) to avoid screen-navigation refactors later.

- [x] T004 **Confirm project router type** — **Finding**: Project uses plain **Flutter Navigator** (`MaterialApp(home: AuthWrapper())`, no GoRouter configured). `go_router ^14` is in pubspec but unused. Package screens will use `Navigator.push` consistently with the rest of the app. Route pattern documented in `package_navigation.dart` (Phase 3). — R12 ✅
- [x] T001 Create feature folder skeleton — **Done**: Created all 13 sub-directories under `lib/features/packages/` (presentation/pages, presentation/widgets, presentation/providers, domain/entities, domain/usecases, domain/repositories, domain/adapters, domain/failures, data/models, data/datasources, data/repositories, data/adapters, data/constants) with `.gitkeep` placeholder files. ✅
- [x] T002 [P] Create Clinic Packages failure types in `lib/features/packages/domain/failures/package_failures.dart` — **Done**: Defined 7 typed failures: `PackageAlreadyActiveFailure`, `PaymentFailure`, `NetworkFailure`, `PackageNotFoundFailure`, `ClinicUnavailableFailure`, `StaleDataFailure` (R1), `UploadFailure`. All extend project `Failure`. Bilingual DartDoc included. flutter analyze: ✅ No errors.
- [x] T002b [P] **Created `ConnectivityProvider`** in `lib/core/network/connectivity_provider.dart` — Riverpod `StreamProvider<bool>` wrapping `connectivity_plus ^5` (handles `List<ConnectivityResult>` API). Exposes `connectivityProvider` (stream), `currentConnectivityProvider` (sync snapshot), and `checkCurrentConnectivity()` helper. Bridges with existing `ConnectionService` without duplication. flutter analyze: ✅ No errors. — R7
- [x] T005 [P] Validate clinic Firestore documents — **✅ VERIFIED (2026-03-07)**: `clinics` collection created in `elajtech` DB with all 5 documents (`andrology`, `physiotherapy`, `internal_family`, `nutrition`, `chronic_diseases`), each with `isActive: true` and `name` in Arabic. Document IDs match `ClinicIds` constants exactly.
- [x] T005b [P] **Confirmed `clinicId` constants** in `lib/features/packages/data/constants/clinic_ids.dart` — 5 constants aligned with existing collection naming (`nutrition_emrs` → `nutrition`, `physiotherapy_emrs` → `physiotherapy`). ID correction: `obesityNutrition` → `nutrition`. All references use `ClinicIds.nutrition`. — R13 ✅

  > ✅ **Pre-Phase-2 blocker resolved**: All 5 clinic documents confirmed in Firestore.

**Checkpoint ✅**: Router type confirmed, feature folder exists, failures typed, connectivity verified, clinic IDs recorded.

---

## Phase 2: Foundational – Domain Entities, Data Models & DI

**Purpose**: All entities, models, repository interfaces, datasources, repository implementations, and DI registration. **Every user story blocks on this phase completing.**

> ⚠️ **CRITICAL**: Run `flutter pub run build_runner build --delete-conflicting-outputs` after every `@injectable` / `@freezed` / `@JsonSerializable` change in this phase.

### Domain Entities

- [ ] T006 [P] Create `PackageEntity` in `lib/features/packages/domain/entities/package_entity.dart` with all fields from data-model.md §3.1 (id, clinicId, category, name, shortDescription, description, services list, validityDays, termsAndConditions, price, currency, discountPercentage, packageType, includesVideoConsultation, includesPhysicalVisit, status, displayOrder, isFeatured, createdAt, updatedAt). Use `@freezed` if project uses it.
- [ ] T007 [P] Create `PatientPackageEntity` in `lib/features/packages/domain/entities/patient_package_entity.dart` with fields from data-model.md §4.1 (id, patientId, packageId, clinicId, category, status, purchaseDate, expiryDate, totalServicesCount, usedServicesCount, servicesUsage list, paymentTransactionId, notes, createdAt, updatedAt). **The `notes` field is included in the entity class but must only be populated by admin-facing use cases (R2).**
- [ ] T008 [P] Create `PackageDocumentEntity` in `lib/features/packages/domain/entities/package_document_entity.dart` with fields from data-model.md §5.1 (id, patientId, patientPackageId, packageId, clinicId, serviceId, documentType, title, description, filePath/fileUrl, uploadedByUserId, uploadedByRole, uploadedAt)
- [ ] T009 [P] Create `PackageServiceItem` value object in `lib/features/packages/domain/entities/package_service_item.dart` (serviceId, serviceType, displayName, quantity) and `ServiceUsageItem` (serviceId, usedCount, lastUsedAt) — used inside both PackageEntity and PatientPackageEntity

### Domain Adapters (R6)

- [ ] T003 **Create `PackagePaymentAdapter` interface** in `lib/features/packages/domain/adapters/package_payment_adapter.dart` (Domain layer — NOT Data). This is an abstract class that use cases depend on. Signature: `Future<Either<PaymentFailure, PaymentSuccess>> initiatePayment({required double amount, required String currency, required String packageRef})` — see spec.md §7.14. R6: domain use cases import this file only.
- [ ] T003b [P] Create `PackagePaymentAdapterImpl` in `lib/features/packages/data/adapters/package_payment_adapter_impl.dart` implementing the Domain `PackagePaymentAdapter` interface, wrapping the existing `PaymentService`. Annotate `@LazySingleton(as: PackagePaymentAdapter)`. Also create `FakePaymentService` in `test/helpers/fake_payment_service.dart` implementing `PackagePaymentAdapter` with a configurable `shouldSucceed` flag and a fixed `transactionId` — used in integration tests via Riverpod `overrideWith`. Document the `overrideWith` pattern as a comment in `fake_payment_service.dart`. — R6, R8

### Domain Repository Interfaces

- [ ] T010 Create `PackageRepository` interface in `lib/features/packages/domain/repositories/package_repository.dart` with methods: `getPackageById`, `listCategoryPackages(clinicId, category, {status})`, `listClinicPackagesForAdmin(clinicId, {filters, cursor, limit})` — returns `Either<Failure, T>` — see spec.md §8.1, §8.2
- [ ] T011 Create `PatientPackageRepository` interface in `lib/features/packages/domain/repositories/patient_package_repository.dart` with methods:
  - `getPatientPackages(patientId)` — for patient app; returns `PatientPackageEntity` with `notes = null` (application-layer enforcement — R2)
  - `getPatientPackageByIdForPatient(patientId, patientPackageId)` — **strips `notes` field** before returning; for patient screens only (R2)
  - `getPatientPackageByIdForAdmin(patientId, patientPackageId)` — includes `notes` field; for admin screens only (R2)
  - `findActiveOrPendingByPackageId(patientId, packageId)` — duplicate-purchase guard (CHK023)
  - `createPatientPackage(...)` — writes with mandatory `paymentTransactionId` for ACTIVE status
  - `listPatientPackagesForAdmin(patientId, {cursor, limit})` — includes `notes` field
  — see spec.md §7.1, §7.8, §8.3
- [ ] T012 [P] Create `PackageDocumentRepository` interface in `lib/features/packages/domain/repositories/package_document_repository.dart` with methods: `getDocumentsByPatientPackage(patientId, patientPackageId)`, `uploadDocument(...)` — see spec.md §7.15

### Core Helpers

- [ ] T090 **Create `ClinicAccessResolver`** in `lib/core/auth/clinic_access_resolver.dart` (R4): reads Firebase Auth custom claims (`idTokenResult.claims`) to derive `allowedClinics: List<String>` for the current user. Fallback: Firestore lookup at `users/{uid}/roles` if claims absent or stale. Returns full clinic list for `ADMIN_GLOBAL`, single-clinic list for `ADMIN_CLINIC` and `DOCTOR_<SPECIALTY>`, empty list for unauthenticated. Annotate `@lazySingleton`. Write unit test file `test/unit/core/auth/clinic_access_resolver_test.dart` with at least: (a) `ADMIN_GLOBAL` returns all 5 clinicIds, (b) `ADMIN_CLINIC` returns only `allowedClinics`, (c) unauthenticated returns empty list. — R4

### Data Layer – Models

- [ ] T013 [P] Create `PackageModel` in `lib/features/packages/data/models/package_model.dart` extending `PackageEntity`, implementing `fromFirestore(DocumentSnapshot)` with `exists` + `data != null` guard and `try-catch` with `debugPrint(stackTrace)` (Data Safety rule). Map all fields from data-model.md §3.1. Add `toFirestore()` method.
- [ ] T014 [P] Create `PatientPackageModel` in `lib/features/packages/data/models/patient_package_model.dart` extending `PatientPackageEntity`, same safety guards. Map all fields from data-model.md §4.1 including `servicesUsage` array. Provide two factory constructors: `fromFirestoreForPatient()` — sets `notes = null` unconditionally (R2); `fromFirestoreForAdmin()` — maps `notes` normally.
- [ ] T015 [P] Create `PackageDocumentModel` in `lib/features/packages/data/models/package_document_model.dart` extending `PackageDocumentEntity`, same safety guards. Map all fields from data-model.md §5.1.

### Data Layer – Datasources (R5: split per SRP)

- [ ] T016a Create `FirestorePackageDatasource` in `lib/features/packages/data/datasources/firestore_package_datasource.dart` using injected `FirebaseFirestore` (`databaseId: 'elajtech'`, never `FirebaseFirestore.instance`). **Firestore reads/writes only** (no Storage). Methods: `fetchPackageById`, `fetchCategoryPackages` (`limit(50)`, patient), `fetchClinicPackagesForAdmin` (cursor `limit(20)`), `createPatientPackage`, `fetchPatientPackages`, `fetchPatientPackageByIdRaw` (returns raw data; model layer applies patient vs admin projection), `findActiveOrPendingByPackageId` (Index 5), `fetchPatientPackagesForAdmin` (cursor `limit(20)`), `fetchDocumentsByPatientPackage`. Enable Firestore offline persistence. Annotate `@lazySingleton`. — R5
- [ ] T016b [P] Create `FirebaseStoragePackageDatasource` in `lib/features/packages/data/datasources/firebase_storage_package_datasource.dart` using injected `FirebaseStorage`. **Storage upload/download only** (no Firestore). Method: `uploadDocument(filePath, clinicId, patientId, patientPackageId, documentId, filename) → Future<Either<UploadFailure, String>> downloadUrl`. Returns `UploadFailure` on Storage errors. Annotate `@lazySingleton`. — R5

### Data Layer – Per-Clinic Repository Implementations

- [ ] T017 [P] Create `AndrologyPackageRepositoryImpl` in `lib/features/packages/data/repositories/andrology_package_repository_impl.dart` implementing `PackageRepository`, using `ClinicIds.andrology` from `clinic_ids.dart` (R13). Delegate all calls to `FirestorePackageDatasource`.
- [ ] T018 [P] Create `PhysiotherapyPackageRepositoryImpl` — same pattern, `ClinicIds.physiotherapy`
- [ ] T019 [P] Create `InternalFamilyPackageRepositoryImpl` — `ClinicIds.internalFamily`
- [ ] T020 [P] Create `NutritionPackageRepositoryImpl` in `lib/features/packages/data/repositories/nutrition_package_repository_impl.dart` — same pattern, `ClinicIds.nutrition`
- [ ] T021 [P] Create `ChronicDiseasesPackageRepositoryImpl` — `ClinicIds.chronicDiseases`
- [ ] T022 Create `PatientPackageRepositoryImpl` in `lib/features/packages/data/repositories/patient_package_repository_impl.dart` implementing `PatientPackageRepository`. Patient-facing methods use `PatientPackageModel.fromFirestoreForPatient()` (notes = null). Admin-facing methods use `PatientPackageModel.fromFirestoreForAdmin()` (notes included). Annotate `@LazySingleton(as: PatientPackageRepository)`. — R2
- [ ] T023 [P] Create `PackageDocumentRepositoryImpl` in `lib/features/packages/data/repositories/package_document_repository_impl.dart` implementing `PackageDocumentRepository`. Injects both `FirestorePackageDatasource` and `FirebaseStoragePackageDatasource` separately (R5). Delegates Storage upload to `T016b` datasource. Annotate `@LazySingleton(as: PackageDocumentRepository)`.

### DI Registration & Indexes

- [ ] T024 Run `flutter pub run build_runner build --delete-conflicting-outputs` and verify all 11 new classes (5 clinic repos + PatientPackageRepo + DocumentRepo + ClinicAccessResolver + 2 datasources + PackagePaymentAdapterImpl) appear in `lib/core/di/injection_container.config.dart`. Fix any registration errors before continuing.
- [ ] T025 Create the **8 mandatory Firestore composite/collection-group indexes** in the Firebase Console for the `elajtech` database: Index 1 (`clinicId+category+status+displayOrder`), Index 2 (`clinicId+isFeatured+displayOrder`), Index 3 (`patientId+status`), Index 4 (`patientId+category`), Index 5 (`patientId+packageId+status`), Index 6 (`patientId+patientPackageId`), Index 7 (`patientPackageId+serviceId`), **Index 8**: Collection Group index on `packages` with `status` ASC + `expiryDate` ASC (required for Cloud Function's cross-patient expiry query — R9).
- [ ] T026 [P] Write Firestore Security Rules for the Packages feature in `firestore.rules`: patient read isolation (`request.auth.uid == patientId`) for `packages` and `packageDocuments` sub-paths; DOCTOR/ADMIN write to `packageDocuments`; clinicId-scoped read/write for `clinics/{clinicId}/packages` using custom claims. Write Storage Security Rules for `packageDocuments/**`. See spec.md §§7.6, 7.7, 7.8.
- [ ] T026b [P] **Add collection group read permission** for the Cloud Function service account in `firestore.rules` (or via IAM): the service account must be able to read/write across all `patients/*/packages` documents to execute the expiry batch — required for Index 8's collection group query. Verify this in a test deploy before Phase 7. — R9

**Checkpoint ✅**: All entities, models, repositories, adapters, datasources, ClinicAccessResolver, and DI wired. 8 indexes created. Security rules deployed. FakePaymentService available. Clinic IDs confirmed.

---

## Phase 3: US1 – Patient Browse & Buy (Operations → Packages) 🎯 MVP

**Goal**: Patient can tap "الباقات" in the Operations section, browse categories and package lists, open Package Details, and complete a purchase.

**Independent test**: Run widget tests for `CategoryPackagesListPage` and `PackageDetailsPage`; run unit tests for `ListCategoryPackagesUseCase`, `GetPackageDetailsUseCase`, and `PurchasePackageUseCase`.

### Domain Use Cases – US1

- [ ] T027 [P] [US1] Write unit tests for `ListCategoryPackagesUseCase` in `test/unit/features/packages/domain/list_category_packages_usecase_test.dart`: (a) happy path returns sorted list (featured first), (b) empty list, (c) `ClinicUnavailableFailure`, (d) network error. Mock `PackageRepository`.
- [ ] T028 [P] [US1] Implement `ListCategoryPackagesUseCase` in `lib/features/packages/domain/usecases/list_category_packages_usecase.dart`: calls `PackageRepository.listCategoryPackages(clinicId, category)` filtered by `status = ACTIVE`; sort: featured packages first, then by `displayOrder` ascending — spec.md §9.3, §8.1
- [ ] T029 [P] [US1] Write unit tests for `GetPackageDetailsUseCase` in `test/unit/features/packages/domain/get_package_details_usecase_test.dart`: (a) happy path, (b) `PackageNotFoundFailure`, (c) `ClinicUnavailableFailure`
- [ ] T030 [P] [US1] Implement `GetPackageDetailsUseCase` in `lib/features/packages/domain/usecases/get_package_details_usecase.dart`: reads `clinics/{clinicId}/packages/{packageId}`; returns `ClinicUnavailableFailure` if clinic not found — spec.md §7.9, §8.1
- [ ] T031 [US1] Write unit tests for `PurchasePackageUseCase` in `test/unit/features/packages/domain/purchase_package_usecase_test.dart`: (a) happy path → `Right(patientPackageId)`, (b) `PackageAlreadyActiveFailure` when ACTIVE record exists, (c) `PackageAlreadyActiveFailure` when PENDING record exists, (d) EXPIRED/COMPLETED → new purchase allowed, (e) `PaymentFailure`, (f) `NetworkFailure`. **All tests use `MockPaymentService` (mockito) implementing the `PackagePaymentAdapter` domain interface** — not the Data impl (R6). Mock `PatientPackageRepository`.
- [ ] T032 [US1] Implement `PurchasePackageUseCase` in `lib/features/packages/domain/usecases/purchase_package_usecase.dart`: (1) call `findActiveOrPendingByPackageId` → return `PackageAlreadyActiveFailure` if found; (2) call `PackagePaymentAdapter.initiatePayment` (injected domain interface — R6); (3) on `PaymentSuccess`: create patient package doc with `status=ACTIVE`, mandatory non-null `paymentTransactionId=transactionId`, `purchaseDate`, `expiryDate=purchaseDate+validityDays×86400s`, `totalServicesCount`, `usedServicesCount=0`, `servicesUsage` initialised; (4) on failure: return typed failure, no write — spec.md §7.4, §7.5

### Riverpod Providers – US1

- [ ] T033 [US1] Create Riverpod providers/notifiers for the browse flow in `lib/features/packages/presentation/providers/packages_provider.dart`: `categoryPackagesProvider(clinicId, category)` (AsyncNotifierProvider), `packageDetailsProvider(clinicId, packageId)` (AsyncNotifierProvider), `purchasePackageProvider` (StateNotifierProvider managing button state: idle/loading/success/failure) — use `ref.watch` for auth, never `!` on user

### Patient Screens – US1

- [ ] T034 [US1] Replace "Video Consultation" button in the Operations section screen with a "الباقات" button that navigates to the Package Categories screen — locate existing Operations screen; do not break existing navigation
- [ ] T035 [P] [US1] Create `PackageCategoriesPage` in `lib/features/packages/presentation/pages/package_categories_page.dart`: displays 5 category cards with Arabic names; each card passes correct `clinicId` (from `clinic_ids.dart` — R13) + `category` pair; RTL layout; static list (no network call)
- [ ] T036 [US1] Create `CategoryPackagesListPage` in `lib/features/packages/presentation/pages/category_packages_list_page.dart`: uses `categoryPackagesProvider`; loading state; empty state (*"لا توجد باقات متاحة في هذا القسم حاليًا"*); error state with retry; list of `PackageCard` widgets sorted featured-first
- [ ] T037 [P] [US1] Create `PackageCard` widget in `lib/features/packages/presentation/widgets/package_card.dart`: Arabic name, shortDescription, price (`"[price] جنيه"`), featured badge *"الأكثر اختيارًا"* amber/gold if `isFeatured=true`; RTL layout; tappable
- [ ] T038 [US1] Create `PackageDetailsPage` in `lib/features/packages/presentation/pages/package_details_page.dart`: watches `packageDetailsProvider` + `purchasePackageProvider` + **`ConnectivityProvider` (T002b) for offline detection (R7)**; button states: idle→"اشترِ الآن", loading→spinner+disabled, success→"عرض الباقة", already-purchased→"عرض الباقة"; **when `isOnline = false`: disable buy button + show Arabic tooltip (R7)**; on deactivated clinic: error banner + hide button (spec.md §7.9)
- [ ] T039 [P] [US1] Create `PackageStatusBadge` widget in `lib/features/packages/presentation/widgets/package_status_badge.dart`: renders ACTIVE/COMPLETED/EXPIRED/PENDING with Arabic labels and distinct colors

### Tests – US1

- [ ] T040 [P] [US1] Write widget test for `CategoryPackagesListPage` in `test/widget/features/packages/patient/category_packages_list_page_test.dart`: (a) loading, (b) empty state (Arabic message), (c) loaded (cards shown), (d) error (retry button)
- [ ] T041 [P] [US1] Write widget test for `PackageDetailsPage` in `test/widget/features/packages/patient/package_details_page_test.dart`: (a) idle button = "اشترِ الآن" enabled, (b) loading → spinner+disabled, (c) success → "عرض الباقة", (d) already-purchased → "عرض الباقة" on load, (e) `ClinicUnavailableFailure` → error banner + button hidden, **(f) offline state → buy button disabled with Arabic tooltip (R7)**

**Checkpoint ✅**: Patient can browse packages and complete a purchase. US1 independently functional.

---

## Phase 4: US2 – Patient My Packages Tab (P2)

**Goal**: Patient can see all purchased packages with status and progress, open a details view, and see linked documents.

**Independent test**: Widget test for `MyPackagesPage`; unit tests for `GetPatientPackagesUseCase` and `GetPatientPackageDetailsUseCase`.

### Domain Use Cases – US2

- [x] T042 [P] [US2] Write unit tests for `GetPatientPackagesUseCase` in `test/unit/features/packages/domain/get_patient_packages_usecase_test.dart`: (a) happy path (list), (b) empty list, (c) network error, (d) verify expiry re-derivation (ACTIVE + `expiryDate < now()` → displayed as EXPIRED — spec.md §6.1), **(e) assert `notes` field is `null` on every returned entity (R2) — even when Firestore document contains a non-null `notes` value**
- [x] T043 [P] [US2] Implement `GetPatientPackagesUseCase` in `lib/features/packages/domain/usecases/get_patient_packages_usecase.dart`: calls `PatientPackageRepository.getPatientPackages(patientId)` which uses the `fromFirestoreForPatient()` model (notes = null); scoped to authenticated `patientId` from `authProvider` (never `!`); returns list ordered by `purchaseDate` descending — spec.md §8.1, R2
- [x] T044 [P] [US2] Write unit tests for `GetPatientPackageDetailsUseCase` in `test/unit/features/packages/domain/get_patient_package_details_usecase_test.dart`: (a) happy path (entity + documents), (b) `PackageNotFoundFailure`, **(c) assert `notes` is absent from entity returned to patient (R2)**
- [x] T045 [P] [US2] Implement `GetPatientPackageDetailsUseCase` in `lib/features/packages/domain/usecases/get_patient_package_details_usecase.dart`: calls `PatientPackageRepository.getPatientPackageByIdForPatient()` (notes stripped — R2) + `getDocumentsByPatientPackage()` (Index 6); returns combined entity — spec.md §8.1, §9.10

### Riverpod Providers – US2

- [x] T046 [US2] Create providers for My Packages in `lib/features/packages/presentation/providers/my_packages_provider.dart`: `myPackagesProvider` (AsyncNotifierProvider, auto-refreshes on purchase event), `patientPackageDetailProvider(patientPackageId)` — null-check user via `authProvider` before building

### Patient Screens – US2

- [x] T047 [US2] Add *"باقاتي"* tab to the patient profile tab bar; wire to `MyPackagesPage` — locate existing patient profile screen; do not break existing tabs
- [x] T048 [US2] Create `MyPackagesPage` in `lib/features/packages/presentation/pages/my_packages_page.dart`: loading, empty state (*"لم تشترِ أي باقة بعد…"* with CTA), error+retry, list of `PatientPackageCard` widgets; dates via `DateFormat.yMMMMd('ar')`; progress `"X / Y"` + `LinearProgressIndicator` in `Directionality(ltr)` — spec.md §9.4, §9.14
- [x] T049 [P] [US2] Create `PackageProgressWidget` in `lib/features/packages/presentation/widgets/package_progress_widget.dart`: `"X / Y"` text + `LinearProgressIndicator` inside `Directionality(TextDirection.ltr)` — spec.md §9.4
- [x] T050 [US2] Create `MyPackagesDetailPage` in `lib/features/packages/presentation/pages/my_packages_detail_page.dart`: per-service usage rows; documents section (tap → full-screen viewer); empty documents state; **`notes` field NOT shown (R2)**; deactivated clinic packages still shown with banner (spec.md §9.11)
- [x] T051 [P] [US2] Create `PackageDocumentCard` widget in `lib/features/packages/presentation/widgets/package_document_card.dart`: Arabic title, documentType label, formatted `uploadedAt`, open/download buttons

### Tests – US2

- [x] T052 [P] [US2] Write widget test for `MyPackagesPage` in `test/widget/features/packages/patient/my_packages_page_test.dart`: (a) loading, (b) empty+CTA, (c) list with status labels+progress, (d) expired package = "منتهية الصلاحية"
- [x] T053 [US2] Write integration test in `test/integration/packages_flow_test.dart`: Operations → "الباقات" → category → package → "اشترِ الآن" (**DI override with `FakePaymentService` from `test/helpers/fake_payment_service.dart` — R8**, `shouldSucceed = true`) → assert button = "عرض الباقة" → My Packages → assert status "نشطة" + progress "0 / N" — spec.md §10.3

**Checkpoint ✅**: Patient full purchase + My Packages flow working end-to-end.

---

## Phase 5: US3 – Admin Packages Management (P3)

**Goal**: Admin/doctor can list, create, edit, activate/deactivate, and duplicate clinic packages.

**Independent test**: Widget tests for `AdminPackagesListPage` and `CreateEditPackagePage`; unit tests for all admin use cases.

### Domain Use Cases – US3

- [x] T054 [P] [US3] Write unit tests for `CreateClinicPackageUseCase` in `test/unit/features/packages/domain/create_clinic_package_usecase_test.dart`: (a) happy path → new packageId, (b) name > 200 chars → validation failure, (c) derived booleans recomputed from `packageType`; **mock `ClinicAccessResolver` to return correct `clinicId` (R4)**
- [x] T055 [P] [US3] Implement `CreateClinicPackageUseCase` in `lib/features/packages/domain/usecases/create_clinic_package_usecase.dart`: get `clinicId` via injected `ClinicAccessResolver` (R4); validate all fields per data-model.md §3.2; compute derived booleans; compute `displayOrder` default (last+1); write with `createdAt=updatedAt=serverTimestamp()`
- [x] T056 [P] [US3] Write unit tests for `UpdateClinicPackageUseCase` in `test/unit/features/packages/domain/update_clinic_package_usecase_test.dart`: (a) happy path, (b) `StaleDataFailure` when `updatedAt` mismatch, **(c) `StaleDataFailure` when `loadedAt` is `null` (must return immediately, no Firestore read — R1)**, (d) derived booleans recomputed
- [x] T057 [P] [US3] Implement `UpdateClinicPackageUseCase` in `lib/features/packages/domain/usecases/update_clinic_package_usecase.dart`: receives mandatory `loadedAt: Timestamp` parameter; **(R1) if `loadedAt` is null → return `StaleDataFailure` immediately**; read current `updatedAt` from Firestore; if mismatch → `StaleDataFailure`; validate; recompute derived booleans; write `updatedAt=serverTimestamp()`. **The form mount in `CreateEditPackagePage` (T067) must read `updatedAt` on load and pass it as `loadedAt` to this use case (R1).**
- [x] T058 [P] [US3] Write unit tests for `TogglePackageStatusUseCase` in `test/unit/features/packages/domain/toggle_package_status_usecase_test.dart`: ACTIVE→INACTIVE, INACTIVE→ACTIVE, ACTIVE→HIDDEN
- [x] T059 [P] [US3] Implement `TogglePackageStatusUseCase` in `lib/features/packages/domain/usecases/toggle_package_status_usecase.dart`: updates only `status` + `updatedAt=serverTimestamp()` — spec.md §8.2
- [x] T060 [P] [US3] Write unit tests for `ListClinicPackagesForAdminUseCase` in `test/unit/features/packages/domain/list_clinic_packages_for_admin_usecase_test.dart`: (a) happy path paginated, (b) empty, (c) filters (category, status, isFeatured), **(d) `ADMIN_CLINIC` only sees their allowedClinics (mock `ClinicAccessResolver` — R4)**
- [x] T061 [P] [US3] Implement `ListClinicPackagesForAdminUseCase` in `lib/features/packages/domain/usecases/list_clinic_packages_for_admin_usecase.dart`: get `clinicId`(s) via **`ClinicAccessResolver` (R4)** — no ad-hoc derivation; cursor-based pagination `limit(20)`; accept optional `category`, `status`, `isFeatured` filters — spec.md §8.2
- [x] T062 [P] [US3] Write unit tests for `DuplicatePackageUseCase` in `test/unit/features/packages/domain/duplicate_package_usecase_test.dart`: (a) happy path → new packageId, (b) status=INACTIVE, (c) displayOrder=last+1, (d) name = "نسخة من: "+original, (e) `PackageNotFoundFailure`
- [x] T063 [P] [US3] Implement `DuplicatePackageUseCase` in `lib/features/packages/domain/usecases/duplicate_package_usecase.dart`: read source; copy with overrides (id=new, status=INACTIVE, displayOrder=last+1, name="نسخة من: "+original, timestamps=serverTimestamp()); write — spec.md §9.9

### Riverpod Providers – US3

- [x] T064 [US3] Create admin packages providers in `lib/features/packages/presentation/providers/admin_packages_provider.dart`: `adminPackagesListProvider` (AsyncNotifier, paginated), `createEditPackageProvider`, `togglePackageStatusProvider`, `duplicatePackageProvider`. **Resolve `clinicId` via `ClinicAccessResolver` (R4), not ad-hoc from auth object.**

### Admin Screens – US3

- [x] T065 [US3] Add *"الباقات"* tab to the admin dashboard navigation. **Derive `clinicId` exclusively via `ClinicAccessResolver` (R4).** Wire to `AdminPackagesListPage`.
- [x] T066 [US3] Create `AdminPackagesListPage` in `lib/features/packages/presentation/pages/admin/admin_packages_list_page.dart`: paginated list (name, category, status, price, displayOrder, isFeatured); filters; Edit/Toggle/Duplicate actions; empty state; FAB "إضافة باقة"
- [x] T067 [US3] Create `CreateEditPackagePage` in `lib/features/packages/presentation/pages/admin/create_edit_package_page.dart`: all fields per spec.md §9.12 + data-model.md §3.2; **on form mount for EDIT mode: read current `updatedAt` from Firestore and store as `loadedAt` in form state — pass `loadedAt` to `UpdateClinicPackageUseCase` (R1)**; `StaleDataFailure` → Arabic reload prompt; inline Arabic validation errors; services list editor; discount preview

### Tests – US3

- [x] T068 [P] [US3] Write widget test for `AdminPackagesListPage` in `test/widget/features/packages/admin/admin_packages_list_page_test.dart`: (a) loading, (b) empty, (c) list columns, (d) filter reload, (e) action buttons
- [x] T069 [P] [US3] Write widget test for `CreateEditPackagePage` in `test/widget/features/packages/admin/create_edit_package_page_test.dart`: (a) empty name → Arabic validation error, (b) price=0 → error, (c) empty services → error, (d) happy path submit, (e) packageType dropdown recomputes derived booleans, **(f) edit mode reads `updatedAt` on mount (R1)**

**Checkpoint ✅**: Admin can fully manage clinic packages. US3 independently functional.

---

## Phase 6: US4 – Admin Patient Packages & Document Upload (P4)

**Goal**: Admin/doctor can view patient packages, upload documents, and record service usage.

**Independent test**: Widget test for admin patient packages; unit tests for `GetPatientPackagesForAdminUseCase`, `UploadPackageDocumentUseCase`, `UpdatePackageServiceUsageUseCase`.

### Domain Use Cases – US4

- [ ] T070 [P] [US4] Write unit tests for `GetPatientPackagesForAdminUseCase` in `test/unit/features/packages/domain/get_patient_packages_for_admin_usecase_test.dart`: (a) happy path paginated, (b) empty, **(c) `notes` field IS included in returned entity (admin-facing — R2)**
- [ ] T071 [P] [US4] Implement `GetPatientPackagesForAdminUseCase` in `lib/features/packages/domain/usecases/get_patient_packages_for_admin_usecase.dart`: calls `PatientPackageRepository.listPatientPackagesForAdmin()` which uses **`fromFirestoreForAdmin()`** model (notes included — R2); `limit(20)` pagination — spec.md §7.8, §8.3
- [ ] T072 [P] [US4] Write unit tests for `UploadPackageDocumentUseCase` in `test/unit/features/packages/domain/upload_package_document_usecase_test.dart`: (a) happy path → documentId, (b) `UploadFailure` on Storage error, (c) file > 20 MB → `UploadFailure`, (d) unsupported type → `UploadFailure`, (e) `serviceId = null` is valid, (f) `NetworkFailure` if offline
- [ ] T073 [P] [US4] Implement `UploadPackageDocumentUseCase` in `lib/features/packages/domain/usecases/upload_package_document_usecase.dart`: (1) validate file size ≤ 20 MB + type ∈ {pdf, jpg, jpeg, png}; (2) delegate to `FirebaseStoragePackageDatasource.uploadDocument()` (R5); (3) write Firestore doc via `FirestorePackageDatasource`; (4) send FCM notification (best-effort, no failure on FCM error) — spec.md §7.11, §9.13, §7.15
- [ ] T074 [P] [US4] Write unit tests for `UpdatePackageServiceUsageUseCase` in `test/unit/features/packages/domain/update_package_service_usage_usecase_test.dart`: (a) increment `usedCount`, (b) reaching `quantity` → `usedServicesCount` incremented, (c) partial use does NOT increment `usedServicesCount`, **(d) simulate two concurrent calls to the use case for the same service — assert that the Firestore Transaction mock verifies commit-once semantics and no usedCount is silently lost (R3, R10)**
- [ ] T075 [P] [US4] Implement `UpdatePackageServiceUsageUseCase` in `lib/features/packages/domain/usecases/update_package_service_usage_usecase.dart`: **uses `FirebaseFirestore.runTransaction()` (R3)** — reads `servicesUsage` inside the transaction, increments `usedCount` for the target service, recomputes `usedServicesCount` = count of services where `usedCount >= quantity`, writes the updated arrays + `updatedAt=serverTimestamp()`. **No direct `update()` call on `servicesUsage` or `usedServicesCount`** — spec.md §7.12, §9.4 (CHK020)

### Riverpod Providers – US4

- [ ] T076 [US4] Create admin patient packages providers in `lib/features/packages/presentation/providers/admin_patient_packages_provider.dart`: `adminPatientPackagesProvider(patientId)` (AsyncNotifier, paginated), `uploadDocumentProvider(patientId, patientPackageId)` (StateNotifier for upload progress)

### Admin Screens – US4

- [ ] T077 [US4] Add *"باقات المريض"* section to the existing admin patient detail page; wire to `adminPatientPackagesProvider(patientId)`
- [ ] T078 [US4] Create `AdminPatientPackagesPage` / section widget in `lib/features/packages/presentation/pages/admin/admin_patient_packages_page.dart`: list of patient packages (name, category, status, progress X/Y, dates in Arabic locale); empty state; tap → `AdminPatientPackageContextView`; `notes` editable and visible (R2, admin only)
- [ ] T079 [US4] Create `AdminPatientPackageContextView` in `lib/features/packages/presentation/pages/admin/admin_patient_package_context_view.dart`: services with `usedCount/quantity` per service; documents list per service; FAB "رفع مستند" → upload bottom sheet; role labels ("طبيب" / "أدمن")
- [ ] T080 [US4] Create `DocumentUploadBottomSheet` in `lib/features/packages/presentation/widgets/document_upload_bottom_sheet.dart`: documentType dropdown (Arabic labels), title (required), description (optional), serviceId optional, file picker (PDF/JPEG/PNG); client-side size validation ≤ 20 MB; upload progress via `uploadDocumentProvider`; error/success states in Arabic

### Tests – US4

- [ ] T081 [P] [US4] Write widget test for admin patient packages section in `test/widget/features/packages/admin/admin_patient_packages_page_test.dart`: (a) loading, (b) empty state, (c) list columns, (d) document upload button visible, **(e) `notes` field visible for admin/doctor (R2)**

**Checkpoint ✅**: Admin can view patient packages and upload documents. Documents visible to patient. US4 independently functional.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Cloud Function, performance, RTL/date format audit, DartDoc compliance, analysis, and coverage gate.

- [ ] T082 Create/update the expiry Cloud Function in `functions/src/expire_packages.ts`: scheduled trigger `europe-west1`, daily midnight Cairo time (UTC+2 cron); **uses collection group query `collectionGroup('packages').where('status', '==', 'ACTIVE').where('expiryDate', '<', now())` backed by Index 8 (collection group index — R9)**; batched updates: `status='EXPIRED'`, `updatedAt=serverTimestamp()`; batch size ≤ 500; retry policy enabled. Verify service account has collection group read/write IAM permission (T026b) — spec.md §6.1, §10.2
- [ ] T083 [P] RTL audit: open each new screen in Flutter Inspector; confirm Arabic text right-aligned; `LinearProgressIndicator` wrapped in `Directionality(ltr)`; English-only widgets (dates, codes, URLs) also in `Directionality(ltr)` — spec.md §9.14
- [ ] T084 [P] Arabic date format audit: search `lib/features/packages/` for raw `DateTime.toString()` or non-localised date display; ensure all `purchaseDate`, `expiryDate`, `uploadedAt` use `DateFormat.yMMMMd('ar').format(date.toDate())` — spec.md §9.14
- [ ] T085 [P] Firestore offline persistence: verify `FirebaseFirestore.instanceFor(..., databaseId: 'elajtech').settings` includes `persistenceEnabled: true` in the injection module — spec.md §7.10
- [ ] T086 [P] Performance smoke test: run on mid-range Android device or emulator; open Category Packages List; measure time-to-first-content with Flutter DevTools Timeline; confirm ≤ 2 seconds — spec.md §10.1
- [ ] T087 Run `flutter analyze` on the entire project; fix all errors, warnings, and info messages until exit is clean. **Also verify that all new public classes, entities, repositories, and use cases have bilingual `///` DartDoc comments (Arabic + English) per Constitution IV (R11).** Zero issues required before Implementation is considered complete.
- [ ] T088 [P] Run `flutter test --coverage` for the packages feature; verify domain ≥ 80% and data ≥ 70% line coverage; fix any gaps — spec.md §10.4
- [ ] T089 [P] Run `flutter pub run build_runner build --delete-conflicting-outputs` final time; commit `injection_container.config.dart` and all `.g.dart`/`.freezed.dart` files — plan.md §CI/CD

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 1 (Setup)    ──► Phase 2 (Foundation)
                          │
          ┌───────────────┼─────────────────┐
          ▼               ▼                 ▼
   Phase 3 (US1)   Phase 5 (US3)     Phase 5 concurrent
          │               │
          ▼               ▼
   Phase 4 (US2)   Phase 6 (US4)
          │               │
          └──────┬─────────┘
                 ▼
          Phase 7 (Polish)
```

- **Phase 1** (T004→T001→T002→T002b→T005→T005b): No dependencies. Start immediately. T004 is first (R12).
- **Phase 2** (T006–T026b): Depends on Phase 1. Blocks all user-story phases.
- **Phase 3** (T027–T041): Depends on Phase 2. US1 is MVP — prioritise.
- **Phase 4** (T042–T053): Depends on Phase 2. Concurrent with Phase 3 if staffed.
- **Phase 5** (T054–T069): Depends on Phase 2. Concurrent with Phases 3–4.
- **Phase 6** (T070–T081): Depends on Phase 2 (especially T022, T023).
- **Phase 7** (T082–T089): Depends on all previous phases.

### Critical Linear Path (single developer, fastest to MVP)

> T004 → T001 → T002 → T002b → T005b → T003 → T006→T009 → T010→T012 → T090 → T013→T015 → T016a → T016b → T003b → T017→T023 → T024 → T025 → T026 → T026b → T027→T032 → T033 → T034→T039 → T040→T041 → **(MVP validation)**

---

## Resolved Risk Table

| Risk | Category | Original Severity | Resolution Applied | Status |
|---|---|---|---|---|
| **R1** | Optimistic Concurrency | CRITICAL | spec.md §7.13 updated; `loadedAt` mandatory in `UpdateClinicPackageUseCase`; T056(c) + T057 + T067 updated; T069(f) added | ✅ Resolved |
| **R2** | notes field / Firestore limits | CRITICAL | spec.md §7.8 corrected (app-layer enforcement); data-model.md §4.1 annotated; T011 split into patient/admin variants; T014 dual factory; T042(e) + T044(c) + T070(c) + T081(e) tests added | ✅ Resolved |
| **R3** | servicesUsage Concurrency | CRITICAL | spec.md §7.12 + data-model.md §4.1 mandate Firestore Transaction; T075 uses `runTransaction()`; T074(d) adds concurrent-call test | ✅ Resolved |
| **R4** | ClinicAccessResolver | HIGH | spec.md §7.7 defines mechanism; T090 (new task) creates `ClinicAccessResolver`; T055, T061, T064, T065 reference it | ✅ Resolved |
| **R5** | Datasource SRP | HIGH | plan.md + T016a/T016b split datasource into Firestore-only and Storage-only; T023 injects both separately | ✅ Resolved |
| **R6** | PaymentAdapter layer | HIGH | plan.md layering section; T003 moved to Domain; T003b creates Data impl; T031, T032 reference Domain interface | ✅ Resolved |
| **R7** | Offline detection | MEDIUM | spec.md §7.10 names `connectivity_plus`; T002b creates `ConnectivityProvider`; T038 + T041(f) updated | ✅ Resolved |
| **R8** | FakePaymentService | MEDIUM | plan.md §Payment Mock updated; T003b creates `FakePaymentService`; T053 references it explicitly | ✅ Resolved |
| **R9** | Collection group index | MEDIUM | data-model.md §4.2 adds Index 8; T025 + T082 updated; T026b adds IAM/rules for service account | ✅ Resolved |
| **R10** | Concurrent-write test | MEDIUM | T074(d) added concurrent calls test with Transaction mock semantics | ✅ Resolved |
| **R11** | Bilingual DartDoc | LOW | T087 updated to include Constitution IV DartDoc verification | ✅ Resolved |
| **R12** | Router type not confirmed | LOW | T004 moved before T001 in Phase 1 with explicit "confirm router type first" note | ✅ Resolved |
| **R13** | clinicId values not normalised | LOW | T005b (new task) creates `clinic_ids.dart` constants file; T017–T021 reference `ClinicIds` constants | ✅ Resolved |

---

## Notes

- **[P]** = parallelisable within its phase
- **[USn]** = traceability label to user story
- Every task references its `spec.md` / `plan.md` / `data-model.md` section
- Run `flutter pub run build_runner build --delete-conflicting-outputs` after every `@injectable`/`@freezed`/`@JsonSerializable` change
- Never use `FirebaseFirestore.instance` — always use injected `elajtech` instance
- Never use `!` on the auth user object — always null-check via `authProvider`
- Commit after each phase checkpoint; open a PR per user story for independent review

---

<div dir="rtl">

## ملاحظات بالعربية

**ملخص التعديلات (R1–R13)**:

- **R1**: تعديل §7.13 في spec.md — يجب تمرير `loadedAt` للـ UseCase، وإذا كانت `null` يُعاد `StaleDataFailure` فوراً.
- **R2**: تصحيح §7.8 — إخفاء `notes` يتم في طبقة التطبيق لا في قواعد Firestore؛ نموذجان: `fromFirestoreForPatient` و`fromFirestoreForAdmin`.
- **R3**: §7.12 ملزمة بـ Firestore Transaction لكل كتابة على `servicesUsage`.
- **R4**: مهمة جديدة T090 — `ClinicAccessResolver` مرجع موحد لاستنتاج `clinicId`.
- **R5**: T016a (Firestore فقط) + T016b (Storage فقط) لاحترام مبدأ SRP.
- **R6**: واجهة `PackagePaymentAdapter` في طبقة Domain، التنفيذ في Data — لا انتهاك لـ Clean Architecture.
- **R7**: T002b ينشئ `ConnectivityProvider` باستخدام `connectivity_plus`.
- **R8**: T003b ينشئ `FakePaymentService` في `test/helpers/` للاختبارات التكاملية.
- **R9**: Index 8 (collection group) مضاف إلى data-model.md وT025 وT082.
- **R10**: اختبار (d) في T074 يُحاكي استدعاءين متزامنين مع التحقق من سلوك Transaction.
- **R11**: T087 محدّث ليشمل التحقق من توثيق DartDoc ثنائي اللغة.
- **R12**: T004 أصبح أول مهمة في المرحلة الأولى للتحقق من نوع الـ Router.
- **R13**: T005b ينشئ ملف `clinic_ids.dart` بثوابت `clinicId` الحقيقية.

</div>
