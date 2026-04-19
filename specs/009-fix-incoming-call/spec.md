# Feature Specification: Fix Patient Incoming Call — Not Ringing and Auto-Ended on Answer

**Feature Branch**: `009-fix-incoming-call`
**Created**: 2026-04-01
**Status**: Draft
**Input**: User description: "fix-patient-incoming-call-not-ringing-and-auto-ended-on-answer"

---

## Problem Statement

AndroCare360 supports doctor-to-patient video consultations. When the doctor taps "Start Call" from an appointment, the expected flow is:

1. The patient's device rings using a native incoming call screen (displayed above the lock screen).
2. The patient taps **Answer**.
3. The app opens (or restores), shows a brief connecting state while Agora join is in progress, and then places the patient into the live video session with the doctor.
4. The call continues until either party intentionally ends it.

Two bugs break this flow:

**Bug A — Patient device does not ring:** The patient's phone either does not display a native call screen at all, or the ringing UI is not fully presented. The patient misses the call silently.

**Bug B — Immediate "call ended" state on answer:** When the patient does tap Answer (possibly after seeing a notification rather than the full native call screen), the app opens but immediately shows a "call ended" message instead of the active video session.

Both bugs together make doctor-to-patient video calls non-functional for patients.

## Clarifications

### Session 2026-04-01

- Q: What is the expected incoming call UI behavior by platform and app state, and what is the fallback if native incoming UI cannot be shown? → A: Require native incoming call UI with ringtone on Android and iOS in foreground, background, and terminated states; if native UI cannot be shown, show the highest-priority in-app or system incoming-call notification and keep the call answerable.
- Q: After Answer, should the patient go directly to the live call or see an intermediate state first? → A: Show a brief connecting state after Answer, then transition to the live call once Agora join succeeds.
- Q: What is the join timeout and what exact user messages should distinguish local join failure from a truly ended call? → A: Join fails after 40 seconds; show "Unable to connect to the call. Please try again." for local join failure and "The call has ended." when the call truly ended.
- Q: What are the cleanup guard rules after Answer? → A: Block cleanup from Answer until join succeeds or a 40-second join timeout or explicit end occurs; treat the call as ended only on explicit end or timeout, and do not run cleanup before the join outcome is known.
- Q: How long should the doctor wait for the patient to join, and should doctor-side end/timeout use a different message from local join failure? → A: The doctor waits 40 seconds for the patient to join; doctor-side end or unanswered timeout is treated as a true ended call and shows "The call has ended.".

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Patient Receives and Answers Call in Background (Priority: P1)

A patient has AndroCare360 running in the background (screen off or using another app). The doctor starts the video call. The patient sees a native incoming call screen, taps Answer, sees a brief connecting state, and is then placed into the live video session without any "call ended" message.

**Why this priority**: This is the most common real-world scenario. It directly blocks all doctor-to-patient consultations and is the core failure path for both bugs.

**Independent Test**: Doctor starts call on one device. Tester verifies native incoming call UI appears on patient device within 5 seconds. Tester taps Answer. Tester verifies patient device joins the active Agora session (doctor is visible/audible).

**Acceptance Scenarios**:

1. **Given** the patient app is in the background and the doctor starts a call, **When** the FCM push is delivered, **Then** the patient device displays a native incoming call screen within 5 seconds.
2. **Given** the native incoming call screen is shown, **When** the patient taps Answer, **Then** the patient app opens into a brief connecting state and transitions to the active video session when join succeeds.
3. **Given** the patient has navigated to the video session, **When** the video session loads, **Then** the doctor is visible and both parties can communicate without interruption.
4. **Given** the patient has just answered the call, **When** the app resumes from background to foreground, **Then** no call cleanup or "call ended" state is triggered.

---

### User Story 2 — Patient Receives and Answers Call from Terminated App State (Priority: P1)

The patient's app is fully closed (force-quit or never opened). The doctor starts a call. A native incoming call screen appears on the patient's device via the system. The patient taps Answer, the app cold-starts, shows a brief connecting state, and the patient joins the active video session.

**Why this priority**: Cold-start is a critical edge case specifically called out in the bug description. It requires separate handling of call data restoration, and it is one of the most likely root causes of the "immediate call ended" symptom.

**Independent Test**: Force-quit patient app. Doctor starts call. Tester verifies native call screen appears. Tester taps Answer. Tester verifies app launches fresh, shows a brief connecting state, and transitions to the active video session with call data intact.

**Acceptance Scenarios**:

1. **Given** the patient app is terminated and the doctor starts a call, **When** the push notification is delivered, **Then** the system native call screen appears without requiring the app to be open first.
2. **Given** the native call screen is showing and the patient taps Answer, **When** the app cold-starts, **Then** all call credentials (`appointmentId`, `channelName`, `agoraToken`, `agoraUid`, and caller name) are correctly restored from the incoming call data.
3. **Given** the app has cold-started after answer, **When** the connecting state finishes and the video screen initializes, **Then** the patient joins the correct session and the doctor remains connected.
4. **Given** the app cold-starts after answer, **When** the app lifecycle "resumed" event fires during startup, **Then** no premature cleanup logic runs that would clear the call session.

---

### User Story 3 — Patient Receives Call in Foreground (Priority: P2)

The patient has AndroCare360 actively open on screen. The doctor starts a call. A native or in-app incoming call screen appears. The patient taps Answer, sees a brief connecting state, and joins the session.

**Why this priority**: Less risky than the other states because the app is active, but still required for full coverage.

**Independent Test**: Patient is on app home screen. Doctor starts call. Tester verifies incoming call UI appears. Tester taps Answer. Tester verifies a brief connecting state appears before the video session opens.

**Acceptance Scenarios**:

1. **Given** the patient app is in the foreground when the doctor starts a call, **When** the push is received, **Then** the incoming call screen is presented over the current screen.
2. **Given** the incoming call screen is visible, **When** the patient taps Answer, **Then** the patient enters a brief connecting state and then navigates to the active video session without showing any intermediate "call ended" state.

---

### User Story 4 — Call Lifecycle Logging is Complete for Diagnosis (Priority: P2)

Every stage of a call attempt — initiation, ring delivery, answer, join, error, cleanup, and end — is recorded in `call_logs` with sufficient detail for a developer to diagnose any future failure without accessing the device.

**Why this priority**: Without complete logs, the root cause of regressions cannot be identified. This is a diagnostic safety net for both bugs.

**Independent Test**: Run a complete call scenario. Query `call_logs` in Firestore. Verify the applicable canonical events exist in order: `callattempt`, `notification_dispatched`, `incoming_call_received`, `answer_accepted`, `active_call_restored` when a restore path is used, `join_started`, `join_success|join_failure`, `cleanup_triggered` when cleanup runs, `end_agora_call_invoked` when an end action is invoked, and `callended`.

**Acceptance Scenarios**:

1. **Given** the doctor starts a call, **When** the cloud function executes, **Then** a `callattempt` log entry is written with appointment ID, doctor ID, and timestamp.
2. **Given** the patient's device receives the push, **When** the incoming call screen is displayed, **Then** an `incoming_call_received` log entry is written on the patient side.
3. **Given** the patient taps Answer, **When** the answer event is processed, **Then** an `answer_accepted` log entry is written.
4. **Given** the patient app begins joining the video session, **When** the join starts, **Then** a `join_started` log entry is written; on success a `join_success` entry is written; on failure a `join_failure` entry with error detail is written.
5. **Given** any cleanup logic runs, **When** it executes, **Then** a `cleanup_triggered` log entry is written with the reason (e.g., "lifecycle resumed", "user ended call", "timeout").
6. **Given** the call ends, **When** the end event fires, **Then** a `callended` log entry is written with the initiating party and timestamp.

---

### Edge Cases

- If the patient's FCM token is missing or stale, the server MUST fail the notification dispatch explicitly, write a diagnostic log entry, and MUST NOT silently mark the call as successfully delivered.
- If the doctor's session is still initializing when the patient answers, the patient MUST remain in the connecting state until join succeeds, the doctor-side session ends, or the 40-second join timeout expires.
- If the app lifecycle `resumed` event fires during the answer transition before the video session finishes loading, the system MUST keep the call in a connecting state and MUST NOT run cleanup.
- If Agora join has not succeeded within 40 seconds after Answer, the attempt is treated as a local join failure and the patient sees "Unable to connect to the call. Please try again.".
- If the doctor ends the call or the ringing window expires before the patient joins, the patient sees "The call has ended." rather than a connection-failure message.
- Cleanup MUST remain blocked from the moment Answer is tapped until Agora join succeeds or a 40-second join timeout or explicit end event is received.
- A call remains in a connecting state, not an ended state, while Answer has been accepted and no explicit end event or 40-second join timeout has occurred.
- If the patient declines the call, the call status MUST transition to `declined` and the system MUST record the decline outcome in `call_logs`.
- If the call rings for 60 seconds with no answer, the call status MUST transition to `missed` and the system MUST record the timeout outcome in `call_logs`.
- If notification permission is denied or revoked, the system MUST use the highest-priority platform-allowed fallback and MUST log that native incoming-call presentation was unavailable.
- If two rapid call attempts target the same patient, the system MUST ignore or reject duplicate call attempts for the same active `callId` and MUST NOT present duplicate active sessions.
- If the appointment time window has passed after a call is already in progress, the active consultation MAY continue until explicitly ended; the expired scheduling window alone MUST NOT terminate an in-progress call.

---

## Requirements *(mandatory)*

### Functional Requirements

**Notification Delivery**

- **FR-001**: When the doctor starts a call, the system MUST dispatch a high-priority push notification to the patient's registered device token within 3 seconds of call initiation.
- **FR-002**: The push notification payload MUST include all data required to present the incoming call screen and join the video session: `appointmentId`, `channelName`, `agoraToken`, `agoraUid`, and `callerName`.
- **FR-003**: The system MUST read the patient's device token from the correct data store (Firestore, `elajtech` database) at the time of dispatch; a stale or missing token MUST result in a clear error logged server-side, not a silent failure.
- **FR-004**: The Android configuration MUST specify a notification channel that is designated for incoming calls, with maximum priority and lock-screen visibility enabled.
- **FR-005**: The iOS configuration MUST use VoIP-capable push settings, entitlements, and server payload headers that allow CallKit to present the incoming call screen without the app being open.

**Incoming Call Presentation**

- **FR-006**: When the patient's device receives an incoming call push, the system MUST trigger the native incoming call UI (full-screen lock screen overlay on Android; CallKit on iOS) with ringtone regardless of whether the app is in the foreground, background, or terminated state.
- **FR-007**: The incoming call UI MUST display the caller's name and a visual indicator of a video call.
- **FR-008**: All call credentials (`appointmentId`, `channelName`, `agoraToken`, `agoraUid`, and `callerName`) MUST be stored in the incoming call's extra/payload data so that they survive a cold-start app launch.
- **FR-008A**: If the operating system prevents the native incoming call UI from being shown, the system MUST present the highest-priority platform-allowed fallback (`CallKit/ConnectionService native UI` first; otherwise full-screen incoming-call notification where supported; otherwise in-app incoming-call screen if the app is foregrounded), preserve the call credentials, and keep the call answerable until the call times out or ends.

**Answer Flow**

- **FR-009**: When the patient taps Answer, the system MUST retrieve the stored call credentials from the incoming call data before any lifecycle or cleanup event can run.
- **FR-010**: The system MUST NOT trigger call cleanup logic when the app returns to foreground as a direct result of the patient answering a call. Cleanup on resume MUST be suppressed or deferred until the system can confirm no active call answer is in progress.
- **FR-011**: If the patient answers from a terminated-app state (cold start), the system MUST restore the call session using credentials stored in the incoming call notification data, without relying on in-memory service state that may have been cleared.
- **FR-012**: After the patient taps Answer and the app opens, the patient MUST enter a brief connecting state while session restoration and Agora join are in progress; the system MUST transition to the active video session on join success and MUST NOT show an intermediate "call ended" state during that connection attempt.
- **FR-012A**: The connecting state MUST appear immediately after Answer is accepted, remain visible until join success or terminal outcome, and MUST NOT be replaced by an ended-state screen unless a backend-confirmed end or the 40-second join timeout occurs.

**Session Join**

- **FR-013**: The patient MUST join the same video session channel that the doctor initiated, using the credentials that were set by the server at call start time.
- **FR-014**: The doctor MUST remain connected to the session while the patient is in the process of joining. The server MUST NOT mark the call as ended until at least one party explicitly ends it or the 40-second unanswered join window expires after the patient answers.
- **FR-015**: The patient's join attempt MUST either succeed or be declared failed within 40 seconds after Answer; if that deadline is exceeded without join success, the system MUST show `Unable to connect to the call. Please try again.`.
- **FR-015A**: If the call ends because the doctor ended it or the unanswered ringing window expired before join success, the system MUST show `The call has ended.` and MUST NOT label that outcome as a join failure.

**Lifecycle Safety**

- **FR-016**: The app resume cleanup routine MUST distinguish between: (a) resuming after a completed call (cleanup should run), and (b) resuming because the user just answered an incoming call or is still connecting (cleanup MUST NOT run).
- **FR-017**: The `cleanupAfterCall` operation MUST only clear session state after the answer flow has resolved to one of these outcomes: join success, explicit local or remote end, or the 40-second join timeout.
- **FR-017A**: After Answer is accepted, the call MUST remain in a connecting state until Agora join succeeds or an explicit end event or the 40-second join timeout occurs; lifecycle cleanup MUST NOT run before that outcome is known.

**Call Logging**

- **FR-018**: The system MUST record a structured log entry for each of the following canonical events when applicable: `callattempt`, `notification_dispatched`, `incoming_call_received`, `answer_accepted`, `active_call_restored`, `join_started`, `join_success`, `join_failure`, `cleanup_triggered`, `end_agora_call_invoked`, `callended`.
- **FR-018A**: `callattempt`, `notification_dispatched`, `incoming_call_received`, `answer_accepted`, `join_started`, and one of `join_success|join_failure|callended` are required for every answered call attempt. `active_call_restored` is required only when cold-start or native-call restoration occurs. `cleanup_triggered` is required only when cleanup executes. `end_agora_call_invoked` is required only when a local or backend end action is explicitly invoked.
- **FR-019**: Each log entry MUST include: appointment ID, user ID, timestamp, and event-specific metadata sufficient for remote diagnosis.

### Key Entities

- **Appointment**: Represents a scheduled consultation between a doctor and patient. During an active call it carries: call status, `channelName`, patient `agoraToken`, doctor `agoraToken`, patient `agoraUid`, doctor `agoraUid`, call start time, and call end time.
- **Call Session**: The live video channel both parties join. Identified by a unique channel name generated at call start. Active while either party is connected.
- **Incoming Call Record**: A system-level record created when the native call UI is shown. Carries all call credentials in its extra data to support cold-start restoration. Created and owned by the device's native call framework.
- **Call Log Entry**: An immutable audit record of a single call lifecycle event. Written to Firestore and used for post-incident diagnosis.
- **Device Token**: The patient's current push notification address. Must be kept fresh; stale tokens cause silent call delivery failure.

### Authoritative Call Lifecycle

- **ACL-001**: Firestore state in `databaseId: 'elajtech'`, updated through validated backend actions, is the authoritative source of truth for consultation call state.
- **ACL-002**: Flutter client state is limited to transient UI/process state such as incoming-call presentation, connecting state, restored payload state, and cleanup suppression flags.
- **ACL-003**: The canonical consultation call states are: `scheduled`, `ringing`, `patient_answered`, `joining`, `in_progress`, `declined`, `missed`, `join_timeout_failed`, `ended`, `completed`.
- **ACL-004**: Allowed transitions are:
  - `scheduled -> ringing` when the doctor starts a call.
  - `ringing -> patient_answered` when patient acceptance is validated.
  - `patient_answered -> joining` when session restoration and join begin.
  - `joining -> in_progress` when Agora join succeeds.
  - `ringing -> declined` when the patient declines.
  - `ringing -> missed` when the ringing window expires without answer.
  - `joining -> join_timeout_failed` when the 40-second post-answer join window expires without join success.
  - `ringing|patient_answered|joining|in_progress -> ended` when doctor, patient, or backend timeout logic ends the call.
  - `ended -> completed` only if broader appointment-completion rules explicitly require it.
- **ACL-005**: Patient-side lifecycle events such as app resume, app startup, cleanup, or UI dismissal MUST NOT write terminal consultation states directly without backend validation.
- **ACL-006**: If consultation state affects appointment status, audit logs, or timeout outcomes, the backend is the final authority and client assumptions MUST defer to backend-confirmed state.

---

## Root-Cause Hypotheses

The following hypotheses are ordered by likelihood based on the known codebase structure. All must be investigated before implementing any fix.

### Hypothesis A — App Resume Cleanup Runs Before Join Completes (HIGH likelihood)

When the patient answers the call, the operating system brings the app to the foreground. The Flutter lifecycle fires `AppLifecycleState.resumed`. `_checkAndCleanupCalls()` runs immediately and calls `cleanupAfterCall()`, which clears `_pendingCallData` and ends all native call records. The subsequent `_joinPendingCall()` finds no pending data and either silently exits or navigates with empty credentials, landing on a "call ended" screen.

**Exact code location to inspect**: `main.dart` — `didChangeAppLifecycleState()` and `_checkAndCleanupCalls()`. Verify whether cleanup runs unconditionally on every resume event, or only when a call genuinely finished.

### Hypothesis B — Cold-Start Race: pendingCallData Is Null When Accept Event Fires (HIGH likelihood)

In the cold-start (terminated app) path, the background isolate that showed the call screen may have been garbage-collected before the main isolate starts. When `_onCallAccepted()` fires, `_pendingCallData` is null. The fallback reads from `event.body['extra']`, but if the extra map key names differ between what was stored and what is read (e.g. `agoraUid` stored as int vs. string), the credentials are silently skipped, and join is attempted with null values.

**Exact code location to inspect**: `voip_call_service.dart` — `_onCallAccepted()` extra-map fallback. Verify key names, types, and null safety. Also inspect `_checkActiveCallsOnStartup()` — if it runs and finds the call but misreads the extra data, `_pendingCallData` may be partially populated with null credentials.

### Hypothesis C — FCM Token Read from Wrong Database or Missing (MEDIUM likelihood)

`startAgoraCall` in the Cloud Function reads the patient's FCM token from the `users/{patientId}` document. If the token was saved to the default Firestore database instead of the `elajtech` database, the lookup returns no token, triggering an early function error before the notification is ever sent.

**Exact code location to inspect**: `functions/index.js` — the Firestore client initialization and the patient FCM token read. Confirm `databaseId: 'elajtech'` is used consistently for all reads.

### Hypothesis D — Android Notification Channel Not Registered or Not Max Priority (MEDIUM likelihood)

The FCM payload specifies `channelId: 'incoming_calls'` with maximum priority. If this channel was never registered in the Android app with the correct importance level (`IMPORTANCE_HIGH`), Android silently downgrades it to a heads-up notification or drops it entirely. This would explain why the full-screen incoming call UI does not appear.

**Exact code location to inspect**: Android notification channel registration code (likely in `MainActivity.kt` or app initialization). Verify the `incoming_calls` channel exists, has `IMPORTANCE_HIGH`, and has `lockscreenVisibility` set to public.

### Hypothesis E — Background FCM Handler Initialises VoIPCallService in an Isolate But State Is Not Shared (MEDIUM likelihood)

The background FCM handler runs in a separate Dart isolate. It calls `VoIPCallService.showIncomingCall()` which sets `_pendingCallData`. When the main isolate starts on cold-start, `getIt<VoIPCallService>()` is a different singleton instance with `_pendingCallData = null`. This means the background isolate's call data never reaches the foreground handler.

**Exact code location to inspect**: `fcm_service.dart` — `_firebaseMessagingBackgroundHandler()`. Inspect how VoIPCallService is resolved and whether the `extra` data in `FlutterCallkitIncoming.activeCalls()` is the reliable fallback for cross-isolate state.

### Hypothesis F — iOS VoIP Push Type Incorrect (MEDIUM likelihood for iOS)

For CallKit to trigger on iOS, the push must use `apns-push-type: voip`, not `apns-push-type: alert`. The current payload uses `alert`. This means CallKit never activates; instead a standard notification appears, which does not produce the full-screen incoming call UI and does not persist call data in the format CallKit expects.

**Exact code location to inspect**: `functions/index.js` — `sendAgoraVoIPNotification()`. Verify `apns-push-type` value and whether a separate APNs VoIP certificate is configured.

### Hypothesis G — endAgoraCall Called Prematurely by Doctor Side (LOW-MEDIUM likelihood)

If the doctor's side triggers `endAgoraCall` while the patient's answer is still being processed (e.g. due to a UI timeout or an aggressive "no answer" timer), the Firestore appointment document may be moved into a terminal state such as `ended` before the patient finishes joining. The patient's video screen then checks call state on load and immediately shows "call ended."

**Exact code location to inspect**: `video_consultation_service.dart` — any timeout or auto-end logic on the doctor side. Also the `AgoraVideoCallScreen` on the patient side — does it read `callStatus` from Firestore on init?

---

## Failure Points to Inspect

| # | Component | What to Check |
|---|-----------|---------------|
| 1 | `functions/index.js` — `startAgoraCall` | Confirm `databaseId: 'elajtech'` used for patient token lookup; confirm FCM send logs are captured |
| 2 | `functions/index.js` — `sendAgoraVoIPNotification` | Verify complete payload (all Agora fields present); verify `apns-push-type` value for iOS VoIP |
| 3 | `main.dart` — `didChangeAppLifecycleState` | Confirm cleanup does not run when an answer event is in progress |
| 4 | `main.dart` — `_checkAndCleanupCalls` | Verify this is not called during a call answer transition |
| 5 | `voip_call_service.dart` — `_onCallAccepted` | Verify extra-map key names and types; confirm null safety of fallback path |
| 6 | `voip_call_service.dart` — `_checkActiveCallsOnStartup` | Verify correct parsing of `agoraUid` (int vs string coercion) |
| 7 | `voip_call_service.dart` — `cleanupAfterCall` | Confirm it is not called before join completes |
| 8 | `fcm_service.dart` — background handler | Confirm VoIPCallService state is written to the CallKit extra payload, not just in-memory |
| 9 | Android `MainActivity` / app init | Confirm `incoming_calls` notification channel exists with `IMPORTANCE_HIGH` |
| 10 | iOS `AppDelegate` / entitlements | Confirm VoIP background mode and APNs VoIP certificate are configured |
| 11 | Firestore `users/{patientId}` | Verify `fcmToken` field is present and recently refreshed |
| 12 | `AgoraVideoCallScreen` | Verify it does not read `callStatus` from Firestore on init and auto-exit if status is not `ringing` |

---

## Required Logs to Collect

To diagnose the live bug before implementing a fix, the following logs must be collected:

**Server-side (Firebase Cloud Functions logs):**
- `startAgoraCall` execution: success/error, patientId, FCM token value (first 8 chars), notification send result
- `sendAgoraVoIPNotification`: full FCM response including message ID or error code

**Patient device (Flutter debug logs or Crashlytics):**
- Background FCM handler invocation: timestamp, message type, appointmentId
- `VoIPCallService.showIncomingCall` called: callId, appointmentId, channelName (null or value)
- `_onCallAccepted` fired: pendingCallData null/set, extra map contents
- `AppLifecycleState.resumed` fired: timestamp, `_pendingCallData` null/set at that moment
- `_checkAndCleanupCalls` called: timestamp, result of `cleanupAfterCall`
- `_joinPendingCall` called: pendingCallData null/set
- Agora `joinChannel` called: channelName, token present/absent, uid
- Agora join result: success or error code

**Firestore `call_logs`:**
- All log entries for the test appointment, ordered by timestamp
- Specifically: were `incoming_call_received`, `answer_accepted`, `join_started` ever written?

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: When the doctor starts a call, the patient's device displays either the native incoming call screen or, when native presentation is blocked by platform/device conditions, the highest-priority platform-allowed fallback within 5 seconds in 95% of test runs across Android and iOS on a stable connection.
- **SC-002**: 100% of answered calls enter a brief connecting state and then proceed to the active video session without an intermediate "call ended" screen, across all three app states (foreground, background, terminated).
- **SC-003**: Cold-start call restoration succeeds (patient joins active session) in 100% of test runs where the doctor is still connected at the time of answer.
- **SC-004**: The app resume event during call answer does not trigger cleanup in 100% of test runs.
- **SC-005**: `call_logs` contains a complete and correctly ordered sequence of the required canonical lifecycle events for 100% of test call attempts. For every answered call attempt this includes `callattempt`, `notification_dispatched`, `incoming_call_received`, `answer_accepted`, `join_started`, and one terminal outcome from `join_success|join_failure|callended`, plus the conditional events `active_call_restored`, `cleanup_triggered`, and `end_agora_call_invoked` when those flows occur.
- **SC-006**: Existing doctor call initiation, explicit doctor end-call behavior, unanswered join timeout behavior, and appointment status update flows continue to pass 100% of the regression scenarios `T-10`, `T-12`, and the doctor-side regression suite defined for this feature.

---

## Assumptions

- Both Android and iOS test devices have notification permissions granted to AndroCare360.
- The Agora App ID and App Certificate are correctly configured in the Cloud Functions environment variables.
- The `elajtech` Firestore database contains valid test appointment documents and user documents with current FCM tokens.
- The doctor-side call flow (start call, join session, end call) works correctly and is not broken by this fix.
- The APNs VoIP certificate is provisioned and uploaded to Firebase for iOS; if it is not, this must be raised as a prerequisite blocker before the fix can be validated on iOS.
- The `incoming_calls` Android notification channel is expected to be registered at app startup; if it does not exist at the time of the first call, Android will silently downgrade the notification.
- The background FCM handler running in a Dart isolate does not share in-memory state with the main Flutter isolate; all call data passed through the handler must be written to a persistent medium (CallKit/ConnectionService extra payload) to survive the isolate boundary.
- Cloud Function region is `europe-west1`; any region mismatch will cause callable function invocations to fail silently from the client.

---

## Regression Risks

- **Risk 1 — Doctor post-call cleanup dialog**: If the lifecycle cleanup guard is modified to suppress cleanup on answer, the doctor's session-end dialog (shown after `_checkAndCleanupCalls`) must still fire correctly when the doctor exits the call normally.
- **Risk 2 — Missed call / decline flow**: Changes to the `cleanupAfterCall` or `_pendingCallData` lifecycle must not break the missed call and decline flows, which rely on cleanup running promptly.
- **Risk 3 — Duplicate cleanup on app resume**: If a flag is used to suppress cleanup during call answer, it must be reset after the video session ends to prevent cleanup from being permanently suppressed on subsequent app resumes.
- **Risk 4 — Android notification channel downgrade**: If the notification channel is re-created with lower importance to fix an unrelated issue, the incoming call priority will silently regress.
- **Risk 5 — FCM token refresh**: Any change to how FCM tokens are saved must ensure they continue to be written to `elajtech` (not the default Firestore database), or all future call notifications will fail.

---

## Testing Requirements

### Real-Device Testing (Mandatory)

All acceptance scenarios must be verified on physical devices:

- Android (minimum API 29): background state, terminated state, foreground state
- iOS (minimum iOS 15): background state, terminated state, foreground state

Emulators/simulators are not acceptable for incoming call UI testing; CallKit and ConnectionService require real hardware.

### Integration Test Scenarios

| ID | Scenario | Expected Result |
|----|----------|-----------------|
| T-01 | Doctor starts call → patient in background | Native incoming call UI appears within 5s |
| T-02 | Doctor starts call → patient app terminated | Native incoming call UI appears; app cold-starts correctly on answer |
| T-03 | Doctor starts call → patient in foreground | Incoming call screen shown; answer shows brief connecting state, then navigates to video session |
| T-04 | Patient answers from terminated state | All call credentials restored; patient joins active session |
| T-05 | Patient answers from background state | App comes to foreground; no cleanup runs; patient joins session |
| T-06 | App lifecycle "resumed" fires during answer | Cleanup is NOT triggered; video session remains accessible |
| T-07 | Patient joins active Agora session | Doctor and patient see each other; audio/video functional |
| T-08 | Patient declines call | `callStatus` updates to `declined`; call logs record decline event |
| T-09 | Call rings 60s with no answer | Timeout fires; `callStatus` updates to `missed`; call logs record timeout |
| T-10 | Doctor ends call while patient is joining | Patient sees `The call has ended.` gracefully, not a join-failure message |
| T-11 | Join does not succeed within 40 seconds after Answer | Patient sees `Unable to connect to the call. Please try again.` |
| T-12 | Doctor-side unanswered join window reaches 40 seconds after Answer | Session is treated as ended and patient sees `The call has ended.` |

### Logging Validation

For every test run, query `call_logs` for the test appointment and confirm presence of applicable entries for:

1. `callattempt` — written by Cloud Function when doctor initiates
2. `notification_dispatched` — written when the notification send attempt completes
3. `incoming_call_received` — written by patient device when call screen appears
4. `answer_accepted` — written when patient taps Answer
5. `active_call_restored` — written when a cold-start or native-call restore path reconstructs active call state
6. `join_started` — written when patient initiates Agora channel join
7. `join_success` OR `join_failure` (with error detail) — written after join attempt resolves
8. `cleanup_triggered` — written whenever cleanup runs, with `reason` field
9. `end_agora_call_invoked` — written when a local or backend end-call action is invoked
10. `callended` — written when call terminates, with `endedBy` field

Entries must be in chronological order. Any gap in the applicable required sequence is a bug.

---

## Confirmed Root Causes *(from code analysis)*

After inspecting the codebase against the hypotheses above, the following root causes are **confirmed**:

### RC-1 — `_checkAndCleanupCalls()` destroys pending call data on every resume *(Bug B — HIGH)*

**File**: `lib/main.dart:514-544`

When the patient answers the call, the OS brings the app to the foreground. `didChangeAppLifecycleState(resumed)` fires and calls `_checkAndCleanupCalls()`, which unconditionally calls `cleanupAfterCall()`. This method (`voip_call_service.dart:758-805`) executes:
1. `FlutterCallkitIncoming.endAllCalls()` — dismisses the native call UI
2. `_pendingCallData = null` — erases the Agora credentials
3. `_currentCallId = null`

By the time `_joinPendingCall()` runs, `_pendingCallData` is null and the call data is gone. The user sees a "call ended" state.

**Confirms**: Hypothesis A.

### RC-2 — FCM message includes `notification` object, suppressing background handler *(Bug A — HIGH)*

**File**: `functions/index.js:1513-1519`

`sendVoIPNotification()` sends a FCM message with BOTH a `notification` object AND a `data` object. On Android, when a `notification` key is present, the system auto-displays it as a system notification and the `onBackgroundMessage` handler may NOT fire. This means `VoIPCallService.showIncomingCall()` is never called, so no native call UI is displayed.

The `data`-only message pattern is required for VoIP calls so that the background handler can invoke `flutter_callkit_incoming` to show the native incoming call screen.

### RC-3 — iOS APNS payload missing `apns-push-type: voip` header *(Bug A on iOS — HIGH)*

**File**: `functions/index.js:1539-1549`

The APNS configuration sets `apns-priority: '10'` and `content-available: 1`, but does NOT include the `apns-push-type: voip` header. Without this header, iOS does NOT invoke CallKit. Instead, a standard push notification appears, which cannot show the full-screen incoming call UI or survive a terminated-app state.

### RC-4 — Android notification channel `incoming_calls` not registered at app startup *(Bug A on Android — MEDIUM)*

**File**: `android/app/src/main/kotlin/com/example/elajtech/MainActivity.kt`

`MainActivity.kt` does not register any notification channel. The FCM payload specifies `channelId: 'incoming_calls'`, and `flutter_callkit_incoming` may register it internally, but if the channel does not exist with `IMPORTANCE_HIGH` before the first call arrives, Android silently downgrades the notification priority.

---

## Implementation Plan

### Step 1 — Add answer-in-progress guard to lifecycle cleanup *(Fixes RC-1 / Bug B)*

**File**: `lib/main.dart` — `_AuthWrapperState`

Add a boolean flag `_isAnsweringCall` to `_AuthWrapperState`. Set it to `true` when VoIPCallService reports an `accepted` event. In `_checkAndCleanupCalls()`, skip `cleanupAfterCall()` when `_isAnsweringCall` is `true`. Reset the flag after the video screen navigation completes.

Changes:
1. Add `bool _isAnsweringCall = false;` field.
2. In `initState()`, listen to `VoIPCallService.callEventStream`:
   - On `VoIPCallEventType.accepted`: set `_isAnsweringCall = true`.
   - On `VoIPCallEventType.ended` or `VoIPCallEventType.declined` or `VoIPCallEventType.missed`: set `_isAnsweringCall = false`.
3. In `_checkAndCleanupCalls()`:
   - If `_isAnsweringCall` is `true`, skip `cleanupAfterCall()` entirely and log the skip reason.
   - Otherwise, proceed with existing cleanup logic.
4. In `_joinPendingCall()`, after `Navigator.push()` to `AgoraVideoCallScreen`:
   - Set `_isAnsweringCall = false` in the push callback (when the video screen is popped).

**Regression safety**: The flag only suppresses cleanup when an answer is in progress. Normal resume-from-call scenarios (doctor ends call, patient returns to app) do NOT set the flag, so cleanup runs as before.

### Step 2 — Convert FCM message to data-only in `sendVoIPNotification()` *(Fixes RC-2 / Bug A)*

**File**: `functions/index.js` — `sendVoIPNotification()` (line ~1513)

Remove the `notification` key from the FCM message payload. Keep only the `data` key and the `android`/`apns` configuration blocks. This ensures FCM delivers the message as a data message, which always triggers `onBackgroundMessage` on Android.

Before:
```javascript
const message = {
  token: fcmToken,
  notification: {          // ← REMOVE this block
    title: `...`,
    body: '...',
  },
  data: { ... },
  android: { ... },
  apns: { ... },
};
```

After:
```javascript
const message = {
  token: fcmToken,
  data: { ... },
  android: {
    priority: 'high',
  },
  apns: { ... },
};
```

**Note**: Remove the `notification` block within `android` as well, since the data-only pattern does not use it. The `flutter_callkit_incoming` package handles displaying the native call UI.

### Step 3 — Add `apns-push-type: voip` to iOS APNS headers *(Fixes RC-3 / Bug A on iOS)*

**File**: `functions/index.js` — `sendVoIPNotification()` (line ~1539)

Add `'apns-push-type': 'voip'` to the `apns.headers` object.

Before:
```javascript
apns: {
  headers: {
    'apns-priority': '10',
  },
  payload: {
    aps: {
      'content-available': 1,
      sound: 'default',
    },
  },
},
```

After:
```javascript
apns: {
  headers: {
    'apns-priority': '10',
    'apns-push-type': 'voip',
  },
  payload: {
    aps: {
      'content-available': 1,
      sound: 'default',
    },
  },
},
```

**Prerequisite**: A VoIP APNs certificate must be provisioned in the Firebase console for the iOS app. If this certificate is not configured, the VoIP push will be rejected by APNs. Verify this in Firebase Console → Project Settings → Cloud Messaging → iOS app configuration.

### Step 4 — Register Android notification channel at app startup *(Fixes RC-4 / Bug A on Android)*

**File**: `android/app/src/main/kotlin/com/example/elajtech/MainActivity.kt`

Add notification channel registration in `configureFlutterEngine()`:

```kotlin
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.media.AudioAttributes
import android.os.Build

// In configureFlutterEngine(), after super call:
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
    val channel = NotificationChannel(
        "incoming_calls",
        "مكالمات واردة",
        NotificationManager.IMPORTANCE_HIGH
    ).apply {
        description = "Incoming video call notifications"
        lockscreenVisibility = Notification.VISIBILITY_PUBLIC
        setBypassDnd(true)
        val audioAttributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_RINGTONE)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        setSound(android.provider.Settings.System.DEFAULT_RINGTONE_URI, audioAttributes)
    }
    val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    notificationManager.createNotificationChannel(channel)
}
```

### Step 5 — Add comprehensive call lifecycle logging *(Addresses FR-018, FR-019)*

**Files**: `lib/main.dart`, `lib/core/services/voip_call_service.dart`, `lib/features/patient/consultation/presentation/screens/agora_video_call_screen.dart`

Add `call_logs` entries (top-level Firestore collection, database `elajtech`) at each lifecycle stage:

| Event | File | Where to log |
|-------|------|-------------|
| `incoming_call_received` | `voip_call_service.dart` | In `showIncomingCall()`, after `FlutterCallkitIncoming.showCallkitIncoming()` succeeds |
| `answer_accepted` | `voip_call_service.dart` | In `_onCallAccepted()`, after restoring call data (already partially done) |
| `join_started` | `agora_video_call_screen.dart` | In `_initializeAgora()`, before `_agoraService.joinChannel()` |
| `join_success` | `agora_video_call_screen.dart` | In `_handleAgoraEvent()`, on `AgoraEventType.joinedChannel` |
| `join_failure` | `agora_video_call_screen.dart` | In `_initializeAgora()`, in the catch block |
| `cleanup_triggered` | `main.dart` | In `_checkAndCleanupCalls()`, log whether cleanup ran or was skipped, with reason |
| `call_ended` | `agora_video_call_screen.dart` | In `_endCall()`, before `VideoConsultationService().endVideoCall()` |

Each log entry structure:
```json
{
  "appointmentId": "...",
  "userId": "...",
  "eventType": "...",
  "timestamp": "serverTimestamp",
  "metadata": { ... event-specific details ... }
}
```

### Step 6 — Handle cold-start answer race condition

**File**: `lib/core/services/voip_call_service.dart` — `_checkActiveCallsOnStartup()`

The existing cold-start path reads call data from `FlutterCallkitIncoming.activeCalls()`. Verify that:
1. `agoraUid` type coercion is handled (it may come back as a String from the extra map, but the model expects `int?`). The current code at line 157 reads `extra?['agoraUid'] as int?` — this may throw if the value is a String. Add `int.tryParse()` fallback.
2. The `callerName` field in `activeCalls()` data uses the key `nameCaller` (confirmed at line 154), which matches the CallKit params. Verify this is correct across platforms.

### Step 7 — Verify and test

After implementing Steps 1–6, perform the following verification:

1. **Deploy Cloud Functions** (`functions/index.js`) with the updated `sendVoIPNotification()`.
2. **Run the Android app** on a physical device with a test account.
3. **Test T-01 through T-12** from the Integration Test Scenarios table.
4. **Query `call_logs`** in Firestore after each test to verify the complete event sequence.
5. **Verify no regression** on doctor-side call initiation and ending.

---

## Files to Modify

| File | Changes |
|------|---------|
| `functions/index.js` | Remove `notification` from FCM message; add `apns-push-type: voip` |
| `lib/main.dart` | Add `_isAnsweringCall` flag and guard in `_checkAndCleanupCalls()`; add cleanup logging |
| `lib/core/services/voip_call_service.dart` | Add `int.tryParse()` fallback for `agoraUid`; enhance logging in `_onCallAccepted()` |
| `lib/features/patient/consultation/presentation/screens/agora_video_call_screen.dart` | Add `join_started`, `join_success`, `join_failure`, `call_ended` log entries |
| `android/app/src/main/kotlin/com/example/elajtech/MainActivity.kt` | Register `incoming_calls` notification channel with `IMPORTANCE_HIGH` |
