# Quickstart: Patient Appointments Actions and Medical Record Navigation

**Feature**: 008-patient-appt-actions
**Date**: 2026-04-01

---

## Scenario 1 — Time-Aware Call Action (US1, MVP)

**Goal**: Verify "Waiting for Call" → "Join Meeting" transition on appointment card.

**Setup**:
```dart
// Seed a confirmed appointment scheduled 30 minutes from now
final appointment = AppointmentModel(
  id: 'test_apt_001',
  status: AppointmentStatus.confirmed,
  appointmentDate: DateTime.now(),
  timeSlot: '${DateTime.now().add(Duration(minutes: 30)).hour}:${DateTime.now().add(Duration(minutes: 30)).minute.toString().padLeft(2, '0')}',
  callSessionActive: false,
  ...
);
```

**Test steps**:
1. Render `AppointmentCardWidget` with the appointment → call area shows "في انتظار المكالمة" (non-tappable)
2. Change `appointment.fullDateTime` to `DateTime.now().subtract(Duration(minutes: 1))` → call area shows active "انضم للاجتماع" button
3. Tap "Join Meeting" with `callSessionActive = false` and status `confirmed` → SnackBar "لم يبدأ الطبيب المكالمة بعد"
4. Change status to `calling` → "Join Meeting" shown regardless of time

**Pass criteria**: Step 1 shows waiting label; step 2 shows join button; step 3 shows SnackBar; step 4 shows join button.

---

## Scenario 2 — Reschedule Action (US2)

**Goal**: Verify reschedule button visibility and flow.

**Setup**:
```dart
// Appointment eligible for reschedule
final eligible = AppointmentModel(
  status: AppointmentStatus.confirmed,
  appointmentDate: DateTime.now().add(Duration(hours: 3)),
  timeSlot: '10:00',
  ...
);

// Appointment NOT eligible (too close)
final tooClose = AppointmentModel(
  status: AppointmentStatus.confirmed,
  appointmentDate: DateTime.now().add(Duration(hours: 1)),
  timeSlot: '${DateTime.now().add(Duration(hours: 1)).hour}:00',
  ...
);
```

**Test steps**:
1. Render card with `eligible` → "Reschedule" button visible
2. Render card with `tooClose` → no "Reschedule" button
3. Render card with `status: completed` → no "Reschedule" button
4. Tap "Reschedule" on eligible → `RescheduleAppointmentSheet` opens
5. Select a new slot, confirm → appointment updated, card shows new time

**Pass criteria**: Steps 1–3 match visibility rules; steps 4–5 complete the flow.

---

## Scenario 3 — Medical Record Navigation (US3)

**Goal**: Verify "View Medical Record" icon and navigation for completed appointments.

**Setup**:
```dart
final completed = AppointmentModel(
  status: AppointmentStatus.completed,
  ...
);
final missed = AppointmentModel(
  status: AppointmentStatus.missed,
  ...
);
```

**Test steps**:
1. Render History tab with `completed` appointment → "View Medical Record" icon visible
2. Render History tab with `missed` appointment → no "View Medical Record" icon
3. Tap `completed` card → navigates to `AppointmentMedicalRecordScreen`
4. Tap "View Medical Record" icon → same navigation as step 3
5. Tap `completed` card when no EMR exists → SnackBar "السجل الطبي غير متاح بعد"

**Pass criteria**: Icon shows only for completed; both tap entry points navigate to same screen; fallback SnackBar shown when no EMR.

---

## Scenario 4 — Analytics Logging

**Goal**: Verify join-tap and reschedule events are logged.

**Test steps**:
1. Tap "Join Meeting" (session active) → `call_logs` contains event `join_meeting_tapped` with outcome `"navigated"`
2. Tap "Join Meeting" (session expired) → `call_logs` contains event `join_meeting_tapped` with outcome `"session_expired"`
3. Submit reschedule successfully → `call_logs` contains event `reschedule_submitted` with outcome `"confirmed"`
4. Submit reschedule with conflict → `call_logs` contains event `reschedule_submitted` with outcome `"conflict"`

**Pass criteria**: All 4 events written to `call_logs` with correct `eventType` and `outcome` fields.

---

## Scenario 5 — Status Coverage (All 11 Statuses)

**Goal**: Verify all action areas are hidden/shown correctly across all statuses.

| Status | Waiting for Call | Join Meeting | Reschedule | Medical Record Icon |
|--------|-----------------|--------------|------------|---------------------|
| `pending` (outside window) | ✅ shown | hidden | ✅ shown (if >2h away) | hidden |
| `confirmed` (outside window) | ✅ shown | hidden | ✅ shown (if >2h away) | hidden |
| `confirmed` (inside window) | hidden | ✅ shown | hidden | hidden |
| `calling` | hidden | ✅ shown | hidden | hidden |
| `inProgress` | hidden | ✅ shown | hidden | hidden |
| `missed` (active session) | hidden | ✅ shown | hidden | hidden |
| `missed` (no session) | hidden | hidden | hidden | hidden |
| `declined` | hidden | hidden | hidden | hidden |
| `endedPendingConfirmation` | hidden | hidden | hidden | hidden |
| `notCompleted` | hidden | hidden | hidden | hidden |
| `completed` | hidden | hidden | hidden | ✅ shown |
| `cancelled` | hidden | hidden | hidden | hidden |

**Pass criteria**: Widget tests confirm each row of this table.
