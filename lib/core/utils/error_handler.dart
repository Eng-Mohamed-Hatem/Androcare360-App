/// Standardized error handling utilities for the AndroCare360 application.
///
/// This file provides utility functions for consistent error handling across
/// all repository methods using the `Either<Failure, T>` pattern.
library;

import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:flutter/foundation.dart';
import 'package:elajtech/core/errors/exceptions.dart';
import 'package:elajtech/core/errors/failures.dart';

/// Executes an async operation with standardized error handling.
///
/// This utility function wraps repository operations to provide consistent
/// error handling and logging across the application. It catches common
/// exception types and converts them to appropriate Failure types.
///
/// **Parameters:**
/// - [operation]: The async operation to execute
/// - [operationName]: Name of the operation for logging purposes
///
/// **Returns:**
/// `Either<Failure, T>` where:
/// - Left(Failure): If an error occurred
/// - Right(T): If the operation succeeded
///
/// **Usage Example:**
/// ```dart
/// @override
/// Future<Either<Failure, AppointmentModel>> createAppointment(
///   AppointmentModel appointment,
/// ) async {
///   return executeWithErrorHandling(
///     operation: () async {
///       await firestore
///           .collection('appointments')
///           .doc(appointment.id)
///           .set(appointment.toFirestore());
///       return appointment;
///     },
///     operationName: 'createAppointment',
///   );
/// }
/// ```
///
/// **Error Handling Flow:**
/// 1. FirebaseException → FirestoreFailure
/// 2. SocketException → NetworkFailure
/// 3. AppException (custom) → AppFailure
/// 4. Any other exception → UnexpectedFailure
Future<Either<Failure, T>> executeWithErrorHandling<T>({
  required Future<T> Function() operation,
  required String operationName,
}) async {
  try {
    if (kDebugMode) {
      debugPrint('$operationName - Starting operation');
    }

    final result = await operation();

    if (kDebugMode) {
      debugPrint('$operationName - Operation completed successfully');
    }

    return Right(result);
  } on firebase_core.FirebaseException catch (e) {
    if (kDebugMode) {
      debugPrint('$operationName - Firebase error: ${e.code} - ${e.message}');
    }
    return Left(Failure.firestore(e.message ?? 'Firestore operation failed'));
  } on SocketException catch (e) {
    if (kDebugMode) {
      debugPrint('$operationName - Network error: ${e.message}');
    }
    return const Left(Failure.network('No internet connection'));
  } on FirestoreException catch (e) {
    if (kDebugMode) {
      debugPrint('$operationName - Firestore error: ${e.message}');
    }
    return Left(Failure.firestore(e.message));
  } on NetworkException catch (e) {
    if (kDebugMode) {
      debugPrint('$operationName - Network error: ${e.message}');
    }
    return Left(Failure.network(e.message));
  } on AgoraException catch (e) {
    if (kDebugMode) {
      debugPrint('$operationName - Agora error: ${e.message}');
    }
    return Left(Failure.agora(e.message));
  } on VoIPException catch (e) {
    if (kDebugMode) {
      debugPrint('$operationName - VoIP error: ${e.message}');
    }
    return Left(Failure.voip(e.message));
  } on AppException catch (e) {
    if (kDebugMode) {
      debugPrint('$operationName - App error: ${e.message}');
    }
    return Left(Failure.app(e.message));
  } on Exception catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('$operationName - Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
    }
    return Left(Failure.unexpected(e.toString()));
  }
}

/// Logs an error with context information for debugging.
///
/// This utility function provides consistent error logging across the
/// application. It should be used in service classes where exceptions
/// are thrown rather than returned as Failures.
///
/// **Parameters:**
/// - [operation]: Name of the operation that failed
/// - [error]: The error object
/// - [stackTrace]: Optional stack trace for debugging
/// - [context]: Optional additional context (user ID, document ID, etc.)
///
/// **Usage Example:**
/// ```dart
/// try {
///   await rtcEngine.joinChannel(token: token, channelId: channelId);
/// } catch (e, stackTrace) {
///   logError(
///     operation: 'joinChannel',
///     error: e,
///     stackTrace: stackTrace,
///     context: {'channelId': channelId, 'userId': userId},
///   );
///   throw AgoraException('Failed to join channel', originalError: e);
/// }
/// ```
void logError({
  required String operation,
  required dynamic error,
  StackTrace? stackTrace,
  Map<String, dynamic>? context,
}) {
  if (kDebugMode) {
    debugPrint('=== ERROR ===');
    debugPrint('Operation: $operation');
    debugPrint('Error: $error');
    if (context != null && context.isNotEmpty) {
      debugPrint('Context: $context');
    }
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
    debugPrint('=============');
  }

  // TODO(dev): Send to Firebase Crashlytics in production
  // FirebaseCrashlytics.instance.recordError(error, stackTrace);
}
