/// Phone number validator for E.164 format
library;

/// Validates international phone numbers in E.164 format.
///
/// **Arabic**: مدقق صيغات الأرقام الدولية
/// **English**: International phone number format validator
///
/// Validates that phone numbers comply with E.164 international format.
/// E.164 format: `+[country_code][number]` where:
/// - Country code: 1-3 digits (e.g., +20 for Egypt, +966 for Saudi Arabia)
/// - Number: maximum 14 digits (total 15 digits including country code)
///
/// **Usage Example:**
/// ```dart
/// // Check if a phone number is valid
/// final isValid = PhoneValidator.isValid('+201234567890'); // true
///
/// // Validate user input and get error message
/// final result = PhoneValidator.validate('1234567890');
/// if (result != null) {
///   // Show error message to user
///   print(result);
/// }
/// ```
class PhoneValidator {
  /// E.164 regex pattern for international phone number validation.
  ///
  /// Matches: `+[country_code][number]`
  /// - Country code: 1-3 digits
  /// - Number: 1-14 digits
  /// - Total: maximum 15 digits including `+` sign
  static const pattern = r'^\+[1-9]\d{1,14}$';

  /// Validates if a phone number matches E.164 format.
  ///
  /// Returns `true` if the phone number matches the E.164 pattern,
  /// otherwise `false`.
  ///
  /// **Parameters:**
  /// - [phone]: Phone number string to validate
  ///
  /// **Returns:** `bool` - true if valid, false if invalid
  ///
  /// **Example:**
  /// ```dart
  /// PhoneValidator.isValid('+201234567890'); // true
  /// PhoneValidator.isValid('201234567890');  // false (missing +)
  /// PhoneValidator.isValid('+201234567890123456');  // false (too long)
  /// ```
  static bool isValid(String phone) {
    return RegExp(pattern).hasMatch(phone);
  }

  /// Validates a phone number and returns an error message if invalid.
  ///
  /// Returns `null` if the phone number is valid, otherwise returns
  /// an error message describing the issue.
  ///
  /// **Parameters:**
  /// - [phone]: Phone number string to validate (nullable)
  ///
  /// **Returns:** `String?` - Error message if invalid, `null` if valid
  ///
  /// **Example:**
  /// ```dart
  /// PhoneValidator.validate(null); // "Phone number is required"
  /// PhoneValidator.validate(''); // "Phone number is required"
  /// PhoneValidator.validate('1234567890'); // "Please enter a valid international phone number (e.g., +201234567890)"
  /// PhoneValidator.validate('+201234567890'); // null (valid)
  /// ```
  static String? validate(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Phone number is required';
    }

    if (!isValid(phone)) {
      return 'Please enter a valid international phone number (e.g., +201234567890)';
    }

    return null; // Valid
  }
}
