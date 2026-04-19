# Clarifications: Agora Video-Calling Service Audit and Fix

**Created**: 2026-03-31  
**Feature**: `.specify/specs/agora-audit-and-fix/spec.md`

## Confirmed Context

- governing rule files are `docs/important-rules.md` and `docs/instructions-for-flutter-app-development.md`
- the active backend for this feature is `functions/`
- Firestore must use `databaseId: 'elajtech'`
- callable functions must use `europe-west1`

## Open Questions Logged via `/speckit.clarify`

1. What are the canonical user-facing error categories for Agora failures?
Assumption: treat current failure surface as callable auth/validation errors, Firestore lookup/update errors, notification delivery failures, and Agora join/timeout failures.

2. Which environments are available for rollout?
Assumption: local/dev, staging, and production exist conceptually even if staging config is lighter than production.

3. Is there a strict call duration limit?
Assumption: the current hard evidence is a 60-second ringing timeout in `VoIPCallService.showIncomingCall`; no separate in-call duration limit is yet codified.

4. What is the authoritative source of appointment completion?
Assumption: the intended source is the callable `completeAppointment`, not direct patient-side or provider-only Firestore writes.

5. Are missed and declined outcomes part of the required backend contract?
Assumption: yes, because Flutter currently calls `handleMissedCall` and `handleCallDeclined` in `VoIPCallService`.

6. What should happen during cold-start restoration if pending call data exists but the appointment document is missing or incomplete?
Assumption: the app should fail safely with a user-visible error and should not fabricate session state locally.

7. What should happen when the doctor retries after timeout?
Assumption: retries should be server-authorized and should not silently rely on stale local Agora data.

## Clarification Outcome Used for Planning

- implement only fixes that are strongly supported by current code and rules
- avoid introducing a new appointment/session data model in this pass
- prioritize ownership, completion safety, missing backend handlers, and incoming-call restoration
