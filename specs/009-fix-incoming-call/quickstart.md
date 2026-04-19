# Quickstart: Fix Patient Incoming Call — Not Ringing and Auto-Ended on Answer

## 1. Prerequisites

- Flutter SDK compatible with Dart `^3.10.4`
- Node.js `20`
- Firebase project and Functions access for `elajtech-fc804`
- Firestore access to `databaseId: 'elajtech'`
- One physical Android device and one physical iOS device
- iOS VoIP/CallKit prerequisites configured before full-scope validation

## 2. Install dependencies

### Flutter app

```powershell
flutter pub get
```

### Cloud Functions

```powershell
npm install
```

Run from: `C:\Users\moham\Desktop\androcare\elajtech\elajtech\functions`

## 3. Automated validation

### Flutter unit and integration coverage

```powershell
flutter test test/unit/services/voip_call_service_test.dart
flutter test test/unit/services/fcm_service_test.dart
flutter test test/unit/services/voip_logging_property_test.dart
flutter test test/unit/services/call_monitoring_service_test.dart
flutter test test/integration/agora_call_happy_path_test.dart
flutter test test/integration/agora_missed_call_rejoin_test.dart
flutter test test/integration/voip_flow_integration_test.dart
flutter test test/integration/video_call_flow_test.dart
```

### Cloud Functions coverage

```powershell
npm run test:standalone
```

Run from: `C:\Users\moham\Desktop\androcare\elajtech\elajtech\functions`

### What each test suite validates

| Suite | Validates |
|-------|-----------|
| `voip_call_service_test.dart` | Lifecycle guards, payload restoration, `answer_accepted` / `active_call_restored` / `cleanup_triggered` / `callended` canonical logging |
| `fcm_service_test.dart` | Foreground incoming-call path (T031): caller name, video indicator, `incoming_call_received` event type, duplicate-call guard |
| `voip_logging_property_test.dart` | All 11 canonical event names, sanitization of `agoraToken` from metadata, property-based field coverage |
| `call_monitoring_service_test.dart` | `logStructuredEvent` write path, metadata sanitization, `join_failure` / `cleanup_triggered` schema |
| `video_call_flow_test.dart` | Foreground integration (T032): payload mapping, connecting-state isolation, cleanup-blocked invariant |
| `voip_flow_integration_test.dart` | E2E logging ordering (T038): canonical sequence, mandatory vs conditional events, token exclusion |
| `voip-notification-logging.test.js` | Cloud Functions canonical event names (T037): `callattempt`, `notification_dispatched`, `end_agora_call_invoked`, `callended`, token exclusion |

## 4. Manual real-device validation

Validate all of the following on physical devices only:

1. Android foreground, background, and terminated incoming-call presentation
2. iOS foreground, background, and terminated incoming-call presentation
3. Answer flow enters connecting state, not immediate `call ended`
4. Join success occurs before the 40-second timeout when doctor remains connected
5. Local join failure shows `Unable to connect to the call. Please try again.`
6. Doctor-side or timeout-driven terminal paths show `The call has ended.`
7. Cleanup does not run during answer/connect transition
8. `call_logs` contains the expected ordered structured events

## 5. Rollout gate

Do not treat the feature as complete until:

- Android and iOS real-device scenarios pass
- iOS VoIP/CallKit prerequisites are confirmed if terminated-state native incoming UI is part of release scope
- Firestore logging is verified to exclude raw tokens and sensitive payload data
- Doctor-side start/end flows show no regression
- All automated Flutter tests pass (`flutter test test/unit/services/ test/integration/`)
- All Cloud Functions Jest tests pass (`npm run test:standalone`)
- Duplicate-call deduplication verified: rapid repeated pushes for the same appointment do not produce duplicate call screens
- `call_logs` event sequence verified in a real call: `callattempt` → `notification_dispatched` → `incoming_call_received` → `answer_accepted` → `join_started` → `join_success` → `callended`
- `FCMService.resetCallDeduplication()` is called from `VoIPCallService.cleanupAfterCall()` or equivalent lifecycle hook so that doctor retry calls are not silently dropped
