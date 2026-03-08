# NotificationService Integration Testing Guide

## Overview

NotificationService uses `flutter_local_notifications` which provides platform-specific notification functionality through native iOS UserNotifications framework and Android NotificationManager. These features require actual device or emulator testing with proper platform channel setup.

## Why Integration Testing is Required

### Platform Channel Dependencies
- **iOS UserNotifications**: Native iOS framework for local notifications
- **Android NotificationManager**: Native Android service for notification management
- **flutter_local_notifications**: Flutter plugin that bridges to native code

### Limitations of Unit Testing
1. Platform channels cannot be fully mocked in unit tests
2. Notification behavior varies by OS version and device settings
3. Notification channels (Android 8.0+) require actual platform APIs
4. Permission handling needs real platform permission systems
5. Scheduled notifications require actual system scheduling
6. Notification display and interaction cannot be tested in unit tests

## Current Test Coverage

The integration tests in `test/integration/notification_service_integration_test.dart` cover:
- ✅ Service initialization and singleton pattern
- ✅ Local notification display
- ✅ Multiple notification handling
- ✅ Scheduled notification delivery
- ✅ Notification cancellation (specific and all)
- ✅ Special character and Arabic text support
- ✅ Long text handling
- ✅ Notification replacement (same ID)
- ✅ Rapid successive notifications
- ✅ Edge cases (empty fields, past dates)
- ✅ Platform-specific features (Android channels, iOS permissions)

**Total Tests**: 15 core tests + 5 platform-specific tests = 20 integration tests

## Integration Test Scenarios

### Priority 1: Core Notification Functionality (Critical)

#### Test 1: Service Initialization
```dart
// Scenario: NotificationService initializes successfully
// Expected: Service instance created, plugin initialized
// Verify: 
// - Service is not null
// - Plugin is not null
// - Initialization completes without errors
```

#### Test 2: Display Local Notification
```dart
// Scenario: Display a simple local notification
// Expected: Notification appears in system tray
// Verify:
// - Notification displays with correct title and body
// - Method completes without errors
// - Notification is visible to user
```

#### Test 3: Display Multiple Notifications
```dart
// Scenario: Display multiple notifications with different IDs
// Expected: All notifications appear separately
// Verify:
// - Each notification has unique ID
// - All notifications display correctly
// - No conflicts between notifications
```

#### Test 4: Schedule Future Notification
```dart
// Scenario: Schedule notification for future delivery
// Expected: Notification scheduled and delivered at specified time
// Verify:
// - Scheduling completes without errors
// - Notification delivers at correct time
// - Scheduled notification appears in system
```

### Priority 2: Notification Management

#### Test 5: Schedule Notification - Past Date Handling
```dart
// Scenario: Attempt to schedule notification with past date
// Expected: Graceful handling, no notification scheduled
// Verify:
// - Method completes without errors
// - No notification is scheduled
// - No exceptions thrown
```

#### Test 6: Cancel Specific Notification
```dart
// Scenario: Cancel a specific notification by ID
// Expected: Notification removed from system tray
// Verify:
// - Cancellation completes without errors
// - Notification is removed
// - Other notifications remain unaffected
```

#### Test 7: Cancel All Notifications
```dart
// Scenario: Cancel all active notifications
// Expected: All notifications removed
// Verify:
// - All notifications cleared
// - System tray is empty
// - Method completes without errors
```

### Priority 3: Content Handling

#### Test 8: Notification with Special Characters
```dart
// Scenario: Display notification with Arabic text and emojis
// Expected: Text displays correctly with proper encoding
// Verify:
// - Arabic text renders correctly (RTL)
// - Emojis display properly
// - No encoding issues
```

#### Test 9: Notification with Long Text
```dart
// Scenario: Display notification with very long title and body
// Expected: Text truncated or wrapped appropriately
// Verify:
// - Long text handled gracefully
// - Notification displays without errors
// - Text is readable
```

#### Test 10: Replace Existing Notification
```dart
// Scenario: Display new notification with same ID as existing
// Expected: Original notification replaced with new content
// Verify:
// - Only one notification visible (not duplicated)
// - Content updated to new values
// - Replacement occurs smoothly
```

### Priority 4: Advanced Scenarios

#### Test 11: Schedule Multiple Notifications
```dart
// Scenario: Schedule multiple notifications at different times
// Expected: All notifications scheduled correctly
// Verify:
// - Each notification scheduled independently
// - No conflicts between scheduled notifications
// - All deliver at correct times
```

#### Test 12: Cancel Scheduled Notification Before Delivery
```dart
// Scenario: Cancel a scheduled notification before it delivers
// Expected: Notification removed from schedule
// Verify:
// - Cancellation completes without errors
// - Notification does not deliver
// - Schedule is updated
```

#### Test 13: Notification Service Singleton Pattern
```dart
// Scenario: Verify singleton pattern implementation
// Expected: Same instance returned on multiple calls
// Verify:
// - Multiple calls return identical instance
// - Singleton pattern enforced
// - State is shared across calls
```

#### Test 14: Rapid Notification Display
```dart
// Scenario: Display many notifications in rapid succession
// Expected: All notifications handled without errors
// Verify:
// - System handles rapid requests
// - No notifications lost
// - No performance degradation
```

#### Test 15: Empty Title and Body Handling
```dart
// Scenario: Display notifications with empty fields
// Expected: Graceful handling of edge cases
// Verify:
// - Empty title handled correctly
// - Empty body handled correctly
// - Both empty handled correctly
```

### Priority 5: Platform-Specific Features

#### Test 16-18: Android-Specific Tests
```dart
// Android Only
// Verify:
// - Notification channels created during initialization
// - High-priority notifications display correctly
// - Incoming call channel created with max importance
// - Channel settings respected by system
```

#### Test 19-20: iOS-Specific Tests
```dart
// iOS Only
// Verify:
// - Notification permissions requested during initialization
// - Darwin (iOS) settings applied correctly
// - Notifications display with iOS styling
// - Permission status handled appropriately
```

## Test Environment Setup

### Prerequisites

#### 1. Physical Devices (Recommended)
- **Android device**: Android 8.0+ (API 26+) for notification channels
- **iOS device**: iOS 10+ for UserNotifications framework
- Both devices with notification permissions enabled

#### 2. Emulators (Acceptable)
- **Android Emulator**: API 26+ with Google Play Services
- **iOS Simulator**: iOS 13+ (notifications work in simulator)

#### 3. Flutter Setup
```bash
# Ensure integration_test package is added
flutter pub add integration_test --dev

# Ensure flutter_local_notifications is up to date
flutter pub get
```

#### 4. Timezone Data
The NotificationService uses timezone package for scheduled notifications:
- Timezone data initialized during service initialization
- Default timezone: Asia/Riyadh (Saudi Arabia)
- Fallback handling included

### Test Data Requirements

```dart
// Sample notification data
const testNotification = {
  'id': 1001,
  'title': 'Test Notification',
  'body': 'This is a test notification',
};

// Sample scheduled notification
final scheduledNotification = {
  'id': 2001,
  'title': 'Scheduled Reminder',
  'body': 'This is a scheduled notification',
  'scheduledDate': DateTime.now().add(Duration(seconds: 10)),
};

// Sample Arabic notification
const arabicNotification = {
  'id': 3001,
  'title': 'إشعار اختبار',
  'body': 'هذا إشعار تجريبي يحتوي على نص عربي',
};
```

## Running Integration Tests

### Option 1: Run on Android Device/Emulator

```bash
# Connect Android device or start emulator
adb devices

# Run integration tests
flutter test integration_test/notification_service_integration_test.dart

# Run with verbose output
flutter test integration_test/notification_service_integration_test.dart --verbose
```

### Option 2: Run on iOS Device/Simulator

```bash
# List available iOS simulators
xcrun simctl list devices

# Run integration tests
flutter test integration_test/notification_service_integration_test.dart -d <device-id>

# Run on physical iOS device
flutter test integration_test/notification_service_integration_test.dart -d <device-name>
```

### Option 3: Run All Integration Tests

```bash
# Run all integration tests including notification tests
flutter test integration_test/

# Generate coverage report
flutter test integration_test/ --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Manual Verification Steps

While integration tests verify that methods complete without errors, some aspects require manual verification:

### Visual Verification Checklist

#### Android
- [ ] Notification appears in status bar
- [ ] Notification displays in notification drawer
- [ ] Notification icon is correct (@mipmap/ic_launcher)
- [ ] Notification title and body are readable
- [ ] Arabic text displays correctly (RTL)
- [ ] Notification channels visible in app settings
- [ ] High-priority notifications show heads-up display
- [ ] Scheduled notifications deliver at correct time
- [ ] Cancelled notifications disappear from drawer

#### iOS
- [ ] Notification appears in notification center
- [ ] Notification displays on lock screen (if unlocked)
- [ ] Notification banner appears (if enabled)
- [ ] Notification title and body are readable
- [ ] Arabic text displays correctly (RTL)
- [ ] Permission prompt appears on first run
- [ ] Scheduled notifications deliver at correct time
- [ ] Cancelled notifications disappear from center

## Platform-Specific Considerations

### Android (API 26+)

#### Notification Channels
The NotificationService creates the following channels:

1. **main_channel** (General Notifications)
   - Importance: Max
   - Priority: High
   - Used for: General app notifications

2. **incoming_calls** (Incoming Calls)
   - Importance: Max
   - Priority: High
   - Features: Lights enabled
   - Used for: VoIP call notifications

3. **scheduled_channel** (Scheduled Reminders)
   - Importance: Max
   - Priority: High
   - Used for: Appointment reminders

#### Permissions
- `POST_NOTIFICATIONS` (Android 13+): Requested automatically
- `SCHEDULE_EXACT_ALARM`: Not requested (uses `exactAllowWhileIdle` mode)

#### Testing Notes
- Test on Android 8.0+ for channel support
- Test on Android 13+ for permission handling
- Verify channel settings in: Settings > Apps > AndroCare360 > Notifications

### iOS (iOS 10+)

#### Notification Settings
- Uses `DarwinInitializationSettings` for iOS configuration
- Permissions requested during initialization
- Supports notification categories (future enhancement)

#### Permissions
- Alert permission: Requested automatically
- Sound permission: Requested automatically
- Badge permission: Requested automatically

#### Testing Notes
- Test on iOS 10+ for UserNotifications framework
- Test permission prompt on first launch
- Verify notifications in: Settings > Notifications > AndroCare360

## Known Limitations

### Integration Test Limitations
1. **Cannot verify actual notification display**: Tests verify methods complete without errors but cannot programmatically check if notification appears in system tray
2. **Cannot test notification taps**: Tap handling requires user interaction testing
3. **Cannot test notification actions**: Action buttons require additional setup
4. **Cannot test notification sounds**: Sound playback verification requires manual testing
5. **Cannot test Do Not Disturb**: DND mode behavior requires manual testing

### Platform Limitations
1. **Android Emulator**: May not show heads-up notifications consistently
2. **iOS Simulator**: Cannot test push notifications (local notifications work)
3. **Background delivery**: Scheduled notifications may be delayed by system battery optimization
4. **Permission denial**: Tests assume permissions granted; denial scenarios require manual testing

## Troubleshooting

### Issue: Notifications Not Appearing

**Possible Causes:**
1. Notification permissions not granted
2. Do Not Disturb mode enabled
3. App notifications disabled in system settings
4. Battery optimization preventing background delivery

**Solutions:**
- Check app notification permissions in system settings
- Disable Do Not Disturb mode during testing
- Disable battery optimization for the app
- Verify notification channels are enabled (Android)

### Issue: Scheduled Notifications Not Delivering

**Possible Causes:**
1. Device in power-saving mode
2. App killed by system
3. Timezone configuration issues
4. Exact alarm permission not granted (Android 12+)

**Solutions:**
- Keep device plugged in during testing
- Disable battery optimization
- Verify timezone initialization in service
- Use `exactAllowWhileIdle` mode (already implemented)

### Issue: Arabic Text Not Displaying Correctly

**Possible Causes:**
1. Font not supporting Arabic characters
2. RTL layout not applied
3. Encoding issues

**Solutions:**
- Verify device supports Arabic fonts
- Check system language settings
- Ensure UTF-8 encoding in notification data

### Issue: Integration Tests Timing Out

**Possible Causes:**
1. Platform channel initialization slow
2. Permission dialogs blocking execution
3. Network issues (if service requires connectivity)

**Solutions:**
- Increase test timeout duration
- Grant permissions before running tests
- Ensure device has stable connectivity

## Test Execution Checklist

### Before Testing
- [ ] Device/emulator running and connected
- [ ] App installed on device
- [ ] Notification permissions granted
- [ ] Do Not Disturb mode disabled
- [ ] Battery optimization disabled for app
- [ ] System time and timezone correct

### During Testing
- [ ] Monitor device notification tray
- [ ] Check for permission prompts
- [ ] Verify notification appearance
- [ ] Test scheduled notification delivery
- [ ] Test notification cancellation
- [ ] Verify Arabic text rendering
- [ ] Check notification channel settings (Android)

### After Testing
- [ ] Review test results
- [ ] Document any failures
- [ ] Verify all notifications cleared
- [ ] Check for memory leaks
- [ ] Review platform-specific behavior

## Best Practices

1. **Clean State**: Always clear notifications before and after each test
2. **Delays**: Add small delays between rapid operations to allow platform processing
3. **Unique IDs**: Use unique notification IDs to avoid conflicts
4. **Manual Verification**: Supplement automated tests with manual visual verification
5. **Platform Testing**: Test on both Android and iOS to verify platform-specific behavior
6. **Real Devices**: Use physical devices for final validation
7. **Permission Handling**: Ensure permissions granted before running tests
8. **Timezone Awareness**: Be aware of timezone differences in scheduled notifications

## Success Criteria

Integration tests are considered successful when:
- ✅ All 20 tests pass without errors
- ✅ Notifications display correctly on both platforms
- ✅ Scheduled notifications deliver at correct times
- ✅ Cancellation works for both active and scheduled notifications
- ✅ Arabic text renders correctly
- ✅ Platform-specific features work as expected
- ✅ No memory leaks or performance issues
- ✅ Manual verification confirms visual appearance

## Future Enhancements

Potential improvements for notification testing:

- [ ] Add notification tap handling tests
- [ ] Test notification actions and buttons
- [ ] Test notification grouping (Android)
- [ ] Test notification categories (iOS)
- [ ] Add notification sound verification
- [ ] Test notification badges
- [ ] Add notification priority testing
- [ ] Test notification persistence across app restarts
- [ ] Add performance benchmarking
- [ ] Test notification delivery in background/killed app states

## Resources

- [flutter_local_notifications Documentation](https://pub.dev/packages/flutter_local_notifications)
- [Android Notification Channels](https://developer.android.com/develop/ui/views/notifications/channels)
- [iOS UserNotifications Framework](https://developer.apple.com/documentation/usernotifications)
- [Flutter Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Timezone Package](https://pub.dev/packages/timezone)

## Related Tests

- **Unit Tests**: `test/unit/services/notification_service_test.dart` (if exists)
- **VoIP Integration**: `test/integration/VOIP_INTEGRATION_TESTING.md`
- **Video Call Flow**: `test/integration/video_call_flow_test.dart`
- **Appointment Booking**: `test/integration/appointment_booking_test.dart`

---

**Note**: NotificationService integration testing validates platform-dependent functionality that cannot be fully tested through unit tests. These tests require running on actual devices or emulators with proper platform channel support. Manual verification is recommended to supplement automated tests.
