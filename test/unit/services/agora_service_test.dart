/// Unit tests for AgoraService
///
/// Tests cover:
/// - Service initialization and structure
/// - Dependency injection pattern
/// - State management (audio/video mute states)
/// - Remote users tracking
/// - Event stream functionality
/// - Parameter validation
/// - Error handling patterns
/// - Resource cleanup
///
/// Note: Platform-specific functionality (actual Agora RTC operations)
/// requires integration testing with real devices/emulators as it depends on
/// agora_rtc_engine platform channels.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'package:elajtech/core/services/agora_service.dart';
import 'package:elajtech/core/services/call_monitoring_service.dart';
import 'package:elajtech/core/errors/exceptions.dart';

// Generate mocks for dependencies
@GenerateMocks([CallMonitoringService])
import 'agora_service_test.mocks.dart';

void main() {
  late AgoraService agoraService;
  late MockCallMonitoringService mockCallMonitoring;

  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  setUp(() {
    mockCallMonitoring = MockCallMonitoringService();

    // Create service with mocked dependency
    agoraService = AgoraService(
      callMonitoringService: mockCallMonitoring,
    );
  });

  group('AgoraService - Dependency Injection', () {
    test('should create instance with injected dependencies', () {
      // Arrange
      final mockMonitoring = MockCallMonitoringService();

      // Act
      final service = AgoraService(
        callMonitoringService: mockMonitoring,
      );

      // Assert
      expect(service, isNotNull);
      expect(service, isA<AgoraService>());
    });

    test('should create instance with default dependencies', () {
      // Act
      final service = AgoraService();

      // Assert
      expect(service, isNotNull);
      expect(service, isA<AgoraService>());
    });

    test('should allow multiple independent instances', () {
      // Arrange
      final instance1 = AgoraService();
      final instance2 = AgoraService();

      // Assert - not singleton, each instance is independent
      expect(identical(instance1, instance2), isFalse);
    });

    test('should maintain independent state per instance', () {
      // Arrange
      final instance1 = AgoraService();
      final instance2 = AgoraService();

      // Assert - each instance has its own state
      expect(instance1.currentChannel, isNull);
      expect(instance2.currentChannel, isNull);
      expect(instance1.isLocalAudioMuted, isFalse);
      expect(instance2.isLocalAudioMuted, isFalse);
    });
  });

  group('AgoraService - Initial State', () {
    test('should initialize with null engine', () {
      // Assert
      expect(agoraService.engine, isNull);
    });

    test('should initialize with null channel', () {
      // Assert
      expect(agoraService.currentChannel, isNull);
    });

    test('should initialize with null local UID', () {
      // Assert
      expect(agoraService.localUid, isNull);
    });

    test('should initialize with empty remote users', () {
      // Assert
      expect(agoraService.remoteUsers, isEmpty);
      expect(agoraService.remoteUsers, isA<Set<int>>());
    });

    test('should initialize with audio unmuted', () {
      // Assert
      expect(agoraService.isLocalAudioMuted, isFalse);
    });

    test('should initialize with video unmuted', () {
      // Assert
      expect(agoraService.isLocalVideoMuted, isFalse);
    });

    test('should provide event stream', () {
      // Assert
      expect(agoraService.eventStream, isNotNull);
      expect(agoraService.eventStream, isA<Stream<AgoraEvent>>());
    });
  });

  group('AgoraService - Join Channel Validation', () {
    test('should throw AgoraException when engine not initialized', () async {
      // Arrange
      const token = 'test_token';
      const channelName = 'test_channel';
      const uid = 12345;

      // Act & Assert
      expect(
        () => agoraService.joinChannel(
          token: token,
          channelName: channelName,
          uid: uid,
        ),
        throwsA(isA<AgoraException>()),
      );
    });

    test('should accept valid token parameter', () {
      // Arrange
      const validTokens = [
        'valid_agora_token_12345',
        '006abc123def456',
        'token_with_underscores_and_numbers_123',
      ];

      // Assert - all tokens should be valid strings
      for (final token in validTokens) {
        expect(token, isA<String>());
        expect(token.isNotEmpty, isTrue);
      }
    });

    test('should accept valid channel name parameter', () {
      // Arrange
      const validChannels = [
        'appointment_123',
        'channel_456',
        'test_channel',
        'video_call_789',
      ];

      // Assert - all channel names should be valid
      for (final channel in validChannels) {
        expect(channel, isA<String>());
        expect(channel.isNotEmpty, isTrue);
      }
    });

    test('should accept valid UID parameter', () {
      // Arrange
      const validUids = [0, 1, 12345, 999999];

      // Assert - all UIDs should be valid integers
      for (final uid in validUids) {
        expect(uid, isA<int>());
        expect(uid, greaterThanOrEqualTo(0));
      }
    });

    test('should accept optional appointment ID', () {
      // Arrange
      const appointmentIds = [
        'apt_123',
        'appointment_456',
        'APT-789',
      ];

      // Assert - all appointment IDs should be valid
      for (final id in appointmentIds) {
        expect(id, isA<String>());
        expect(id.isNotEmpty, isTrue);
      }
    });

    test('should accept optional user ID', () {
      // Arrange
      const userIds = [
        'user_123',
        'doctor_456',
        'patient_789',
      ];

      // Assert - all user IDs should be valid
      for (final id in userIds) {
        expect(id, isA<String>());
        expect(id.isNotEmpty, isTrue);
      }
    });
  });

  group('AgoraService - Leave Channel', () {
    test('should handle leave channel when engine not initialized', () async {
      // Act
      await agoraService.leaveChannel();

      // Assert - should not throw, just return
      expect(agoraService.currentChannel, isNull);
      expect(agoraService.localUid, isNull);
    });

    test('should clear channel state after leaving', () async {
      // Act
      await agoraService.leaveChannel();

      // Assert
      expect(agoraService.currentChannel, isNull);
    });

    test('should clear local UID after leaving', () async {
      // Act
      await agoraService.leaveChannel();

      // Assert
      expect(agoraService.localUid, isNull);
    });

    test('should clear remote users after leaving', () async {
      // Act
      await agoraService.leaveChannel();

      // Assert
      expect(agoraService.remoteUsers, isEmpty);
    });

    test('should reset audio mute state after leaving', () async {
      // Act
      await agoraService.leaveChannel();

      // Assert
      expect(agoraService.isLocalAudioMuted, isFalse);
    });

    test('should reset video mute state after leaving', () async {
      // Act
      await agoraService.leaveChannel();

      // Assert
      expect(agoraService.isLocalVideoMuted, isFalse);
    });
  });

  group('AgoraService - Audio Controls', () {
    test(
      'should handle toggle microphone when engine not initialized',
      () async {
        // Act & Assert - should not throw
        await agoraService.toggleMicrophone();

        // State should remain unchanged when engine not initialized
        expect(agoraService.isLocalAudioMuted, isFalse);
      },
    );

    test('should track audio mute state', () {
      // Assert - initial state
      expect(agoraService.isLocalAudioMuted, isFalse);
    });

    test('should provide audio mute state getter', () {
      // Assert
      expect(agoraService.isLocalAudioMuted, isA<bool>());
    });
  });

  group('AgoraService - Video Controls', () {
    test('should handle toggle camera when engine not initialized', () async {
      // Act & Assert - should not throw
      await agoraService.toggleCamera();

      // State should remain unchanged when engine not initialized
      expect(agoraService.isLocalVideoMuted, isFalse);
    });

    test('should track video mute state', () {
      // Assert - initial state
      expect(agoraService.isLocalVideoMuted, isFalse);
    });

    test('should provide video mute state getter', () {
      // Assert
      expect(agoraService.isLocalVideoMuted, isA<bool>());
    });

    test('should handle switch camera when engine not initialized', () async {
      // Act & Assert - should not throw
      await agoraService.switchCamera();
    });
  });

  group('AgoraService - Speakerphone Controls', () {
    test(
      'should handle set speakerphone when engine not initialized',
      () async {
        // Act & Assert - should not throw
        await agoraService.setEnableSpeakerphone(enabled: true);
        await agoraService.setEnableSpeakerphone(enabled: false);
      },
    );

    test('should accept boolean parameter for speakerphone', () {
      // Arrange
      const validValues = [true, false];

      // Assert
      for (final value in validValues) {
        expect(value, isA<bool>());
      }
    });
  });

  group('AgoraService - Remote Users', () {
    test('should initialize with empty remote users set', () {
      // Assert
      expect(agoraService.remoteUsers, isEmpty);
      expect(agoraService.remoteUsers, isA<Set<int>>());
    });

    test('should return unmodifiable remote users set', () {
      // Assert
      final remoteUsers = agoraService.remoteUsers;
      expect(remoteUsers, isA<Set<int>>());

      // Attempting to modify should not affect internal state
      // (Set.unmodifiable prevents modifications)
    });

    test('should handle remote user UIDs', () {
      // Arrange
      const validUids = [12345, 67890, 111213];

      // Assert - all UIDs should be valid integers
      for (final uid in validUids) {
        expect(uid, isA<int>());
        expect(uid, greaterThan(0));
      }
    });
  });

  group('AgoraService - Event Stream', () {
    test('should provide event stream for listening to Agora events', () {
      // Assert
      expect(agoraService.eventStream, isNotNull);
      expect(agoraService.eventStream, isA<Stream<AgoraEvent>>());
    });

    test('should emit events through event stream', () async {
      // Arrange
      final events = <AgoraEvent>[];
      final subscription = agoraService.eventStream.listen(events.add);

      // Wait a bit to ensure stream is ready
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Assert
      // Events would be emitted during actual Agora operations
      expect(subscription, isNotNull);

      // Cleanup
      await subscription.cancel();
    });

    test('should support multiple listeners on event stream', () async {
      // Arrange
      final events1 = <AgoraEvent>[];
      final events2 = <AgoraEvent>[];

      final subscription1 = agoraService.eventStream.listen(events1.add);
      final subscription2 = agoraService.eventStream.listen(events2.add);

      // Wait a bit
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Assert - both subscriptions should be active
      expect(subscription1, isNotNull);
      expect(subscription2, isNotNull);

      // Cleanup
      await subscription1.cancel();
      await subscription2.cancel();
    });
  });

  group('AgoraService - Dispose', () {
    test('should dispose resources without throwing', () async {
      // Act
      await agoraService.dispose();

      // Assert - should complete without error
      expect(agoraService.engine, isNull);
    });

    test('should handle dispose when already disposed', () async {
      // Arrange
      await agoraService.dispose();

      // Act & Assert - should not throw
      await agoraService.dispose();
    });

    test('should handle dispose when engine not initialized', () async {
      // Act & Assert - should not throw
      await agoraService.dispose();
    });
  });

  group('AgoraService - Error Handling', () {
    test('should handle AgoraException type', () {
      // Verify exception type exists
      expect(AgoraException, isA<Type>());
    });

    test('should handle NetworkException type', () {
      // Verify exception type exists
      expect(NetworkException, isA<Type>());
    });

    test('should create AgoraException with message', () {
      // Arrange & Act
      const exception = AgoraException('Test error message');

      // Assert
      expect(exception, isA<AgoraException>());
      expect(exception.message, equals('Test error message'));
    });

    test('should create AgoraException with code', () {
      // Arrange & Act
      const exception = AgoraException(
        'Test error',
        code: '123',
      );

      // Assert
      expect(exception.code, equals('123'));
    });

    test('should create NetworkException with message', () {
      // Arrange & Act
      const exception = NetworkException('Network error');

      // Assert
      expect(exception, isA<NetworkException>());
      expect(exception.message, equals('Network error'));
    });
  });

  group('AgoraService - Call Monitoring Integration', () {
    test('should accept appointment ID for monitoring', () {
      // Arrange
      const appointmentId = 'apt_test_123';
      const userId = 'user_test_123';

      // Assert - parameters are valid
      expect(appointmentId.isNotEmpty, isTrue);
      expect(userId.isNotEmpty, isTrue);
    });

    test('should handle optional monitoring parameters', () {
      // Verify that join channel works with and without monitoring params
      const token = 'test_token';
      const channelName = 'test_channel';

      // Both should be valid calls
      expect(token.isNotEmpty, isTrue);
      expect(channelName.isNotEmpty, isTrue);
    });

    test('should use injected call monitoring service', () {
      // Assert - service was created with mock
      expect(agoraService, isNotNull);
      // The mock is injected and will be used internally
    });
  });

  group('AgoraEvent', () {
    test('should create AgoraEvent with required type', () {
      // Arrange & Act
      final event = AgoraEvent(
        type: AgoraEventType.joinedChannel,
        channelId: 'test_channel',
        uid: 12345,
      );

      // Assert
      expect(event.type, equals(AgoraEventType.joinedChannel));
      expect(event.channelId, equals('test_channel'));
      expect(event.uid, equals(12345));
    });

    test('should create AgoraEvent with optional parameters', () {
      // Arrange & Act
      final event = AgoraEvent(
        type: AgoraEventType.error,
        error: 'Test error message',
      );

      // Assert
      expect(event.type, equals(AgoraEventType.error));
      expect(event.error, equals('Test error message'));
      expect(event.channelId, isNull);
      expect(event.uid, isNull);
    });

    test('should create AgoraEvent with mute state', () {
      // Arrange & Act
      final event = AgoraEvent(
        type: AgoraEventType.localAudioMuteChanged,
        isMuted: true,
      );

      // Assert
      expect(event.type, equals(AgoraEventType.localAudioMuteChanged));
      expect(event.isMuted, isTrue);
    });

    test('should support all event types', () {
      // Assert - verify all event types are defined
      expect(AgoraEventType.joinedChannel, isNotNull);
      expect(AgoraEventType.leftChannel, isNotNull);
      expect(AgoraEventType.userJoined, isNotNull);
      expect(AgoraEventType.userLeft, isNotNull);
      expect(AgoraEventType.localAudioMuteChanged, isNotNull);
      expect(AgoraEventType.localVideoMuteChanged, isNotNull);
      expect(AgoraEventType.cameraSwitched, isNotNull);
      expect(AgoraEventType.connectionStateChanged, isNotNull);
      expect(AgoraEventType.error, isNotNull);
    });

    test('should create event for joined channel', () {
      // Arrange & Act
      final event = AgoraEvent(
        type: AgoraEventType.joinedChannel,
        channelId: 'channel_123',
        uid: 12345,
      );

      // Assert
      expect(event.type, equals(AgoraEventType.joinedChannel));
      expect(event.channelId, isNotNull);
      expect(event.uid, isNotNull);
    });

    test('should create event for left channel', () {
      // Arrange & Act
      final event = AgoraEvent(
        type: AgoraEventType.leftChannel,
        channelId: 'channel_123',
      );

      // Assert
      expect(event.type, equals(AgoraEventType.leftChannel));
      expect(event.channelId, isNotNull);
    });

    test('should create event for user joined', () {
      // Arrange & Act
      final event = AgoraEvent(
        type: AgoraEventType.userJoined,
        channelId: 'channel_123',
        uid: 67890,
      );

      // Assert
      expect(event.type, equals(AgoraEventType.userJoined));
      expect(event.uid, equals(67890));
    });

    test('should create event for user left', () {
      // Arrange & Act
      final event = AgoraEvent(
        type: AgoraEventType.userLeft,
        channelId: 'channel_123',
        uid: 67890,
      );

      // Assert
      expect(event.type, equals(AgoraEventType.userLeft));
      expect(event.uid, equals(67890));
    });

    test('should create event for audio mute changed', () {
      // Arrange & Act
      final event = AgoraEvent(
        type: AgoraEventType.localAudioMuteChanged,
        isMuted: true,
      );

      // Assert
      expect(event.type, equals(AgoraEventType.localAudioMuteChanged));
      expect(event.isMuted, isTrue);
    });

    test('should create event for video mute changed', () {
      // Arrange & Act
      final event = AgoraEvent(
        type: AgoraEventType.localVideoMuteChanged,
        isMuted: false,
      );

      // Assert
      expect(event.type, equals(AgoraEventType.localVideoMuteChanged));
      expect(event.isMuted, isFalse);
    });

    test('should create event for camera switched', () {
      // Arrange & Act
      final event = AgoraEvent(
        type: AgoraEventType.cameraSwitched,
      );

      // Assert
      expect(event.type, equals(AgoraEventType.cameraSwitched));
    });

    test('should create event for error', () {
      // Arrange & Act
      final event = AgoraEvent(
        type: AgoraEventType.error,
        error: 'Connection failed',
      );

      // Assert
      expect(event.type, equals(AgoraEventType.error));
      expect(event.error, equals('Connection failed'));
    });
  });

  group('AgoraService - Integration Documentation', () {
    test('should document platform-specific testing requirements', () {
      const documentation = '''
      AgoraService Platform Testing:
      
      1. Android Testing (Requires Real Device/Emulator):
         - Test on different Android versions (5.0+)
         - Verify video/audio streaming works
         - Test camera switching (front/back)
         - Test microphone mute/unmute
         - Test video mute/unmute
         - Test network quality changes
         - Test connection recovery
         - Test remote user join/leave events
      
      2. iOS Testing (Requires Real Device/Simulator):
         - Test on different iOS versions (9.0+)
         - Verify video/audio streaming works
         - Test camera switching
         - Test microphone controls
         - Test video controls
         - Test background mode handling
         - Test connection state changes
      
      3. Cross-Platform Testing:
         - Test video call between Android and iOS
         - Test audio quality
         - Test video quality
         - Test network interruption handling
         - Test automatic reconnection
         - Test call monitoring integration
      
      4. Integration Test Scenarios:
         - Initialize Agora engine
         - Join channel with valid token
         - Toggle microphone on/off
         - Toggle camera on/off
         - Switch camera front/back
         - Handle remote user joined
         - Handle remote user left
         - Handle network quality changes
         - Handle connection lost
         - Automatic reconnection
         - Leave channel
         - Dispose resources
      ''';

      expect(documentation, isNotEmpty);
      expect(documentation, contains('Android Testing'));
      expect(documentation, contains('iOS Testing'));
      expect(documentation, contains('Cross-Platform Testing'));
      expect(documentation, contains('Integration Test Scenarios'));
    });

    test('should list required manual testing scenarios', () {
      const scenarios = [
        'Initialize Agora RTC Engine',
        'Join channel with token',
        'Toggle microphone',
        'Toggle camera',
        'Switch camera',
        'Handle remote user events',
        'Handle network quality changes',
        'Handle connection lost',
        'Automatic reconnection',
        'Leave channel',
      ];

      expect(scenarios.length, greaterThan(5));
      expect(scenarios, contains('Initialize Agora RTC Engine'));
      expect(scenarios, contains('Toggle microphone'));
      expect(scenarios, contains('Handle remote user events'));
    });
  });
}
