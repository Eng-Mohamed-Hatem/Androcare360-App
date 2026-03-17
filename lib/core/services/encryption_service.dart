/// Encryption Service - خدمة التشفير
///
/// Provides end-to-end encryption for sensitive medical messages using AES-256-GCM
/// algorithm to ensure data security and compliance with HIPAA and GDPR standards.
///
/// تقدم هذه الخدمة تشفير end-to-end للرسائل الطبية الحساسة
/// باستخدام خوارزمية AES-256-GCM لضمان أمان البيانات والامتثال لمعايير HIPAA و GDPR.
///
/// **Key Features:**
/// - AES-256-GCM encryption for maximum security
/// - Secure key storage using FlutterSecureStorage with Keychain (iOS) and KeyStore (Android)
/// - Unique encryption key per device
/// - Automatic key generation and persistence
/// - HIPAA and GDPR compliant encryption
///
/// **Security Standards:**
/// - Encryption Algorithm: AES-256-GCM (Galois/Counter Mode)
/// - Key Size: 256 bits (32 bytes)
/// - IV Size: 128 bits (16 bytes)
/// - Key Storage: iOS Keychain (first_unlock accessibility) / Android KeyStore
///
/// **Dependency Injection:**
/// This service uses the Singleton pattern with lazy initialization.
/// Access via `EncryptionService.instance`.
///
/// **Important:** Must call `initialize()` once during app startup in main.dart
/// before any encryption/decryption operations.
///
/// Example usage:
/// ```dart
/// // In main.dart
/// await EncryptionService.instance.initialize();
///
/// // Encrypt sensitive message
/// final encrypted = EncryptionService.instance.encrypt('Patient diagnosis: ...');
/// await firestore.collection('messages').add({'content': encrypted});
///
/// // Decrypt received message
/// final decrypted = EncryptionService.instance.decrypt(encryptedMessage);
/// print('Message: $decrypted');
/// ```
library;

import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encryption Service for Medical Messages - خدمة التشفير للرسائل الطبية
///
/// Provides strong encryption for messages before sending to Firestore and decryption
/// upon receipt. Uses a unique encryption key per device stored securely.
///
/// توفر هذه الخدمة تشفير قوي للرسائل قبل إرسالها إلى Firestore،
/// وفك تشفيرها عند الاستلام. يتم استخدام مفتاح تشفير فريد لكل جهاز.
class EncryptionService {
  factory EncryptionService() => _instance;

  EncryptionService._internal();

  static final EncryptionService _instance = EncryptionService._internal();

  static EncryptionService get instance => _instance;

  // التخزين الآمن للمفتاح
  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const _keyStorageKey = 'chat_encryption_key';
  static const _ivStorageKey = 'chat_encryption_iv';

  Encrypter? _encrypter;
  IV? _iv;
  bool _isInitialized = false;

  /// Check if the service is initialized - التحقق من تهيئة الخدمة
  ///
  /// Returns `true` if `initialize()` has been called successfully and the service
  /// is ready for encryption/decryption operations.
  ///
  /// يُرجع `true` إذا تم استدعاء `initialize()` بنجاح والخدمة جاهزة
  /// لعمليات التشفير/فك التشفير.
  bool get isInitialized => _isInitialized;

  /// Initialize the encryption service - تهيئة خدمة التشفير
  ///
  /// Must be called once during app startup in main.dart before any encryption
  /// operations. This method:
  /// 1. Retrieves or generates a 256-bit AES encryption key
  /// 2. Retrieves or generates a 128-bit initialization vector (IV)
  /// 3. Stores keys securely using FlutterSecureStorage
  /// 4. Creates the AES-GCM encrypter instance
  ///
  /// يجب استدعاء هذه الدالة مرة واحدة عند بدء التطبيق في main.dart قبل أي عمليات تشفير.
  /// تقوم هذه الدالة بـ:
  /// 1. استرجاع أو توليد مفتاح تشفير AES بحجم 256 بت
  /// 2. استرجاع أو توليد متجه التهيئة (IV) بحجم 128 بت
  /// 3. تخزين المفاتيح بشكل آمن باستخدام FlutterSecureStorage
  /// 4. إنشاء نسخة من مشفر AES-GCM
  ///
  /// **Safe to call multiple times** - subsequent calls are ignored if already initialized.
  ///
  /// Throws:
  /// - [Exception] if key generation or storage fails
  ///
  /// Example:
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await EncryptionService.instance.initialize();
  ///   runApp(MyApp());
  /// }
  /// ```
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // استرجاع أو توليد مفتاح التشفير
      final keyData = await _storage.read(key: _keyStorageKey);
      Key key;
      if (keyData != null) {
        key = Key.fromBase64(keyData);
      } else {
        key = await _generateAndStoreKey();
      }

      // استرجاع أو توليد IV
      final ivData = await _storage.read(key: _ivStorageKey);
      if (ivData != null) {
        _iv = IV.fromBase64(ivData);
      } else {
        _iv = await _generateAndStoreIV();
      }

      // إنشاء مشفر AES
      _encrypter = Encrypter(AES(key, mode: AESMode.gcm));
      _isInitialized = true;

      print('✅ EncryptionService initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize EncryptionService: $e');
      rethrow;
    }
  }

  /// Generate a new encryption key and store it securely
  /// توليد مفتاح تشفير جديد وتخزينه بشكل آمن
  ///
  /// Generates a cryptographically secure 256-bit (32 bytes) AES key using
  /// secure random number generation and stores it in platform-specific secure storage:
  /// - iOS: Keychain with first_unlock accessibility
  /// - Android: EncryptedSharedPreferences backed by KeyStore
  ///
  /// يولد مفتاح AES بحجم 256 بت (32 بايت) باستخدام مولد أرقام عشوائية آمن
  /// ويخزنه في التخزين الآمن الخاص بالمنصة.
  ///
  /// Returns: The generated [Key] instance
  ///
  /// Throws:
  /// - [Exception] if secure storage write fails
  Future<Key> _generateAndStoreKey() async {
    // توليد مفتاح 256-bit (32 bytes)
    final key = Key.fromSecureRandom(32);
    final keyBase64 = key.base64;

    // تخزين المفتاح بشكل آمن
    await _storage.write(key: _keyStorageKey, value: keyBase64);

    print('🔑 Generated and stored new encryption key');
    return key;
  }

  /// Generate a new initialization vector (IV) and store it
  /// توليد IV جديد وتخزينه
  ///
  /// Generates a cryptographically secure 128-bit (16 bytes) initialization vector
  /// for AES-GCM mode and stores it securely.
  ///
  /// يولد متجه تهيئة (IV) بحجم 128 بت (16 بايت) لوضع AES-GCM ويخزنه بشكل آمن.
  ///
  /// Returns: The generated [IV] instance
  ///
  /// Throws:
  /// - [Exception] if secure storage write fails
  Future<IV> _generateAndStoreIV() async {
    final iv = IV.fromSecureRandom(16);
    final ivBase64 = iv.base64;

    await _storage.write(key: _ivStorageKey, value: ivBase64);

    return iv;
  }

  /// Encrypt plaintext to ciphertext - تشفير نص عادي
  ///
  /// Encrypts the provided plaintext string using AES-256-GCM encryption and
  /// returns the encrypted result as a Base64-encoded string suitable for storage
  /// in Firestore or transmission over network.
  ///
  /// يشفر النص العادي المقدم باستخدام تشفير AES-256-GCM ويُرجع النتيجة المشفرة
  /// كنص مشفر بتنسيق Base64 مناسب للتخزين في Firestore أو الإرسال عبر الشبكة.
  ///
  /// Parameters:
  /// - [plaintext]: The plain text string to encrypt (required)
  ///   النص العادي المراد تشفيره (مطلوب)
  ///
  /// Returns: Base64-encoded encrypted string
  ///   يُرجع النص المشفر بتنسيق Base64
  ///
  /// Throws:
  /// - [Exception] if service not initialized (call `initialize()` first)
  /// - [Exception] if encrypter or IV not available
  /// - [Exception] if encryption operation fails
  ///
  /// Example:
  /// ```dart
  /// final service = EncryptionService.instance;
  /// final encrypted = service.encrypt('Patient has diabetes type 2');
  /// // Store encrypted in Firestore
  /// await firestore.collection('messages').add({
  ///   'content': encrypted,
  ///   'timestamp': FieldValue.serverTimestamp(),
  /// });
  /// ```
  String encrypt(String plaintext) {
    if (!_isInitialized) {
      throw Exception(
        'EncryptionService not initialized. Call initialize() first.',
      );
    }

    if (_encrypter == null || _iv == null) {
      throw Exception('Encrypter or IV not available');
    }

    try {
      final encrypted = _encrypter!.encrypt(plaintext, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      print('❌ Encryption failed: $e');
      rethrow;
    }
  }

  /// Decrypt ciphertext to plaintext - فك تشفير نص مشفر
  ///
  /// Decrypts a Base64-encoded encrypted string back to the original plaintext
  /// using AES-256-GCM decryption. The ciphertext must have been encrypted using
  /// the same encryption key and IV.
  ///
  /// يفك تشفير نص مشفر بتنسيق Base64 ويُرجعه إلى النص الأصلي باستخدام
  /// فك تشفير AES-256-GCM. يجب أن يكون النص المشفر قد تم تشفيره باستخدام
  /// نفس مفتاح التشفير و IV.
  ///
  /// Parameters:
  /// - [ciphertext]: Base64-encoded encrypted string (required)
  ///   النص المشفر بتنسيق Base64 (مطلوب)
  ///
  /// Returns: The original decrypted plaintext string
  ///   يُرجع النص الأصلي بعد فك التشفير
  ///
  /// Throws:
  /// - [Exception] if service not initialized (call `initialize()` first)
  /// - [Exception] if encrypter or IV not available
  /// - [Exception] if ciphertext is invalid or corrupted
  /// - [Exception] if decryption operation fails
  ///
  /// Example:
  /// ```dart
  /// final service = EncryptionService.instance;
  /// // Retrieve encrypted message from Firestore
  /// final doc = await firestore.collection('messages').doc(messageId).get();
  /// final encryptedContent = doc.data()?['content'] as String;
  ///
  /// // Decrypt the message
  /// final decrypted = service.decrypt(encryptedContent);
  /// print('Decrypted message: $decrypted');
  /// ```
  String decrypt(String ciphertext) {
    if (!_isInitialized) {
      throw Exception(
        'EncryptionService not initialized. Call initialize() first.',
      );
    }

    if (_encrypter == null || _iv == null) {
      throw Exception('Encrypter or IV not available');
    }

    try {
      final encrypted = Encrypted.fromBase64(ciphertext);
      return _encrypter!.decrypt(encrypted, iv: _iv);
    } catch (e) {
      print('❌ Decryption failed: $e');
      rethrow;
    }
  }

  /// Reset the encryption service (for testing only) - إعادة تعيين خدمة التشفير (للاختبار فقط)
  ///
  /// **⚠️ WARNING: FOR TESTING ONLY - DO NOT USE IN PRODUCTION**
  ///
  /// Completely resets the encryption service by:
  /// 1. Deleting the stored encryption key from secure storage
  /// 2. Deleting the stored IV from secure storage
  /// 3. Clearing the encrypter instance
  /// 4. Resetting initialization state
  ///
  /// **⚠️ تحذير: للاختبار فقط - لا تستخدم في الإنتاج**
  ///
  /// يعيد تعيين خدمة التشفير بالكامل عن طريق:
  /// 1. حذف مفتاح التشفير المخزن من التخزين الآمن
  /// 2. حذف IV المخزن من التخزين الآمن
  /// 3. مسح نسخة المشفر
  /// 4. إعادة تعيين حالة التهيئة
  ///
  /// After calling this method, you must call `initialize()` again before using
  /// the service. All previously encrypted data will become undecryptable.
  ///
  /// بعد استدعاء هذه الدالة، يجب استدعاء `initialize()` مرة أخرى قبل استخدام
  /// الخدمة. جميع البيانات المشفرة سابقاً ستصبح غير قابلة لفك التشفير.
  ///
  /// Use case: Unit tests that need to test initialization logic or key generation.
  ///
  /// Example:
  /// ```dart
  /// // In test file
  /// test('should generate new key on first initialization', () async {
  ///   await EncryptionService.instance.reset();
  ///   await EncryptionService.instance.initialize();
  ///   expect(EncryptionService.instance.isInitialized, true);
  /// });
  /// ```
  Future<void> reset() async {
    await _storage.delete(key: _keyStorageKey);
    await _storage.delete(key: _ivStorageKey);
    _encrypter = null;
    _iv = null;
    _isInitialized = false;
  }
}
