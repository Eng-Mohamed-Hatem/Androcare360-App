import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elajtech/core/extensions/color_extensions.dart';

void main() {
  group('ColorExtensions', () {
    test('withAlphaValue should create color with correct alpha value', () {
      // Arrange
      const baseColor = Colors.blue;
      const alphaValue = 0.7;

      // Act
      final result = baseColor.withAlphaValue(alphaValue);

      // Assert
      expect(result.a * 255, closeTo(0.7 * 255, 1.0));
      expect(result.r, baseColor.r);
      expect(result.g, baseColor.g);
      expect(result.b, baseColor.b);
    });

    test('withAlphaValue should handle edge cases', () {
      const baseColor = Colors.red;

      // Test fully transparent
      final transparent = baseColor.withAlphaValue(0);
      expect((transparent.a * 255).round(), 0);

      // Test fully opaque
      final opaque = baseColor.withAlphaValue(1);
      expect((opaque.a * 255).round(), 255);
    });

    test('withAlphaValue should assert on invalid alpha values', () {
      const baseColor = Colors.green;

      // Test negative alpha
      expect(() => baseColor.withAlphaValue(-0.1), throwsAssertionError);

      // Test alpha > 1.0
      expect(() => baseColor.withAlphaValue(1.1), throwsAssertionError);
    });
  });
}
