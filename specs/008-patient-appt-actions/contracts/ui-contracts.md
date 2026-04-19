# UI Contracts: Patient Appointments Actions and Medical Record Navigation

**Feature**: 008-patient-appt-actions
**Date**: 2026-04-01

---

## Contract U1 — AppointmentCardWidget: Call Action Area

**Widget**: `AppointmentCardWidget` (patient view)
**Location**: `lib/features/patient/appointments/presentation/widgets/appointment_card_widget.dart`

### States

| State | Trigger Condition | Displayed Element | Tappable |
|-------|------------------|-------------------|----------|
| Waiting for Call | `status ∈ {pending, confirmed}` AND `!isInJoinWindow` | Label: "في انتظار المكالمة" / "Waiting for Call" | No |
| Join Meeting (active) | `isInJoinWindow && status == confirmed` OR `status ∈ {calling, inProgress}` OR `status == missed && callSessionActive` | Button: "انضم للاجتماع" / "Join Meeting" | Yes |
| Hidden | `status ∈ {completed, notCompleted, cancelled, declined, endedPendingConfirmation}` | Nothing | — |

### "Join Meeting" Tap Outcomes

| Scenario | System Response |
|----------|----------------|
| Session not yet started (doctor hasn't called) | SnackBar: "لم يبدأ الطبيب المكالمة بعد — يرجى الانتظار" |
| Session expired / `callSessionActive == false` | SnackBar: "الاجتماع لم يعد متاحاً" |
| Session active | Navigate to `AgoraVideoCallScreen` |
| Network error | SnackBar: generic connection error message |

### Analytics

- Every "Join Meeting" tap → `CallMonitoringService.logJoinMeetingTap(appointmentId, outcome)`

---

## Contract U2 — AppointmentCardWidget: Reschedule Action

**Widget**: `AppointmentCardWidget` (patient view)

### Visibility Rule

```
show Reschedule button when:
  status ∈ {pending, confirmed}
  AND fullDateTime > DateTime.now() + 2 hours
```

### Reschedule Flow

1. Patient taps "Reschedule" button on card
2. `RescheduleAppointmentSheet` opens as a bottom sheet
3. Sheet shows calendar (today forward, max 90 days) for the same doctor
4. Patient selects date → available time slots for that doctor on that date are loaded
5. Patient selects time slot
6. Conflict check runs via `appointmentsProvider.checkAppointmentConflict()`
7. On success → appointment updated, sheet closes, card refreshes with new time
8. On conflict → inline error in sheet: "هذا الموعد محجوز، اختر وقتاً آخر"
9. On failure → SnackBar error, sheet closes, original appointment unchanged

### Analytics

- On submit (success or failure) → `CallMonitoringService.logRescheduleSubmitted(appointmentId, originalTime, newTime, outcome)`

### Inputs

| Input | Source |
|-------|--------|
| `doctorId` | `appointment.doctorId` |
| `appointmentId` | `appointment.id` |
| `originalDateTime` | `appointment.fullDateTime` |

---

## Contract U3 — AppointmentCardWidget: Medical Record Action

**Widget**: `AppointmentCardWidget` (patient History tab)

### Visibility Rule

```
show "View Medical Record" icon when:
  status == AppointmentStatus.completed
```

### Tap Behavior

| Entry Point | Trigger | Destination |
|------------|---------|-------------|
| Tap completed card (History tab) | `onTap` on card | → `AppointmentMedicalRecordScreen` OR SnackBar fallback |
| Tap "View Medical Record" icon | `onTap` on icon | → same as card tap |

### Navigation Call

```dart
PatientNavigationHelper.openAppointmentMedicalRecord(
  context,
  appointment: appointment,
  patientName: currentPatientName,
)
```

### Fallback (no medical record filed)

Before navigating, check EMR existence for the appointment's speciality collection.

- Record found → navigate
- Record not found → show SnackBar: "السجل الطبي غير متاح بعد — يرجى المراجعة لاحقاً" / "Medical record not yet available — please check back later"

---

## Contract U4 — PatientNavigationHelper: openAppointmentMedicalRecord

**Helper**: `PatientNavigationHelper`
**Location**: `lib/features/patient/navigation/presentation/helpers/patient_navigation_helper.dart`

### New Method

```
openAppointmentMedicalRecord(
  context: BuildContext,
  appointment: AppointmentModel,
  patientName: String,
) → Future<void>
```

**Behavior**: Pushes `MaterialPageRoute` to `AppointmentMedicalRecordScreen(appointment: appointment, patientName: patientName)`.

---

## Contract U5 — CallMonitoringService: New Log Methods

**Service**: `CallMonitoringService`
**Location**: `lib/core/services/call_monitoring_service.dart`

### New Method: logJoinMeetingTap

```
logJoinMeetingTap(
  appointmentId: String,
  userId: String,
  outcome: String,   // "navigated" | "session_not_started" | "session_expired"
) → Future<void>
```

Writes event type `join_meeting_tapped` to `call_logs` collection.

### New Method: logRescheduleSubmitted

```
logRescheduleSubmitted(
  appointmentId: String,
  userId: String,
  originalDateTime: DateTime,
  newDateTime: DateTime,
  outcome: String,   // "confirmed" | "failed" | "conflict"
) → Future<void>
```

Writes event type `reschedule_submitted` to `call_logs` collection.

---

## Contract U6 — RescheduleAppointmentSheet

**New Widget**: `RescheduleAppointmentSheet`
**Location**: `lib/features/patient/appointments/presentation/widgets/reschedule_appointment_sheet.dart`

### Constructor

```
RescheduleAppointmentSheet({
  required AppointmentModel appointment,
  required String patientId,
  required void Function(DateTime newDateTime) onRescheduled,
})
```

### Behavior

- Shows `CalendarDatePicker` constrained to today + 90 days
- On date selection, fetches available time slots for `appointment.doctorId` on selected date
- Shows slot grid (reuses slot display from `BookAppointmentScreen`)
- Validates no conflicts before submitting
- Calls `appointmentsProvider.rescheduleAppointment(id, newDate, newTimeSlot)` on confirm
- Calls `onRescheduled(newDateTime)` on success
- Handles loading, error, and conflict states inline
