# Feature Specification: Patient Packages UI and Data Display Update

**Feature Branch**: `004-patient-packages-update`  
**Created**: 2026-03-11  
**Status**: Draft  
**Input**: User description: "Implement UI and data-display update for the Patient Packages in the AndroCare / Elajtech app"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Clear Visibility of All Packages (Priority: P1)

As a patient, I want to be able to scroll to the bottom of the packages list and see the last package card completely, so that I don't miss any available options.

**Why this priority**: Crucial for accessibility and ensuring all available medical packages are discoverable.

**Independent Test**: Can be fully tested by navigating to any package category with more cards than fit on the screen and verifying the last card is fully visible and not clipped by the bottom edge.

**Acceptance Scenarios**:

1. **Given** a package category with many packages, **When** I scroll to the bottom, **Then** I should see a clear margin/padding below the last card.
2. **Given** any screen size (mobile/tablet), **When** at the bottom of the list, **Then** the last card's "Price" and "Validity" info should be fully visible.

---

### User Story 2 - Human-Readable Package Identification (Priority: P1)

As a patient, I want to see the clear name of the packages I've purchased instead of internal codes or IDs, so that I can easily identify my medical subscriptions.

**Why this priority**: Essential for user experience; internal IDs (e.g., "pkg_001") are confusing for patients.

**Independent Test**: Can be tested by viewing the "My Packages" list and "My Packages Details" and verifying the display text matches the package name (e.g., "Basic Fertility Package").

**Acceptance Scenarios**:

1. **Given** the "My Packages" tab, **When** I view my purchased packages, **Then** each card should display the package name field.
2. **Given** the "Package Details" screen of a purchased package, **When** I view the details, **Then** the header title should show the package name.

---

### User Story 3 - Detailed Service Usage Tracking (Priority: P1)

As a patient, I want to see exactly which services are included in my package and how many times I have used each one, so that I can track my medical progress and remaining benefits.

**Why this priority**: Core value proposition of the packages feature; allows patients to manage their healthcare usage.

**Independent Test**: Can be tested by viewing a purchased package's details and verifying that every service (e.g., "Semen Analysis") shows its specific usage (e.g., "1 / 2").

**Acceptance Scenarios**:

1. **Given** the "Package Details" screen of a purchased package, **When** I view the "Included Services" section, **Then** I should see a list of all services defined in that package.
2. **Given** a specific service in the list, **When** I look at its progress, **Then** I should see a usage ratio (Used / Total) and a visual progress bar.

---

### Edge Cases

- **Boundary condition**: Package with 0 total services (should handle gracefully, though not expected by business logic).
- **Error scenario**: Service definition missing in the record (should show a fallback name or "Unknown Service").
- **Boundary condition**: Expired packages (should still show usage history but with expired status).

## Requirements *(mandatory)*

### Functional Requirements

-   **FR-001**: **UI (Available Packages)**: `CategoryPackagesListPage` MUST include a safe bottom padding (minimum 80px) or a footer element to ensure the last item is fully scrollable above system bars/navigation.
-   **FR-002**: **UI (Purchased Packages)**: `MyPackagesPage` and `MyPackagesDetailPage` MUST display the human-readable `packageName` field instead of the internal `packageId`.
-   FR-003: **Data Architecture**: `PatientPackageEntity` MUST be updated to include the full list of definitions for included services (`List<PackageServiceItem> packageServices`) to ensure name and total quantity are available offline and historically. 
-   FR-007: **Legacy Migration**: A one-time migration script/utility MUST be implemented to backfill `packageServices` and `packageName` into all existing `patient_packages` documents by matching them with their source definitions in `clinics/{clinicId}/packages/{packageId}`.
-   **FR-004**: **UI (Usage Display)**: `MyPackagesDetailPage` MUST render per-service usage rows using normalized names and actual usage ratios (e.g., "1 / 3 sessions").
-   **FR-005**: **UI (Progress Bar)**: Each service row in `MyPackagesDetailPage` MUST include a visual progress indicator (percent-based bar).
-   **FR-006**: **Data Mapping**: MyPackagesDetailProvider MUST ensure it correctly merges the usage counts with the original service definitions.

### Key Entities *(include if feature involves data)*

-   **PatientPackageEntity**:
    -   `packageName`: Human-readable name (String).
    -   `packageServices`: List of service definitions at purchase time (List<PackageServiceItem>).
    -   `servicesUsage`: List of usage tracking items (List<ServiceUsageItem>).

## Success Criteria *(mandatory)*

### Measurable Outcomes

-   **SC-001**: 100% of "My Packages" list items show the human-readable name instead of IDs.
-   **SC-002**: Bottom padding in `CategoryPackagesListPage` is at least 80px across all device configurations.
-   **SC-003**: Every service in the "Package Details" usage list has a corresponding progress bar and correctly calculated ratio (UsedCount / TotalQuantity).
-   SC-004: All existing 700+ tests pass, and new widget tests for `MyPackagesDetailPage` usage display are implemented.
-   SC-005: 100% of legacy `patient_packages` records in the `elajtech` database are successfully backfilled with `packageName` and `packageServices`.
