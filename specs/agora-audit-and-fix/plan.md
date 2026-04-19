# Implementation Plan: Agora Video-Calling Service Audit and Fix

**Branch**: `agora-audit-and-fix` | **Date**: 2026-03-31 | **Spec**: `.specify/specs/agora-audit-and-fix/spec.md`
**Input**: Feature specification from `.specify/specs/agora-audit-and-fix/spec.md`

## Summary

Stabilize the existing Agora telemedicine flow by fixing the highest-risk lifecycle gaps in the active Flutter and Cloud Functions code: enforce server-side ownership for call control, stop client-side patient auto-completion, implement missing missed/declined callable handlers, and complete pending-call restoration for accepted incoming calls.

## Technical Context

**Language/Version**: Dart/Flutter app + Node.js Firebase Cloud Functions  
**Primary Dependencies**: Flutter, Riverpod, Firebase Auth, Cloud Firestore, Cloud Functions, Agora RTC, flutter_callkit_incoming  
**Storage**: Firestore (`databaseId: 'elajtech'`) and existing log collections  
**Testing**: `flutter test`, widget/integration tests, Functions Jest tests  
**Target Platform**: Flutter mobile app + Firebase Cloud Functions (`europe-west1`)  
**Project Type**: Mobile app + backend functions  
**Performance Goals**: no added UI-thread blocking during call startup/restoration  
**Constraints**: must preserve current production architecture, must not bypass rules, must avoid storing tokens in logs  
**Scale/Scope**: focused Agora lifecycle remediation, not a full telemedicine redesign

## Constitution Check

- **Architecture Check**: pass if Flutter business logic stays in services/providers or minimal app-shell orchestration, not scattered into widgets.
- **Security Check**: pass only if privileged call-state actions are server-authorized and no new sensitive logging is introduced.
- **Testing Check**: pass only if targeted Flutter and Functions tests cover the fixed paths.
- **Spec Kit Check**: pass because this plan is written after constitution, spec, and clarify artifacts.

## Code Review Steps

### Flutter

1. Review `lib/main.dart` for pending-call restoration and patient cleanup completion behavior.
2. Review `lib/core/services/voip_call_service.dart` for accepted/declined/missed event handling and callable usage.
3. Review `lib/core/services/video_consultation_service.dart` and `lib/core/services/appointment_completion_service.dart` for callable contracts.
4. Review `lib/features/patient/consultation/presentation/screens/agora_video_call_screen.dart` for end-call and retry boundaries.
5. Review `lib/shared/providers/appointments_provider.dart` and doctor UI usage for direct completion writes that should not own Agora completion behavior.

### Cloud Functions

1. Review `functions/index.js` exports for `startAgoraCall`, `endAgoraCall`, and `completeAppointment` authorization gaps.
2. Verify whether missed/declined callable handlers are missing from the active backend.
3. Review `logCallEvent` usage to ensure outcome logging can be added without storing raw tokens.

## Configuration Verification Steps

1. Confirm Flutter DI and runtime usage keep `databaseId: 'elajtech'` for Firestore operations.
2. Confirm all Agora-related callables use `FirebaseFunctions.instanceFor(region: 'europe-west1')`.
3. Verify active Firebase Functions deployment unit is `functions/`.
4. Verify Agora credentials are still sourced server-side only.
5. Verify current incoming-call setup across FCM/CallKit/VoIP paths is preserved while the lifecycle fixes are added.

## Fix Workstreams

### Workstream 1: Completion Ownership and App Safety

1. Remove patient-side auto-completion from `lib/main.dart` cleanup flow.
2. Route doctor confirmation in `lib/main.dart` through `AppointmentCompletionService` instead of provider-only direct write.
3. Keep user-facing messaging clear for doctor and patient outcomes.

### Workstream 2: Pending-Call Restoration

1. Implement `_joinPendingCall()` in `lib/main.dart` to fetch the appointment from Firestore and navigate into `AgoraVideoCallScreen` when valid pending call data exists.
2. Fail safely if pending data is incomplete or the appointment record cannot be reconstructed.

### Workstream 3: Cloud Functions Authorization and Missing Handlers

1. Tighten `startAgoraCall` to require `context.auth.uid == doctorId`.
2. Tighten `completeAppointment` to require `context.auth.uid == doctorId`.
3. Tighten `endAgoraCall` to verify the authenticated user belongs to the appointment.
4. Add active-backend exports for `handleMissedCall` and `handleCallDeclined` that log outcomes and update only non-completion fields.

## Testing Plan

### Flutter Tests

1. Add or update tests proving patient cleanup no longer completes appointments.
2. Add or update tests for doctor completion dialog using server completion path.
3. Add or update tests for pending-call restoration navigation and safe failure behavior.

### Functions Tests

1. Add tests for start-call auth mismatch rejection.
2. Add tests for complete-appointment auth mismatch rejection.
3. Add tests that end-call rejects unrelated users.
4. Add tests that `handleMissedCall` and `handleCallDeclined` are exported and do not complete appointments.

### Verification Commands

1. `flutter analyze`
2. `flutter test` for targeted Flutter suites, expanding if needed
3. `npm test` inside `functions/`

## Progressive Rollout Strategy

1. **Dev**: run local/unit/widget/functions tests and verify manual doctor/patient call flows.
2. **Staging**: deploy Functions and app build to staging, verify start, answer, decline, missed, end, and doctor completion with logging.
3. **Production**: deploy only after staging confirms no client-side completion regression and callable ownership checks behave correctly.

## Source Structure

```text
lib/
├── main.dart
├── core/services/
│   ├── appointment_completion_service.dart
│   ├── video_consultation_service.dart
│   └── voip_call_service.dart
├── features/patient/consultation/presentation/screens/agora_video_call_screen.dart
└── shared/providers/appointments_provider.dart

functions/
└── index.js

test/
├── unit/
├── widget/
└── integration/
```

**Structure Decision**: limit the implementation to the existing Flutter app shell, core services, and active Functions entrypoint. No broad refactor or new module introduction in this pass.
