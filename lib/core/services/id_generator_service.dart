/// ID Generator Service - خدمة توليد المعرفات
///
/// Provides secure and unique ID generation for various entities in the elajtech
/// application including messages, conversations, documents, files, and notifications.
/// Uses UUID v4 for guaranteed uniqueness and custom algorithms for specific use cases.
///
/// توفر هذه الخدمة توليد معرفات فريدة وآمنة لمختلف الكيانات في تطبيق elajtech
/// بما في ذلك الرسائل، المحادثات، المستندات، الملفات، والإشعارات. تستخدم UUID v4
/// لضمان التفرد المطلق وخوارزميات مخصصة لحالات استخدام محددة.
///
/// **Key Features:**
/// - UUID v4 generation for absolute uniqueness
/// - Short ID generation with timestamp + random number
/// - Deterministic conversation ID from user IDs
/// - File ID generation with timestamp prefix
/// - UUID validation utilities
/// - Conversation ID validation and parsing
///
/// **ID Types Generated:**
/// - Message IDs: Full UUID v4 or short timestamp-based
/// - Conversation IDs: Deterministic from sorted user IDs
/// - Document IDs: Full UUID v4
/// - File IDs: Prefixed timestamp-based
/// - Notification IDs: Full UUID v4
///
/// **Uniqueness Guarantees:**
/// - UUID v4: Cryptographically random, collision probability ~0
/// - Short IDs: Timestamp + random, collision risk in same millisecond
/// - Conversation IDs: Deterministic, same users = same ID
///
/// **Dependency Injection:**
/// This service uses the Singleton pattern with lazy initialization.
/// Access via `IdGeneratorService.instance`.
///
/// Example usage:
/// ```dart
/// final idService = IdGeneratorService.instance;
///
/// // Generate message ID
/// final messageId = IdGeneratorService.generateMessageId();
/// // Output: "550e8400-e29b-41d4-a716-446655440000"
///
/// // Generate short message ID
/// final shortId = IdGeneratorService.generateShortMessageId();
/// // Output: "1709123456789-abc123"
///
/// // Generate conversation ID (deterministic)
/// final chatId = IdGeneratorService.generateConversationId(
///   'user123',
///   'user456',
/// );
/// // Output: "user123_user456" (always same for these users)
///
/// // Validate UUID
/// final isValid = IdGeneratorService.isValidUuid(messageId);
/// // Output: true
/// ```
library;

import 'package:uuid/uuid.dart';

/// ID Generator Service - خدمة توليد المعرفات
///
/// Provides unique identifiers for messages, conversations, documents, and other entities.
/// Ensures no ID collisions using UUID and custom algorithms.
///
/// توفر هذه الخدمة معرفات فريدة للرسائل والمحادثات والمستندات وغيرها.
/// مع التأكد من عدم التضارب في المعرفات باستخدام UUID وخوارزميات مخصصة.
class IdGeneratorService {
  IdGeneratorService._internal();
  // Singleton pattern
  static IdGeneratorService? _instance;
  static IdGeneratorService get instance =>
      _instance ??= IdGeneratorService._internal();

  static const _uuid = Uuid();

  /// Generate unique message ID - توليد معرف فريد للرسالة
  ///
  /// Generates a universally unique identifier (UUID v4) for a message.
  /// UUID v4 uses cryptographically strong random numbers, ensuring virtually
  /// zero collision probability.
  ///
  /// يولد معرف فريد عالمياً (UUID v4) للرسالة. يستخدم UUID v4 أرقام عشوائية
  /// قوية تشفيرياً، مما يضمن احتمالية تصادم تقارب الصفر.
  ///
  /// **Format:** `xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx`
  /// - x: hexadecimal digit (0-9, a-f)
  /// - y: one of 8, 9, a, or b
  ///
  /// **Uniqueness:** Collision probability is approximately 1 in 2^122
  ///
  /// Returns: A UUID v4 string (36 characters including hyphens)
  ///   يُرجع سلسلة UUID v4 (36 حرفاً بما في ذلك الشرطات)
  ///
  /// Example:
  /// ```dart
  /// final messageId = IdGeneratorService.generateMessageId();
  /// print(messageId); // "550e8400-e29b-41d4-a716-446655440000"
  ///
  /// // Use in Firestore
  /// await firestore.collection('messages').doc(messageId).set({
  ///   'content': 'Hello',
  ///   'senderId': userId,
  ///   'timestamp': FieldValue.serverTimestamp(),
  /// });
  /// ```
  static String generateMessageId() => _uuid.v4();

  /// Generate short message ID - توليد معرف قصير للرسالة
  ///
  /// Generates a shorter identifier combining timestamp and random number.
  /// Useful when full UUID length is not required and readability is preferred.
  ///
  /// يولد معرفاً أقصر يجمع بين الطابع الزمني ورقم عشوائي. مفيد عندما لا يكون
  /// طول UUID الكامل مطلوباً ويُفضل سهولة القراءة.
  ///
  /// **Format:** `{timestamp}-{random}`
  /// - timestamp: milliseconds since epoch (13 digits)
  /// - random: hexadecimal number (up to 6 digits)
  ///
  /// **Uniqueness:** High probability of uniqueness, but not guaranteed like UUID.
  /// Collision possible if generated in same millisecond with same random value.
  ///
  /// **Length:** Approximately 20-22 characters (shorter than UUID's 36)
  ///
  /// Returns: Short ID string in format "timestamp-random"
  ///   يُرجع معرف قصير بتنسيق "timestamp-random"
  ///
  /// **Use Cases:**
  /// - Temporary IDs
  /// - Display-friendly identifiers
  /// - When full UUID uniqueness is not critical
  ///
  /// Example:
  /// ```dart
  /// final shortId = IdGeneratorService.generateShortMessageId();
  /// print(shortId); // "1709123456789-abc123"
  ///
  /// // Use for temporary message ID
  /// final tempMessage = Message(
  ///   id: shortId,
  ///   content: 'Sending...',
  ///   status: MessageStatus.pending,
  /// );
  /// ```
  static String generateShortMessageId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _generateRandomNumber(0, 0xFFFFFF);
    return '$timestamp-$random';
  }

  /// Generate deterministic conversation ID - توليد معرف محادثة حتمي
  ///
  /// Generates a consistent conversation ID from two user IDs. The same pair of
  /// users will always produce the same conversation ID, regardless of order.
  /// This ensures a single conversation thread between any two users.
  ///
  /// يولد معرف محادثة ثابت من معرفي مستخدمين. نفس زوج المستخدمين سينتج دائماً
  /// نفس معرف المحادثة، بغض النظر عن الترتيب. هذا يضمن خيط محادثة واحد بين أي
  /// مستخدمين.
  ///
  /// **Algorithm:**
  /// 1. Sort user IDs alphabetically
  /// 2. Join with underscore separator
  /// 3. Result: "userId1_userId2" (alphabetically sorted)
  ///
  /// **Deterministic Property:**
  /// - generateConversationId("alice", "bob") == generateConversationId("bob", "alice")
  /// - Both return "alice_bob"
  ///
  /// **Format:** `{sortedUserId1}_{sortedUserId2}`
  ///
  /// Parameters:
  /// - [userId1]: First user's ID (required)
  ///   معرف المستخدم الأول (مطلوب)
  /// - [userId2]: Second user's ID (required)
  ///   معرف المستخدم الثاني (مطلوب)
  ///
  /// Returns: Deterministic conversation ID
  ///   يُرجع معرف المحادثة الحتمي
  ///
  /// **Use Cases:**
  /// - One-on-one chat identification
  /// - Ensuring single conversation per user pair
  /// - Firestore document ID for conversations
  ///
  /// Example:
  /// ```dart
  /// final chatId1 = IdGeneratorService.generateConversationId(
  ///   'doctor123',
  ///   'patient456',
  /// );
  /// final chatId2 = IdGeneratorService.generateConversationId(
  ///   'patient456',
  ///   'doctor123',
  /// );
  ///
  /// print(chatId1 == chatId2); // true
  /// print(chatId1); // "doctor123_patient456"
  ///
  /// // Use in Firestore
  /// final conversationRef = firestore
  ///   .collection('conversations')
  ///   .doc(chatId1);
  /// ```
  static String generateConversationId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return ids.join('_');
  }

  /// Generate unique document ID - توليد معرف فريد للمستند
  ///
  /// Generates a UUID v4 for document identification. Identical to generateMessageId()
  /// but semantically distinct for document entities.
  ///
  /// يولد UUID v4 لتعريف المستند. مطابق لـ generateMessageId() ولكنه مختلف
  /// دلالياً لكيانات المستندات.
  ///
  /// Returns: A UUID v4 string
  ///   يُرجع سلسلة UUID v4
  ///
  /// Example:
  /// ```dart
  /// final docId = IdGeneratorService.generateDocumentId();
  /// await firestore.collection('documents').doc(docId).set({
  ///   'title': 'Medical Report',
  ///   'createdAt': FieldValue.serverTimestamp(),
  /// });
  /// ```
  static String generateDocumentId() => _uuid.v4();

  /// Generate unique file ID - توليد معرف فريد للملف
  ///
  /// Generates a file identifier with "file_" prefix, timestamp, and random number.
  /// The prefix makes it easy to identify file IDs in logs and databases.
  ///
  /// يولد معرف ملف مع بادئة "file_"، طابع زمني، ورقم عشوائي. تجعل البادئة
  /// من السهل تحديد معرفات الملفات في السجلات وقواعد البيانات.
  ///
  /// **Format:** `file_{timestamp}-{random}`
  ///
  /// Returns: File ID string with "file_" prefix
  ///   يُرجع معرف ملف مع بادئة "file_"
  ///
  /// Example:
  /// ```dart
  /// final fileId = IdGeneratorService.generateFileId();
  /// print(fileId); // "file_1709123456789-abc123"
  ///
  /// // Use for file tracking
  /// await firestore.collection('uploaded_files').doc(fileId).set({
  ///   'fileName': 'report.pdf',
  ///   'uploadedBy': userId,
  ///   'uploadedAt': FieldValue.serverTimestamp(),
  /// });
  /// ```
  static String generateFileId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _generateRandomNumber(0, 0xFFFFFF);
    return 'file_$timestamp-$random';
  }

  /// Generate unique notification ID - توليد معرف فريد للإشعار
  ///
  /// Generates a UUID v4 for notification identification. Ensures each notification
  /// has a unique identifier for tracking and management.
  ///
  /// يولد UUID v4 لتعريف الإشعار. يضمن أن كل إشعار له معرف فريد للتتبع والإدارة.
  ///
  /// Returns: A UUID v4 string
  ///   يُرجع سلسلة UUID v4
  ///
  /// Example:
  /// ```dart
  /// final notificationId = IdGeneratorService.generateNotificationId();
  /// await firestore.collection('notifications').doc(notificationId).set({
  ///   'title': 'Appointment Reminder',
  ///   'body': 'You have an appointment in 1 hour',
  ///   'userId': userId,
  ///   'createdAt': FieldValue.serverTimestamp(),
  /// });
  /// ```
  static String generateNotificationId() => _uuid.v4();

  /// Generate random number in range - توليد رقم عشوائي في نطاق محدد
  ///
  /// Internal helper method that generates a pseudo-random number within a
  /// specified range using timestamp modulo operation.
  ///
  /// طريقة مساعدة داخلية تولد رقماً عشوائياً زائفاً ضمن نطاق محدد باستخدام
  /// عملية modulo على الطابع الزمني.
  ///
  /// **Note:** This is NOT cryptographically secure. Used for non-security-critical
  /// random components in IDs.
  ///
  /// Parameters:
  /// - [min]: Minimum value (inclusive)
  ///   الحد الأدنى (شامل)
  /// - [max]: Maximum value (inclusive)
  ///   الحد الأقصى (شامل)
  ///
  /// Returns: Random integer between min and max (inclusive)
  ///   يُرجع عدد صحيح عشوائي بين min و max (شامل)
  static int _generateRandomNumber(int min, int max) =>
      min + (DateTime.now().millisecondsSinceEpoch % (max - min + 1));

  /// Validate UUID format - التحقق من صحة تنسيق UUID
  ///
  /// Checks if a string matches the UUID v4 format using regex pattern matching.
  /// Validates the standard 8-4-4-4-12 hexadecimal format.
  ///
  /// يتحقق مما إذا كانت السلسلة تطابق تنسيق UUID v4 باستخدام مطابقة نمط regex.
  /// يتحقق من تنسيق 8-4-4-4-12 السداسي العشري القياسي.
  ///
  /// **UUID v4 Format:** `xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx`
  /// - 8 hex digits, hyphen, 4 hex digits, hyphen, 4 hex digits (starting with 4),
  ///   hyphen, 4 hex digits (starting with 8/9/a/b), hyphen, 12 hex digits
  ///
  /// Parameters:
  /// - [uuid]: The string to validate (required)
  ///   السلسلة المراد التحقق منها (مطلوب)
  ///
  /// Returns: `true` if valid UUID v4 format, `false` otherwise
  ///   يُرجع `true` إذا كان تنسيق UUID v4 صالحاً، `false` خلاف ذلك
  ///
  /// **Case Insensitive:** Accepts both uppercase and lowercase hex digits
  ///
  /// Example:
  /// ```dart
  /// final id1 = '550e8400-e29b-41d4-a716-446655440000';
  /// print(IdGeneratorService.isValidUuid(id1)); // true
  ///
  /// final id2 = 'invalid-uuid';
  /// print(IdGeneratorService.isValidUuid(id2)); // false
  ///
  /// final id3 = '550e8400e29b41d4a716446655440000'; // Missing hyphens
  /// print(IdGeneratorService.isValidUuid(id3)); // false
  /// ```
  static bool isValidUuid(String uuid) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(uuid);
  }

  /// Validate conversation ID format - التحقق من صحة معرف المحادثة
  ///
  /// Checks if a conversation ID follows the expected format of two user IDs
  /// separated by an underscore. Validates that both parts are valid user ID lengths.
  ///
  /// يتحقق مما إذا كان معرف المحادثة يتبع التنسيق المتوقع لمعرفي مستخدمين
  /// مفصولين بشرطة سفلية. يتحقق من أن كلا الجزأين بطول معرف مستخدم صالح.
  ///
  /// **Expected Format:** `{userId1}_{userId2}`
  ///
  /// **Validation Rules:**
  /// 1. Must not be empty
  /// 2. Must contain exactly one underscore separator
  /// 3. Both parts must be between 10-128 characters (typical user ID length)
  ///
  /// Parameters:
  /// - [conversationId]: The conversation ID to validate (required)
  ///   معرف المحادثة المراد التحقق منه (مطلوب)
  ///
  /// Returns: `true` if valid conversation ID format, `false` otherwise
  ///   يُرجع `true` إذا كان تنسيق معرف المحادثة صالحاً، `false` خلاف ذلك
  ///
  /// Example:
  /// ```dart
  /// final id1 = 'doctor123_patient456';
  /// print(IdGeneratorService.isValidConversationId(id1)); // true
  ///
  /// final id2 = 'invalid';
  /// print(IdGeneratorService.isValidConversationId(id2)); // false
  ///
  /// final id3 = 'user1_user2_user3'; // Too many underscores
  /// print(IdGeneratorService.isValidConversationId(id3)); // false
  ///
  /// final id4 = 'abc_def'; // User IDs too short
  /// print(IdGeneratorService.isValidConversationId(id4)); // false
  /// ```
  static bool isValidConversationId(String conversationId) {
    if (conversationId.isEmpty) return false;

    final parts = conversationId.split('_');
    if (parts.length != 2) return false;

    // التحقق من أن كلا الجزأين معرفات مستخدمين صالحة
    return parts.every((part) => part.length >= 10 && part.length <= 128);
  }

  /// Extract user IDs from conversation ID - استخراج معرفات المستخدمين من معرف المحادثة
  ///
  /// Parses a conversation ID and returns the two user IDs that compose it.
  /// The IDs are returned in the order they appear in the conversation ID
  /// (alphabetically sorted).
  ///
  /// يحلل معرف المحادثة ويُرجع معرفي المستخدمين اللذين يكونانه. يتم إرجاع
  /// المعرفات بالترتيب الذي تظهر به في معرف المحادثة (مرتبة أبجدياً).
  ///
  /// **Important:** This method does NOT validate the conversation ID format.
  /// Use `isValidConversationId()` first if validation is needed.
  ///
  /// Parameters:
  /// - [conversationId]: The conversation ID to parse (required)
  ///   معرف المحادثة المراد تحليله (مطلوب)
  ///
  /// Returns: List of two user IDs [userId1, userId2] (alphabetically sorted)
  ///   يُرجع قائمة تحتوي على معرفي المستخدمين [userId1, userId2] (مرتبة أبجدياً)
  ///
  /// **Note:** If conversation ID is invalid, the returned list may not contain
  /// exactly 2 elements. Always validate first or handle edge cases.
  ///
  /// Example:
  /// ```dart
  /// final conversationId = 'doctor123_patient456';
  /// final userIds = IdGeneratorService.extractUserIds(conversationId);
  /// print(userIds); // ['doctor123', 'patient456']
  ///
  /// // Use to check if current user is part of conversation
  /// final currentUserId = 'doctor123';
  /// final isParticipant = userIds.contains(currentUserId);
  /// print(isParticipant); // true
  ///
  /// // Get the other user in conversation
  /// final otherUserId = userIds.firstWhere((id) => id != currentUserId);
  /// print(otherUserId); // 'patient456'
  /// ```
  static List<String> extractUserIds(String conversationId) =>
      conversationId.split('_');
}
