# Data Model: Agora Call Workflow Alignment

**Branch**: `007-agora-call-alignment` | **Date**: 2026-03-31

---

## 1. AppointmentStatus Enum Extension

### Current Values (Dart)

```dart
enum AppointmentStatus {
  pending,
  confirmed,
  scheduled,
  completed,
  cancelled,
  missed,
}
```

### New Values to Add

| Dart Enum Case | Firestore String | Meaning |
|----------------|-----------------|---------|
| `calling` | `'calling'` | Doctor has initiated call; VoIP ring active on patient device; patient has not yet answered |
| `inProgress` | `'in_progress'` | Patient has joined the Agora channel; call is live |
| `declined` | `'declined'` | Patient explicitly rejected the incoming call |
| `endedPendingConfirmation` | `'ended_pending_confirmation'` | Call has ended (by any party); awaiting doctor's Yes/No confirmation |
| `notCompleted` | `'not_completed'` | Doctor confirmed the session was not completed; terminal state |

### Updated fromJson Mapping

```dart
static AppointmentStatus _statusFromString(String? value) {
  switch (value) {
    case 'pending':        return AppointmentStatus.pending;
    case 'confirmed':      return AppointmentStatus.confirmed;
    case 'scheduled':      return AppointmentStatus.scheduled;
    case 'completed':      return AppointmentStatus.completed;
    case 'cancelled':      return AppointmentStatus.cancelled;
    case 'missed':         return AppointmentStatus.missed;
    case 'calling':        return AppointmentStatus.calling;
    case 'in_progress':    return AppointmentStatus.inProgress;
    case 'declined':       return AppointmentStatus.declined;
    case 'ended_pending_confirmation': return AppointmentStatus.endedPendingConfirmation;
    case 'not_completed':  return AppointmentStatus.notCompleted;
    default:               return AppointmentStatus.pending;
  }
}
```

### Terminal States (No Further Transitions Permitted)

- `completed`
- `notCompleted`
- `cancelled`

---

## 2. Appointment Document Schema (Firestore)

**Collection**: `appointments` in database `elajtech`

### Existing Fields (unchanged)

| Field | Type | Description |
|-------|------|-------------|
| `appointmentId` | string | Document ID |
| `doctorId` | string | UID of the doctor |
| `patientId` | string | UID of the patient |
| `status` | string | Appointment lifecycle state (primary state field) |
| `callStatus` | string | Legacy call state (retained for backward compatibility during transition) |
| `scheduledAt` | timestamp | Original appointment time |
| `completedAt` | timestamp | Set when status → `completed` |
| `callEndedAt` | timestamp | Set when `endAgoraCall` is called |
| `missedAt` | timestamp | Set when `handleMissedCall` transitions to `missed` |
| `declinedAt` | timestamp | Set when `handleCallDeclined` transitions to `declined` |

### New Fields

| Field | Type | Set By | Description |
|-------|------|--------|-------------|
| `callSessionId` | string | `startAgoraCall` | Channel name used for this call session (e.g., `channel_${appointmentId}_${timestamp}`); used to validate rejoin eligibility |
| `callStartedAt` | timestamp | `startAgoraCall` | Time call was initiated; used to compute token expiry for rejoin |
| `confirmationDeadlineAt` | timestamp | `endAgoraCall` | `callEndedAt + 24 hours`; used by auto-transition scheduler |
| `notCompletedAt` | timestamp | `confirmAppointmentCompletion` (no) or auto-scheduler | Set when status → `not_completed` |
| `callSessionActive` | boolean | `handleMissedCall` | Set to `true` when status → `missed`; cleared when session expires; controls patient "Join Meeting" visibility |

---

## 3. State Transition Map

```
scheduled
  └─ startAgoraCall (doctor) ──────────────────────────────► calling
                                                               │
                         ┌─────────────────────────────────────┤
                         │                                     │
                    patient answers                      ring timeout → missed
                         │                                     │
                         ▼                                     ▼
                    in_progress ◄────────────── missed (patientJoinCall)
                         │
                    call ends (either party)
                         │
                         ▼
               ended_pending_confirmation
                    │           │
              doctor Yes      doctor No
              (or 24h auto)   (explicit)
                    │           │
                    ▼           ▼
               completed    not_completed

calling ──────────────────────────────────────────────────► scheduled
  └─ doctor cancels (cancelCall)

calling ──────────────────────────────────────────────────► declined
  └─ patient declines (handleCallDeclined)

declined / missed ────────────────────────────────────────► calling
  └─ doctor retries (startAgoraCall, within ±30 min window)
```

---

## 4. Call Log Document Schema (Firestore)

**Collection**: `calllogs` in database `elajtech`

No schema changes required. Existing `CallMonitoringService` logs are sufficient. New functions must write to this collection following the existing pattern.

---

## 5. Patient-Facing Status Labels (FR-036)

| `AppointmentStatus` | Patient Label (English) | Patient Label (Arabic) |
|--------------------|------------------------|------------------------|
| `scheduled` | Scheduled | مجدول |
| `calling` | Doctor is calling | الطبيب يتصل |
| `inProgress` | In Meeting | في الاجتماع |
| `missed` | Missed Call | مكالمة فائتة |
| `declined` | Call Declined | تم رفض المكالمة |
| `endedPendingConfirmation` | Awaiting Confirmation | في انتظار التأكيد |
| `completed` | Completed | مكتمل |
| `notCompleted` | Session Incomplete | الجلسة غير مكتملة |

---

## 6. Entity Relationships

```
Appointment (1) ──────── (1) Doctor
Appointment (1) ──────── (1) Patient
Appointment (1) ──────── (0..1) CallLog
AppointmentStatus ──────── Appointment.status (primary field)
```

---

## 7. Validation Rules

| Rule | Field | Constraint |
|------|-------|-----------|
| Terminal state protection | `status` | No write permitted if current status is `completed`, `not_completed`, or `cancelled` (except by admin) |
| Call initiation window | `scheduledAt` | `startAgoraCall` only valid within ±30 minutes of `scheduledAt` |
| Rejoin eligibility | `callStartedAt`, `callSessionId`, `status` | `patientJoinCall` requires: status ∈ {`calling`, `in_progress`, `missed`}, `callSessionId` exists, `callStartedAt + 3600 > now` |
| Doctor authorization | `doctorId` | All callable functions that transition state must verify caller UID == `appointment.doctorId` |
| Patient authorization | `patientId` | `patientJoinCall` must verify caller UID == `appointment.patientId` |
| Confirmation guard | `status` | `confirmAppointmentCompletion` only valid when status == `ended_pending_confirmation` |
| Duplicate call guard | `status` | `startAgoraCall` rejected if status ∈ {`calling`, `in_progress`, `completed`, `not_completed`, `cancelled`} |
