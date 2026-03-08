/// Common test utilities and helper functions
///
/// Provides reusable utilities for test setup, teardown, and common operations
/// across unit, widget, and integration tests.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Common test helper utilities
class TestHelpers {
  /// Pumps a widget with MaterialApp wrapper for testing
  ///
  /// This is useful for widget tests that need Material context
  ///
  /// Example:
  /// ```dart
  /// await TestHelpers.pumpWidgetWithMaterial(
  ///   tester,
  ///   MyWidget(),
  /// );
  /// ```
  static Future<void> pumpWidgetWithMaterial(
    WidgetTester tester,
    Widget widget, {
    ThemeData? theme,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: widget,
        ),
      ),
    );
  }

  /// Pumps and settles with a timeout
  ///
  /// Useful for animations and async operations
  static Future<void> pumpAndSettleWithTimeout(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await tester.pumpAndSettle(timeout);
  }

  /// Enters text into a TextField by key
  ///
  /// Example:
  /// ```dart
  /// await TestHelpers.enterTextByKey(
  ///   tester,
  ///   'email_field',
  ///   'test@example.com',
  /// );
  /// ```
  static Future<void> enterTextByKey(
    WidgetTester tester,
    String key,
    String text,
  ) async {
    await tester.enterText(find.byKey(Key(key)), text);
    await tester.pump();
  }

  /// Taps a widget by key
  ///
  /// Example:
  /// ```dart
  /// await TestHelpers.tapByKey(tester, 'submit_button');
  /// ```
  static Future<void> tapByKey(
    WidgetTester tester,
    String key,
  ) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  /// Taps a widget by text
  static Future<void> tapByText(
    WidgetTester tester,
    String text,
  ) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  /// Scrolls until a widget is visible
  ///
  /// Useful for testing long lists or scrollable content
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder finder,
    Finder scrollable, {
    double delta = 100.0,
  }) async {
    await tester.scrollUntilVisible(
      finder,
      delta,
      scrollable: scrollable,
    );
  }

  /// Waits for a specific duration
  ///
  /// Use sparingly - prefer pumpAndSettle when possible
  static Future<void> wait(Duration duration) async {
    await Future<void>.delayed(duration);
  }

  /// Verifies a widget exists by key
  static void expectWidgetByKey(String key, {int count = 1}) {
    expect(find.byKey(Key(key)), findsNWidgets(count));
  }

  /// Verifies a widget exists by text
  static void expectWidgetByText(String text, {int count = 1}) {
    expect(find.text(text), findsNWidgets(count));
  }

  /// Verifies a widget exists by type
  static void expectWidgetByType<T extends Widget>({int count = 1}) {
    expect(find.byType(T), findsNWidgets(count));
  }

  /// Verifies a widget does not exist
  static void expectWidgetNotFound(Finder finder) {
    expect(finder, findsNothing);
  }

  /// Creates a mock DateTime for consistent testing
  ///
  /// Returns a fixed date: 2024-01-15 10:00:00
  static DateTime mockDateTime() {
    return DateTime(2024, 1, 15, 10);
  }

  /// Creates a future DateTime for testing (7 days from mock date)
  static DateTime mockFutureDateTime() {
    return mockDateTime().add(const Duration(days: 7));
  }

  /// Creates a past DateTime for testing (7 days before mock date)
  static DateTime mockPastDateTime() {
    return mockDateTime().subtract(const Duration(days: 7));
  }

  /// Formats a DateTime to ISO8601 string for testing
  static String formatDateTimeForTest(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  /// Prints debug information during tests
  ///
  /// Only prints in debug mode
  static void debugPrint(String message) {
    if (kDebugMode) {
      print('[TEST] $message');
    }
  }

  /// Creates a test delay for simulating async operations
  ///
  /// Use in tests to simulate network delays or processing time
  static Future<void> simulateDelay({
    Duration duration = const Duration(milliseconds: 100),
  }) async {
    await Future<void>.delayed(duration);
  }

  /// Verifies that a callback was called
  ///
  /// Example:
  /// ```dart
  /// bool called = false;
  /// final callback = () => called = true;
  /// // ... trigger callback
  /// TestHelpers.expectCallbackCalled(called);
  /// ```
  static void expectCallbackCalled(bool called) {
    expect(called, isTrue, reason: 'Callback should have been called');
  }

  /// Verifies that a callback was not called
  static void expectCallbackNotCalled(bool called) {
    expect(called, isFalse, reason: 'Callback should not have been called');
  }

  /// Creates a test error message
  static String createErrorMessage(String operation, String reason) {
    return '$operation failed: $reason';
  }

  /// Verifies error message format
  static void expectErrorMessage(String actual, String expectedOperation) {
    expect(
      actual,
      contains(expectedOperation),
      reason: 'Error message should contain operation name',
    );
  }
}

/// Extension methods for WidgetTester
extension WidgetTesterExtensions on WidgetTester {
  /// Pumps widget with Material wrapper
  Future<void> pumpMaterialWidget(Widget widget) async {
    await TestHelpers.pumpWidgetWithMaterial(this, widget);
  }

  /// Enters text by key
  Future<void> enterTextByKey(String key, String text) async {
    await TestHelpers.enterTextByKey(this, key, text);
  }

  /// Taps by key
  Future<void> tapByKey(String key) async {
    await TestHelpers.tapByKey(this, key);
  }

  /// Taps by text
  Future<void> tapByText(String text) async {
    await TestHelpers.tapByText(this, text);
  }
}
