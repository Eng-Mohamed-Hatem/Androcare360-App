# Implementation Plan: Patient Appointments Actions and Medical Record Navigation

**Branch**: `008-patient-appt-actions` | **Date**: 2026-04-01 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/008-patient-appt-actions/spec.md`

---

## Summary

Enhance `AppointmentCardWidget` and `PatientAppointmentsScreen` with three independently deliverable patient-facing improvements:

1. **Time-aware call action** — display "Waiting for Call" (non-tappable) when outside the 10-minute join window; switch to active "Join Meeting" when inside the window or when a live/missed call session is active.
2. **Self-service reschedule** — show "Reschedule" on eligible (`pending`/`confirmed`, >2 hours away) appointment cards; open a bottom sheet restricted to the same doctor's available slots; confirm immediately with no approval queue.
3. **Medical record navigation** — show a "View Medical Record" icon only on `completed` appointment cards in the History tab; both card tap and icon tap navigate to `AppointmentMedicalRecordScreen`; graceful fallback if no EMR is filed yet.

All three user stories extend existing widgets and services without new screens or Firestore collections. Two new analytics log events extend `CallMonitoringService`.

---

## Technical Context

**Language/Version**: Dart 3 / Flutter 3.x (iOS + Android)
**State Management**: Riverpod — `appointmentsProvider` (existing `AppointmentsNotifier`)
**Storage**: Firestore — databaseId `elajtech` (read-only for US1/US3; update via existing `rescheduleAppointment()` for US2)
**Testing**: `flutter_test` + `mockito` (unit), `flutter_test` widget tests
**Target Platform**: iOS 14+, Android 6+ (mobile only)
**Performance Goals**: Card action state updates within 3 seconds of status change (SC-002); medical record screen loads within 3 seconds (SC-005)
**Constraints**: No new Firestore collections. No new Cloud Function callables. All Firestore reads use `databaseId: 'elajtech'`. Reschedule uses existing `appointmentsProvider.rescheduleAppointment()`.
**Scale/Scope**: Patient appointments list — typically 5–50 appointments per patient.

---

## Constitution Check

### Gate Evaluation (pre-design)

| Principle | Status | Notes |
|-----------|--------|-------|
| §I Clean Architecture | ✅ Pass | Widget changes stay in Presentation; `canJoinMeeting` / `canReschedule` logic in widget or extracted helper, not in raw UI event handler |
| §II Riverpod | ✅ Pass | All state via `appointmentsProvider`; new bottom sheet uses same provider |
| §III Code Quality | ✅ Pass | Extend existing widget with conditional areas; extract `RescheduleAppointmentSheet` as its own widget |
| §V Security | ✅ Pass | Join eligibility enforced server-side by `patientJoinCall` CF; analytics log must not include PHI (no patient name, no medical content) |
| §VI Performance | ✅ Pass | Join window is a pure datetime comparison — no network calls on render; medical record existence check is lazy (on tap only) |
| §VII UX | ✅ Pass | Arabic/English labels defined in spec; loading/error/empty states specified per FR-005/FR-007/FR-017 |
| §VIII Testing | ✅ Pass | Unit tests for action visibility logic; widget tests for all 12 status × 4 action combinations; integration test for reschedule and navigation flows |
| §IX Project Structure | ✅ Pass | Files added under existing `lib/features/patient/appointments/` structure |
| §XII Telemedicine | ✅ Pass | "Join Meeting" tap outcome is logged; session state (expired/not-started) is handled with user-facing messages; no client-side completion logic introduced |

**Constitution result**: All gates pass. No violations.

### §XII Telemedicine — Timeout / Retry / Reconnection Scope Note

This feature is **client-side only** — it reads existing appointment and call-session state but does not create, transition, or control call sessions. Timeout, retry, and reconnection behaviors for the video call itself are owned by feature 007 (`patientJoinCall` Cloud Function + Agora SDK) and are not in scope for 008. Error fallback for the patient-facing UI is covered: expired sessions show "This meeting is no longer available" (FR-005), not-yet-started sessions show "The doctor has not started the call yet" (FR-007), and network errors show a generic connection SnackBar (edge case in spec). Rollout is a single client deploy with no staged migration — changes are additive conditional branches in `AppointmentCardWidget`.

---

## Project Structure

### Documentation (this feature)

```text
specs/008-patient-appt-actions/
├── plan.md              ← this file
├── research.md          ← Phase 0 output ✅
├── data-model.md        ← Phase 1 output ✅
├── quickstart.md        ← Phase 1 output ✅
├── contracts/
│   └── ui-contracts.md  ← Phase 1 output ✅
└── tasks.md             ← Phase 2 output (created by /speckit.tasks)
```

### Source Code (affected files)

```text
lib/
├── features/
│   └── patient/
│       └── appointments/
│           └── presentation/
│               ├── screens/
│               │   └── patient_appointments_screen.dart       [MODIFY — wire card tap for completed]
│               └── widgets/
│                   ├── appointment_card_widget.dart           [MODIFY — core of this feature]
│                   └── reschedule_appointment_sheet.dart      [NEW]
│       └── navigation/
│           └── presentation/
│               └── helpers/
│                   └── patient_navigation_helper.dart         [MODIFY — add openAppointmentMedicalRecord()]
└── core/
    └── services/
        └── call_monitoring_service.dart                       [MODIFY — add logJoinMeetingTap, logRescheduleSubmitted]

test/
├── unit/
│   └── features/
│       └── appointments/
│           └── appointment_card_action_logic_test.dart        [NEW]
├── widget/
│   └── features/
│       └── appointments/
│           ├── appointment_card_widget_test.dart              [NEW or EXTEND]
│           └── reschedule_appointment_sheet_test.dart         [NEW]
└── integration/
    └── patient_appointments_actions_test.dart                 [NEW]
```

**Structure Decision**: Extend existing `lib/features/patient/appointments/` module. No new feature module. `RescheduleAppointmentSheet` is a widget in the same `widgets/` folder. One new integration test file.

---

## Implementation Phases

### Phase A — Time-Aware Call Action (US1) 🎯 MVP

**Files**: `appointment_card_widget.dart`

**A1 — Join window computation**:
- Add computed bool `_isInJoinWindow` to `AppointmentCardWidget`:
  ```
  appointment.fullDateTime != null
  && DateTime.now().isAfter(
       appointment.fullDateTime!.subtract(const Duration(minutes: 10))
     )
  && appointment.status == AppointmentStatus.confirmed
  ```
- The existing `_canJoinMeeting` getter must be updated to incorporate `_isInJoinWindow` as a new trigger condition alongside `calling`, `inProgress`, and `missed + callSessionActive`.

**A2 — "Waiting for Call" display**:
- Add a new branch to the call action area builder:
  ```
  if (showWaitingForCall) → display non-interactive label "في انتظار المكالمة" / "Waiting for Call"
  ```
- `showWaitingForCall = (status ∈ {pending, confirmed}) && !_canJoinMeeting`

**A3 — "Join Meeting" tap error handling**:
- Extend the existing `_joinMeeting()` method:
  - After `patientJoinCall()` attempt, catch `FAILED_PRECONDITION` → show "لم يبدأ الطبيب المكالمة بعد — يرجى الانتظار"
  - After `patientJoinCall()` attempt, catch `NOT_FOUND` or `DEADLINE_EXCEEDED` → show "الاجتماع لم يعد متاحاً"
- Log outcome to `CallMonitoringService.logJoinMeetingTap()`

**A4 — Real-time updates**:
- Verify `appointmentsProvider` already streams Firestore changes. If not, ensure the appointments list listens on a stream snapshot rather than a one-time fetch.

---

### Phase B — Reschedule Action (US2)

**Files**: `appointment_card_widget.dart`, `reschedule_appointment_sheet.dart`

**B1 — Reschedule button visibility**:
- Add `_canReschedule` getter to `AppointmentCardWidget`:
  ```
  (status ∈ {pending, confirmed})
  && appointment.fullDateTime != null
  && appointment.fullDateTime!.isAfter(DateTime.now().add(const Duration(hours: 2)))
  ```
- Render "إعادة جدولة" / "Reschedule" button in the card action row when `_canReschedule`.

**B2 — RescheduleAppointmentSheet widget**:
- New stateful widget: `RescheduleAppointmentSheet`
- Calendar picker (today → today + 90 days)
- On date select: fetch available slots for `appointment.doctorId` on that date (reuse provider logic from `BookAppointmentScreen`)
- Slot grid with loading/empty states
- "Confirm" button → calls `appointmentsProvider.rescheduleAppointment(id, newDate, newTimeSlot)`
- Conflict error shown inline
- On success: calls `onRescheduled(newDateTime)` callback, closes sheet

**B3 — Analytics**:
- In `RescheduleAppointmentSheet` submit handler, call `CallMonitoringService.logRescheduleSubmitted()` before or after the provider call, capturing outcome.

---

### Phase C — Medical Record Navigation (US3)

**Files**: `appointment_card_widget.dart`, `patient_appointments_screen.dart`, `patient_navigation_helper.dart`

**C1 — "View Medical Record" icon**:
- Add icon widget to `AppointmentCardWidget` when `status == completed`
- Icon: `Icons.article_outlined` or equivalent, with tooltip "عرض السجل الطبي" / "View Medical Record"
- Minimum tap target: 48×48 dp

**C2 — Navigation helper**:
- Add `openAppointmentMedicalRecord(context, appointment, patientName)` to `PatientNavigationHelper`
- Pushes `MaterialPageRoute` to `AppointmentMedicalRecordScreen`

**C3 — Tap handler for completed cards**:
- In `patient_appointments_screen.dart` (History tab), wrap completed appointment cards with `GestureDetector` / `InkWell.onTap` → trigger `_openMedicalRecord(context, appointment)`
- `_openMedicalRecord()` checks EMR existence for the appointment's speciality collection → navigates or shows SnackBar fallback

**C4 — Icon tap handler**:
- Icon `onTap` calls same `_openMedicalRecord()` — identical destination to card tap

---

### Phase D — Analytics Extension (US1 + US2)

**Files**: `call_monitoring_service.dart`

**D1 — logJoinMeetingTap**:
- New method matching contract U5
- Writes `eventType: 'join_meeting_tapped'` to `call_logs` (databaseId: `elajtech`)

**D2 — logRescheduleSubmitted**:
- New method matching contract U5
- Writes `eventType: 'reschedule_submitted'` to `call_logs` (databaseId: `elajtech`)
- `originalDateTime` and `newDateTime` stored as ISO 8601 strings (no PHI)

---

### Phase E — Tests

**Unit tests** (`appointment_card_action_logic_test.dart`):
- `_isInJoinWindow` returns true/false for all time boundary cases
- `_canJoinMeeting` returns correct value for all status combinations
- `showWaitingForCall` returns correct value for all statuses
- `_canReschedule` returns correct value for all status + time combinations
- `showMedicalRecordIcon` returns true only for `completed`

**Widget tests** (`appointment_card_widget_test.dart`):
- Full status × action matrix from quickstart Scenario 5 (12 status rows × 4 columns)
- "Waiting for Call" label is not tappable
- "Join Meeting" tap triggers `_joinMeeting()`
- "Reschedule" button opens bottom sheet
- "View Medical Record" icon visible only for `completed`

**Widget tests** (`reschedule_appointment_sheet_test.dart`):
- Sheet opens with calendar
- Slot selection enabled after date picked
- Conflict error shown inline
- Success closes sheet and triggers callback

**Integration tests** (`patient_appointments_actions_test.dart`):
- Waiting-to-join transition: card updates when appointment status changes from `confirmed` to `calling`
- Reschedule flow end-to-end: tap button → pick slot → confirm → appointment updated
- Completed appointment → "View Medical Record" icon → `AppointmentMedicalRecordScreen` opened
- Completed appointment with no EMR → SnackBar shown
- Non-completed appointment → no "View Medical Record" icon, card tap does not navigate to EMR

---

## Critical Deployment Notes

- **No staged deployment required**: This feature is entirely client-side (Flutter only). All Firestore reads use existing fields. No Cloud Function changes.
- **Backward compatibility**: The existing `_canJoinMeeting` getter is being extended, not replaced. No change to the `patientJoinCall` Cloud Function.
- **Regression risk**: Low — changes are additive conditional branches in `AppointmentCardWidget`. Existing "Join Meeting" behavior for `calling`/`inProgress` statuses is preserved.
- **Device time drift**: Documented in research.md §Decision 1. Acceptable for a 10-minute window.
