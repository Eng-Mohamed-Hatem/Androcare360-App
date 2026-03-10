# Feature Specification: Admin Packages UI and Creation Fix

**Feature Branch**: `002-admin-packages-fix`  
**Created**: 2026-03-09  
**Status**: Draft  
**Input**: User description: "Redesign admin packages module using Grid cards, update 'Create Package' form with Arabic support and character counters, localize categories/types, fix included services numeric fields, and ensure reliable submission/validation/logging."

## Clarifications

### Session 2026-03-09
- Q: For the new clinics Grid screen: should clinic cards show only the clinic name and icon, or also a summary (e.g., number of active/inactive packages)? → A: Name and Icon only (Static navigation).
- Q: For the “included services” numeric field: do we need to support decimal numbers (e.g., 1.5 sessions) or only integers, and is there a maximum allowed value per service? → A: Integers only (1-99 range).
- Q: For localization of category and type: do you want the Arabic labels to be fully configurable from Firestore/remote config, or is a hard-coded, centralized mapping in the Flutter app acceptable? → A: Hard-coded centralized mapping (Extension-based).
- Q: When “Create Package” fails (validation or Firestore error), what is the preferred UX? → A: Inline errors (Validation) + Snackbar (System errors).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Clinic Package Management Navigation (Priority: P1)

As an Admin, I want to navigate to a specific clinic's packages through a visual grid of clinics, so that I can manage packages for different medical specialties efficiently.

**Why this priority**: Core navigation for the entire feature. Without this, admins cannot access the management screens.

**Independent Test**: Can be tested by navigating from the admin dashboard to the Packages module and selecting a clinic (e.g., "Nutrition"). The system should land on the "Nutrition Packages" screen with Active/Inactive tabs.

**Acceptance Scenarios**:

1. **Given** the admin is on the Packages module, **When** they see the list of clinics (Andrology, Physiotherapy, etc.), **Then** each clinic should be represented by a clear grid card.
2. **Given** a clinic card is selected, **When** navigated to the clinic-specific screen, **Then** the admin should see tabs for "Active Packages" and "Inactive Packages".

---

### User Story 2 - Enhanced Package Creation Form (Priority: P1)

As an Admin, I want to create a new clinical package using a form that supports Arabic multi-line input, character counters, and localized labels, so that I can provide clear and accurate information to patients.

**Why this priority**: Essential for data entry quality. Arabic support and live feedback (counters) are critical for the target audience.

**Independent Test**: Can be fully tested by opening the "Create Package" form, typing in Arabic in multi-line fields, and verifying the character counters increment correctly.

**Acceptance Scenarios**:

1. **Given** the "Create Package" form, **When** the admin enters text in `shortDescription` or `detailedDescription`, **Then** live character counters should update and the field should expand vertically to handle multi-line input.
2. **Given** the "Category" and "Type" dropdowns, **When** opened, **Then** labels should be in Arabic, even if the system stores them using internal enums/values.

---

### User Story 3 - Included Services Numeric Validation (Priority: P2)

As an Admin, I want to add included services to a package and specify their quantity using a numeric field that correctly binds to the model, so that patients get the correct number of sessions/items.

**Why this priority**: Prevents data corruption and ensures "what you see is what you get" when configuring package contents.

**Independent Test**: Can be tested by adding a service row, entering a number (e.g., "5"), and verifying that the numeric value is persisted in the model and doesn't disappear or show as empty.

**Acceptance Scenarios**:

1. **Given** a service inclusion row, **When** a number is entered in the quantity box, **Then** the value should be visually reflected and bound to the package model.
2. **Given** an empty quantity field, **When** "Create" is pressed, **Then** a validation error should highlight the row.

---

### User Story 4 - Reliable Package Submission (Priority: P2)

As an Admin, I want the "Create Package" button to trigger robust validation and provide clear feedback on success or failure, so that I know for certain if the package was saved correctly.

**Why this priority**: Ensures system stability and user trust. Reliable error surfacing is part of the project's safety requirements.

**Independent Test**: Can be tested by attempting to save an incomplete form (validation check) and by saving a valid form (successful repo call/navigation back).

**Acceptance Scenarios**:

1. **Given** a valid form, **When** the "Create Package" button is clicked, **Then** the repository call should be triggered and a success message shown upon completion.
2. **Given** a network failure during submission, **When** the repo call fails, **Then** the admin should see a clear error message and the error must be logged to the console (debug mode).

### Edge Cases

- **Mobile Viewport**: What happens when long Arabic text is entered? (Must not cause visual overflow/clipping).
- **Empty Service List**: How does the system handle a package with zero included services? (Should validate or allow if business logic permits).
- **Malformed Numeric Input**: What if symbols are pasted into the numeric field? (Should be sanitized or rejected).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display a Grid layout for clinic categories on the main Packages screen.
- **FR-002**: Clinic package screens MUST implement a Tab-bar interface for "Active" and "Inactive" states.
- **FR-003**: `shortDescription` and `detailedDescription` MUST support expanding multi-line input (max lines unspecified, scrolls if too large).
- **FR-004**: System MUST display `current_length / max_length` counter below text input fields.
- **FR-005**: Dropdown selections for `Category` and `Type` MUST map Arabic UI labels to existing database enums using a hard-coded centralized mapping (Extension-based).
- **FR-006**: Included services quantity fields MUST accept `int` (range 1-99) and participate in form validation.
- **FR-007**: The "Create Package" button MUST NOT proceed if any required fields (title, price, description, type, category) are missing or invalid.
- **FR-008**: System MUST use `debugPrint` for Firestore write operations according to `important-rules.md`.

### Key Entities *(include if feature involves data)*

- **Package**: The core entity containing metadata, pricing, status, and associated clinic specialty.
- **IncludedService**: A child object of Package representing specific services provided (name and count).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Admin can navigate from home to any clinic's package creation form in under 10 seconds.
- **SC-002**: 100% of user-entered Arabic text remains visible without clipping or overlapping UI elements on 360px+ screens.
- **SC-003**: All validation errors are displayed within 500ms of the "Create" button click.
- **SC-004**: Zero "silent failures" during creation; field validation errors MUST be inline, while system/Firestore failures MUST result in a visible Snackbar.
