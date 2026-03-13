# Feature Specification: Simulated Package Purchase (Test Stub)

**Feature Branch**: `003-test-package-purchase`  
**Created**: 2026-03-10  
**Status**: Draft  
**Input**: User description: "Simulate package purchase experience with test records in Firestore"

## Clarifications

### Session 2026-03-10
- Q: Does a "Package Details" screen already exist in the codebase? → A: Yes, use `lib/features/packages/presentation/pages/package_details_page.dart` (`PackageDetailsPage`).
- Q: Use existing PatientPackageEntity or new one? → A: Use existing `PatientPackageEntity` in `lib/features/packages/domain/entities/patient_package_entity.dart` and add `isTestPurchase` flag.
- Q: What is the exact Firestore collection name? → A: `patients/{patientId}/packages` (within the `elajtech` database).
- Q: Where is the duplicate purchase guard? → A: In `PurchasePackageUseCase` using `_patientPackageRepo.findActiveOrPendingByPackageId`.
- Q: Where is the "Buy Now" disabled logic? → A: In `PackageDetailsBuyButton` (within `package_details_page.dart`) using `ref.watch(connectivityProvider)`.
- Q: Which provider handles the Package Details state? → A: `purchasePackageProvider` in `lib/features/packages/presentation/providers/packages_provider.dart`.
- Q: Where should the user be directed after purchase? → A: Navigate to the "My Packages" page (`MyPackagesPage`).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Simulated Purchase Flow (Priority: P1)

As a patient, I want to be able to "purchase" a package from its details page so that I can see how the application behaves after a purchase is completed.

**Why this priority**: Core requirement to prepare the interface for future payment integration and allow testing of post-purchase flows.

**Independent Test**: Can be fully tested by tapping the "Buy Now" button on any package details page and verifying the confirmation dialog appears.

**Acceptance Scenarios**:

1. **Given** a patient is on a package details page, **When** they tap "Buy Now", **Then** a dialog titled "Purchase Completed (Test)" appears.
2. **Given** the test purchase dialog is shown, **When** the patient reads the message, **Then** it must explicitly state that no real payment was processed.

---

### User Story 2 - Test Data Persistence (Priority: P2)

As a developer/tester, I want the system to record the test purchase in the database so that I can verify the purchase flow persisted the correct data.

**Why this priority**: Vital for testing downstream logic (e.g., active package lists) without real financial data.

**Independent Test**: Can be tested by checking the Firestore database after a "Buy Now" action for a new record with `isTestPurchase: true`.

**Acceptance Scenarios**:

1. **Given** a successful test purchase, **When** checking the patient's subscriptions in Firestore, **Then** a new record must exist with `patientId`, `packageId`, `purchasedAt`, and `isTestPurchase: true`.

---

### Edge Cases

- **What happens when the user is offline?**: The "Buy Now" button is already disabled by existing logic; this feature should maintain that behavior.
- **How does the system handle duplicate test purchases?**: Existing duplicate guards in the use case should still apply to prevent redundant active subscriptions.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The "Buy Now" button MUST NOT initiate any real payment transaction.
- **FR-002**: System MUST display a centered dialog titled "Purchase Completed (Test)" on the `PackageDetailsPage` with the message: "The package has been purchased successfully for testing purposes only. No real payment has been processed."
- **FR-009**: System MUST show a loading indicator on the "Buy Now" button while the Firestore write operation is in progress (Loading State).
- **FR-010**: System MUST handle Firestore write failures by displaying a localized error message (SnackBar or Error Banner) and re-enabling the purchase button.
- **FR-003**: System MUST create a test-only record in Firestore linked to the patient.
- **FR-004**: The persisted record MUST include: `patientId`, `packageId`, `purchasedAt` (timestamp), and `isTestPurchase: true`.
- **FR-005**: After the patient taps "OK" on the test purchase dialog, the system MUST navigate the user to the `MyPackagesPage`.
- **FR-007**: System MUST display a `(Test)` / `(تجريبي)` label next to the package name in `MyPackagesPage` for test purchases.
- **FR-008**: Admin Dashboard MUST visually distinguish test purchases from real ones using a "Test" badge and provide filtering capabilities.
- **FR-006**: All code related to this simulated flow MUST be marked with comments as temporary behavior (Test/Stub) to be replaced by a real payment gateway.

### Key Entities *(include if feature involves data)*

- **PatientPackageEntity**: Represents the link between a patient and a purchased package. 
  - `id`: Document ID.
  - `patientId`: Unique ID of the patient.
  - `packageId`: ID of the purchased package.
  - `clinicId`: ID of the clinic.
  - `purchasedAt`: Date and time of purchase.
  - `isTestPurchase`: Boolean flag (true for this flow).

## Maintenance & Cleanup (CHK019)

- **Test Data Identification**: All simulated purchases are uniquely identified by the `isTestPurchase: true` flag.
- **Rollback/Cleanup**: In case of data corruption or for periodic maintenance, administrators can identify and bulk-delete these records using the `isTestPurchase` filter in Firestore.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Patients can complete the simulated purchase flow in under 5 seconds from the moment they tap "Buy Now".
- **SC-002**: 100% of test purchases result in a Firestore record with the `isTestPurchase` flag set to `true`.
- **SC-003**: Zero calls are made to any external payment gateway API during this flow.
