# Cloud Functions Contracts: Agora Call Workflow Alignment

**Branch**: `007-agora-call-alignment` | **Date**: 2026-03-31
**Region**: `europe-west1` (all functions)
**Database**: `elajtech` (all Firestore writes)

---

## Modified Functions

### A1 — `startAgoraCall` (modified)

**Type**: HTTPS Callable
**Caller**: Doctor (authenticated)

**Request**:
```json
{
  "appointmentId": "string",
  "doctorId": "string"
}
```

**Response** (unchanged):
```json
{
  "agoraToken": "string",
  "channelName": "string",
  "uid": "number"
}
```

**New side effects** (additions to existing behavior):
- Sets `appointment.status = 'calling'`
- Sets `appointment.callSessionId = channelName`
- Sets `appointment.callStartedAt = now`

**Guard (new)**:
- Rejects with `FAILED_PRECONDITION` if `appointment.status` ∈ `{calling, in_progress, completed, not_completed, cancelled}`

**Existing behavior preserved**:
- Token generation with 3600s expiry
- VoIP push notification to patient
- `callStatus: 'ringing'` write (legacy compat)
- `CallMonitoringService` logging

---

### A2 — `endAgoraCall` (modified)

**Type**: HTTPS Callable
**Caller**: Doctor or Patient (authenticated)

**Request** (unchanged):
```json
{
  "appointmentId": "string"
}
```

**Response**:
```json
{
  "status": "ended_pending_confirmation"
}
```

**New behavior**:
- Sets `appointment.status = 'ended_pending_confirmation'`
- Sets `appointment.callEndedAt = now`
- Sets `appointment.confirmationDeadlineAt = now + 86400s`

**Guard (new)**:
- If current status ∈ `{completed, not_completed, cancelled}`: no-op; log and return current status (FR-035)
- If current status ∈ `{calling, missed}` (patient never joined): set `status = 'missed'` instead of `ended_pending_confirmation` (FR-015)

**Existing behavior preserved**:
- `callStatus: 'ended'` write (legacy compat)
- `CallMonitoringService` logging

---

### A6 — `handleMissedCall` (modified)

**Type**: HTTPS Callable (system-triggered)
**Caller**: System (ring timeout handler)

**Request** (unchanged):
```json
{
  "appointmentId": "string"
}
```

**New behavior**:
- Sets `appointment.status = 'missed'`
- Sets `appointment.callSessionActive = true`
- Sends FCM push to patient: `{ type: 'missed_call', appointmentId, doctorName }`

**Idempotent**: If status already `missed`, does nothing (FR-033, FR-041)

**Existing behavior preserved**:
- `callStatus: 'missed'` write
- `missedAt` write

---

### A7 — `handleCallDeclined` (modified)

**Type**: HTTPS Callable (system-triggered)
**Caller**: System (patient decline handler)

**Request** (unchanged):
```json
{
  "appointmentId": "string"
}
```

**New behavior**:
- Sets `appointment.status = 'declined'`

**Idempotent**: If status already `declined`, does nothing (FR-041)

**Existing behavior preserved**:
- `callStatus: 'declined'` write
- `declinedAt` write
- Doctor notification

---

## New Functions

### A3 — `confirmAppointmentCompletion` (new)

**Type**: HTTPS Callable
**Caller**: Doctor (authenticated)

**Request**:
```json
{
  "appointmentId": "string",
  "doctorId": "string",
  "completed": "boolean"
}
```

**Response**:
```json
{
  "status": "completed | not_completed",
  "timestamp": "ISO8601 string"
}
```

**Behavior**:
- If `completed === true`: sets `status = 'completed'`, `completedAt = now`
- If `completed === false`: sets `status = 'not_completed'`, `notCompletedAt = now`
- Sends patient notification per FR-042 notification matrix

**Guards**:
- `PERMISSION_DENIED` if caller UID ≠ `appointment.doctorId`
- `FAILED_PRECONDITION` if `appointment.status` ≠ `'ended_pending_confirmation'`
- **Idempotent**: if status already `completed` or `not_completed`, returns current state without error (FR-033)

---

### A4 — `patientJoinCall` (new)

**Type**: HTTPS Callable
**Caller**: Patient (authenticated)

**Request**:
```json
{
  "appointmentId": "string",
  "patientId": "string"
}
```

**Response**:
```json
{
  "agoraToken": "string",
  "channelName": "string",
  "uid": "number"
}
```

**Behavior**:
- Generates new Agora RTC token for the existing `callSessionId` channel
- Sets `appointment.status = 'in_progress'`

**Guards** (all must pass; reject with specific error codes):
- `PERMISSION_DENIED` if caller UID ≠ `appointment.patientId` — message: "You are not authorized to join this meeting" (NFR-003)
- `FAILED_PRECONDITION` if `appointment.status` ∉ `{calling, in_progress, missed}` — message: "This meeting is no longer available"
- `DEADLINE_EXCEEDED` if `callStartedAt + 3600 < now` — message: "This meeting session has expired"
- `NOT_FOUND` if `callSessionId` is null/empty — message: "No active session found for this appointment"

**Idempotent**: if status already `in_progress`, returns new token for same channel without re-setting status

---

### A5 — `cancelCall` (new)

**Type**: HTTPS Callable
**Caller**: Doctor (authenticated)

**Request**:
```json
{
  "appointmentId": "string",
  "doctorId": "string"
}
```

**Response**:
```json
{
  "status": "scheduled"
}
```

**Behavior**:
- Sets `appointment.status = 'scheduled'`
- Clears `callSessionId`, `callStartedAt`, `callStatus` fields

**Guards**:
- `PERMISSION_DENIED` if caller UID ≠ `appointment.doctorId`
- `FAILED_PRECONDITION` if `appointment.status` ≠ `'calling'`

**No patient notification** (FR-026)

---

### A8 — `autoCompleteExpiredConfirmations` (new scheduled)

**Type**: Pub/Sub triggered (Cloud Scheduler)
**Schedule**: Every 30 minutes
**Topic**: `appointment-auto-complete` (new) or extend `appointment-reminders` (TBD during implementation)

**Behavior**:
- Queries: `status == 'ended_pending_confirmation'` AND `confirmationDeadlineAt <= now`
- For each matching appointment:
  - Sets `status = 'not_completed'`, `notCompletedAt = now`
  - Sends patient notification: "Your appointment session was recorded as incomplete"
  - Sends doctor notification: "Appointment confirmation window expired"

**Idempotent**: skips if status has already changed from `ended_pending_confirmation`

---

## Notification Payload Matrix (FR-042)

| Trigger | Recipient | Payload `type` | Message |
|---------|-----------|---------------|---------|
| `handleMissedCall` | Patient | `missed_call` | "Missed call from Dr. [name]" |
| `confirmAppointmentCompletion(true)` | Patient | `appointment_completed` | "Your appointment has been marked completed" |
| `confirmAppointmentCompletion(false)` | Patient | `appointment_not_completed` | "Your appointment session was recorded as incomplete" |
| `autoCompleteExpiredConfirmations` | Patient | `appointment_not_completed` | "Your appointment session was recorded as incomplete" |
| `autoCompleteExpiredConfirmations` | Doctor | `confirmation_expired` | "Appointment confirmation window expired" |

All notification payloads include: `{ type, appointmentId, doctorName }` — no PHI beyond doctor name.

---

## Error Code Reference

| Code | Meaning | Used In |
|------|---------|---------|
| `PERMISSION_DENIED` | Caller is not authorized for this operation | All functions with actor guards |
| `FAILED_PRECONDITION` | Appointment is not in the required state | All transition guards |
| `DEADLINE_EXCEEDED` | Session token has expired | `patientJoinCall` |
| `NOT_FOUND` | Required resource (session, appointment) not found | `patientJoinCall` |
| `ALREADY_EXISTS` | Idempotent: operation already completed | None — idempotent functions return success |
