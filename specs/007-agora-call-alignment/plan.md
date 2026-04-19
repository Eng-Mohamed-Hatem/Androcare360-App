# Implementation Plan: Agora Call Workflow Alignment

**Branch**: `007-agora-call-alignment` | **Date**: 2026-03-31 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/007-agora-call-alignment/spec.md`

---

## Summary

Align the AndroCare360 doctor-patient Agora video call workflow with the approved business rules by:
1. Extending the `AppointmentStatus` enum with 5 new states that model the full call lifecycle
2. Modifying `endAgoraCall` and related Cloud Functions to transition through `ended_pending_confirmation` rather than auto-completing
3. Adding a new `confirmAppointmentCompletion` callable that captures Yes/No doctor intent
4. Auto-triggering the doctor confirmation dialog when the call screen is dismissed
5. Adding a `patientJoinCall` callable and patient-side "Join Meeting" entry point for missed-call rejoin
6. Adding a 24-hour auto-transition scheduled function for unresolved confirmations
7. Delivering push notifications for missed-call and completion events per the FR-042 matrix

---

## Technical Context

**Language/Version**: Dart / Flutter (mobile, iOS + Android) + Node.js 18 (Firebase Cloud Functions)
**Primary Dependencies**:
- Flutter: `agora_rtc_engine`, `cloud_firestore`, `firebase_messaging`, `flutter_riverpod`, `flutter_local_notifications`
- Cloud Functions: Firebase Admin SDK, `agora-access-token`, Firebase Functions v2
**Storage**: Firestore — `databaseId: elajtech` (mandatory; default database must not be used)
**Testing**: Flutter test framework (unit + widget), Jest (Cloud Functions integration)
**Target Platform**: iOS 13+ and Android 8+ (mobile)
**Project Type**: Mobile app (Flutter Clean Architecture) + Backend (Firebase Cloud Functions)
**Performance Goals**: Notification delivery ≤5s (SC-001); patient joins meeting ≤10s of answering (SC-006); status update visible to patient ≤5s (SC-006)
**Constraints**: All Cloud Functions in `europe-west1`; all Firestore writes to `elajtech`; no client-side trust for call state transitions; Clean Architecture layers respected
**Scale/Scope**: 1:1 doctor-patient video calls per appointment; concurrent calls are per-appointment, not shared channels

---

## Constitution Check

*GATE: Must pass before implementation begins.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Clean Architecture | ✅ Pass | All call state changes flow through Domain layer (UseCases/Services); no direct Firestore writes from UI |
| II. Riverpod | ✅ Pass | New call state providers required; appointment state listened via StreamProvider |
| III. Code Quality | ✅ Pass | New enum cases and functions must follow Effective Dart naming |
| IV. Documentation | ✅ Pass | All new public classes and Cloud Functions must carry Arabic + English documentation |
| V. Security — server-side auth | ✅ Pass | FR-015, FR-027, FR-033, FR-035 ensure all transitions are backend-enforced; patient cannot self-complete |
| V. Security — call metadata | ✅ Pass | FR-042 notifications must not include PHI beyond doctor name; tokens must not be logged |
| VI. Performance | ✅ Pass | Notification timing and join latency targets defined in SC-001, SC-006 |
| VII. UX | ✅ Pass | FR-036 defines patient labels in both states; error messages defined; Arabic RTL labels used |
| **VIII. Telemedicine Testing** | ✅ **GATE** | Constitution §VIII requires automated coverage for doctor + patient call flows, callable-function error handling, and session lifecycle boundaries. Test requirements defined in Phase 4. |
| IX. Project Structure | ✅ Pass | New files follow existing feature module structure; no folder reorganization |
| X. Spec Kit Lifecycle | ✅ Pass | Full lifecycle followed: specify → clarify → checklist → plan |
| XI. Human Governance | ✅ Pass | All architectural decisions surfaced; human approval required before implementation |
| **XII. Telemedicine Lifecycle** | ✅ **GATE** | State ownership documented; source of truth is backend; patient-side cannot auto-complete; timeout/retry/reconnect documented in spec (FR-015, FR-020, FR-028, FR-031, FR-037–FR-040) |

**No gate violations. All constitution checks pass.**

---

## Project Structure

### Documentation (this feature)

```text
specs/007-agora-call-alignment/
├── plan.md              ← This file
├── research.md          ← Phase 0 output
├── data-model.md        ← Phase 1 output
├── contracts/
│   ├── cloud-functions.md
│   └── firestore-schema.md
└── tasks.md             ← Phase 2 output (/speckit.tasks)
```

### Source Code (affected files)

```text
functions/
└── index.js                                    # 8 function modifications/additions

lib/
├── shared/
│   └── models/
│       └── appointment_model.dart              # Enum extension + fromJson
├── core/
│   └── services/
│       ├── video_consultation_service.dart     # New patientJoinCall method
│       └── appointment_completion_service.dart  # New confirmCompletion(bool) method
└── features/
    ├── patient/
    │   ├── appointments/
    │   │   └── presentation/
    │   │       ├── screens/
    │   │       │   └── patient_appointments_screen.dart  # NEW: patient appointment list
    │   │       └── widgets/
    │   │           └── appointment_card_widget.dart       # NEW: card with Join Meeting
    │   ├── consultation/
    │   │   └── presentation/screens/
    │   │       └── agora_video_call_screen.dart           # Auto-trigger dialog on end
    │   └── navigation/
    │       └── presentation/helpers/
    │           └── patient_navigation_helper.dart         # Add openAppointments()
    └── appointments/
        └── presentation/
            └── screens/
                └── doctor_appointments_screen.dart        # Yes/No dialog + auto-trigger

test/
├── unit/
│   └── core/
│       └── appointment_status_state_machine_test.dart    # NEW
└── integration/
    ├── agora_call_happy_path_test.dart                   # NEW
    └── agora_missed_call_rejoin_test.dart                # NEW
```

---

## Complexity Tracking

No constitution violations requiring justification.

---

## Phase 0: Research Findings

See [research.md](research.md) for full findings.

**Key decisions:**

| Decision | Chosen Approach | Rationale |
|----------|----------------|-----------|
| Call state field | Extend `AppointmentStatus` enum; use `status` as unified field | Eliminates split between `status` and `callStatus`; single source of truth; backward-compatible addition |
| 24h auto-transition | Pub/Sub scheduled function (extend existing `checkAppointmentReminders` pattern) | Pattern already established in codebase; no extra infrastructure needed; sufficient for 24h window |
| Doctor confirmation trigger | Auto-trigger from `AgoraVideoCallScreen` dispose/end callback via Riverpod | Screen already knows call ended; Riverpod provider can carry pending-confirmation state |
| Patient Join Meeting | New `patientJoinCall` callable + new patient appointment screen | No patient appointment view exists currently; must be built from scratch |
| Session invalidation on retry | `startAgoraCall` generates new channel name with new timestamp; old channel becomes orphaned | Already uses timestamp in channel name; behavior is correct by default |

---

## Phase 1: Design

### Implementation Phases

---

### Phase A — Backend: State Machine Foundation (Cloud Functions)

**Objective**: Make the backend the authoritative state machine for all call lifecycle transitions.

**A1 — Modify `startAgoraCall`**
- Add: set `status: 'calling'` on appointment document when call is initiated
- Add: set `callSessionId` to the channel name (for session tracking)
- Preserve all existing token generation, VoIP notification, and logging behavior

**A2 — Modify `endAgoraCall`**
- Change: instead of `callStatus: 'ended'` only, also set `status: 'ended_pending_confirmation'`
- Add: compute and store `confirmationDeadlineAt = callEndedAt + 24 hours`
- Guard: if appointment is already in `completed`, `not_completed`, or `cancelled` — discard signal and log (FR-035)
- Guard: if appointment is in `calling` or `missed` (patient never joined) — set `status` back to `missed` (no confirmation dialog) per FR-015

**A3 — Add `confirmAppointmentCompletion` callable**
- Parameters: `{ appointmentId, doctorId, completed: boolean }`
- If `completed === true`: set `status: 'completed'`, `completedAt: now`
- If `completed === false`: set `status: 'not_completed'`, `notCompletedAt: now`
- Authorization: verify `doctorId` matches appointment's `doctorId`
- Guard: only valid when current status is `ended_pending_confirmation`
- Idempotent: if already `completed` or `not_completed`, return current state without error
- Send patient notification per FR-042

**A4 — Add `patientJoinCall` callable**
- Parameters: `{ appointmentId, patientId }`
- Eligibility check: appointment status must be `calling`, `in_progress`, or `missed`; `callSessionId` must exist; token has not expired (use `callStartedAt + 3600s`)
- Authorization: verify `patientId` matches appointment's `patientId`
- Returns: `{ agoraToken, channelName, uid }` — same token generation as `startAgoraCall`
- On success: set `status: 'in_progress'` (patient is now joining)
- Idempotent: if already `in_progress`, return new token for same channel

**A5 — Add `cancelCall` callable**
- Parameters: `{ appointmentId, doctorId }`
- Guard: only valid when status is `calling`
- Action: set `status: 'scheduled'`; clear `callSessionId`, `callStartedAt`, `callStatus`
- No patient notification (FR-026)

**A6 — Modify `handleMissedCall`**
- Existing: sets `callStatus: 'missed'`, `missedAt`
- Add: set `status: 'missed'`
- Add: send FCM push notification to patient: "Missed call from Dr. [name]" (FR-007, FR-042)
- Add: `callSessionActive: true` flag (so patient can still see "Join Meeting")
- Idempotent: if already `missed`, do nothing (FR-033)

**A7 — Modify `handleCallDeclined`**
- Existing: sets `callStatus: 'declined'`, `declinedAt`
- Add: set `status: 'declined'`
- Preserve doctor notification
- Idempotent: if already `declined`, do nothing

**A8 — Add scheduled auto-transition (24h)**
- Extend existing pub/sub scheduler pattern (`checkAppointmentReminders`)
- Add query: find appointments where `status == 'ended_pending_confirmation'` AND `confirmationDeadlineAt <= now`
- For each: set `status: 'not_completed'`, send patient notification (FR-042), send doctor expiry notification (FR-042)
- Run frequency: every 30 minutes is sufficient for 24h precision
- Idempotent: skip if status has already changed

---

### Phase B — Flutter: Enum and Model

**B1 — Extend `AppointmentStatus` enum** (`appointment_model.dart`)

Add the following values:
```
calling           → Firestore string: 'calling'
inProgress        → Firestore string: 'in_progress'
declined          → Firestore string: 'declined'
endedPendingConfirmation → Firestore string: 'ended_pending_confirmation'
notCompleted      → Firestore string: 'not_completed'
```

Update `fromJson` mapping to handle all new string values with correct enum mapping.
Keep `missed` (already exists), `completed` (already exists), `scheduled` (already exists).

**B2 — Update `AppointmentModel.fromFirestore`**
- Map all new status strings to new enum values
- Existing fallback to `pending` is preserved for unknown values
- Add `callSessionId` and `confirmationDeadlineAt` fields to model

---

### Phase C — Flutter: Doctor-Side Confirmation Flow

**C1 — Auto-trigger confirmation dialog in `AgoraVideoCallScreen`**
- When `_endCall()` is called and the user's role is `doctor`
- After `Navigator.pop(context)`, use a post-frame callback or route result to trigger the confirmation dialog on the previous screen
- Pass `appointmentId` and `doctorId` through route result or via Riverpod provider

**C2 — Modify `_showCompleteDialog` in `doctor_appointments_screen.dart`**
- Change from single "Complete" action to two actions: "Yes, completed" and "No, incomplete"
- "Yes" → calls `AppointmentCompletionService.confirmCompletion(appointmentId, doctorId, completed: true)`
- "No" → calls `AppointmentCompletionService.confirmCompletion(appointmentId, doctorId, completed: false)`
- Remove the old "Cancel" dismiss option — both buttons must set a definitive state
- Dialog must auto-trigger when doctor's call screen pops AND appointment was in `in_progress` state
- Dialog must also re-appear on next app open if appointment is in `ended_pending_confirmation` (FR-020)

**C3 — Update `AppointmentCompletionService`**
- Add: `confirmCompletion({ appointmentId, doctorId, completed: bool })` method
- Calls new `confirmAppointmentCompletion` Cloud Function
- Keep existing `completeAppointment` method for backward compatibility (delegates to `confirmCompletion(completed: true)`)

**C4 — Show pending-confirmation prompt in doctor appointment list**
- When appointment status is `endedPendingConfirmation`, show a persistent "Confirmation Required" badge/banner on the appointment card (FR-029)
- Tapping it re-shows the Yes/No confirmation dialog

---

### Phase D — Flutter: Patient-Side Join Meeting

**D1 — Create patient appointments screen** (`patient_appointments_screen.dart`)
- Shows the patient's upcoming and recent appointments
- Appointment card displays the patient-facing label per state (FR-036)
- When status is `calling`, `inProgress`, or `missed` with active session: show "Join Meeting" button
- Tapping "Join Meeting" calls `VideoConsultationService.patientJoinCall(appointmentId, patientId)`
- On success: navigate to `AgoraVideoCallScreen` with returned token data

**D2 — Add `VideoConsultationService.patientJoinCall`**
- Calls `patientJoinCall` Cloud Function
- Returns `AgoraCallData` with token, channel, uid
- Handles error cases: session expired (FR-023), unauthorized (NFR-003), already ended (FR-011)

**D3 — Add `openAppointments()` to `PatientNavigationHelper`**
- Navigates to `PatientAppointmentsScreen`
- Called from home screen or missed-call notification tap

**D4 — Update cold-start restoration guard** (`incoming_call_screen.dart` / app initialization)
- On app launch from terminated state: read current appointment status from backend
- Only proceed with call restoration if status is `calling` or `inProgress` (FR-005)
- If status is `missed`, `endedPendingConfirmation`, `completed`, or `notCompleted`: navigate to patient appointments screen instead

---

### Phase E — Notifications

**E1 — Missed call push notification**
- Triggered by `handleMissedCall` (A6)
- Payload: `{ type: 'missed_call', appointmentId, doctorName }`
- Notification tap: deep link to patient appointments screen → appointment card with "Join Meeting"

**E2 — Completion notifications**
- `completed`: patient receives "Your appointment has been marked completed" (FR-042)
- `not_completed`: patient receives "Your appointment session was recorded as incomplete" (FR-042)
- 24h auto-expiry: patient and doctor both notified per FR-042

---

### Phase F — Testing (Constitution §VIII Gate)

**F1 — Unit tests: state machine** (`appointment_status_state_machine_test.dart`)
- Test all 13 valid state transitions from the transitions table
- Test all guard conditions (wrong state, wrong actor, time window)
- Test idempotency (duplicate signals)
- Test terminal state protection (FR-035)

**F2 — Unit tests: Cloud Function logic**
- `endAgoraCall`: verify `ended_pending_confirmation` is set; verify no direct `completed`; verify terminal state guard
- `confirmAppointmentCompletion`: verify both `completed` and `not_completed` paths; verify wrong-doctor rejection
- `patientJoinCall`: verify eligibility checks; verify expired token rejection

**F3 — Integration tests: doctor call happy path**
- Doctor starts call → appointment is `calling` → patient answers → `in_progress` → doctor ends → `ended_pending_confirmation` → doctor confirms Yes → `completed`
- Verify patient sees `completed` label

**F4 — Integration tests: missed call rejoin**
- Doctor starts call → appointment is `calling` → ring timeout → `missed` → patient opens app → sees "Join Meeting" → taps → joins → `in_progress` → call ends → doctor confirms

**F5 — Integration tests: 24h auto-transition**
- Appointment reaches `ended_pending_confirmation` → simulate 24h elapsed → verify transition to `not_completed` → verify patient notification

**F6 — Regression tests**
- Existing `completeAppointment` callable must still work (delegates to `confirmCompletion(completed: true)`)
- Existing appointment booking, scheduling, and confirmation flows must not be affected
- Existing doctor start-call button must still work

---

## Rollout Considerations

1. The `endAgoraCall` modification is a **breaking change** in behavior — previously it set `callStatus: 'ended'` only; now it also sets `status: 'ended_pending_confirmation'`. Any existing appointments in flight must be handled gracefully (old status values must fall through to existing behavior).
2. The new `AppointmentStatus` enum values must be deployed to Flutter **before** the Cloud Functions change goes live — otherwise the app will receive unknown status strings and fall back to `pending`.
3. The 24h scheduler can be deployed independently and run safely on existing data (it will only find appointments in `ended_pending_confirmation`, which will not exist until the new backend is live).
4. The patient appointments screen can be deployed without the "Join Meeting" logic and progressively enhanced.
