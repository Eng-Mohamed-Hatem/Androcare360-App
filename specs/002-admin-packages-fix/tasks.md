# Tasks: Admin Packages UI and Creation Fix

**Input**: Design documents from `specs/002-admin-packages-fix/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), implementation_plan.md

**Organization**: Tasks are organized by user story (Story) and development phases.

## Format: `- [ ] [ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Verify project structure and clinic ID constants in `lib/features/packages/data/constants/clinic_ids.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [x] T002 [P] Update `PackageCategory` enum with Arabic labels and ensure mapping in `lib/features/packages/domain/entities/package_entity.dart`
- [x] T003 [P] Ensure `adminSelectedClinicProvider` is correctly defined in `lib/features/packages/presentation/providers/admin_packages_provider.dart`

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Clinic Package Management Navigation (Priority: P1) 🎯 MVP

**Goal**: Implement a visual grid of clinics for easy navigation to package management.

**Independent Test**: Navigate to Admin -> Packages. Verify 5 clinic cards. Tap one and land on the correct `AdminPackagesListPage`.

### Implementation for User Story 1

- [x] T004 [P] [US1] Create `AdminPackagesGridPage` with clinic cards in `lib/features/packages/presentation/pages/admin_packages_grid_page.dart` (Include bilingual /// documentation)
- [x] T005 [P] [US1] Create widget test for clinic grid navigation in `test/widget/features/packages/admin/admin_packages_grid_page_test.dart`
- [x] T006 [US1] Refactor `AdminPackagesListPage` to remove dropdown and ensure proper Tab-Bar filtering (Include fallback redirect if clinic is null) in `lib/features/packages/presentation/pages/admin_packages_list_page.dart`
- [x] T007 [US1] Register/Update routing to point to `AdminPackagesGridPage` as the main entry for Admin Packages

**Checkpoint**: User Story 1 is functional. Admin can select clinics via Grid.

---

## Phase 4: User Story 2 & 3 - Enhanced Form & Numeric Validation (Priority: P1/P2)

**Goal**: Support multi-line Arabic input, character counters, and fixed numeric validation for services.

**Independent Test**: Open "Create Package" form. Type Arabic in descriptions (multi-line). Add service quantity "5". Verify counters and persistence.

### Implementation for User Story 2 & 3

- [x] T008 [US2] Refactor `CreateEditPackagePage` descriptions (`short` and `detailed`) to support multi-line Arabic input with character counters and no small-screen overflow in `lib/features/packages/presentation/pages/create_edit_package_page.dart`
- [x] T009 [US2] Update `category` and `type` dropdowns in `CreateEditPackagePage` to display localized Arabic labels while maintaining enum bindingseCategory` and `PackageType` dropdowns in `lib/features/packages/presentation/pages/create_edit_package_page.dart`
- [x] T010 [P] [US3] Fix `quantity` field binding and 1-99 range validation in `lib/features/packages/presentation/pages/create_edit_package_page.dart`
- [x] T011 [US3] Ensure `PackageServiceItem` in `lib/features/packages/domain/entities/package_service_item.dart` correctly handles numeric quantity during creation

**Checkpoint**: Form is enhanced with better UX, localization, and fixed numeric fields.

---

## Phase 5: User Story 4 - Reliable Package Submission (Priority: P2)

**Goal**: Ensure robust validation, clear error feedback, and diagnostic logging.

**Independent Test**: Submit invalid form (verify inline errors). Submit valid form (verify success Snackbar). Simulate error (verify Snackbar + console log).

### Implementation for User Story 4

- [x] T012 [Domain/Data] Review and adjust package creation use case and repository to handle new/updated fields with proper `Either<Failure, T>` error handling (Include bilingual /// documentation)
- [x] T013 [UX/Error handling] Ensure "Create Package" button triggers validation, shows clear error messages on failure, and logs diagnostics (User ID, Clinic ID, Package ID) according to Elajtech rules/packages/presentation/pages/create_edit_package_page.dart`
- [x] T014 [US4] Add/Update widget tests for form validation, multi-line growth, character counters, and error states in `test/widget/features/packages/admin/create_edit_package_page_test.dart`

**Checkpoint**: Package creation is reliable with clear feedback and proper logging.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final touches and wide-ranging verifications.

- [x] T015 [P] Run `flutter analyze` and fix any new warnings
- [x] T016 [P] Verify LTR/RTL layout consistency for English content in clinical forms
- [x] T017 [P] Execute full manual verification checklist from `implementation_plan.md` (Include SC-001 Navigation < 10s check)
- [x] T018 Run `build_runner` to ensure DI and JSON serialization are up to date

---

## Dependencies & Execution Order

- **Setup & Foundational**: T001-T003 MUST be completed first.
- **User Story 1**: T004-T007 can proceed immediately after Foundation.
- **User Story 2 & 3**: T008-T011 can be worked on in parallel with US1.
- **User Story 4**: T012-T014 depends on US2/US3 form changes.
- **Polish**: T015-T018 runs after implementation is complete.

---

## Implementation Strategy

1. **MVP**: Complete US1 (Grid Navigation) and foundational form fixes (US2/US3).
2. **Incremental**: Add US4 (Submission reliability) and finish with Polish (Phase 6).
