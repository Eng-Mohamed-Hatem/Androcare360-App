/// Validators - التحقق من صحة البيانات
class Validators {
  Validators._();

  /// Email Validator - التحقق من البريد الإلكتروني
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }

    return null;
  }

  /// Password Validator - التحقق من كلمة المرور
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }

    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }

    return null;
  }

  /// Required Field Validator - التحقق من الحقل المطلوب
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'هذا الحقل'} مطلوب';
    }
    return null;
  }

  /// Phone Number Validator - التحقق من رقم الموبايل
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الموبايل مطلوب';
    }

    // E.164 phone number format (+ followed by 8-15 digits)
    final phoneRegex = RegExp(r'^\+\d{8,15}$');

    if (!phoneRegex.hasMatch(value)) {
      return 'برجاء إدخال رقم الموبايل بصيغة دولية صحيحة، مثل +9665XXXXXXXX';
    }

    return null;
  }

  /// Confirm Password Validator - التحقق من تطابق كلمة المرور
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }

    if (value != password) {
      return 'كلمات المرور غير متطابقة';
    }

    return null;
  }

  /// Username Validator - التحقق من اسم المستخدم
  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return 'اسم المستخدم مطلوب';
    }

    if (value.length < 3) {
      return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
    }

    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');

    if (!usernameRegex.hasMatch(value)) {
      return 'اسم المستخدم يجب أن يحتوي على أحرف وأرقام فقط';
    }

    return null;
  }
}
