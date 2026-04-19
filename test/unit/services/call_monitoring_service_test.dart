/// Unit tests for CallMonitoringService
///
/// Tests cover:
/// - Event logging with correct data structure
/// - Firestore write operations with mocks
/// - Device info collection integration
/// - Error handling for failed writes
/// - Different event types (attempt, success, error, failure, device error, ended)
/// - Query operations for retrieving logs
/// - Retry logic and offline scenarios
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:elajtech/core/services/call_monitoring_service.dart';
import 'package:elajtech/core/models/device_info_model.dart';
import 'package:elajtech/core/services/device_info_service.dart';

import '../../mocks/mocks.mocks.dart';

// Generate mock for DeviceInfoService
@GenerateMocks([DeviceInfoService])
import 'call_monitoring_service_test.mocks.dart';

void main() {
  late CallMonitoringService monitoringService;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocument;
  late MockDeviceInfoService mockDeviceInfoService;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocument = MockDocumentReference<Map<String, dynamic>>();
    mockDeviceInfoService = MockDeviceInfoService();

    // Setup default mock behavior
    when(mockFirestore.collection('call_logs')).thenReturn(mockCollection);
    when(mockCollection.doc(any)).thenReturn(mockDocument);
    when(mockDocument.set(any)).thenAnswer((_) async => {});

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

    monitoringService = CallMonitoringService(
      mockFirestore,
    )..deviceInfoService = mockDeviceInfoService;
  });

  group('CallMonitoringService - Initialization', () {
    test('should initialize with injected dependencies', () {
      // Assert
      expect(monitoringService, isNotNull);
    });

    test('should initialize with default dependencies', () {
      // Act
      final service = CallMonitoringService(mockFirestore);

      // Assert
      expect(service, isNotNull);
    });
  });

  group('CallMonitoringService - Log Call Attempt', () {
    test('should log call attempt successfully', () async {
      // Arrange
      const appointmentId = 'apt_123';
      const userId = 'user_123';

      // Act
      await monitoringService.logCallAttempt(
        appointmentId: appointmentId,
        userId: userId,
      );

      // Assert
      verify(mockFirestore.collection('call_logs')).called(1);
      verify(mockCollection.doc(any)).called(1);
      verify(mockDocument.set(any)).called(1);
      verify(mockDeviceInfoService.getDeviceInfo()).called(1);
    });

    test('should log call attempt with provided device info', () async {
      // Arrange
      const appointmentId = 'apt_123';
      const userId = 'user_123';
      const deviceInfo = DeviceInfoModel(
        platform: 'iOS',
        deviceModel: 'iPhone 14',
        manufacturer: 'Apple',
        osVersion: '16',
        appVersion: '1.0.0',
        appBuildNumber: '1',
        connectionType: 'cellular',
        screenResolution: '1170x2532',
      );

      // Act
      await monitoringService.logCallAttempt(
        appointmentId: appointmentId,
        userId: userId,
        deviceInfo: deviceInfo,
      );

      // Assert
      verify(mockDocument.set(any)).called(1);
      verifyNever(mockDeviceInfoService.getDeviceInfo());
    });

    test('should handle Firestore error gracefully', () async {
      // Arrange
      when(mockDocument.set(any)).thenThrow(
        FirebaseException(
          plugin: 'firestore',
          code: 'permission-denied',
          message: 'Permission denied',
        ),
      );

      // Act & Assert - should not throw
      await monitoringService.logCallAttempt(
        appointmentId: 'apt_123',
        userId: 'user_123',
      );

      verify(mockDocument.set(any)).called(1);
    });

    test('should handle network error gracefully', () async {
      // Arrange
      when(mockDocument.set(any)).thenThrow(
        Exception('Network error'),
      );

      // Act & Assert - should not throw
      await monitoringService.logCallAttempt(
        appointmentId: 'apt_123',
        userId: 'user_123',
      );

      verify(mockDocument.set(any)).called(1);
    });

    test('should collect device info when not provided', () async {
      // Act
      await monitoringService.logCallAttempt(
        appointmentId: 'apt_123',
        userId: 'user_123',
      );

      // Assert
      verify(mockDeviceInfoService.getDeviceInfo()).called(1);
    });
  });

  group('CallMonitoringService - Log Call Success', () {
    test('should log call success successfully', () async {
      // Arrange
      const appointmentId = 'apt_123';
      const userId = 'user_123';
      const channelName = 'channel_123';

      // Act
      await monitoringService.logCallSuccess(
        appointmentId: appointmentId,
        userId: userId,
        channelName: channelName,
      );

      // Assert
      verify(mockFirestore.collection('call_logs')).called(1);
      verify(mockCollection.doc(any)).called(1);
      verify(mockDocument.set(any)).called(1);
    });

    test('should include channel name in metadata', () async {
      // Arrange
      const channelName = 'test_channel_456';

      // Act
      await monitoringService.logCallSuccess(
        appointmentId: 'apt_123',
        userId: 'user_123',
        channelName: channelName,
      );

      // Assert
      final captured = verify(mockDocument.set(captureAny)).captured;
      expect(captured.length, 1);
      final data = captured[0] as Map<String, dynamic>;
      final metadata = data['metadata'] as Map<String, dynamic>;
      expect(metadata['channelName'], equals(channelName));
    });

    test('should include additional metadata when provided', () async {
      // Arrange
      final metadata = {
        'uid': 12345,
        'customData': 'test',
      };

      // Act
      await monitoringService.logCallSuccess(
        appointmentId: 'apt_123',
        userId: 'user_123',
        channelName: 'channel_123',
        metadata: metadata,
      );

      // Assert
      final captured = verify(mockDocument.set(captureAny)).captured;
      final data = captured[0] as Map<String, dynamic>;
      final capturedMetadata = data['metadata'] as Map<String, dynamic>;
      expect(capturedMetadata['uid'], equals(12345));
      expect(capturedMetadata['customData'], equals('test'));
    });

    test('should handle Firestore error gracefully', () async {
      // Arrange
      when(mockDocument.set(any)).thenThrow(
        FirebaseException(
          plugin: 'firestore',
          code: 'unavailable',
          message: 'Service unavailable',
        ),
      );

      // Act & Assert - should not throw
      await monitoringService.logCallSuccess(
        appointmentId: 'apt_123',
        userId: 'user_123',
        channelName: 'channel_123',
      );

      verify(mockDocument.set(any)).called(1);
    });
  });

  group('CallMonitoringService - Log Call Error', () {
    test('should log call error successfully', () async {
      // Arrange
      const appointmentId = 'apt_123';
      const userId = 'user_123';
      const errorType = 'token_generation_failed';
      const errorMessage = 'Failed to generate Agora token';

      // Act
      await monitoringService.logCallError(
        appointmentId: appointmentId,
        userId: userId,
        errorType: errorType,
        errorMessage: errorMessage,
      );

      // Assert
      verify(mockFirestore.collection('call_logs')).called(1);
      verify(mockCollection.doc(any)).called(1);
      verify(mockDocument.set(any)).called(1);
      verify(mockDeviceInfoService.getDeviceInfo()).called(1);
    });

    test('should include error details in log', () async {
      // Arrange
      const errorType = 'network_error';
      const errorMessage = 'Connection timeout';
      const stackTrace = 'Stack trace here...';

      // Act
      await monitoringService.logCallError(
        appointmentId: 'apt_123',
        userId: 'user_123',
        errorType: errorType,
        errorMessage: errorMessage,
        stackTrace: stackTrace,
      );

      // Assert
      final captured = verify(mockDocument.set(captureAny)).captured;
      final data = captured[0] as Map<String, dynamic>;
      expect(data['errorCode'], equals(errorType));
      expect(data['errorMessage'], equals(errorMessage));
      expect(data['stackTrace'], equals(stackTrace));
    });

    test('should handle optional stack trace', () async {
      // Act
      await monitoringService.logCallError(
        appointmentId: 'apt_123',
        userId: 'user_123',
        errorType: 'error',
        errorMessage: 'Error occurred',
      );

      // Assert
      final captured = verify(mockDocument.set(captureAny)).captured;
      final data = captured[0] as Map<String, dynamic>;
      expect(data['stackTrace'], isNull);
    });

    test('should collect device info for error logs', () async {
      // Act
      await monitoringService.logCallError(
        appointmentId: 'apt_123',
        userId: 'user_123',
        errorType: 'error',
        errorMessage: 'Error occurred',
      );

      // Assert
      verify(mockDeviceInfoService.getDeviceInfo()).called(1);
    });

    test('should handle Firestore error gracefully', () async {
      // Arrange
      when(mockDocument.set(any)).thenThrow(
        FirebaseException(
          plugin: 'firestore',
          code: 'deadline-exceeded',
          message: 'Deadline exceeded',
        ),
      );

      // Act & Assert - should not throw
      await monitoringService.logCallError(
        appointmentId: 'apt_123',
        userId: 'user_123',
        errorType: 'error',
        errorMessage: 'Error occurred',
      );

      verify(mockDocument.set(any)).called(1);
    });
  });

  group('CallMonitoringService - Log Connection Failure', () {
    test('should log connection failure successfully', () async {
      // Arrange
      const appointmentId = 'apt_123';
      const userId = 'user_123';
      const reason = 'connection_lost';

      // Act
      await monitoringService.logConnectionFailure(
        appointmentId: appointmentId,
        userId: userId,
        reason: reason,
      );

      // Assert
      verify(mockFirestore.collection('call_logs')).called(1);
      verify(mockCollection.doc(any)).called(1);
      verify(mockDocument.set(any)).called(1);
      verify(mockDeviceInfoService.getDeviceInfo()).called(1);
    });

    test('should include connection failure details', () async {
      // Arrange
      const reason = 'network_timeout';
      final metadata = {
        'connectionState': 'disconnected',
        'lastKnownState': 'connected',
      };

      // Act
      await monitoringService.logConnectionFailure(
        appointmentId: 'apt_123',
        userId: 'user_123',
        reason: reason,
        metadata: metadata,
      );

      // Assert
      final captured = verify(mockDocument.set(captureAny)).captured;
      final data = captured[0] as Map<String, dynamic>;
      expect(data['errorCode'], equals('connection_failure'));
      expect(data['errorMessage'], equals(reason));
      final capturedMetadata = data['metadata'] as Map<String, dynamic>;
      expect(capturedMetadata['connectionState'], equals('disconnected'));
    });

    test('should handle Firestore error gracefully', () async {
      // Arrange
      when(mockDocument.set(any)).thenThrow(
        FirebaseException(
          plugin: 'firestore',
          code: 'aborted',
          message: 'Transaction aborted',
        ),
      );

      // Act & Assert - should not throw
      await monitoringService.logConnectionFailure(
        appointmentId: 'apt_123',
        userId: 'user_123',
        reason: 'connection_lost',
      );

      verify(mockDocument.set(any)).called(1);
    });
  });

  group('CallMonitoringService - Log Media Device Error', () {
    test('should log camera error successfully', () async {
      // Arrange
      const appointmentId = 'apt_123';
      const userId = 'user_123';
      const deviceType = 'camera';
      const errorMessage = 'Camera failed to initialize';

      // Act
      await monitoringService.logMediaDeviceError(
        appointmentId: appointmentId,
        userId: userId,
        deviceType: deviceType,
        errorMessage: errorMessage,
      );

      // Assert
      verify(mockFirestore.collection('call_logs')).called(1);
      verify(mockCollection.doc(any)).called(1);
      verify(mockDocument.set(any)).called(1);
      verify(mockDeviceInfoService.getDeviceInfo()).called(1);
    });

    test('should log microphone error successfully', () async {
      // Arrange
      const deviceType = 'microphone';
      const errorMessage = 'Microphone permission denied';

      // Act
      await monitoringService.logMediaDeviceError(
        appointmentId: 'apt_123',
        userId: 'user_123',
        deviceType: deviceType,
        errorMessage: errorMessage,
      );

      // Assert
      final captured = verify(mockDocument.set(captureAny)).captured;
      final data = captured[0] as Map<String, dynamic>;
      expect(data['errorCode'], equals('microphone_error'));
      final capturedMetadata = data['metadata'] as Map<String, dynamic>;
      expect(capturedMetadata['deviceType'], equals('microphone'));
    });

    test('should include device type in metadata', () async {
      // Act
      await monitoringService.logMediaDeviceError(
        appointmentId: 'apt_123',
        userId: 'user_123',
        deviceType: 'camera',
        errorMessage: 'Error',
      );

      // Assert
      final captured = verify(mockDocument.set(captureAny)).captured;
      final data = captured[0] as Map<String, dynamic>;
      final capturedMetadata = data['metadata'] as Map<String, dynamic>;
      expect(capturedMetadata['deviceType'], equals('camera'));
    });

    test('should handle Firestore error gracefully', () async {
      // Arrange
      when(mockDocument.set(any)).thenThrow(
        FirebaseException(
          plugin: 'firestore',
          code: 'resource-exhausted',
          message: 'Resource exhausted',
        ),
      );

      // Act & Assert - should not throw
      await monitoringService.logMediaDeviceError(
        appointmentId: 'apt_123',
        userId: 'user_123',
        deviceType: 'camera',
        errorMessage: 'Error',
      );

      verify(mockDocument.set(any)).called(1);
    });
  });

  group('CallMonitoringService - Log Call Ended', () {
    test('should log call ended successfully', () async {
      // Arrange
      const appointmentId = 'apt_123';
      const userId = 'user_123';
      const duration = 300;

      // Act
      await monitoringService.logCallEnded(
        appointmentId: appointmentId,
        userId: userId,
        duration: duration,
      );

      // Assert
      verify(mockFirestore.collection('call_logs')).called(1);
      verify(mockCollection.doc(any)).called(1);
      verify(mockDocument.set(any)).called(1);
    });

    test('should include duration in metadata', () async {
      // Arrange
      const duration = 450; // 7.5 minutes

      // Act
      await monitoringService.logCallEnded(
        appointmentId: 'apt_123',
        userId: 'user_123',
        duration: duration,
      );

      // Assert
      final captured = verify(mockDocument.set(captureAny)).captured;
      final data = captured[0] as Map<String, dynamic>;
      final metadata = data['metadata'] as Map<String, dynamic>;
      expect(metadata['durationSeconds'], equals(duration));
    });

    test('should handle call ended without duration', () async {
      // Act
      await monitoringService.logCallEnded(
        appointmentId: 'apt_123',
        userId: 'user_123',
      );

      // Assert
      final captured = verify(mockDocument.set(captureAny)).captured;
      final data = captured[0] as Map<String, dynamic>;
      // Metadata should be null or empty when no duration provided
      final metadata = data['metadata'];
      expect(metadata == null || (metadata as Map).isEmpty, isTrue);
    });

    test('should include additional metadata when provided', () async {
      // Arrange
      final metadata = {
        'endReason': 'user_hangup',
        'quality': 'good',
      };

      // Act
      await monitoringService.logCallEnded(
        appointmentId: 'apt_123',
        userId: 'user_123',
        duration: 300,
        metadata: metadata,
      );

      // Assert
      final captured = verify(mockDocument.set(captureAny)).captured;
      final data = captured[0] as Map<String, dynamic>;
      final capturedMetadata = data['metadata'] as Map<String, dynamic>;
      expect(capturedMetadata['endReason'], equals('user_hangup'));
      expect(capturedMetadata['quality'], equals('good'));
    });

    test('should handle Firestore error gracefully', () async {
      // Arrange
      when(mockDocument.set(any)).thenThrow(
        FirebaseException(
          plugin: 'firestore',
          code: 'internal',
          message: 'Internal error',
        ),
      );

      // Act & Assert - should not throw
      await monitoringService.logCallEnded(
        appointmentId: 'apt_123',
        userId: 'user_123',
        duration: 300,
      );

      verify(mockDocument.set(any)).called(1);
    });
  });

  group('CallMonitoringService - Query Operations', () {
    test('should get logs for appointment', () async {
      // Arrange
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      final mockDocSnapshot = MockQueryDocumentSnapshot<Map<String, dynamic>>();

      when(
        mockCollection.where('appointmentId', isEqualTo: 'apt_123'),
      ).thenReturn(mockQuery);
      when(
        mockQuery.orderBy('timestamp', descending: true),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
      when(mockDocSnapshot.data()).thenReturn({
        'id': 'log_123',
        'appointmentId': 'apt_123',
        'userId': 'user_123',
        'eventType': 'call_attempt',
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Act
      final logs = await monitoringService.getLogsForAppointment('apt_123');

      // Assert
      expect(logs, isNotEmpty);
      expect(logs.length, 1);
      expect(logs[0].appointmentId, equals('apt_123'));
    });

    test('should return empty list on Firestore error', () async {
      // Arrange
      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenThrow(
        FirebaseException(
          plugin: 'firestore',
          code: 'unavailable',
        ),
      );

      // Act
      final logs = await monitoringService.getLogsForAppointment('apt_123');

      // Assert
      expect(logs, isEmpty);
    });

    test('should get logs for user with limit', () async {
      // Arrange
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();

      when(
        mockCollection.where('userId', isEqualTo: 'user_123'),
      ).thenReturn(mockQuery);
      when(
        mockQuery.orderBy('timestamp', descending: true),
      ).thenReturn(mockQuery);
      when(mockQuery.limit(50)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      // Act
      final logs = await monitoringService.getLogsForUser(
        'user_123',
      );

      // Assert
      verify(mockQuery.limit(50)).called(1);
      expect(logs, isEmpty);
    });

    test('should get error logs only', () async {
      // Arrange
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();

      when(
        mockCollection.where(
          'eventType',
          whereIn: anyNamed('whereIn'),
        ),
      ).thenReturn(mockQuery);
      when(
        mockQuery.orderBy('timestamp', descending: true),
      ).thenReturn(mockQuery);
      when(mockQuery.limit(100)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      // Act
      final logs = await monitoringService.getErrorLogs();

      // Assert
      verify(mockQuery.limit(100)).called(1);
      expect(logs, isEmpty);
    });
  });

  group('CallMonitoringService - Error Handling', () {
    test('should handle FirestoreException in _saveLog', () async {
      // Arrange
      when(mockDocument.set(any)).thenThrow(
        FirebaseException(
          plugin: 'firestore',
          code: 'permission-denied',
          message: 'Permission denied',
        ),
      );

      // Act & Assert - should not throw (caught internally)
      await monitoringService.logCallAttempt(
        appointmentId: 'apt_123',
        userId: 'user_123',
      );

      verify(mockDocument.set(any)).called(1);
    });

    test('should handle generic Exception in _saveLog', () async {
      // Arrange
      when(mockDocument.set(any)).thenThrow(
        Exception('Unexpected error'),
      );

      // Act & Assert - should not throw (caught internally)
      await monitoringService.logCallAttempt(
        appointmentId: 'apt_123',
        userId: 'user_123',
      );

      verify(mockDocument.set(any)).called(1);
    });

    test('should handle network errors in all log methods', () async {
      // Arrange
      when(mockDocument.set(any)).thenThrow(
        Exception('Network error'),
      );

      // Act & Assert - none should throw
      await monitoringService.logCallAttempt(
        appointmentId: 'apt_123',
        userId: 'user_123',
      );
      await monitoringService.logCallSuccess(
        appointmentId: 'apt_123',
        userId: 'user_123',
        channelName: 'channel',
      );
      await monitoringService.logCallError(
        appointmentId: 'apt_123',
        userId: 'user_123',
        errorType: 'error',
        errorMessage: 'message',
      );
      await monitoringService.logConnectionFailure(
        appointmentId: 'apt_123',
        userId: 'user_123',
        reason: 'reason',
      );
      await monitoringService.logMediaDeviceError(
        appointmentId: 'apt_123',
        userId: 'user_123',
        deviceType: 'camera',
        errorMessage: 'message',
      );
      await monitoringService.logCallEnded(
        appointmentId: 'apt_123',
        userId: 'user_123',
      );

      // Assert - all methods were called
      verify(mockDocument.set(any)).called(6);
    });
  });

  group('CallMonitoringService - Data Validation', () {
    test('should generate unique IDs for each log', () async {
      // Arrange
      final capturedData = <Map<String, dynamic>>[];

      when(mockDocument.set(any)).thenAnswer((invocation) {
        capturedData.add(
          invocation.positionalArguments[0] as Map<String, dynamic>,
        );
        return Future.value();
      });

      // Act
      await monitoringService.logCallAttempt(
        appointmentId: 'apt_123',
        userId: 'user_123',
      );
      await monitoringService.logCallAttempt(
        appointmentId: 'apt_123',
        userId: 'user_123',
      );

      // Assert
      expect(capturedData.length, 2);
      expect(capturedData[0]['id'], isNot(equals(capturedData[1]['id'])));
    });

    test('should include timestamp in all logs', () async {
      // Act
      await monitoringService.logCallAttempt(
        appointmentId: 'apt_123',
        userId: 'user_123',
      );

      // Assert
      final captured = verify(mockDocument.set(captureAny)).captured;
      final data = captured[0] as Map<String, dynamic>;
      expect(data['timestamp'], isNotNull);
      expect(data['timestamp'], isA<String>());
    });

    test('should include appointment ID and user ID in all logs', () async {
      // Arrange
      const appointmentId = 'apt_456';
      const userId = 'user_789';

      // Act
      await monitoringService.logCallAttempt(
        appointmentId: appointmentId,
        userId: userId,
      );

      // Assert
      final captured = verify(mockDocument.set(captureAny)).captured;
      final data = captured[0] as Map<String, dynamic>;
      expect(data['appointmentId'], equals(appointmentId));
      expect(data['userId'], equals(userId));
    });
  });
}
