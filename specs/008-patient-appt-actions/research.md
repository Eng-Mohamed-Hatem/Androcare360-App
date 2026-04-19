# Research: Patient Appointments Actions and Medical Record Navigation

**Feature**: 008-patient-appt-actions
**Date**: 2026-04-01

---

## Decision 1: Join Window Time Source — Device Clock vs. Server Time

**Decision**: Use `appointment.fullDateTime` (server-written Firestore field) compared against `DateTime.now()` (device clock) for the 10-minute join window calculation.

**Rationale**: The appointment time is authored by the server and stored in Firestore — it is not a client guess. The comparison is `appointment.fullDateTime.subtract(Duration(minutes: 10)).isBefore(DateTime.now())`. Clock drift between the patient's device and the server is typically ±5–30 seconds; this is negligible against a 10-minute window. Fetching server time on every card render would add latency, cost, and complexity for no meaningful benefit.

**Alternatives considered**:
- Server time API call on every render: Rejected — too expensive, adds network dependency to a pure UI calculation.
- Cloud Function to return join eligibility: Rejected — overkill for a display-only flag; security enforcement happens at `patientJoinCall` server side anyway.

---

## Decision 2: Same-Doctor Slot Availability for Reschedule

**Decision**: The reschedule flow navigates to a new `RescheduleAppointmentSheet` (bottom sheet) that reuses the slot-fetching logic from `BookAppointmentScreen`. The sheet is pre-loaded with the original doctor's ID and the existing appointment's speciality, shows available slots for that doctor only, and confirms the new time immediately on selection.

**Rationale**: The existing `BookAppointmentScreen` already handles date + time slot selection with a calendar + slot grid. Extracting a reusable slot-picking widget or calling the same provider from a sheet avoids duplication. The sheet approach (vs. full-screen navigation) is lower friction for a reschedule that is a single date/time change.

**Alternatives considered**:
- Reuse the existing `_RescheduleDialog` from `patient_profile_screen.dart`: Rejected — that dialog shows any calendar date/time without checking doctor availability. Self-service reschedule (FR-011) requires showing only the doctor's real available slots to prevent double-booking.
- Full-screen navigation to a reschedule screen: Deferred — a bottom sheet is sufficient for a single doctor's slot selection; a full screen is only needed if doctor-switching were in scope.

---

## Decision 3: Analytics Logging — Extend CallMonitoringService

**Decision**: Extend the existing `CallMonitoringService` with two new event method signatures: `logJoinMeetingTap(appointmentId, outcome)` and `logRescheduleSubmitted(appointmentId, originalTime, newTime, outcome)`. Events are written to the existing `call_logs` collection in Firestore (databaseId: `elajtech`).

**Rationale**: A dedicated analytics service would duplicate the Firestore write pattern, injectable singleton setup, and error handling already present in `CallMonitoringService`. The `call_logs` collection already captures appointment-level events; adding join-tap and reschedule events is a natural extension. This avoids creating a new Firestore collection and a new service class.

**Alternatives considered**:
- Create a new `AppointmentActionService`: Rejected — unnecessary duplication of an identical pattern.
- Use `AssessmentReferralTrackingService.logEvent()`: Rejected — that service is tightly coupled to the assessment funnel context (stage, referral metadata) and is not appropriate for general appointment actions.
- Skip logging and add later: Rejected — FR-022/FR-023 are explicit requirements; deferring breaks the spec.

---

## Decision 4: Medical Record Navigation Target

**Decision**: Navigate to `AppointmentMedicalRecordScreen(appointment: apt, patientName: currentPatientName)`. This screen already handles multi-speciality EMR display for a specific appointment. The patient name is sourced from the authenticated user's profile (already available via the auth provider). A new helper method `PatientNavigationHelper.openAppointmentMedicalRecord(context, appointment, patientName)` encapsulates the route push.

**Rationale**: `AppointmentMedicalRecordScreen` is the correct existing target — it is appointment-scoped (not a general record list) and supports all specialities. `MedicalRecordsScreen` (the 5-tab general view) would not show appointment-specific records correctly. Adding a navigation helper method follows the existing `PatientNavigationHelper` pattern used for all other patient deep-links.

**Alternatives considered**:
- Navigate to `MedicalRecordsScreen`: Rejected — it is a general list, not appointment-scoped.
- Navigate to `PatientMedicalRecordScreen`: Rejected — that is the doctor's view with add/edit capabilities, not the patient read-only view.

---

## Decision 5: "View Medical Record" Icon — Placement and Fallback

**Decision**: The "View Medical Record" icon is placed in the `AppointmentCardWidget` action row, visible only when `appointment.status == AppointmentStatus.completed`. Before navigating, check if a medical record document exists for the appointment. If none exists, show an inline `SnackBar` with the "not yet available" message (FR-017) instead of navigating.

**Rationale**: An inline SnackBar is the lightest-weight way to show the fallback — it does not add a new screen, does not require a loading state on the card itself, and the check is a fast Firestore single-document read. This is consistent with how other error states are shown in `PatientAppointmentsScreen` (SnackBar via `ScaffoldMessenger`).

**Alternatives considered**:
- Navigate to a "no record available" placeholder screen: Rejected — adds navigation complexity for a transient state.
- Pre-check on list load and hide icon if no record: Rejected — adds N Firestore queries on appointments load; better to check lazily on tap.

---

## Decision 6: Waiting for Call — `pending` Status Handling

**Decision**: Per spec clarification (Q1: A), "Waiting for Call" is shown for both `pending` and `confirmed` appointments before the join window. For `pending` appointments the call action area shows "Waiting for Call" because the patient is queued for an eventual call regardless of confirmation status. The `_canJoinMeeting` logic in `AppointmentCardWidget` must NOT show "Join Meeting" for `pending` status even if within the 10-minute window — join eligibility requires `confirmed` or an active call status.

**Rationale**: A `pending` appointment has not yet been accepted; the backend would reject a join attempt. Showing "Waiting for Call" is informational (patient is aware they have an upcoming slot) while "Join Meeting" is actionable (patient actively joins). Keeping the two separate prevents a failed join attempt on an unconfirmed appointment.

**Alternatives considered**:
- Show no call action for `pending`: Rejected — per spec Q1 answer, "Waiting for Call" must show for `pending`.
- Show "Join Meeting" for `pending` in the join window: Rejected — backend rejects join on unconfirmed appointments; this would produce a confusing error.
