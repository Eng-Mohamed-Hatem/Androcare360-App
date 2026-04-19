# Quality Checklist: Agora Video-Calling Service Audit and Fix

**Purpose**: Validate safety, correctness, and rollout readiness for the Agora remediation.
**Created**: 2026-03-31
**Feature**: `.specify/specs/agora-audit-and-fix/spec.md`

## Constitution and Rules

- [ ] Constitution 1.1.0 telemedicine governance requirements are reflected in the implementation.
- [ ] Firestore usage remains on `databaseId: 'elajtech'`.
- [ ] Cloud Functions calls remain in `europe-west1`.
- [ ] No new sensitive logging stores raw Agora tokens or unnecessary PHI.

## Flutter Behavior

- [ ] Patient app cleanup no longer completes appointments.
- [ ] Doctor completion flow uses the server completion path.
- [ ] Pending-call cold-start restoration navigates into `AgoraVideoCallScreen` when valid data exists.
- [ ] Invalid pending-call data fails safely with a clear user-facing result.

## Cloud Functions Behavior

- [ ] `startAgoraCall` rejects `doctorId` values that do not match `context.auth.uid`.
- [ ] `completeAppointment` rejects `doctorId` values that do not match `context.auth.uid`.
- [ ] `endAgoraCall` rejects callers unrelated to the appointment.
- [ ] Active backend exports exist for `handleMissedCall` and `handleCallDeclined`.
- [ ] Missed and declined handlers do not mark appointments completed.

## Tests and Verification

- [ ] Targeted Flutter tests cover the changed app-shell/service behavior.
- [ ] Functions tests cover auth checks and missing-handler regressions.
- [ ] `flutter analyze` passes.
- [ ] Targeted `flutter test` suites pass.
- [ ] `npm test` in `functions/` passes.

## Rollout

- [ ] Dev validation completed.
- [ ] Staging verification steps are documented.
- [ ] Production rollout is gated on staging success.
