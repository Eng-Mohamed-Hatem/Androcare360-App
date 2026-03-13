# Research: Patient Packages Update

## Current State Analysis

### 1. UI Spacing Issue
- **File**: `lib/features/packages/presentation/pages/category_packages_list_page.dart`
- **Component**: `ListView.separated` in `CategoryPackagesListPage`.
- **Finding**: Padding is currently `const EdgeInsets.symmetric(horizontal: 16, vertical: 20)`. This lacks safe bottom padding.
- **Proposed Fix**: Change padding to `EdgeInsets.fromLTRB(16, 20, 16, 100)`.

### 2. Package Name Display
- **Files**: 
    - `MyPackagesPage.dart` (uses `package.packageId`)
    - `MyPackagesDetailPage.dart` (uses `entity.packageId`)
- **Finding**: Both pages display the ID instead of the name. `PatientPackageEntity` already has a `packageName` field, but it needs to be consistently used.
- **Action**: Update widgets to use `entity.packageName`.

### 3. Service Usage Tracking Gap
- **Entities**: `PatientPackageEntity` (`servicesUsage`), `PackageEntity` (`services`).
- **Data Gap**: `PatientPackageEntity` only stores `serviceId` and `usedCount`. It does not store the service name or the total quantity allowed (which is in `PackageEntity`).
- **Constraint**: If a package definition changes or is deleted in the admin panel, the patient's usage screen might break or show incorrect total quantities.
- **Decision**: Denormalize `packageServices` (List of `PackageServiceItem`) into `PatientPackageEntity`.

### 4. Legacy Data Migration
- **Target**: `elajtech` database, `patient_packages` collections.
- **Mechanism**: A one-time script that iterates through docs, fetches the matching source package from `clinics/{clinicId}/packages/{packageId}`, and updates the purchased record.

## Technical Feasibility
- **Clean Architecture**: Changes are needed across all layers (Domain entity, Data model, Presentation widgets).
- **Migration**: Can be performed using a temporary script in the app or a cloud function. Based on project constraints, a local script run via a test or a temporary page is safer.
