# Feature Spec: Patient "My Packages" Enhancement

## Overview
Enhance the Patient "My Packages" tab and "Package Details" screen to provide a more human-readable, consistent, and detailed experience for patients tracking their subscriptions.

## Requirements

### 1. Consistent Package Naming
- **Goal**: Ensure the "My Packages" tab and the "Package Details" screen use the same human-readable name as the "Packages" tab on the home screen.
- **Data Source**: Use the `name` field from `PackageEntity` (or `packageName` from `PatientPackageEntity` once fixed).
- **Consistency**: Avoid showing internal codes (e.g., `PKG_001`) or fallback strings (e.g., `باقة عيادة andrology`).

### 2. Detailed Package Metadata
- **Goal**: Empower patients with full details of their purchased package.
- **Fields to Display**:
    - Full Package Description (`description`).
    - Validity Duration (e.g., "90 Days").
    - Terms and Conditions (if available).
- **Presentation**: Display in a dedicated "Package Info" section in the details screen.

### 3. Comprehensive Service Usage
- **Goal**: Provide transparency on what services are included and how they have been consumed.
- **Details per Service**:
    - Service Type (Lab, Visit, etc.).
    - Service Display Name.
    - Usage Ratio: `Used: X / Y`.
    - Visual Progress Indicator: Percentage-based progress bar.
- **Implementation**: Map `packageServices` (snapshot) against `servicesUsage` (counters) in `PatientPackageEntity`.

## Data Contract

### PatientPackageEntity (Domain)
- Ensure `packageName` contains the human-readable Arabic name from `PackageEntity.name`.
- Consider snapshotting `description`, `shortDescription`, and `validityDays` at purchase time for history.

### Package Details Result (Domain/UI)
- The UI should have access to:
    - `entity.packageName`
    - `entity.category.arabicLabel`
    - `entity.status`
    - `entity.purchaseDate` / `entity.expiryDate`
    - `entity.packageServices` (list of `PackageServiceItem`)
    - `entity.servicesUsage` (list of `ServiceUsageItem`)
    - Added snapshots: `description`, `validityDays`.

## UI Design Patterns
- **Colors**: Use `AppColors.primary` for progress indicators and headers.
- **Spacing**: Follow existing 16dp/24dp padding patterns.
- **Directionality**: Wrap English/Numeric content (like ratios `X / Y`) in `Directionality(textDirection: TextDirection.ltr)` for correct RTL display.

## Security & Rules
- **Firestore**: Continue using `databaseId: 'elajtech'`.
- **R2 (Notes)**: Ensure `notes` field is ALWAYS `null` for patient-facing views.
- **Auth**: Use `ref.watch(authProvider).user` with null-checks.
- **Clinic Isolation**: Keep logic within `lib/features/packages`.
