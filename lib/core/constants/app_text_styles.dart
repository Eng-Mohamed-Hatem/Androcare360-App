import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App Text Styles - أنماط النصوص
class AppTextStyles {
  AppTextStyles._();

  // Base Font Family - الخط الأساسي
  static TextStyle get _baseStyle => GoogleFonts.cairo();

  // Headings - العناوين
  static TextStyle get h1 => _baseStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static TextStyle get h2 => _baseStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static TextStyle get h3 => _baseStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle get h4 => _baseStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle get h5 => _baseStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle get h6 => _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Body Text - النصوص الأساسية
  static TextStyle get bodyLarge => _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static TextStyle get bodyMedium => _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static TextStyle get bodySmall => _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  // Button Text - نصوص الأزرار
  static TextStyle get button => _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static TextStyle get buttonSmall => _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // Caption & Labels - التسميات
  static TextStyle get caption => _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.3,
  );

  static TextStyle get label => _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  // Special Styles - أنماط خاصة
  static TextStyle get subtitle => _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static TextStyle get overline => _baseStyle.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.6,
  );
}
