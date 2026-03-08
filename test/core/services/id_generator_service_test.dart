/// ID Generator Service Tests
///
/// اختبارات خدمة توليد المعرفات
///
/// تتضمن هذه الاختبارات:
/// - توليد معرفات الرسائل
/// - توليد معرفات المحادثات
/// - التحقق من تفرد المعرفات
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:elajtech/core/services/id_generator_service.dart';

void main() {
  group('IdGeneratorService', () {
    group('generateMessageId', () {
      test('should generate unique message IDs', () {
        final id1 = IdGeneratorService.generateMessageId();
        final id2 = IdGeneratorService.generateMessageId();

        expect(id1, isNotNull);
        expect(id2, isNotNull);
        expect(id1, isNot(equals(id2)));
      });

      test('should generate valid UUID v4 format', () {
        final id = IdGeneratorService.generateMessageId();

        expect(
          id,
          matches(
            RegExp(
              r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
              caseSensitive: false,
            ),
          ),
        );
      });

      test('should generate non-empty IDs', () {
        final id = IdGeneratorService.generateMessageId();

        expect(id, isNotEmpty);
        expect(id.length, equals(36)); // UUID v4 length
      });

      test('should generate IDs with correct format', () {
        final id = IdGeneratorService.generateMessageId();

        expect(id, contains('-'));
        final parts = id.split('-');
        expect(parts.length, equals(5));
        expect(parts[0].length, equals(8));
        expect(parts[1].length, equals(4));
        expect(parts[2].length, equals(4));
        expect(parts[3].length, equals(4));
        expect(parts[4].length, equals(12));
      });
    });

    group('generateConversationId', () {
      test('should generate unique conversation IDs', () {
        final id1 = IdGeneratorService.generateConversationId('user1', 'user2');
        final id2 = IdGeneratorService.generateConversationId('user1', 'user3');

        expect(id1, isNotNull);
        expect(id2, isNotNull);
        expect(id1, isNot(equals(id2)));
      });

      test('should generate consistent IDs for same users', () {
        const user1 = 'user1';
        const user2 = 'user2';
        final id1 = IdGeneratorService.generateConversationId(user1, user2);
        final id2 = IdGeneratorService.generateConversationId(user1, user2);

        expect(id1, equals(id2));
      });

      test('should generate non-empty IDs', () {
        final id = IdGeneratorService.generateConversationId('user1', 'user2');

        expect(id, isNotEmpty);
      });

      test('should generate IDs with underscore separator', () {
        final id = IdGeneratorService.generateConversationId('user1', 'user2');

        expect(id, contains('_'));
        final parts = id.split('_');
        expect(parts.length, equals(2));
      });

      test('should sort user IDs alphabetically', () {
        final id1 = IdGeneratorService.generateConversationId('user2', 'user1');
        final id2 = IdGeneratorService.generateConversationId('user1', 'user2');

        expect(id1, equals(id2));
        expect(id1, startsWith('user1'));
      });
    });

    group('uniqueness', () {
      test('should generate 100 unique message IDs', () {
        final ids = <String>{};

        for (var i = 0; i < 100; i++) {
          final id = IdGeneratorService.generateMessageId();
          ids.add(id);
        }

        expect(ids.length, equals(100));
      });

      test('should generate 100 unique conversation IDs', () {
        final ids = <String>{};

        for (var i = 0; i < 100; i++) {
          final id = IdGeneratorService.generateConversationId(
            'user$i',
            'user${i + 1}',
          );
          ids.add(id);
        }

        expect(ids.length, equals(100));
      });

      test('should not generate duplicate IDs across types', () {
        final messageIds = <String>{};
        final conversationIds = <String>{};

        for (var i = 0; i < 50; i++) {
          messageIds.add(IdGeneratorService.generateMessageId());
          conversationIds.add(
            IdGeneratorService.generateConversationId('user$i', 'user${i + 1}'),
          );
        }

        final allIds = {...messageIds, ...conversationIds};
        expect(allIds.length, equals(100));
      });
    });

    group('format validation', () {
      test('should generate lowercase hex characters only', () {
        final id = IdGeneratorService.generateMessageId();

        final hexChars = RegExp('[0-9a-f]');
        final nonHexChars = id.replaceAll(hexChars, '');

        // UUID has 4 hyphens separating the 5 groups
        expect(nonHexChars, equals('----'));
      });

      test('should have correct UUID version', () {
        final id = IdGeneratorService.generateMessageId();
        final parts = id.split('-');

        // Third group should start with '4' for UUID v4
        expect(parts[2].startsWith('4'), true);
      });

      test('should have correct UUID variant', () {
        final id = IdGeneratorService.generateMessageId();
        final parts = id.split('-');

        // Fourth group should start with '8', '9', 'a', or 'b' for variant 1
        final variantChar = parts[3][0];
        expect(['8', '9', 'a', 'b'].contains(variantChar.toLowerCase()), true);
      });
    });

    group('isValidUuid', () {
      test('should validate correct UUID', () {
        const uuid = '550e8400-e29b-41d4-a716-446655440000';
        final isValid = IdGeneratorService.isValidUuid(uuid);

        expect(isValid, true);
      });

      test('should reject invalid UUID', () {
        const uuid = 'not-a-uuid';
        final isValid = IdGeneratorService.isValidUuid(uuid);

        expect(isValid, false);
      });

      test('should reject empty string', () {
        const uuid = '';
        final isValid = IdGeneratorService.isValidUuid(uuid);

        expect(isValid, false);
      });

      test('should reject UUID with wrong format', () {
        const uuid = '550e8400-e29b-41d4-a716';
        final isValid = IdGeneratorService.isValidUuid(uuid);

        expect(isValid, false);
      });
    });

    group('isValidConversationId', () {
      test('should validate correct conversation ID', () {
        // Use longer user IDs that meet the 10-128 character requirement
        const conversationId = 'user123456_user789012';
        final isValid = IdGeneratorService.isValidConversationId(
          conversationId,
        );

        expect(isValid, true);
      });

      test('should reject empty conversation ID', () {
        const conversationId = '';
        final isValid = IdGeneratorService.isValidConversationId(
          conversationId,
        );

        expect(isValid, false);
      });

      test('should reject conversation ID with wrong format', () {
        const conversationId = 'user1_user2_extra';
        final isValid = IdGeneratorService.isValidConversationId(
          conversationId,
        );

        expect(isValid, false);
      });

      test('should reject conversation ID with single part', () {
        const conversationId = 'user1';
        final isValid = IdGeneratorService.isValidConversationId(
          conversationId,
        );

        expect(isValid, false);
      });
    });

    group('extractUserIds', () {
      test('should extract user IDs from conversation ID', () {
        const conversationId = 'user1_user2';
        final userIds = IdGeneratorService.extractUserIds(conversationId);

        expect(userIds.length, equals(2));
        expect(userIds[0], equals('user1'));
        expect(userIds[1], equals('user2'));
      });

      test('should return list with single element for invalid ID', () {
        const conversationId = 'single';
        final userIds = IdGeneratorService.extractUserIds(conversationId);

        expect(userIds.length, equals(1));
        expect(userIds[0], equals('single'));
      });
    });

    group('generateShortMessageId', () {
      test('should generate unique short IDs', () async {
        final id1 = IdGeneratorService.generateShortMessageId();

        // Add a small delay to ensure different timestamp
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final id2 = IdGeneratorService.generateShortMessageId();

        expect(id1, isNotNull);
        expect(id2, isNotNull);
        expect(id1, isNot(equals(id2)));
      });

      test('should generate IDs with timestamp format', () {
        final id = IdGeneratorService.generateShortMessageId();

        expect(id, contains('-'));
        final parts = id.split('-');
        expect(parts.length, equals(2));
        expect(parts[0], isNotEmpty);
        expect(parts[1], isNotEmpty);
      });
    });

    group('generateDocumentId', () {
      test('should generate unique document IDs', () {
        final id1 = IdGeneratorService.generateDocumentId();
        final id2 = IdGeneratorService.generateDocumentId();

        expect(id1, isNotNull);
        expect(id2, isNotNull);
        expect(id1, isNot(equals(id2)));
      });

      test('should generate valid UUID v4 format', () {
        final id = IdGeneratorService.generateDocumentId();

        expect(
          id,
          matches(
            RegExp(
              r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
              caseSensitive: false,
            ),
          ),
        );
      });
    });

    group('generateFileId', () {
      test('should generate unique file IDs', () async {
        final id1 = IdGeneratorService.generateFileId();

        // Add a small delay to ensure different timestamp
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final id2 = IdGeneratorService.generateFileId();

        expect(id1, isNotNull);
        expect(id2, isNotNull);
        expect(id1, isNot(equals(id2)));
      });

      test('should generate IDs with file prefix', () {
        final id = IdGeneratorService.generateFileId();

        expect(id, startsWith('file_'));
      });

      test('should generate IDs with timestamp format', () {
        final id = IdGeneratorService.generateFileId();

        expect(id, contains('-'));
        final parts = id.split('-');
        expect(parts.length, greaterThan(1));
      });
    });

    group('generateNotificationId', () {
      test('should generate unique notification IDs', () {
        final id1 = IdGeneratorService.generateNotificationId();
        final id2 = IdGeneratorService.generateNotificationId();

        expect(id1, isNotNull);
        expect(id2, isNotNull);
        expect(id1, isNot(equals(id2)));
      });

      test('should generate valid UUID v4 format', () {
        final id = IdGeneratorService.generateNotificationId();

        expect(
          id,
          matches(
            RegExp(
              r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
              caseSensitive: false,
            ),
          ),
        );
      });
    });
  });
}
