# Phase 0: Research Findings — Agora Call Workflow Alignment

**Branch**: `007-agora-call-alignment` | **Date**: 2026-03-31

---

## Codebase Audit Results

### Current Cloud Functions (functions/index.js)

| Function | Current Behavior | Gap vs. Desired |
|----------|-----------------|-----------------|
| `startAgoraCall` | Sets `callStatus: 'ringing'`; does NOT update `status` field; generates Agora RTC token with 3600s expiry; sends VoIP push to patient | Must also set `status: 'calling'` and `callSessionId` |
| `endAgoraCall` | Sets `callStatus: 'ended'` and `callEndedAt`; does NOT transition `status` | Must set `status: 'ended_pending_confirmation'` instead of leaving it unchanged |
| `completeAppointment` | Sets `status: 'completed'` — manually called by doctor | Will delegate to new `confirmAppointmentCompletion(completed: true)` for backward compatibility |
| `handleMissedCall` | Sets `callStatus: 'missed'`, `missedAt`; exists as callable | Must also set `status: 'missed'`; must add FCM push notification to patient |
| `handleCallDeclined` | Sets `callStatus: 'declined'`, `declinedAt`; exists as callable | Must also set `status: 'declined'` |
| `checkAppointmentReminders` | Pub/Sub scheduler running every 5 minutes; checks appointment reminders | Will be extended or a parallel scheduler added for 24h auto-transition |

**Key finding**: `endAgoraCall` does NOT currently auto-complete appointments — it only sets `callStatus: 'ended'`. Completion requires a separate `completeAppointment` call. The conflict is not about auto-completion; it is about the Yes-only nature of the doctor confirmation (no explicit "No, incomplete" path exists).

### Current Flutter Model (lib/shared/models/appointment_model.dart)

Current `AppointmentStatus` enum values:
```
pending, confirmed, scheduled, completed, cancelled, missed
```

`fromJson` uses `firstWhere` with fallback to `AppointmentStatus.pending` for unknown strings.
`toJson` uses `.name` property directly.

**Gap**: The following status strings from the new backend will not map to any enum value and will fall back to `pending`:
- `calling`, `in_progress`, `declined`, `ended_pending_confirmation`, `not_completed`

### Existing Patient Navigation

- No patient appointments screen exists currently. The patient has no UI to list their appointments.
- `PatientNavigationHelper` exists and handles screen routing but has no `openAppointments()` method.
- `IncomingCallScreen` handles cold-start restoration but does not check current appointment status before restoring.

### Token Expiry and Session Validity

- Agora token expiry is hardcoded at `3600s` (1 hour) from `callStartedAt` in `startAgoraCall`.
- FR-040 requires token valid minimum 30 minutes from initiation — satisfied by 3600s.
- Rejoin eligibility check in `patientJoinCall` must validate: `callStartedAt + 3600 > now`.

### Existing Scheduler Pattern

`checkAppointmentReminders` runs via Cloud Scheduler every 5 minutes using Pub/Sub topic `appointment-reminders`. The 24h auto-transition scheduler will follow the identical pattern using a new or extended function. Running every 30 minutes is sufficient for 24h precision.

---

## Design Decisions

### Decision 1: Call State Field Strategy

**Decision**: Extend the existing `AppointmentStatus` enum. Use `status` as the single unified field for both appointment and call lifecycle state.

**Rationale**: The current codebase has a split between `status` (appointment-level) and `callStatus` (call-level). This split creates inconsistency — the UI must check two fields to determine display state. Unifying into `status` eliminates the split and creates a single source of truth. `callStatus` can be retained as a legacy field written alongside `status` for backward compatibility during transition.

**Alternatives considered**:
- Add a separate `callLifecycleStatus` field — rejected; adds another split
- Keep `callStatus` as the primary field — rejected; `status` is the field all existing query logic reads

---

### Decision 2: 24-hour Auto-Transition Mechanism

**Decision**: Add a pub/sub scheduled Cloud Function following the `checkAppointmentReminders` pattern. Run every 30 minutes. Query appointments where `status == 'ended_pending_confirmation'` and `confirmationDeadlineAt <= now`.

**Rationale**: The pattern is already established in the codebase. No new infrastructure is needed. A 30-minute run frequency provides more than sufficient precision for a 24-hour window (worst case: 30-minute delay vs. exact deadline). The function is idempotent: once status changes, it will not reprocess the same appointment.

**Alternatives considered**:
- Cloud Tasks per-appointment timer — rejected; adds unnecessary complexity and infrastructure for a 24h window
- Client-side timer — rejected; violates FR-028 (backend-enforced; no client dependency)

---

### Decision 3: Doctor Confirmation Dialog Trigger

**Decision**: Auto-trigger from `AgoraVideoCallScreen._endCall()` (or the `dispose` callback when the doctor ends the call) via Riverpod provider carrying pending-confirmation state. The dialog shows on the doctor's appointment screen after navigation pops back.

**Rationale**: The call screen already knows when the call is ending (the `_endCall` button triggers it). Rather than relying on a Firestore stream to re-trigger the dialog, the screen can pass back a result to the parent screen (doctor appointments screen) indicating confirmation is required. The doctor appointments screen already exists and handles appointment interactions.

**Alternatives considered**:
- Firestore stream listener that auto-triggers dialog when status becomes `ended_pending_confirmation` — also valid; can be used as the re-trigger mechanism for FR-020 (dialog on next app open)
- Both approaches are used: navigation result for immediate trigger, stream listener for re-prompt on next app open

---

### Decision 4: Patient Appointments Screen

**Decision**: Create a new `patient_appointments_screen.dart` with appointment cards showing patient-facing status labels (FR-036) and "Join Meeting" button (FR-030). Navigate to it from `PatientNavigationHelper.openAppointments()`.

**Rationale**: No patient appointment list screen currently exists. The patient currently has no UI to see their appointment states or rejoin missed calls. This is a required new screen per the feature spec.

**Alternatives considered**:
- Integrate into existing home screen — rejected; adds complexity to an existing screen; new screen follows Clean Architecture feature module pattern

---

### Decision 5: Session Invalidation on Retry

**Decision**: `startAgoraCall` already uses a timestamp-based channel name (`channel_${appointmentId}_${timestamp}`). Re-initiating the call naturally generates a new channel name. The old session becomes orphaned. No additional invalidation logic needed.

**Rationale**: The existing implementation already provides the correct behavior by default. FR-034 requires new sessions invalidate old ones — the timestamp channel name satisfies this since the old channel name is no longer referenced after a retry.

**Alternatives considered**:
- Explicit session invalidation field — not needed since channel name is timestamp-based

---

### Decision 6: Flutter Deployment Order (Rollout Safety)

**Decision**: Flutter enum extension (Phase B) must be deployed BEFORE the Cloud Functions change (Phase A2) goes live. This prevents unknown status strings falling back to `pending` while the app is receiving new `ended_pending_confirmation` strings from the backend.

**Rationale**: The `fromJson` fallback to `pending` would cause the patient or doctor UI to show an incorrect state if the backend transitions to `ended_pending_confirmation` before the Flutter app knows about it.

---

## Resolved Unknowns

| Unknown | Resolution |
|---------|-----------|
| Is `handleMissedCall` implemented? | Yes — exists in `functions/index.js`; sets `callStatus: 'missed'` only; missing: `status` field update and push notification |
| Is `handleCallDeclined` implemented? | Yes — exists in `functions/index.js`; sets `callStatus: 'declined'` only; missing: `status` field update |
| Does `endAgoraCall` auto-complete? | No — only sets `callStatus: 'ended'`; completion requires separate `completeAppointment` call |
| Is patient rejoin from Appointments supported? | No — no patient appointments screen exists; `patientJoinCall` callable does not exist |
| What token expiry does `startAgoraCall` use? | 3600s (1 hour) — satisfies FR-040 (min 30 min) |
| Does a scheduler already exist? | Yes — `checkAppointmentReminders` pub/sub; 5-minute frequency; can extend or add parallel function |
