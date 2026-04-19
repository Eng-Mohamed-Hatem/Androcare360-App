# Firestore Schema Contract: Agora Call Workflow Alignment

**Branch**: `007-agora-call-alignment` | **Date**: 2026-03-31
**Database**: `elajtech` (non-default; all reads/writes must specify this database ID)

---

## Collection: `appointments`

### Document Structure

```
appointments/{appointmentId}
├── appointmentId        : string       (document ID)
├── doctorId             : string       (doctor UID)
├── patientId            : string       (patient UID)
├── scheduledAt          : timestamp    (original appointment time)
├── status               : string       ← PRIMARY STATE FIELD (see enum below)
│
│   ── Legacy call fields (retained for backward compat) ──
├── callStatus           : string?      ('ringing' | 'ended' | 'missed' | 'declined')
│
│   ── New call lifecycle fields ──
├── callSessionId        : string?      (Agora channel name; set on startAgoraCall)
├── callStartedAt        : timestamp?   (time startAgoraCall was called)
├── callEndedAt          : timestamp?   (time endAgoraCall was called)
├── confirmationDeadlineAt: timestamp?  (callEndedAt + 24h; for auto-transition scheduler)
├── callSessionActive    : boolean?     (true when missed + session still valid for rejoin)
│
│   ── Completion fields ──
├── completedAt          : timestamp?   (set when status → 'completed')
├── notCompletedAt       : timestamp?   (set when status → 'not_completed')
│
│   ── Existing missed/declined fields ──
├── missedAt             : timestamp?   (set by handleMissedCall)
└── declinedAt           : timestamp?   (set by handleCallDeclined)
```

### `status` Field Values

| Value | Description | Terminal? |
|-------|-------------|-----------|
| `'pending'` | Awaiting confirmation | No |
| `'confirmed'` | Appointment confirmed | No |
| `'scheduled'` | Appointment scheduled and ready | No |
| `'calling'` | Doctor initiated call; patient's device ringing | No |
| `'in_progress'` | Patient joined; call is live | No |
| `'missed'` | Patient did not answer (ring timeout) | No* |
| `'declined'` | Patient explicitly declined | No* |
| `'ended_pending_confirmation'` | Call ended; awaiting doctor Yes/No | No |
| `'completed'` | Doctor confirmed session completed | **Yes** |
| `'not_completed'` | Doctor confirmed or auto-timeout: not completed | **Yes** |
| `'cancelled'` | Appointment cancelled | **Yes** |

*`missed` and `declined` allow re-initiation within ±30 min window (FR-002)

---

## Collection: `calllogs`

**No schema changes.** New functions follow the existing `CallMonitoringService` write pattern.

---

## Firestore Security Rules (Requirements)

The following rules must be enforced (implementation detail left to implementation phase):

1. **Terminal state protection**: Documents where `status` ∈ `{'completed', 'not_completed', 'cancelled'}` must not be writable by client SDKs. Only Cloud Functions (admin SDK) may update these documents.

2. **Actor-scoped reads**: Appointment documents are readable only by the assigned `doctorId` and `patientId`.

3. **No client-side status writes**: The `status` field must not be directly writable by mobile clients. All status transitions must go through Cloud Functions.

4. **`callSessionId` immutability after set**: Once `callSessionId` is set, it must not be overwritten by client writes (only Cloud Functions may update it on retry).

---

## Indexes Required

| Collection | Fields | Type | Purpose |
|------------|--------|------|---------|
| `appointments` | `status` ASC, `confirmationDeadlineAt` ASC | Composite | Auto-transition scheduler query |
| `appointments` | `patientId` ASC, `status` ASC | Composite | Patient appointment list screen |
| `appointments` | `doctorId` ASC, `status` ASC | Composite | Doctor appointment list (existing; verify) |

---

## Migration Notes

### Backward Compatibility

- Existing appointments in `pending`, `confirmed`, `scheduled`, `completed`, `cancelled`, `missed` states are unaffected.
- New fields (`callSessionId`, `callStartedAt`, `confirmationDeadlineAt`, `callSessionActive`, `notCompletedAt`) are optional — absent on existing documents.
- `callStatus` legacy field is preserved alongside new `status` values during transition.
- The Flutter `fromJson` fallback to `AppointmentStatus.pending` for unknown strings means old app versions receiving `calling` or `ended_pending_confirmation` will display the appointment as `pending` — acceptable degradation during rollout.

### Rollout Order

1. Deploy Flutter with new `AppointmentStatus` enum values (Phase B) **first**
2. Deploy Cloud Functions changes (Phase A) **after** Flutter is live
3. Deploy patient appointments screen (Phase D) can follow independently
4. The 24h scheduler (Phase A8) can be deployed at any time — it only acts on `ended_pending_confirmation` documents which won't exist until Phase A2 is live
