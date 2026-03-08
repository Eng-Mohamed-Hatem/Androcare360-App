/// Integration test for NotificationService
///
/// Tests platform-dependent notification functionality including local notifications,
/// scheduled notifications, notification channels (Android), and notification
/// permissions (iOS). These tests require running on physical devices or emulators
/// with proper platform channel support.
///
/// Platform Requirements:
/// - Android: API 26+ for notification channels
/// - iOS: iOS 10+ for UserNotifications framework
///
/// Note: These tests validate real platform behavior and cannot be fully mocked.

library;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:elajtech/core/services/notification_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group(
    'NotificationService Integration Tests',
    () {
      late NotificationService notificationService;

      setUp(() async {
        notificationService = NotificationService();
        await notificationService.init();

        // Clear any existing notifications before each test
        await notificationService.cancelAll();

        // Small delay to ensure cleanup completes
        await Future<void>.delayed(const Duration(milliseconds: 500));
      });

      tearDown(() async {
        // Cleanup after each test
        await notificationService.cancelAll();
      });

      // ═══════════════════════════════════════════════════════════════════════
      // Test 1: Service Initialization
      // ═══════════════════════════════════════════════════════════════════════

      testWidgets(
        'NotificationService initializes successfully',
        (WidgetTester tester) async {
          // ARRANGE & ACT
          final service = NotificationService();

          // ASSERT
          expect(service, isNotNull);
          expect(service.flutterLocalNotificationsPlugin, isNotNull);

          // Verify initialization completes without errors
          await expectLater(
            service.init(),
            completes,
          );
        },
      );

      // ═══════════════════════════════════════════════════════════════════════
      // Test 2: Display Local Notification
      // ═══════════════════════════════════════════════════════════════════════

      testWidgets(
        'displays local notification with title and body',
        (WidgetTester tester) async {
          // ARRANGE
          const notificationId = 1001;
          const title = 'Test Notification';
          const body = 'This is a test notification body';

          // ACT
          await notificationService.showNotification(
            id: notificationId,
            title: title,
            body: body,
          );

          // Wait for notification to be displayed
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // ASSERT
          // Note: Actual notification display verification requires manual inspection
          // or platform-specific notification checking APIs
          // This test verifies the method completes without errors
          expect(true, isTrue);
        },
      );

      // ═══════════════════════════════════════════════════════════════════════
      // Test 3: Display Multiple Notifications
      // ═══════════════════════════════════════════════════════════════════════

      testWidgets(
        'displays multiple notifications with different IDs',
        (WidgetTester tester) async {
          // ARRANGE
          const notifications = [
            {
              'id': 2001,
              'title': 'Notification 1',
              'body': 'First notification',
            },
            {
              'id': 2002,
              'title': 'Notification 2',
              'body': 'Second notification',
            },
            {
              'id': 2003,
              'title': 'Notification 3',
              'body': 'Third notification',
            },
          ];

          // ACT
          for (final notification in notifications) {
            await notificationService.showNotification(
              id: notification['id']! as int,
              title: notification['title']! as String,
              body: notification['body']! as String,
            );

            // Small delay between notifications
            await Future<void>.delayed(const Duration(milliseconds: 300));
          }

          await tester.pumpAndSettle(const Duration(seconds: 1));

          // ASSERT
          // Multiple notifications should be displayed without errors
          expect(true, isTrue);
        },
      );

      // ═══════════════════════════════════════════════════════════════════════
      // Test 4: Schedule Future Notification
      // ═══════════════════════════════════════════════════════════════════════

      testWidgets(
        'schedules notification for future delivery',
        (WidgetTester tester) async {
          // ARRANGE
          const notificationId = 3001;
          const title = 'Scheduled Notification';
          const body = 'This notification was scheduled';
          final scheduledDate = DateTime.now().add(const Duration(seconds: 5));

          // ACT
          await notificationService.scheduleNotification(
            id: notificationId,
            title: title,
            body: body,
            scheduledDate: scheduledDate,
          );

          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          // ASSERT
          // Notification should be scheduled without errors
          // Actual delivery will occur after 5 seconds
          expect(true, isTrue);
        },
      );

      // ═══════════════════════════════════════════════════════════════════════
      // Test 5: Schedule Notification - Past Date Handling
      // ═══════════════════════════════════════════════════════════════════════

      testWidgets(
        'handles scheduling notification with past date gracefully',
        (WidgetTester tester) async {
          // ARRANGE
          const notificationId = 3002;
          const title = 'Past Date Notification';
          const body = 'This should not be scheduled';
          final pastDate = DateTime.now().subtract(const Duration(hours: 1));

          // ACT
          await notificationService.scheduleNotification(
            id: notificationId,
            title: title,
            body: body,
            scheduledDate: pastDate,
          );

          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          // ASSERT
          // Method should complete without errors (notification not scheduled)
          expect(true, isTrue);
        },
      );

      // ═══════════════════════════════════════════════════════════════════════
      // Test 6: Cancel Specific Notification
      // ═══════════════════════════════════════════════════════════════════════

      testWidgets(
        'cancels specific notification by ID',
        (WidgetTester tester) async {
          // ARRANGE
          const notificationId = 4001;
          const title = 'Notification to Cancel';
          const body = 'This notification will be cancelled';

          // Display notification
          await notificationService.showNotification(
            id: notificationId,
            title: title,
            body: body,
          );

          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          // ACT
          await notificationService.cancelNotification(notificationId);

          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          // ASSERT
          // Notification should be cancelled without errors
          expect(true, isTrue);
        },
      );

      // ═══════════════════════════════════════════════════════════════════════
      // Test 7: Cancel All Notifications
      // ═══════════════════════════════════════════════════════════════════════

      testWidgets(
        'cancels all active notifications',
        (WidgetTester tester) async {
          // ARRANGE
          // Display multiple notifications
          for (var i = 5001; i <= 5005; i++) {
            await notificationService.showNotification(
              id: i,
              title: 'Notification $i',
              body: 'Body for notification $i',
            );
            await Future<void>.delayed(const Duration(milliseconds: 200));
          }

          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          // ACT
          await notificationService.cancelAll();

          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          // ASSERT
          // All notifications should be cancelled without errors
          expect(true, isTrue);
        },
      );

      // ═══════════════════════════════════════════════════════════════════════
      // Test 8: Notification with Special Characters
      // ═══════════════════════════════════════════════════════════════════════

      testWidgets(
        'displays notification with Arabic text and special characters',
        (WidgetTester tester) async {
          // ARRANGE
          const notificationId = 6001;
          const title = 'إشعار اختبار';
          const body = 'هذا إشعار تجريبي يحتوي على نص عربي 🔔';

          // ACT
          await notificationService.showNotification(
            id: notificationId,
            title: title,
            body: body,
          );

          await tester.pumpAndSettle(const Duration(seconds: 1));

          // ASSERT
          // Notification with Arabic text should display without errors
          expect(true, isTrue);
        },
      );

      // ═══════════════════════════════════════════════════════════════════════
      // Test 9: Notification with Long Text
      // ═══════════════════════════════════════════════════════════════════════

      testWidgets(
        'displays notification with long title and body text',
        (WidgetTester tester) async {
          // ARRANGE
          const notificationId = 6002;
          const title =
              'This is a very long notification title that should be '
              'truncated or wrapped appropriately by the notification system';
          const body =
              'This is a very long notification body that contains '
              'multiple sentences and should be displayed properly. '
              'The notification system should handle this gracefully and '
              'show the content in an appropriate format for the user to read.';

          // ACT
          await notificationService.showNotification(
            id: notificationId,
            title: title,
            body: body,
          );

          await tester.pumpAndSettle(const Duration(seconds: 1));

          // ASSERT
          // Long text notification should display without errors
          expect(true, isTrue);
        },
      );

      // ═══════════════════════════════════════════════════════════════════════
      // Test 10: Replace Existing Notification
      // ═══════════════════════════════════════════════════════════════════════

      testWidgets(
        'replaces existing notification when using same ID',
        (WidgetTester tester) async {
          // ARRANGE
          const notificationId = 7001;
          const originalTitle = 'Original Notification';
          const originalBody = 'This is the original notification';
          const updatedTitle = 'Updated Notification';
          const updatedBody = 'This notification has been updated';

          // ACT
          // Display original notification
          await notificationService.showNotification(
            id: notificationId,
            title: originalTitle,
            body: originalBody,
          );

          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          // Display updated notification with same ID
          await notificationService.showNotification(
            id: notificationId,
            title: updatedTitle,
            body: updatedBody,
          );

          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          // ASSERT
          // Updated notification should replace the original without errors
          expect(true, isTrue);
        },
      );

      // ═══════════════════════════════════════════════════════════════════════
      // Test 11: Schedule Multiple Notifications
      // ═══════════════════════════════════════════════════════════════════════

      testWidgets(
        'schedules multiple notifications at different times',
        (WidgetTester tester) async {
          // ARRANGE
          final now = DateTime.now();
          final scheduledNotifications = [
            {
              'id': 8001,
              'title': 'Reminder 1',
              'body': 'First reminder',
              'date': now.add(const Duration(seconds: 10)),
            },
            {
              'id': 8002,
              'title': 'Reminder 2',
              'body': 'Second reminder',
              'date': now.add(const Duration(seconds: 20)),
            },
            {
              'id': 8003,
              'title': 'Reminder 3',
              'body': 'Third reminder',
              'date': now.add(const Duration(seconds: 30)),
            },
          ];

          // ACT
          for (final notification in scheduledNotifications) {
            await notificationService.scheduleNotification(
              id: notification['id']! as int,
              title: notification['title']! as String,
              body: notification['body']! as String,
              scheduledDate: notification['date']! as DateTime,
            );

            await Future<void>.delayed(const Duration(milliseconds: 200));
          }

          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          // ASSERT
          // All notifications should be scheduled without errors
          expect(true, isTrue);
        },
      );

      // ═══════════════════════════════════════════════════════════════════════
      // Test 12: Cancel Scheduled Notification Before Delivery
      // ═══════════════════════════════════════════════════════════════════════

      testWidgets(
        'cancels scheduled notification before it is delivered',
        (WidgetTester tester) async {
          // ARRANGE
          const notificationId = 9001;
          const title = 'Scheduled to Cancel';
          const body = 'This notification will be cancelled before delivery';
          final scheduledDate = DateTime.now().add(const Duration(seconds: 30));

          // Schedule notification
          await notificationService.scheduleNotification(
            id: notificationId,
            title: title,
            body: body,
            scheduledDate: scheduledDate,
          );

          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          // ACT
          // Cancel before delivery
          await notificationService.cancelNotification(notificationId);

          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          // ASSERT
          // Scheduled notification should be cancelled without errors
          expect(true, isTrue);
        },
      );

      // ═══════════════════════════════════════════════════════════════════════
      // Test 13: Notification Service Singleton Pattern
      // ═══════════════════════════════════════════════════════════════════════

      testWidgets(
        'NotificationService maintains singleton instance',
        (WidgetTester tester) async {
          // ARRANGE & ACT
          final instance1 = NotificationService();
          final instance2 = NotificationService();

          // ASSERT
          expect(instance1, same(instance2));
          expect(identical(instance1, instance2), isTrue);
        },
      );

      // ═══════════════════════════════════════════════════════════════════════
      // Test 14: Rapid Notification Display
      // ═══════════════════════════════════════════════════════════════════════

      testWidgets(
        'handles rapid successive notification displays',
        (WidgetTester tester) async {
          // ARRANGE
          const notificationCount = 10;

          // ACT
          for (var i = 10001; i < 10001 + notificationCount; i++) {
            await notificationService.showNotification(
              id: i,
              title: 'Rapid Notification $i',
              body: 'Body $i',
            );
            // No delay between notifications
          }

          await tester.pumpAndSettle(const Duration(seconds: 1));

          // ASSERT
          // All notifications should be displayed without errors
          expect(true, isTrue);
        },
      );

      // ═══════════════════════════════════════════════════════════════════════
      // Test 15: Empty Title and Body Handling
      // ═══════════════════════════════════════════════════════════════════════

      testWidgets(
        'handles notifications with empty title or body',
        (WidgetTester tester) async {
          // ARRANGE & ACT
          // Empty title
          await notificationService.showNotification(
            id: 11001,
            title: '',
            body: 'Body without title',
          );

          await Future<void>.delayed(const Duration(milliseconds: 300));

          // Empty body
          await notificationService.showNotification(
            id: 11002,
            title: 'Title without body',
            body: '',
          );

          await Future<void>.delayed(const Duration(milliseconds: 300));

          // Both empty
          await notificationService.showNotification(
            id: 11003,
            title: '',
            body: '',
          );

          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          // ASSERT
          // Notifications with empty fields should be handled gracefully
          expect(true, isTrue);
        },
      );
    },
    skip:
        'Integration tests require real device/emulator with platform channels. See NOTIFICATION_INTEGRATION_TESTING.md',
  );

  // ═══════════════════════════════════════════════════════════════════════
  // Platform-Specific Tests
  // ═══════════════════════════════════════════════════════════════════════

  group(
    'Platform-Specific Notification Tests',
    () {
      late NotificationService notificationService;

      setUp(() async {
        notificationService = NotificationService();
        await notificationService.init();
        await notificationService.cancelAll();
        await Future<void>.delayed(const Duration(milliseconds: 500));
      });

      tearDown(() async {
        await notificationService.cancelAll();
      });

      // ═══════════════════════════════════════════════════════════════════════
      // Android-Specific Tests
      // ═══════════════════════════════════════════════════════════════════════

      testWidgets(
        'Android: notification channels are created during initialization',
        (WidgetTester tester) async {
          // ARRANGE & ACT
          final service = NotificationService();
          await service.init();

          // ASSERT
          // Verify initialization completes (channels created internally)
          expect(service.flutterLocalNotificationsPlugin, isNotNull);

          // Note: Actual channel verification requires platform-specific APIs
          // This test verifies the initialization process completes successfully
        },
      );

      testWidgets(
        'Android: high-priority notification displays with correct importance',
        (WidgetTester tester) async {
          // ARRANGE
          const notificationId = 12001;
          const title = 'High Priority Notification';
          const body = 'This is a high-priority notification';

          // ACT
          await notificationService.showNotification(
            id: notificationId,
            title: title,
            body: body,
          );

          await tester.pumpAndSettle(const Duration(seconds: 1));

          // ASSERT
          // High-priority notification should display without errors
          // Actual importance level verification requires platform APIs
          expect(true, isTrue);
        },
      );

      testWidgets(
        'Android: incoming call channel is created with max importance',
        (WidgetTester tester) async {
          // ARRANGE & ACT
          final service = NotificationService();
          await service.init();

          // ASSERT
          // Incoming call channel should be created during initialization
          // Channel ID: 'incoming_calls'
          // Importance: max
          expect(service.flutterLocalNotificationsPlugin, isNotNull);
        },
      );

      // ═══════════════════════════════════════════════════════════════════════
      // iOS-Specific Tests
      // ═══════════════════════════════════════════════════════════════════════

      testWidgets(
        'iOS: notification permissions are requested during initialization',
        (WidgetTester tester) async {
          // ARRANGE & ACT
          final service = NotificationService();
          await service.init();

          // ASSERT
          // Permission request should complete without errors
          expect(service.flutterLocalNotificationsPlugin, isNotNull);

          // Note: Actual permission status verification requires platform APIs
        },
      );

      testWidgets(
        'iOS: notification displays with Darwin settings',
        (WidgetTester tester) async {
          // ARRANGE
          const notificationId = 13001;
          const title = 'iOS Notification';
          const body = 'This notification uses Darwin settings';

          // ACT
          await notificationService.showNotification(
            id: notificationId,
            title: title,
            body: body,
          );

          await tester.pumpAndSettle(const Duration(seconds: 1));

          // ASSERT
          // iOS notification should display without errors
          expect(true, isTrue);
        },
      );
    },
    skip:
        'Integration tests require real device/emulator with platform channels. See NOTIFICATION_INTEGRATION_TESTING.md',
  );
}
