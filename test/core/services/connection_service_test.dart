/// Connection Service Tests
///
/// اختبارات خدمة الاتصال
///
/// تتضمن هذه الاختبارات:
/// - مراقبة حالة الاتصال
/// - إشعار التغييرات في الاتصال
/// - تهيئة الخدمة
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:elajtech/core/services/connection_service.dart';
import '../../../test/helpers/widget_test_helper.dart';

void main() {
  setUpAll(setupFirebaseMocks);

  tearDownAll(cleanupFirebaseMocks);

  group('ConnectionService', () {
    test('should be singleton', () {
      final instance1 = ConnectionService.instance;
      final instance2 = ConnectionService.instance;
      expect(identical(instance1, instance2), true);
    });

    test('should have connection status stream', () {
      final stream = ConnectionService.onConnectionChange;
      expect(stream, isNotNull);
      expect(stream, isA<Stream<bool>>());
    });

    test('should emit connection status changes', () async {
      final statuses = <bool>[];
      final subscription = ConnectionService.onConnectionChange.listen(
        statuses.add,
      );

      // Initialize to trigger the first emission
      await ConnectionService.initialize();

      // Wait a bit for initial status
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(statuses.isNotEmpty, true);
      expect(statuses.last, isA<bool>());

      await subscription.cancel();
    });

    test('should initialize successfully', () async {
      await ConnectionService.initialize();
      expect(ConnectionService.instance, isNotNull);
      expect(ConnectionService.isConnected, isA<bool>());
    });

    test('should handle multiple listeners', () async {
      final listener1Results = <bool>[];
      final listener2Results = <bool>[];

      final sub1 = ConnectionService.onConnectionChange.listen(
        listener1Results.add,
      );
      final sub2 = ConnectionService.onConnectionChange.listen(
        listener2Results.add,
      );

      // Initialize to trigger emissions
      await ConnectionService.initialize();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(listener1Results.isNotEmpty, true);
      expect(listener2Results.isNotEmpty, true);
      expect(listener1Results.length, equals(listener2Results.length));

      await sub1.cancel();
      await sub2.cancel();
    });

    test('should cancel subscription properly', () async {
      var callCount = 0;
      final subscription = ConnectionService.onConnectionChange.listen(
        (_) => callCount++,
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));
      await subscription.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // After cancel, no more calls should be made
      final countAfterCancel = callCount;
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(callCount, equals(countAfterCancel));
    });
  });
}
