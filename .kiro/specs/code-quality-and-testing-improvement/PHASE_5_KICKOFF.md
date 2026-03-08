# Phase 5: Integration Tests - KICKOFF 🚀

## Overview

Phase 5 focuses on integration testing for platform-dependent services and end-to-end user flows. This phase addresses the limitations identified in Phases 2 and 4 where platform-specific code couldn't be adequately tested in unit tests.

**Duration**: Week 5 (5-7 days)  
**Target**: Complete integration test coverage for platform services and critical flows  
**Expected Tests**: 30-50 integration tests  
**Platforms**: Android + iOS (with Web considerations)

---

## Lessons from Previous Phases

### From Phase 2: Platform Service Limitations
During Phase 2, we identified that several services have platform dependencies that limit unit test coverage:

1. **NotificationService**: Requires real notification channels
2. **AgoraService**: Requires real RTC engine initialization
3. **FCMService**: Requires Firebase messaging setup
4. **VoIPCallService**: Requires CallKit/ConnectionService
5. **FirebaseAuthService**: Requires real Firebase authentication

### From Phase 4: Provider Platform Dependencies
During Phase 4, we identified provider features that require integration testing:

1. **AuthProvider**: 
   - Biometric authentication
   - Background service initialization
   - Secure storage operations
   - Successful login/registration flows

2. **AppointmentsProvider** (deferred):
   - CRUD operations with real Firestore
   - Notification integration
   - Conflict detection
   - Real-time updates

---

## Integration Testing Strategy

### What is Integration Testing?

Integration tests verify that multiple components work together correctly, including:
- Platform-specific code (biometrics, notifications, etc.)
- Database operations (Firestore)
- Network operations (Firebase, Agora)
- Service interactions
- End-to-end user flows

### Key Differences from Unit Tests

| Aspect | Unit Tests | Integration Tests |
|--------|-----------|-------------------|
| **Scope** | Single component | Multiple components |
| **Dependencies** | Mocked | Real or test doubles |
| **Platform** | Platform-independent | Platform-specific |
| **Speed** | Fast (milliseconds) | Slower (seconds) |
| **Environment** | Isolated | Requires setup |
| **Flakiness** | Low | Higher (network, timing) |

---

## Phase 5 Focus Areas

### Priority 1: Platform-Dependent Services (from Phase 2)

#### 1. NotificationService Integration Tests
- **Current Status**: Unit tests limited by platform channels
- **Integration Tests Needed**: 10-15 tests
- **Complexity**: Medium

**Key Scenarios**:
- Display local notifications on real device
- Handle notification taps
- Schedule notifications
- Cancel notifications
- Notification channels (Android)
- Notification permissions

**Platform-Specific**:
- Android: Notification channels, importance levels
- iOS: Notification categories, authorization

---

#### 2. AgoraService Integration Tests
- **Current Status**: Unit tests limited by RTC engine
- **Integration Tests Needed**: 8-12 tests
- **Complexity**: High

**Key Scenarios**:
- Initialize Agora engine with real credentials
- Join/leave channels
- Mute/unmute audio/video
- Switch camera
- Handle network interruptions
- Token expiration

**Platform-Specific**:
- Android: Camera/microphone permissions
- iOS: Camera/microphone permissions, CallKit integration

---

#### 3. FCMService Integration Tests
- **Current Status**: Unit tests limited by Firebase messaging
- **Integration Tests Needed**: 6-10 tests
- **Complexity**: Medium

**Key Scenarios**:
- Receive FCM messages
- Handle foreground messages
- Handle background messages
- Token refresh
- Topic subscription
- Message data extraction

**Platform-Specific**:
- Android: Background message handling
- iOS: APNs integration, notification permissions

---

#### 4. VoIPCallService Integration Tests
- **Current Status**: Unit tests limited by CallKit/ConnectionService
- **Integration Tests Needed**: 10-15 tests
- **Complexity**: High

**Key Scenarios**:
- Display incoming call UI
- Accept/decline calls
- End active calls
- Handle call interruptions
- Background call handling
- CallKit/ConnectionService integration

**Platform-Specific**:
- Android: ConnectionService, full-screen intent
- iOS: CallKit, PushKit

---

#### 5. FirebaseAuthService Integration Tests
- **Current Status**: Basic unit tests exist
- **Integration Tests Needed**: 8-12 tests
- **Complexity**: Medium

**Key Scenarios**:
- Sign in with email/password
- Sign up new users
- Sign out
- Password reset
- Email verification
- Session persistence

**Platform-Specific**:
- All platforms: Firebase emulator or test project

---

### Priority 2: Provider Integration Tests (from Phase 4)

#### 6. AuthProvider Integration Tests
- **Current Status**: Core unit tests complete, platform features blocked
- **Integration Tests Needed**: 10-15 tests
- **Complexity**: High

**Key Scenarios**:
- Successful login with background service
- Successful registration with background service
- Biometric authentication flow
- Secure storage operations
- Session persistence across app restarts
- Token refresh

**Platform-Specific**:
- Android: Biometric prompt, background service
- iOS: Face ID/Touch ID, background tasks

---

#### 7. AppointmentsProvider Integration Tests
- **Current Status**: Not tested (deferred from Phase 4)
- **Integration Tests Needed**: 15-20 tests
- **Complexity**: High

**Key Scenarios**:
- Create appointment with Firestore
- Load appointments (patient/doctor)
- Update appointment
- Cancel appointment
- Conflict detection with real data
- Notification integration
- Real-time updates

**Platform-Specific**:
- All platforms: Firestore operations, real-time listeners

---

### Priority 3: End-to-End User Flows

#### 8. Authentication Flow
- **Tests Needed**: 5-8 tests
- **Complexity**: Medium

**Scenarios**:
- Complete registration → login → logout flow
- Login → biometric setup → biometric login
- Password reset flow
- Session expiration handling

---

#### 9. Appointment Booking Flow
- **Tests Needed**: 8-12 tests
- **Complexity**: High

**Scenarios**:
- Patient: Browse doctors → book appointment → receive notification
- Doctor: Receive appointment → accept → start call
- Conflict detection during booking
- Appointment cancellation flow

---

#### 10. Video Call Flow
- **Tests Needed**: 10-15 tests
- **Complexity**: Very High

**Scenarios**:
- Incoming call → accept → video call → end call
- Incoming call → decline
- Call with network interruption
- Call with camera/mic toggle
- Background call handling

---

## Test Environment Setup

### 1. Firebase Test Project

**Requirements**:
- Separate Firebase project for testing
- Test Firestore database
- Test authentication users
- Test FCM configuration

**Setup**:
```bash
# Create test Firebase project
# Configure test google-services.json (Android)
# Configure test GoogleService-Info.plist (iOS)
# Set up Firestore security rules for testing
```

### 2. Agora Test Credentials

**Requirements**:
- Test Agora App ID
- Test token generation
- Test channel names

**Setup**:
```dart
// test/integration/config/agora_test_config.dart
class AgoraTestConfig {
  static const String testAppId = 'test_app_id';
  static const String testToken = 'test_token';
  static const String testChannelName = 'test_channel';
}
```

### 3. Test Devices

**Requirements**:
- Android physical device or emulator (API 21+)
- iOS physical device or simulator (iOS 12+)
- Permissions granted (camera, microphone, notifications)

### 4. Test Data

**Requirements**:
- Test user accounts
- Test patient/doctor profiles
- Test appointments
- Test call records

---

## Integration Test Structure

### Directory Structure

```
test/
├── integration/
│   ├── config/
│   │   ├── test_config.dart
│   │   ├── firebase_test_config.dart
│   │   └── agora_test_config.dart
│   ├── helpers/
│   │   ├── test_helpers.dart
│   │   ├── firebase_helpers.dart
│   │   └── permission_helpers.dart
│   ├── services/
│   │   ├── notification_service_integration_test.dart
│   │   ├── agora_service_integration_test.dart
│   │   ├── fcm_service_integration_test.dart
│   │   ├── voip_service_integration_test.dart
│   │   └── firebase_auth_service_integration_test.dart
│   ├── providers/
│   │   ├── auth_provider_integration_test.dart
│   │   └── appointments_provider_integration_test.dart
│   ├── flows/
│   │   ├── authentication_flow_test.dart
│   │   ├── appointment_booking_flow_test.dart
│   │   └── video_call_flow_test.dart
│   └── README.md
```

### Test Template

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../config/test_config.dart';
import '../helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Service Integration Tests', () {
    setUpAll(() async {
      // Initialize test environment
      await TestHelpers.initializeTestEnvironment();
    });

    tearDownAll(() async {
      // Clean up test environment
      await TestHelpers.cleanupTestEnvironment();
    });

    testWidgets('should perform action on real device', (tester) async {
      // Arrange
      await TestHelpers.setupTestData();

      // Act
      // Perform actions

      // Assert
      // Verify results

      // Cleanup
      await TestHelpers.cleanupTestData();
    });
  });
}
```

---

## Success Metrics

### Quantitative Metrics

| Metric | Target | Rationale |
|--------|--------|-----------|
| **Platform services tested** | 5/5 | Complete platform coverage |
| **Provider flows tested** | 2/2 | Auth + Appointments |
| **End-to-end flows tested** | 3/3 | Critical user journeys |
| **Integration tests created** | 30-50 | Comprehensive coverage |
| **Test pass rate** | 90%+ | Account for flakiness |
| **Platforms tested** | 2/2 | Android + iOS |

### Qualitative Metrics

| Metric | Target | Rationale |
|--------|--------|-----------|
| **Platform features validated** | Complete | Real device testing |
| **Network scenarios tested** | Complete | Offline, slow, interrupted |
| **Permission flows tested** | Complete | All permission types |
| **Error recovery tested** | Complete | Graceful degradation |
| **Documentation** | Complete | Setup + troubleshooting |

---

## Daily Schedule

### Day 1: Setup + NotificationService (8 hours)

**Morning (4 hours)**:
- Set up Firebase test project
- Configure test environment
- Create test helpers
- Set up test data

**Afternoon (4 hours)**:
- NotificationService integration tests
- Test on Android device
- Test on iOS device
- Document platform differences

**Expected Output**:
- Test environment ready
- 10-15 notification tests
- Platform-specific documentation

---

### Day 2: AgoraService + FCMService (8 hours)

**Morning (4 hours)**:
- AgoraService integration tests
- Test video call initialization
- Test audio/video controls
- Test network scenarios

**Afternoon (4 hours)**:
- FCMService integration tests
- Test message reception
- Test background handling
- Test token management

**Expected Output**:
- 8-12 Agora tests
- 6-10 FCM tests
- Network scenario documentation

---

### Day 3: VoIPCallService + FirebaseAuthService (8 hours)

**Morning (4 hours)**:
- VoIPCallService integration tests
- Test incoming call UI
- Test CallKit/ConnectionService
- Test background calls

**Afternoon (4 hours)**:
- FirebaseAuthService integration tests
- Test authentication flows
- Test session persistence
- Test error scenarios

**Expected Output**:
- 10-15 VoIP tests
- 8-12 Auth service tests
- CallKit/ConnectionService documentation

---

### Day 4: AuthProvider + AppointmentsProvider (8 hours)

**Morning (4 hours)**:
- AuthProvider integration tests
- Test biometric authentication
- Test background service
- Test secure storage

**Afternoon (4 hours)**:
- AppointmentsProvider integration tests
- Test CRUD operations
- Test conflict detection
- Test real-time updates

**Expected Output**:
- 10-15 AuthProvider tests
- 15-20 AppointmentsProvider tests
- Biometric flow documentation

---

### Day 5: End-to-End Flows (8 hours)

**Morning (4 hours)**:
- Authentication flow tests
- Appointment booking flow tests
- Test complete user journeys

**Afternoon (4 hours)**:
- Video call flow tests
- Test call scenarios
- Test interruption handling

**Expected Output**:
- 5-8 authentication flow tests
- 8-12 appointment flow tests
- 10-15 video call flow tests

---

### Day 6-7: Buffer + Documentation (8-16 hours)

**Activities**:
- Fix flaky tests
- Add missing scenarios
- Test on multiple devices
- Create troubleshooting guide
- Document platform-specific issues
- Create Phase 5 summary

---

## Testing Best Practices

### 1. Test Isolation

```dart
setUp(() async {
  // Create fresh test data
  await TestHelpers.createTestUser();
  await TestHelpers.createTestAppointment();
});

tearDown() async {
  // Clean up test data
  await TestHelpers.deleteTestUser();
  await TestHelpers.deleteTestAppointment();
});
```

### 2. Handle Async Operations

```dart
testWidgets('should load data', (tester) async {
  // Trigger action
  await tester.tap(find.byKey(Key('load_button')));
  await tester.pumpAndSettle();

  // Wait for async operation
  await tester.pump(Duration(seconds: 2));

  // Verify result
  expect(find.text('Data loaded'), findsOneWidget);
});
```

### 3. Handle Permissions

```dart
setUpAll(() async {
  // Request permissions before tests
  await TestHelpers.grantCameraPermission();
  await TestHelpers.grantMicrophonePermission();
  await TestHelpers.grantNotificationPermission();
});
```

### 4. Handle Flakiness

```dart
testWidgets('should handle network request', (tester) async {
  // Retry logic for flaky tests
  await tester.runAsync(() async {
    for (int i = 0; i < 3; i++) {
      try {
        await performNetworkRequest();
        break;
      } catch (e) {
        if (i == 2) rethrow;
        await Future.delayed(Duration(seconds: 1));
      }
    }
  });
});
```

---

## Platform-Specific Considerations

### Android

**Permissions**:
- Camera, Microphone, Notifications
- Background location (if needed)
- Phone state (for VoIP)

**Platform Features**:
- Notification channels
- ConnectionService
- Background services
- Full-screen intents

**Testing Tools**:
- Android Emulator (API 21+)
- Physical device recommended for VoIP

### iOS

**Permissions**:
- Camera, Microphone, Notifications
- Face ID/Touch ID
- Background modes

**Platform Features**:
- CallKit
- PushKit
- Background tasks
- Notification categories

**Testing Tools**:
- iOS Simulator (iOS 12+)
- Physical device required for biometrics and VoIP

### Web (Considerations)

**Limitations**:
- No biometric authentication
- No CallKit/ConnectionService
- Limited background processing
- Different notification API

**Testing Approach**:
- Focus on core functionality
- Test web-specific features
- Document limitations

---

## Risk Mitigation

### Known Challenges

1. **Test Flakiness**
   - Challenge: Network timing, platform delays
   - Mitigation: Retry logic, generous timeouts
   - Impact: Medium

2. **Platform Differences**
   - Challenge: Different behavior on Android/iOS
   - Mitigation: Platform-specific tests, documentation
   - Impact: Medium

3. **Test Environment Setup**
   - Challenge: Firebase, Agora configuration
   - Mitigation: Detailed setup guide, automation
   - Impact: High

4. **Device Requirements**
   - Challenge: Need physical devices for some tests
   - Mitigation: Prioritize critical tests, document requirements
   - Impact: Medium

5. **Test Data Management**
   - Challenge: Creating/cleaning test data
   - Mitigation: Test helpers, automated cleanup
   - Impact: Low

---

## Success Criteria

### Quantitative
- ✅ 5/5 platform services have integration tests
- ✅ 2/2 providers have integration tests
- ✅ 3/3 end-to-end flows tested
- ✅ 30-50 integration tests created
- ✅ 90%+ test pass rate
- ✅ Tests run on Android + iOS

### Qualitative
- ✅ Platform features validated on real devices
- ✅ Network scenarios tested
- ✅ Permission flows tested
- ✅ Error recovery tested
- ✅ Comprehensive documentation
- ✅ Troubleshooting guide created

---

## Expected Outcomes

### By End of Phase 5

**Test Coverage**:
- NotificationService: Complete integration tests
- AgoraService: Complete integration tests
- FCMService: Complete integration tests
- VoIPCallService: Complete integration tests
- FirebaseAuthService: Complete integration tests
- AuthProvider: Platform features tested
- AppointmentsProvider: Complete integration tests

**Documentation**:
- Integration test setup guide
- Platform-specific testing guide
- Troubleshooting guide
- Phase 5 summary report

**Quality**:
- 30-50 integration tests
- 90%+ pass rate
- Platform-validated features
- Clear documentation

---

## Getting Started

### Prerequisites

1. **Development Environment**:
   - Flutter SDK installed
   - Android Studio / Xcode configured
   - Physical devices or emulators ready

2. **Test Projects**:
   - Firebase test project created
   - Agora test credentials obtained
   - Test accounts created

3. **Permissions**:
   - Camera, microphone access
   - Notification permissions
   - Biometric permissions (iOS)

### Step 1: Environment Setup

```bash
# Install integration_test package
flutter pub add integration_test --dev

# Create test directories
mkdir -p test/integration/{config,helpers,services,providers,flows}

# Configure Firebase test project
# Add test google-services.json
# Add test GoogleService-Info.plist
```

### Step 2: Create Test Helpers

```dart
// test/integration/helpers/test_helpers.dart
class TestHelpers {
  static Future<void> initializeTestEnvironment() async {
    // Initialize Firebase
    // Initialize test data
    // Grant permissions
  }
  
  static Future<void> cleanupTestEnvironment() async {
    // Delete test data
    // Sign out users
    // Reset state
  }
}
```

### Step 3: Start with Day 1

Begin with NotificationService integration tests (simplest platform service).

---

## Phase 5 Status: 🚀 **READY TO START**

Let's validate platform-dependent features and complete our testing coverage!

---

*Phase 5 Kickoff Document*  
*Created*: February 12, 2026  
*Target*: Complete integration test coverage  
*Duration*: 5-7 days  
*Expected Tests*: 30-50 integration tests
