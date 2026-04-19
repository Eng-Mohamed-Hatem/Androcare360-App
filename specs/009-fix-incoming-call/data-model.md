# Data Model: Fix Patient Incoming Call — Not Ringing and Auto-Ended on Answer

## 1. Appointment / Consultation Call

**Purpose**: Canonical backend-owned consultation lifecycle for doctor and patient call coordination.

### Core identifiers

- `appointmentId: string` - Stable consultation identifier.
- `callId: string` - Correlation ID for one call attempt tied to the appointment.
- `doctorId: string`
- `patientId: string`

### Session fields

- `channelName: string`
- `patientAgoraUid: int`
- `doctorAgoraUid: int`
- `patientTokenRef: string or ephemeral token value` - Must never be persisted to diagnostic logs.
- `doctorTokenRef: string or ephemeral token value` - Must never be persisted to diagnostic logs.

### Canonical lifecycle fields

- `callStatus: enum`
  - `scheduled`
  - `ringing`
  - `patient_answered`
  - `joining`
  - `in_progress`
  - `declined`
  - `missed`
  - `join_timeout_failed`
  - `ended`
  - `completed`
- `answeredAt: timestamp?`
- `joinDeadlineAt: timestamp?`
- `startedAt: timestamp?`
- `endedAt: timestamp?`
- `endedBy: enum?` - `doctor`, `patient`, `system_timeout`, `system_join_timeout`
- `endReasonCode: string?`

### Validation rules

- `appointmentId`, `callId`, `doctorId`, `patientId`, and `channelName` are required for any active call attempt.
- `joinDeadlineAt` is required once `callStatus` becomes `patient_answered` or `joining`.
- `startedAt` is required when `callStatus` becomes `in_progress`.
- `endedAt` and `endedBy` are required for terminal states.
- Client lifecycle callbacks must not write terminal states directly without backend validation.

### State transitions

- `scheduled -> ringing` when doctor starts a call.
- `ringing -> patient_answered` when patient acceptance is validated.
- `patient_answered -> joining` when client begins session restoration/join.
- `joining -> in_progress` when Agora join succeeds.
- `ringing -> declined` when patient declines.
- `ringing -> missed` when answer never occurs before the ring timeout.
- `joining -> join_timeout_failed` when the 40-second post-answer join window expires without success.
- `ringing|patient_answered|joining|in_progress -> ended` when doctor or patient explicitly ends the call.
- `ended -> completed` only if broader appointment-completion rules require it; this feature does not allow client cleanup to imply completion.

## 2. Incoming Call Payload

**Purpose**: Durable payload copied into native incoming-call extras so the app can restore the call after background delivery or cold start.

### Fields

- `callId: string`
- `appointmentId: string`
- `doctorId: string`
- `patientId: string`
- `callerName: string`
- `channelName: string`
- `agoraToken: string`
- `agoraUid: int|string`
- `platformSource: enum` - `android_fcm`, `ios_voip`, `fallback_notification`
- `createdAt: timestamp`

### Validation rules

- Payload must include all fields required to join without relying on in-memory singleton state.
- `agoraUid` must support safe coercion from string to int on restoration.
- `agoraToken` is allowed in payload transit only for call restoration and must not be copied into persistent logs.

## 3. Client Call Context

**Purpose**: Transient Flutter-owned UI/process state that supports answer and cleanup behavior but does not decide the canonical consultation outcome.

### Fields

- `isIncomingUiVisible: bool`
- `isAnswering: bool`
- `isConnecting: bool`
- `activeNativeCallId: string?`
- `restoredFromColdStart: bool`
- `appLifecycleState: enum` - `foreground`, `background`, `terminated`, `resumed-transition`
- `cleanupBlockedUntil: timestamp?`

### Validation rules

- `isAnswering` becomes true on accepted answer and remains true until join success, explicit end, or 40-second join timeout.
- Cleanup may run only when `isAnswering` and `isConnecting` are both false and a terminal outcome has been confirmed.
- Client context must be reconstructible from native call extras after cold start.

## 4. Call Log Entry

**Purpose**: Structured, sanitized diagnostic event written to `call_logs` for remote diagnosis and auditability.

### Fields

- `logId: string`
- `callId: string`
- `appointmentId: string`
- `actorId: string`
- `actorRole: enum` - `doctor`, `patient`, `system`, `server`
- `eventType: enum`
  - `callattempt`
  - `notification_dispatched`
  - `incoming_call_received`
  - `answer_accepted`
  - `active_call_restored`
  - `join_started`
  - `join_success`
  - `join_failure`
  - `cleanup_triggered`
  - `end_agora_call_invoked`
  - `callended`
- `platform: enum?` - `android`, `ios`, `server`
- `appState: enum?` - `foreground`, `background`, `terminated`, `cold_start`, `unknown`
- `callStatusBefore: string?`
- `callStatusAfter: string?`
- `reasonCode: string?`
- `errorCode: string?`
- `elapsedMsFromAnswer: int?`
- `timestamp: timestamp`
- `metadata: map<string, scalar>` - sanitized and bounded.

### Validation rules

- Every entry must include `callId`, `appointmentId`, `eventType`, and `timestamp`.
- `join_failure` requires `reasonCode` or `errorCode`.
- `cleanup_triggered` requires a cleanup reason in `metadata`.
- `metadata` must exclude raw tokens, raw notification payloads, and unnecessary PHI.

## 5. Device Token Record

**Purpose**: Current patient push target used to deliver call notifications.

### Fields

- `userId: string`
- `fcmToken: string`
- `updatedAt: timestamp`
- `platform: enum`

### Validation rules

- Reads and writes must target Firestore `databaseId: 'elajtech'`.
- Missing or stale tokens must produce explicit server-side errors and diagnostic logs instead of silent failure.

## Relationships

- One `Appointment / Consultation Call` has one active `Incoming Call Payload` per call attempt.
- One `Appointment / Consultation Call` produces many `Call Log Entry` records.
- One `patientId` maps to one current `Device Token Record` per platform.
