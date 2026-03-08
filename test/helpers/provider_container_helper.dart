/// Riverpod ProviderContainer helper utilities for testing
///
/// Provides utilities for setting up and managing ProviderContainer
/// instances during tests. This enables testing of Riverpod providers
/// with proper dependency injection and state management.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Riverpod testing utilities
class ProviderContainerHelper {
  /// Creates a ProviderContainer for testing
  ///
  /// Parameters:
  /// - [overrides]: List of provider overrides for mocking dependencies
  /// - [observers]: List of provider observers for monitoring state changes
  ///
  /// Returns a configured ProviderContainer
  ///
  /// Example:
  /// ```dart
  /// final container = ProviderContainerHelper.createContainer(
  ///   overrides: [
  ///     authRepositoryProvider.overrideWithValue(mockAuthRepository),
  ///   ],
  /// );
  /// ```
  static ProviderContainer createContainer({
    List<Override> overrides = const [],
    List<ProviderObserver> observers = const [],
  }) {
    return ProviderContainer(
      overrides: overrides,
      observers: observers,
    );
  }

  /// Creates a ProviderScope widget for testing
  ///
  /// This wraps a widget with ProviderScope for widget tests
  ///
  /// Parameters:
  /// - [child]: Widget to wrap
  /// - [overrides]: List of provider overrides
  /// - [observers]: List of provider observers
  ///
  /// Returns a ProviderScope widget
  ///
  /// Example:
  /// ```dart
  /// await tester.pumpWidget(
  ///   ProviderContainerHelper.createProviderScope(
  ///     child: MyWidget(),
  ///     overrides: [
  ///       authRepositoryProvider.overrideWithValue(mockAuthRepository),
  ///     ],
  ///   ),
  /// );
  /// ```
  static ProviderScope createProviderScope({
    required Widget child,
    List<Override> overrides = const [],
    List<ProviderObserver> observers = const [],
  }) {
    return ProviderScope(
      overrides: overrides,
      observers: observers,
      child: child,
    );
  }

  /// Reads a provider value from a container
  ///
  /// Example:
  /// ```dart
  /// final authState = ProviderContainerHelper.read(
  ///   container,
  ///   authProvider,
  /// );
  /// ```
  static T read<T>(
    ProviderContainer container,
    ProviderListenable<T> provider,
  ) {
    return container.read(provider);
  }

  /// Listens to a provider and returns the value
  ///
  /// This is useful for testing provider state changes
  ///
  /// Example:
  /// ```dart
  /// final authState = ProviderContainerHelper.listen(
  ///   container,
  ///   authProvider,
  /// );
  /// ```
  static T listen<T>(
    ProviderContainer container,
    ProviderListenable<T> provider,
  ) {
    return container
        .listen<T>(
          provider,
          (previous, next) {},
        )
        .read();
  }

  /// Disposes a ProviderContainer
  ///
  /// This should be called in tearDown to clean up resources
  ///
  /// Example:
  /// ```dart
  /// tearDown(() {
  ///   ProviderContainerHelper.dispose(container);
  /// });
  /// ```
  static void dispose(ProviderContainer container) {
    container.dispose();
  }

  /// Creates a test observer for monitoring provider changes
  ///
  /// This is useful for verifying that providers are being updated correctly
  ///
  /// Example:
  /// ```dart
  /// final observer = ProviderContainerHelper.createTestObserver();
  /// final container = ProviderContainerHelper.createContainer(
  ///   observers: [observer],
  /// );
  /// ```
  static TestProviderObserver createTestObserver() {
    return TestProviderObserver();
  }

  /// Waits for a provider to emit a specific value
  ///
  /// Parameters:
  /// - [container]: ProviderContainer instance
  /// - [provider]: Provider to watch
  /// - [matcher]: Matcher to verify the value
  /// - [timeout]: Maximum wait time
  ///
  /// Returns true if value matches within timeout
  static Future<bool> waitForProviderValue<T>(
    ProviderContainer container,
    ProviderListenable<T> provider,
    Matcher matcher, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final endTime = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(endTime)) {
      final value = container.read(provider);
      if (matcher.matches(value, {})) {
        return true;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    return false;
  }

  /// Pumps a widget with ProviderScope for widget testing
  ///
  /// This is a convenience method that combines pumpWidget with ProviderScope
  ///
  /// Example:
  /// ```dart
  /// await ProviderContainerHelper.pumpWidgetWithProviders(
  ///   tester,
  ///   MyWidget(),
  ///   overrides: [
  ///     authRepositoryProvider.overrideWithValue(mockAuthRepository),
  ///   ],
  /// );
  /// ```
  static Future<void> pumpWidgetWithProviders(
    WidgetTester tester,
    Widget widget, {
    List<Override> overrides = const [],
    List<ProviderObserver> observers = const [],
  }) async {
    await tester.pumpWidget(
      createProviderScope(
        child: widget,
        overrides: overrides,
        observers: observers,
      ),
    );
  }
}

/// Test observer for monitoring provider changes
///
/// This observer tracks all provider lifecycle events for testing purposes
class TestProviderObserver extends ProviderObserver {
  /// List of provider updates
  final List<ProviderUpdate> updates = [];

  /// List of provider additions
  final List<ProviderAddition> additions = [];

  /// List of provider disposals
  final List<ProviderDisposal> disposals = [];

  /// List of provider errors
  final List<ProviderError> errors = [];

  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    additions.add(ProviderAddition(provider, value));
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    updates.add(ProviderUpdate(provider, previousValue, newValue));
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    disposals.add(ProviderDisposal(provider));
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    errors.add(ProviderError(provider, error, stackTrace));
  }

  /// Clears all recorded events
  void clear() {
    updates.clear();
    additions.clear();
    disposals.clear();
    errors.clear();
  }

  /// Checks if a provider was updated
  bool wasProviderUpdated(ProviderBase<Object?> provider) {
    return updates.any((update) => update.provider == provider);
  }

  /// Checks if a provider was added
  bool wasProviderAdded(ProviderBase<Object?> provider) {
    return additions.any((addition) => addition.provider == provider);
  }

  /// Checks if a provider was disposed
  bool wasProviderDisposed(ProviderBase<Object?> provider) {
    return disposals.any((disposal) => disposal.provider == provider);
  }

  /// Checks if a provider had an error
  bool didProviderFail(ProviderBase<Object?> provider) {
    return errors.any((error) => error.provider == provider);
  }

  /// Gets the number of updates for a provider
  int getUpdateCount(ProviderBase<Object?> provider) {
    return updates.where((update) => update.provider == provider).length;
  }
}

/// Represents a provider update event
class ProviderUpdate {
  const ProviderUpdate(this.provider, this.previousValue, this.newValue);

  final ProviderBase<Object?> provider;
  final Object? previousValue;
  final Object? newValue;
}

/// Represents a provider addition event
class ProviderAddition {
  const ProviderAddition(this.provider, this.value);

  final ProviderBase<Object?> provider;
  final Object? value;
}

/// Represents a provider disposal event
class ProviderDisposal {
  const ProviderDisposal(this.provider);

  final ProviderBase<Object?> provider;
}

/// Represents a provider error event
class ProviderError {
  const ProviderError(this.provider, this.error, this.stackTrace);

  final ProviderBase<Object?> provider;
  final Object error;
  final StackTrace stackTrace;
}

/// Extension methods for WidgetTester with Riverpod support
extension WidgetTesterRiverpodExtensions on WidgetTester {
  /// Pumps a widget with ProviderScope
  Future<void> pumpWithProviders(
    Widget widget, {
    List<Override> overrides = const [],
    List<ProviderObserver> observers = const [],
  }) async {
    await ProviderContainerHelper.pumpWidgetWithProviders(
      this,
      widget,
      overrides: overrides,
      observers: observers,
    );
  }
}
