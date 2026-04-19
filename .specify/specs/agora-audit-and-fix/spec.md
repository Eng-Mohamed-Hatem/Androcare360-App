# Feature Specification: Agora Video-Calling Service Audit and Fix

**Feature Branch**: `agora-audit-and-fix`  
**Created**: 2026-03-31  
**Status**: Draft  
**Input**: User description: "Agora video-calling service audit and fix for AndroCare360: perform a comprehensive audit and remediation for the Agora integration across Flutter app, Cloud Functions, and call monitoring. Cover call behavior, session start/end, handling of startAgoraCall/endAgoraCall/completeAppointment errors, and doctor/patient scenarios."

## Problem and Scope

AndroCare360 already contains an Agora-based consultation flow in Flutter and Firebase Cloud Functions, but the current behavior is split across multiple client and server paths. The main risks are:

- consultation lifecycle state is not consistently owned by one server-side source of truth
- patient app cleanup can currently complete an appointment from the client
- incoming-call restoration for cold start is incomplete
- Flutter invokes missed/declined call handlers that are not exported from the active `functions/index.js`
- session end and appointment completion are easy to blur across UI, providers, and Cloud Functions
- monitoring exists, but not every failure/outcome is normalized enough for reliable support and auditing

This feature covers a comprehensive audit and fix for the Agora integration across:

- Flutter call initiation, incoming-call restoration, timeout/retry, and appointment completion UX
- Firebase Cloud Functions for `startAgoraCall`, `endAgoraCall`, `completeAppointment`, and missed/declined handling
- call monitoring and error observability

This feature does not introduce a new telemedicine product flow. It stabilizes and aligns the current one with the constitution, `docs/important-rules.md`, and `docs/instructions-for-flutter-app-development.md`.

## User Scenarios and Testing

### User Story 1 - Doctor Starts a Safe Agora Session (Priority: P1)

As a doctor, I need `startAgoraCall` to start one valid consultation session for my own appointment so that the patient receives a correct incoming call and I join the right Agora channel.

**Why this priority**: If session creation is not authoritative, all other call states become unreliable.

**Independent Test**: Start a video appointment from the doctor flow and verify one session is created, the doctor receives valid Agora credentials, the appointment is updated in `elajtech`, and the patient notification payload contains the matching session data.

**Acceptance Scenarios**:

1. **Given** a doctor is authenticated and owns the appointment, **When** `startAgoraCall` is invoked, **Then** the backend MUST validate ownership from `context.auth.uid`, update the appointment/session state safely, and return doctor Agora credentials.
2. **Given** the appointment does not exist, belongs to another doctor, or the payload doctor ID does not match `context.auth.uid`, **When** `startAgoraCall` is invoked, **Then** the backend MUST reject the request with a typed error and MUST NOT start or mutate the session incorrectly.
3. **Given** session creation succeeds but notification delivery fails, **When** the function completes, **Then** the system MUST preserve a recoverable server-side session state and log the failure without leaking secrets.

---

### User Story 2 - Patient Can Answer, Decline, or Miss the Call Reliably (Priority: P1)

As a patient, I need incoming Agora calls to behave consistently in foreground, background, and cold-start cases so that I can answer, decline, or miss a call without corrupting appointment status.

**Why this priority**: Incoming call handling is the main user-facing risk in the current flow.

**Independent Test**: Receive a doctor-initiated call in foreground, background, and terminated app states, then verify answer, decline, and timeout outcomes separately.

**Acceptance Scenarios**:

1. **Given** the app is opened from an accepted incoming call, **When** pending Agora data exists, **Then** the app MUST navigate the patient into `AgoraVideoCallScreen` using valid appointment and Agora data.
2. **Given** the patient declines the call, **When** the decline event is processed, **Then** the backend MUST record a declined outcome and MUST NOT mark the appointment completed.
3. **Given** the patient does not answer before timeout, **When** timeout occurs, **Then** the backend MUST record a missed outcome and keep the appointment lifecycle separate from clinical completion.

---

### User Story 3 - Session End and Appointment Completion Stay Separate (Priority: P1)

As a doctor or patient, I need ending the media call to remain separate from completing the medical appointment so that disconnects, background cleanup, or lifecycle restoration do not falsely complete a consultation.

**Why this priority**: This is a constitutional rule and directly affects clinical correctness.

**Independent Test**: End a joined call from either side, resume the app, and verify the technical call can end without automatically marking the appointment completed unless the approved doctor completion action is executed.

**Acceptance Scenarios**:

1. **Given** a patient leaves the call or the app resumes after cleanup, **When** local call state is cleared, **Then** the app MUST NOT complete the appointment from the patient client path.
2. **Given** the doctor confirms the consultation is finished, **When** the completion action is chosen, **Then** the app MUST call the server-owned `completeAppointment` path instead of directly saving `status: completed` from the provider.
3. **Given** `endAgoraCall` is triggered, **When** the call ends, **Then** the backend MUST record call end metadata without bypassing appointment-completion authorization.

---

### User Story 4 - Support and Engineering Can Audit Failures End-to-End (Priority: P2)

As an operations or engineering team member, I need normalized monitoring for call start, answer, decline, miss, end, and completion failures so that Agora and telemedicine issues can be diagnosed quickly.

**Why this priority**: Auditability is required for reliability, support, and safe rollout.

**Independent Test**: Force callable failures and call-outcome events, then confirm `call_logs` and function logs contain consistent appointment IDs, actor IDs, event types, and non-sensitive error metadata.

**Acceptance Scenarios**:

1. **Given** a callable function fails, **When** Flutter receives the failure, **Then** a matching non-sensitive monitoring record MUST exist for diagnosis.
2. **Given** a missed or declined call occurs, **When** the outcome is processed, **Then** the backend MUST record a normalized event instead of silently failing because an export is missing.
3. **Given** a successful call and completion flow, **When** the consultation ends, **Then** monitoring MUST allow tracing the flow from start to end to completion.

## Edge Cases

- doctor retries `startAgoraCall` while a previous ringing session still exists
- patient accepts from cold start but Firestore appointment data is stale or partially missing
- `endAgoraCall` is called twice or by both participants near-simultaneously
- `completeAppointment` is invoked for an appointment that is already completed or cancelled
- patient declines after the doctor already ended the call
- missed/declined handlers fail after the local CallKit event already completed
- monitoring write fails while the main call-state update succeeds
- the active backend remains `functions/`, but old legacy folders still exist in the repo and must not become an accidental source of truth

## Requirements

### Functional Requirements

- **FR-001**: The system MUST treat `functions/index.js` as the active backend source of truth for Agora call-state transitions.
- **FR-002**: `startAgoraCall` MUST validate authenticated ownership using `context.auth.uid` and MUST reject mismatched `doctorId` values.
- **FR-003**: `startAgoraCall` MUST continue using Firestore configured for `databaseId: 'elajtech'` and callable region `europe-west1`.
- **FR-004**: The Flutter doctor start-call flow MUST surface typed errors from `startAgoraCall` without navigating to `AgoraVideoCallScreen` on incomplete Agora credentials.
- **FR-005**: The patient incoming-call flow MUST support pending-call restoration and MUST navigate to `AgoraVideoCallScreen` after auth restoration when valid pending call data exists.
- **FR-006**: The Flutter app MUST stop auto-completing appointments from patient-side cleanup or app resume.
- **FR-007**: The doctor completion path MUST use the callable `completeAppointment` server flow rather than direct Firestore writes from `appointmentsProvider` for Agora call completion.
- **FR-008**: `endAgoraCall` MUST require authentication and MUST verify the caller belongs to the appointment before updating call-end metadata.
- **FR-009**: `completeAppointment` MUST require authentication, MUST validate `context.auth.uid == doctorId`, and MUST validate that the appointment belongs to that doctor before completion.
- **FR-010**: The active Cloud Functions backend MUST expose callable handlers for missed-call and declined-call outcomes used by Flutter.
- **FR-011**: Missed and declined call handlers MUST record outcome metadata without marking the appointment completed.
- **FR-012**: Monitoring for `startAgoraCall`, `endAgoraCall`, `completeAppointment`, missed call, and declined call MUST avoid storing raw Agora tokens or unnecessary PHI.
- **FR-013**: Doctor and patient call flows MUST continue to work through the existing Flutter Clean Architecture boundaries, keeping orchestration in services/providers rather than embedding new business logic in widgets where avoidable.
- **FR-014**: Any code touching Firestore snapshots or appointment parsing MUST preserve the repo rules for null-safe snapshot validation and clean error handling.
- **FR-015**: The implementation MUST preserve doctor and patient scenarios for start, answer, decline, timeout/missed, end, and completion across Flutter and Cloud Functions.

### Non-Functional Requirements

- **NFR-001 Reliability**: Call-state mutations MUST be safe under repeated invocations and failed retries.
- **NFR-002 Error Monitoring**: Failures MUST be diagnosable through normalized Cloud Function and call-log records keyed by appointment ID.
- **NFR-003 Performance**: The remediation MUST not introduce extra blocking work in Flutter build methods or heavy UI-thread work during call initialization/restoration.
- **NFR-004 Security**: The remediation MUST follow `docs/important-rules.md`, including authenticated ownership checks, `databaseId: 'elajtech'`, and `europe-west1` callable usage.
- **NFR-005 Architecture Alignment**: Flutter changes MUST align with the project’s Clean Architecture and Riverpod-first patterns, and backend changes MUST stay inside the active `functions/` deployment unit.
- **NFR-006 Rollout Safety**: The remediation MUST be deployable progressively across dev, staging, and production with verification gates.

### Key Entities

- **Appointment**: Existing clinical booking document that anchors doctor, patient, status, and Agora metadata.
- **PendingCallData**: Client-side restoration payload used to resume an accepted incoming call.
- **Call Log Entry**: Monitoring record for start, missed, declined, end, completion, and error events.

## Success Criteria

- **SC-001**: A patient app resume or call cleanup path can no longer complete an appointment without a server-authorized doctor completion action.
- **SC-002**: `startAgoraCall`, `endAgoraCall`, and `completeAppointment` all enforce authenticated ownership against the appointment in the active backend.
- **SC-003**: Accepted pending calls from cold start navigate into `AgoraVideoCallScreen` when valid pending appointment data exists.
- **SC-004**: Missed and declined call events no longer fail due to missing callable exports in the active backend.
- **SC-005**: Targeted automated tests covering the fixed paths pass in Flutter and Cloud Functions.

## Assumptions

- `functions/` is the only active Cloud Functions backend for this feature.
- Existing appointment documents remain the canonical business record for this remediation.
- The current appointment status vocabulary remains in use unless a later spec explicitly broadens it.
- Rollout will verify behavior in non-production environments before production deployment.
