# Data Model: Patient Appointments Actions and Medical Record Navigation

**Feature**: 008-patient-appt-actions
**Date**: 2026-04-01

---

## 1. No New Firestore Fields Required

This feature is primarily a Flutter UI enhancement. All three user stories read existing fields — no new Firestore document fields, collections, or indexes are introduced by this feature.

---

## 2. Existing Fields Used

### AppointmentModel (`appointments` collection, databaseId: `elajtech`)

| Field | Type | Used By | Purpose |
|-------|------|---------|---------|
| `status` | `String` (→ `AppointmentStatus` enum) | US1, US2, US3 | Gates all three action areas |
| `callSessionActive` | `bool` | US1 | Determines if "Join Meeting" is available for missed appointments |
| `appointmentDate` | `DateTime` | US1, US2 | Combined with `timeSlot` via `fullDateTime` getter |
| `timeSlot` | `String` | US1, US2 | Combined with `appointmentDate` via `fullDateTime` getter |
| `fullDateTime` | computed getter | US1, US2 | `appointmentDate + timeSlot` → used for 10-min join window and 2-hr reschedule cutoff |
| `doctorId` | `String` | US2 | Constrains reschedule slot query to same doctor |
| `id` | `String` | US2, US3 | Passed to reschedule update and medical record navigation |
| `patientId` | `String` | US3 | Identifies the patient for medical record lookup |

---

## 3. New Client-Only State

These are computed values derived from existing data — they are not persisted to Firestore.

### Join Window State (computed in UI layer)

```
isInJoinWindow: bool
  = appointment.fullDateTime != null
    && DateTime.now().isAfter(
         appointment.fullDateTime!.subtract(const Duration(minutes: 10))
       )
    && appointment.status == AppointmentStatus.confirmed
```

### Can Join Meeting (computed in AppointmentCardWidget)

```
canJoinMeeting: bool
  = (isInJoinWindow)
    || (status ∈ {calling, inProgress})
    || (status == missed && callSessionActive == true)
```

### Show Waiting for Call (computed in AppointmentCardWidget)

```
showWaitingForCall: bool
  = (status ∈ {pending, confirmed})
    && !canJoinMeeting
```

### Is Eligible to Reschedule (computed in AppointmentCardWidget)

```
canReschedule: bool
  = (status ∈ {pending, confirmed})
    && appointment.fullDateTime != null
    && appointment.fullDateTime!.isAfter(
         DateTime.now().add(const Duration(hours: 2))
       )
```

### Show Medical Record Icon (computed in AppointmentCardWidget)

```
showMedicalRecordIcon: bool
  = status == AppointmentStatus.completed
```

---

## 4. Analytics Log Events (new entries in `call_logs` collection)

Two new event types added to the existing `call_logs` collection pattern.

### Event: `join_meeting_tapped`

| Field | Type | Value |
|-------|------|-------|
| `eventType` | String | `"join_meeting_tapped"` |
| `appointmentId` | String | appointment identifier |
| `userId` | String | patient user ID |
| `outcome` | String | `"navigated"` / `"session_not_started"` / `"session_expired"` |
| `timestamp` | Timestamp | server timestamp |

### Event: `reschedule_submitted`

| Field | Type | Value |
|-------|------|-------|
| `eventType` | String | `"reschedule_submitted"` |
| `appointmentId` | String | appointment identifier |
| `userId` | String | patient user ID |
| `originalDateTime` | String | ISO 8601 of previous scheduled time |
| `newDateTime` | String | ISO 8601 of requested new time |
| `outcome` | String | `"confirmed"` / `"failed"` / `"conflict"` |
| `timestamp` | Timestamp | server timestamp |

---

## 5. Medical Record Existence Check

Before navigating to `AppointmentMedicalRecordScreen`, a lightweight existence check is performed:

**Query**: Read the medical record document for the appointment from the appropriate EMR subcollection (`andrology_emrs`, `internal_medicine_emrs`, `nutrition_emrs`, `physiotherapy_emrs`) using the `appointmentId` as the lookup key.

**Result handling**:
- Document exists → navigate to `AppointmentMedicalRecordScreen`
- Document does not exist → show SnackBar: "السجل الطبي غير متاح بعد — يرجى المراجعة لاحقاً" / "Medical record not yet available — please check back later"

**Note**: The specific collection to query depends on the doctor's speciality stored in the appointment. If the speciality is unknown or the appointment has no linked speciality, default to showing the "not yet available" message rather than querying all collections.

---

## 6. Reschedule Slot Availability

No new data model. The reschedule flow queries the same doctor-availability data used by `BookAppointmentScreen`:

- **Source**: Existing doctor availability Firestore documents (queried by `doctorId`)
- **Filter**: Exclude slots already booked by other patients on the target date
- **Result**: List of available `timeSlot` strings for the selected doctor on the selected date

The `appointmentsProvider.checkAppointmentConflict()` method is already available for pre-submission conflict validation.
