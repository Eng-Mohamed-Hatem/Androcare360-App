# Tasks: Patient Appointments Actions and Medical Record Navigation

**Input**: Design documents from `specs/008-patient-appt-actions/`
**Prerequisites**: plan.md ✅ | spec.md ✅ | research.md ✅ | data-model.md ✅ | contracts/ui-contracts.md ✅ | quickstart.md ✅

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.
**Tests**: Included — explicitly requested in spec (unit, widget, and integration tests).

---

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1–US3)

---

## Phase 1: Setup

**Purpose**: Confirm branch and understand existing code structure before any changes.

- [x] T001 Confirm feature branch `008-patient-appt-actions` is active and `dart analyze` is clean before any modifications
- [x] T002 [P] Read `lib/features/patient/appointments/presentation/widgets/appointment_card_widget.dart` in full to map current `_canJoinMeeting`, status label, and action row structure
- [x] T003 [P] Read `lib/core/services/call_monitoring_service.dart` in full to understand log method signature and Firestore write pattern before extending it

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Extend `CallMonitoringService` with the two new analytics log methods required by both US1 and US2. Must complete before US1 and US2 implementations begin.

**⚠️ CRITICAL**: T004 and T005 are required by US1 (T011) and US2 (T018) respectively.

- [x] T004 Add `logJoinMeetingTap(appointmentId: String, userId: String, outcome: String)` method to `lib/core/services/call_monitoring_service.dart` — writes `eventType: 'join_meeting_tapped'` with outcome field to `call_logs` collection per contracts/ui-contracts.md §U5. Include `///` documentation comments in Arabic and English per constitution §IV.
- [x] T005 [P] Add `logRescheduleSubmitted(appointmentId: String, userId: String, originalDateTime: DateTime, newDateTime: DateTime, outcome: String)` method to `lib/core/services/call_monitoring_service.dart` — writes `eventType: 'reschedule_submitted'` with ISO 8601 timestamps (no PHI) to `call_logs` collection per contracts/ui-contracts.md §U5. Include `///` documentation comments in Arabic and English per constitution §IV.

**Checkpoint**: Run `dart analyze lib/core/services/call_monitoring_service.dart`. No issues before Phase 3 begins.

---

## Phase 3: User Story 1 — Time-Aware Call Action (Priority: P1) 🎯 MVP

**Goal**: The call action area on the patient appointment card shows "Waiting for Call" (non-tappable) before the 10-minute join window, switches to active "Join Meeting" inside the window or when a live session is active, and shows appropriate SnackBar messages on expired/not-started sessions.

**Independent Test**: Render `AppointmentCardWidget` with a `confirmed` appointment 30 minutes away → "Waiting for Call" shown; change `fullDateTime` to 5 minutes ago → "Join Meeting" shown; tap "Join Meeting" with `callSessionActive = false` → SnackBar displayed.

### Tests for User Story 1

- [x] T006 [P] [US1] Write unit tests for `_isInJoinWindow`, `_canJoinMeeting`, and `showWaitingForCall` computed bools covering all 12 appointment statuses and time boundary cases in `test/unit/features/appointments/appointment_card_action_logic_test.dart`
- [x] T007 [P] [US1] Write widget tests for the call action area: "Waiting for Call" not tappable, "Join Meeting" tappable, call action hidden for `completed`/`cancelled`/`notCompleted`/`declined`/`endedPendingConfirmation` in `test/widget/features/appointments/appointment_card_widget_test.dart`

### Implementation for User Story 1

- [x] T008 [US1] Add `_isInJoinWindow` computed bool (checks `appointment.fullDateTime != null && DateTime.now().isAfter(fullDateTime.subtract(10 min)) && status == confirmed`) and update `_canJoinMeeting` to add `_isInJoinWindow` as a third trigger condition alongside `calling`/`inProgress` and `missed+callSessionActive` in `lib/features/patient/appointments/presentation/widgets/appointment_card_widget.dart`
- [x] T009 [US1] Add `showWaitingForCall` computed bool (`status ∈ {pending, confirmed} && !_canJoinMeeting`) and render "في انتظار المكالمة" / "Waiting for Call" non-interactive label in the call action area when true in `lib/features/patient/appointments/presentation/widgets/appointment_card_widget.dart`
- [x] T010 [US1] Extend the existing `_joinMeeting()` method to show SnackBar "لم يبدأ الطبيب المكالمة بعد — يرجى الانتظار" on `FAILED_PRECONDITION` error and "الاجتماع لم يعد متاحاً" on `NOT_FOUND`/`DEADLINE_EXCEEDED` per contracts/ui-contracts.md §U1 in `lib/features/patient/appointments/presentation/widgets/appointment_card_widget.dart`
- [x] T011 [US1] Wire `CallMonitoringService.logJoinMeetingTap(appointmentId, userId, outcome)` call in `_joinMeeting()` after determining the outcome (`"navigated"` / `"session_not_started"` / `"session_expired"`) in `lib/features/patient/appointments/presentation/widgets/appointment_card_widget.dart`

**Checkpoint**: Run T006 and T007 tests — all must pass. Render card on emulator: confirm "Waiting for Call" → "Join Meeting" transition at the 10-minute mark.

---

## Phase 4: User Story 2 — Reschedule Action for Eligible Appointments (Priority: P2)

**Goal**: A "Reschedule" button appears on `pending`/`confirmed` appointment cards more than 2 hours away. Tapping opens `RescheduleAppointmentSheet` — a bottom sheet restricted to the same doctor's available slots. Confirming a slot updates the appointment immediately.

**Independent Test**: Render card with `confirmed` appointment 3 hours away → "Reschedule" button visible; render card with appointment 1 hour away → button hidden; complete a reschedule flow → appointment card shows updated time.

### Tests for User Story 2

- [x] T012 [P] [US2] Write unit tests for `_canReschedule` computed bool — all status values and time boundary cases (exactly 2 hours, 1 minute over, 1 minute under) in `test/unit/features/appointments/appointment_card_action_logic_test.dart`
- [x] T013 [P] [US2] Write widget tests for reschedule button visibility: shown for `pending`/`confirmed` >2h away, hidden for all other statuses and when <2h away in `test/widget/features/appointments/appointment_card_widget_test.dart`
- [x] T014 [P] [US2] Write widget tests for `RescheduleAppointmentSheet`: calendar shown, slot grid loads after date selected, conflict error shown inline, success closes sheet and calls `onRescheduled` in `test/widget/features/appointments/reschedule_appointment_sheet_test.dart`

### Implementation for User Story 2

- [x] T015 [US2] Add `_canReschedule` computed bool (`status ∈ {pending, confirmed} && fullDateTime != null && fullDateTime.isAfter(now + 2h)`) and render "إعادة جدولة" / "Reschedule" button in the card action row when true in `lib/features/patient/appointments/presentation/widgets/appointment_card_widget.dart`
- [x] T016 [US2] Create `RescheduleAppointmentSheet` stateful widget with: `CalendarDatePicker` (today + 90 days), available-slot grid for `appointment.doctorId` on selected date (reuse slot-fetch provider from `BookAppointmentScreen`), conflict validation via `appointmentsProvider.checkAppointmentConflict()`, confirm button, loading/error/empty inline states, and `onRescheduled(DateTime)` success callback in `lib/features/patient/appointments/presentation/widgets/reschedule_appointment_sheet.dart`
- [x] T017 [US2] Wire "Reschedule" button tap in `AppointmentCardWidget` to open `RescheduleAppointmentSheet` via `showModalBottomSheet` and handle `onRescheduled` callback by refreshing appointment state in `lib/features/patient/appointments/presentation/widgets/appointment_card_widget.dart`
- [x] T018 [US2] Wire `CallMonitoringService.logRescheduleSubmitted()` in the `RescheduleAppointmentSheet` confirm handler — log before returning, capture `"confirmed"` / `"failed"` / `"conflict"` outcome in `lib/features/patient/appointments/presentation/widgets/reschedule_appointment_sheet.dart`

**Checkpoint**: Run T012–T014 tests — all must pass. Complete a full reschedule flow on emulator: tap button → pick slot → confirm → appointment card shows new time.

---

## Phase 5: User Story 3 — Medical Record Navigation from Completed Appointments (Priority: P3)

**Goal**: `completed` appointment cards in the History tab display a "View Medical Record" icon. Both card tap and icon tap navigate to `AppointmentMedicalRecordScreen`. If no EMR is filed, a SnackBar is shown instead of navigating.

**Independent Test**: Render History tab with one `completed` and one `missed` appointment → icon visible only on completed. Tap completed card → `AppointmentMedicalRecordScreen` pushed. Tap completed card with no EMR → SnackBar shown.

### Tests for User Story 3

- [x] T019 [P] [US3] Write unit tests for `showMedicalRecordIcon` bool — true only for `completed`, false for all other 11 statuses in `test/unit/features/appointments/appointment_card_action_logic_test.dart`
- [x] T020 [P] [US3] Write widget tests for "View Medical Record" icon: visible only for `completed`, meets 48dp minimum tap target, hidden for all other statuses in `test/widget/features/appointments/appointment_card_widget_test.dart`
- [x] T021 [P] [US3] Write integration tests for: completed card navigates to `AppointmentMedicalRecordScreen`, icon tap navigates to same screen, completed card with no EMR shows SnackBar, non-completed card does not navigate to EMR in `test/integration/patient_appointments_actions_test.dart`

### Implementation for User Story 3

- [x] T022 [US3] Add `static Future<void> openAppointmentMedicalRecord(BuildContext context, {required AppointmentModel appointment, required String patientName})` method to `lib/features/patient/navigation/presentation/helpers/patient_navigation_helper.dart` — pushes `MaterialPageRoute` to `AppointmentMedicalRecordScreen(appointment: appointment, patientName: patientName)`. Include `///` documentation comments in Arabic and English per constitution §IV.
- [x] T023 [US3] Add `showMedicalRecordIcon` computed bool (`status == AppointmentStatus.completed`) and render "View Medical Record" icon (`Icons.article_outlined`) with tooltip "عرض السجل الطبي" / "View Medical Record" and 48dp minimum tap target in `lib/features/patient/appointments/presentation/widgets/appointment_card_widget.dart`
- [x] T024 [US3] Add `_openMedicalRecord(BuildContext context, AppointmentModel appointment)` private method in `lib/features/patient/appointments/presentation/screens/patient_appointments_screen.dart` that: (1) checks EMR existence for the appointment's speciality collection, (2) calls `PatientNavigationHelper.openAppointmentMedicalRecord()` on found, (3) shows SnackBar "السجل الطبي غير متاح بعد — يرجى المراجعة لاحقاً" on not-found; wire this method to both the completed card's `onTap` and the icon's `onTap`

**Checkpoint**: Run T019–T021 tests — all must pass. Open History tab on emulator: confirm icon visible on completed, tap navigates correctly, SnackBar shows when EMR absent.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Full status-coverage tests, RTL/accessibility verification, regression checks, and final analysis pass.

- [x] T025 [P] Write full 12-status × 4-action coverage widget test table from quickstart.md Scenario 5 — every row must pass in `test/widget/features/appointments/appointment_card_widget_test.dart`
- [x] T026 [P] Write integration test for waiting-to-join transition (Scenario 1), reschedule end-to-end (Scenario 2), analytics logging (Scenario 4) in `test/integration/patient_appointments_actions_test.dart`
- [x] T027 Verify all Arabic labels in `appointment_card_widget.dart` and `reschedule_appointment_sheet.dart` match spec strings exactly (FR-001/FR-005/FR-007/FR-011/FR-017) and RTL direction is applied correctly per FR-020
- [x] T028 Verify all interactive elements (join button, reschedule button, medical record icon, sheet confirm button) meet 48dp minimum tap target and carry `Semantics` / `tooltip` labels for screen readers per FR-021
- [x] T029 Run `dart analyze` on all modified and new files — zero warnings or errors before merging
- [x] T030 Run full test suite (`flutter test`) and confirm all existing tests continue to pass (regression check for SC-007)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately; T002 and T003 can run in parallel
- **Phase 2 (Foundational)**: Depends on Phase 1 — T004 blocks T011; T005 blocks T018
- **Phase 3 (US1)**: Depends on Phase 2 (T004 must be done before T011); T006 and T007 can be written in parallel before T008–T011
- **Phase 4 (US2)**: Depends on Phase 2 (T005 must be done before T018); independently executable from US1
- **Phase 5 (US3)**: Depends only on Phase 1; no dependency on US1 or US2
- **Phase 6 (Polish)**: Depends on all user stories complete

### User Story Dependencies

- **US1 (P1)**: Depends on Phase 2 (T004) — no dependency on US2 or US3
- **US2 (P2)**: Depends on Phase 2 (T005) — no dependency on US1 or US3; can be worked in parallel with US1
- **US3 (P3)**: Depends only on Phase 1 — fully independent from US1 and US2; can start as soon as Phase 1 is done

### Within Each User Story

- Tests (T006/T007, T012/T013/T014, T019/T020/T021) MUST be written first and confirmed failing before implementation
- Foundational Phase 2 before US1/US2 implementations
- `appointment_card_widget.dart` is shared across US1, US2, and US3 — commits should be sequential within this file

### Critical File Sequencing

`appointment_card_widget.dart` is touched by all three stories. Recommended commit order within the file:
1. T008–T011 (US1 changes) — commit
2. T015, T017 (US2 changes) — commit
3. T023 (US3 icon) — commit

---

## Parallel Opportunities

Within Phase 3 (US1):
- T006 (unit tests) and T007 (widget tests) can be written in parallel — different files
- T008, T009, T010, T011 are sequential — all modify `appointment_card_widget.dart`

Within Phase 4 (US2):
- T012, T013, T014 (tests) can be written in parallel — different files
- T016 (`RescheduleAppointmentSheet`) can be written in parallel with T015 (button in card)
- T017 and T018 follow T015 and T016

Within Phase 5 (US3):
- T019, T020, T021 (tests) can all be written in parallel — different files
- T022 (`PatientNavigationHelper`) can be written in parallel with T023 (icon in card)
- T024 (screen wiring) follows T022 and T023

Phase 3 + Phase 4 + Phase 5 can all proceed in parallel once Phase 2 is done, if multiple developers are available.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T003)
2. Complete Phase 2: Foundational — T004 only (T005 can wait for US2)
3. Write US1 tests T006–T007 — confirm they fail
4. Complete Phase 3: T008 → T009 → T010 → T011
5. **STOP and VALIDATE**: Run T006–T007 tests; smoke test on device — "Waiting for Call" / "Join Meeting" transition confirmed

### Incremental Delivery

1. MVP: Phase 1 + Phase 2 (T004) + Phase 3 → time-aware call action deployed
2. Add US2: Phase 2 (T005) + Phase 4 → reschedule action deployed
3. Add US3: Phase 5 → medical record navigation deployed
4. Phase 6 Polish → full test suite green, RTL + a11y verified

### Parallel Team Strategy

With two developers after Phase 2:
- Developer A: Phase 3 (US1) — time-aware call action in `appointment_card_widget.dart`
- Developer B: Phase 5 (US3) — navigation helper + medical record icon (different file targets)
- Both merge; then Developer A picks up Phase 4 (US2 — `RescheduleAppointmentSheet`)

---

## Notes

- **[P]** tasks = different files, no shared dependencies; safe to parallelize
- `appointment_card_widget.dart` is the highest-change file — coordinate commits across US1 (T008–T011), US2 (T015, T017), and US3 (T023) to avoid merge conflicts
- All Firestore writes in `call_monitoring_service.dart` must use `databaseId: 'elajtech'` — existing pattern already enforces this
- No Cloud Function changes; no new Firestore collections
- The spec was tested via `/speckit.clarify` — all clarifications are recorded in `spec.md §Clarifications`
- Commit after each task or logical group; run `dart analyze` after each commit
