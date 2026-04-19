import 'package:flutter/material.dart';

/// App Colors - Medical Theme
/// ألوان التطبيق - تصميم طبي مريح
class AppColors {
  AppColors._();

  // Primary Colors - الألوان الأساسية
  static const Color primary = Color(0xFF4A90E2); // أزرق فاتح
  static const Color primaryDark = Color(0xFF2E5C8A);
  static const Color primaryLight = Color(0xFF7AB8F5);

  // Secondary Colors - الألوان الثانوية
  static const Color secondary = Color(0xFF4CAF50); // أخضر
  static const Color secondaryDark = Color(0xFF388E3C);
  static const Color secondaryLight = Color(0xFF81C784);

  // Background Colors - Light Mode
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF5F7FA);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Background Colors - Dark Mode
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF2C2C2C);

  // Text Colors - Light Mode
  static const Color textPrimaryLight = Color(0xFF333333);
  static const Color textSecondaryLight = Color(0xFF666666);
  static const Color textHintLight = Color(0xFF999999);

  // Text Colors - Dark Mode
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textHintDark = Color(0xFF808080);

  // Status Colors - ألوان الحالة
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Medical Department Colors - ألوان الأقسام الطبية
  static const Color department1 = Color(0xFFE3F2FD); // أزرق فاتح جداً
  static const Color department2 = Color(0xFFF3E5F5); // بنفسجي فاتح
  static const Color department3 = Color(0xFFE8F5E9); // أخضر فاتح
  static const Color department4 = Color(0xFFFFF3E0); // برتقالي فاتح
  static const Color department5 = Color(0xFFFCE4EC); // وردي فاتح

  // Feature Colors
  static const Color sexualHealth = Color(0xFF0F766E);
  static const Color sexualHealthLight = Color(0xFFD7F3EE);

  // Gradient Colors - الألوان المتدرجة
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF404040);

  // Divider Colors
  static const Color dividerLight = Color(0xFFEEEEEE);
  static const Color dividerDark = Color(0xFF303030);

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);
}
