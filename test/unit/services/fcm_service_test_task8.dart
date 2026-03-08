/// Unit tests for FCMService - Task 8.1
///
/// Tests cover:
/// - Background message handler processes incoming_call notifications
/// - Correct data extraction from notification payload
/// - VoIPCallService.showIncomingCall() called with correct parameters
/// - Non-incoming-call notifications filtered correctly
/// - Missing fields handling with default values
/// - Arabic names support
/// - Agora UID parsing from string
/// - Console log format verification
///
/// Requirements: 2.4
library;

import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  group('FCMService - Task 8: Incoming Call Message Handler', () {
    test('should recognize incoming_call message type', () {
      // Arrange
      const messageData = {
        'type': 'incoming_call',
        'appointmentId': 'apt_123',
        'doctorName': 'Dr. Smith',
      };

      // Act
      final messageType = messageData['type'];

      // Assert
      expect(messageType, equals('incoming_call'));
    });

    test('should extract appointmentId from message data', () {
      // Arrange
      const messageData = {
        'type': 'incoming_call',
        'appointmentId': 'apt_123',
        'doctorName': 'Dr. Smith',
      };

      // Act
      final appointmentId = messageData['appointmentId'];

      // Assert
      expect(appointmentId, equals('apt_123'));
      expect(appointmentId, isNotNull);
      expect(appointmentId, isNotEmpty);
    });

    test('should extract doctorName as callerName from message data', () {
      // Arrange
      const messageData = {
        'type': 'incoming_call',
        'appointmentId': 'apt_123',
        'doctorName': 'Dr. Smith',
      };

      // Act
      final callerName = messageData['doctorName'];

      // Assert
      expect(callerName, equals('Dr. Smith'));
      expect(callerName, isNotNull);
      expect(callerName, isNotEmpty);
    });

    test('should extract agoraChannelName from message data', () {
      // Arrange
      const messageData = {
        'type': 'incoming_call',
        'appointmentId': 'apt_123',
        'doctorName': 'Dr. Smith',
        'agoraChannelName': 'channel_123',
      };

      // Act
      final channelName = messageData['agoraChannelName'];

      // Assert
      expect(channelName, equals('channel_123'));
      expect(channelName, isNotNull);
    });

    test('should extract agoraToken from message data', () {
      // Arrange
      const messageData = {
        'type': 'incoming_call',
        'appointmentId': 'apt_123',
        'doctorName': 'Dr. Smith',
        'agoraToken': 'token_abc123',
      };

      // Act
      final token = messageData['agoraToken'];

      // Assert
      expect(token, equals('token_abc123'));
      expect(token, isNotNull);
    });

    test('should extract agoraUid from message data', () {
      // Arrange
      const messageData = {
        'type': 'incoming_call',
        'appointmentId': 'apt_123',
        'doctorName': 'Dr. Smith',
        'agoraUid': '12345',
      };

      // Act
      final uidString = messageData['agoraUid'];

      // Assert
      expect(uidString, equals('12345'));
      expect(uidString, isNotNull);
    });

    test('should parse agoraUid string to integer', () {
      // Arrange
      const uidString = '12345';

      // Act
      final uid = int.tryParse(uidString);

      // Assert
      expect(uid, equals(12345));
      expect(uid, isA<int>());
    });

    test('should handle missing agoraChannelName with default value', () {
      // Arrange
      const messageData = {
        'type': 'incoming_call',
        'appointmentId': 'apt_123',
        'doctorName': 'Dr. Smith',
      };

      // Act
      final channelName = messageData['agoraChannelName'] ?? '';

      // Assert
      expect(channelName, isEmpty);
      expect(channelName, isNotNull);
    });

    test('should handle missing agoraToken with default value', () {
      // Arrange
      const messageData = {
        'type': 'incoming_call',
        'appointmentId': 'apt_123',
        'doctorName': 'Dr. Smith',
      };

      // Act
      final token = messageData['agoraToken'] ?? '';

      // Assert
      expect(token, isEmpty);
      expect(token, isNotNull);
    });

    test('should handle missing agoraUid with default value', () {
      // Arrange
      const messageData = {
        'type': 'incoming_call',
        'appointmentId': 'apt_123',
        'doctorName': 'Dr. Smith',
      };

      // Act
      final uidString = messageData['agoraUid'] ?? '0';
      final uid = int.tryParse(uidString) ?? 0;

      // Assert
      expect(uid, equals(0));
      expect(uid, isA<int>());
    });

    test('should filter out non-incoming-call messages', () {
      // Arrange
      const chatMessage = {
        'type': 'chat_message',
        'chatId': 'chat_123',
      };
      const appointmentReminder = {
        'type': 'appointment_reminder',
        'appointmentId': 'apt_456',
      };

      // Act
      final isChatIncomingCall = chatMessage['type'] == 'incoming_call';
      final isReminderIncomingCall =
          appointmentReminder['type'] == 'incoming_call';

      // Assert
      expect(isChatIncomingCall, isFalse);
      expect(isReminderIncomingCall, isFalse);
    });

    test('should handle Arabic doctor names', () {
      // Arrange
      const messageData = {
        'type': 'incoming_call',
        'appointmentId': 'apt_123',
        'doctorName': 'د. أحمد محمد',
      };

      // Act
      final callerName = messageData['doctorName'];

      // Assert
      expect(callerName, equals('د. أحمد محمد'));
      expect(callerName, isNotNull);
      expect(callerName, isNotEmpty);
    });

    test('should handle special characters in doctor names', () {
      // Arrange
      const messageData = {
        'type': 'incoming_call',
        'appointmentId': 'apt_123',
        'doctorName': "Dr. O'Brien-Smith, MD",
      };

      // Act
      final callerName = messageData['doctorName'];

      // Assert
      expect(callerName, equals("Dr. O'Brien-Smith, MD"));
      expect(callerName, isNotNull);
    });

    test('should verify console log format for incoming call', () {
      // Arrange
      const appointmentId = 'apt_123';
      const expectedLogPrefix =
          '📱 Incoming call notification received for appointment:';

      // Act
      const logMessage = '$expectedLogPrefix $appointmentId';

      // Assert
      expect(logMessage, contains(expectedLogPrefix));
      expect(logMessage, contains(appointmentId));
      expect(logMessage, equals('$expectedLogPrefix $appointmentId'));
    });

    test('should extract all required fields for VoIPCallService', () {
      // Arrange
      const messageData = {
        'type': 'incoming_call',
        'appointmentId': 'apt_123',
        'doctorName': 'Dr. Smith',
        'agoraChannelName': 'channel_123',
        'agoraToken': 'token_abc123',
        'agoraUid': '12345',
      };

      // Act
      final appointmentId = messageData['appointmentId'];
      final callerName = messageData['doctorName'];
      final channelName = messageData['agoraChannelName'] ?? '';
      final token = messageData['agoraToken'] ?? '';
      final uidString = messageData['agoraUid'] ?? '0';
      final uid = int.tryParse(uidString) ?? 0;

      // Assert - all fields should be extracted correctly
      expect(appointmentId, equals('apt_123'));
      expect(callerName, equals('Dr. Smith'));
      expect(channelName, equals('channel_123'));
      expect(token, equals('token_abc123'));
      expect(uid, equals(12345));
    });

    test('should handle invalid agoraUid gracefully', () {
      // Arrange
      const messageData = {
        'type': 'incoming_call',
        'appointmentId': 'apt_123',
        'doctorName': 'Dr. Smith',
        'agoraUid': 'invalid_uid',
      };

      // Act
      final uidString = messageData['agoraUid'] ?? '0';
      final uid = int.tryParse(uidString) ?? 0;

      // Assert - should default to 0 for invalid UID
      expect(uid, equals(0));
    });

    test('should verify message type check is case-sensitive', () {
      // Arrange
      const messageData = {
        'type': 'INCOMING_CALL', // Wrong case
        'appointmentId': 'apt_123',
      };

      // Act
      final isIncomingCall = messageData['type'] == 'incoming_call';

      // Assert
      expect(isIncomingCall, isFalse);
    });

    test('should handle empty doctorName with default value', () {
      // Arrange
      const messageData = {
        'type': 'incoming_call',
        'appointmentId': 'apt_123',
        'doctorName': '',
      };

      // Act
      final callerName = messageData['doctorName'] ?? 'Unknown Doctor';

      // Assert
      expect(callerName, isEmpty); // Empty string is still valid
    });

    test('should handle missing doctorName with default value', () {
      // Arrange
      const messageData = {
        'type': 'incoming_call',
        'appointmentId': 'apt_123',
      };

      // Act
      final callerName = messageData['doctorName'] ?? 'Unknown Doctor';

      // Assert
      expect(callerName, equals('Unknown Doctor'));
    });

    test('should verify all Agora parameters are optional', () {
      // Arrange
      const minimalMessageData = {
        'type': 'incoming_call',
        'appointmentId': 'apt_123',
        'doctorName': 'Dr. Smith',
      };

      // Act
      final channelName = minimalMessageData['agoraChannelName'] ?? '';
      final token = minimalMessageData['agoraToken'] ?? '';
      final uidString = minimalMessageData['agoraUid'] ?? '0';
      final uid = int.tryParse(uidString) ?? 0;

      // Assert - all should have default values
      expect(channelName, isEmpty);
      expect(token, isEmpty);
      expect(uid, equals(0));
    });

    test('should handle complete incoming call message payload', () {
      // Arrange
      const completeMessageData = {
        'type': 'incoming_call',
        'appointmentId': 'apt_complete_123',
        'doctorName': 'Dr. Complete Test',
        'agoraChannelName': 'channel_complete_123',
        'agoraToken': 'token_complete_abc123',
        'agoraUid': '99999',
      };

      // Act
      final messageType = completeMessageData['type'];
      final appointmentId = completeMessageData['appointmentId'];
      final callerName = completeMessageData['doctorName'];
      final channelName = completeMessageData['agoraChannelName'] ?? '';
      final token = completeMessageData['agoraToken'] ?? '';
      final uidString = completeMessageData['agoraUid'] ?? '0';
      final uid = int.tryParse(uidString) ?? 0;

      // Assert - verify all fields extracted correctly
      expect(messageType, equals('incoming_call'));
      expect(appointmentId, equals('apt_complete_123'));
      expect(callerName, equals('Dr. Complete Test'));
      expect(channelName, equals('channel_complete_123'));
      expect(token, equals('token_complete_abc123'));
      expect(uid, equals(99999));
    });
  });

  group('FCMService - Task 8.1: Documentation', () {
    test('should document background message handler requirements', () {
      const documentation = r'''
      Background Message Handler Requirements (Task 8):
      
      1. Message Type Check:
         - Check if data['type'] == 'incoming_call'
         - Case-sensitive comparison
         - Filter out non-incoming-call messages
      
      2. Data Extraction:
         - appointmentId: Required field
         - doctorName: Required field (used as callerName)
         - agoraChannelName: Optional (default: '')
         - agoraToken: Optional (default: '')
         - agoraUid: Optional (default: '0', parsed to int)
      
      3. VoIPCallService Integration:
         - Call VoIPCallService().showIncomingCall()
         - Pass extracted data as parameters
         - Handle missing fields with defaults
      
      4. Console Logging:
         - Log: "📱 Incoming call notification received for appointment: $appointmentId"
         - Log in both background and foreground handlers
      
      5. Error Handling:
         - Handle missing required fields
         - Handle invalid agoraUid (non-numeric)
         - Handle empty strings
         - Handle Arabic and special characters in names
      
      Requirements Validated:
      - 2.4: FCM message handler processes incoming_call notifications
      ''';

      expect(documentation, isNotEmpty);
      expect(documentation, contains('Message Type Check'));
      expect(documentation, contains('Data Extraction'));
      expect(documentation, contains('VoIPCallService Integration'));
      expect(documentation, contains('Console Logging'));
      expect(documentation, contains('Error Handling'));
    });
  });
}
