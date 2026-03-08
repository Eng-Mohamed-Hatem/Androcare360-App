import 'package:flutter/material.dart';

/// Extension methods for Color to support both old and new opacity APIs.
///
/// This extension provides backward-compatible methods for migrating from
/// the deprecated `withOpacity()` to the new `withValues(alpha:)` API.
///
/// **Migration Strategy:**
/// 1. Use `withAlphaValue()` extension method during migration
/// 2. Gradually replace with direct `withValues(alpha:)` calls
/// 3. Remove extension after full migration
///
/// **Example:**
/// ```dart
/// // Old (deprecated)
/// final color = Colors.blue.withOpacity(0.7);
///
/// // Transition (using extension)
/// final color = Colors.blue.withAlphaValue(0.7);
///
/// // New (direct API)
/// final color = Colors.blue.withValues(alpha: 0.7);
/// ```
///
/// **Note:** The method is named `withAlphaValue()` instead of `withAlpha()`
/// to avoid conflicts with Flutter's built-in `Color.withAlpha(int)` method.
extension ColorExtensions on Color {
  /// Creates a copy of this color with the specified alpha value.
  ///
  /// This is a backward-compatible wrapper around `withValues(alpha:)`.
  ///
  /// Parameters:
  /// - [alphaValue]: Alpha value between 0.0 (transparent) and 1.0 (opaque)
  ///
  /// Returns a new Color with the specified alpha value.
  ///
  /// Note: This method uses the same parameter type as the deprecated
  /// `withOpacity()` method (double 0.0-1.0) for easy migration.
  Color withAlphaValue(double alphaValue) {
    assert(
      alphaValue >= 0.0 && alphaValue <= 1.0,
      'Alpha must be between 0.0 and 1.0',
    );
    return withValues(alpha: alphaValue);
  }
}
