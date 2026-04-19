# Tasks: Fix Patient Incoming Call — Not Ringing and Auto-Ended on Answer

**Input**: Design documents from `C:\Users\moham\Desktop\androcare\elajtech\elajtech\specs\009-fix-incoming-call\`
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/call-lifecycle-contract.md`, `quickstart.md`

**Tests**: Tests are required by the feature spec and constitution for this telemedicine flow.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (`US1`, `US2`, `US3`, `US4`)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare the feature branch for telemedicine call-flow changes and test execution.

- [X] T001 Verify Flutter and Functions dependencies for incoming-call flow in `pubspec.yaml` and `functions/package.json`
- [X] T002 Create or align shared task notes and developer references in `specs/009-fix-incoming-call/quickstart.md` and `specs/009-fix-incoming-call/contracts/call-lifecycle-contract.md`
- [X] T003 [P] Confirm existing Flutter test targets for call flow in `test/unit/services/voip_call_service_test.dart`, `test/unit/services/fcm_service_test.dart`, and `test/integration/voip_flow_integration_test.dart`
- [X] T004 [P] Confirm existing Functions test targets for notification and logging behavior in `functions/test/fcm-notification-payload.test.js` and `functions/test/voip-notification-logging.test.js`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core lifecycle, payload, and platform prerequisites that MUST be complete before any user story work.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T005 Create consultation call-state repository interfaces and lifecycle use cases in `lib/features/patient/consultation/domain/repositories/` and `lib/features/patient/consultation/domain/usecases/`
- [X] T006 [P] Create Riverpod providers/notifiers for incoming call, connecting state, and cleanup suppression in `lib/features/patient/consultation/presentation/providers/`
- [X] T007 [P] Implement consultation call repository and payload restoration adapters in `lib/features/patient/consultation/data/repositories/`, `lib/core/services/voip_call_service.dart`, and `lib/core/services/fcm_service.dart`
- [X] T008 [P] Add structured call-log schema helpers and sanitized metadata enforcement in `lib/core/services/call_monitoring_service.dart` and `functions/index.js`
- [X] T009 [P] Register the Android `incoming_calls` notification channel at startup in `android/app/src/main/kotlin/com/example/elajtech/MainActivity.kt`
- [X] T010 [P] Configure iOS VoIP/CallKit bootstrap and app entry points in `ios/Runner/AppDelegate.swift`
- [X] T011 Add foundational lifecycle, payload, and contract tests in `test/unit/services/voip_call_service_test.dart` and `functions/test/fcm-notification-payload.test.js`

**Checkpoint**: Foundation ready - user story implementation can now begin.

---

## Phase 3: User Story 1 - Patient Receives and Answers Call in Background (Priority: P1) 🎯 MVP

**Goal**: Ensure a backgrounded patient receives native incoming-call UI, answers successfully, enters a brief connecting state, and joins without premature cleanup.

**Independent Test**: Doctor starts a call while patient app is in background; patient sees native incoming UI within 5 seconds, taps Answer, enters connecting state, joins Agora, and no `call ended` state appears on resume.

### Tests for User Story 1 ⚠️

- [X] T012 [P] [US1] Add background answer lifecycle regression tests in `test/unit/services/voip_call_service_test.dart`
- [X] T013 [P] [US1] Add background incoming-call delivery tests in `test/unit/services/fcm_service_test.dart`
- [X] T014 [P] [US1] Add background answer integration coverage in `test/integration/voip_flow_integration_test.dart`

### Implementation for User Story 1

- [X] T015 [US1] Route app lifecycle answer/connect behavior through providers and use cases in `lib/main.dart`, `lib/features/patient/consultation/presentation/providers/`, and `lib/features/patient/consultation/domain/usecases/`
- [X] T016 [US1] Preserve pending call credentials and native call context during background answer in `lib/features/patient/consultation/data/repositories/` and `lib/core/services/voip_call_service.dart`
- [X] T017 [US1] Convert Android incoming-call delivery to the background data-first path in `lib/core/services/fcm_service.dart` and `functions/index.js`
- [X] T018 [US1] Implement connecting-state handoff through Riverpod presentation state in `lib/features/patient/consultation/presentation/providers/`, `lib/features/patient/consultation/presentation/screens/incoming_call_screen.dart`, and `lib/features/patient/consultation/presentation/screens/agora_video_call_screen.dart`
- [X] T019 [US1] Enforce join success vs local join-failure messaging through domain/use-case boundaries in `lib/features/patient/consultation/domain/usecases/`, `lib/core/services/agora_service.dart`, and `lib/features/patient/consultation/presentation/screens/agora_video_call_screen.dart`

**Checkpoint**: User Story 1 should now be functional and testable on its own.

---

## Phase 4: User Story 2 - Patient Receives and Answers Call from Terminated App State (Priority: P1)

**Goal**: Ensure the patient can answer from a terminated state, restore payload data after cold start, and reach the live session without losing call context.

**Independent Test**: Force-quit the patient app; doctor starts a call; patient sees native incoming UI, taps Answer, app cold-starts into connecting state, restores payload data, and joins the correct active session.

### Tests for User Story 2 ⚠️

- [X] T020 [P] [US2] Add cold-start payload restoration tests in `test/unit/services/voip_call_service_test.dart`
- [X] T021 [P] [US2] Add terminated-state integration coverage in `test/integration/agora_call_happy_path_test.dart` and `test/integration/voip_flow_integration_test.dart`
- [X] T022 [P] [US2] Add callable payload contract coverage for cold-start fields in `functions/test/fcm-notification-payload.test.js`
- [X] T023 [P] [US2] Add iOS VoIP payload header and terminated-state delivery contract coverage in `functions/test/fcm-notification-payload.test.js`

### Implementation for User Story 2

- [X] T024 [US2] Implement active-call restoration from native extras through repository and restore-use-case paths in `lib/features/patient/consultation/data/repositories/`, `lib/features/patient/consultation/domain/usecases/`, and `lib/core/services/voip_call_service.dart`
- [X] T025 [US2] Add safe `agoraUid` coercion and null-safe credential restoration in `lib/core/services/voip_call_service.dart`
- [X] T026 [US2] Update app-start navigation to consume restored provider state in `lib/main.dart` and `lib/features/patient/consultation/presentation/providers/`
- [X] T027 [US2] Ensure Cloud Functions include the full cold-start restore payload and canonical state transition fields in `functions/index.js`
- [X] T028 [US2] Implement iOS VoIP payload/header requirements for terminated-state incoming-call delivery in `functions/index.js`
- [X] T029 [US2] Prevent backend timeout/end races during patient post-answer joining in `functions/index.js` and `lib/features/patient/consultation/domain/usecases/`
- [X] T030 [P] [US2] Add doctor-side unanswered join-window and premature-end regression coverage in `test/integration/agora_missed_call_rejoin_test.dart`, `test/integration/video_call_flow_test.dart`, and `functions/test/integration.test.js`

**Checkpoint**: User Stories 1 and 2 should both work independently.

---

## Phase 5: User Story 3 - Patient Receives Call in Foreground (Priority: P2)

**Goal**: Ensure foreground patients see incoming-call UI, enter the same connecting flow, and join without inconsistent behavior versus background or terminated states.

**Independent Test**: Patient app is open in foreground; doctor starts a call; patient sees incoming-call UI, taps Answer, enters connecting state, and reaches the video session without an intermediate `call ended` state.

### Tests for User Story 3 ⚠️

- [X] T031 [P] [US3] Add foreground incoming-call handling tests, including caller name and video-call indicator coverage, in `test/unit/services/fcm_service_test.dart` and `test/integration/video_call_flow_test.dart`
- [X] T032 [P] [US3] Add foreground call-flow integration coverage in `test/integration/video_call_flow_test.dart`

### Implementation for User Story 3

- [X] T033 [US3] Unify foreground incoming-call presentation with the native/fallback flow and ensure the UI shows caller name plus a video-call indicator in `lib/core/services/fcm_service.dart`, `lib/features/patient/consultation/presentation/providers/`, and `lib/features/patient/consultation/presentation/screens/incoming_call_screen.dart`
- [X] T034 [US3] Reuse the shared connecting-state and join outcome use cases for foreground answers in `lib/features/patient/consultation/domain/usecases/` and `lib/features/patient/consultation/presentation/screens/agora_video_call_screen.dart`
- [X] T035 [US3] Align foreground answer lifecycle suppression with shared provider and cleanup guards in `lib/main.dart`, `lib/features/patient/consultation/presentation/providers/`, and `lib/core/services/voip_call_service.dart`

**Checkpoint**: User Stories 1, 2, and 3 should be independently functional across app states.

---

## Phase 6: User Story 4 - Call Lifecycle Logging is Complete for Diagnosis (Priority: P2)

**Goal**: Ensure the full call attempt is remotely diagnosable through ordered, structured, sanitized lifecycle logs across app and backend boundaries.

**Independent Test**: Run a full call attempt and verify `call_logs` contains the applicable ordered canonical events: `callattempt`, `notification_dispatched`, `incoming_call_received`, `answer_accepted`, `active_call_restored`, `join_started`, `join_success|join_failure`, `cleanup_triggered`, `end_agora_call_invoked`, and `callended`.

### Tests for User Story 4 ⚠️

- [X] T036 [P] [US4] Add client-side structured logging tests in `test/unit/services/voip_logging_property_test.dart` and `test/unit/services/call_monitoring_service_test.dart`
- [X] T037 [P] [US4] Add Functions logging contract tests in `functions/test/voip-notification-logging.test.js`
- [X] T038 [P] [US4] Add end-to-end logging validation coverage in `test/integration/voip_flow_integration_test.dart`

### Implementation for User Story 4

- [X] T039 [US4] Implement sanitized client log emission for `incoming_call_received`, `answer_accepted`, `active_call_restored`, `join_started`, `join_success|join_failure`, `cleanup_triggered`, and `callended` in `lib/core/services/call_monitoring_service.dart`, `lib/core/services/voip_call_service.dart`, and `lib/features/patient/consultation/presentation/providers/`
- [X] T040 [US4] Implement backend log emission for `callattempt`, `notification_dispatched`, timeout transitions, `end_agora_call_invoked`, and `callended` in `functions/index.js`
- [X] T041 [US4] Align canonical event names and required fields with `specs/009-fix-incoming-call/contracts/call-lifecycle-contract.md` in `lib/core/services/call_monitoring_service.dart` and `functions/index.js`
- [X] T042 [US4] Enforce sanitized log metadata and Firestore `databaseId: 'elajtech'` targeting rules in `lib/core/services/call_monitoring_service.dart` and `functions/index.js`

**Checkpoint**: Logging should now be complete enough to diagnose any call-flow failure independently of UI testing.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Finish platform parity, edge-case handling, regression coverage, and validation.

- [X] T043 [P] Harden duplicate-event and fallback-notification handling in `lib/core/services/fcm_service.dart`, `lib/core/services/voip_call_service.dart`, and `functions/index.js`
- [X] T044 Update documentation and rollout notes in `specs/009-fix-incoming-call/quickstart.md`, `specs/009-fix-incoming-call/plan.md`, and `specs/009-fix-incoming-call/contracts/call-lifecycle-contract.md`
- [ ] T045 Run the full validation workflow from `specs/009-fix-incoming-call/quickstart.md` across Flutter tests, Functions tests, and real-device checks

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately.
- **Foundational (Phase 2)**: Depends on Setup completion - blocks all user stories.
- **User Story phases (Phase 3-6)**: Depend on Foundational completion.
- **Polish (Phase 7)**: Depends on all targeted user stories being complete.

### User Story Dependencies

- **US1 (P1)**: Starts after Foundational - establishes MVP background answer flow.
- **US2 (P1)**: Starts after Foundational and should build on shared payload/lifecycle work from US1 without blocking US1 completion.
- **US3 (P2)**: Starts after Foundational and reuses shared answer/join handling from US1.
- **US4 (P2)**: Starts after Foundational and can proceed alongside US2/US3 once shared logging helpers exist.

### Recommended Completion Order

1. Phase 1
2. Phase 2
3. Phase 3 (US1) MVP
4. Phase 4 (US2)
5. Phase 5 (US3)
6. Phase 6 (US4)
7. Phase 7

### Within Each User Story

- Write tests first and ensure they fail before implementation.
- Shared service and payload work before UI wiring.
- Cloud Functions/backend transitions before final end-to-end validation.
- Complete each story to its independent-test checkpoint before advancing priority.

### Parallel Opportunities

- `T003-T004` can run in parallel.
- `T006-T010` contain parallelizable foundational work across different files.
- In US1, `T012-T014` can run in parallel, followed by `T016` and `T017` in parallel after lifecycle guards begin.
- In US2, `T020-T023` can run in parallel, and `T025-T027` can proceed in parallel once payload restoration rules are fixed.
- In US4, `T036-T038` can run in parallel, then `T039-T042` can be split between app and backend owners.

---

## Parallel Example: User Story 1

```text
Task: "Add background answer lifecycle regression tests in test/unit/services/voip_call_service_test.dart"
Task: "Add background incoming-call delivery tests in test/unit/services/fcm_service_test.dart"
Task: "Add background answer integration coverage in test/integration/voip_flow_integration_test.dart"
```

## Parallel Example: User Story 2

```text
Task: "Add cold-start payload restoration tests in test/unit/services/voip_call_service_test.dart"
Task: "Add terminated-state integration coverage in test/integration/agora_call_happy_path_test.dart and test/integration/voip_flow_integration_test.dart"
Task: "Add callable payload contract coverage for cold-start fields in functions/test/fcm-notification-payload.test.js"
```

## Parallel Example: User Story 4

```text
Task: "Add client-side structured logging tests in test/unit/services/voip_logging_property_test.dart and test/unit/services/call_monitoring_service_test.dart"
Task: "Add Functions logging contract tests in functions/test/voip-notification-logging.test.js"
Task: "Add end-to-end logging validation coverage in test/integration/voip_flow_integration_test.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational.
3. Complete Phase 3: US1.
4. Validate the background incoming-call flow independently on a physical Android device and, if environment-ready, a physical iOS device.

### Incremental Delivery

1. Finish Setup + Foundational.
2. Deliver US1 as the first usable patient call-answer fix.
3. Add US2 to close terminated-state restoration gaps.
4. Add US3 to align foreground behavior.
5. Add US4 to complete remote diagnosability and rollout safety.

### Parallel Team Strategy

1. One owner handles Flutter lifecycle/payload work.
2. One owner handles Cloud Functions delivery/state/logging work.
3. One owner handles tests and platform bootstrap tasks.
4. Rejoin for real-device validation and final regression pass.

---

## Notes

- `[P]` tasks touch different files and can be parallelized safely.
- Every user story phase maps directly to a spec user story for traceability.
- Real-device validation is mandatory for background and terminated incoming-call UX.
- Do not persist raw Agora tokens, FCM tokens, or raw notification payloads in logs.
- Domain-layer use cases and Riverpod providers are required to satisfy the project constitution.
- iOS terminated-state native incoming-call support is not implementation-ready until VoIP/CallKit prerequisites and server payload headers are covered by tasks and validation.
