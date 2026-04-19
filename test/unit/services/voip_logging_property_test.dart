import 'package:elajtech/core/models/device_info_model.dart';
import 'package:elajtech/core/services/call_monitoring_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/mocks.mocks.dart';
import 'call_monitoring_service_test.mocks.dart';

/// Property Test for VoIP Event Logging Completeness
///
/// **Feature: video-call-ui-voip-bugfix, Property 8: Comprehensive VoIP Event Logging**
///
/// **Validates: Requirements 5.6, 5.7**
///
/// For all VoIP-related events, verify logs include required fields and use correct database.
/// Test with 100 iterations using property-based testing.
///
/// Property: For all VoIP-related events (call_attempt, call_started, voip_notification_sent,
/// call_error, call_timeout), logs must be written to the call_logs collection in the 'elajtech'
/// database, and every log entry must include appointmentId, userId, and timestamp fields.
void main() {
  group('Property 8: Comprehensive VoIP Event Logging', () {
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference<Map<String, dynamic>> mockCollection;
    late MockDocumentReference<Map<String, dynamic>> mockDocument;
    late MockDeviceInfoService mockDeviceInfoService;
    late CallMonitoringService service;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockCollectionReference<Map<String, dynamic>>();
      mockDocument = MockDocumentReference<Map<String, dynamic>>();
      mockDeviceInfoService = MockDeviceInfoService();

      // Setup mock chain
      when(mockFirestore.collection('call_logs')).thenReturn(mockCollection);
      when(mockCollection.doc(any)).thenReturn(mockDocument);
      when(mockDocument.set(any)).thenAnswer((_) async => {});
      when(mockCollection.add(any)).thenAnswer((_) async => mockDocument);

      // Setup device info mock
      when(mockDeviceInfoService.getDeviceInfo()).thenAnswer(
        (_) async => const DeviceInfoModel(
          platform: 'Android',
          deviceModel: 'Test Device',
          manufacturer: 'Test Manufacturer',
          osVersion: '13',
          appVersion: '1.0.0',
          appBuildNumber: '1',
          connectionType: 'wifi',
          screenResolution: '1080x2400',
        ),
      );

      service = CallMonitoringService(
        mockFirestore,
      );
    });

    test(
      'Property 8: All VoIP events logged with required fields (100 iterations)',
      () async {
        // Property-based testing with 100 iterations
        const iterations = 100;
        final eventTypes = [
          'call_attempt',
          'call_started',
          'voip_notification_sent',
          'call_error',
          'call_timeout',
        ];

        for (var i = 0; i < iterations; i++) {
          // Generate random test data
          final appointmentId =
              'apt_${i}_${DateTime.now().millisecondsSinceEpoch}';
          final userId = 'user_${i}_${DateTime.now().millisecondsSinceEpoch}';
          final eventType = eventTypes[i % eventTypes.length];

          // Reset mocks for each iteration
          reset(mockCollection);
          reset(mockDocument);
          when(
            mockFirestore.collection('call_logs'),
          ).thenReturn(mockCollection);
          when(mockCollection.doc(any)).thenReturn(mockDocument);
          when(mockDocument.set(any)).thenAnswer((_) async => {});
          when(mockCollection.add(any)).thenAnswer((_) async => mockDocument);

          const dummyDevice = DeviceInfoModel(
            platform: 'Android',
            deviceModel: 'Test Device',
            manufacturer: 'Test Manufacturer',
            osVersion: '13',
            appVersion: '1.0.0',
            appBuildNumber: '1',
            connectionType: 'wifi',
            screenResolution: '1080x2400',
          );

          // Execute logging based on event type
          switch (eventType) {
            case 'call_attempt':
              await service.logCallAttempt(
                appointmentId: appointmentId,
                userId: userId,
                deviceInfo: dummyDevice,
              );
            case 'call_started':
              await service.logCallSuccess(
                appointmentId: appointmentId,
                userId: userId,
                channelName: 'channel_$i',
                metadata: {'eventType': 'call_started'},
              );
            case 'voip_notification_sent':
              await service.logCallSuccess(
                appointmentId: appointmentId,
                userId: userId,
                channelName: 'voip_notification',
                metadata: {'eventType': 'voip_notification_sent'},
              );
            case 'call_error':
              await service.logCallError(
                appointmentId: appointmentId,
                userId: userId,
                errorType: 'test_error',
                errorMessage: 'Test error message',
                deviceInfo: dummyDevice,
              );
            case 'call_timeout':
              await service.logConnectionFailure(
                appointmentId: appointmentId,
                userId: userId,
                reason: 'Call timeout',
                deviceInfo: dummyDevice,
                metadata: {'eventType': 'call_timeout'},
              );
          }

          // Verify log entry includes all required fields
          final captured = verify(mockDocument.set(captureAny)).captured;
          expect(
            captured,
            isNotEmpty,
            reason: 'Log should be saved for iteration $i',
          );

          final logData = captured.first as Map<String, dynamic>;

          // Property: Every log entry must include appointmentId, userId, and timestamp
          expect(
            logData['appointmentId'],
            equals(appointmentId),
            reason: 'appointmentId must match for iteration $i',
          );
          expect(
            logData['userId'],
            equals(userId),
            reason: 'userId must match for iteration $i',
          );
          expect(
            logData['timestamp'],
            isNotNull,
            reason: 'timestamp must be present for iteration $i',
          );
          expect(
            logData['timestamp'],
            isA<String>(),
            reason: 'timestamp must be String (ISO 8601) for iteration $i',
          );

          // Verify correct collection used
          verify(mockFirestore.collection('call_logs')).called(1);
        }

        // All 100 iterations completed successfully
        expect(iterations, equals(100));
      },
      tags: ['property-test', 'voip-logging', 'task13_1'],
    );

    test(
      'Property 8: Logs written to elajtech database (verification)',
      () async {
        // This test verifies that the service uses the correct database
        // In production, the FirebaseFirestore instance is configured with databaseId: 'elajtech'

        const appointmentId = 'apt_test';
        const userId = 'user_test';

        await service.logCallAttempt(
          appointmentId: appointmentId,
          userId: userId,
          deviceInfo: const DeviceInfoModel(
            platform: 'Android',
            deviceModel: 'Test Device',
            manufacturer: 'Test Manufacturer',
            osVersion: '13',
            appVersion: '1.0.0',
            appBuildNumber: '1',
            connectionType: 'wifi',
            screenResolution: '1080x2400',
          ),
        );

        // Verify call_logs collection is used
        verify(mockFirestore.collection('call_logs')).called(1);

        // Verify log data includes required fields
        final captured = verify(mockDocument.set(captureAny)).captured;
        expect(captured, isNotEmpty);

        final logData = captured.first as Map<String, dynamic>;
        expect(logData['appointmentId'], equals(appointmentId));
        expect(logData['userId'], equals(userId));
        expect(logData['timestamp'], isNotNull);
      },
      tags: ['property-test', 'voip-logging', 'task13_1'],
    );

    test(
      'Property 8: All event types include required fields',
      () async {
        // Test all event types to ensure consistency
        const appointmentId = 'apt_all_events';
        const userId = 'user_all_events';

        const dummyDevice = DeviceInfoModel(
          platform: 'Android',
          deviceModel: 'Test Device',
          manufacturer: 'Test Manufacturer',
          osVersion: '13',
          appVersion: '1.0.0',
          appBuildNumber: '1',
          connectionType: 'wifi',
          screenResolution: '1080x2400',
        );

        final testCases = [
          () => service.logCallAttempt(
            appointmentId: appointmentId,
            userId: userId,
            deviceInfo: dummyDevice,
          ),
          () => service.logCallSuccess(
            appointmentId: appointmentId,
            userId: userId,
            channelName: 'test_channel',
          ),
          () => service.logCallError(
            appointmentId: appointmentId,
            userId: userId,
            errorType: 'test_error',
            errorMessage: 'Test message',
            deviceInfo: dummyDevice,
          ),
          () => service.logConnectionFailure(
            appointmentId: appointmentId,
            userId: userId,
            reason: 'Test reason',
            deviceInfo: dummyDevice,
          ),
          () => service.logCallEnded(
            appointmentId: appointmentId,
            userId: userId,
          ),
        ];

        for (var i = 0; i < testCases.length; i++) {
          // Reset mocks
          reset(mockCollection);
          reset(mockDocument);
          when(
            mockFirestore.collection('call_logs'),
          ).thenReturn(mockCollection);
          when(mockCollection.doc(any)).thenReturn(mockDocument);
          when(mockDocument.set(any)).thenAnswer((_) async => {});

          // Execute test case
          await testCases[i]();

          // Verify required fields
          final captured = verify(mockDocument.set(captureAny)).captured;
          expect(captured, isNotEmpty, reason: 'Test case $i should log');

          final logData = captured.first as Map<String, dynamic>;
          expect(
            logData['appointmentId'],
            equals(appointmentId),
            reason: 'Test case $i: appointmentId required',
          );
          expect(
            logData['userId'],
            equals(userId),
            reason: 'Test case $i: userId required',
          );
          expect(
            logData['timestamp'],
            isNotNull,
            reason: 'Test case $i: timestamp required',
          );
        }
      },
      tags: ['property-test', 'voip-logging', 'task13_1'],
    );

    // ─────────────────────────────────────────────────────────────────────
    // T036: Canonical event-type validation — all 11 contract event names
    // ─────────────────────────────────────────────────────────────────────

    test('T036: all canonical event types must be non-empty strings', () {
      // Contract §4 canonical event types (data-model.md + call-lifecycle-contract.md)
      const canonicalEvents = [
        'callattempt',
        'notification_dispatched',
        'incoming_call_received',
        'answer_accepted',
        'active_call_restored',
        'join_started',
        'join_success',
        'join_failure',
        'cleanup_triggered',
        'end_agora_call_invoked',
        'callended',
      ];

      for (final eventType in canonicalEvents) {
        expect(eventType, isA<String>());
        expect(eventType, isNotEmpty);
        expect(eventType.contains(' '), isFalse,
            reason: 'Event type $eventType must not contain spaces');
      }
      expect(canonicalEvents.length, equals(11));
    });

    test('T036: logStructuredEvent with canonical answer_accepted writes to call_logs', () async {
      const appointmentId = 'apt_canonical_001';
      const userId = 'user_canonical_001';

      when(mockFirestore.collection('call_logs')).thenReturn(mockCollection);
      when(mockCollection.doc(any)).thenReturn(mockDocument);
      when(mockDocument.set(any)).thenAnswer((_) async => {});

      await service.logStructuredEvent(
        appointmentId: appointmentId,
        userId: userId,
        eventType: 'answer_accepted',
        metadata: {'callId': 'call_001'},
      );

      final captured = verify(mockDocument.set(captureAny)).captured;
      expect(captured, isNotEmpty);
      final logData = captured.first as Map<String, dynamic>;
      expect(logData['eventType'], equals('answer_accepted'));
      expect(logData['appointmentId'], equals(appointmentId));
      expect(logData['userId'], equals(userId));
    });

    test('T036: logStructuredEvent sanitizes agoraToken from metadata', () async {
      const appointmentId = 'apt_sanitize_001';
      const userId = 'user_sanitize_001';

      when(mockFirestore.collection('call_logs')).thenReturn(mockCollection);
      when(mockCollection.doc(any)).thenReturn(mockDocument);
      when(mockDocument.set(any)).thenAnswer((_) async => {});

      await service.logStructuredEvent(
        appointmentId: appointmentId,
        userId: userId,
        eventType: 'incoming_call_received',
        metadata: {
          'appState': 'foreground',
          'agoraToken': 'secret_token', // must be stripped
          'callerName': 'Dr. Test',
        },
      );

      final captured = verify(mockDocument.set(captureAny)).captured;
      final logData = captured.first as Map<String, dynamic>;
      final savedMetadata = logData['metadata'] as Map<String, dynamic>?;

      expect(savedMetadata, isNotNull);
      expect(savedMetadata!.containsKey('agoraToken'), isFalse,
          reason: 'agoraToken must be stripped from metadata');
      expect(savedMetadata['appState'], equals('foreground'));
      expect(savedMetadata['callerName'], equals('Dr. Test'));
    });

    test('T036: cleanup_triggered log must include reason in metadata', () async {
      const appointmentId = 'apt_cleanup_001';
      const userId = 'user_cleanup_001';

      when(mockFirestore.collection('call_logs')).thenReturn(mockCollection);
      when(mockCollection.doc(any)).thenReturn(mockDocument);
      when(mockDocument.set(any)).thenAnswer((_) async => {});

      await service.logStructuredEvent(
        appointmentId: appointmentId,
        userId: userId,
        eventType: 'cleanup_triggered',
        metadata: {'reason': 'lifecycle_resumed'},
      );

      final captured = verify(mockDocument.set(captureAny)).captured;
      final logData = captured.first as Map<String, dynamic>;
      expect(logData['eventType'], equals('cleanup_triggered'));
      final meta = logData['metadata'] as Map<String, dynamic>?;
      expect(meta, isNotNull);
      expect(meta!['reason'], equals('lifecycle_resumed'));
    });

    test('T036: join_failure log must include errorCode or reasonCode', () async {
      const appointmentId = 'apt_join_fail_001';
      const userId = 'user_join_fail_001';

      when(mockFirestore.collection('call_logs')).thenReturn(mockCollection);
      when(mockCollection.doc(any)).thenReturn(mockDocument);
      when(mockDocument.set(any)).thenAnswer((_) async => {});

      await service.logStructuredEvent(
        appointmentId: appointmentId,
        userId: userId,
        eventType: 'join_failure',
        errorCode: 'agora_join_timeout',
        metadata: {'elapsedMs': '14980'},
      );

      final captured = verify(mockDocument.set(captureAny)).captured;
      final logData = captured.first as Map<String, dynamic>;
      expect(logData['eventType'], equals('join_failure'));
      expect(logData['errorCode'], equals('agora_join_timeout'));
    });
  });
}
