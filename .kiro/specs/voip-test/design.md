# Design Document: VoIP Video Call System Testing

## Overview

This design document outlines a comprehensive testing strategy for the AndroCare360 video call system. The testing approach combines manual testing with real devices, automated monitoring, and systematic evidence collection to validate all aspects of the VoIP video consultation workflow.

The testing system will validate:
- Complete call flows from initiation to completion
- VoIP notification delivery across all app states
- Video/audio quality and call controls
- Network resilience and error recovery
- Edge cases and error scenarios
- Performance metrics and system monitoring

## Architecture

### Testing System Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Testing Framework                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Test Plan  │  │  Test Cases  │  │   Evidence   │     │
│  │   Document   │  │  Execution   │  │  Collection  │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  Monitoring  │  │  Performance │  │    Report    │     │
│  │    Setup     │  │   Metrics    │  │  Generation  │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              AndroCare360 Video Call System                  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │    Agora     │  │     VoIP     │  │     Call     │     │
│  │   Service    │  │   Service    │  │  Monitoring  │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │    Cloud     │  │     FCM      │  │  Firestore   │     │
│  │  Functions   │  │  Messaging   │  │   Database   │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Test Environment Setup


**Required Devices:**
- Android devices: Minimum 2 devices (one for doctor, one for patient)
  - Android 10, 11, 12, 13 (at least one device per major version)
  - Various manufacturers: Samsung, Google Pixel, Xiaomi
- iOS devices: Minimum 2 devices (one for doctor, one for patient)
  - iOS 14, 15, 16, 17 (at least one device per major version)
  - iPhone models: iPhone 11+, iPhone 13+, iPhone 15+

**Network Configurations:**
- WiFi (high-speed, 50+ Mbps)
- 4G/LTE mobile data
- 3G mobile data (for low-bandwidth testing)
- Network switching scenarios (WiFi ↔ Mobile)

**Test Accounts:**
- Doctor accounts: Minimum 3 test doctors with valid credentials
- Patient accounts: Minimum 5 test patients with valid credentials
- Appointments: Pre-created test appointments in various states

**Monitoring Tools:**
- Firebase Console (for Firestore logs)
- Agora Analytics Dashboard (for video quality metrics)
- Device logging tools (logcat for Android, Console for iOS)
- Screen recording software
- Network monitoring tools (Charles Proxy, Wireshark)

## Components and Interfaces

### Test Plan Document Structure

The test plan document will be organized as follows:

**1. Executive Summary**
- Testing objectives
- Scope and limitations
- Test environment overview
- Key success criteria

**2. Test Scenarios**
- Scenario ID, name, and description
- Preconditions and setup steps
- Test steps (numbered, detailed)
- Expected outcomes (measurable)
- Pass/fail criteria
- Priority (Critical, High, Medium, Low)

**3. Test Data**
- Appointment IDs for testing
- User credentials (doctor/patient)
- Agora configuration details
- FCM tokens for notification testing

**4. Test Schedule**
- Test execution timeline
- Resource allocation
- Dependencies between tests

**5. Risk Assessment**
- Potential blockers
- Mitigation strategies
- Contingency plans

### Test Scenario Categories


#### Category 1: Call Initiation Scenarios

**Scenario 1.1: Successful Call Initiation (Happy Path)**
- Preconditions: Doctor logged in, valid appointment exists, patient online
- Steps:
  1. Doctor navigates to appointment details
  2. Doctor clicks "Start Video Call" button
  3. System calls startAgoraCall Cloud Function
  4. System generates Agora tokens
  5. System sends FCM notification to patient
  6. Patient receives incoming call notification
- Expected: Call initiated within 3 seconds, patient receives notification
- Priority: Critical

**Scenario 1.2: Call Initiation with Invalid Appointment**
- Preconditions: Doctor logged in, invalid appointment ID
- Steps:
  1. Doctor attempts to start call with non-existent appointment
  2. System calls startAgoraCall with invalid ID
- Expected: System returns "not-found" error, displays error message to doctor
- Priority: High

**Scenario 1.3: Call Initiation Without Authentication**
- Preconditions: User not authenticated
- Steps:
  1. Attempt to call startAgoraCall without auth token
- Expected: System returns "unauthenticated" error
- Priority: High

**Scenario 1.4: Call Initiation with Wrong Doctor**
- Preconditions: Doctor A logged in, appointment belongs to Doctor B
- Steps:
  1. Doctor A attempts to start call for Doctor B's appointment
- Expected: System returns "permission-denied" error
- Priority: High

#### Category 2: VoIP Notification Delivery Scenarios

**Scenario 2.1: Notification Delivery - App Foreground**
- Preconditions: Patient app open and in foreground
- Steps:
  1. Doctor initiates call
  2. FCM sends high-priority notification
  3. Patient app receives notification via onMessage handler
- Expected: Incoming call UI displays within 2 seconds
- Priority: Critical

**Scenario 2.2: Notification Delivery - App Background**
- Preconditions: Patient app in background (home screen visible)
- Steps:
  1. Doctor initiates call
  2. FCM sends high-priority notification
  3. System displays native call UI (CallKit/ConnectionService)
- Expected: Native call UI displays within 2 seconds
- Priority: Critical

**Scenario 2.3: Notification Delivery - App Terminated (Cold Start)**
- Preconditions: Patient app completely closed (swiped away)
- Steps:
  1. Doctor initiates call
  2. FCM sends high-priority notification
  3. System launches app and displays native call UI
- Expected: App launches and call UI displays within 5 seconds
- Priority: Critical

**Scenario 2.4: Notification Delivery - Device Locked**
- Preconditions: Patient device locked with screen off
- Steps:
  1. Doctor initiates call
  2. FCM sends high-priority notification
  3. System displays call on lock screen
- Expected: Lock screen shows incoming call with doctor name
- Priority: Critical

**Scenario 2.5: Notification Delivery - Missing FCM Token**
- Preconditions: Patient has no valid FCM token in Firestore
- Steps:
  1. Doctor initiates call
  2. System attempts to retrieve FCM token
- Expected: System logs error, returns "patient unreachable" to doctor
- Priority: High


#### Category 3: Call Acceptance and Connection Scenarios

**Scenario 3.1: Successful Call Acceptance and Connection**
- Preconditions: Patient receives incoming call notification
- Steps:
  1. Patient clicks "Accept" button
  2. VoIPCallService extracts Agora credentials from notification
  3. AgoraService joins channel with patient token
  4. Doctor already in channel
  5. Agora establishes bidirectional video/audio streams
- Expected: Video connection established within 5 seconds, both parties see each other
- Priority: Critical

**Scenario 3.2: Call Acceptance from Cold Start**
- Preconditions: App terminated, patient receives call, taps notification
- Steps:
  1. App launches from terminated state
  2. VoIPCallService checks active calls on startup
  3. System restores call data from CallKit/ConnectionService
  4. Patient accepts call
  5. System joins Agora channel with restored credentials
- Expected: Call connects successfully despite cold start
- Priority: Critical

**Scenario 3.3: Connection Failure - Invalid Token**
- Preconditions: Patient accepts call with expired/invalid Agora token
- Steps:
  1. Patient accepts call
  2. AgoraService attempts to join channel
  3. Agora SDK rejects invalid token
- Expected: System logs error, displays connection error to patient
- Priority: High

**Scenario 3.4: Connection Failure - Network Unavailable**
- Preconditions: Patient device has no network connection
- Steps:
  1. Patient accepts call
  2. AgoraService attempts to join channel
  3. Network request fails
- Expected: System logs network error, displays "No internet connection" message
- Priority: High

#### Category 4: Call Control Scenarios

**Scenario 4.1: Mute/Unmute Audio**
- Preconditions: Active video call in progress
- Steps:
  1. User clicks mute button
  2. AgoraService calls muteLocalAudioStream(true)
  3. UI updates to show muted state
  4. User clicks unmute button
  5. AgoraService calls muteLocalAudioStream(false)
- Expected: Audio mutes/unmutes correctly, remote party hears silence when muted
- Priority: Critical

**Scenario 4.2: Enable/Disable Video**
- Preconditions: Active video call in progress
- Steps:
  1. User clicks video off button
  2. AgoraService calls muteLocalVideoStream(true)
  3. Remote party sees placeholder image
  4. User clicks video on button
  5. AgoraService calls muteLocalVideoStream(false)
- Expected: Video stream stops/resumes correctly
- Priority: Critical

**Scenario 4.3: Switch Camera**
- Preconditions: Active video call in progress
- Steps:
  1. User clicks switch camera button
  2. AgoraService calls switchCamera()
  3. Camera switches between front and rear
- Expected: Camera switches within 1 second, video stream continues
- Priority: High

**Scenario 4.4: End Call**
- Preconditions: Active video call in progress
- Steps:
  1. User clicks end call button
  2. AgoraService leaves channel
  3. System calls endAgoraCall Cloud Function
  4. System updates appointment status
- Expected: Call ends cleanly, both parties disconnected
- Priority: Critical


#### Category 5: Call Decline and Timeout Scenarios

**Scenario 5.1: Patient Declines Call**
- Preconditions: Patient receives incoming call
- Steps:
  1. Patient clicks "Decline" button
  2. VoIPCallService calls _onCallDeclined
  3. System notifies server via handleCallDeclined function
  4. System updates appointment status
- Expected: Doctor sees "Patient declined call" message
- Priority: High

**Scenario 5.2: Call Timeout (Missed Call)**
- Preconditions: Patient receives incoming call, doesn't answer
- Steps:
  1. Call rings for 60 seconds
  2. VoIPCallService triggers timeout event
  3. System calls _onCallTimeout
  4. System notifies server via handleMissedCall function
- Expected: Doctor sees "Patient didn't answer" message, call marked as missed
- Priority: High

**Scenario 5.3: Doctor Cancels Before Patient Answers**
- Preconditions: Doctor initiated call, patient hasn't answered yet
- Steps:
  1. Doctor clicks cancel button
  2. System sends cancellation notification to patient
  3. Patient's incoming call UI dismisses
- Expected: Patient sees "Call cancelled" message
- Priority: Medium

#### Category 6: Network Resilience Scenarios

**Scenario 6.1: Network Switch During Call (WiFi to Mobile)**
- Preconditions: Active call on WiFi
- Steps:
  1. Disable WiFi on device during call
  2. Device switches to mobile data
  3. Agora SDK detects network change
  4. System logs connection state change
- Expected: Call continues on mobile data, brief interruption < 3 seconds
- Priority: High

**Scenario 6.2: Network Quality Degradation**
- Preconditions: Active call on high-speed network
- Steps:
  1. Simulate network throttling (reduce bandwidth to 3G speeds)
  2. Agora SDK detects poor network quality
  3. System adjusts video quality automatically
- Expected: Video quality reduces but call remains connected
- Priority: High

**Scenario 6.3: Temporary Network Disconnection**
- Preconditions: Active call in progress
- Steps:
  1. Disable all network connections for 10 seconds
  2. Agora SDK attempts reconnection
  3. Re-enable network
  4. System reconnects to call
- Expected: Call reconnects within 5 seconds of network restoration
- Priority: High

**Scenario 6.4: Extended Network Disconnection**
- Preconditions: Active call in progress
- Steps:
  1. Disable all network connections for 35 seconds
  2. Agora SDK attempts reconnection
  3. Reconnection timeout exceeds 30 seconds
- Expected: Call ends, system logs "connection_failure" event
- Priority: High

**Scenario 6.5: Call on Slow Network (3G)**
- Preconditions: Device connected to 3G network only
- Steps:
  1. Doctor initiates call
  2. Patient accepts call on 3G
  3. Agora establishes connection with adjusted quality
- Expected: Call connects within 10 seconds, video quality adjusted for bandwidth
- Priority: Medium


#### Category 7: Edge Case and Error Scenarios

**Scenario 7.1: Multiple Simultaneous Calls**
- Preconditions: Doctor has multiple appointments
- Steps:
  1. Doctor initiates call for Appointment A
  2. Before Patient A answers, doctor initiates call for Appointment B
  3. System handles both calls independently
- Expected: Each call operates independently without interference
- Priority: Medium

**Scenario 7.2: App Crash During Active Call**
- Preconditions: Active call in progress
- Steps:
  1. Force close app during call
  2. Reopen app
  3. System checks for active calls on startup
  4. System cleans up call state
- Expected: Call state cleaned up, appointment status updated correctly
- Priority: High

**Scenario 7.3: Token Expiration During Long Call**
- Preconditions: Active call running for 55+ minutes
- Steps:
  1. Call continues past 1 hour mark
  2. Agora token expires
  3. System detects token expiration
- Expected: Call ends gracefully, system notifies users of time limit
- Priority: Medium

**Scenario 7.4: Camera Permission Denied**
- Preconditions: User hasn't granted camera permission
- Steps:
  1. Patient accepts call
  2. AgoraService requests camera permission
  3. User denies permission
- Expected: System logs media_device_error, displays permission request dialog
- Priority: High

**Scenario 7.5: Microphone Permission Denied**
- Preconditions: User hasn't granted microphone permission
- Steps:
  1. Patient accepts call
  2. AgoraService requests microphone permission
  3. User denies permission
- Expected: System logs media_device_error, displays permission request dialog
- Priority: High

**Scenario 7.6: Firestore Temporarily Unavailable**
- Preconditions: Firestore experiencing outage
- Steps:
  1. Doctor initiates call
  2. System attempts to write to call_logs collection
  3. Firestore write fails
- Expected: Call continues, error logged locally, retry attempted
- Priority: Medium

**Scenario 7.7: Cloud Functions Timeout**
- Preconditions: Cloud Functions experiencing high latency
- Steps:
  1. Doctor initiates call
  2. startAgoraCall function takes > 30 seconds
  3. Client timeout triggers
- Expected: System displays timeout error, allows retry
- Priority: Medium

## Data Models

### Test Scenario Model

```typescript
interface TestScenario {
  id: string;                    // e.g., "1.1", "2.3"
  category: string;              // e.g., "Call Initiation"
  name: string;                  // e.g., "Successful Call Initiation"
  description: string;           // Brief description
  priority: 'Critical' | 'High' | 'Medium' | 'Low';
  preconditions: string[];       // Setup requirements
  steps: TestStep[];             // Execution steps
  expectedOutcomes: string[];    // Measurable outcomes
  passCriteria: string[];        // Pass/fail criteria
  estimatedDuration: number;     // Minutes
  requiredDevices: string[];     // Device requirements
  networkConfig: string;         // Network setup
}

interface TestStep {
  stepNumber: number;
  action: string;
  actor: 'Doctor' | 'Patient' | 'System';
  expectedResult: string;
}
```

### Test Execution Record Model

```typescript
interface TestExecutionRecord {
  scenarioId: string;
  executionDate: Date;
  tester: string;
  deviceInfo: {
    doctorDevice: DeviceInfo;
    patientDevice: DeviceInfo;
  };
  networkConfig: string;
  status: 'Pass' | 'Fail' | 'Blocked' | 'Skip';
  actualDuration: number;        // Minutes
  notes: string;
  evidence: Evidence[];
  defects: Defect[];
}

interface DeviceInfo {
  platform: 'Android' | 'iOS';
  model: string;
  osVersion: string;
  appVersion: string;
}

interface Evidence {
  type: 'Screenshot' | 'Video' | 'Log' | 'Metric';
  filename: string;
  description: string;
  timestamp: Date;
}

interface Defect {
  id: string;
  severity: 'Critical' | 'High' | 'Medium' | 'Low';
  title: string;
  description: string;
  reproductionSteps: string[];
  evidence: string[];           // References to evidence files
}
```


### Performance Metrics Model

```typescript
interface PerformanceMetrics {
  scenarioId: string;
  executionId: string;
  
  // Timing Metrics
  callSetupTime: number;         // ms from button press to notification
  notificationDeliveryTime: number; // ms from FCM send to device receipt
  connectionEstablishmentTime: number; // ms from accept to first frame
  
  // Video Quality Metrics
  videoResolution: string;       // e.g., "640x480"
  videoFrameRate: number;        // fps
  videoBitrate: number;          // kbps
  videoPacketLoss: number;       // percentage
  
  // Audio Quality Metrics
  audioLatency: number;          // ms
  audioPacketLoss: number;       // percentage
  audioQuality: 'Excellent' | 'Good' | 'Fair' | 'Poor';
  
  // Resource Usage
  memoryUsage: number;           // MB
  cpuUsage: number;              // percentage
  batteryDrain: number;          // percentage per 30 minutes
  
  // Network Metrics
  networkType: string;           // WiFi, 4G, 3G
  bandwidth: number;             // Mbps
  networkLatency: number;        // ms
}
```

### Call Log Query Model

```typescript
interface CallLogQuery {
  appointmentId?: string;
  userId?: string;
  eventType?: CallLogEventType[];
  startDate?: Date;
  endDate?: Date;
  limit?: number;
}

interface CallLogResult {
  logs: CallLogModel[];
  summary: {
    totalEvents: number;
    errorCount: number;
    successRate: number;
    averageDuration: number;
  };
}
```

## Correctness Properties

A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.

### Property 1: Call Initiation Token Generation

*For any* valid appointment with assigned doctor, when the doctor initiates a call, the system should generate valid Agora tokens (doctor token and patient token) with 1-hour expiration and successfully store them in the appointment document.

**Validates: Requirements 2.1, 2.5**

### Property 2: VoIP Notification Delivery Reliability

*For any* patient with valid FCM token, when a doctor initiates a call, the system should deliver a high-priority FCM notification containing complete call data (agoraToken, channelName, doctorName) within 3 seconds.

**Validates: Requirements 3.1, 3.2, 3.3, 3.5**

### Property 3: Call Acceptance Connection Establishment

*For any* accepted incoming call with valid Agora credentials, the patient device should successfully join the Agora channel and establish bidirectional video/audio streams within 5 seconds.

**Validates: Requirements 4.1, 4.2, 4.3**

### Property 4: Call Control State Consistency

*For any* active video call, when a user toggles audio or video mute state, the local state (isLocalAudioMuted, isLocalVideoMuted) should match the Agora SDK state and the UI should reflect the current state accurately.

**Validates: Requirements 5.1, 5.2, 5.3, 5.4**

### Property 5: Call Decline Notification

*For any* incoming call that is declined by the patient, the system should notify the server via handleCallDeclined function and the doctor should receive a "Patient declined call" message within 2 seconds.

**Validates: Requirements 6.1, 6.5**

### Property 6: Call Timeout Handling

*For any* incoming call that is not answered within 60 seconds, the system should trigger a timeout event, notify the server via handleMissedCall function, and display a "Missed call" message to the doctor.

**Validates: Requirements 6.2, 6.5**

### Property 7: Network Resilience During Call

*For any* active call experiencing network switch (WiFi to mobile or vice versa), the Agora SDK should maintain the connection with at most 3 seconds of interruption and log the network change event.

**Validates: Requirements 7.1, 7.2**

### Property 8: Network Disconnection Recovery

*For any* active call experiencing temporary network disconnection (< 30 seconds), the system should attempt reconnection and restore the call within 5 seconds of network restoration.

**Validates: Requirements 7.3**

### Property 9: Extended Network Disconnection Termination

*For any* active call experiencing extended network disconnection (> 30 seconds), the system should terminate the call gracefully and log a "connection_failure" event with appropriate metadata.

**Validates: Requirements 7.4**


### Property 10: Call Monitoring Event Logging

*For any* call lifecycle event (attempt, start, error, end), the CallMonitoringService should write a corresponding log entry to the call_logs Firestore collection with complete metadata including timestamp, user ID, appointment ID, and device information.

**Validates: Requirements 8.1, 8.2, 8.3, 8.4, 8.5**

### Property 11: Error Event Logging with Device Context

*For any* call error (token generation failure, connection failure, media device error), the system should log the error to call_logs collection with errorCode, errorMessage, stackTrace, and complete device information for debugging.

**Validates: Requirements 8.2, 8.6**

### Property 12: Permission Denial Handling

*For any* call acceptance where camera or microphone permission is denied, the system should log a "media_device_error" event, display a permission request dialog to the user, and prevent call connection until permissions are granted.

**Validates: Requirements 9.6**

### Property 13: App Crash Recovery

*For any* app crash during an active call, when the app restarts, the system should detect the interrupted call state, clean up CallKit/ConnectionService notifications, and update the appointment status appropriately.

**Validates: Requirements 9.2**

### Property 14: Performance Metrics Collection Accuracy

*For any* test execution, the system should accurately measure and record call setup time (< 3 seconds), connection establishment time (< 5 seconds), video quality metrics (resolution, frame rate, bitrate), and resource usage (memory, CPU, battery).

**Validates: Requirements 10.1, 10.2, 10.3, 10.4, 10.5, 10.6**

### Property 15: Test Evidence Completeness

*For any* test scenario execution, the system should capture and organize complete evidence including screenshots at key points, relevant Firestore logs, device logs, and performance metrics with clear naming conventions.

**Validates: Requirements 11.1, 11.2, 11.3, 11.4, 11.5, 11.6**

### Property 16: Test Report Accuracy

*For any* completed test execution, the generated test report should accurately reflect all test results (pass/fail status), include all collected evidence with proper references, document all defects with severity and reproduction steps, and provide performance metrics summary.

**Validates: Requirements 12.1, 12.2, 12.3, 12.4, 12.5, 12.6**

### Property 17: Cross-Platform Consistency

*For any* test scenario executed on both Android and iOS platforms, the core functionality (call initiation, acceptance, controls, termination) should behave consistently, with only platform-specific UI differences (CallKit vs ConnectionService) documented.

**Validates: Requirements 13.3, 13.4, 13.5**

## Error Handling

### Error Categories and Handling Strategies

**1. Cloud Functions Errors**
- Error Types: unauthenticated, permission-denied, not-found, failed-precondition
- Handling: Display user-friendly error messages, log to call_logs, allow retry
- Example: "Appointment not found" → Display "Unable to start call. Please refresh and try again."

**2. Agora SDK Errors**
- Error Types: Invalid token, join channel failed, connection lost
- Handling: Log error with stack trace, display technical error code, provide retry option
- Example: "Join channel failed" → Display "Connection error. Please check your internet and try again."

**3. Network Errors**
- Error Types: No internet connection, timeout, DNS resolution failure
- Handling: Detect network state, display connectivity message, auto-retry when network restored
- Example: "Network unavailable" → Display "No internet connection. Please check your network settings."

**4. Permission Errors**
- Error Types: Camera denied, microphone denied
- Handling: Display permission rationale, open app settings, prevent call until granted
- Example: "Camera permission denied" → Display "Camera access is required for video calls. Please grant permission in Settings."

**5. VoIP Notification Errors**
- Error Types: Missing FCM token, notification delivery failure
- Handling: Log error, notify doctor of unreachable patient, suggest alternative contact
- Example: "Patient unreachable" → Display "Unable to reach patient. They may need to update the app."

**6. Firestore Errors**
- Error Types: Write failure, read failure, permission denied
- Handling: Retry with exponential backoff, cache locally if possible, log error
- Example: "Failed to save call log" → Retry 3 times, then log locally

### Error Recovery Mechanisms

**Automatic Retry Logic:**
```typescript
async function retryWithBackoff<T>(
  operation: () => Promise<T>,
  maxAttempts: number = 3,
  initialDelay: number = 1000
): Promise<T> {
  let delay = initialDelay;
  
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await operation();
    } catch (error) {
      if (attempt === maxAttempts) throw error;
      
      // Don't retry on client errors
      if (isClientError(error)) throw error;
      
      await sleep(delay);
      delay *= 2; // Exponential backoff
    }
  }
  
  throw new Error('Max retry attempts reached');
}
```

**Network State Monitoring:**
```typescript
class NetworkMonitor {
  private isOnline: boolean = true;
  private listeners: ((online: boolean) => void)[] = [];
  
  startMonitoring() {
    // Monitor connectivity changes
    Connectivity().onConnectivityChanged.listen((result) => {
      const wasOnline = this.isOnline;
      this.isOnline = result !== ConnectivityResult.none;
      
      if (wasOnline !== this.isOnline) {
        this.notifyListeners();
      }
    });
  }
  
  onNetworkStateChange(callback: (online: boolean) => void) {
    this.listeners.push(callback);
  }
}
```


## Testing Strategy

### Dual Testing Approach

The testing strategy combines manual testing with automated monitoring:

**Manual Testing:**
- Execute test scenarios with real devices
- Validate user experience and UI behavior
- Test edge cases and error scenarios
- Collect qualitative feedback
- Document defects with reproduction steps

**Automated Monitoring:**
- Query Firestore call_logs collection for event tracking
- Monitor Agora Analytics Dashboard for video quality metrics
- Collect device logs automatically during test execution
- Generate performance metrics reports
- Aggregate test results for analysis

### Test Execution Workflow

**Phase 1: Pre-Test Setup (30 minutes)**
1. Prepare test devices (charge, update app, clear cache)
2. Configure network environments (WiFi, 4G, 3G)
3. Create test appointments in Firestore
4. Verify test accounts and credentials
5. Set up monitoring tools (Firebase Console, Agora Dashboard)
6. Prepare evidence collection folders

**Phase 2: Test Execution (4-6 hours)**
1. Execute Critical priority scenarios first
2. Execute High priority scenarios
3. Execute Medium priority scenarios
4. Execute Low priority scenarios (if time permits)
5. Document results in real-time
6. Capture evidence for each scenario
7. Log defects immediately when found

**Phase 3: Post-Test Analysis (2-3 hours)**
1. Query call_logs collection for all test executions
2. Analyze performance metrics
3. Review collected evidence
4. Categorize and prioritize defects
5. Calculate pass/fail rates
6. Identify patterns and trends

**Phase 4: Report Generation (2-3 hours)**
1. Compile test results into report template
2. Add evidence references
3. Document defects with severity
4. Include performance metrics summary
5. Provide recommendations
6. Review and finalize report

### Test Prioritization

**Critical Priority (Must Pass):**
- Call initiation happy path
- VoIP notification delivery (all app states)
- Call acceptance and connection
- Basic call controls (mute, end call)
- Call monitoring event logging

**High Priority (Should Pass):**
- Error scenarios (invalid appointment, wrong doctor)
- Call decline and timeout
- Network resilience (WiFi to mobile switch)
- Permission handling
- App crash recovery

**Medium Priority (Nice to Pass):**
- Multiple simultaneous calls
- Token expiration
- Slow network (3G) calls
- Extended network disconnection
- Firestore unavailability

**Low Priority (Optional):**
- Performance optimization scenarios
- UI/UX edge cases
- Non-critical error messages

### Monitoring Setup Guide

**Firebase Console Monitoring:**

1. **Access Firestore Database:**
   - Navigate to Firebase Console → Firestore Database
   - Select `elajtech` database
   - Open `call_logs` collection

2. **Create Monitoring Queries:**
   ```javascript
   // Query all logs for a specific appointment
   db.collection('call_logs')
     .where('appointmentId', '==', 'test_appt_123')
     .orderBy('timestamp', 'desc')
     .get()
   
   // Query all error logs
   db.collection('call_logs')
     .where('eventType', 'in', ['call_error', 'connection_failure', 'media_device_error'])
     .orderBy('timestamp', 'desc')
     .limit(100)
     .get()
   
   // Query logs for specific time range
   db.collection('call_logs')
     .where('timestamp', '>=', startDate)
     .where('timestamp', '<=', endDate)
     .orderBy('timestamp', 'desc')
     .get()
   ```

3. **Export Logs for Analysis:**
   - Use Firebase CLI: `firebase firestore:export logs_export`
   - Or use Firestore export feature in console
   - Save as JSON for offline analysis

**Agora Analytics Dashboard:**

1. **Access Dashboard:**
   - Navigate to Agora Console → Analytics
   - Select project: AndroCare360
   - Choose date range for test execution

2. **Monitor Key Metrics:**
   - Call Quality: Video resolution, frame rate, packet loss
   - Network Quality: Bandwidth usage, latency, jitter
   - User Experience: Join success rate, call duration
   - Error Rates: Connection failures, SDK errors

3. **Export Reports:**
   - Download CSV reports for offline analysis
   - Include in test report as evidence

**Device Log Collection:**

**Android (logcat):**
```bash
# Start logging before test
adb logcat -c  # Clear existing logs
adb logcat > test_scenario_1_1_android.log

# Filter for relevant logs
adb logcat | grep -E "AgoraService|VoIPCallService|CallMonitoringService"

# Save logs after test
adb logcat -d > test_scenario_1_1_android_full.log
```

**iOS (Console.app):**
1. Connect device to Mac
2. Open Console.app
3. Select device from sidebar
4. Filter for "AndroCare" or "Agora"
5. Start recording before test
6. Save logs after test completion


### Evidence Collection Guidelines

**Screenshot Capture Points:**
1. Call initiation button press
2. Incoming call notification (foreground, background, lock screen)
3. Call acceptance screen
4. Video call connected (both parties visible)
5. Call controls (mute, video off, camera switch)
6. Error messages
7. Call end confirmation

**Video Recording Scenarios:**
- Complete call flow (initiation to end)
- Network switch during call
- App crash and recovery
- Permission denial handling
- Critical defect reproduction

**Log Collection:**
- Device logs (logcat/Console) for each test scenario
- Firestore call_logs export for test session
- Cloud Functions logs from Firebase Console
- Network traffic logs (if using Charles Proxy)

**Performance Metrics:**
- Call setup time measurements
- Video quality metrics from Agora Dashboard
- Memory usage snapshots
- Battery drain measurements
- Network bandwidth usage

**File Naming Convention:**
```
evidence/
├── screenshots/
│   ├── scenario_1_1_step_1_doctor_initiate.png
│   ├── scenario_1_1_step_2_patient_notification.png
│   └── scenario_1_1_step_3_call_connected.png
├── videos/
│   ├── scenario_1_1_complete_flow.mp4
│   └── scenario_9_2_app_crash_recovery.mp4
├── logs/
│   ├── scenario_1_1_android_doctor.log
│   ├── scenario_1_1_ios_patient.log
│   └── scenario_1_1_firestore_logs.json
└── metrics/
    ├── scenario_1_1_performance.json
    └── scenario_1_1_agora_quality.csv
```

### Test Report Template

**Executive Summary**
- Testing Period: [Start Date] - [End Date]
- Total Scenarios Executed: [Number]
- Pass Rate: [Percentage]
- Critical Issues Found: [Number]
- Overall Assessment: [Pass/Fail/Conditional Pass]

**Test Environment**
- Devices Tested:
  - Android: [List models and OS versions]
  - iOS: [List models and OS versions]
- Network Configurations: [WiFi, 4G, 3G]
- App Version: [Version number]
- Test Data: [Appointment IDs, user accounts]

**Test Results Summary**

| Category | Total | Pass | Fail | Blocked | Skip | Pass Rate |
|----------|-------|------|------|---------|------|-----------|
| Call Initiation | 4 | 3 | 1 | 0 | 0 | 75% |
| VoIP Notification | 5 | 5 | 0 | 0 | 0 | 100% |
| Call Connection | 4 | 4 | 0 | 0 | 0 | 100% |
| Call Controls | 4 | 4 | 0 | 0 | 0 | 100% |
| Decline/Timeout | 3 | 3 | 0 | 0 | 0 | 100% |
| Network Resilience | 5 | 4 | 1 | 0 | 0 | 80% |
| Edge Cases | 7 | 5 | 2 | 0 | 0 | 71% |
| **Total** | **32** | **28** | **4** | **0** | **0** | **87.5%** |

**Detailed Test Results**

For each scenario:
- Scenario ID and Name
- Execution Date/Time
- Tester Name
- Device Information
- Status (Pass/Fail/Blocked/Skip)
- Actual Duration
- Notes
- Evidence References
- Defects Found

**Performance Metrics Summary**

| Metric | Target | Average | Min | Max | Status |
|--------|--------|---------|-----|-----|--------|
| Call Setup Time | < 3s | 2.1s | 1.8s | 2.5s | ✅ Pass |
| Notification Delivery | < 2s | 1.5s | 1.2s | 1.9s | ✅ Pass |
| Connection Time | < 5s | 3.8s | 3.2s | 4.5s | ✅ Pass |
| Video Resolution | 640x480 | 640x480 | 640x480 | 640x480 | ✅ Pass |
| Video Frame Rate | ≥ 15fps | 18fps | 15fps | 24fps | ✅ Pass |
| Memory Usage | < 200MB | 165MB | 145MB | 185MB | ✅ Pass |
| Battery Drain | < 10%/30min | 8.5% | 7% | 10% | ✅ Pass |

**Defects Found**

For each defect:
- Defect ID: [Unique identifier]
- Severity: [Critical/High/Medium/Low]
- Title: [Brief description]
- Description: [Detailed description]
- Reproduction Steps: [Numbered steps]
- Expected Behavior: [What should happen]
- Actual Behavior: [What actually happened]
- Evidence: [References to screenshots, logs, videos]
- Affected Platforms: [Android/iOS/Both]
- Affected Scenarios: [List of scenario IDs]
- Workaround: [If available]
- Status: [Open/In Progress/Fixed/Closed]

**Example Defect:**
```
Defect ID: DEF-001
Severity: High
Title: Call fails when patient has no FCM token

Description:
When a patient's FCM token is missing or invalid in Firestore, the doctor 
receives a generic error instead of a clear "patient unreachable" message.

Reproduction Steps:
1. Remove FCM token from patient's user document in Firestore
2. Doctor initiates call for that patient
3. Observe error message displayed to doctor

Expected Behavior:
Doctor should see: "Unable to reach patient. They may need to update the app."

Actual Behavior:
Doctor sees: "An error occurred. Please try again."

Evidence:
- Screenshot: evidence/screenshots/def_001_error_message.png
- Logs: evidence/logs/def_001_cloud_functions.log
- Firestore: evidence/logs/def_001_call_logs.json

Affected Platforms: Both Android and iOS
Affected Scenarios: 2.5
Workaround: Manually verify patient FCM token before initiating call
Status: Open
```

**Recommendations**

1. **Critical Issues:**
   - [List critical issues that must be fixed before release]

2. **High Priority Improvements:**
   - [List high priority improvements]

3. **Performance Optimizations:**
   - [List performance optimization opportunities]

4. **Future Testing:**
   - [Recommendations for future test cycles]

5. **Documentation Updates:**
   - [Suggested updates to user documentation]

**Conclusion**

[Overall assessment of the video call system quality, readiness for production, 
and any conditions or caveats for release]

**Appendices**

- Appendix A: Complete Test Scenario List
- Appendix B: Evidence Index
- Appendix C: Firestore Log Analysis
- Appendix D: Agora Analytics Reports
- Appendix E: Device Log Excerpts

