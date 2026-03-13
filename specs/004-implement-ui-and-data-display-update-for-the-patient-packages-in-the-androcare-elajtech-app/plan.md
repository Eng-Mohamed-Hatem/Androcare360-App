# Implementation Plan: Patient Packages UI and Data Display Update

**Branch**: `004-patient-packages-update` | **Date**: 2026-03-11 | **Spec**: [spec.md](file:///C:/Users/moham/Desktop/androcare/elajtech/elajtech/specs/004-implement-ui-and-data-display-update-for-the-patient-packages-in-the-androcare-elajtech-app/spec.md)

## Summary
The goal is to improve the Patient Packages UX by fixing a scroll clipping issue, displaying human-readable names instead of internal IDs, and showing detailed service usage with progress bars. Techncially, this requires denormalizing service definitions into the `PatientPackageEntity` and migrating legacy data.

## Technical Context
- **Storage**: Firestore `databaseId: 'elajtech'`.
- **Architecture**: Clean Architecture (Domain -> Data -> Presentation).
- **Injection**: `injectable` + `get_it`.
- **Constraint**: Strict adherence to `important-rules.md` (no `!`, databaseId usage, Clinic Isolation).

## Proposed Changes

### Domain Layer
- **[MODIFY] [patient_package_entity.dart](file:///C:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/features/packages/domain/entities/patient_package_entity.dart)**: Add `packageServices` field.

### Data Layer
- **[MODIFY] [patient_package_model.dart](file:///C:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/features/packages/data/models/patient_package_model.dart)**: Add serialisation for `packageServices`.
- **[MODIFY] [patient_package_repository_impl.dart](file:///C:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/features/packages/data/repositories/patient_package_repository_impl.dart)**: Update `createPatientPackage` to store `packageServices`.

### Presentation Layer
- **[MODIFY] [category_packages_list_page.dart](file:///C:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/features/packages/presentation/pages/category_packages_list_page.dart)**: Add bottom padding (100px) to `ListView`.
- **[MODIFY] [my_packages_page.dart](file:///C:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/features/packages/presentation/pages/my_packages_page.dart)**: Use `entity.packageName`.
- **[MODIFY] [my_packages_detail_page.dart](file:///C:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/features/packages/presentation/pages/my_packages_detail_page.dart)**: 
    - Display `entity.packageName`.
    - Iterate over `entity.packageServices` to show usage rows.
    - Implement progress bar and usage ratio (used/total).

### Migration Utility
- **[NEW] `PackageMigrationService`**: A one-time utility to backfill data for legacy records.

## Verification Plan

### Automated Tests
- **Unit Tests**: 
    - Test `PatientPackageModel.fromFirestore` with new `packageServices` field.
    - Test usage calculation logic in `MyPackagesDetailPage`.
- **Command**: `flutter test test/unit/features/packages/data/models/patient_package_model_test.dart`

### Manual Verification
1. **Scroll Check**: Open any package category and ensure the last card is fully visible above the bottom navigation.
2. **Name Check**: Buy a package and verify "My Packages" shows the name, not `pkg_...`.
3. **Usage Check**: 
    - View "My Packages Detail".
    - Verify all services are listed with "0 / X" initially.
    - Verify the progress bar is empty (0%).
