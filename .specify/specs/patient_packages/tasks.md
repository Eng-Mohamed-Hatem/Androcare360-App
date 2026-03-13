# Implementation Tasks: Patient "My Packages" Enhancement

## Phase 1: Domain & Data Layer (Persistence Fix)
- [ ] **Task 1: Update Entities**
    - [ ] Add `description`, `shortDescription`, `validityDays` to `PatientPackageEntity`.
    - [ ] Add bilingual DartDoc with usage examples.
- [ ] **Task 2: Update Models**
    - [ ] Update `PatientPackageModel.fromFirestore` and `toFirestore`.
    - [ ] Ensure legacy record compatibility (fallbacks).
- [ ] **Task 3: Repository & Use Case Fix**
    - [ ] Update `PatientPackageRepository.createPatientPackage` interface.
    - [ ] Implement fix in `PatientPackageRepositoryImpl` (incl. `packageName`).
    - [ ] Update `PurchasePackageUseCase` to pass the new metadata.
- [ ] **Task 4: Build Runner**
    - [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs`.

## Phase 2: Presentation Layer (UI Enhancement)
- [ ] **Task 5: Update "My Packages" List**
    - [ ] Ensure human-readable `packageName` is the title in `_PatientPackageCard`.
- [ ] **Task 6: Update "Package Details" Screen**
    - [ ] Show human-readable `packageName` in the header.
    - [ ] Implement "Package Info" section.
    - [ ] Enhance "Included Services & Usage" section:
        - [ ] Service icons and display names.
        - [ ] Usage ratio with LTR directionality.
        - [ ] Percentage-based progress bars.
        - [ ] 0% fallback for missing usage data.

## Phase 3: Verification & QA
- [ ] **Task 7: Automated Testing**
    - [ ] Create `test/features/packages/presentation/pages/my_packages_detail_page_test.dart`.
    - [ ] Verify 0%, 50%, 100% usage states.
    - [ ] Run `test/integration/packages_flow_test.dart`.
- [ ] **Task 8: Manual Verification**
    - [ ] Perform a test purchase and verify name/details correctness.
- [ ] **Task 9: Final Quality Checks**
    - [ ] Run `flutter analyze`.
    - [ ] Run `flutter test`.
