import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ConnectivityProvider — مزوّد حالة الاتصال بالإنترنت (Riverpod)
///
/// **English**
/// A Riverpod [StreamProvider] that exposes the real-time online status of the
/// device using the `connectivity_plus ^5` package (already a project dependency).
///
/// This provider wraps [Connectivity.onConnectivityChanged] and emits `true`
/// whenever the device has at least one active network interface, `false` when
/// fully offline ([ConnectivityResult.none]).
///
/// Screens that must react to connectivity changes should watch
/// [connectivityProvider]:
///
/// ```dart
/// final isOnline = ref.watch(connectivityProvider).valueOrNull ?? true;
/// ```
///
/// A synchronous snapshot is also available via [currentConnectivityProvider].
/// For use-case / repository code without a Riverpod context, prefer the
/// standalone [checkCurrentConnectivity] helper.
///
/// **Arabic**
/// مزوّد Riverpod يعرض حالة الاتصال بالإنترنت في الوقت الفعلي باستخدام
/// حزمة `connectivity_plus ^5`. يُصدر `true` عند وجود اتصال نشط، و`false`
/// عند الانقطاع الكامل ([ConnectivityResult.none]).
///
/// **Spec reference**: spec.md §7.10 (R7) — ConnectivityProvider requirement.
/// **Plan reference**: plan.md §Technical Context — `connectivity_plus`.

// ─────────────────────────────────────────────────────────────────────────────
// Internal helper
// ─────────────────────────────────────────────────────────────────────────────

/// Maps a [ConnectivityResult] to a boolean online flag.
///
/// Returns `false` only when the result is [ConnectivityResult.none].
/// يعيد `false` فقط عند انعدام الاتصال الكامل.
bool _resultToOnline(ConnectivityResult result) =>
    result != ConnectivityResult.none;

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

/// A [StreamProvider] that emits `true` when the device has at least one
/// active network connection, and `false` when fully offline.
///
/// The stream starts with the current connectivity state obtained via
/// [Connectivity.checkConnectivity].
///
/// **Usage**:
/// ```dart
/// final isOnline = ref.watch(connectivityProvider).valueOrNull ?? true;
/// ```
///
/// مزوّد تيار يُصدر `true` عندما يكون الجهاز متصلاً، و`false` عند الانقطاع.
/// يبدأ بالحالة الحالية للاتصال فور الاشتراك.
final connectivityProvider = StreamProvider<bool>((ref) {
  final connectivity = Connectivity();

  final controller = StreamController<bool>.broadcast();

  // Emit current state immediately so the stream does not linger in loading.
  connectivity
      .checkConnectivity()
      .then((result) {
        if (!controller.isClosed) {
          controller.add(_resultToOnline(result));
        }
      })
      .catchError((Object e) {
        if (kDebugMode) debugPrint('[ConnectivityProvider] Initial check: $e');
        if (!controller.isClosed) controller.add(true); // optimistic fallback
      })
      .ignore();

  // Forward all subsequent connectivity changes.
  final subscription = connectivity.onConnectivityChanged.listen(
    (ConnectivityResult result) {
      if (!controller.isClosed) {
        final online = _resultToOnline(result);
        if (kDebugMode) {
          debugPrint('[ConnectivityProvider] Changed → online=$online');
        }
        controller.add(online);
      }
    },
    onError: (Object e) {
      if (kDebugMode) debugPrint('[ConnectivityProvider] Stream error: $e');
    },
  );

  ref.onDispose(() {
    unawaited(subscription.cancel());
    if (!controller.isClosed) unawaited(controller.close());
  });

  return controller.stream;
});

/// A [Provider] that synchronously returns the **latest** online status from
/// the stream, falling back to `true` (optimistic) before the first emission.
///
/// Useful for one-shot or synchronous checks.
///
/// مزوّد متزامن يُعيد آخر حالة اتصال معروفة من التيار، أو `true` إذا لم يُصدر
/// التيار قيمة بعد.
///
/// **Usage**:
/// ```dart
/// final isOnline = ref.read(currentConnectivityProvider);
/// if (!isOnline) return Left(const NetworkFailure());
/// ```
final currentConnectivityProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).valueOrNull ?? true;
});

/// Standalone async helper for one-off connectivity checks inside use cases or
/// repositories without a Riverpod context.
///
/// Returns `true` on error (optimistic) to avoid blocking the UI unnecessarily.
///
/// دالة مساعدة مستقلة للتحقق من حالة الاتصال مرة واحدة خارج سياق Riverpod.
///
/// **Example**:
/// ```dart
/// if (!await checkCurrentConnectivity()) {
///   return Left(const NetworkFailure());
/// }
/// ```
Future<bool> checkCurrentConnectivity() async {
  try {
    final result = await Connectivity().checkConnectivity();
    return _resultToOnline(result);
  } on Exception catch (e) {
    if (kDebugMode) debugPrint('[ConnectivityProvider] checkCurrent: $e');
    return true; // optimistic fallback
  }
}
