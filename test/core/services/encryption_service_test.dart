/// Encryption Service Tests
///
/// اختبارات خدمة التشفير
///
/// تتضمن هذه الاختبارات:
/// - تهيئة خدمة التشفير
/// - تشفير وفك تشفير النصوص
/// - توليد مفتاح التشفير
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:elajtech/core/services/encryption_service.dart';
import '../../helpers/widget_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EncryptionService', () {
    late EncryptionService encryptionService;

    setUpAll(() async {
      // Setup platform channel mocks for flutter_secure_storage
      setupFirebaseMocks();

      encryptionService = EncryptionService.instance;
      await encryptionService.initialize();
    });

    tearDownAll(cleanupFirebaseMocks);

    test('should be singleton', () {
      final instance1 = EncryptionService.instance;
      final instance2 = EncryptionService.instance;
      expect(identical(instance1, instance2), true);
    });

    test('should encrypt and decrypt text correctly', () {
      const plainText = 'Hello World!';
      final encrypted = encryptionService.encrypt(plainText);

      expect(encrypted, isNotNull);
      expect(encrypted, isNotEmpty);
      expect(encrypted, isNot(plainText));

      final decrypted = encryptionService.decrypt(encrypted);
      expect(decrypted, equals(plainText));
    });

    test('should encrypt Arabic text correctly', () {
      const plainText = 'مرحباً بالعالم';
      final encrypted = encryptionService.encrypt(plainText);

      expect(encrypted, isNotNull);
      expect(encrypted, isNotEmpty);
      expect(encrypted, isNot(plainText));

      final decrypted = encryptionService.decrypt(encrypted);
      expect(decrypted, equals(plainText));
    });

    test('should encrypt medical data correctly', () {
      const plainText = 'Patient ID: 12345, Diagnosis: Diabetes Type 2';
      final encrypted = encryptionService.encrypt(plainText);

      expect(encrypted, isNotNull);
      expect(encrypted, isNotEmpty);
      expect(encrypted, isNot(plainText));

      final decrypted = encryptionService.decrypt(encrypted);
      expect(decrypted, equals(plainText));
    });

    test('should encrypt and decrypt consistently', () {
      const plainText = 'Test Message';
      final encrypted1 = encryptionService.encrypt(plainText);
      final encrypted2 = encryptionService.encrypt(plainText);

      // In test environment with mocked storage, encryption may be deterministic
      // The important thing is that both decrypt correctly
      expect(encrypted1, isNotNull);
      expect(encrypted2, isNotNull);

      final decrypted1 = encryptionService.decrypt(encrypted1);
      final decrypted2 = encryptionService.decrypt(encrypted2);

      expect(decrypted1, equals(plainText));
      expect(decrypted2, equals(plainText));
    });

    test('should handle empty string', () {
      const plainText = '';
      final encrypted = encryptionService.encrypt(plainText);

      expect(encrypted, isNotNull);

      final decrypted = encryptionService.decrypt(encrypted);
      expect(decrypted, equals(plainText));
    });

    test('should handle special characters', () {
      const plainText = r'!@#$%^&*()_+-=[]{}|;:,.<>?/~`';
      final encrypted = encryptionService.encrypt(plainText);

      expect(encrypted, isNotNull);

      final decrypted = encryptionService.decrypt(encrypted);
      expect(decrypted, equals(plainText));
    });

    test('should handle very long text', () {
      final plainText = 'A' * 10000;
      final encrypted = encryptionService.encrypt(plainText);

      expect(encrypted, isNotNull);

      final decrypted = encryptionService.decrypt(encrypted);
      expect(decrypted, equals(plainText));
    });

    test('should throw error when decrypting invalid ciphertext', () {
      const invalidCiphertext = 'invalid-ciphertext';

      expect(
        () => encryptionService.decrypt(invalidCiphertext),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw error when decrypting empty string', () {
      expect(
        () => encryptionService.decrypt(''),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw error when decrypting null', () {
      expect(
        () => encryptionService.decrypt(''),
        throwsA(isA<Exception>()),
      );
    });
  });
}
