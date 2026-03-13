# Tasks: Simulated Package Purchase (Test Stub)

**Input**: [spec.md](file:///C:/Users/moham/Desktop/androcare/elajtech/elajtech/specs/003-test-package-purchase/spec.md), [plan.md](file:///C:/Users/moham/Desktop/androcare/elajtech/elajtech/specs/003-test-package-purchase/plan.md), [quality_checklist.md](file:///C:/Users/moham/Desktop/androcare/elajtech/elajtech/specs/003-test-package-purchase/checklists/quality_checklist.md)

| Task ID | Title | Priority | Est. Hours | Dependencies | Files | Status |
|---------|-------|----------|------------|--------------|-------|--------|
| T001 | Verify project structure | Low | 0.5 | None | None | [ ] |
| T002 | Run build_runner check | Low | 0.5 | None | None | [ ] |
| T003 | Update PatientPackageEntity | High | 1.0 | None | lib/features/packages/domain/entities/patient_package_entity.dart | [ ] |
| T004 | Update PatientPackageModel | High | 1.5 | T003 | lib/features/packages/data/models/patient_package_model.dart | [ ] |
| T005 | Update Repository Interface | Medium | 1.0 | T003 | lib/features/packages/domain/repositories/patient_package_repository.dart | [ ] |
| T006 | Update Repository Impl | High | 2.0 | T005, T004 | lib/features/packages/data/repositories/patient_package_repository_impl.dart | [ ] |
| T007 | Update PurchasePackageUseCase | High | 2.5 | T006 | lib/features/packages/domain/usecases/purchase_package_usecase.dart | [ ] |
| T008 | Create Unit Tests (Model) | Medium | 1.5 | T004 | test/unit/features/packages/data/models/patient_package_model_test.dart | [ ] |
| T009 | Create Unit Tests (UseCase) | Medium | 2.0 | T007 | test/unit/features/packages/domain/usecases/purchase_package_usecase_test.dart | [ ] |
| T010 | Implement Test Dialog UI | High | 3.0 | T007 | lib/features/packages/presentation/pages/package_details_page.dart | [ ] |
| T011 | Implement Post-Purchase Navigation | High | 1.0 | T010 | lib/features/packages/presentation/pages/package_details_page.dart | [ ] |
| T012 | Create Widget Test (Dialog) | Medium | 2.5 | T010 | test/widget/features/packages/presentation/pages/package_details_page_test.dart | [ ] |
| T013 | Bilingual Documentation | Medium | 1.0 | All | All modified files | [ ] |
| T014 | Admin Dashboard Indicator | Critical | 4.0 | T007 | lib/features/admin/presentation/screens/admin_dashboard_screen.dart | [ ] |
| T015 | Patient MyPackages Label | Critical | 3.0 | T007 | lib/features/packages/presentation/pages/my_packages_page.dart | [ ] |
| T016 | Final Analysis & Tests | Critical | 2.0 | All | All | [ ] |

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Initial verification and dependency check.

- [x] T001 Verify branch `003-test-package-purchase` and project root `lib/features/packages/`
- [x] T002 Run `flutter pub run build_runner build --delete-conflicting-outputs` to ensure clean state before changes

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core data layer updates required for all flows.

- [x] T003 [P] [US2] Add `isTestPurchase` field to `PatientPackageEntity` in `lib/features/packages/domain/entities/patient_package_entity.dart`.
- [x] T004 [P] [US2] Update `PatientPackageModel` to handle `isTestPurchase` in `fromFirestore` and `toFirestore` in `lib/features/packages/data/models/patient_package_model.dart`.
- [x] T005 [P] [US2] Add `isTestPurchase` parameter to `createPatientPackage` in `PatientPackageRepository` interface.
- [x] T006 [US2] Implement `isTestPurchase` logic in `PatientPackageRepositoryImpl` using `databaseId: 'elajtech'` and `debugPrint` for writes.

---

## Phase 3: User Story 2 - Test Data Persistence (Priority: P2)

**Goal**: Persist test purchases with the `isTestPurchase: true` flag.

**Independent Test**: Perform a purchase and check Firestore document for `isTestPurchase: true`.

- [x] T007 [US2] Update `PurchasePackageUseCase` to bypass `PackagePaymentAdapter` for test purchases and pass `isTestPurchase: true` to repo.
- [x] T008 [Q] [US2] Create unit test for `PatientPackageModel` verifying `isTestPurchase` field parsing/serialization.
- [x] T009 [US2] Update `PurchasePackageNotifier` in `packages_provider.dart` to handle the simulated flow.

---

## Phase 4: User Story 1 - Simulated Purchase Flow (Priority: P1) 🎯 MVP

**Goal**: Implement the user-facing test purchase dialog and navigation.

**Independent Test**:- [x] T010 [US1] Update `PackageDetailsBuyButton` to trigger `SimulatedPurchaseDialog` before calling `purchase()`.
- [x] T011 [US1] Implement `SimulatedPurchaseDialog` widget with required Arabic/English text in `lib/features/packages/presentation/widgets/simulated_purchase_dialog.dart`.
- [x] T012 [US2] Add visual "Test Purchase" indicator to `_PatientPackageCard` in `MyPackagesPage`.
 in `PackageDetailsPage`.

---

## Phase 5: UI Extensions (Critical Visibility)

**Purpose**: Address Admin and Patient visibility for test purchases (CA-001, CA-002).

- [x] T014 [US4] Add Test Purchase Indicator to Admin Dashboard package management screens (Patient Portfolio).
- [x] T015 [US4] Add Test Purchase Filter toggle to `AdminPatientPackagesPage`.
- [x] T017 [US1/US4] Add Bilingual DartDoc (Arabic/English) to all new/modified presentation components.
ip to `MyPackagesPage` list items for test purchases in `lib/features/packages/presentation/pages/my_packages_page.dart`.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Documentation, static analysis, and regression testing.

- [x] T013 [P] Add bilingual DartDoc (Arabic + English) with usage examples to all modified public entities and methods.
- [x] T016 Run `flutter analyze` and verify zero errors/warnings in modified files.
- [x] T017 Run relevant unit and widget tests to ensure zero regressions.
- [x] T018 Mark all test logic with `// TODO: Remove when real payment gateway integrated`.
- [x] T020 Prepare final walkthrough with screenshots.

---

## Dependencies & Execution Order

- **Foundational (Phase 2)**: MUST complete before Phase 3 and 4.
- **US2 (Phase 3)**: Provides the data persistence logic for US1.
- **US1 (Phase 4)**: UI implementation depends on use case and repository changes.
- **Polish (Phase 5)**: Final cleanup and verification.

### Parallel Opportunities
- T003, T004, T005 can be started simultaneously.
- T008, T012 (Tests) can be developed alongside implementation.

---

## Implementation Strategy
1. **MVP First**: T003 → T004 → T006 → T007 → T010 → T011.
2. **Verify**: Run manual check on device/simulator.
3. **Robustness**: Complete all unit and widget tests.
4. **Compliance**: Add documentation and run analysis.
