# Tasks: Patient Packages UI and Data Display Update

**Feature**: [spec.md](file:///C:/Users/moham/Desktop/androcare/elajtech/elajtech/specs/004-implement-ui-and-data-display-update-for-the-patient-packages-in-the-androcare-elajtech-app/spec.md) | **Plan**: [plan.md](file:///C:/Users/moham/Desktop/androcare/elajtech/elajtech/specs/004-implement-ui-and-data-display-update-for-the-patient-packages-in-the-androcare-elajtech-app/plan.md)

## Phase 1: Domain & Data Layers (Foundation)

- [x] **T-101**: Update `PatientPackageEntity` to include `packageServices` list. <!-- id: 101 -->
- [x] **T-102**: Update `PatientPackageModel` to handle `packageServices` serialization (from/to Firestore). <!-- id: 102 -->
- [x] **T-103**: Update `PatientPackageRepositoryImpl.createPatientPackage` to pass `packageServices` during purchase. <!-- id: 103 -->
- [x] **T-104**: Run `build_runner` to update generated code. <!-- id: 104 -->
- [x] **T-105**: Update unit tests for `PatientPackageModel` to verify new fields. <!-- id: 105 -->

## Phase 2: Legacy Data Migration

- [x] **T-201**: Implement `PackageMigrationService` to backfill `packageName` and `packageServices` into existing Firestore docs. <!-- id: 201 -->
- [x] **T-202**: Execute migration (via a temporary test or script). <!-- id: 202 -->

## Phase 3: Presentation Layer (UI)

- [x] **T-301**: Add bottom padding (100px) to `CategoryPackagesListPage` ListView. <!-- id: 301 -->
- [x] **T-302**: Update `MyPackagesPage` card to display `packageName`. <!-- id: 302 -->
- [x] **T-303**: Update `MyPackagesDetailPage` header to display `packageName`. <!-- id: 303 -->
- [x] **T-304**: Refactor `MyPackagesDetailPage` to display usage rows based on `packageServices`. <!-- id: 304 -->
- [x] **T-305**: Implement progress bar and usage ratio calculation in usage rows. <!-- id: 305 -->

## Phase 4: Verification

- [ ] **T-401**: Run `flutter analyze` and ensure zero errors. <!-- id: 401 -->
- [ ] **T-402**: Run full test suite. <!-- id: 402 -->
- [ ] **T-403**: Perform manual UI verification. <!-- id: 403 -->
