# Tasks: Agora Call Workflow Alignment

**Input**: Design documents from `specs/007-agora-call-alignment/`
**Prerequisites**: plan.md ✅ | spec.md ✅ | research.md ✅ | data-model.md ✅ | contracts/ ✅

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.
**Tests**: Included — required by Constitution §VIII (Telemedicine Testing gate) and plan Phase F.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1–US4)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Verify project structure and create the two new feature-module files before any implementation begins.

- [x] T001 Verify feature branch `007-agora-call-alignment` is checked out and CI is green before any changes
- [x] T002 [P] Create empty placeholder `lib/features/patient/appointments/presentation/screens/patient_appointments_screen.dart` with a `TODO` stub so dependent tasks have a compile target
- [x] T003 [P] Create empty placeholder `lib/features/patient/appointments/presentation/widgets/appointment_card_widget.dart` with a `TODO` stub

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Flutter enum and model changes that MUST be deployed before Cloud Functions state changes go live. All user stories depend on the app correctly recognising the new status strings.

**⚠️ CRITICAL**: These tasks block all user stories. Complete and validate before Phase 3.

- [x] T004 Extend `AppointmentStatus` enum in `lib/shared/models/appointment_model.dart` — add `calling`, `inProgress`, `declined`, `endedPendingConfirmation`, `notCompleted` with their Firestore string values per data-model.md §1
- [x] T005 Update `AppointmentModel.fromJson` / `fromFirestore` in `lib/shared/models/appointment_model.dart` — add switch-case mapping for all 5 new status strings; preserve fallback to `pending` for unknown values per data-model.md §1
- [x] T006 Add `callSessionId` (String?) and `confirmationDeadlineAt` (DateTime?) fields to `AppointmentModel` in `lib/shared/models/appointment_model.dart` per data-model.md §2
- [x] T007 [P] Write unit tests for `AppointmentStatus` enum serialisation round-trip in `test/unit/core/appointment_status_serialisation_test.dart` — cover all 11 known values plus an unknown string falling back to `pending`

**Checkpoint**: Run `flutter test test/unit/core/appointment_status_serialisation_test.dart`. All tests must pass before Phase 3 begins.

---

## Phase 3: User Story 1 — Doctor Initiates Call, Patient Answers (Priority: P1) 🎯 MVP

**Goal**: End-to-end happy path — doctor starts call, patient answers, both are in meeting, doctor ends and confirms "Yes", appointment becomes `completed`.

**Independent Test**: Start a call as doctor, answer on patient device, end call, select "Yes" in confirmation dialog — appointment shows `completed` for both.

### Tests for User Story 1

- [x] T008 [P] [US1] Write unit tests for `startAgoraCall` side effects in `test/unit/core/auth/` — verify `status: 'calling'`, `callSessionId`, `callStartedAt` are written; verify guard rejects duplicate-initiation states per FR-027
- [x] T009 [P] [US1] Write unit tests for `endAgoraCall` in `test/unit/core/auth/` — verify transition to `ended_pending_confirmation`; verify terminal-state guard (FR-035); verify `missed`-state guard (FR-015, patient never joined → stay `missed`)
- [x] T010 [P] [US1] Write unit tests for `confirmAppointmentCompletion` in `test/unit/core/auth/` — verify `completed` path, `not_completed` path, wrong-doctor rejection, wrong-state rejection, idempotency (FR-033)
- [x] T011 [P] [US1] Write state machine unit tests for all valid US1 transitions in `test/unit/core/appointment_status_state_machine_test.dart` — `scheduled→calling`, `calling→in_progress`, `in_progress→ended_pending_confirmation`, `ended_pending_confirmation→completed`, `ended_pending_confirmation→not_completed`
- [x] T012 [US1] Write integration test for doctor call happy path in `test/integration/agora_call_happy_path_test.dart` — full flow: doctor starts → `calling` → patient answers → `in_progress` → doctor ends → `ended_pending_confirmation` → doctor confirms Yes → `completed`; verify patient sees `completed` label

### Backend — User Story 1

- [x] T013 [US1] Modify `startAgoraCall` in `functions/index.js` — add writes: `status: 'calling'`, `callSessionId: channelName`, `callStartedAt: now`; add duplicate-call guard per FR-027 (reject if status ∈ {`calling`, `in_progress`, `completed`, `not_completed`, `cancelled`}); preserve all existing token generation, VoIP notification, and logging behavior (plan §A1)
- [x] T014 [US1] Modify `endAgoraCall` in `functions/index.js` — change behavior to set `status: 'ended_pending_confirmation'`, `confirmationDeadlineAt: callEndedAt + 86400s`; add terminal-state guard (FR-035 — discard if status ∈ {`completed`, `not_completed`, `cancelled`}); add missed-state guard (FR-015 — if status is `calling` or `missed`, keep `missed`, skip confirmation); preserve `callStatus: 'ended'` legacy write and `callEndedAt` (plan §A2)
- [x] T015 [US1] Add `confirmAppointmentCompletion` callable in `functions/index.js` — params: `{appointmentId, doctorId, completed: boolean}`; if true: set `status: 'completed'`, `completedAt`; if false: set `status: 'not_completed'`, `notCompletedAt`; verify `doctorId` matches appointment; guard: only valid when status is `ended_pending_confirmation`; idempotent if already terminal; send patient notification per FR-042 (plan §A3)

### Flutter Doctor — User Story 1

- [x] T016 [US1] Update `AppointmentCompletionService` in `lib/core/services/appointment_completion_service.dart` — add `confirmCompletion({required String appointmentId, required String doctorId, required bool completed})` method that calls the new `confirmAppointmentCompletion` Cloud Function; keep existing `completeAppointment` method delegating to `confirmCompletion(completed: true)` for backward compatibility (plan §C3)
- [x] T017 [US1] Modify `_showCompleteDialog` in `lib/features/appointments/presentation/screens/doctor_appointments_screen.dart` — replace single "Complete" button with two actions: "Yes, completed" → `AppointmentCompletionService.confirmCompletion(..., completed: true)` and "No, incomplete" → `confirmCompletion(..., completed: false)`; remove old "Cancel" dismiss option (both buttons must set definitive state per FR-017/FR-018) (plan §C2)
- [x] T018 [US1] Modify `AgoraVideoCallScreen._endCall()` in `lib/features/patient/consultation/presentation/screens/agora_video_call_screen.dart` — when the user's role is `doctor` and call ends, use a post-frame callback or `Navigator.pop` result to trigger the confirmation dialog on the doctor appointments screen; pass `appointmentId` and `doctorId` via route result or Riverpod provider (plan §C1)

**Checkpoint**: Run integration test T012. Full happy path must pass. Verify `completeAppointment` backward-compat still works.

---

## Phase 4: User Story 2 — Patient Misses Call and Rejoins (Priority: P2)

**Goal**: Doctor starts call, patient misses ring, patient opens Appointments tab, sees "Join Meeting" on the card, taps it, and enters the active meeting.

**Independent Test**: Have doctor start a call, let ring timeout expire (or decline on patient side), then patient opens app → Appointments tab → taps "Join Meeting" → enters meeting with doctor.

### Tests for User Story 2

- [x] T019 [P] [US2] Write unit tests for `patientJoinCall` in `test/unit/core/auth/` — verify eligibility checks (state, token, identity); verify expired token rejection (FR-040); verify `PERMISSION_DENIED` for wrong patient; verify `in_progress` idempotency
- [x] T020 [P] [US2] Write unit tests for `handleMissedCall` in `test/unit/core/auth/` — verify `status: 'missed'` write; verify `callSessionActive: true` write; verify FCM push notification dispatched; verify idempotency (FR-033/FR-041)
- [x] T021 [P] [US2] Write state machine unit tests for US2 transitions in `test/unit/core/appointment_status_state_machine_test.dart` — `calling→missed` (timeout), `missed→in_progress` (patient rejoin); include guard tests (expired token, wrong state)
- [x] T022 [US2] Write integration test for missed call rejoin in `test/integration/agora_missed_call_rejoin_test.dart` — doctor starts → `calling` → ring timeout → `missed` → patient opens app → sees "Join Meeting" → taps → `in_progress` → call ends → doctor confirms (plan §F4)

### Backend — User Story 2

- [x] T023 [US2] Modify `handleMissedCall` in `functions/index.js` — add: `status: 'missed'`, `callSessionActive: true`; add FCM push notification to patient with payload `{type: 'missed_call', appointmentId, doctorName}` per FR-042; idempotent: skip all writes if status already `missed`; preserve existing `callStatus: 'missed'` and `missedAt` writes (plan §A6)
- [x] T024 [US2] Add `patientJoinCall` callable in `functions/index.js` — params: `{appointmentId, patientId}`; eligibility: status ∈ {`calling`, `in_progress`, `missed`}, `callSessionId` exists, `callStartedAt + 3600 > now`; verify `patientId` matches appointment; generate new Agora token for existing `callSessionId` channel; set `status: 'in_progress'`; idempotent if already `in_progress`; return `{agoraToken, channelName, uid}` per contracts/cloud-functions.md §A4

### Flutter Patient — User Story 2

- [x] T025 [US2] Add `patientJoinCall` method to `VideoConsultationService` in `lib/core/services/video_consultation_service.dart` — calls `patientJoinCall` Cloud Function; returns `AgoraCallData`; handles error codes: `DEADLINE_EXCEEDED` (session expired), `PERMISSION_DENIED` (unauthorized), `FAILED_PRECONDITION` (wrong state) per contracts §A4 and FR-011/FR-023 (plan §D2)
- [x] T026 [US2] Implement `PatientAppointmentsScreen` in `lib/features/patient/appointments/presentation/screens/patient_appointments_screen.dart` — lists patient appointments; shows patient-facing state labels per FR-036; shows "Join Meeting" button when status ∈ {`calling`, `inProgress`, `missed` with `callSessionActive`}; tapping "Join Meeting" calls `VideoConsultationService.patientJoinCall` → navigates to `AgoraVideoCallScreen` on success; shows error message on session expiry or wrong state (plan §D1)
- [x] T027 [US2] Implement `AppointmentCardWidget` in `lib/features/patient/appointments/presentation/widgets/appointment_card_widget.dart` — displays appointment card with status label from FR-036; shows/hides "Join Meeting" based on appointment state and `callSessionActive`; shows "Confirmation Required" badge for `endedPendingConfirmation` on doctor-side cards (plan §D1, §C4)
- [x] T028 [US2] Add `openAppointments()` to `PatientNavigationHelper` in `lib/features/patient/navigation/presentation/helpers/patient_navigation_helper.dart` — navigates to `PatientAppointmentsScreen`; called from patient home screen or missed-call notification tap (plan §D3)
- [x] T029 [US2] Update cold-start restoration guard in `lib/features/patient/consultation/presentation/screens/incoming_call_screen.dart` — on app launch from terminated state, read current appointment status from backend before restoring; only proceed with call restoration if status ∈ {`calling`, `inProgress`}; if status is `missed`, `endedPendingConfirmation`, `completed`, or `notCompleted`, navigate to `PatientAppointmentsScreen` instead per FR-005 (plan §D4)

**Checkpoint**: Run integration test T022. Patient rejoin must complete successfully. Verify expired-session error message appears correctly.

---

## Phase 5: User Story 3 — Doctor Ends Call Without Completing (Priority: P2)

**Goal**: Doctor ends call, dismisses or misses the confirmation dialog, appointment persists in `ended_pending_confirmation` with a visible badge, and auto-transitions to `not_completed` after 24 hours if doctor still has not responded.

**Independent Test**: End a call, dismiss the dialog, verify "Confirmation Required" badge on appointment card; simulate 24h elapsed, verify appointment becomes `not_completed` and patient is notified.

### Tests for User Story 3

- [x] T030 [P] [US3] Write unit tests for `autoCompleteExpiredConfirmations` scheduler in `test/unit/core/auth/` — verify correct query (`status == ended_pending_confirmation` AND `confirmationDeadlineAt <= now`); verify `not_completed` write; verify patient and doctor notifications dispatched; verify idempotency (already-changed records skipped)
- [x] T031 [P] [US3] Write state machine unit tests for US3 transitions in `test/unit/core/appointment_status_state_machine_test.dart` — `ended_pending_confirmation→not_completed` (24h auto); race condition guard (FR-039: doctor response beats auto-transition)
- [x] T032 [US3] Write integration test for 24h auto-transition in `test/integration/agora_call_happy_path_test.dart` — reach `ended_pending_confirmation`; set `confirmationDeadlineAt` in the past; run scheduler function; verify `not_completed` and patient notification (plan §F5)

### Backend — User Story 3

- [x] T033 [US3] Add `autoCompleteExpiredConfirmations` scheduled Cloud Function in `functions/index.js` — pub/sub triggered, runs every 30 minutes; query: `status == 'ended_pending_confirmation'` AND `confirmationDeadlineAt <= now`; for each: set `status: 'not_completed'`, `notCompletedAt: now`, send patient and doctor notifications per FR-042; idempotent: skip if status has already changed (plan §A8)

### Flutter Doctor — User Story 3

- [x] T034 [US3] Add re-prompt logic in `doctor_appointments_screen.dart` — when doctor opens the app and an appointment is in `endedPendingConfirmation` state (detected via Firestore stream or provider), auto-show the Yes/No confirmation dialog; this handles the "next app open" re-prompt per FR-020 (plan §C2, §C4)
- [x] T035 [US3] Add "Confirmation Required" persistent badge to appointment card in `lib/features/patient/appointments/presentation/widgets/appointment_card_widget.dart` — shown when appointment status is `endedPendingConfirmation` on the doctor's view; tapping it re-shows the confirmation dialog per FR-029 (plan §C4)

**Checkpoint**: Run integration test T032. Auto-transition must fire and produce correct state + notifications.

---

## Phase 6: User Story 4 — Patient Declines Incoming Call (Priority: P3)

**Goal**: Patient explicitly declines the call; doctor receives decline notification; appointment status becomes `declined` (distinct from `missed`); doctor can retry within the appointment time window.

**Independent Test**: Initiate a call, press decline on patient side — doctor sees "declined" notification, appointment shows `declined` status; doctor initiates a new call on the same appointment within the time window.

### Tests for User Story 4

- [x] T036 [P] [US4] Write unit tests for `handleCallDeclined` in `test/unit/core/auth/` — verify `status: 'declined'` write; verify idempotency; verify doctor notification dispatched
- [x] T037 [P] [US4] Write unit tests for `cancelCall` in `test/unit/core/auth/` — verify `status: 'scheduled'` revert; verify `callSessionId`/`callStartedAt`/`callStatus` cleared; verify guard (only valid in `calling`); verify no patient notification (FR-026)
- [x] T038 [P] [US4] Write state machine unit tests for US4 transitions in `test/unit/core/appointment_status_state_machine_test.dart` — `calling→declined`, `declined→calling` (retry within window), `calling→scheduled` (doctor cancel)
- [x] T039 [US4] Write regression tests in `test/integration/agora_call_happy_path_test.dart` — verify existing `completeAppointment` callable still delegates to `confirmCompletion(completed: true)`; verify existing doctor start-call button still works; verify existing appointment booking/scheduling/confirmation flows unaffected (plan §F6)

### Backend — User Story 4

- [x] T040 [US4] Modify `handleCallDeclined` in `functions/index.js` — add `status: 'declined'` write; preserve existing `callStatus: 'declined'`, `declinedAt`, and doctor notification writes; idempotent: skip if status already `declined` (plan §A7)
- [x] T041 [US4] Add `cancelCall` callable in `functions/index.js` — params: `{appointmentId, doctorId}`; guard: only valid when status is `calling`; action: set `status: 'scheduled'`, clear `callSessionId`, `callStartedAt`, `callStatus`; verify `doctorId` matches; no patient notification per FR-026 (plan §A5)

**Checkpoint**: Run regression tests T039. All existing flows must pass without modification.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Notifications wiring, UX label enforcement, logging completeness, and security hardening across all user stories.

- [x] T042 [P] Add patient home screen entry point or bottom nav shortcut to `PatientAppointmentsScreen` in `lib/features/patient/home/presentation/screens/patient_home_screen.dart` — connects `PatientNavigationHelper.openAppointments()` to the patient's primary navigation (completes plan §D3)
- [x] T043 [P] Wire missed-call push notification tap handling to deep-link into `PatientAppointmentsScreen` — update FCM notification handler to route `type: 'missed_call'` to the appointments screen (plan §E1)
- [x] T044 [P] Verify all patient-facing status labels in `AppointmentCardWidget` match FR-036 exactly — all 8 states (including Arabic RTL labels per data-model.md §5); add `assert` or test to catch any label drift
- [x] T045 [P] Add Firestore composite index for auto-transition scheduler query: `status ASC + confirmationDeadlineAt ASC` in `firestore.indexes.json` per contracts/firestore-schema.md §Indexes
- [x] T046 [P] Add Firestore composite index for patient appointments list query: `patientId ASC + status ASC` in `firestore.indexes.json`
- [x] T047 Audit all new Cloud Function writes to confirm `databaseId: 'elajtech'` is specified on every Firestore client init in `functions/index.js` — no default database writes permitted (NFR-005)
- [x] T048 Audit all new Cloud Functions for `europe-west1` region declaration in `functions/index.js` — confirm every new function uses `functions.region('europe-west1')` (NFR-004)
- [x] T049 [P] Add call-log entries for all new lifecycle events in `functions/index.js` — `startAgoraCall` (calling), `endAgoraCall` (ended_pending_confirmation), `confirmAppointmentCompletion` (completed/not_completed), `patientJoinCall` (in_progress), `cancelCall` (cancelled), `autoCompleteExpiredConfirmations` (auto-not_completed) — all logs to `calllogs` collection (FR-025, NFR-002)
- [x] T050 Run `flutter analyze` and resolve all new warnings in modified files; run `npm test` in `functions/` and confirm all Jest tests pass
- [ ] T051 End-to-end smoke test on physical devices (iOS + Android) — execute US1 happy path, US2 missed-call rejoin, and US3 "No" confirmation scenario; confirm UI labels, notification delivery, and status transitions are correct

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1 — **BLOCKS all user stories**
- **Phase 3 (US1)**: Depends on Phase 2 completion — Flutter enum must be live before Cloud Functions changes
- **Phase 4 (US2)**: Depends on Phase 2; independently testable from US1 once Phase 2 is done
- **Phase 5 (US3)**: Depends on Phase 3 (US1) — the auto-transition builds on `endedPendingConfirmation` introduced in US1
- **Phase 6 (US4)**: Depends on Phase 2; can be worked in parallel with US2/US3
- **Phase 7 (Polish)**: Depends on all user stories complete

### User Story Dependencies

- **US1 (P1)**: Must complete before US3 (US3 extends the `ended_pending_confirmation` state introduced in US1's `endAgoraCall` change)
- **US2 (P2)**: Independent from US1 once Phase 2 is done; can be developed in parallel with US1
- **US3 (P2)**: Depends on US1 (`endedPendingConfirmation` state must exist)
- **US4 (P3)**: Independent; can be developed in parallel with all other stories

### Within Each User Story

- Tests (T008–T012, T019–T022, etc.) MUST be written first, confirmed failing, then implementation makes them pass
- Model/enum changes before service changes
- Service changes before UI changes
- Backend callable before Flutter service calling it
- Story complete and checkpointed before moving to next priority

### Critical Deployment Order (from research.md §Decision 6)

1. Deploy Flutter with Phase 2 (T004–T007) first — enum must be live before backend changes
2. Deploy Cloud Functions Phase 3 backend (T013–T015) second
3. Remaining phases can deploy in order without strict cross-dependency

### Parallel Opportunities

Within Phase 3 (US1):
- Tests T008, T009, T010, T011 can all run in parallel (different test files)
- T013, T014, T015 are sequential (same file `functions/index.js`) — commit each separately
- T016, T017, T018 touch different files — can run in parallel

Within Phase 4 (US2):
- T019, T020, T021 can run in parallel
- T025, T026, T027, T028, T029 touch different files — can run in parallel after T024 (backend) is done

---

## Parallel Example: User Story 1

```
# Write tests in parallel first (all different test files):
Task T008: Unit tests for startAgoraCall guard behavior
Task T009: Unit tests for endAgoraCall transition + guards
Task T010: Unit tests for confirmAppointmentCompletion callable
Task T011: State machine unit tests (US1 transitions)
Task T012: Integration test for happy path (write stub, fail first)

# Then implement backend sequentially (same file):
Task T013 → T014 → T015 (functions/index.js changes)

# Then implement Flutter in parallel (different files):
Task T016: AppointmentCompletionService
Task T017: _showCompleteDialog (doctor_appointments_screen.dart)
Task T018: AgoraVideoCallScreen._endCall() auto-trigger
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (enum + model — **CRITICAL**)
3. Complete Phase 3: User Story 1 (happy path)
4. **STOP and VALIDATE**: Run T012 integration test; smoke test on device
5. Deploy Flutter enum first, then Cloud Functions

### Incremental Delivery

1. Phase 2 complete → enum/model deployed to app stores
2. Phase 3 (US1) → happy path works → MVP deployed
3. Phase 4 (US2) → missed call rejoin works → deployed
4. Phase 5 (US3) → auto-timeout + not-completed → deployed
5. Phase 6 (US4) → declined call handling → deployed

### Parallel Team Strategy

With two developers after Phase 2:
- Developer A: Phase 3 (US1) — backend + doctor Flutter
- Developer B: Phase 4 (US2) — patient Flutter + patientJoinCall backend
- Both merge after Phase 3 + Phase 4 complete, then:
  - Phase 5 (US3) + Phase 6 (US4) in parallel

---

## Notes

- **[P]** tasks = different files, no shared dependencies; safe to parallelize
- **[Story]** label maps every task to a user story for traceability
- Constitution §VIII gate: all F-phase tests (T008–T012, T019–T022, T030–T032, T036–T039) are mandatory — the feature may not be considered complete without passing tests
- Commit after each task or logical group; keep Cloud Functions and Flutter changes in separate commits to support the staged deployment order
- `functions/index.js` tasks within a phase must be sequential (same file); coordinate via branch strategy if working in parallel
- All Firestore writes in `functions/index.js` must specify `databaseId: 'elajtech'` — verified in T047
