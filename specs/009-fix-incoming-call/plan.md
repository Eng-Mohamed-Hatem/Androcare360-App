# Implementation Plan: Fix Patient Incoming Call — Not Ringing and Auto-Ended on Answer

**Branch**: `009-fix-incoming-call` | **Date**: 2026-04-01 | **Spec**: `C:\Users\moham\Desktop\androcare\elajtech\elajtech\specs\009-fix-incoming-call\spec.md`
**Input**: Feature specification from `C:\Users\moham\Desktop\androcare\elajtech\elajtech\specs\009-fix-incoming-call\spec.md`

## Summary

Fix the patient incoming-call flow by making call-state authority backend-owned, preserving call credentials across background and cold-start transitions, preventing lifecycle cleanup during the answer-to-join window, and aligning Android/iOS incoming-call delivery with platform-native constraints. The implementation spans Flutter patient call services and screens, Firebase Cloud Functions, Android notification channel setup, iOS VoIP/CallKit prerequisites, and structured call lifecycle logging with automated coverage plus real-device validation.

## Technical Context

**Language/Version**: Dart SDK `^3.10.4` / Flutter 3.x mobile app, Node.js `20` Cloud Functions  
**Primary Dependencies**: `flutter_riverpod`, `firebase_messaging`, `cloud_functions`, `cloud_firestore`, `agora_rtc_engine`, `flutter_callkit_incoming`, `firebase_crashlytics`, `firebase-admin`, `firebase-functions`, `agora-access-token`  
**Storage**: Firestore (`databaseId: 'elajtech'`), native call-framework extras/payload storage, Crashlytics/console logs for transient diagnostics  
**Testing**: Flutter `flutter_test` unit tests, Flutter `integration_test`, selective golden tests, Jest standalone/emulator tests for Cloud Functions  
**Target Platform**: Android API 29+, iOS 15+, Firebase Cloud Functions in `europe-west1`  
**Project Type**: Mobile app plus serverless backend  
**Performance Goals**: Native incoming-call UI within 5 seconds in 95% of stable-network test runs; answered flows enter connecting state immediately and resolve to join success or user-visible failure within 40 seconds  
**Constraints**: HIPAA-like data minimization in logs; backend must own canonical call-state transitions; cleanup must not run during answer/connect window; Android requires a pre-registered high-importance `incoming_calls` channel; iOS terminated-state native calling requires VoIP-capable APNs/PushKit/CallKit configuration, entitlements, and server payload headers; real-device validation is mandatory  
**Scale/Scope**: One telemedicine feature spanning Flutter patient call flow, native Android/iOS call presentation, Cloud Functions call start/end handling, Firestore call logs, and existing call-related automated tests

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Layering and architecture**: PASS. Planned changes stay within existing mobile presentation/service structure and Cloud Functions backend boundaries; no UI-to-data shortcut is introduced.
- **State management discipline**: PASS. UI keeps transient presentation state only; canonical lifecycle ownership moves to validated backend state instead of widget or lifecycle callbacks.
- **Layer implementation note**: PASS only if implementation tasks introduce or reuse Riverpod-managed providers and domain-layer use cases for answer, restore, join, end, and lifecycle logging flows instead of placing business rules directly in widgets or app lifecycle methods.
- **Security and medical data protection**: PASS with guardrails. Persistent logs will exclude raw Agora tokens, FCM tokens, raw notification payloads, and unnecessary PHI; Firestore operations remain on `databaseId: 'elajtech'`.
- **Testing and reliability**: PASS. Plan includes Flutter unit/integration coverage, Jest coverage for callable/payload behavior, and mandatory physical-device validation for Android and iOS incoming-call UX.
- **Telemedicine lifecycle governance**: PASS after design. This plan defines one authoritative lifecycle, backend-owned timeout decisions, cleanup guard boundaries, fallback behavior, and rollout/validation gates before implementation.
- **Decision governance**: PASS. iOS terminated-state native call presentation is in scope for this feature and is treated as a prerequisite-gated requirement: implementation and release remain blocked until VoIP/PushKit/CallKit capability, entitlements, and server payload headers are correctly configured and validated on real devices.

## Project Structure

### Documentation (this feature)

```text
specs/009-fix-incoming-call/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── call-lifecycle-contract.md
└── tasks.md
```

### Source Code (repository root)

```text
functions/
├── index.js
└── test/

lib/
├── main.dart
├── core/
│   └── services/
│       ├── agora_service.dart
│       ├── call_monitoring_service.dart
│       ├── fcm_service.dart
│       ├── video_consultation_service.dart
│       └── voip_call_service.dart
├── features/
│   └── patient/
│       └── consultation/
│           ├── data/
│           │   ├── datasources/
│           │   └── repositories/
│           ├── domain/
│           │   ├── repositories/
│           │   └── usecases/
│           └── presentation/
│               ├── providers/
│               └── screens/
│                   ├── agora_video_call_screen.dart
│                   └── incoming_call_screen.dart
└── shared/
    └── models/
        └── appointment_model.dart

android/app/src/main/kotlin/com/example/elajtech/
└── MainActivity.kt

ios/Runner/
└── AppDelegate.swift

test/
├── integration/
│   ├── agora_call_happy_path_test.dart
│   ├── agora_missed_call_rejoin_test.dart
│   ├── video_call_flow_test.dart
│   └── voip_flow_integration_test.dart
└── unit/
    └── services/
        ├── agora_service_test.dart
        ├── call_monitoring_service_test.dart
        ├── fcm_service_test.dart
        ├── voip_call_service_test.dart
        └── voip_logging_property_test.dart
```

**Structure Decision**: Use the existing Flutter mobile app plus Firebase Cloud Functions layout, but keep constitution-compliant layering explicit:
- **Presentation**: screens and Riverpod providers/notifiers in `lib/features/patient/consultation/presentation/`
- **Domain**: call lifecycle use cases and repository interfaces in `lib/features/patient/consultation/domain/`
- **Data**: repository implementations and data sources integrating Agora, Firestore, Cloud Functions, FCM, and native call APIs in `lib/features/patient/consultation/data/` and `lib/core/services/`
Platform bootstrap changes stay in `android/` and `ios/`, and backend lifecycle/state validation stays in `functions/index.js` with supporting Jest tests in `functions/test/`.

## Phase 0 Research Output

- `research.md` resolves lifecycle authority, push delivery strategy, logging boundaries, test strategy, and contract scope.

## Phase 1 Design Output

- `data-model.md` defines canonical call-state ownership, persisted entities, transient client context, validation rules, and lifecycle transitions.
- `contracts/call-lifecycle-contract.md` defines callable-function and structured-log contracts for this feature.
- `quickstart.md` defines local setup, automated checks, and real-device validation steps.

## Post-Design Constitution Check

- **Authoritative lifecycle defined**: PASS. Canonical states are backend-owned; client lifecycle callbacks cannot end consultations.
- **Timeout, retry, fallback, rollout documented**: PASS. 40-second post-answer join timeout, notification/native UI fallback, duplicate-event/idempotency handling, and staged real-device rollout validation are all captured in the generated artifacts.
- **Sensitive data minimization preserved**: PASS. Contracted logs use correlation IDs, state, platform/app-state, and sanitized reasons only.
- **Test obligations satisfied**: PASS. Design requires automated coverage for client lifecycle boundaries and callable-function behavior plus physical-device validation for native incoming-call UX.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
