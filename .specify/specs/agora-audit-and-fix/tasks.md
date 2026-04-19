# Tasks: Agora Video-Calling Service Audit and Fix

**Input**: `.specify/specs/agora-audit-and-fix/spec.md`, `.specify/specs/agora-audit-and-fix/clarify.md`, `.specify/specs/agora-audit-and-fix/plan.md`

## Phase 1: Audit-Grounded Setup

- [X] T001 Verify the active backend remains `functions/index.js` and ignore legacy Agora folders for this implementation.
- [X] T002 Confirm Flutter files in scope: `lib/main.dart`, `lib/core/services/appointment_completion_service.dart`, `lib/core/services/voip_call_service.dart`, `lib/features/patient/consultation/presentation/screens/agora_video_call_screen.dart`, `lib/shared/providers/appointments_provider.dart`.

## Phase 2: Flutter Safety Fixes

- [X] T003 Remove patient-side appointment completion from `lib/main.dart` cleanup flow.
- [X] T004 Route doctor completion in `lib/main.dart` through `AppointmentCompletionService` and preserve success/error UX.
- [X] T005 Implement pending-call navigation in `lib/main.dart` by loading the appointment from Firestore and attaching pending Agora data.
- [X] T006 Fail safely when pending call data is incomplete or the appointment cannot be loaded.

## Phase 3: Cloud Functions Fixes

- [X] T007 Update `functions/index.js` so `startAgoraCall` rejects payload doctor IDs that do not match `context.auth.uid`.
- [X] T008 Update `functions/index.js` so `completeAppointment` rejects payload doctor IDs that do not match `context.auth.uid`.
- [X] T009 Update `functions/index.js` so `endAgoraCall` verifies the authenticated caller belongs to the appointment before updating it.
- [X] T010 Add `handleMissedCall` export in `functions/index.js`.
- [X] T011 Add `handleCallDeclined` export in `functions/index.js`.
- [X] T012 Ensure missed/declined handlers update only non-completion fields and write normalized monitoring events.

## Phase 4: Tests

- [X] T013 Add/update Flutter tests for patient cleanup no-complete behavior.
- [X] T014 Add/update Flutter tests for pending-call restoration behavior.
- [X] T015 Add/update Functions tests for auth mismatch and appointment ownership checks.
- [X] T016 Add/update Functions tests for missed/declined handler exports and non-completion behavior.

## Phase 5: Verification

- [X] T017 Run `flutter analyze`.
- [X] T018 Run targeted `flutter test` suites for changed Flutter behavior.
- [ ] T019 Run `npm test` in `functions/` (blocked: `functions/package.json` has no `test` script; direct `npx jest test/integration.test.js --runInBand` currently times out in emulator setup in this environment).
- [X] T020 Review checklist completion in `.specify/specs/agora-audit-and-fix/checklist.md`.
