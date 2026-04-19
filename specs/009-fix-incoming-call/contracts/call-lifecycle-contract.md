# Call Lifecycle Contract

## Purpose

Define the cross-system contract for patient incoming-call handling across Flutter, native call presentation, Firebase Cloud Functions, and Firestore logging.

## 1. Callable Function Contract: `startAgoraCall`

### Request

```json
{
  "appointmentId": "string",
  "patientId": "string",
  "doctorId": "string",
  "callerName": "string"
}
```

### Required behavior

- Validate appointment ownership and authorization server-side.
- Read the patient device token from Firestore `databaseId: "elajtech"`.
- Generate `callId`, Agora channel name, and participant join credentials.
- Persist canonical lifecycle state as `ringing` before notification dispatch succeeds or fails.
- Send a platform-appropriate incoming-call payload with enough data to restore the session after cold start.
- Write structured lifecycle logs for call attempt and notification dispatch outcome.

### Success response

```json
{
  "success": true,
  "callId": "string",
  "appointmentId": "string",
  "callStatus": "ringing",
  "channelName": "string",
  "doctorJoinUid": 12345,
  "patientJoinUid": 67890,
  "joinDeadlineSecondsAfterAnswer": 40
}
```

### Error response

```json
{
  "success": false,
  "errorCode": "PATIENT_TOKEN_MISSING|UNAUTHORIZED|INVALID_APPOINTMENT|NOTIFICATION_SEND_FAILED",
  "message": "string",
  "appointmentId": "string"
}
```

## 2. Callable Function Contract: `endAgoraCall`

### Request

```json
{
  "appointmentId": "string",
  "callId": "string",
  "endedBy": "doctor|patient|system_timeout|system_join_timeout",
  "reasonCode": "string"
}
```

### Required behavior

- Validate the caller is authorized to end the consultation.
- Apply an idempotent transition to a terminal backend-owned state.
- Reject invalid transitions from already terminal states unless the operation is a safe no-op.
- Write `end_agora_call_invoked` and `callended` logs.

### Success response

```json
{
  "success": true,
  "appointmentId": "string",
  "callId": "string",
  "callStatus": "ended|missed|declined|join_timeout_failed",
  "endedBy": "doctor|patient|system_timeout|system_join_timeout"
}
```

## 3. Native Incoming Call Payload Contract

### Payload fields

```json
{
  "callId": "string",
  "appointmentId": "string",
  "doctorId": "string",
  "patientId": "string",
  "callerName": "string",
  "channelName": "string",
  "agoraToken": "string",
  "agoraUid": "int-or-string",
  "platformSource": "android_fcm|ios_voip|fallback_notification"
}
```

### Required behavior

- The same keys must be readable from foreground, background, and cold-start restore paths.
- Field naming must remain stable across Cloud Functions payload construction, native incoming-call extras, and Flutter restoration parsing.
- The payload may contain join credentials for runtime restoration but those credentials must never be copied into persistent logs.

## 4. Structured `call_logs` Event Contract

### Required base schema

```json
{
  "callId": "string",
  "appointmentId": "string",
  "actorId": "string",
  "actorRole": "doctor|patient|system|server",
  "eventType": "string",
  "timestamp": "serverTimestamp",
  "platform": "android|ios|server",
  "appState": "foreground|background|terminated|cold_start|unknown",
  "callStatusBefore": "string|null",
  "callStatusAfter": "string|null",
  "reasonCode": "string|null",
  "errorCode": "string|null",
  "elapsedMsFromAnswer": 0,
  "metadata": {}
}
```

### Canonical event types

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

### Logging constraints

- Do not persist raw Agora tokens, FCM tokens, raw APNs/FCM payloads, or unnecessary PHI.
- Use `reasonCode` and `errorCode` instead of long free-text diagnostics wherever possible.
- Keep `metadata` bounded to scalar debugging values such as callback origin, timeout source, or parse path.

## 5. State-Transition Guard Contract

### Allowed backend transitions

- `ringing -> patient_answered`
- `patient_answered -> joining`
- `joining -> in_progress`
- `ringing -> declined`
- `ringing -> missed`
- `joining -> join_timeout_failed`
- `ringing|patient_answered|joining|in_progress -> ended`

### Required client guard behavior

- Client cleanup must not produce terminal state transitions on its own.
- Client may report observed events such as answer accepted, join started, join success, join failure, cleanup invoked, and local end intent.
- Client must treat backend-confirmed end and backend join timeout as authoritative over local assumptions.
