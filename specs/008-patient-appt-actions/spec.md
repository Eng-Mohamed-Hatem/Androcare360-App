# Feature Specification: Patient Appointments Actions and Medical Record Navigation

**Feature Branch**: `008-patient-appt-actions`
**Created**: 2026-04-01
**Status**: Draft
**Input**: Patient appointments screen enhancements — reschedule action, time-aware call action, completed-appointment medical record navigation.

---

## Clarifications

### Session 2026-04-01

- Q: Should "Waiting for Call" appear for `pending` appointments (not yet confirmed), or only for `confirmed`? → A: Both `pending` and `confirmed` — "Waiting for Call" is shown for both statuses before the join window opens.
- Q: When rescheduling, can the patient pick a new slot with any available doctor, or only with the same originally assigned doctor? → A: Same doctor only — reschedule is a date/time change within the existing doctor assignment.
- Q: Should patient actions (join-meeting tap, reschedule submission, medical record open) be logged for analytics? → A: Log join-meeting taps and reschedule submissions only.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Time-Aware Call Action (Priority: P1)

A patient with a confirmed appointment opens the "My Appointments" tab. Before the join window opens, the call action shows "Waiting for Call" and cannot be tapped. When the join window opens — or when the doctor initiates the call — the button changes to "Join Meeting" and becomes active. If the session has expired or is unavailable, an appropriate message is shown instead.

**Why this priority**: This is the most confusing point for patients today. Showing a tappable "Join Meeting" before the call is available (or showing nothing) creates unnecessary support load. Making the pre-call state explicit is the highest-impact UX fix and has no dependencies on the other stories.

**Independent Test**: Seed a confirmed appointment with a future scheduled time. Open appointments tab — the call area must show "Waiting for Call" (non-tappable). Advance time past the join window start — the action must become an active "Join Meeting" button.

**Acceptance Scenarios**:

1. **Given** a confirmed appointment whose scheduled time is outside the join window, **When** the patient views the appointment card, **Then** the call area displays "Waiting for Call" and the patient cannot tap it.
2. **Given** a confirmed appointment inside the join window, **When** the patient views the card, **Then** the call area displays an active "Join Meeting" button.
3. **Given** an appointment with status `calling`, `in_progress`, or `missed` with an active session, **When** the patient views the card, **Then** "Join Meeting" is shown as active regardless of scheduled time.
4. **Given** a confirmed appointment inside the join window when the doctor has not yet started the call, **When** the patient taps "Join Meeting", **Then** the app attempts to join and shows a clear message if the session is not yet active.
5. **Given** an appointment whose call session has expired, **When** the patient taps "Join Meeting", **Then** the patient sees "This meeting is no longer available" — no crash and no empty screen.
6. **Given** a `completed`, `not_completed`, or `cancelled` appointment, **When** the patient views the card, **Then** no call action area is shown.

---

### User Story 2 — Reschedule Action for Eligible Appointments (Priority: P2)

A patient who needs to change their appointment date or time sees a "Reschedule" option on eligible appointment cards. Tapping it initiates the reschedule flow. Appointments that are already in progress, completed, cancelled, or too close to their start time do not show this option.

**Why this priority**: Rescheduling reduces no-shows and cancellations. It depends only on appointment status and a time check — no dependency on US1 or US3.

**Independent Test**: Open appointments tab with a confirmed appointment more than 2 hours away — the "Reschedule" button must appear. Open an in-progress appointment — no "Reschedule" button must appear. Complete a reschedule — appointment date must update.

**Acceptance Scenarios**:

1. **Given** an appointment with status `pending` or `confirmed` and scheduled time more than 2 hours away, **When** the patient views the card, **Then** the "Reschedule" action is visible and tappable.
2. **Given** an appointment with status `calling`, `in_progress`, `missed`, `declined`, `completed`, `not_completed`, or `cancelled`, **When** the patient views the card, **Then** no "Reschedule" action is shown.
3. **Given** an appointment within 2 hours of its scheduled start, **When** the patient views the card, **Then** the "Reschedule" action is hidden regardless of status.
4. **Given** a patient taps "Reschedule" on an eligible appointment, **When** the reschedule flow completes successfully, **Then** the appointment card reflects the updated scheduled time.
5. **Given** a patient taps "Reschedule" and cancels the flow, **When** the patient returns to the appointments screen, **Then** the original appointment details are unchanged.
6. **Given** a patient submits a reschedule and it fails, **When** the error is returned, **Then** the patient sees a human-readable error message and the original appointment remains intact.

---

### User Story 3 — Medical Record Navigation from Completed Appointments (Priority: P3)

A patient in the History tab sees a "View Medical Record" icon on completed appointment cards. Tapping the icon, or tapping the completed appointment card itself, navigates to the medical record screen for that appointment. No medical record entry point is shown for any other appointment status.

**Why this priority**: This closes the post-visit loop — patients can review their doctor's notes and prescriptions directly from appointment history. It depends on completed appointments existing and is the most naturally deferred enhancement.

**Independent Test**: In History tab, place one completed appointment and one missed appointment. The completed card shows the "View Medical Record" icon; the missed card does not. Tapping the completed card navigates to the medical record screen or the "not yet available" message.

**Acceptance Scenarios**:

1. **Given** a completed appointment in the History tab, **When** the patient views the card, **Then** a "View Medical Record" icon is visible on the card.
2. **Given** a completed appointment in the History tab, **When** the patient taps the appointment card, **Then** the patient is navigated to the medical record screen for that appointment.
3. **Given** a completed appointment in the History tab, **When** the patient taps the "View Medical Record" icon, **Then** the patient is navigated to the same medical record screen as tapping the card.
4. **Given** a completed appointment with no medical record yet filed, **When** the patient taps the card or icon, **Then** the patient sees "Medical record not yet available — please check back later" and is not shown an empty or error screen.
5. **Given** any appointment with status other than `completed`, **When** the patient views the card, **Then** no "View Medical Record" icon is shown and tapping the card does NOT navigate to the medical record screen.

---

### Edge Cases

- What happens if an appointment transitions from `confirmed` to `calling` while the patient is viewing the card? The card must update in real time without requiring a manual refresh.
- What happens if the device clock differs from server time? The join window MUST be evaluated against the server-authoritative appointment timestamp, not the device clock alone.
- What happens if an appointment is rescheduled concurrently from another device? The patient must receive an updated view after the flow and see a conflict message if a race condition occurs.
- What happens while the appointment list is loading? Cards show a loading state — no blank cards and no premature "no appointments" message.
- What happens if the medical record screen is unavailable (server error)? The patient sees a retry option and a human-readable error message — no crash.
- What happens if network connectivity is lost mid-action (reschedule submit, join tap)? The patient sees a connection error and the previous appointment state remains unchanged.
- What happens with an appointment that has status `ended_pending_confirmation`? No call action, no reschedule, no medical record icon — only an informational status label.

---

## Requirements *(mandatory)*

### Functional Requirements

#### Call Action Button (US1)

- **FR-001**: The appointment card MUST display a "Waiting for Call" label in the call action area when the appointment status is `pending` or `confirmed` and the current time is before the join window start. This applies to both statuses: `pending` appointments show "Waiting for Call" because the patient is in a pre-call queue regardless of whether clinic confirmation has arrived yet.
- **FR-002**: The "Waiting for Call" label MUST be non-interactive — the patient cannot tap it to initiate any action.
- **FR-003**: The appointment card MUST display an active "Join Meeting" button when: (a) the current time is within the join window for a `confirmed` appointment, OR (b) the appointment status is `calling`, `in_progress`, or `missed` with `callSessionActive = true`.
- **FR-004**: The join window MUST open 10 minutes before the scheduled appointment start time. Before this threshold, the call area shows "Waiting for Call". At or after this threshold, the call area shows the active "Join Meeting" button.
- **FR-005**: When a patient taps "Join Meeting" and the session is no longer active or has expired, the system MUST display the message "This meeting is no longer available" (Arabic: "الاجتماع لم يعد متاحاً") and MUST NOT navigate to the call screen.
- **FR-006**: The call action area MUST be hidden entirely for appointments with status `completed`, `not_completed`, `cancelled`, `declined`, or `ended_pending_confirmation`.
- **FR-007**: When a patient is inside the join window and taps "Join Meeting" but the doctor has not yet started the call session, the system MUST show a clear message "The doctor has not started the call yet — please wait" (Arabic: "لم يبدأ الطبيب المكالمة بعد — يرجى الانتظار") without navigating to the call screen.

#### Reschedule Action (US2)

- **FR-008**: The appointment card MUST display a "Reschedule" action for appointments with status `pending` or `confirmed` when the scheduled time is more than 2 hours in the future.
- **FR-009**: The "Reschedule" action MUST NOT be shown for appointments with status `calling`, `in_progress`, `missed`, `declined`, `completed`, `not_completed`, `cancelled`, or `ended_pending_confirmation`.
- **FR-010**: The "Reschedule" action MUST NOT be shown when the scheduled appointment time is 2 hours or less away, regardless of status.
- **FR-011**: Rescheduling MUST be self-service — the patient selects a new available slot from the **same originally assigned doctor's** availability and the appointment is updated immediately with no admin or doctor approval required. The patient MUST NOT be able to switch doctors during the reschedule flow. The patient MUST see a confirmation that the appointment has been rescheduled to the new time before leaving the reschedule flow.
- **FR-012**: If the reschedule action fails or is rejected, the patient MUST receive a clear error message in their language and the original appointment details MUST remain unchanged.

#### Medical Record Navigation (US3)

- **FR-013**: The appointment card in the History tab MUST display a "View Medical Record" icon when and only when the appointment status is `completed`.
- **FR-014**: The "View Medical Record" icon MUST be hidden for all other statuses: `pending`, `confirmed`, `calling`, `in_progress`, `missed`, `declined`, `not_completed`, `cancelled`, and `ended_pending_confirmation`.
- **FR-015**: Tapping a `completed` appointment card in the History tab MUST navigate the patient to the medical record screen for that appointment.
- **FR-016**: Tapping the "View Medical Record" icon MUST navigate the patient to the same medical record screen as tapping the card (FR-015) — both actions have an identical destination.
- **FR-017**: When navigating to a medical record for a `completed` appointment that has no filed record, the system MUST display "Medical record not yet available — please check back later" (Arabic: "السجل الطبي غير متاح بعد — يرجى المراجعة لاحقاً") instead of an empty or error screen.

#### General

- **FR-018**: All appointment card action areas MUST update in real time when the underlying appointment status changes, without requiring the patient to manually refresh the screen.
- **FR-019**: Actions unavailable due to status or time rules MUST be hidden (not just visually disabled), with the exception of the "Waiting for Call" informational label per FR-001 which is shown as an explicit non-tappable state.
- **FR-020**: All labels and messages MUST be available in both Arabic (RTL) and English, switching based on the patient's active language setting.
- **FR-021**: All interactive elements (buttons, icons) MUST meet minimum tap target requirements and carry descriptive accessibility labels readable by screen readers.
- **FR-022**: Every patient tap of the "Join Meeting" button MUST be logged as an analytics event including the appointment identifier, the resulting outcome (navigated to call / session not active / doctor not started), and a timestamp.
- **FR-023**: Every patient submission of a reschedule (successful or failed) MUST be logged as an analytics event including the appointment identifier, the original scheduled time, the newly requested time, and the outcome (confirmed / failed).

### Key Entities

- **Appointment**: A scheduled consultation between patient and doctor. Relevant attributes: identifier, status, scheduled date/time, assigned doctor, `callSessionActive` flag, `callStartedAt` timestamp.
- **Medical Record**: A health record filed by the doctor after a completed consultation. Linked to an appointment by identifier. May or may not exist even when the appointment status is `completed`.
- **Call Session**: The live video meeting associated with an appointment. Determines whether "Join Meeting" is available. Attributes: active/expired state, session identifier.
- **Reschedule Action**: A self-service change to the scheduled date/time of an appointment. Linked to a patient and an appointment; the doctor assignment does not change. Results in an immediately confirmed new slot with no approval queue.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of appointment cards correctly show or hide the call action, reschedule action, and medical record icon based on appointment status and time rules — verified by automated tests covering all 11 appointment statuses across all 3 action types.
- **SC-002**: The call action label (Waiting for Call → Join Meeting) updates within 3 seconds of a status change without requiring the patient to reload the appointments screen.
- **SC-003**: Patients can initiate a reschedule on an eligible appointment in under 60 seconds from opening the appointments tab.
- **SC-004**: 100% of completed appointments in the History tab display the "View Medical Record" icon; 0% of non-completed appointments display it — verified by widget tests.
- **SC-005**: When a patient navigates to a medical record for a completed appointment, the screen either displays the record content or the "not yet available" message within 3 seconds — no blank screens or unhandled errors.
- **SC-006**: All patient-facing labels and messages appear in the correct language and text direction (RTL for Arabic, LTR for English) across all appointment card states.
- **SC-007**: No existing appointment listing, video call join flow, or medical record access regressions — all existing automated tests continue to pass after this feature is deployed.
- **SC-008**: 100% of "Join Meeting" taps and reschedule submissions produce a corresponding analytics log entry — verified by integration tests checking the log collection after each action.

---

## Assumptions

- The patient-facing appointments screen already has a History tab (completed appointments) and an Active tab (upcoming/ongoing). This feature adds actions to existing card views — it does not require building new screen containers.
- The existing appointment card widget will be extended with conditional action areas rather than replaced.
- The existing `callSessionActive` boolean field and appointment `status` field (as aligned by feature 007) are the authoritative sources for call action visibility.
- The 2-hour reschedule cutoff (FR-008, FR-010) is a reasonable default for a healthcare telemedicine platform and protects doctors from last-minute no-shows. This can be revised during planning.
- The "View Medical Record" navigation target is an existing medical record screen already available in the app. This feature only adds the entry point — it does not build a new screen.
- Completed appointments may exist without a filed medical record (doctor has not filed yet). FR-017 handles this graceful fallback.
- Both the "View Medical Record" icon and tapping the completed card navigate to the same destination (same screen, same appointment context) — FR-016 makes this explicit.
- Arabic is the primary language for AndroCare360 patients; English is secondary. All new labels must be provided in both languages.
- The reschedule flow will reuse or extend the existing appointment slot-selection flow. The booking UI content is outside this specification's scope.
- No new backend functions are required for US1 (call action display) or US3 (medical record navigation) — these are client-side state and navigation changes. US2 may require a backend call depending on the outcome of FR-011 clarification.

---

## Out of Scope

- Building a new medical record viewing screen (existing screen is reused as the navigation target).
- Redesigning the doctor-side appointment management experience.
- Changing the video call flow itself (covered by feature 007).
- Admin or doctor approval workflow UI for reschedule requests (admin side only; this spec covers patient-facing initiation).
- Push notification delivery for reschedule confirmation (out of scope; the real-time card update per FR-018 is in scope).
- Any appointment statuses or flows outside the patient account view.
