# Feature Specification: Agora Call Workflow Alignment

**Feature Branch**: `007-agora-call-alignment`
**Created**: 2026-03-31
**Status**: Draft
**Input**: Audit, align, and finalize the doctor-patient Agora call workflow in AndroCare360

---

## Problem Statement

AndroCare360 supports video consultations between doctors and patients using a real-time call channel. The current implementation partially covers the intended workflow, but several behavioral gaps and conflicts exist between what is implemented and what the business requires. Specifically:

- The system currently marks an appointment as **completed automatically** when the doctor ends the call, bypassing the doctor's intent and removing the ability to flag a session as incomplete.
- Patients who miss an incoming call have **no supported path** to rejoin an active meeting from the Appointments tab.
- The appointment status model does not capture all meaningful states in the call lifecycle (e.g., ringing, declined, ended-pending-confirmation).
- Missed-call and declined-call backend handling may or may not be fully implemented — this must be verified and confirmed.

This specification defines the approved business workflow, documents what is currently implemented vs. what is missing, and establishes the requirements that must be met before implementation work begins.

---

## Clarifications

### Session 2026-03-31

- Q: How long after a missed call is the "Join Meeting" action available to the patient? → A: Available until the doctor ends the call (doctor-controlled). No time-based expiry applies while the doctor remains in the session.
- Q: If the doctor does not respond to the post-call confirmation dialog, what happens to the appointment? → A: Re-prompt on doctor's next app open. Auto-transition to `not_completed` after 24 hours from call end if still no response.
- Q: What form should the missed-call indication take for the patient? → A: Push notification delivered to the patient's device AND a visual indicator on the appointment card in the Appointments tab.
- Q: After a patient declines a call, can the doctor retry the call on the same appointment? → A: Yes — within the appointment time window, the doctor can retry and the appointment transitions back to `calling`.

---

## Scope

**In scope**:
- Doctor initiating a video consultation from an appointment
- Patient receiving, answering, or missing the incoming call
- Patient rejoining an active meeting from the Appointments tab after a missed call
- Doctor and patient experience during the meeting
- End-of-call behavior: doctor confirmation dialog, appointment completion/non-completion outcome
- Appointment status transitions across the full call lifecycle
- Backend state management for calls, missed-call handling, and declined-call handling
- Call event logging
- Post-call appointment state visibility for both doctor and patient

**Out of scope**:
- Appointment booking, scheduling, and confirmation flows
- Zoom or other third-party meeting link flows
- Admin management of appointments
- Clinic (in-person) appointment types
- Billing or payment flows related to consultations

---

## Implementation Audit

This section explicitly separates current documented behavior, verified implemented behavior, missing behavior, and desired future behavior to identify gaps and conflicts.

### Current Documented Behavior (as stated in project documentation)

1. Doctor initiates the call via `startAgoraCall`.
2. Patient receives a VoIP incoming call notification.
3. If patient accepts, cold-start handling restores call data and joins the channel.
4. `endAgoraCall` updates the call end timestamp.
5. `completeAppointment` marks the appointment as completed.
6. A doctor session-end confirmation dialog is documented.
7. Missed-call and declined-call backend handlers are documented as planned / to be implemented.
8. Patient auto-complete after lifecycle cleanup is documented as intended behavior.

### Verified Implemented Behavior (confirmed by codebase audit)

| Component | Status | Notes |
|-----------|--------|-------|
| `startAgoraCall` (call initiation, token, VoIP notification) | Implemented | Doctor-side call start is fully functional |
| `endAgoraCall` (updates call end timestamp) | Implemented | Also sets appointment status to `completed` automatically — see conflict below |
| Patient incoming call screen (VoIP answer/decline) | Implemented | Serves as fallback when native call UI is unavailable |
| Cold-start restoration (app launched from terminated state) | Implemented | 60-second timeout with exponential backoff retries |
| Call event logging (`CallMonitoringService`) | Implemented | Full lifecycle logging into `calllogs` collection |
| Doctor session-end confirmation dialog | Implemented | Manual trigger; calls `AppointmentCompletionService` |
| `handleMissedCall` (backend) | Implemented | Sets `callStatus: missed` and `missedAt` timestamp |
| `handleCallDeclined` (backend) | Implemented | Sets `callStatus: declined` and `declinedAt`; notifies doctor |
| Patient "Join Meeting" from Appointments tab | **Not implemented** | No UI entry point exists for patient to rejoin from appointment list |
| Appointment status: `ended_pending_confirmation` state | **Not implemented** | No intermediate state between call ending and doctor confirming |

### Identified Conflicts

**Conflict 1 — Auto-complete vs. Doctor Confirmation (Critical)**

`endAgoraCall` currently sets the appointment status directly to `completed` when the doctor ends the call. This conflicts with the desired business rule where only the doctor's explicit "Yes" confirmation should mark the appointment as completed. Under the current behavior, every ended call becomes completed regardless of whether the consultation was meaningful or complete.

*Desired behavior*: When the call ends, the appointment must transition to `ended_pending_confirmation`. The final status (`completed` or `not_completed`) must only be set after the doctor responds to the confirmation dialog.

**Conflict 2 — Patient Has No Path to Rejoin After Missed Call**

The patient currently has no way to join an active meeting unless they answer the initial VoIP notification. The Appointments tab shows no "Join Meeting" action for ongoing or missed-call sessions. This leaves the patient stranded if they miss the ring or if their device was offline.

*Desired behavior*: If a call session is still active and the appointment is in a `calling` or `in_progress` state, the patient must see a "Join Meeting" action on the corresponding appointment card.

**Conflict 3 — Patient Auto-Complete**

Documentation references patient auto-complete after lifecycle cleanup. This is consistent with the current `endAgoraCall` auto-complete behavior (Conflict 1 above). Under the desired workflow, the patient must never be the source of truth for appointment completion — only the doctor's confirmation drives that outcome.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Doctor Initiates Call and Patient Answers (Priority: P1)

A doctor opens a confirmed appointment and starts a video consultation. The patient's device rings. The patient answers, the app opens, and both parties are in the same meeting. The consultation concludes. The doctor ends the call, sees a confirmation dialog, answers "Yes", and the appointment is marked completed. The patient then sees the appointment as completed.

**Why this priority**: This is the primary happy-path flow. Everything else depends on this working correctly first.

**Independent Test**: Can be fully tested by having a doctor start a call and a patient answer it, then completing the confirmation. Delivers a fully functional end-to-end consultation.

**Acceptance Scenarios**:

1. **Given** a confirmed appointment and the doctor presses the call button, **When** the patient's device receives the incoming call, **Then** the patient sees a ringing incoming call notification within 5 seconds.
2. **Given** the patient answers the incoming call, **When** the call is accepted, **Then** the patient's app opens (if needed) and the patient enters the same meeting as the doctor within 10 seconds.
3. **Given** both parties are in the meeting and the doctor presses end call, **When** the session closes, **Then** a confirmation dialog appears asking the doctor whether the session was completed.
4. **Given** the doctor answers "Yes" in the confirmation dialog, **When** confirmed, **Then** the appointment status becomes `completed` for both doctor and patient.
5. **Given** the doctor answers "No" in the confirmation dialog, **When** confirmed, **Then** the appointment status becomes `not_completed` and no completion is recorded.

---

### User Story 2 — Patient Misses the Call and Rejoins from Appointments Tab (Priority: P2)

A doctor starts a call, but the patient does not answer. The patient's device shows a missed-call indication. The doctor remains in the meeting waiting. The patient later opens the app, navigates to the Appointments tab, finds the appointment showing a "Join Meeting" action, and taps it to enter the active meeting with the doctor.

**Why this priority**: Missed calls are a realistic scenario in a healthcare app. Patients may be in a situation where they cannot answer immediately. Without a rejoin path, the entire consultation is lost.

**Independent Test**: Can be tested by having a doctor start a call, declining it on the patient side, then rejoining from the appointment card while the doctor is still in the meeting.

**Acceptance Scenarios**:

1. **Given** the doctor starts a call and the patient does not answer, **When** the ring timeout expires, **Then** the patient's device shows a missed-call notification or indication.
2. **Given** the appointment is in `calling` or `in_progress` state, **When** the patient opens the Appointments tab, **Then** the appointment card displays a "Join Meeting" action.
3. **Given** the patient taps "Join Meeting", **When** the session is still valid and active, **Then** the patient enters the same Agora meeting and can see/hear the doctor.
4. **Given** the patient taps "Join Meeting" but the doctor has already ended the call, **When** the session is no longer active, **Then** the patient sees a clear message that the meeting has ended.

---

### User Story 3 — Doctor Ends Call Without Completing (Not Completed Flow) (Priority: P2)

A doctor starts and ends a call but determines the consultation was not completed (e.g., technical issue, patient was unavailable despite connecting briefly). The doctor answers "No" to the confirmation dialog. The appointment remains in a `not_completed` state so it can be followed up.

**Why this priority**: Equal importance to completion — the system must correctly record incomplete sessions to protect clinical accountability.

**Independent Test**: Can be tested by ending a call and selecting "No" in the confirmation dialog, then verifying the appointment status.

**Acceptance Scenarios**:

1. **Given** the call ends and the confirmation dialog appears, **When** the doctor selects "No", **Then** the appointment status transitions to `not_completed`.
2. **Given** an appointment in `not_completed` state, **When** the doctor views the appointment list, **Then** the appointment is visually distinguishable from `completed` appointments.
3. **Given** an appointment is `not_completed`, **When** the patient views their appointments, **Then** the appointment is not shown as completed.

---

### User Story 4 — Patient Declines the Incoming Call (Priority: P3)

The doctor initiates a call. The patient explicitly declines (presses the decline button). The doctor is notified that the patient declined. The appointment remains available for rescheduling or manual follow-up.

**Why this priority**: Declined calls must be handled gracefully — the doctor must know whether the patient actively declined vs. simply did not answer.

**Independent Test**: Can be tested by initiating a call and pressing the decline button on the patient side.

**Acceptance Scenarios**:

1. **Given** the patient explicitly declines the incoming call, **When** declined, **Then** the doctor receives a notification or in-app signal that the patient declined.
2. **Given** a declined call, **When** viewing the appointment, **Then** the appointment status reflects `declined` (or equivalent) rather than `missed`.
3. **Given** a declined call, **When** the session has ended, **Then** the patient does not see a "Join Meeting" action.
4. **Given** a declined call within the appointment time window, **When** the doctor initiates a new call attempt on the same appointment, **Then** the appointment transitions back to `calling` and the patient receives a new incoming call notification.

---

### Edge Cases

- What happens when the patient answers but cannot join due to a network interruption mid-connection? The appointment MUST remain in `in_progress` state (since the answer event was received). The patient MUST see an error message and be offered a retry option. No state change occurs until the patient successfully joins or the doctor ends the call.
- What happens when the doctor ends the call before the confirmation dialog appears (app crash, force quit)? The appointment must not remain permanently in `ended_pending_confirmation` — a timeout or fallback must eventually transition it to `not_completed`.
- What happens when the doctor has not responded to the confirmation dialog and the patient tries to check appointment status? The patient sees the appointment as "pending review." If the doctor has not responded within 24 hours of the call ending, the appointment automatically transitions to `not_completed` and the patient sees it as not completed.
- What happens when the Agora token expires while the patient is trying to rejoin? The patient should see a clear message that the session token has expired and rejoin is no longer possible.
- What happens when both doctor and patient drop from the meeting simultaneously due to connectivity loss? The appointment MUST transition to `ended_pending_confirmation` (not `not_completed` directly). The doctor MUST be re-prompted on next app open, and the standard 24-hour auto-transition applies. See FR-015 and FR-028.
- What happens when a patient taps "Join Meeting" on an appointment in `calling` state but the ring timeout has already expired and the appointment has transitioned to `missed`? Since the state is now `missed` and the doctor's session may still be active, the "Join Meeting" action still applies per FR-008. If the doctor has since ended the waiting session (appointment no longer has an active session), the patient MUST see: "The doctor has ended the waiting session. The meeting is no longer available."

---

## Requirements *(mandatory)*

### Functional Requirements

**Call Initiation**

- **FR-001**: A doctor with a confirmed appointment MUST be able to initiate a video call from that appointment.
- **FR-002**: The system MUST prevent call initiation outside of a ±30-minute window relative to the scheduled appointment time. This same window applies to doctor retry calls after a missed or declined call.
- **FR-003**: Upon call initiation, the patient's device MUST receive an incoming call notification regardless of whether the patient's app is in the foreground, background, or not running.

**Patient Answer Flow**

- **FR-004**: When the patient answers the incoming call notification, the patient's app MUST open (if closed) and navigate the patient directly into the meeting.
- **FR-005**: If the patient's app was terminated when the notification arrived, the system MUST restore all necessary call session data before joining the meeting. Cold-start restoration is only valid when the appointment is in `calling` or `in_progress` state. If the appointment is in any other state at launch time, the app MUST present the current appointment state rather than attempting to restore a call session.
- **FR-006**: The patient MUST join the same meeting session as the doctor within 10 seconds of answering.

**Missed Call and Rejoin**

- **FR-007**: When the ring timeout expires (60 seconds) without the patient answering, the system MUST automatically transition the appointment from `calling` to `missed`, record the missed-call event, deliver a push notification to the patient's device, and display a visual missed-call indicator on the corresponding appointment card. This transition is system-triggered — it does not require any action from the doctor or patient.
- **FR-008**: When the appointment is in `calling`, `in_progress`, or `missed` state AND the doctor's call session is still active, the patient's Appointments tab MUST display a "Join Meeting" action on the corresponding appointment card.
- **FR-009**: The "Join Meeting" action MUST allow the patient to enter the active meeting if the session is still valid.
- **FR-010**: The "Join Meeting" action MUST NOT appear when the appointment is in `ended_pending_confirmation`, `completed`, `not_completed`, `declined`, or `scheduled` state. "Join Meeting" disappears at the moment the appointment transitions from `in_progress` (or `missed`/`calling` with active session) into `ended_pending_confirmation` — this is state-driven, not a separate UI-layer rule.
- **FR-011**: If the patient taps "Join Meeting" on an expired session, the system MUST display a clear message explaining the session is no longer available.

**Declined Call**

- **FR-012**: When the patient explicitly declines the incoming call, the system MUST notify the doctor that the call was declined.
- **FR-013**: A declined call MUST result in an appointment status that is distinct from a missed call.
- **FR-014**: After a declined call, the "Join Meeting" action MUST NOT appear for the patient.

**End-of-Call and Doctor Confirmation**

- **FR-015**: When the call session ends while the appointment is in `in_progress` state — whether the doctor ends it, the patient ends it, or both parties lose connectivity simultaneously — the appointment MUST transition to `ended_pending_confirmation`. The appointment MUST NOT transition directly to `completed` under any end-of-call condition. If the doctor ends a waiting session while the appointment is in `calling` or `missed` state (patient never joined), the appointment MUST remain in `missed` state with no confirmation dialog triggered.
- **FR-016**: Immediately after the call ends on the doctor's side, the doctor MUST see a confirmation dialog asking: "Was this consultation completed?"
- **FR-017**: If the doctor selects "Yes", the appointment MUST transition to `completed`.
- **FR-018**: If the doctor selects "No", the appointment MUST transition to `not_completed`.
- **FR-019**: The patient MUST NOT see the appointment as `completed` until the doctor has confirmed "Yes".
- **FR-020**: If the doctor dismisses or does not respond to the confirmation dialog, the system MUST re-prompt the doctor the next time they open the app. If the doctor has still not responded after 24 hours from call end, the appointment MUST automatically transition to `not_completed`.

**Appointment Status Visibility**

- **FR-021**: The patient MUST see a real-time reflection of the appointment status that matches the outcome of the doctor's confirmation.
- **FR-022**: An appointment in `not_completed` state MUST be visually distinguishable from `completed` and `scheduled` appointments for both doctor and patient.

**Expired Tokens and Inactive Sessions**

- **FR-023**: If the session token has expired at the time the patient attempts to join via "Join Meeting", the system MUST display a clear expiry message and block the join attempt.
- **FR-024**: Session token expiry MUST NOT cause the appointment to permanently remain in an unresolved state.

**Call Logging**

- **FR-025**: Every call lifecycle event (initiation, answer, decline, miss, join, end, confirmation, doctor-cancel, retry, auto-timeout) MUST be logged with a timestamp, actor identity, and outcome.

**Doctor Cancel**

- **FR-026**: If the doctor cancels the outgoing call before the patient answers or the ring timeout expires, the appointment MUST return to `scheduled` state. No missed-call notification or indication MUST be sent to the patient for a doctor-cancelled call.

**Call Initiation Guard**

- **FR-027**: The system MUST prevent a doctor from initiating a call on an appointment that is already in `in_progress`, `ended_pending_confirmation`, `completed`, or `not_completed` state. Any such attempt MUST be rejected with a clear message and logged.

**Auto-Transition Enforcement**

- **FR-028**: The 24-hour auto-transition from `ended_pending_confirmation` to `not_completed` MUST be enforced by the backend without requiring any action from the doctor's client device. The transition MUST complete even if the doctor has not opened the app since the call ended.

**Doctor Appointment List During Pending Confirmation**

- **FR-029**: When an appointment is in `ended_pending_confirmation` state and the doctor has dismissed or not yet seen the confirmation dialog, the doctor's appointment list MUST display a clear persistent prompt on the appointment card indicating that a confirmation response is required.

**Patient Appointment Card Display**

- **FR-030**: The patient's appointment card MUST reflect the call state in a user-facing label: when the appointment is in `calling` state, the card MUST display a "Join Meeting" action with an indicator that the doctor is waiting; when in `in_progress` state, the card MUST display a "Join Meeting" action with an indicator that the session is currently active.

**App Crash and State Recovery**

- **FR-031**: The backend MUST be the sole authoritative source of appointment state. On app restart after a crash or force-quit during any state transition, the app MUST retrieve the current appointment state from the backend and render the corresponding UI. No locally cached pre-crash state MAY override the authoritative backend state.

**Retry Count**

- **FR-032**: Doctor retry calls after a patient missed or declined are unlimited in count within the appointment time window. No maximum retry cap applies.

**Idempotent State Transitions**

- **FR-033**: All appointment state transition signals MUST be idempotent. If a signal that would trigger a transition is received more than once (e.g., duplicate end-call events, duplicate missed-call signals), only the first signal MUST apply the state change. Subsequent duplicate signals MUST be silently ignored and logged.

**Session Invalidation on Retry**

- **FR-034**: When a doctor initiates a retry call after a `missed` or `declined` appointment, a new call session with a new token MUST be created. Any previously existing call session for that appointment MUST be invalidated before the new session begins. The patient MUST receive a fresh incoming call notification for the new session.

**End-Call on Terminal State**

- **FR-035**: If an end-call signal is received for an appointment already in `completed` or `not_completed` state, the system MUST silently discard the signal and record a log entry. The terminal appointment state MUST NOT be altered.

**Patient-Facing State Labels**

- **FR-036**: Each appointment state MUST map to a unique, unambiguous patient-facing label. The required labels are: `scheduled` → "Upcoming"; `calling` → "Doctor is calling — Join Now"; `in_progress` → "Session Active — Join Now"; `missed` → "Missed Call"; `declined` → "Call Declined"; `ended_pending_confirmation` → "Awaiting Confirmation"; `completed` → "Completed"; `not_completed` → "Session Incomplete". No two states may share the same label. The `not_completed` and `missed` labels must be visually and textually distinct from each other and from `completed`.

**Ring Timeout Duration**

- **FR-037**: The ring timeout — the period before `calling` automatically transitions to `missed` — MUST be a minimum of 60 seconds. This value MUST be configurable by the backend without a client update.

**24-Hour Countdown Reference Point**

- **FR-038**: The 24-hour auto-transition countdown from `ended_pending_confirmation` to `not_completed` MUST start from `callEndedAt` — the timestamp recorded when the call session ended. It MUST NOT start from when the confirmation dialog was first displayed to the doctor.

**Race Condition: Simultaneous Auto-Transition and Doctor Response**

- **FR-039**: If the doctor submits a response ("Yes" or "No") to the confirmation dialog at the same moment the 24-hour auto-transition fires, the doctor's explicit response MUST take precedence. The resulting state MUST reflect the doctor's choice, not the auto-transition outcome. Both events MUST be logged.

**Session Token Validity Window**

- **FR-040**: The session token for a call MUST remain valid for a minimum of 30 minutes from the time the call was initiated. This ensures the token does not expire during the ring period, a missed-call rejoin, or a reasonable doctor waiting period.

**Missed-Call and Declined-Call Handler Ownership**

- **FR-041**: The `handleMissedCall` and `handleCallDeclined` state transition handlers MUST be system-automatic — triggered by the backend when the timeout or decline event is detected. Neither handler requires any client-side action to fire. Both MUST be idempotent per FR-033.

**Notification Recipient Matrix**

- **FR-042**: The following notification recipients are required for each state transition that produces a notification:
  - `calling` → `missed`: patient receives a push notification ("Missed call from Dr. [Name]") AND a visual card indicator; doctor receives no separate missed-call notification.
  - `calling` → `declined`: doctor receives an in-app notification ("Patient declined the call"); patient receives no additional notification.
  - `calling` → `scheduled` (doctor cancel): neither party receives a notification.
  - `ended_pending_confirmation` → `completed`: patient receives a status update notification ("Your appointment has been marked completed").
  - `ended_pending_confirmation` → `not_completed`: patient receives a status update notification ("Your appointment session was recorded as incomplete").
  - `ended_pending_confirmation` → `not_completed` (24h auto): patient receives the same incomplete notification; doctor receives a notification that the confirmation window has expired and the appointment was auto-resolved.

### Non-Functional Requirements

- **NFR-001 — Reliability**: The incoming call notification MUST be delivered to the patient within 5 seconds of the doctor initiating the call under normal network conditions. The system MUST handle temporary network interruptions without losing appointment state.
- **NFR-002 — Logging**: All call lifecycle events MUST be captured in the `calllogs` audit trail. Errors MUST be logged with enough context to diagnose failures without reproducing them. The `elajtech` data store MUST be used exclusively.
- **NFR-003 — Authorization**: Only the doctor assigned to an appointment MUST be able to initiate a call for that appointment. Only the patient assigned to the appointment MUST be able to join as the patient participant. Unauthorized join attempts MUST be blocked, logged, and the unauthorized user MUST see the message: "You are not authorized to join this meeting."
- **NFR-004 — Region Consistency**: All backend call handling functions MUST run in the `europe-west1` region.
- **NFR-005 — Database Consistency**: All appointment and call state changes MUST be written to the `elajtech` database. No default database writes are permitted for call or appointment data.
- **NFR-006 — UX Clarity**: Both doctor and patient MUST always know the current state of their consultation. Ambiguous states (e.g., "pending confirmation") MUST be clearly communicated in the UI rather than silently withheld.
- **NFR-007 — Regression Safety**: Changes to call lifecycle behavior MUST not break existing appointment booking, confirmation, or notification flows. Any change to how appointment status is set MUST be verified against existing appointment lifecycle tests.

### Key Entities

- **Appointment**: Represents a scheduled consultation between a doctor and a patient. Holds a status field that transitions through the call lifecycle. The `elajtech` database is the authoritative store.
- **Call Session**: Represents the active video meeting associated with an appointment. Holds references to the channel, the token expiry window, and participant join/leave events.
- **Call Event Log**: An append-only record of every lifecycle event in a call. Used for debugging, compliance, and post-call auditing.
- **Doctor**: The initiator of the call. The sole authority on whether a consultation was completed.
- **Patient**: The call recipient. Can answer, decline, or miss the call. Can rejoin via the Appointments tab if the session remains active.

### State Model

The following state machine governs appointment call status. Each state is mutually exclusive. The backend is the sole authoritative source of state at all times.

#### State Definitions

- **`scheduled`** — Appointment is confirmed and no call has been initiated. *Entry*: appointment confirmed by the doctor; no active call session exists.

- **`calling`** — A call session is active and the patient's device is ringing. The VoIP ring being active on the patient's device and the doctor waiting for a response are two aspects of the same `calling` state — they are not distinguished as separate states. *Entry*: doctor initiates a call on a `scheduled`, `missed`, or `declined` appointment within the ±30-minute call window.

- **`in_progress`** — The patient has successfully joined the shared call channel and both parties are connected. *Entry*: backend receives confirmation that the patient has joined the call channel. This is the sole authoritative event — no other condition defines `in_progress`.

- **`missed`** — The patient did not respond within the 60-second ring timeout, OR the patient's device did not receive the VoIP notification (e.g., device offline, delivery failure). Both conditions produce `missed`. *Entry*: ring timeout expires without an answer, or backend detects notification delivery failure. The doctor's call session may remain open after `missed` while waiting for a rejoin.

- **`declined`** — The patient explicitly pressed the decline button. The patient was reachable and made an active choice. *Entry*: patient's decline action received by the backend. Distinct from `missed` in that the patient was available and declined intentionally.

- **`ended_pending_confirmation`** — The call session ended while the appointment was `in_progress` (both parties were at some point connected), and the doctor has not yet responded to the confirmation dialog. *Entry*: call session ends from `in_progress` for any reason — doctor ends, patient ends, or simultaneous connectivity loss. This transition is atomic; no intermediate state exists between `in_progress` and `ended_pending_confirmation`. This state is NOT entered when the doctor ends a session from `calling` or `missed` (patient never joined).

- **`completed`** — Doctor confirmed "Yes". *Entry*: doctor's "Yes" response received while appointment is in `ended_pending_confirmation`. Terminal — no further transitions permitted.

- **`not_completed`** — Doctor confirmed "No", or the 24-hour auto-transition fired. *Entry*: doctor's "No" received, OR 24 hours elapsed since `callEndedAt` with no doctor response. Terminal — no further transitions permitted.

> **`not_completed` vs. `missed`**: `missed` means the patient never joined (no consultation occurred). `not_completed` means both parties connected (`in_progress` was reached) but the consultation was incomplete. Semantically distinct; must carry different patient-facing labels and must not be conflated.

#### State Transitions

| From | To | Trigger | Guard Condition |
|------|----|---------|----------------|
| `scheduled` | `calling` | Doctor initiates call | Within ±30 min of scheduled appointment time; appointment not in an active or terminal state |
| `calling` | `in_progress` | Patient answers | Patient identity matches appointment; session token is valid |
| `calling` | `declined` | Patient presses decline | — |
| `calling` | `missed` | Ring timeout expires OR notification delivery fails | No answer received within 60-second ring timeout |
| `calling` | `scheduled` | Doctor cancels before patient answers | Ring has not timed out; no answer received; no missed-call notification sent to patient |
| `in_progress` | `ended_pending_confirmation` | Doctor ends call; OR patient ends call; OR simultaneous connectivity loss | Appointment is in `in_progress` state (patient had joined) |
| `missed` | `calling` | Doctor re-initiates call | Within ±30 min of scheduled time; previous session invalidated; new session created |
| `missed` | `in_progress` | Patient taps "Join Meeting" | Doctor's call session is still active; session token has not expired; patient identity matches appointment |
| `missed` | `missed` (no change) | Doctor ends waiting session without patient having joined | Doctor's session terminates; appointment state unchanged; no confirmation dialog shown |
| `declined` | `calling` | Doctor retries call | Within ±30 min of scheduled time; new session created; retry count is unlimited within the window |
| `ended_pending_confirmation` | `completed` | Doctor selects "Yes" | Doctor is assigned to this appointment |
| `ended_pending_confirmation` | `not_completed` | Doctor selects "No" | Doctor is assigned to this appointment |
| `ended_pending_confirmation` | `not_completed` | System 24-hour auto-transition | 24 hours elapsed since `callEndedAt`; backend-enforced; no client action required |

> **Call initiation time window**: The ±30-minute window applies identically to initial call initiation (`scheduled` → `calling`), doctor retry after missed (`missed` → `calling`), and doctor retry after declined (`declined` → `calling`). The same guard governs all three transitions — this is intentional and must be enforced consistently.

> **Rejoin eligibility rule**: A patient may use "Join Meeting" only when ALL of the following are true: (1) the appointment is in `calling`, `in_progress`, or `missed` state AND the doctor's call session is still active, (2) the session token has not expired, AND (3) the patient identity matches the appointment. All three conditions must be satisfied simultaneously.

> **Confirmation dialog scope**: The doctor post-call confirmation dialog ONLY appears when transitioning from `in_progress`. It does NOT appear when the doctor ends a waiting session from `calling` or `missed` state (patient never joined).

---

## Implementation Gaps to Verify

The following items must be verified before planning begins. Each item is listed with its current assessed status based on the codebase audit.

| Gap | Assessed Status | Required Action |
|-----|----------------|----------------|
| `handleMissedCall` backend function | Implemented — sets `callStatus: missed` | Verify it also transitions appointment to `missed` state and triggers patient notification |
| `handleCallDeclined` backend function | Implemented — sets `callStatus: declined`, notifies doctor | Verify it correctly prevents "Join Meeting" from appearing for patient |
| Auto-complete conflict: `endAgoraCall` sets status to `completed` | **Conflict confirmed** — must be changed | Remove auto-complete from `endAgoraCall`; introduce `ended_pending_confirmation` state |
| Patient "Join Meeting" from Appointments tab | Not implemented | New UI + eligibility logic required |
| `ended_pending_confirmation` appointment state | Not in current enum | Must be added to appointment status model |
| `not_completed` appointment state | Not in current enum | Must be added to appointment status model |
| Doctor confirmation dialog triggering on call end | Partially implemented (manual button trigger) | Must be automatically triggered when call ends, not require manual navigation |
| Patient appointment status reflecting doctor confirmation | Not verified | Must be confirmed via real-time state listening |

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 95% of patient devices receive the incoming call notification within 5 seconds of the doctor initiating the call.
- **SC-002**: 100% of calls that end result in the appointment transitioning to `ended_pending_confirmation` — never directly to `completed`.
- **SC-003**: Patients who miss a call can successfully rejoin an active meeting from the Appointments tab within 2 taps and 30 seconds, at any point while the doctor has not yet ended the call.
- **SC-004**: Zero appointments are marked `completed` without an explicit "Yes" from the doctor in the post-call confirmation dialog.
- **SC-005**: 100% of call lifecycle events (initiation, answer, decline, miss, end, confirmation) are captured in the call audit log.
- **SC-006**: Patients see an updated appointment status within 5 seconds of the doctor completing the post-call confirmation.
- **SC-007**: No regression in existing appointment booking, confirmation, or notification flows is introduced.

---

## Assumptions

- Both doctor and patient have been authenticated and authorized before the call is initiated.
- The appointment is in `confirmed` or `scheduled` status before a call can be started; calls cannot be started on `pending` or `cancelled` appointments.
- The call session token window is sufficient to cover the full ring period plus a reasonable rejoin window for missed calls (assumed: minimum 30 minutes from call initiation).
- Doctor confirmation timeout: if no response is given to the post-call dialog, the doctor is re-prompted on next app open. After 24 hours from call end with no response, the appointment automatically transitions to `not_completed`.
- The `elajtech` Firestore database is the single source of truth for all appointment and call state.
- All backend functions involved in this workflow are deployed to `europe-west1`.
- The existing `CallMonitoringService` and `calllogs` collection are sufficient for logging requirements and do not need structural changes.
- Missed-call indication is delivered via two channels: a push notification to the patient's device (using the same push channel as other app notifications) and a visual indicator on the appointment card in the Appointments tab.
- "Join Meeting" eligibility is enforced on both the client (UI visibility) and the backend (join validation) to prevent unauthorized access.
