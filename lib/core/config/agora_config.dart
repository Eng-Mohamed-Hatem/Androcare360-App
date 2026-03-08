/// Agora Configuration - إعدادات Agora الأمنية
///
/// يحتوي على App ID فقط (آمن للعرض في التطبيق)
///
/// ⚠️ App Certificate يجب أن يكون فقط في Cloud Functions
/// لا تضع Certificate هنا أبداً!
class AgoraConfig {
  /// Agora App ID (آمن - يمكن عرضه في التطبيق)
  static const String appId = 'f9ff6f5ab52c43d0ab7ba76fcee25dbf';

  /// Token Expiry Time (1 hour)
  static const int tokenExpirySeconds = 3600;

  /// Channel Name Prefix
  static const String channelPrefix = 'appointment_';
}
