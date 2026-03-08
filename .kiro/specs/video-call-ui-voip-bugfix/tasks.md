# Implementation Plan: Video Call UI and VoIP Notification Critical Bugfixes

## Overview

This implementation plan addresses two critical bugs discovered during VoIP testing:

1. **Bug #1**: Doctor sees incorrect UI text ("waiting for doctor" instead of "waiting for patient")
2. **Bug #2**: Patient device does not receive incoming call notification

The implementation is divided into two phases:
- **Phase 1**: Fix UI text issue (quick win, low risk)
- **Phase 2**: Investigate and fix VoIP notification issue (more complex, requires investigation)

## Tasks

### Phase 1: Fix UI Text Issue (Bug #1)

- [x] 1. Add role detection logic to AgoraVideoCallScreen
  - Modify `_AgoraVideoCallScreenState` to add `_isDoctor` and `_otherPartyName` fields
  - In `initState()`, get current user ID from `FirebaseAuth.instance.currentUser?.uid`
  - Compare current user ID with `appointment.doctorId` to determine if user is doctor
  - Set `_otherPartyName` to `appointment.patientName` if doctor, `appointment.doctorName` if patient
  - _Requirements: 1.5, 1.6_

- [x] 1.1 Write unit tests for role determination logic
  - **Property 1: Role Determination Correctness**
  - **Validates: Requirements 1.5**
  - Test case: Current user is doctor → `_isDoctor` should be true
  - Test case: Current user is patient → `_isDoctor` should be false
  - Test case: Current user is neither → should default to patient role (false)
  - Use property-based testing with 100 iterations
  - _Requirements: 1.5_

- [x] 2. Update waiting room UI text based on user role
  - In `_remoteVideo()` method, replace hardcoded "جاري الاتصال بالطبيب..." with conditional text
  - If `_isDoctor`, display "جاري الاتصال بالمريض..." (Calling patient...)
  - If not `_isDoctor`, display "جاري الاتصال بالطبيب..." (Calling doctor...)
  - Replace hardcoded sub-message with conditional text
  - If `_isDoctor`, display "في انتظار رد $_otherPartyName..." (Waiting for [name] to answer...)
  - If not `_isDoctor`, display "يرجى الانتظار، سيتم الاتصال بك قريباً" (Please wait, you will be called soon)
  - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [x] 2.1 Write widget tests for UI text display
  - Test case: Doctor role shows "جاري الاتصال بالمريض..." when no remote user
  - Test case: Doctor role shows "في انتظار رد [patient name]..." with actual patient name
  - Test case: Patient role shows "جاري الاتصال بالطبيب..." when no remote user
  - Test case: Patient role shows "يرجى الانتظار، سيتم الاتصال بك قريباً"
  - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [x] 3. Manual testing of UI text fix
  - Test as doctor: Initiate call, verify "جاري الاتصال بالمريض..." appears
  - Test as doctor: Verify patient name appears in waiting message
  - Test as patient: Receive call, verify "جاري الاتصال بالطبيب..." appears
  - Test as patient: Verify "يرجى الانتظار، سيتم الاتصال بك قريباً" appears
  - Take screenshots for documentation
  - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [x] 4. Checkpoint - Ensure Phase 1 tests pass
  - Ensure all tests pass, ask the user if questions arise.

### Phase 2: Investigate and Fix VoIP Notification Issue (Bug #2)

- [x] 5. Add comprehensive logging to Cloud Functions
  - In `sendVoIPNotification()` function, add console.log for FCM token retrieval
  - Log: "📱 Retrieving FCM token for patient: ${patientId}"
  - Log: "✅ FCM token retrieved successfully" or "❌ FCM token missing"
  - Add console.log for FCM notification send attempt
  - Log: "📤 Sending VoIP notification" with appointmentId, doctorName, channelName
  - Log: "✅ VoIP notification sent successfully: ${response}" or "❌ Error sending VoIP notification"
  - Add logCallEvent for successful notification send with eventType 'voip_notification_sent'
  - Add logCallEvent for FCM token missing with errorCode 'fcm_token_missing'
  - Include metadata with databaseId: 'elajtech' in all log events
  - Add "[DB: elajtech]" prefix to all error messages for debugging
  - _Requirements: 2.7, 2.8, 2.11, 5.1, 5.2, 7.4_

- [x] 5.1 Write unit tests for Cloud Functions logging
  - Test case: FCM token missing → logs error with code 'fcm_token_missing'
  - Test case: FCM send fails → logs error with code 'voip_notification_failed'
  - Test case: FCM send succeeds → logs event with type 'voip_notification_sent'
  - Verify all logs include databaseId: 'elajtech' in metadata
  - Verify error messages include "[DB: elajtech]" prefix
  - _Requirements: 2.7, 2.8, 2.11, 5.1, 5.2, 7.4_

- [x] 5.2 Add FCM Service Dependency Injection (HIGH PRIORITY)
  - Review `lib/core/di/injection.dart` and `lib/core/di/firebase_module.dart`
  - Verify `FCMService` is registered with `@injectable` or `@lazySingleton`
  - Verify `FirebaseFirestore` instance is injected via constructor (not direct instantiation)
  - Update `FCMService` constructor to accept `FirebaseFirestore` parameter
  - Ensure `FirebaseFirestore.instanceFor(databaseId: 'elajtech')` is provided by `firebase_module.dart`
  - Run build_runner: `flutter pub run build_runner build --delete-conflicting-outputs`
  - Verify no direct calls to `FirebaseFirestore.instanceFor()` in `FCMService`
  - _Requirements: 3.6, 3.7, 3.8_
  - _Reference: CONTRIBUTING.md - Firestore Database Configuration Rule_

- [x] 6. Verify FCM token storage in FCMService
  - Review `FCMService.initialize()` method
  - Verify `_messaging.getToken()` is called on initialization
  - Verify token is saved to Firestore via `_saveFCMToken()`
  - Verify `onTokenRefresh` listener is set up
  - Add console logs: "✅ FCM Token received" and "🔄 FCM Token refreshed"
  - In `_saveFCMToken()`, verify injected `FirebaseFirestore` instance is used (not direct instantiation)
  - Verify token is saved to users collection with fields: fcmToken, fcmTokenUpdatedAt
  - Add console logs: "✅ FCM token saved to Firestore for user: $userId"
  - _Requirements: 3.1, 3.2, 3.3, 3.6_

- [x] 6.1 Write unit tests for FCM token storage
  - Test case: Token received → saved to Firestore users collection
  - Test case: Token refresh → Firestore document updated
  - Test case: Uses elajtech database ID (not default database)
  - Mock FirebaseFirestore and verify correct database ID used
  - _Requirements: 3.1, 3.2, 3.3, 3.6_

- [x] 7. Verify FCM notification payload structure
  - Review `sendVoIPNotification()` in Cloud Functions
  - Verify message object includes: token, notification (title, body), data (type, appointmentId, doctorName, agoraChannelName, agoraToken, agoraUid)
  - Verify android.priority is 'high' and notification.priority is 'max'
  - Verify apns.headers['apns-priority'] is '10'
  - Verify data.type is 'incoming_call'
  - Verify all Agora fields are included and converted to strings
  - _Requirements: 2.2, 2.3_

- [x] 7.1 Write property test for FCM notification payload
  - **Property 3: FCM Notification Payload Completeness**
  - **Validates: Requirements 2.2, 2.3**
  - For any valid startAgoraCall request, verify payload includes all required fields
  - Test with 100 iterations using property-based testing
  - Verify: appointmentId, doctorName, agoraChannelName, agoraToken, agoraUid
  - Verify: type='incoming_call', android.priority='high', apns.headers['apns-priority']='10'
  - Mock admin.messaging().send() and verify payload structure
  - _Requirements: 2.2, 2.3_

- [x] 8. Verify FCM message handler processes incoming_call notifications
  - Review `FCMService` background message handler
  - Verify handler checks for `data['type'] == 'incoming_call'`
  - Verify handler extracts: appointmentId, doctorName, agoraChannelName, agoraToken, agoraUid
  - Verify handler calls `VoIPCallService().showIncomingCall()` with extracted data
  - Add console log: "📱 Incoming call notification received for appointment: $appointmentId"
  - _Requirements: 2.4_

- [x] 8.1 Write unit tests for FCM message handler
  - Test case: Incoming call notification → VoIPCallService.showIncomingCall() called
  - Test case: Correct data extracted from notification payload
  - Test case: Non-incoming-call notifications → showIncomingCall() not called
  - Mock VoIPCallService and verify method called with correct parameters
  - _Requirements: 2.4_

- [x] 9. Test VoIP notification delivery end-to-end
  - Sign in as patient on test device
  - Verify FCM token saved in Firestore users collection (check via Firebase Console)
  - Sign in as doctor on another device
  - Initiate video call from doctor device
  - Verify Cloud Functions logs show: "📱 Retrieving FCM token", "✅ FCM token retrieved", "📤 Sending VoIP notification", "✅ VoIP notification sent"
  - Verify patient device receives notification (check device logs)
  - Verify CallKit (iOS) or ConnectionService (Android) displays incoming call UI
  - Accept call from patient device
  - Verify navigation to AgoraVideoCallScreen
  - Verify video call connects successfully
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6_

- [x] 10. Test VoIP notification in all app states
  - Test with patient app in foreground → verify incoming call UI appears
  - Test with patient app in background → verify incoming call UI appears
  - Test with patient app terminated (closed completely) → verify incoming call UI appears
  - Test on both iOS and Android devices
  - Document any differences in behavior between platforms
  - _Requirements: 2.5, 6.7_

- [x] 11. Implement graceful error handling for notification failures
  - In Cloud Functions `startAgoraCall`, wrap `sendVoIPNotification()` in try-catch
  - If notification fails, log error but do NOT throw exception
  - Ensure function returns success to doctor even if notification fails
  - Log error with code 'voip_notification_failed' to call_logs
  - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [x] 11.1 Write property test for error handling
  - **Property 6: Graceful VoIP Notification Failure Handling**
  - **Validates: Requirements 4.1, 4.2, 4.3, 4.4**
  - For any VoIP notification failure (missing FCM token or send failure), verify graceful handling
  - Test with 100 iterations using property-based testing
  - Test case: FCM token missing → function returns success, error logged with code 'fcm_token_missing'
  - Test case: FCM send fails → function returns success, error logged with code 'voip_notification_failed'
  - Test case: Patient document not found → function returns success, error logged
  - Verify function does not throw exception in any error scenario
  - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [x] 12. Add timeout handling to doctor's video call screen
  - In `AgoraVideoCallScreen`, add Timer that triggers after 60 seconds if no remote user joins
  - When timeout occurs, display dialog: "لم يرد المريض على المكالمة" (Patient did not answer the call)
  - Provide options: "إعادة المحاولة" (Retry) and "إلغاء" (Cancel)
  - If Retry, call `startAgoraCall` again
  - If Cancel, leave channel and navigate back
  - _Requirements: 4.5, 4.6_

- [x] 12.1 Write property test for timeout handling
  - **Property 7: Timeout and Retry Mechanism**
  - **Validates: Requirements 4.5, 4.6, 4.7, 4.8, 4.9, 4.10**
  - For any video call where remote user does not join, verify timeout and retry behavior
  - Test with 100 iterations using property-based testing
  - Test case: No remote user after 60 seconds → timeout dialog appears
  - Test case: Timeout dialog has Retry and Cancel buttons
  - Test case: Retry button calls startAgoraCall again with exponential backoff (2s, 4s, 8s)
  - Test case: Maximum 3 retry attempts enforced
  - Test case: Timeout events logged to call_logs with eventType 'call_timeout'
  - Test case: Cancel button leaves channel and navigates back
  - _Requirements: 4.5, 4.6, 4.7, 4.8, 4.9, 4.10_

- [x] 13. Add VoIP event logging to client-side services
  - In `FCMService`, log notification receipt: "📱 FCM notification received: type=${data['type']}"
  - In `VoIPCallService.showIncomingCall()`, log call display: "📱 Displaying incoming call UI for appointment: $appointmentId"
  - In VoIP call acceptance handler, log: "✅ Call accepted by user"
  - In VoIP call decline handler, log: "❌ Call declined by user"
  - Write all logs to call_logs collection in Firestore (elajtech database)
  - Include appointmentId, userId, timestamp in all log entries
  - _Requirements: 5.3, 5.4, 5.5, 5.6, 5.7_

- [x] 13.1 Write property test for VoIP logging completeness
  - **Property 8: Comprehensive VoIP Event Logging**
  - **Validates: Requirements 5.6, 5.7**
  - For all VoIP-related events, verify logs include required fields and use correct database
  - Test with 100 iterations using property-based testing
  - Generate random log events (call_attempt, call_started, voip_notification_sent, call_error, call_timeout)
  - Verify every log entry includes: appointmentId, userId, timestamp
  - Verify all logs written to call_logs collection in elajtech database
  - Mock Firestore and verify correct database ID used
  - _Requirements: 5.6, 5.7_

- [x] 13.2 Write property test for error message database context
  - **Property 9: Error Message Database Context**
  - **Validates: Requirements 2.11, 7.4**
  - For all error logs written by Cloud Functions, verify database context included
  - Test with 100 iterations using property-based testing
  - Verify error messages include "[DB: elajtech]" prefix
  - Verify metadata includes databaseId field set to 'elajtech'
  - Test with various error scenarios (missing appointment, FCM failures, etc.)
  - _Requirements: 2.11, 7.4_

- [x] 14. Update UserModel to include FCM token fields
  - Add `String? fcmToken` field to UserModel
  - Add `@JsonKey(name: 'fcmTokenUpdatedAt') DateTime? fcmTokenUpdatedAt` field
  - Run build_runner: `flutter pub run build_runner build --delete-conflicting-outputs`
  - Verify generated code compiles without errors
  - _Requirements: 3.4, 3.5_

- [x] 14.1 Write property test for FCM token persistence
  - **Property 5: FCM Token Persistence with Correct Database**
  - **Validates: Requirements 3.2, 3.3, 3.6, 3.9**
  - For any FCM token received or refreshed, verify correct persistence
  - Test with 100 iterations using property-based testing
  - Verify token written to users collection in elajtech database
  - Verify both fcmToken and fcmTokenUpdatedAt fields included
  - Verify FieldValue.serverTimestamp() used for timestamp
  - Verify FirebaseFirestore.instanceFor with databaseId: 'elajtech' used
  - _Requirements: 3.2, 3.3, 3.6, 3.9_

- [ ] 15. Checkpoint - Ensure Phase 2 tests pass
  - Ensure all tests pass, ask the user if questions arise.

### Phase 3: Integration Testing and Deployment

- [x] 16. Run full test suite and verify Test Persistence Rule
  - Run all tests: `flutter test`
  - **CRITICAL**: Verify output shows "All tests passing (664+/664+)"
  - Run static analysis: `flutter analyze`
  - **CRITICAL**: Verify "No issues found"
  - Check deprecated APIs: `flutter analyze lib/ | grep "deprecated_member_use"`
  - **CRITICAL**: Verify no output (zero deprecated API warnings)
  - Generate coverage report: `flutter test --coverage`
  - Verify coverage maintained or improved (target: 70%+)
  - **BLOCKER**: If any test fails or analyzer shows issues, STOP and fix before proceeding
  - _Requirements: All_
  - _Reference: README.md - Testing - Test Persistence Rule_

- [x] 16.0 Write property test for database targeting consistency
  - **Property 4: Database Targeting Consistency**
  - **Validates: Requirements 2.1, 2.9, 2.10**
  - For all Firestore operations in Cloud Functions, verify elajtech database targeted
  - Test with 100 iterations using property-based testing
  - Verify db.settings({ databaseId: 'elajtech' }) applied after initialization
  - Test with various collection names (users, appointments, call_logs)
  - Verify no operations target default database
  - _Requirements: 2.1, 2.9, 2.10_

- [x] 16.1 Write property test for environment variable fallback
  - **Property 10: Environment Variable Fallback**
  - **Validates: Requirements 7.1, 7.3**
  - For any Cloud Function execution, verify Agora credentials loaded correctly
  - Test with 100 iterations using property-based testing
  - Test case: process.env variables set → credentials loaded from env
  - Test case: process.env variables missing → fallback to functions.config()
  - Verify backward compatibility maintained
  - _Requirements: 7.1, 7.3_

- [x] 16.2 Set up integration test environment
  - Verify Firebase CLI installed: `firebase --version`
  - Verify Java 21+ installed: `java -version` (required for Cloud Functions emulator)
  - Initialize emulators (if not done): `firebase init emulators`
  - Configure emulator ports in `firebase.json`:
    - Firestore: 8080
    - Authentication: 9099
    - Functions: 5001
    - Emulator UI: 4000
  - Start emulators in background: `firebase emulators:start &`
  - Verify emulators running:
    - Firestore: http://localhost:8080
    - Authentication: http://localhost:9099
    - Functions: http://localhost:5001
    - Emulator UI: http://localhost:4000
  - Create `test/helpers/integration_test_config.dart` helper with emulator connection logic
  - _Requirements: 6.1, 6.2, 6.3_
  - _Reference: README.md - Firebase Emulator Setup_

- [x] 16.3 Write integration test for complete VoIP flow
  - Create `test/helpers/integration_test_config.dart` helper with emulator connection logic
  - _Requirements: 6.1, 6.2, 6.3_
  - _Reference: README.md - Firebase Emulator Setup_

- [x] 16.1 Write integration test for complete VoIP flow
  - Test: Doctor initiates call → Patient receives notification → Patient accepts → Video call connects
  - Use Firebase Emulator for Firestore and Cloud Functions (configured in Task 16.0)
- [x] 16.3 Write integration test for complete VoIP flow
  - Test: Doctor initiates call → Patient receives notification → Patient accepts → Video call connects
  - Use Firebase Emulator for Firestore and Cloud Functions (configured in Task 16.2)
  - Mock Agora service for video connection
  - Verify all steps complete successfully
  - Verify database isolation (elajtech database used, not default)
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 6.8, 6.12_

- [ ] 17. Manual testing on real devices
  - Test on iOS device (iPhone)
  - Test on Android device
  - Test all scenarios from test plan
  - Document any issues found
  - Take screenshots/videos for documentation
  - _Requirements: All_

- [ ] 18. Deploy Cloud Functions to staging
  - Deploy functions: `firebase deploy --only functions --project elajtech-staging`
  - Verify deployment successful
  - Test startAgoraCall function in staging
  - Monitor Cloud Functions logs for errors
  - _Requirements: 2.1, 2.2, 2.3, 2.7, 2.8_

- [ ] 19. Deploy Flutter app to staging
  - Build app: `flutter build apk --release` (Android) or `flutter build ios --release` (iOS)
  - Deploy to Firebase App Distribution or TestFlight
  - Notify QA team for testing
  - _Requirements: All_

- [ ] 20. QA verification in staging
  - QA team tests all scenarios
  - QA team verifies both bugs are fixed
  - QA team tests edge cases and error scenarios
  - Document any issues found
  - Fix issues if found and re-test
  - _Requirements: All_

- [ ] 21. Prepare rollback plan (before production deployment)
  - Document current Cloud Functions version hash: `git rev-parse HEAD`
  - Document current Flutter app version (build number from pubspec.yaml)
  - Prepare rollback scripts:
    ```bash
    # Cloud Functions rollback
    git checkout <previous-version-hash> functions/index.js
    firebase deploy --only functions --project elajtech
    
    # Flutter app rollback (if needed)
    # - Google Play: Halt rollout and rollback to previous version
    # - App Store: Submit previous build for expedited review
    ```
  - Test rollback procedure in staging environment
  - Verify rollback restores previous functionality
  - Document rollback steps in deployment runbook
  - Notify on-call engineer of deployment schedule
  - _Requirements: All_
  - _Reference: Design Document - Rollback Plan_

- [x] 21.1 Deploy to production
  - Deploy Cloud Functions: `firebase deploy --only functions --project elajtech`
  - Deploy Flutter app to App Store and Google Play
  - Monitor production logs for 24 hours
  - Monitor VoIP notification success rate
  - Monitor call initiation success rate
  - Keep rollback plan ready (Task 21)
  - _Requirements: All_

- [ ] 22. Post-deployment monitoring
  - Query call_logs for voip_notification_sent vs voip_notification_failed
  - Calculate VoIP notification success rate (target: > 95%)
  - Query users collection for FCM token coverage (target: > 98%)
  - Monitor patient join rate (target: > 90% within 60 seconds)
  - Set up alerts for critical metrics
  - _Requirements: All_

- [ ] 23. Final checkpoint - Verify production deployment
  - Ensure all metrics are within target ranges, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional test tasks and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties (100 iterations each)
- Unit tests validate specific examples and edge cases
- Integration tests validate end-to-end flows

## Estimated Timeline

- **Phase 1 (UI Text Fix)**: 2-3 hours
- **Phase 2 (VoIP Investigation & Fix)**: 6-8 hours
- **Phase 3 (Integration & Deployment)**: 4-6 hours
- **Total**: 12-17 hours

## Risk Assessment

- **Phase 1**: LOW risk - Simple UI change, well-tested
- **Phase 2**: MEDIUM risk - Requires investigation, multiple components involved
- **Phase 3**: LOW risk - Standard deployment process

## Success Criteria

- ✅ Doctor sees "جاري الاتصال بالمريض..." when initiating call
- ✅ Patient sees "جاري الاتصال بالطبيب..." when receiving call
- ✅ Patient device receives incoming call notification in all app states
- ✅ CallKit/ConnectionService displays incoming call UI
- ✅ VoIP notification success rate > 95%
- ✅ All 664+ existing tests still pass
- ✅ New tests added for bugfixes

## Document Refresh Summary (2026-02-16)

This tasks document was refreshed to align with the complete design document (1395 lines) and all 10 correctness properties.

**What Was Refreshed:**

1. **Phase 1 (Complete)**: All tasks marked [x] - UI text fix is complete
2. **Phase 2 Tasks Updated**:
   - Task 5: Added "[DB: elajtech]" prefix requirement for error messages
   - Task 5.1: Added verification of database context in error messages
   - Task 5.2: Added (HIGH PRIORITY) FCM Service Dependency Injection task
   - Task 7.1: Converted to property test (Property 3: FCM Notification Payload Completeness)
   - Task 11.1: Converted to property test (Property 6: Graceful VoIP Notification Failure Handling)
   - Task 12.1: Converted to property test (Property 7: Timeout and Retry Mechanism) with exponential backoff
   - Task 13.1: Converted to property test (Property 8: Comprehensive VoIP Event Logging)
   - Task 13.2: Converted to property test (Property 9: Error Message Database Context)
   - Task 14.1: Added property test (Property 5: FCM Token Persistence with Correct Database)

3. **Phase 3 Tasks Updated**:
   - Task 16.0: Added property test (Property 4: Database Targeting Consistency)
   - Task 16.1: Added property test (Property 10: Environment Variable Fallback)
   - Task 16.2: Renamed from 16.0, kept integration test environment setup
   - Task 16.3: Renamed from 16.1, added database isolation verification

**All 10 Correctness Properties Now Referenced:**
- Property 1: Role-Based UI Text Display (Task 1.1)
- Property 2: Role-Based UI Sub-Message Display (Task 2.1)
- Property 3: FCM Notification Payload Completeness (Task 7.1)
- Property 4: Database Targeting Consistency (Task 16.0)
- Property 5: FCM Token Persistence with Correct Database (Task 14.1)
- Property 6: Graceful VoIP Notification Failure Handling (Task 11.1)
- Property 7: Timeout and Retry Mechanism (Task 12.1)
- Property 8: Comprehensive VoIP Event Logging (Task 13.1)
- Property 9: Error Message Database Context (Task 13.2)
- Property 10: Environment Variable Fallback (Task 16.1)

**Key Improvements:**
- All property-based tests now explicitly reference design properties
- All property tests configured for 100 iterations
- Database context ("[DB: elajtech]") added to all error logging requirements
- FCM Service DI task added to ensure correct database usage
- Integration test setup clarified with emulator configuration
- All tasks maintain traceability to specific requirements
