# VoIP Integration Testing Guide

## Overview

VoIPCallService uses `flutter_callkit_incoming` which provides native iOS CallKit and Android ConnectionService integration. These features require actual device testing or emulator testing with proper platform channel setup.

## Why Integration Testing is Required

### Platform Channel Dependencies
- **iOS CallKit**: Native iOS framework for VoIP calls
- **Android ConnectionService**: Native Android service for call management
- **flutter_callkit_incoming**: Flutter plugin that bridges to native code

### Limitations of Unit Testing
1. Platform channels cannot be fully mocked in unit tests
2. CallKit/ConnectionService behavior varies by OS version
3. Background/killed app scenarios require actual app lifecycle
4. Push notification integration needs real FCM setup
5. Native UI (incoming call screen) cannot be tested in unit tests

## Current Unit Test Coverage

The unit tests in `test/unit/services/voip_call_service_test.dart` cover:
- ✅ API structure verification
- ✅ Data model validation (PendingCallData, VoIPCallEvent)
- ✅ Event type definitions
- ✅ Singleton pattern
- ✅ Stream setup
- ✅ Parameter validation
- ✅ Error type definitions

**Coverage**: ~31/254 lines (12.2%) - Focused on structure and validation

## Integration Test Scenarios

### Priority 1: Core Call Flow (Critical)

#### Test 1: Incoming Call - App in Foreground
```dart
// Scenario: User receives call while app is open
// Expected: CallKit UI appears, user can accept/decline
// Verify: 
// - Native call UI displays
// - Caller name and avatar shown correctly
// - Accept button navigates to video call screen
// - Decline button dismisses call
```

#### Test 2: Incoming Call - App in Background
```dart
// Scenario: User receives call while app is backgrounded
// Expected: CallKit UI appears over lock screen
// Verify:
// - Call notification appears
// - Accept opens app and starts call
// - Decline dismisses without opening app
```

#### Test 3: Incoming Call - App Killed (Cold Start)
```dart
// Scenario: User receives call while app is completely closed
// Expected: App launches and call connects
// Verify:
// - App launches from killed state
// - Pending call data is restored
// - Video call screen opens with correct data
// - Agora connection established
```

### Priority 2: Call State Management

#### Test 4: Accept Call Flow
```dart
// Scenario: User accepts incoming call
// Expected: Navigate to video call screen with Agora data
// Verify:
// - PendingCallData contains agoraToken, channelName, uid
// - Navigation to AgoraVideoCallScreen occurs
// - Call state updated to 'accepted'
// - Event emitted through callEventStream
```

#### Test 5: Decline Call Flow
```dart
// Scenario: User declines incoming call
// Expected: Call dismissed, server notified
// Verify:
// - CallKit UI dismissed
// - Server receives decline notification
// - Call state cleared
// - Event emitted through callEventStream
```

#### Test 6: Missed Call (Timeout)
```dart
// Scenario: User doesn't answer within timeout period
// Expected: Call marked as missed, notification sent
// Verify:
// - Call automatically ends after timeout
// - Server receives missed call notification
// - Local notification shown (optional)
// - Call state cleared
```

### Priority 3: Multiple Calls & Edge Cases

#### Test 7: Multiple Incoming Calls
```dart
// Scenario: Second call arrives while first is active
// Expected: Second call rejected or queued
// Verify:
// - Only one active call at a time
// - Second call handled appropriately
// - No state corruption
```

#### Test 8: Network Failure During Call Setup
```dart
// Scenario: Network drops while accepting call
// Expected: Graceful error handling
// Verify:
// - User sees error message
// - Call state cleaned up
// - Can retry or dismiss
```

#### Test 9: Cleanup After Call Ends
```dart
// Scenario: Call ends normally
// Expected: All resources cleaned up
// Verify:
// - currentCallId set to null
// - pendingCallData cleared
// - Event stream notified
// - No memory leaks
```

### Priority 4: Platform-Specific Features

#### Test 10: iOS CallKit Integration
```dart
// iOS Only
// Verify:
// - CallKit UI matches iOS design
// - Integrates with phone app
// - Shows in recent calls
// - Respects Do Not Disturb
```

#### Test 11: Android ConnectionService Integration
```dart
// Android Only
// Verify:
// - ConnectionService UI appears
// - Integrates with phone app
// - Shows in call log
// - Respects Do Not Disturb
```

## Test Environment Setup

### Prerequisites
1. **Physical Devices** (Recommended)
   - iOS device (iPhone 8 or newer, iOS 13+)
   - Android device (Android 8.0+)
   - Both devices with active SIM cards (for CallKit/ConnectionService)

2. **Emulators** (Limited Testing)
   - iOS Simulator (CallKit partially works)
   - Android Emulator (ConnectionService limited)

3. **Firebase Setup**
   - FCM configured for high-priority notifications
   - Cloud Functions deployed for call notifications
   - Test accounts in Firestore

4. **Agora Setup**
   - Test Agora project
   - Token generation working
   - Test channels available

### Test Data Requirements
```dart
// Sample test data
final testCallData = {
  'callerName': 'Dr. Test Doctor',
  'callerAvatar': 'https://example.com/avatar.jpg',
  'appointmentId': 'apt_test_123',
  'agoraToken': 'test_token_abc123',
  'agoraChannelName': 'test_channel_456',
  'agoraUid': 12345,
};
```

## Running Integration Tests

### Option 1: Manual Device Testing
```bash
# 1. Deploy to device
flutter run --release

# 2. Trigger test call from backend
# Use Firebase Console or Cloud Functions

# 3. Verify behavior manually
# Follow test scenarios above
```

### Option 2: Flutter Integration Tests
```bash
# Create integration test file
# test/integration/voip_call_flow_test.dart

# Run on device
flutter test integration_test/voip_call_flow_test.dart
```

### Option 3: Automated Testing with patrol
```bash
# Add patrol package for native UI testing
flutter pub add patrol --dev

# Run patrol tests
patrol test
```

## Test Checklist

### Before Testing
- [ ] Firebase project configured
- [ ] FCM tokens working
- [ ] Cloud Functions deployed
- [ ] Agora credentials valid
- [ ] Test devices ready
- [ ] Test accounts created

### During Testing
- [ ] Test each scenario on iOS
- [ ] Test each scenario on Android
- [ ] Test with good network
- [ ] Test with poor network
- [ ] Test with no network
- [ ] Test app in foreground
- [ ] Test app in background
- [ ] Test app killed (cold start)

### After Testing
- [ ] Document any issues found
- [ ] Update test scenarios if needed
- [ ] Record test results
- [ ] Update VoIP service if bugs found

## Known Limitations

### iOS Simulator
- CallKit works but with limitations
- Cannot test actual phone integration
- Push notifications may not work reliably

### Android Emulator
- ConnectionService limited functionality
- May not show native call UI
- Push notifications require Google Play Services

### Unit Tests
- Cannot test platform channel behavior
- Cannot test native UI
- Cannot test background/killed app scenarios
- Cannot test push notification integration

## Recommended Testing Strategy

1. **Unit Tests** (Current): Structure, validation, data models
2. **Widget Tests**: VoIP UI components (if any)
3. **Integration Tests**: Full call flow on real devices
4. **Manual Testing**: Edge cases and platform-specific features
5. **Beta Testing**: Real-world usage with test users

## Resources

- [flutter_callkit_incoming Documentation](https://pub.dev/packages/flutter_callkit_incoming)
- [iOS CallKit Framework](https://developer.apple.com/documentation/callkit)
- [Android ConnectionService](https://developer.android.com/reference/android/telecom/ConnectionService)
- [Flutter Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Patrol Testing Framework](https://patrol.leancode.co/)

## Next Steps

1. Set up integration test environment
2. Create integration test file structure
3. Implement Priority 1 scenarios
4. Run tests on physical devices
5. Document results and issues
6. Iterate and improve

---

**Note**: VoIP testing is complex and time-consuming. Prioritize critical paths (incoming call, accept, decline) and test on real devices for accurate results.
