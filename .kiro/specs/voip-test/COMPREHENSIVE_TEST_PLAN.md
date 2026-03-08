# VoIP Video Call System - Comprehensive Test Plan

**Project**: AndroCare360  
**Component**: Video Call System  
**Version**: 1.0  
**Date**: 2026-02-16  
**Status**: In Progress

---

## 1. Executive Summary

### 1.1 Testing Objectives

The primary objective of this comprehensive testing initiative is to validate the complete VoIP video call system for the AndroCare360 telemedicine platform. This testing will ensure that doctors and patients can reliably conduct video consultations with high quality and minimal technical issues.

**Key Objectives:**

1. **Validate Complete Call Workflow**: Ensure the entire call flow from initiation through completion works reliably across all supported scenarios
2. **Verify VoIP Notification Reliability**: Confirm that patients receive incoming call notifications across all app states (foreground, background, terminated, locked)
3. **Ensure Call Quality**: Validate video and audio quality meets minimum requirements (640x480 @ 15fps, clear audio)
4. **Test Network Resilience**: Verify the system handles various network conditions and transitions gracefully
5. **Validate Error Handling**: Ensure all error scenarios are handled appropriately with clear user feedback
6. **Measure Performance**: Collect metrics to validate system performance against requirements
7. **Cross-Platform Validation**: Ensure consistent behavior across Android and iOS platforms

### 1.2 Scope

#### In Scope

**Core Functionality:**
- Call initiation flows (doctor-initiated)
- VoIP notification delivery (FCM with CallKit/ConnectionService)
- Call acceptance and connection establishment
- Video and audio streaming (Agora RTC Engine)
- Call controls (mute, video toggle, camera switch, end call)
- Call decline and timeout handling
- Call completion and appointment status updates

**Network Scenarios:**
- WiFi connectivity (high-speed)
- Mobile data connectivity (4G/LTE)
- Slow network connectivity (3G)
- Network switching (WiFi ↔ Mobile)
- Network quality degradation
- Temporary and extended network disconnections

**Edge Cases and Error Scenarios:**
- Multiple simultaneous calls
- App crashes during active calls
- Token expiration (> 1 hour)
- Permission denials (camera, microphone)
- Firestore and Cloud Functions unavailability
- Invalid appointment IDs and authentication errors

**Performance Metrics:**
- Call setup time (< 3 seconds requirement)
- Connection establishment time (< 5 seconds requirement)
- Video quality metrics (resolution, frame rate, bitrate)
- Audio quality metrics (latency, packet loss)
- Resource usage (memory, CPU, battery)

**Platform Coverage:**
- Android devices (Android 10, 11, 12, 13)
- iOS devices (iOS 14, 15, 16, 17)
- Platform-specific features (CallKit on iOS, ConnectionService on Android)

**Monitoring and Logging:**
- Firestore call_logs collection validation
- Agora Analytics Dashboard metrics
- Device log collection and analysis
- Error event tracking and categorization

#### Out of Scope

The following features are explicitly excluded from this testing initiative:

- Appointment booking and scheduling functionality
- User authentication and registration flows
- Electronic Medical Records (EMR) creation and editing
- Prescription management
- Lab and radiology request workflows
- Payment processing
- User profile management
- Doctor availability and calendar management
- Patient medical history features
- Chat and messaging features (if any)
- Administrative and reporting features

### 1.3 Key Success Criteria

This testing initiative will be considered successful when the following criteria are met:

**Overall Pass Rate:**
- ✅ 95%+ pass rate on Critical priority scenarios
- ✅ 90%+ pass rate on High priority scenarios
- ✅ 85%+ pass rate on all scenarios combined

**Performance Benchmarks:**
- ✅ Call setup time: < 3 seconds (from button press to patient notification)
- ✅ Connection establishment: < 5 seconds (from accept to first video frame)
- ✅ Video quality: 640x480 @ 15fps minimum on WiFi
- ✅ Audio latency: < 200ms
- ✅ Memory usage: < 200MB during active calls
- ✅ Battery drain: < 10% per 30 minutes of call time

**Defect Criteria:**
- ✅ Zero Critical defects blocking release
- ✅ Zero High severity defects affecting core call flows
- ✅ All Medium severity defects documented with workarounds
- ✅ Low severity defects tracked for future releases

**Coverage Criteria:**
- ✅ All 35+ test scenarios executed on both Android and iOS
- ✅ All network scenarios tested (WiFi, 4G, 3G, switching)
- ✅ All error scenarios validated with proper error handling
- ✅ Complete evidence collected for all test executions

**Monitoring Criteria:**
- ✅ All call events logged to Firestore call_logs collection
- ✅ Error events include complete device information and stack traces
- ✅ Performance metrics collected and analyzed
- ✅ Agora Analytics data exported and reviewed

### 1.4 Testing Approach

**Testing Methodology:**

This testing initiative employs a **hybrid manual and automated monitoring approach**:

1. **Manual Test Execution**: Testers execute test scenarios with real devices to validate user experience and UI behavior
2. **Automated Monitoring**: Firestore logs, Agora Analytics, and device logs are collected automatically for analysis
3. **Evidence Collection**: Screenshots, videos, logs, and metrics are systematically captured for each test execution
4. **Real-Time Documentation**: Test results are documented immediately during execution to ensure accuracy

**Testing Phases:**

**Phase 1: Critical Scenarios (2 hours)**
- Focus: Core call flows that must work for release
- Priority: Critical scenarios only
- Platforms: Both Android and iOS
- Goal: Validate essential functionality

**Phase 2: High Priority Scenarios (2 hours)**
- Focus: Important features and error handling
- Priority: High priority scenarios
- Platforms: Both Android and iOS
- Goal: Ensure robust error handling

**Phase 3: Network Resilience (2 hours)**
- Focus: Various network conditions and transitions
- Priority: High priority scenarios
- Platforms: Both Android and iOS
- Special Equipment: Network throttling tools
- Goal: Validate network resilience

**Phase 4: Edge Cases (1.5 hours)**
- Focus: Unusual situations and error conditions
- Priority: Medium priority scenarios
- Platforms: Both Android and iOS
- Goal: Ensure system robustness

**Testing Environment:**

- **Devices**: Minimum 2 Android + 2 iOS devices
- **Network**: WiFi (50+ Mbps), 4G/LTE, 3G configurations
- **Test Data**: 3 doctor accounts, 5 patient accounts, 10 test appointments
- **Monitoring Tools**: Firebase Console, Agora Dashboard, device logging tools

**Quality Assurance:**

- All test scenarios documented with detailed steps and expected outcomes
- Pass/fail criteria clearly defined for each scenario
- Evidence requirements specified for validation
- Cross-platform comparison to identify platform-specific issues
- Regression test suite created for future testing

### 1.5 Risk Assessment

**Potential Risks and Mitigation Strategies:**

**Risk 1: Device Availability**
- **Impact**: High - Cannot test without sufficient devices
- **Probability**: Low
- **Mitigation**: Ensure minimum 4 devices (2 Android, 2 iOS) available before starting
- **Contingency**: Borrow devices from team members or delay testing

**Risk 2: Network Configuration Issues**
- **Impact**: Medium - May not be able to test all network scenarios
- **Probability**: Medium
- **Mitigation**: Test network configurations before starting, have backup network options
- **Contingency**: Use network simulation tools if physical network unavailable

**Risk 3: Test Account Issues**
- **Impact**: Medium - Cannot execute tests without valid accounts
- **Probability**: Low
- **Mitigation**: Use automated scripts to create and verify test accounts
- **Contingency**: Manually create accounts if scripts fail

**Risk 4: Agora Service Unavailability**
- **Impact**: Critical - Cannot test video calls without Agora
- **Probability**: Very Low
- **Mitigation**: Verify Agora service status before testing, have backup testing window
- **Contingency**: Reschedule testing if Agora experiences outage

**Risk 5: Firebase/Firestore Unavailability**
- **Impact**: High - Cannot log events or retrieve appointments
- **Probability**: Very Low
- **Mitigation**: Verify Firebase status before testing, use emulator for local testing
- **Contingency**: Reschedule testing if Firebase experiences outage

**Risk 6: Insufficient Testing Time**
- **Impact**: Medium - May not complete all scenarios
- **Probability**: Medium
- **Mitigation**: Prioritize Critical and High priority scenarios, allocate buffer time
- **Contingency**: Schedule additional testing session for remaining scenarios

**Risk 7: Tester Availability**
- **Impact**: High - Need minimum 2 testers for call testing
- **Probability**: Low
- **Mitigation**: Confirm tester availability before scheduling, have backup testers
- **Contingency**: Reschedule testing if testers unavailable

**Risk 8: Critical Defects Found**
- **Impact**: Critical - May block release
- **Probability**: Medium
- **Mitigation**: Test early to allow time for fixes, have development team on standby
- **Contingency**: Document defects clearly, work with developers to prioritize fixes

---

## 2. Test Environment

### 2.1 Device Specifications

**Android Devices (Minimum 2 required):**

| Device Type | OS Version | Recommended Models | Purpose |
|-------------|------------|-------------------|---------|
| Primary Test Device | Android 12+ | Samsung Galaxy S21+, Google Pixel 6+ | Doctor device |
| Secondary Test Device | Android 11+ | Samsung Galaxy A52, Xiaomi Redmi Note 11 | Patient device |
| Backup Device | Android 10+ | Any compatible device | Backup/additional testing |

**iOS Devices (Minimum 2 required):**

| Device Type | OS Version | Recommended Models | Purpose |
|-------------|------------|-------------------|---------|
| Primary Test Device | iOS 16+ | iPhone 13+, iPhone 14+, iPhone 15+ | Doctor device |
| Secondary Test Device | iOS 15+ | iPhone 11+, iPhone 12+ | Patient device |
| Backup Device | iOS 14+ | Any compatible device | Backup/additional testing |

### 2.2 Network Configurations

**Primary Network (WiFi):**
- Speed: 50+ Mbps download, 10+ Mbps upload
- Latency: < 20ms
- Purpose: Primary testing network for optimal conditions

**Mobile Data (4G/LTE):**
- Speed: 10-20 Mbps download, 5-10 Mbps upload
- Latency: 30-50ms
- Purpose: Mobile data testing and network switching scenarios

**Slow Network (3G):**
- Speed: 1-3 Mbps download, 0.5-1 Mbps upload
- Latency: 100-200ms
- Purpose: Low-bandwidth testing

**Network Switching:**
- Ability to switch between WiFi and mobile data during calls
- Purpose: Network resilience testing

### 2.3 Test Accounts and Data

**Doctor Accounts (3 accounts):**
- Email: doctor.test1@androcare360.test
- Email: doctor.test2@androcare360.test
- Email: doctor.test3@androcare360.test
- Password: TestDoctor123!
- Specializations: Nutrition, Physiotherapy, Internal Medicine

**Patient Accounts (5 accounts):**
- Email: patient.test1@androcare360.test
- Email: patient.test2@androcare360.test
- Email: patient.test3@androcare360.test
- Email: patient.test4@androcare360.test
- Email: patient.test5@androcare360.test
- Password: TestPatient123!

**Test Appointments (10 appointments):**

| Appointment ID | Doctor | Patient | Status | Scheduled Time |
|----------------|--------|---------|--------|----------------|
| apt_test_001 | doctor.test1 | patient.test1 | confirmed | Now + 1 hour |
| apt_test_002 | doctor.test1 | patient.test2 | confirmed | Now + 2 hours |
| apt_test_003 | doctor.test2 | patient.test3 | confirmed | Now + 3 hours |
| apt_test_004 | doctor.test2 | patient.test4 | confirmed | Now + 4 hours |
| apt_test_005 | doctor.test3 | patient.test5 | confirmed | Now + 5 hours |
| apt_test_006 | doctor.test1 | patient.test3 | pending | Now + 1 day |
| apt_test_007 | doctor.test2 | patient.test1 | scheduled | Now + 1 day |
| apt_test_008 | doctor.test3 | patient.test2 | confirmed | Now + 6 hours |
| apt_test_009 | doctor.test1 | patient.test4 | confirmed | Now + 7 hours |
| apt_test_010 | doctor.test2 | patient.test5 | confirmed | Now + 8 hours |

### 2.4 Monitoring Tools

**Firebase Console:**
- URL: https://console.firebase.google.com/
- Project: elajtech
- Database: elajtech (custom database ID)
- Collections: users, appointments, call_logs
- Purpose: Monitor call events and errors in real-time

**Agora Analytics Dashboard:**
- URL: https://console.agora.io/
- Project: AndroCare360
- Purpose: Monitor video quality metrics, connection statistics

**Device Logging:**
- Android: logcat (via Android Studio or ADB)
- iOS: Console.app (via Xcode or macOS Console)
- Purpose: Capture device-level logs for debugging

**Screen Recording:**
- Android: Built-in screen recorder
- iOS: Built-in screen recorder
- Purpose: Record test execution for evidence

**Network Monitoring (Optional):**
- Tools: Wireshark, Charles Proxy
- Purpose: Analyze network traffic and diagnose connection issues

### 2.5 Firebase Configuration

**Project Configuration:**
- Project ID: elajtech
- Region: europe-west1
- Database ID: elajtech (CRITICAL - custom database)

**Cloud Functions:**
- startAgoraCall - Initiates video call with token generation
- endAgoraCall - Ends video call session
- completeAppointment - Marks appointment as completed
- Region: europe-west1

**Agora Configuration:**
- App ID: [From Firebase Functions config]
- Certificate: [From Firebase Functions config]
- Token Expiration: 3600 seconds (1 hour)
- Video Profile: 640x480 @ 15fps

---

## 3. Test Scenarios

### 3.1 Call Initiation Scenarios

This category covers the doctor-initiated call flows, including successful initiation and various error conditions.

---

#### Scenario 1.1: Successful Call Initiation (Happy Path)

**ID**: 1.1  
**Category**: Call Initiation  
**Priority**: Critical  
**Estimated Duration**: 5 minutes

**Preconditions**:
- Doctor logged in with valid credentials (doctor.test1@androcare360.test)
- Valid appointment exists in Firestore (apt_test_001)
- Appointment status is "confirmed"
- Patient account exists with valid FCM token
- Both devices connected to WiFi (50+ Mbps)
- Doctor device has AndroCare360 app installed and updated
- Patient device has AndroCare360 app installed and updated

**Test Steps**:
1. Doctor opens AndroCare360 app and navigates to "My Appointments" screen
2. Doctor selects appointment apt_test_001 from the list
3. Doctor views appointment details screen
4. Doctor clicks "Start Video Call" button
5. System displays loading indicator
6. System calls startAgoraCall Cloud Function with parameters:
   - appointmentId: "apt_test_001"
   - doctorId: [doctor's Firebase Auth UID]
   - deviceInfo: [platform, model, OS version]
7. Cloud Function generates Agora tokens (doctor token + patient token)
8. Cloud Function updates appointment document with:
   - agoraChannelName: "channel_apt_test_001_[timestamp]"
   - agoraToken: [patient token]
   - doctorAgoraToken: [doctor token]
   - callStartedAt: [server timestamp]
9. Cloud Function sends FCM notification to patient with call data
10. Patient device receives FCM notification
11. Patient sees incoming call UI with doctor name

**Expected Outcomes**:
- startAgoraCall Cloud Function returns success response within 3 seconds
- Response contains: agoraToken, agoraChannelName, agoraUid
- Agora tokens generated with 1-hour expiration
- Appointment document updated in Firestore with tokens and channel name
- FCM notification delivered to patient device within 2 seconds
- Patient sees incoming call UI displaying:
  - Doctor name: "Dr. Ahmed Hassan"
  - Appointment type: "Video Consultation"
  - Accept and Decline buttons
- call_logs collection contains "call_attempt" event with:
  - appointmentId: "apt_test_001"
  - userId: [doctor's UID]
  - eventType: "call_attempt"
  - timestamp: [server timestamp]
  - deviceInfo: [complete device information]

**Pass Criteria**:
- ✅ Call initiated within 3 seconds of button press
- ✅ Patient receives notification within 2 seconds
- ✅ Tokens stored correctly in appointment document
- ✅ call_attempt event logged to call_logs collection
- ✅ No errors displayed to doctor
- ✅ Patient incoming call UI displays correctly

**Evidence to Collect**:
- Screenshot: Doctor appointment details screen with "Start Video Call" button
- Screenshot: Doctor loading indicator during call initiation
- Screenshot: Patient incoming call UI (CallKit on iOS or ConnectionService on Android)
- Firestore Log: call_attempt event from call_logs collection
- Firestore Log: Updated appointment document with tokens
- Device Log: Doctor device log showing startAgoraCall function call
- Device Log: Patient device log showing FCM notification receipt
- Metric: Time from button press to notification delivery (should be < 3 seconds)

**Required Devices**:
- Doctor device: Android or iOS
- Patient device: Android or iOS

**Network Configuration**: WiFi (50+ Mbps)

**Notes**:
- This is the most critical scenario - must pass for release
- Timing is critical - measure and record actual times
- Verify both iOS CallKit and Android ConnectionService display correctly
- Ensure doctor name displays correctly in patient notification

---

#### Scenario 1.2: Call Initiation with Invalid Appointment ID

**ID**: 1.2  
**Category**: Call Initiation  
**Priority**: High  
**Estimated Duration**: 3 minutes

**Preconditions**:
- Doctor logged in with valid credentials (doctor.test1@androcare360.test)
- Doctor has access to appointment list
- Invalid appointment ID prepared for testing (e.g., "apt_invalid_999")
- Both devices connected to WiFi

**Test Steps**:
1. Doctor attempts to initiate call with non-existent appointment ID
2. System calls startAgoraCall Cloud Function with:
   - appointmentId: "apt_invalid_999"
   - doctorId: [doctor's Firebase Auth UID]
3. Cloud Function queries Firestore for appointment document
4. Firestore returns empty result (document not found)
5. Cloud Function returns error response
6. System displays error message to doctor

**Expected Outcomes**:
- startAgoraCall Cloud Function returns error within 2 seconds
- Error code: "not-found"
- Error message: "الموعد غير موجود" (Arabic) or "Appointment not found" (English)
- Doctor sees user-friendly error message:
  - "Unable to start call. Appointment not found."
  - "Please refresh and try again."
- No FCM notification sent to patient
- call_logs collection contains "call_error" event with:
  - appointmentId: "apt_invalid_999"
  - userId: [doctor's UID]
  - eventType: "call_error"
  - errorCode: "not-found"
  - errorMessage: "Appointment not found"
  - timestamp: [server timestamp]
- Doctor can dismiss error and return to appointment list

**Pass Criteria**:
- ✅ Error returned within 2 seconds
- ✅ Correct error code ("not-found") returned
- ✅ User-friendly error message displayed
- ✅ No notification sent to patient
- ✅ call_error event logged with complete details
- ✅ Doctor can recover and try again

**Evidence to Collect**:
- Screenshot: Error message displayed to doctor
- Firestore Log: call_error event from call_logs collection
- Device Log: Doctor device log showing error response
- Cloud Functions Log: startAgoraCall function error log

**Required Devices**:
- Doctor device: Android or iOS

**Network Configuration**: WiFi

**Notes**:
- Test with completely invalid ID (not just wrong format)
- Verify error message is clear and actionable
- Ensure no partial state created in Firestore

---

#### Scenario 1.3: Call Initiation Without Authentication

**ID**: 1.3  
**Category**: Call Initiation  
**Priority**: High  
**Estimated Duration**: 3 minutes

**Preconditions**:
- Doctor NOT logged in (no Firebase Auth token)
- Valid appointment exists (apt_test_001)
- App installed on device

**Test Steps**:
1. Simulate unauthenticated state (clear auth token or use test mode)
2. Attempt to call startAgoraCall Cloud Function without auth token
3. Cloud Function checks authentication context (context.auth)
4. Cloud Function detects missing authentication
5. Cloud Function returns authentication error
6. System displays error message to doctor

**Expected Outcomes**:
- startAgoraCall Cloud Function returns error immediately
- Error code: "unauthenticated"
- Error message: "المستخدم غير مصادق عليه" (Arabic) or "User not authenticated" (English)
- Doctor sees error message:
  - "Please sign in to continue"
  - Option to navigate to login screen
- No appointment document modified
- No FCM notification sent
- call_logs collection may not contain event (no user ID available)

**Pass Criteria**:
- ✅ Error returned immediately
- ✅ Correct error code ("unauthenticated") returned
- ✅ User redirected to login screen
- ✅ No data modified in Firestore
- ✅ No notification sent to patient

**Evidence to Collect**:
- Screenshot: Authentication error message
- Screenshot: Login screen after redirect
- Device Log: Doctor device log showing authentication error
- Cloud Functions Log: startAgoraCall function authentication check

**Required Devices**:
- Doctor device: Android or iOS

**Network Configuration**: WiFi

**Notes**:
- This scenario tests security - authentication must be enforced
- Verify user is redirected to login, not just shown error
- Test on both platforms to ensure consistent behavior

---

#### Scenario 1.4: Call Initiation with Wrong Doctor ID

**ID**: 1.4  
**Category**: Call Initiation  
**Priority**: High  
**Estimated Duration**: 4 minutes

**Preconditions**:
- Doctor A logged in (doctor.test1@androcare360.test)
- Valid appointment exists (apt_test_003)
- Appointment belongs to Doctor B (doctor.test2@androcare360.test)
- Both devices connected to WiFi

**Test Steps**:
1. Doctor A (doctor.test1) navigates to appointment apt_test_003
2. Appointment apt_test_003 is assigned to Doctor B (doctor.test2)
3. Doctor A attempts to click "Start Video Call" button
4. System calls startAgoraCall Cloud Function with:
   - appointmentId: "apt_test_003"
   - doctorId: [Doctor A's UID]
5. Cloud Function retrieves appointment document
6. Cloud Function compares authenticated user ID with appointment.doctorId
7. Cloud Function detects mismatch (Doctor A ≠ Doctor B)
8. Cloud Function returns permission error
9. System displays error message to Doctor A

**Expected Outcomes**:
- startAgoraCall Cloud Function returns error within 2 seconds
- Error code: "permission-denied"
- Error message: "غير مصرح لك ببدء هذه المكالمة" (Arabic) or "Not authorized to start this call" (English)
- Doctor A sees error message:
  - "You do not have permission to start this call"
  - "This appointment belongs to another doctor"
- No tokens generated
- No FCM notification sent to patient
- call_logs collection contains "call_error" event with:
  - appointmentId: "apt_test_003"
  - userId: [Doctor A's UID]
  - eventType: "call_error"
  - errorCode: "permission-denied"
  - errorMessage: "Not authorized to start this call"

**Pass Criteria**:
- ✅ Error returned within 2 seconds
- ✅ Correct error code ("permission-denied") returned
- ✅ Clear error message explaining the issue
- ✅ No tokens generated or stored
- ✅ No notification sent to patient
- ✅ call_error event logged with permission details

**Evidence to Collect**:
- Screenshot: Permission denied error message
- Firestore Log: Appointment document showing doctorId mismatch
- Firestore Log: call_error event from call_logs collection
- Device Log: Doctor A device log showing permission error
- Cloud Functions Log: startAgoraCall function permission check

**Required Devices**:
- Doctor device: Android or iOS

**Network Configuration**: WiFi

**Notes**:
- This scenario tests authorization - only assigned doctor can start call
- Verify error message clearly explains the issue
- Ensure no security information leaked in error message
- Test that Doctor B CAN start the call successfully

---


### 3.2 VoIP Notification Delivery Scenarios

This category covers FCM notification delivery across all app states, including foreground, background, terminated, and locked device scenarios.

---

#### Scenario 2.1: Notification Delivery - App Foreground

**ID**: 2.1  
**Category**: VoIP Notification Delivery  
**Priority**: Critical  
**Estimated Duration**: 4 minutes

**Preconditions**:
- Patient logged in (patient.test1@androcare360.test)
- Patient app open and in foreground (visible on screen)
- Valid appointment exists (apt_test_001)
- Patient has valid FCM token in Firestore
- Both devices connected to WiFi
- Doctor ready to initiate call
- Patient device has notifications enabled

**Test Steps**:
1. Patient opens AndroCare360 app and keeps it in foreground
2. Patient navigates to any screen (home, appointments, profile)
3. Doctor initiates call for apt_test_001
4. startAgoraCall Cloud Function sends FCM notification
5. FCM delivers high-priority message to patient device
6. Patient app receives notification via FirebaseMessaging.onMessage handler
7. FCMService processes foreground message
8. VoIPCallService.showIncomingCall() called with call data
9. System displays incoming call UI overlay
10. Patient sees incoming call with doctor information

**Expected Outcomes**:
- FCM notification delivered within 2 seconds of doctor initiating call
- Patient app receives notification via onMessage handler (foreground handler)
- Incoming call UI displays as overlay on current screen
- Call UI shows:
  - Doctor name: "Dr. Ahmed Hassan"
  - Doctor specialization: "Nutrition"
  - Appointment type: "Video Consultation"
  - Accept button (green)
  - Decline button (red)
- No native call UI displayed (CallKit/ConnectionService not used in foreground)
- Call data extracted correctly:
  - agoraToken present
  - agoraChannelName present
  - doctorName present
  - appointmentId present

**Pass Criteria**:
- ✅ Notification delivered within 2 seconds
- ✅ Incoming call UI displays correctly as overlay
- ✅ Doctor information displayed accurately
- ✅ Accept and Decline buttons functional
- ✅ No native call UI shown (app handles notification)
- ✅ Call data complete and valid
- ✅ No app crash or freeze

**Evidence to Collect**:
- Screenshot: Patient app in foreground before call
- Screenshot: Incoming call UI overlay
- Screenshot: Doctor information display
- Device Log: Patient device log showing onMessage handler triggered
- Device Log: FCM notification payload
- Device Log: VoIPCallService.showIncomingCall() call
- Metric: Time from doctor button press to patient UI display
- Video: Screen recording of notification arrival

**Required Devices**:
- Doctor device: Android or iOS
- Patient device: Android or iOS

**Network Configuration**: WiFi

**Notes**:
- Foreground notifications use onMessage handler, not background handler
- No native call UI should appear when app is in foreground
- Test on both Android and iOS to ensure consistent behavior
- Verify notification doesn't interfere with current screen navigation

---

#### Scenario 2.2: Notification Delivery - App Background

**ID**: 2.2  
**Category**: VoIP Notification Delivery  
**Priority**: Critical  
**Estimated Duration**: 5 minutes

**Preconditions**:
- Patient logged in (patient.test2@androcare360.test)
- Patient app in background (home screen visible, app not terminated)
- Valid appointment exists (apt_test_002)
- Patient has valid FCM token in Firestore
- Both devices connected to WiFi
- Doctor ready to initiate call
- Patient device has notifications enabled

**Test Steps**:
1. Patient opens AndroCare360 app and logs in
2. Patient presses home button to send app to background
3. Patient device shows home screen (app still in memory)
4. Doctor initiates call for apt_test_002
5. startAgoraCall Cloud Function sends FCM notification with high priority
6. FCM delivers notification to patient device
7. Patient device receives notification via background handler
8. System displays native call UI:
   - iOS: CallKit incoming call screen
   - Android: ConnectionService full-screen incoming call
9. Patient sees native incoming call interface
10. System plays ringtone

**Expected Outcomes**:
- FCM notification delivered within 2 seconds
- Native call UI displays automatically:
  - **iOS**: CallKit screen with green accept button, red decline button
  - **Android**: Full-screen incoming call with accept/decline buttons
- Call UI shows:
  - Doctor name: "Dr. Ahmed Hassan"
  - Call type: "Video Call" or "AndroCare360"
  - Accept and Decline options
- Ringtone plays (system default or custom)
- Lock screen shows incoming call if device locked
- Call data stored in CallKit/ConnectionService for retrieval

**Pass Criteria**:
- ✅ Notification delivered within 2 seconds
- ✅ Native call UI displays automatically
- ✅ Doctor name displayed correctly
- ✅ Ringtone plays
- ✅ Accept/Decline buttons functional
- ✅ Call data accessible for app launch
- ✅ Works on both iOS (CallKit) and Android (ConnectionService)

**Evidence to Collect**:
- Screenshot: Patient home screen before call
- Screenshot: iOS CallKit incoming call screen
- Screenshot: Android ConnectionService incoming call screen
- Device Log: Patient device log showing background handler triggered
- Device Log: CallKit/ConnectionService registration
- Device Log: FCM notification payload with call data
- Video: Screen recording showing native call UI appearance
- Audio: Recording of ringtone playing (if possible)

**Required Devices**:
- Doctor device: Android or iOS
- Patient device: Both Android AND iOS (test separately)

**Network Configuration**: WiFi

**Platform-Specific Notes**:

**iOS CallKit:**
- Green "Accept" button on right
- Red "Decline" button on left
- Doctor name displayed in system font
- "AndroCare360" or "Video Call" label
- System ringtone plays
- Call appears in recent calls list

**Android ConnectionService:**
- Full-screen incoming call UI
- Large accept button (swipe up or tap)
- Decline button (swipe down or tap)
- Doctor name displayed prominently
- Custom or system ringtone
- Notification channel: "incoming_calls"

**Notes**:
- This is the most common scenario for incoming calls
- Native UI provides better user experience and system integration
- Test on multiple Android manufacturers (Samsung, Google, Xiaomi)
- Verify call data is preserved when app launches

---

#### Scenario 2.3: Notification Delivery - App Terminated (Cold Start)

**ID**: 2.3  
**Category**: VoIP Notification Delivery  
**Priority**: Critical  
**Estimated Duration**: 6 minutes

**Preconditions**:
- Patient logged in previously (patient.test3@androcare360.test)
- Patient app completely terminated (swiped away from recent apps)
- App not running in memory
- Valid appointment exists (apt_test_003)
- Patient has valid FCM token in Firestore
- Both devices connected to WiFi
- Doctor ready to initiate call
- Patient device has notifications enabled

**Test Steps**:
1. Patient opens AndroCare360 app and logs in
2. Patient completely closes app (swipe away from recent apps)
3. Verify app is not in memory (check running processes)
4. Doctor initiates call for apt_test_003
5. startAgoraCall Cloud Function sends FCM notification with high priority
6. FCM delivers notification to patient device
7. System launches app from terminated state
8. App initializes and checks for active calls on startup
9. System displays native call UI:
   - iOS: CallKit incoming call screen
   - Android: ConnectionService full-screen incoming call
10. Patient sees native incoming call interface
11. App restores call data from notification payload

**Expected Outcomes**:
- FCM notification delivered within 3 seconds (slightly longer due to cold start)
- App launches automatically from terminated state
- Native call UI displays within 5 seconds total:
  - **iOS**: CallKit screen
  - **Android**: ConnectionService full-screen call
- Call UI shows doctor information correctly
- App startup completes in background
- Call data restored from CallKit/ConnectionService:
  - agoraToken retrieved
  - agoraChannelName retrieved
  - appointmentId retrieved
- _checkActiveCallsOnStartup() executes successfully
- App ready to accept call

**Pass Criteria**:
- ✅ App launches from terminated state
- ✅ Native call UI displays within 5 seconds
- ✅ Doctor information displayed correctly
- ✅ Call data restored successfully
- ✅ App initialization completes without errors
- ✅ Accept button functional after cold start
- ✅ Works on both iOS and Android

**Evidence to Collect**:
- Screenshot: Recent apps showing app not running
- Screenshot: Native call UI after cold start
- Device Log: App launch log from terminated state
- Device Log: _checkActiveCallsOnStartup() execution
- Device Log: Call data restoration from CallKit/ConnectionService
- Device Log: FCM notification payload
- Metric: Time from notification to UI display (should be < 5 seconds)
- Video: Screen recording of entire cold start process

**Required Devices**:
- Doctor device: Android or iOS
- Patient device: Both Android AND iOS (test separately)

**Network Configuration**: WiFi

**Platform-Specific Notes**:

**iOS CallKit:**
- App launches silently in background
- CallKit UI appears immediately
- App has time to initialize before user accepts
- Call data stored in CallKit provider

**Android ConnectionService:**
- App launches from terminated state
- Full-screen call UI appears
- App initializes in background
- Call data stored in ConnectionService extras

**Notes**:
- This is the most challenging scenario - tests VoIP reliability
- Critical for real-world usage (users often close apps)
- Verify app doesn't crash during cold start
- Test multiple times to ensure consistency
- Monitor app initialization time
- Verify no data loss during cold start

---

#### Scenario 2.4: Notification Delivery - Device Locked

**ID**: 2.4  
**Category**: VoIP Notification Delivery  
**Priority**: Critical  
**Estimated Duration**: 5 minutes

**Preconditions**:
- Patient logged in (patient.test4@androcare360.test)
- Patient device locked with screen off
- App may be in foreground, background, or terminated
- Valid appointment exists (apt_test_004)
- Patient has valid FCM token in Firestore
- Both devices connected to WiFi
- Doctor ready to initiate call
- Patient device has lock screen notifications enabled

**Test Steps**:
1. Patient opens AndroCare360 app (any state)
2. Patient locks device (press power button)
3. Screen turns off
4. Doctor initiates call for apt_test_004
5. startAgoraCall Cloud Function sends FCM notification
6. FCM delivers high-priority notification
7. Patient device screen turns on automatically
8. Lock screen displays incoming call:
   - iOS: CallKit on lock screen
   - Android: Full-screen incoming call over lock screen
9. Patient sees call information on lock screen
10. Patient can accept or decline without unlocking

**Expected Outcomes**:
- Device screen turns on automatically when call arrives
- Lock screen displays incoming call prominently:
  - **iOS**: CallKit UI on lock screen with slide to answer
  - **Android**: Full-screen call UI over lock screen
- Call information visible:
  - Doctor name: "Dr. Ahmed Hassan"
  - Call type: "Video Call"
  - App name: "AndroCare360"
- Accept and Decline buttons accessible without unlocking
- Ringtone and vibration active
- Patient can answer call from lock screen
- After accepting, device unlocks and app opens

**Pass Criteria**:
- ✅ Screen turns on automatically
- ✅ Incoming call displayed on lock screen
- ✅ Doctor information visible
- ✅ Accept/Decline functional without unlocking
- ✅ Ringtone and vibration work
- ✅ Device unlocks after accepting call
- ✅ Works on both iOS and Android

**Evidence to Collect**:
- Screenshot: Lock screen with incoming call (iOS)
- Screenshot: Lock screen with incoming call (Android)
- Device Log: Screen wake event
- Device Log: Lock screen notification display
- Device Log: Call acceptance from locked state
- Video: Screen recording of lock screen call arrival
- Video: Screen recording of accepting call from lock screen

**Required Devices**:
- Doctor device: Android or iOS
- Patient device: Both Android AND iOS (test separately)

**Network Configuration**: WiFi

**Platform-Specific Notes**:

**iOS Lock Screen:**
- Slide to answer gesture
- Swipe to decline
- Doctor name and app name visible
- "Video Call" label
- System ringtone plays
- Vibration pattern

**Android Lock Screen:**
- Full-screen call UI over lock screen
- Swipe up to answer
- Swipe down to decline
- Doctor name prominent
- Custom ringtone if configured
- Vibration pattern

**Notes**:
- Critical for real-world usage (devices often locked)
- Test with different lock screen security (PIN, pattern, biometric)
- Verify call works after unlocking
- Test with "Do Not Disturb" mode (should still ring for calls)
- Verify notification doesn't expose sensitive information

---

#### Scenario 2.5: Notification Delivery - Missing FCM Token

**ID**: 2.5  
**Category**: VoIP Notification Delivery  
**Priority**: High  
**Estimated Duration**: 4 minutes

**Preconditions**:
- Patient account exists (patient.test5@androcare360.test)
- Patient FCM token removed from Firestore (or set to null/invalid)
- Valid appointment exists (apt_test_005)
- Doctor logged in and ready to initiate call
- Both devices connected to WiFi

**Test Steps**:
1. Manually remove or invalidate patient FCM token in Firestore:
   - Navigate to users collection
   - Find patient.test5 document
   - Delete fcmToken field or set to null
2. Doctor initiates call for apt_test_005
3. startAgoraCall Cloud Function executes
4. Function retrieves patient user document
5. Function attempts to get FCM token
6. Function detects missing or invalid token
7. Function logs error to call_logs collection
8. Function returns error response to doctor
9. Doctor sees error message

**Expected Outcomes**:
- startAgoraCall Cloud Function detects missing FCM token
- Function returns error within 2 seconds
- Error code: "failed-precondition" or custom "patient-unreachable"
- Error message: "Patient unreachable. They may need to update the app."
- Doctor sees user-friendly error message:
  - "Unable to reach patient"
  - "The patient may need to update their app or check their connection"
  - Option to try again later
- No FCM notification sent (no valid token)
- call_logs collection contains error event:
  - eventType: "call_error"
  - errorCode: "missing_fcm_token"
  - errorMessage: "Patient FCM token not found"
  - appointmentId: "apt_test_005"
  - userId: [doctor's UID]
- Patient receives no notification (as expected)

**Pass Criteria**:
- ✅ Error detected within 2 seconds
- ✅ Appropriate error code returned
- ✅ Clear error message displayed to doctor
- ✅ Error logged to call_logs collection
- ✅ No notification sent to patient
- ✅ Doctor can dismiss error and try again
- ✅ Suggestion provided to patient (update app)

**Evidence to Collect**:
- Screenshot: Firestore showing missing FCM token
- Screenshot: Doctor error message
- Firestore Log: call_error event from call_logs collection
- Firestore Log: Patient user document without fcmToken
- Device Log: Doctor device showing error response
- Cloud Functions Log: startAgoraCall function error log
- Cloud Functions Log: FCM token retrieval failure

**Required Devices**:
- Doctor device: Android or iOS

**Network Configuration**: WiFi

**Notes**:
- This scenario tests error handling for unreachable patients
- Common in production when users reinstall app or clear data
- Verify error message is helpful and actionable
- Test recovery: add FCM token back and verify call works
- Consider implementing retry mechanism with exponential backoff
- May want to send alternative notification (SMS, email) in production

---

### 3.3 Call Connection Scenarios

This category covers Agora channel join and video/audio stream establishment after the patient accepts the incoming call.

---

#### Scenario 3.1: Successful Call Connection (Happy Path)

**ID**: 3.1  
**Category**: Call Connection  
**Priority**: Critical  
**Estimated Duration**: 6 minutes

**Preconditions**:
- Doctor initiated call successfully (Scenario 1.1 passed)
- Patient received incoming call notification
- Valid Agora tokens generated and stored
- Both devices connected to WiFi (50+ Mbps)
- Camera and microphone permissions granted on both devices
- Agora RTC Engine initialized on both devices
- Valid appointment exists (apt_test_001)

**Test Steps**:
1. Patient sees incoming call UI with doctor information
2. Patient clicks "Accept" button
3. VoIPCallService extracts call data from notification:
   - agoraToken
   - agoraChannelName
   - appointmentId
   - doctorName
4. AgoraService.joinChannel() called with patient token
5. Agora SDK initiates channel join process
6. Doctor already in channel (joined first when initiating call)
7. Agora SDK establishes connection to Agora servers
8. onUserJoined event fires on doctor device (patient joined)
9. onUserJoined event fires on patient device (doctor already present)
10. Video streams established bidirectionally
11. Audio streams established bidirectionally
12. Both parties see and hear each other

**Expected Outcomes**:
- Patient accepts call within 1 second of button press
- Agora channel join completes within 3 seconds
- First video frame displays within 5 seconds total
- Video quality metrics:
  - Resolution: 640x480 minimum
  - Frame rate: 15fps minimum
  - Bitrate: Auto-adjusted for network
- Audio quality metrics:
  - Latency: < 200ms
  - Clear audio with no echo
  - No audio dropouts
- Both parties see each other's video feed
- Both parties hear each other clearly
- Call controls visible and functional:
  - Mute/unmute button
  - Video on/off button
  - Switch camera button
  - End call button
- Connection state: "connected"
- No error messages displayed

**Pass Criteria**:
- ✅ Channel join completes within 3 seconds
- ✅ First video frame within 5 seconds
- ✅ Video quality meets minimum requirements (640x480 @ 15fps)
- ✅ Audio latency < 200ms
- ✅ Both parties see and hear each other
- ✅ No connection errors or warnings
- ✅ Call controls functional

**Evidence to Collect**:
- Screenshot: Patient accept button press
- Screenshot: Doctor video feed on patient device
- Screenshot: Patient video feed on doctor device
- Screenshot: Call controls UI on both devices
- Device Log: Patient AgoraService.joinChannel() call
- Device Log: onUserJoined events on both devices
- Device Log: Video stream establishment logs
- Metric: Time from accept to channel join (should be < 3 seconds)
- Metric: Time from accept to first frame (should be < 5 seconds)
- Metric: Video resolution and frame rate
- Metric: Audio latency measurement
- Video: Screen recording of connection establishment

**Required Devices**:
- Doctor device: Android or iOS
- Patient device: Android or iOS

**Network Configuration**: WiFi (50+ Mbps)

**Notes**:
- This is the most critical connection scenario
- Timing measurements are essential
- Test on both same-platform (Android-Android, iOS-iOS) and cross-platform (Android-iOS)
- Verify video quality is acceptable on both devices
- Check for any audio echo or feedback issues
- Monitor network usage during call

---

#### Scenario 3.2: Call Connection from Cold Start

**ID**: 3.2  
**Category**: Call Connection  
**Priority**: Critical  
**Estimated Duration**: 7 minutes

**Preconditions**:
- Doctor initiated call successfully
- Patient app was terminated (cold start scenario 2.3)
- Patient received notification and app launched
- Native call UI displayed (CallKit/ConnectionService)
- Valid Agora tokens in notification payload
- Both devices connected to WiFi
- Camera and microphone permissions granted

**Test Steps**:
1. Patient app launches from terminated state (cold start)
2. App initialization begins in background
3. _checkActiveCallsOnStartup() executes
4. System retrieves active calls from CallKit/ConnectionService
5. Call data extracted from CallKit/ConnectionService:
   - agoraToken from extras/userInfo
   - agoraChannelName from extras/userInfo
   - appointmentId from extras/userInfo
6. Patient sees native call UI and clicks "Accept"
7. App completes initialization
8. VoIPCallService processes call acceptance
9. AgoraService.joinChannel() called with restored credentials
10. Agora SDK joins channel
11. Connection established with doctor
12. Video and audio streams established

**Expected Outcomes**:
- App initializes successfully in background during call UI display
- Call data restored correctly from CallKit/ConnectionService
- All required data present:
  - agoraToken valid
  - agoraChannelName correct
  - appointmentId matches
- Channel join succeeds despite cold start
- Connection establishment time < 7 seconds (slightly longer due to cold start)
- Video and audio quality same as warm start
- No data loss during cold start
- No app crashes or freezes
- Call proceeds normally after connection

**Pass Criteria**:
- ✅ App initializes successfully from cold start
- ✅ Call data restored completely
- ✅ Channel join succeeds
- ✅ Connection established within 7 seconds
- ✅ Video and audio quality acceptable
- ✅ No crashes or errors
- ✅ Call proceeds normally

**Evidence to Collect**:
- Screenshot: Native call UI before acceptance
- Screenshot: Connected call after cold start
- Device Log: App launch from terminated state
- Device Log: _checkActiveCallsOnStartup() execution
- Device Log: Call data restoration logs
- Device Log: AgoraService initialization
- Device Log: Channel join from cold start
- Metric: Time from accept to connection (should be < 7 seconds)
- Video: Screen recording of entire cold start connection process

**Required Devices**:
- Doctor device: Android or iOS
- Patient device: Both Android AND iOS (test separately)

**Network Configuration**: WiFi

**Notes**:
- Critical scenario for real-world usage
- Tests VoIP reliability and data persistence
- Verify no memory leaks during cold start
- Test multiple times to ensure consistency
- Monitor app initialization time
- Verify Agora SDK initializes correctly after cold start

---

#### Scenario 3.3: Connection Failure - Invalid Token

**ID**: 3.3  
**Category**: Call Connection  
**Priority**: High  
**Estimated Duration**: 5 minutes

**Preconditions**:
- Doctor initiated call
- Patient received notification
- Agora token is expired (> 1 hour old) or malformed
- Both devices connected to WiFi
- Camera and microphone permissions granted

**Test Steps**:
1. Manually expire or corrupt Agora token in appointment document
2. Patient accepts incoming call
3. VoIPCallService extracts call data including invalid token
4. AgoraService.joinChannel() called with invalid token
5. Agora SDK attempts to join channel
6. Agora servers reject invalid token
7. Agora SDK returns error code
8. onError event fires with token error
9. CallMonitoringService logs connection failure
10. System displays error message to patient

**Expected Outcomes**:
- Agora SDK rejects invalid token immediately
- Error code from Agora: TOKEN_EXPIRED or INVALID_TOKEN
- onError event fires with error details
- CallMonitoringService logs "connection_failure" event:
  - eventType: "connection_failure"
  - errorCode: "invalid_token"
  - errorMessage: "Agora token expired or invalid"
  - appointmentId: "apt_test_001"
  - userId: [patient's UID]
  - deviceInfo: [complete device information]
- Patient sees error message:
  - "Connection failed"
  - "Unable to join video call. Please try again."
  - Option to retry or cancel
- Doctor notified of connection failure
- Call UI dismissed after error

**Pass Criteria**:
- ✅ Invalid token detected immediately
- ✅ Appropriate error code from Agora SDK
- ✅ connection_failure event logged
- ✅ Clear error message displayed
- ✅ Doctor notified of failure
- ✅ Patient can retry or cancel
- ✅ No app crash

**Evidence to Collect**:
- Screenshot: Error message on patient device
- Firestore Log: Appointment document with invalid token
- Firestore Log: connection_failure event from call_logs
- Device Log: Patient device showing Agora SDK error
- Device Log: onError event with error code
- Device Log: CallMonitoringService logging
- Cloud Functions Log: Token generation (if testing expired token)

**Required Devices**:
- Doctor device: Android or iOS
- Patient device: Android or iOS

**Network Configuration**: WiFi

**Notes**:
- Test with both expired token (> 1 hour) and malformed token
- Verify error message is user-friendly, not technical
- Test retry mechanism if implemented
- Consider implementing automatic token refresh for long calls
- Verify doctor is notified appropriately

---

#### Scenario 3.4: Connection Failure - Network Unavailable

**ID**: 3.4  
**Category**: Call Connection  
**Priority**: High  
**Estimated Duration**: 5 minutes

**Preconditions**:
- Doctor initiated call successfully
- Patient received notification (while network was available)
- Valid Agora tokens generated
- Patient device network will be disabled before accepting
- Camera and microphone permissions granted

**Test Steps**:
1. Patient receives incoming call notification
2. Disable all network connections on patient device:
   - Turn off WiFi
   - Turn off mobile data
   - Enable airplane mode
3. Patient clicks "Accept" button
4. VoIPCallService extracts call data
5. AgoraService.joinChannel() called
6. Agora SDK attempts to connect to servers
7. Network request fails (no connectivity)
8. Agora SDK returns network error
9. onError event fires with network error code
10. CallMonitoringService logs network failure
11. System displays network error message

**Expected Outcomes**:
- Agora SDK detects network unavailability
- Error code from Agora: NETWORK_ERROR or CONNECTION_FAILED
- onError event fires with network error details
- CallMonitoringService logs "connection_failure" event:
  - eventType: "connection_failure"
  - errorCode: "network_unavailable"
  - errorMessage: "No internet connection"
  - connectionType: "none"
  - deviceInfo: [complete device information]
- Patient sees error message:
  - "No internet connection"
  - "Please check your network settings and try again"
  - Option to retry when network available
- Call UI remains visible with retry option
- When network restored, retry button functional

**Pass Criteria**:
- ✅ Network error detected immediately
- ✅ Appropriate error code from Agora SDK
- ✅ connection_failure event logged with network details
- ✅ Clear network error message displayed
- ✅ Retry option available
- ✅ Retry works after network restored
- ✅ No app crash

**Evidence to Collect**:
- Screenshot: Network disabled (airplane mode)
- Screenshot: Network error message
- Firestore Log: connection_failure event from call_logs
- Device Log: Patient device showing network error
- Device Log: Agora SDK network error
- Device Log: Network connectivity check
- Video: Screen recording of network error and retry

**Required Devices**:
- Doctor device: Android or iOS
- Patient device: Android or iOS

**Network Configuration**: WiFi initially, then disabled

**Notes**:
- Test with different network disable methods (WiFi off, airplane mode)
- Verify error message is clear and actionable
- Test retry mechanism after re-enabling network
- Verify app doesn't crash when network unavailable
- Consider implementing automatic retry when network restored

---

### 3.4 Call Control Scenarios

This category covers audio and video controls during active video calls, including mute, video toggle, camera switch, and call termination.

---

#### Scenario 4.1: Mute/Unmute Audio

**ID**: 4.1  
**Category**: Call Controls  
**Priority**: Critical  
**Estimated Duration**: 4 minutes

**Preconditions**:
- Active video call in progress (Scenario 3.1 passed)
- Both parties connected with audio and video
- Audio currently unmuted on test device
- Both devices on WiFi
- Call duration at least 30 seconds (stable connection)

**Test Steps**:
1. Verify active call with audio enabled
2. Test device user speaks - remote party should hear clearly
3. Test device user clicks mute button
4. AgoraService.muteLocalAudioStream(true) called
5. Agora SDK stops transmitting audio stream
6. UI updates to show muted state (microphone icon with slash)
7. Test device user speaks - remote party should hear nothing
8. Remote party confirms no audio received
9. Test device user clicks unmute button
10. AgoraService.muteLocalAudioStream(false) called
11. Agora SDK resumes transmitting audio stream
12. UI updates to show unmuted state (microphone icon active)
13. Test device user speaks - remote party should hear clearly again

**Expected Outcomes**:
- Mute button responds within 100ms
- UI state updates immediately:
  - Muted: Microphone icon with slash (red color)
  - Unmuted: Microphone icon active (blue/white color)
- When muted:
  - Local audio stream stops transmitting
  - Remote party hears complete silence
  - No audio artifacts or noise
  - isLocalAudioMuted state = true
- When unmuted:
  - Local audio stream resumes immediately
  - Remote party hears audio clearly
  - No delay or audio glitches
  - isLocalAudioMuted state = false
- Agora SDK state matches UI state
- Multiple mute/unmute cycles work correctly
- No audio echo or feedback issues

**Pass Criteria**:
- ✅ Mute toggle responds within 100ms
- ✅ UI state matches actual audio state
- ✅ Remote party hears silence when muted
- ✅ Remote party hears audio when unmuted
- ✅ No audio artifacts during toggle
- ✅ Multiple cycles work correctly
- ✅ isLocalAudioMuted state accurate

**Evidence to Collect**:
- Screenshot: UI with audio unmuted (microphone icon active)
- Screenshot: UI with audio muted (microphone icon with slash)
- Device Log: muteLocalAudioStream(true) call
- Device Log: muteLocalAudioStream(false) call
- Device Log: isLocalAudioMuted state changes
- Video: Screen recording showing mute/unmute cycles
- Audio: Recording from remote party showing silence when muted
- Metric: Response time from button press to state change

**Required Devices**:
- Doctor device: Android or iOS (test device)
- Patient device: Android or iOS (remote party)

**Network Configuration**: WiFi

**Notes**:
- Test on both doctor and patient devices
- Verify remote party experience (critical for validation)
- Test rapid mute/unmute cycles
- Verify no audio echo when unmuting
- Check that mute state persists if app backgrounded briefly

---

#### Scenario 4.2: Enable/Disable Video

**ID**: 4.2  
**Category**: Call Controls  
**Priority**: Critical  
**Estimated Duration**: 5 minutes

**Preconditions**:
- Active video call in progress
- Both parties connected with audio and video
- Video currently enabled on test device
- Both devices on WiFi
- Call duration at least 30 seconds

**Test Steps**:
1. Verify active call with video enabled
2. Remote party sees test device user's video feed
3. Test device user clicks video off button
4. AgoraService.muteLocalVideoStream(true) called
5. Agora SDK stops transmitting video stream
6. UI updates to show video disabled state (camera icon with slash)
7. Remote party sees placeholder image or avatar instead of video
8. Test device user's camera LED turns off (if applicable)
9. Test device user clicks video on button
10. AgoraService.muteLocalVideoStream(false) called
11. Agora SDK resumes transmitting video stream
12. UI updates to show video enabled state (camera icon active)
13. Remote party sees test device user's video feed again
14. Test device user's camera LED turns on

**Expected Outcomes**:
- Video toggle responds within 100ms
- UI state updates immediately:
  - Video off: Camera icon with slash (red color)
  - Video on: Camera icon active (blue/white color)
- When video disabled:
  - Local video stream stops transmitting
  - Remote party sees placeholder (avatar or "Video Off" message)
  - Camera LED turns off
  - isLocalVideoMuted state = true
  - Local preview may show placeholder or freeze
- When video enabled:
  - Local video stream resumes within 1 second
  - Remote party sees video feed
  - Camera LED turns on
  - isLocalVideoMuted state = false
  - Local preview shows live camera feed
- Video quality maintained after re-enabling
- No video artifacts or corruption

**Pass Criteria**:
- ✅ Video toggle responds within 100ms
- ✅ UI state matches actual video state
- ✅ Remote party sees placeholder when video off
- ✅ Remote party sees video when enabled
- ✅ Video resumes within 1 second
- ✅ Video quality maintained
- ✅ isLocalVideoMuted state accurate

**Evidence to Collect**:
- Screenshot: UI with video enabled (camera icon active)
- Screenshot: UI with video disabled (camera icon with slash)
- Screenshot: Remote party view with video off (placeholder)
- Screenshot: Remote party view with video on
- Device Log: muteLocalVideoStream(true) call
- Device Log: muteLocalVideoStream(false) call
- Device Log: isLocalVideoMuted state changes
- Video: Screen recording showing video toggle cycles
- Metric: Time to resume video after enabling

**Required Devices**:
- Doctor device: Android or iOS (test device)
- Patient device: Android or iOS (remote party)

**Network Configuration**: WiFi

**Notes**:
- Test on both doctor and patient devices
- Verify remote party sees appropriate placeholder
- Test rapid video on/off cycles
- Verify camera LED behavior (hardware indicator)
- Check video quality after re-enabling
- Test with different camera orientations

---

#### Scenario 4.3: Switch Camera

**ID**: 4.3  
**Category**: Call Controls  
**Priority**: High  
**Estimated Duration**: 4 minutes

**Preconditions**:
- Active video call in progress
- Video enabled on test device
- Test device has front and rear cameras
- Currently using front camera
- Both devices on WiFi
- Call duration at least 30 seconds

**Test Steps**:
1. Verify active call with front camera active
2. Test device user sees self in local preview (front camera)
3. Remote party sees test device user (front camera view)
4. Test device user clicks switch camera button
5. AgoraService.switchCamera() called
6. Agora SDK switches from front to rear camera
7. Video stream continues without interruption
8. Local preview shows rear camera view
9. Remote party sees rear camera view
10. Test device user clicks switch camera button again
11. Agora SDK switches back to front camera
12. Video stream continues
13. Local preview shows front camera view again

**Expected Outcomes**:
- Camera switch completes within 1 second
- Video stream continues without disconnection
- Smooth transition between cameras:
  - No black screen or freeze
  - Brief transition (< 1 second)
  - Video quality maintained
- Local preview updates to show new camera view
- Remote party sees new camera view
- Switch camera button remains functional
- Multiple switches work correctly
- No impact on audio stream
- Camera orientation handled correctly

**Pass Criteria**:
- ✅ Camera switches within 1 second
- ✅ Video stream continues without interruption
- ✅ Smooth transition (no freeze)
- ✅ Remote party sees new camera view
- ✅ Multiple switches work correctly
- ✅ Audio unaffected
- ✅ No errors or crashes

**Evidence to Collect**:
- Screenshot: Front camera view (local preview)
- Screenshot: Rear camera view (local preview)
- Screenshot: Remote party view during switch
- Device Log: switchCamera() call
- Device Log: Camera switch completion
- Video: Screen recording showing camera switch
- Metric: Time to complete camera switch

**Required Devices**:
- Doctor device: Android or iOS with front and rear cameras
- Patient device: Android or iOS (remote party)

**Network Configuration**: WiFi

**Notes**:
- Test on devices with multiple cameras
- Verify smooth transition without black screen
- Test rapid camera switches
- Verify camera orientation (portrait/landscape)
- Check that switch button is disabled when video is off
- Test on both Android and iOS (different camera APIs)

---

#### Scenario 4.4: End Call

**ID**: 4.4  
**Category**: Call Controls  
**Priority**: Critical  
**Estimated Duration**: 5 minutes

**Preconditions**:
- Active video call in progress
- Both parties connected
- Call duration at least 1 minute
- Both devices on WiFi
- Valid appointment exists

**Test Steps**:
1. Verify active call in progress
2. Note call start time
3. Test device user clicks "End Call" button
4. System displays confirmation dialog (optional)
5. User confirms end call
6. AgoraService.leaveChannel() called
7. Agora SDK leaves channel
8. Video and audio streams stop
9. System calls endAgoraCall Cloud Function with appointmentId
10. Cloud Function updates appointment document:
    - callEndedAt: [server timestamp]
11. Cloud Function logs call_ended event to call_logs
12. Call UI dismissed
13. User returned to appointment details screen
14. Remote party receives notification that call ended
15. Remote party's call UI dismissed

**Expected Outcomes**:
- End call button responds immediately
- Confirmation dialog displays (if implemented)
- Call ends within 1 second of confirmation
- Agora channel leave completes successfully
- endAgoraCall Cloud Function executes:
  - Updates callEndedAt timestamp
  - Calculates call duration
  - Returns success response
- call_logs collection contains "call_ended" event:
  - eventType: "call_ended"
  - appointmentId: [appointment ID]
  - userId: [user who ended call]
  - timestamp: [server timestamp]
  - duration: [calculated from callStartedAt to callEndedAt]
- Call UI dismissed on both devices
- Both users returned to appropriate screen
- Appointment status remains "confirmed" (not auto-completed)
- No lingering call state
- Camera and microphone released

**Pass Criteria**:
- ✅ Call ends within 1 second
- ✅ endAgoraCall function executes successfully
- ✅ callEndedAt timestamp updated
- ✅ call_ended event logged
- ✅ Call UI dismissed on both devices
- ✅ No lingering call state
- ✅ Resources released properly

**Evidence to Collect**:
- Screenshot: End call button
- Screenshot: Confirmation dialog (if present)
- Screenshot: Appointment details after call
- Firestore Log: Updated appointment document with callEndedAt
- Firestore Log: call_ended event from call_logs
- Device Log: leaveChannel() call
- Device Log: endAgoraCall function call
- Cloud Functions Log: endAgoraCall execution
- Metric: Call duration (callEndedAt - callStartedAt)

**Required Devices**:
- Doctor device: Android or iOS (test device)
- Patient device: Android or iOS (remote party)

**Network Configuration**: WiFi

**Notes**:
- Test ending call from both doctor and patient devices
- Verify both parties are disconnected properly
- Check that appointment status is NOT auto-completed (requires manual completion)
- Verify no memory leaks after ending call
- Test that camera/microphone are released (LED off)
- Verify user can start another call immediately after

---

### 3.5 Call Decline and Timeout Scenarios

This category covers scenarios where the patient declines the call, doesn't answer (timeout), or the doctor cancels before the patient answers.

---

#### Scenario 5.1: Patient Declines Call

**ID**: 5.1  
**Category**: Call Decline and Timeout  
**Priority**: High  
**Estimated Duration**: 4 minutes

**Preconditions**:
- Doctor initiated call successfully
- Patient received incoming call notification
- Native call UI displayed (CallKit/ConnectionService)
- Valid appointment exists (apt_test_001)
- Both devices connected to WiFi
- handleCallDeclined Cloud Function implemented (or mock)

**Test Steps**:
1. Patient sees incoming call UI with doctor information
2. Patient clicks "Decline" button
3. VoIPCallService._onCallDeclined() event handler triggered
4. System extracts appointmentId from call data
5. System calls handleCallDeclined Cloud Function (or notifies server):
   - appointmentId: "apt_test_001"
   - patientId: [patient's UID]
   - timestamp: [current timestamp]
   - reason: "declined"
6. Cloud Function updates appointment status to "declined"
7. Cloud Function sends notification to doctor
8. Patient's call UI dismissed
9. Doctor receives decline notification
10. Doctor sees message: "Patient declined call"

**Expected Outcomes**:
- Decline button responds immediately
- _onCallDeclined() handler executes
- handleCallDeclined function called (or server notified)
- Appointment status updated to "declined" in Firestore
- call_logs collection contains decline event:
  - eventType: "call_declined"
  - appointmentId: "apt_test_001"
  - userId: [patient's UID]
  - timestamp: [server timestamp]
  - reason: "declined"
- Patient's call UI dismissed within 1 second
- Doctor receives notification within 2 seconds
- Doctor sees clear message:
  - "Patient declined call"
  - Option to reschedule or contact patient
- No lingering call state on either device

**Pass Criteria**:
- ✅ Decline processed within 1 second
- ✅ Appointment status updated to "declined"
- ✅ call_declined event logged
- ✅ Doctor notified within 2 seconds
- ✅ Clear message displayed to doctor
- ✅ Call UI dismissed on both devices
- ✅ No errors or crashes

**Evidence to Collect**:
- Screenshot: Patient decline button
- Screenshot: Doctor decline notification
- Firestore Log: Updated appointment status
- Firestore Log: call_declined event from call_logs
- Device Log: Patient _onCallDeclined() handler
- Device Log: Doctor notification receipt
- Cloud Functions Log: handleCallDeclined execution (if implemented)

**Required Devices**:
- Doctor device: Android or iOS
- Patient device: Android or iOS

**Network Configuration**: WiFi

**Notes**:
- handleCallDeclined function may need to be implemented
- Test on both iOS (CallKit decline) and Android (ConnectionService decline)
- Verify doctor receives appropriate notification
- Test that appointment can be rescheduled after decline
- Consider logging decline reason for analytics

---

#### Scenario 5.2: Call Timeout (Missed Call)

**ID**: 5.2  
**Category**: Call Decline and Timeout  
**Priority**: High  
**Estimated Duration**: 65 seconds (includes 60-second timeout)

**Preconditions**:
- Doctor initiated call successfully
- Patient received incoming call notification
- Native call UI displayed
- Valid appointment exists (apt_test_002)
- Both devices connected to WiFi
- Timeout duration configured to 60 seconds
- handleMissedCall Cloud Function implemented (or mock)

**Test Steps**:
1. Patient sees incoming call UI
2. Patient does NOT answer (intentionally ignore)
3. Call rings for 60 seconds
4. Timeout timer expires
5. VoIPCallService._onCallTimeout() event handler triggered
6. System extracts appointmentId from call data
7. System calls handleMissedCall Cloud Function:
   - appointmentId: "apt_test_002"
   - patientId: [patient's UID]
   - timestamp: [current timestamp]
   - reason: "timeout"
8. Cloud Function updates appointment status to "missed"
9. Cloud Function sends notification to doctor
10. Patient's call UI dismissed automatically
11. Doctor receives missed call notification
12. Doctor sees message: "Patient didn't answer"

**Expected Outcomes**:
- Call rings for exactly 60 seconds
- Timeout triggers automatically at 60 seconds
- _onCallTimeout() handler executes
- handleMissedCall function called
- Appointment status updated to "missed" in Firestore
- call_logs collection contains timeout event:
  - eventType: "call_timeout"
  - appointmentId: "apt_test_002"
  - userId: [patient's UID]
  - timestamp: [server timestamp]
  - duration: 60 seconds
  - reason: "timeout"
- Patient's call UI dismissed automatically
- Doctor receives notification within 2 seconds of timeout
- Doctor sees clear message:
  - "Patient didn't answer"
  - "Call timed out after 60 seconds"
  - Option to try again or contact patient
- Ringtone stops on patient device

**Pass Criteria**:
- ✅ Timeout triggers at exactly 60 seconds
- ✅ Appointment status updated to "missed"
- ✅ call_timeout event logged
- ✅ Doctor notified within 2 seconds
- ✅ Clear message displayed to doctor
- ✅ Call UI dismissed automatically
- ✅ Ringtone stops

**Evidence to Collect**:
- Screenshot: Patient incoming call UI (before timeout)
- Screenshot: Doctor missed call notification
- Firestore Log: Updated appointment status
- Firestore Log: call_timeout event from call_logs
- Device Log: Patient _onCallTimeout() handler
- Device Log: Timeout timer logs
- Device Log: Doctor notification receipt
- Cloud Functions Log: handleMissedCall execution
- Metric: Exact timeout duration (should be 60 seconds)

**Required Devices**:
- Doctor device: Android or iOS
- Patient device: Android or iOS

**Network Configuration**: WiFi

**Notes**:
- This test takes 60+ seconds to complete
- Verify timeout is exactly 60 seconds (not 59 or 61)
- Test on both iOS and Android (different timeout mechanisms)
- Verify ringtone stops when timeout occurs
- Consider implementing retry mechanism for doctor
- Test that patient can call back after missed call

---

#### Scenario 5.3: Doctor Cancels Before Patient Answers

**ID**: 5.3  
**Category**: Call Decline and Timeout  
**Priority**: Medium  
**Estimated Duration**: 4 minutes

**Preconditions**:
- Doctor initiated call successfully
- Patient received incoming call notification
- Patient has NOT answered yet (call still ringing)
- Valid appointment exists (apt_test_003)
- Both devices connected to WiFi
- Doctor has option to cancel call

**Test Steps**:
1. Doctor initiates call
2. Patient receives notification (call ringing)
3. Before patient answers, doctor clicks "Cancel" button
4. System calls cancelCall function (or similar)
5. System sends cancellation notification to patient via FCM
6. Patient receives cancellation notification
7. Patient's incoming call UI dismissed
8. Ringtone stops on patient device
9. Doctor sees confirmation: "Call cancelled"
10. Appointment status updated (optional)

**Expected Outcomes**:
- Cancel button available to doctor while call ringing
- Cancel button responds immediately
- Cancellation notification sent to patient within 1 second
- Patient's call UI dismissed within 2 seconds
- Ringtone stops immediately on patient device
- Patient sees brief message:
  - "Call cancelled"
  - "The doctor cancelled the call"
- call_logs collection contains cancellation event:
  - eventType: "call_cancelled"
  - appointmentId: "apt_test_003"
  - userId: [doctor's UID]
  - timestamp: [server timestamp]
  - reason: "doctor_cancelled"
- Doctor can initiate new call if needed
- No lingering call state

**Pass Criteria**:
- ✅ Cancel button functional
- ✅ Patient notified within 2 seconds
- ✅ Call UI dismissed on both devices
- ✅ Ringtone stops
- ✅ call_cancelled event logged
- ✅ Clear message to patient
- ✅ Doctor can retry

**Evidence to Collect**:
- Screenshot: Doctor cancel button
- Screenshot: Patient cancellation message
- Firestore Log: call_cancelled event from call_logs
- Device Log: Doctor cancel action
- Device Log: Patient cancellation notification receipt
- Device Log: Call UI dismissal

**Required Devices**:
- Doctor device: Android or iOS
- Patient device: Android or iOS

**Network Configuration**: WiFi

**Notes**:
- Cancel functionality may need to be implemented
- Test on both platforms
- Verify patient receives clear cancellation message
- Test that doctor can immediately start new call
- Consider logging cancellation reason for analytics

---

### 3.6 Network Resilience Scenarios

This category covers various network conditions and transitions to validate the system's ability to maintain call quality and recover from network issues.

---

#### Scenario 6.1: Network Switch (WiFi to Mobile Data)

**ID**: 6.1  
**Category**: Network Resilience  
**Priority**: High  
**Estimated Duration**: 6 minutes

**Preconditions**:
- Active video call in progress on WiFi
- Both parties connected and communicating
- Test device has mobile data available and enabled
- Call duration at least 1 minute (stable connection)
- Both WiFi and mobile data functional
- Network monitoring enabled

**Test Steps**:
1. Verify active call on WiFi with stable connection
2. Note current video quality and audio quality
3. Monitor network type in device settings
4. Disable WiFi on test device (turn off WiFi)
5. Device automatically switches to mobile data
6. Agora SDK detects network change
7. onConnectionStateChanged event fires
8. Agora SDK attempts to maintain connection on mobile data
9. Video and audio streams adjust to new network
10. Monitor interruption duration
11. Verify call continues on mobile data
12. Note new video quality and audio quality

**Expected Outcomes**:
- Network switch detected by Agora SDK
- onConnectionStateChanged event fires with:
  - Previous state: connected (WiFi)
  - New state: reconnecting → connected (mobile)
  - Reason: network_changed
- Connection maintained during switch
- Brief interruption < 3 seconds:
  - Video may freeze briefly
  - Audio may have brief dropout
  - Connection recovers automatically
- Call continues on mobile data
- Video quality may adjust:
  - Resolution may decrease slightly
  - Frame rate maintained
  - Bitrate adjusted for mobile bandwidth
- Audio quality maintained
- CallMonitoringService logs network change:
  - eventType: "connection_state_changed"
  - previousNetwork: "wifi"
  - currentNetwork: "mobile"
  - interruptionDuration: [< 3 seconds]
- Remote party experiences brief interruption but call continues

**Pass Criteria**:
- ✅ Network switch detected
- ✅ Connection maintained (not dropped)
- ✅ Interruption < 3 seconds
- ✅ Call continues on mobile data
- ✅ Video quality adjusts appropriately
- ✅ Audio quality maintained
- ✅ Network change logged

**Evidence to Collect**:
- Screenshot: WiFi enabled before switch
- Screenshot: Mobile data after switch
- Screenshot: Network settings showing switch
- Device Log: onConnectionStateChanged event
- Device Log: Network type change detection
- Firestore Log: connection_state_changed event
- Video: Screen recording showing switch and recovery
- Metric: Interruption duration (should be < 3 seconds)
- Metric: Video quality before and after switch

**Required Devices**:
- Doctor device: Android or iOS (test device with mobile data)
- Patient device: Android or iOS (remote party)

**Network Configuration**: WiFi initially, then mobile data

**Notes**:
- Test on both Android and iOS (different network APIs)
- Verify interruption is acceptable (< 3 seconds)
- Test reverse switch (mobile to WiFi) as well
- Monitor data usage on mobile network
- Test with different mobile network speeds (4G, 5G)
- Verify video quality adjustment is automatic

---

#### Scenario 6.2: Network Quality Degradation

**ID**: 6.2  
**Category**: Network Resilience  
**Priority**: High  
**Estimated Duration**: 7 minutes

**Preconditions**:
- Active video call on high-speed WiFi (50+ Mbps)
- Both parties connected with high-quality video
- Network throttling tool available (Network Link Conditioner, Android Developer Options)
- Call duration at least 1 minute
- Ability to throttle bandwidth during call

**Test Steps**:
1. Verify active call with high-quality video (640x480 @ 15fps)
2. Note current video quality metrics
3. Enable network throttling to simulate 3G speeds:
   - Download: 1-3 Mbps
   - Upload: 0.5-1 Mbps
   - Latency: 100-200ms
4. Agora SDK detects poor network quality
5. onNetworkQuality event fires with poor quality indicator
6. Agora SDK automatically adjusts video quality:
   - Resolution may decrease
   - Frame rate may decrease
   - Bitrate reduced
7. Monitor call stability
8. Verify call remains connected
9. Disable network throttling (restore high-speed)
10. Agora SDK detects improved network
11. Video quality increases automatically

**Expected Outcomes**:
- Network quality degradation detected by Agora SDK
- onNetworkQuality event fires with quality indicators:
  - Quality level: poor or bad
  - Uplink quality: degraded
  - Downlink quality: degraded
- Video quality adjusts automatically:
  - Resolution may drop to 320x240 or lower
  - Frame rate may drop to 10fps or lower
  - Bitrate reduced significantly
- Call remains connected (not dropped)
- Audio quality prioritized over video
- Audio remains clear despite network issues
- Network quality indicator displayed to user (optional)
- When network improves:
  - Video quality increases automatically
  - Resolution and frame rate restored
  - Smooth transition back to high quality

**Pass Criteria**:
- ✅ Network degradation detected
- ✅ Video quality adjusts automatically
- ✅ Call remains connected
- ✅ Audio quality maintained
- ✅ Quality improves when network restored
- ✅ No call drop
- ✅ Smooth quality transitions

**Evidence to Collect**:
- Screenshot: High-quality video before throttling
- Screenshot: Degraded video during throttling
- Screenshot: Restored quality after throttling
- Device Log: onNetworkQuality events
- Device Log: Video quality adjustments
- Video: Screen recording showing quality changes
- Metric: Video resolution before/during/after
- Metric: Frame rate before/during/after
- Metric: Bitrate before/during/after

**Required Devices**:
- Doctor device: Android or iOS (test device with throttling capability)
- Patient device: Android or iOS (remote party)

**Network Configuration**: WiFi with throttling capability

**Notes**:
- Use Network Link Conditioner (iOS/macOS) or Android Developer Options
- Test with different throttling levels (3G, 2G speeds)
- Verify audio is prioritized over video
- Monitor packet loss during degradation
- Test that quality recovers smoothly
- Verify user experience is acceptable on poor network

---

#### Scenario 6.3: Temporary Network Disconnection (< 30 seconds)

**ID**: 6.3  
**Category**: Network Resilience  
**Priority**: High  
**Estimated Duration**: 6 minutes

**Preconditions**:
- Active video call in progress
- Both parties connected on WiFi
- Call duration at least 1 minute
- Ability to disable/enable network quickly
- Agora SDK reconnection timeout set to 30 seconds

**Test Steps**:
1. Verify active call with stable connection
2. Note call state and quality
3. Disable all network connections on test device:
   - Turn off WiFi
   - Turn off mobile data (or enable airplane mode)
4. Monitor Agora SDK behavior
5. onConnectionStateChanged fires: disconnected
6. Agora SDK enters reconnecting state
7. Wait 10 seconds (network still disabled)
8. Agora SDK continues reconnection attempts
9. Re-enable network (turn on WiFi)
10. Agora SDK detects network availability
11. Agora SDK reconnects to channel
12. Video and audio streams re-establish
13. Call continues normally

**Expected Outcomes**:
- Network disconnection detected immediately
- onConnectionStateChanged events:
  - State: connected → disconnected → reconnecting → connected
  - Reason: network_lost → network_restored
- During disconnection:
  - Video freezes on last frame
  - Audio stops
  - UI shows "Reconnecting..." message
  - Agora SDK attempts reconnection for up to 30 seconds
- Reconnection succeeds within 5 seconds of network restoration
- Video and audio resume:
  - Video stream re-establishes
  - Audio stream re-establishes
  - Quality restored to previous level
- Call continues without manual intervention
- Total disconnection time < 15 seconds (10s offline + 5s reconnect)
- CallMonitoringService logs disconnection and reconnection

**Pass Criteria**:
- ✅ Disconnection detected immediately
- ✅ Reconnection attempted automatically
- ✅ Reconnection succeeds within 5 seconds of network restoration
- ✅ Call continues without manual intervention
- ✅ Video and audio quality restored
- ✅ Total interruption < 15 seconds
- ✅ Connection events logged

**Evidence to Collect**:
- Screenshot: "Reconnecting..." message
- Screenshot: Restored call after reconnection
- Device Log: onConnectionStateChanged events
- Device Log: Reconnection attempts
- Firestore Log: connection_state_changed events
- Video: Screen recording of disconnection and reconnection
- Metric: Time offline (10 seconds)
- Metric: Time to reconnect (should be < 5 seconds)

**Required Devices**:
- Doctor device: Android or iOS (test device)
- Patient device: Android or iOS (remote party)

**Network Configuration**: WiFi (disabled temporarily)

**Notes**:
- Test with different disconnection durations (5s, 10s, 20s)
- Verify reconnection is automatic (no user action required)
- Test on both Android and iOS
- Monitor remote party experience during disconnection
- Verify call quality after reconnection
- Test that reconnection works on different networks (WiFi, mobile)

---

#### Scenario 6.4: Extended Network Disconnection (> 30 seconds)

**ID**: 6.4  
**Category**: Network Resilience  
**Priority**: High  
**Estimated Duration**: 6 minutes

**Preconditions**:
- Active video call in progress
- Both parties connected on WiFi
- Call duration at least 1 minute
- Ability to disable network for extended period
- Agora SDK reconnection timeout set to 30 seconds

**Test Steps**:
1. Verify active call with stable connection
2. Note call state and quality
3. Disable all network connections on test device
4. Monitor Agora SDK behavior
5. onConnectionStateChanged fires: disconnected
6. Agora SDK enters reconnecting state
7. Wait 35 seconds (network still disabled)
8. Agora SDK reconnection timeout expires (30 seconds)
9. onConnectionStateChanged fires: failed
10. System terminates call
11. CallMonitoringService logs connection failure
12. Call UI dismissed with error message
13. User returned to appointment screen

**Expected Outcomes**:
- Network disconnection detected immediately
- Agora SDK attempts reconnection for 30 seconds
- onConnectionStateChanged events:
  - State: connected → disconnected → reconnecting → failed
  - Reason: network_lost → timeout
- After 30 seconds:
  - Reconnection timeout expires
  - Call terminates automatically
  - UI shows error message:
    - "Connection lost"
    - "Unable to reconnect after 30 seconds"
  - Call UI dismissed
- CallMonitoringService logs "connection_failure" event:
  - eventType: "connection_failure"
  - reason: "timeout"
  - duration: 30 seconds
  - connectionState: "failed"
  - deviceInfo: [complete device information]
- User returned to appointment details screen
- Appointment status updated (optional)
- Remote party notified of disconnection

**Pass Criteria**:
- ✅ Reconnection attempted for 30 seconds
- ✅ Call terminates after 30-second timeout
- ✅ connection_failure event logged
- ✅ Clear error message displayed
- ✅ Call UI dismissed
- ✅ User returned to appropriate screen
- ✅ Remote party notified

**Evidence to Collect**:
- Screenshot: "Reconnecting..." message during attempts
- Screenshot: "Connection lost" error message
- Screenshot: Appointment screen after call termination
- Device Log: onConnectionStateChanged events
- Device Log: Reconnection timeout
- Firestore Log: connection_failure event
- Video: Screen recording of entire timeout process
- Metric: Exact timeout duration (should be 30 seconds)

**Required Devices**:
- Doctor device: Android or iOS (test device)
- Patient device: Android or iOS (remote party)

**Network Configuration**: WiFi (disabled for 35+ seconds)

**Notes**:
- Verify timeout is exactly 30 seconds (not 29 or 31)
- Test on both Android and iOS
- Verify error message is clear and actionable
- Test that user can start new call after timeout
- Verify remote party is notified appropriately
- Consider implementing manual retry option

---

#### Scenario 6.5: Call on 3G Network

**ID**: 6.5  
**Category**: Network Resilience  
**Priority**: Medium  
**Estimated Duration**: 8 minutes

**Preconditions**:
- Both devices have 3G mobile data available
- WiFi disabled on both devices
- 3G network speed: 1-3 Mbps download, 0.5-1 Mbps upload
- Valid appointment exists
- Camera and microphone permissions granted
- Both devices charged (3G uses more battery)

**Test Steps**:
1. Disable WiFi on both doctor and patient devices
2. Enable 3G mobile data only (disable 4G/LTE if possible)
3. Verify 3G connection on both devices
4. Doctor initiates call
5. startAgoraCall Cloud Function executes
6. FCM notification sent to patient
7. Patient receives notification (may be slower on 3G)
8. Patient accepts call
9. Agora SDK joins channel on 3G
10. Connection establishment on slow network
11. Video and audio streams established
12. Monitor call quality and stability

**Expected Outcomes**:
- Call initiation succeeds on 3G
- FCM notification delivered (may take 3-5 seconds)
- Patient accepts call successfully
- Connection establishment completes within 10 seconds (slower than WiFi)
- Video quality adjusted for 3G bandwidth:
  - Resolution: 320x240 or lower
  - Frame rate: 10-15fps
  - Bitrate: Significantly reduced
  - May have occasional freezing
- Audio quality:
  - Clear audio maintained (prioritized)
  - Latency may be higher (200-300ms)
  - Occasional audio dropouts possible
- Call remains stable on 3G
- No automatic disconnection
- Battery usage higher than WiFi
- Data usage monitored

**Pass Criteria**:
- ✅ Call initiates successfully on 3G
- ✅ Connection established within 10 seconds
- ✅ Video quality adjusted appropriately
- ✅ Audio quality acceptable
- ✅ Call remains stable
- ✅ No unexpected disconnections
- ✅ User experience acceptable

**Evidence to Collect**:
- Screenshot: 3G network indicator on both devices
- Screenshot: Video quality on 3G
- Screenshot: Network settings showing 3G only
- Device Log: Network type detection (3G)
- Device Log: Video quality adjustments
- Video: Screen recording of call on 3G
- Metric: Connection establishment time (should be < 10 seconds)
- Metric: Video resolution and frame rate on 3G
- Metric: Audio latency on 3G
- Metric: Data usage during call
- Metric: Battery drain during call

**Required Devices**:
- Doctor device: Android or iOS with 3G capability
- Patient device: Android or iOS with 3G capability

**Network Configuration**: 3G mobile data only (no WiFi, no 4G)

**Notes**:
- 3G testing may be difficult (many networks are 4G/5G only)
- Use network throttling if real 3G unavailable
- Verify user experience is acceptable on slow network
- Monitor data usage (important for users with limited data)
- Test battery drain (3G uses more power)
- Verify video quality is automatically adjusted
- Consider displaying network quality indicator to users

---

### 3.7 Edge Case and Error Scenarios

This category covers unusual situations, error conditions, and edge cases to ensure system robustness and proper error handling.

---

#### Scenario 7.1: Multiple Simultaneous Calls

**ID**: 7.1  
**Category**: Edge Cases  
**Priority**: Medium  
**Estimated Duration**: 6 minutes

**Preconditions**:
- Doctor has multiple confirmed appointments
- Multiple patients available for testing
- Valid appointments exist (apt_test_001, apt_test_002)
- All devices connected to WiFi
- Doctor device capable of handling multiple operations

**Test Steps**:
1. Doctor initiates call for apt_test_001
2. Patient 1 receives notification
3. Before Patient 1 answers, doctor initiates call for apt_test_002
4. System processes second call initiation
5. Patient 2 receives notification
6. Monitor system behavior with two pending calls
7. Patient 1 accepts first call
8. Monitor first call connection
9. Patient 2 accepts second call (or times out)
10. Monitor system handling of second call

**Expected Outcomes**:
- System handles both call initiations independently
- Each call has unique:
  - agoraChannelName
  - Agora tokens
  - call_logs entries
- First call proceeds normally:
  - Patient 1 connects successfully
  - Video and audio work correctly
- Second call behavior (implementation-dependent):
  - **Option A**: Second call blocked with error "Call already in progress"
  - **Option B**: Second call queued until first call ends
  - **Option C**: Second call proceeds independently (if supported)
- No interference between calls:
  - Tokens don't conflict
  - Channels are separate
  - Logs are distinct
- No system crashes or errors
- Each call logged separately in call_logs collection

**Pass Criteria**:
- ✅ Both calls initiated successfully
- ✅ Each call has unique identifiers
- ✅ First call proceeds normally
- ✅ Second call handled appropriately (blocked, queued, or independent)
- ✅ No interference between calls
- ✅ No system crashes
- ✅ All events logged correctly

**Evidence to Collect**:
- Screenshot: Doctor initiating first call
- Screenshot: Doctor initiating second call
- Screenshot: Patient 1 incoming call
- Screenshot: Patient 2 incoming call
- Firestore Log: Both appointments with different tokens
- Firestore Log: Separate call_logs entries for each call
- Device Log: Doctor device handling multiple calls
- Device Log: Agora SDK managing multiple channels (if applicable)

**Required Devices**:
- Doctor device: Android or iOS
- Patient 1 device: Android or iOS
- Patient 2 device: Android or iOS

**Network Configuration**: WiFi

**Notes**:
- Behavior depends on implementation (may block second call)
- Test to ensure no token conflicts
- Verify each call is logged independently
- Test that ending first call doesn't affect second call
- Consider implementing call queue if multiple calls needed

---

#### Scenario 7.2: App Crash During Active Call

**ID**: 7.2  
**Category**: Edge Cases  
**Priority**: High  
**Estimated Duration**: 6 minutes

**Preconditions**:
- Active video call in progress
- Call duration at least 1 minute
- Both parties connected
- Ability to force close app
- _checkActiveCallsOnStartup() implemented

**Test Steps**:
1. Verify active call in progress
2. Note call state and appointment ID
3. Force close app on test device:
   - Android: Force stop from Settings
   - iOS: Swipe up and force quit
4. App process terminated
5. Wait 10 seconds
6. Reopen app
7. App launches and initializes
8. _checkActiveCallsOnStartup() executes
9. System checks for active calls in CallKit/ConnectionService
10. System detects interrupted call
11. System cleans up call state
12. System updates appointment status (if needed)

**Expected Outcomes**:
- App crashes/closes during active call
- Remote party's call continues briefly then disconnects
- When app reopens:
  - _checkActiveCallsOnStartup() executes
  - Active calls detected from CallKit/ConnectionService
  - Call data retrieved (appointmentId)
  - cleanupAfterCall() called
  - CallKit/ConnectionService notifications cleared
- Appointment status handling:
  - **Doctor crash**: Show dialog to confirm completion
  - **Patient crash**: Auto-complete or mark as interrupted
- call_logs collection contains crash event (if detectable)
- No lingering call state
- User returned to normal app state
- No memory leaks or corrupted data

**Pass Criteria**:
- ✅ App handles crash gracefully
- ✅ _checkActiveCallsOnStartup() executes on reopen
- ✅ Call state cleaned up properly
- ✅ CallKit/ConnectionService notifications cleared
- ✅ Appointment status updated appropriately
- ✅ No lingering call state
- ✅ No data corruption

**Evidence to Collect**:
- Screenshot: Active call before crash
- Screenshot: App after reopening
- Device Log: Force close event
- Device Log: App relaunch
- Device Log: _checkActiveCallsOnStartup() execution
- Device Log: cleanupAfterCall() execution
- Firestore Log: Appointment status update
- Firestore Log: call_logs entries

**Required Devices**:
- Doctor device: Android or iOS (test device)
- Patient device: Android or iOS (remote party)

**Network Configuration**: WiFi

**Notes**:
- Test on both doctor and patient devices
- Verify remote party is notified appropriately
- Test that app doesn't crash again on reopen
- Verify no memory leaks after crash recovery
- Test that user can start new call after crash recovery

---

#### Scenario 7.3: Token Expiration During Long Call (> 1 hour)

**ID**: 7.3  
**Category**: Edge Cases  
**Priority**: Medium  
**Estimated Duration**: 65 minutes (includes 60-minute call)

**Preconditions**:
- Active video call in progress
- Agora tokens generated with 1-hour expiration
- Both parties connected on WiFi
- Ability to maintain call for 60+ minutes
- Token expiration handling implemented (or to be tested)

**Test Steps**:
1. Initiate call and note start time
2. Verify call connects successfully
3. Maintain active call for 55 minutes
4. Monitor call quality and stability
5. At 55 minutes, note token expiration approaching
6. Continue call past 60-minute mark
7. Monitor Agora SDK behavior at token expiration
8. Observe system response to expired token
9. Check if call continues or terminates
10. Verify error handling if call terminates

**Expected Outcomes**:
- Call proceeds normally for first 55 minutes
- At 60 minutes (token expiration):
  - **Option A**: Call terminates gracefully with message
  - **Option B**: Token refreshed automatically (if implemented)
  - **Option C**: Call continues (Agora may allow brief grace period)
- If call terminates:
  - User sees message: "Call time limit reached (1 hour)"
  - Call ends gracefully
  - endAgoraCall function called
  - Appointment status updated
- If token refresh implemented:
  - New tokens generated before expiration
  - Call continues seamlessly
  - No interruption to user
- call_logs collection contains appropriate event:
  - eventType: "token_expired" or "call_ended"
  - duration: ~60 minutes
  - reason: "token_expiration" or "time_limit"

**Pass Criteria**:
- ✅ Call stable for 55+ minutes
- ✅ Token expiration handled appropriately
- ✅ Clear message if call terminates
- ✅ Graceful termination (no crash)
- ✅ Appointment status updated
- ✅ Event logged correctly
- ✅ User can start new call after expiration

**Evidence to Collect**:
- Screenshot: Call at 55 minutes
- Screenshot: Call at/after 60 minutes
- Screenshot: Expiration message (if applicable)
- Device Log: Token expiration detection
- Device Log: Call termination or refresh
- Firestore Log: call_logs event
- Metric: Exact call duration at termination

**Required Devices**:
- Doctor device: Android or iOS
- Patient device: Android or iOS

**Network Configuration**: WiFi (stable for 60+ minutes)

**Notes**:
- This test requires 60+ minutes to complete
- Consider implementing token refresh for long calls
- Verify both parties are notified if call terminates
- Test that call quality remains stable for full hour
- Monitor battery and data usage during long call
- Consider displaying time remaining to users

---

#### Scenario 7.4: Camera Permission Denied

**ID**: 7.4  
**Category**: Edge Cases  
**Priority**: High  
**Estimated Duration**: 5 minutes

**Preconditions**:
- Doctor initiated call
- Patient received notification
- Camera permission NOT granted on patient device
- Microphone permission granted
- Both devices on WiFi

**Test Steps**:
1. Revoke camera permission in device settings
2. Patient accepts incoming call
3. AgoraService attempts to initialize camera
4. System requests camera permission
5. Permission dialog displays
6. Patient denies camera permission
7. System detects permission denial
8. CallMonitoringService logs media device error
9. System displays error message to patient
10. System provides option to open settings

**Expected Outcomes**:
- Permission dialog displays when call accepted
- If denied:
  - Camera initialization fails
  - media_device_error logged:
    - eventType: "media_device_error"
    - deviceType: "camera"
    - errorMessage: "Camera permission denied"
    - appointmentId: [appointment ID]
  - Error message displayed:
    - "Camera access required"
    - "Video calls require camera permission"
    - "Open Settings" button
  - Call cannot proceed without camera
  - Option to open app settings provided
- If granted:
  - Camera initializes successfully
  - Call proceeds normally

**Pass Criteria**:
- ✅ Permission dialog displays
- ✅ Permission denial detected
- ✅ media_device_error logged
- ✅ Clear error message displayed
- ✅ Settings option provided
- ✅ Call blocked without permission
- ✅ Call proceeds if permission granted

**Evidence to Collect**:
- Screenshot: Permission dialog
- Screenshot: Permission denied error message
- Screenshot: Settings option
- Device Log: Permission request
- Device Log: Permission denial
- Firestore Log: media_device_error event
- Device Log: Camera initialization failure

**Required Devices**:
- Doctor device: Android or iOS
- Patient device: Android or iOS (test device)

**Network Configuration**: WiFi

**Notes**:
- Test on both Android and iOS (different permission systems)
- Verify error message is clear and actionable
- Test that granting permission allows call to proceed
- Test with permission denied permanently (requires app reinstall)
- Consider allowing audio-only calls if camera denied

---

#### Scenario 7.5: Microphone Permission Denied

**ID**: 7.5  
**Category**: Edge Cases  
**Priority**: High  
**Estimated Duration**: 5 minutes

**Preconditions**:
- Doctor initiated call
- Patient received notification
- Microphone permission NOT granted on patient device
- Camera permission granted
- Both devices on WiFi

**Test Steps**:
1. Revoke microphone permission in device settings
2. Patient accepts incoming call
3. AgoraService attempts to initialize microphone
4. System requests microphone permission
5. Permission dialog displays
6. Patient denies microphone permission
7. System detects permission denial
8. CallMonitoringService logs media device error
9. System displays error message to patient
10. System provides option to open settings

**Expected Outcomes**:
- Permission dialog displays when call accepted
- If denied:
  - Microphone initialization fails
  - media_device_error logged:
    - eventType: "media_device_error"
    - deviceType: "microphone"
    - errorMessage: "Microphone permission denied"
    - appointmentId: [appointment ID]
  - Error message displayed:
    - "Microphone access required"
    - "Video calls require microphone permission"
    - "Open Settings" button
  - Call cannot proceed without microphone
  - Option to open app settings provided
- If granted:
  - Microphone initializes successfully
  - Call proceeds normally

**Pass Criteria**:
- ✅ Permission dialog displays
- ✅ Permission denial detected
- ✅ media_device_error logged
- ✅ Clear error message displayed
- ✅ Settings option provided
- ✅ Call blocked without permission
- ✅ Call proceeds if permission granted

**Evidence to Collect**:
- Screenshot: Permission dialog
- Screenshot: Permission denied error message
- Screenshot: Settings option
- Device Log: Permission request
- Device Log: Permission denial
- Firestore Log: media_device_error event
- Device Log: Microphone initialization failure

**Required Devices**:
- Doctor device: Android or iOS
- Patient device: Android or iOS (test device)

**Network Configuration**: WiFi

**Notes**:
- Test on both Android and iOS
- Verify error message is clear and actionable
- Test that granting permission allows call to proceed
- Test with both permissions denied simultaneously
- Microphone is more critical than camera for medical consultations

---

#### Scenario 7.6: Firestore Temporarily Unavailable

**ID**: 7.6  
**Category**: Edge Cases  
**Priority**: Medium  
**Estimated Duration**: 6 minutes

**Preconditions**:
- Doctor ready to initiate call
- Valid appointment exists
- Ability to simulate Firestore outage (disconnect network or use emulator)
- Retry logic implemented (or to be tested)
- Both devices on WiFi initially

**Test Steps**:
1. Simulate Firestore unavailability:
   - Disconnect from network briefly, OR
   - Use Firebase Emulator and stop Firestore, OR
   - Use Firestore security rules to block access temporarily
2. Doctor attempts to initiate call
3. startAgoraCall function attempts to query Firestore
4. Firestore query fails (timeout or permission denied)
5. Cloud Function handles Firestore error
6. System implements retry logic (if available)
7. After 3 retry attempts, return error to doctor
8. Restore Firestore availability
9. Doctor retries call initiation
10. Call proceeds successfully

**Expected Outcomes**:
- Firestore unavailability detected
- startAgoraCall function handles error gracefully
- Retry logic executes (if implemented):
  - Retry 1: Wait 1 second, retry
  - Retry 2: Wait 2 seconds, retry
  - Retry 3: Wait 4 seconds, retry
  - After 3 attempts: Return error
- Error returned to doctor:
  - Error code: "unavailable" or "deadline-exceeded"
  - Error message: "Service temporarily unavailable"
- Doctor sees user-friendly message:
  - "Unable to start call"
  - "Please try again in a moment"
  - Retry button available
- call_logs may not be written (Firestore unavailable)
- When Firestore restored:
  - Retry succeeds
  - Call proceeds normally
  - Events logged correctly

**Pass Criteria**:
- ✅ Firestore error detected
- ✅ Retry logic executes (if implemented)
- ✅ Clear error message after retries exhausted
- ✅ Retry option available to user
- ✅ Call succeeds when Firestore restored
- ✅ No app crash
- ✅ Graceful error handling

**Evidence to Collect**:
- Screenshot: Firestore unavailable error
- Screenshot: Retry button
- Device Log: Firestore query failures
- Device Log: Retry attempts
- Cloud Functions Log: startAgoraCall error handling
- Cloud Functions Log: Retry logic execution

**Required Devices**:
- Doctor device: Android or iOS

**Network Configuration**: WiFi (with simulated Firestore outage)

**Notes**:
- Difficult to test in production (use emulator)
- Verify retry logic with exponential backoff
- Test that app doesn't crash on Firestore errors
- Consider caching critical data locally
- Verify user can retry manually

---

#### Scenario 7.7: Cloud Functions Timeout

**ID**: 7.7  
**Category**: Edge Cases  
**Priority**: Medium  
**Estimated Duration**: 5 minutes

**Preconditions**:
- Doctor ready to initiate call
- Valid appointment exists
- Ability to simulate slow Cloud Functions (add delay in function code or simulate high latency)
- Client timeout set to 30 seconds
- Both devices on WiFi

**Test Steps**:
1. Simulate slow Cloud Functions response:
   - Add artificial delay in startAgoraCall function, OR
   - Simulate high network latency
2. Doctor initiates call
3. Client calls startAgoraCall function
4. Function takes > 30 seconds to respond
5. Client timeout triggers
6. System handles timeout error
7. Error message displayed to doctor
8. Doctor has option to retry

**Expected Outcomes**:
- startAgoraCall function takes > 30 seconds
- Client timeout triggers at 30 seconds
- TimeoutException thrown
- CallMonitoringService logs timeout:
  - eventType: "call_error"
  - errorCode: "timeout"
  - errorMessage: "Function call timed out after 30 seconds"
  - appointmentId: [appointment ID]
- Doctor sees error message:
  - "Request timed out"
  - "Please check your connection and try again"
  - Retry button available
- When retry attempted:
  - If function still slow: Timeout again
  - If function responds: Call proceeds normally

**Pass Criteria**:
- ✅ Timeout triggers at 30 seconds
- ✅ Timeout error handled gracefully
- ✅ Timeout event logged
- ✅ Clear error message displayed
- ✅ Retry option available
- ✅ No app crash
- ✅ Call succeeds on retry if function responds

**Evidence to Collect**:
- Screenshot: Timeout error message
- Screenshot: Retry button
- Device Log: Function call timeout
- Device Log: TimeoutException
- Firestore Log: Timeout event in call_logs
- Cloud Functions Log: Slow function execution
- Metric: Exact timeout duration (should be 30 seconds)

**Required Devices**:
- Doctor device: Android or iOS

**Network Configuration**: WiFi

**Notes**:
- Difficult to test in production (use emulator or add artificial delay)
- Verify timeout is exactly 30 seconds
- Test that retry works if function responds faster
- Consider implementing loading indicator with timeout countdown
- Verify user can cancel during timeout

---

## 4. Test Data Requirements

### 4.1 Test Appointments

All test appointments are pre-created using automated scripts. See `scripts/create_test_appointments.dart` for details.

| Appointment ID | Doctor Email | Patient Email | Status | Purpose |
|----------------|--------------|---------------|--------|---------|
| apt_test_001 | doctor.test1@androcare360.test | patient.test1@androcare360.test | confirmed | Primary happy path testing |
| apt_test_002 | doctor.test1@androcare360.test | patient.test2@androcare360.test | confirmed | VoIP notification testing |
| apt_test_003 | doctor.test2@androcare360.test | patient.test3@androcare360.test | confirmed | Call connection testing |
| apt_test_004 | doctor.test2@androcare360.test | patient.test4@androcare360.test | confirmed | Call controls testing |
| apt_test_005 | doctor.test3@androcare360.test | patient.test5@androcare360.test | confirmed | Error scenario testing |
| apt_test_006 | doctor.test1@androcare360.test | patient.test3@androcare360.test | pending | Pending appointment testing |
| apt_test_007 | doctor.test2@androcare360.test | patient.test1@androcare360.test | scheduled | Scheduled appointment testing |
| apt_test_008 | doctor.test3@androcare360.test | patient.test2@androcare360.test | confirmed | Network resilience testing |
| apt_test_009 | doctor.test1@androcare360.test | patient.test4@androcare360.test | confirmed | Edge case testing |
| apt_test_010 | doctor.test2@androcare360.test | patient.test5@androcare360.test | confirmed | Additional testing |

### 4.2 Test User Credentials

**Doctor Accounts:**
- doctor.test1@androcare360.test (Dr. Ahmed Hassan - Nutrition)
- doctor.test2@androcare360.test (Dr. Sara Mohamed - Physiotherapy)
- doctor.test3@androcare360.test (Dr. Khaled Ali - Internal Medicine)
- Password: TestDoctor123!

**Patient Accounts:**
- patient.test1@androcare360.test (Omar Ibrahim)
- patient.test2@androcare360.test (Fatima Ahmed)
- patient.test3@androcare360.test (Ali Hassan)
- patient.test4@androcare360.test (Layla Mohamed)
- patient.test5@androcare360.test (Youssef Ali)
- Password: TestPatient123!

### 4.3 Firebase Configuration

- **Project ID**: elajtech
- **Database ID**: elajtech (CRITICAL - custom database)
- **Region**: europe-west1
- **Collections**: users, appointments, call_logs

### 4.4 Agora Configuration

- **App ID**: [From Firebase Functions config]
- **Certificate**: [From Firebase Functions config]
- **Token Expiration**: 3600 seconds (1 hour)
- **Video Profile**: 640x480 @ 15fps
- **Region**: Automatic (Agora selects optimal)

---

## 5. Test Execution Schedule

### Phase 1: Critical Scenarios (2 hours)
- Scenarios: 1.1, 2.1-2.4, 3.1, 4.1, 4.2, 4.4
- Priority: Critical
- Testers: 2 (1 Android, 1 iOS)

### Phase 2: High Priority Scenarios (2 hours)
- Scenarios: 1.2-1.4, 2.5, 3.2-3.4, 5.1-5.2
- Priority: High
- Testers: 2

### Phase 3: Network Resilience (2 hours)
- Scenarios: 6.1-6.5
- Priority: High
- Testers: 2
- Special Equipment: Network throttling tools

### Phase 4: Edge Cases (1.5 hours)
- Scenarios: 4.3, 5.3, 7.1-7.7
- Priority: Medium
- Testers: 2

**Total Estimated Time**: 7.5 hours

---

## 6. Evidence Collection Requirements

For each test scenario, collect:
- Screenshots at key points
- Device logs (logcat/Console)
- Firestore logs (call_logs collection)
- Performance metrics
- Video recordings (for critical scenarios)

Evidence naming convention:
```
[ScenarioID]_[Platform]_[EvidenceType]_[Description]_[Timestamp].[Extension]

Examples:
1.1_Android_Screenshot_InitiateCall_20260216_143022.png
2.3_iOS_Video_ColdStart_20260216_143530.mp4
3.1_Android_Log_ChannelJoin_20260216_144015.txt
```

---

**Document Status**: Complete  
**Total Scenarios**: 32 (4 Call Initiation + 5 VoIP Notification + 4 Call Connection + 4 Call Controls + 3 Decline/Timeout + 5 Network Resilience + 7 Edge Cases)  
**Last Updated**: 2026-02-16  
**Version**: 1.0
