/// Custom exception types for the AndroCare360 application.
///
/// This file defines a hierarchy of domain-specific exceptions to replace
/// generic catch clauses throughout the application. Each exception type
/// corresponds to a specific failure domain (Firestore, Network, Agora, VoIP).
library;

/// Base exception for all application errors.
///
/// All custom exceptions in the application should extend this base class.
/// It provides a consistent structure for error messages, error codes, and
/// original error tracking.
abstract class AppException implements Exception {
  const AppException(
    this.message, {
    this.code,
    this.originalError,
  });

  /// Human-readable error message
  final String message;

  /// Optional error code for categorization
  final String? code;

  /// Original error that caused this exception (for debugging)
  final dynamic originalError;

  @override
  String toString() {
    if (code != null) {
      return 'AppException [$code]: $message';
    }
    return 'AppException: $message';
  }
}

/// Thrown when Firestore operations fail.
///
/// This exception should be used for all Firebase Firestore-related errors
/// including document reads, writes, queries, and permission issues.
///
/// **Usage Example:**
/// ```dart
/// try {
///   await firestore.collection('users').doc(userId).get();
/// } on firebase_core.FirebaseException catch (e) {
///   throw FirestoreException(
///     'Failed to fetch user data',
///     code: e.code,
///     originalError: e,
///   );
/// }
/// ```
class FirestoreException extends AppException {
  const FirestoreException(
    super.message, {
    super.code,
    super.originalError,
  });

  @override
  String toString() {
    if (code != null) {
      return 'FirestoreException [$code]: $message';
    }
    return 'FirestoreException: $message';
  }
}

/// Thrown when network connectivity issues occur.
///
/// This exception should be used for all network-related errors including
/// connection timeouts, DNS failures, and socket exceptions.
///
/// **Usage Example:**
/// ```dart
/// try {
///   await http.get(url);
/// } on SocketException catch (e) {
///   throw NetworkException(
///     'No internet connection',
///     originalError: e,
///   );
/// }
/// ```
class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.originalError,
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown when Agora video call operations fail.
///
/// This exception should be used for all Agora RTC Engine-related errors
/// including initialization failures, channel join/leave errors, and
/// video/audio device issues.
///
/// **Usage Example:**
/// ```dart
/// try {
///   await rtcEngine.joinChannel(token: token, channelId: channelId);
/// } catch (e) {
///   throw AgoraException(
///     'Failed to join video call channel',
///     code: 'JOIN_CHANNEL_FAILED',
///     originalError: e,
///   );
/// }
/// ```
class AgoraException extends AppException {
  const AgoraException(
    super.message, {
    super.code,
    super.originalError,
  });

  @override
  String toString() {
    if (code != null) {
      return 'AgoraException [$code]: $message';
    }
    return 'AgoraException: $message';
  }
}

/// Thrown when VoIP call operations fail.
///
/// This exception should be used for all flutter_callkit_incoming-related
/// errors including incoming call handling, call acceptance/decline, and
/// CallKit/ConnectionService integration issues.
///
/// **Usage Example:**
/// ```dart
/// try {
///   await FlutterCallkitIncoming.showCallkitIncoming(params);
/// } catch (e) {
///   throw VoIPException(
///     'Failed to display incoming call notification',
///     originalError: e,
///   );
/// }
/// ```
class VoIPException extends AppException {
  const VoIPException(
    super.message, {
    super.originalError,
  });

  @override
  String toString() => 'VoIPException: $message';
}
