# Research: Fix Patient Incoming Call — Not Ringing and Auto-Ended on Answer

## Decision 1: Backend owns the canonical call lifecycle

- **Decision**: Firestore state in `databaseId: 'elajtech'`, updated through validated backend actions, is the source of truth for consultation state. Flutter owns only transient UI state such as native incoming presentation, connecting state, and local cleanup suppression flags.
- **Rationale**: The current bug is caused by local lifecycle signals racing the real call flow. Backend ownership prevents client resume/cleanup from incorrectly ending a session and keeps doctor/patient devices aligned on the same truth.
- **Alternatives considered**:
  - Let Flutter decide answered/joined/ended state locally: rejected because it reproduces lifecycle and cold-start race conditions.
  - Split ownership between client and backend: rejected because timeout and end-state responsibility becomes ambiguous.

## Decision 2: Canonical post-answer state includes an explicit joining window

- **Decision**: Use canonical lifecycle transitions `ringing -> patient_answered -> joining -> in_progress` with terminal outcomes `declined`, `missed`, `ended`, and `join_timeout_failed`. The 40-second unanswered join window after answer is backend-owned.
- **Rationale**: The feature requires cleanup suppression during answer, a distinct connecting screen, and different user messaging for local join failure versus a true ended call. An explicit joining state models those outcomes cleanly.
- **Alternatives considered**:
  - Collapse `patient_answered` and `joining` into a single state: rejected because it weakens logging and timeout precision.
  - Let app lifecycle callbacks control timeout: rejected because lifecycle is not authoritative.

## Decision 3: Android and iOS incoming-call delivery must follow platform-native patterns

- **Decision**: On Android, use a high-priority data-first FCM delivery path, pre-register the `incoming_calls` notification channel at app startup, and invoke `flutter_callkit_incoming` from the background message path. On iOS, plan for VoIP-capable APNs/PushKit + CallKit behavior for reliable background/terminated native incoming UI; if native UI is blocked, fall back to the highest-priority available notification while preserving the join payload.
- **Rationale**: Android can support native incoming UI through data-message handling plus a correctly registered channel. iOS terminated-state native incoming-call behavior is not reliably delivered by standard notification semantics and requires CallKit-compatible VoIP setup.
- **Alternatives considered**:
  - Use mixed notification+data payloads and rely on the OS to show incoming UI: rejected because background handlers may not run and native UI may not appear.
  - Assume standard iOS alert/data pushes are sufficient for terminated CallKit behavior: rejected because the platform behavior is not reliable for this requirement.

## Decision 4: Persistent logging must be structured and sanitized

- **Decision**: `call_logs` entries must include correlation ID, appointment ID, actor, event name, timestamp, platform, app state, lifecycle state, reason/error code, and elapsed timing metadata. Persistent logs must not store raw Agora tokens, FCM tokens, raw notification payloads, free-text PHI, or unsanitized stack traces.
- **Rationale**: The team needs remote diagnosis of delivery, answer, join, cleanup, and end behavior without creating a sensitive-data leak surface in medical-call telemetry.
- **Alternatives considered**:
  - Store full payloads and tokens for easier debugging: rejected because it violates least-privilege logging and medical-data protection requirements.
  - Use only console logs: rejected because they are insufficient for cross-device post-incident diagnosis.

## Decision 5: Contracts must cover both callable functions and log schema

- **Decision**: Phase 1 contracts will document callable-function request/response expectations for call start/end actions and the structured `call_logs` event schema.
- **Rationale**: This feature crosses Flutter, Cloud Functions, native incoming-call presentation, and Firestore monitoring. Contract drift is a primary failure risk, especially for payload restoration and lifecycle events.
- **Alternatives considered**:
  - Document only function payloads: rejected because observability schema is part of the cross-system contract.
  - Rely on implementation tests without written contracts: rejected because rollout risk remains high when the app and backend evolve separately.

## Decision 6: Automated coverage must focus on state transitions and integration boundaries

- **Decision**: Use Flutter unit tests for lifecycle guards, payload restoration, and logging helpers; Flutter integration tests for happy path and timeout/error boundaries; Jest tests for Cloud Functions payloads, database targeting, and callable-function error handling; plus mandatory Android and iOS physical-device validation for native incoming UI.
- **Rationale**: The highest-risk failures are lifecycle races, payload mismatches, and native/background behavior, not purely visual rendering. The repository already has matching Flutter and Jest test layers.
- **Alternatives considered**:
  - Depend mainly on manual testing: rejected because regressions would be hard to contain.
  - Depend mainly on widget/golden tests: rejected because they do not exercise lifecycle or backend boundaries.

## Decision 7: Rollout must be gated by platform readiness and real-device validation

- **Decision**: Roll out only after Android and iOS real-device validation passes for foreground, background, and terminated states, and only after verifying iOS VoIP/CallKit prerequisites are configured. If iOS native terminated behavior remains blocked by environment setup, treat it as a release blocker for full-scope completion rather than silently downgrading the requirement.
- **Rationale**: Telemedicine call delivery is patient-critical, and the constitution requires timeout, fallback, and rollout behavior to be documented before implementation starts.
- **Alternatives considered**:
  - Release Android first and defer iOS without explicit gating: rejected because the spec scope covers both platforms.
  - Consider simulator/emulator evidence sufficient: rejected because native incoming-call presentation requires physical devices.
