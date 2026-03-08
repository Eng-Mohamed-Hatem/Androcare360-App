import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/emr/domain/repositories/nutrition_emr_repository.dart';
import 'package:elajtech/shared/models/nutrition_emr_model.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementation of Nutrition EMR Repository using Firestore
///
/// This repository handles all Firestore operations for Nutrition EMR records.
/// It uses typed exception handling for consistent error management across all operations.
///
/// **Database Configuration:**
/// - Collection: 'nutrition_emrs'
/// - Database ID: 'elajtech' (injected via GetIt)
///
/// **Error Handling:**
/// All methods use typed exception catching:
/// - firebase_core.FirebaseException for Firestore errors
/// - Exception for unexpected errors
/// - Automatic conversion to Failure types
/// - Debug logging with operation context
@LazySingleton(as: NutritionEMRRepository)
class NutritionEMRRepositoryImpl implements NutritionEMRRepository {
  NutritionEMRRepositoryImpl(this._firestore);
  final FirebaseFirestore _firestore;

  static const String collectionName = 'nutrition_emrs';

  @override
  Future<Either<Failure, void>> saveEMR(NutritionEMRModel emr) async {
    try {
      if (kDebugMode) {
        debugPrint('[NutritionEMRRepo] Operation: saveEMR | Status: started');
        debugPrint('[NutritionEMRRepo] DatabaseId: ${_firestore.databaseId}');
        debugPrint(
          '[NutritionEMRRepo] EMR ID: ${emr.id} | Appointment ID: ${emr.appointmentId}',
        );
        debugPrint('[NutritionEMRRepo] Patient ID: ${emr.patientId}');
      }

      if (emr.appointmentId.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '[NutritionEMRRepo] Operation: saveEMR | Status: failed | Reason: Empty appointment ID',
          );
        }
        return const Left(
          Failure.firestore('appointmentId is required to save Nutrition EMR'),
        );
      }

      await _firestore.collection(collectionName).doc(emr.id).set(emr.toJson());

      if (kDebugMode) {
        debugPrint('[NutritionEMRRepo] Operation: saveEMR | Status: success');
      }

      return const Right(null);
    } on firebase_core.FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint('[NutritionEMRRepo] Operation: saveEMR | Status: error');
        debugPrint(
          '[NutritionEMRRepo] FirebaseException: ${e.code} - ${e.message}',
        );
      }
      return Left(
        Failure.firestore('Firebase error: ${e.code} - ${e.message}'),
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[NutritionEMRRepo] Operation: saveEMR | Status: error');
        debugPrint('[NutritionEMRRepo] Exception: $e');
        debugPrint('[NutritionEMRRepo] StackTrace: $stackTrace');
      }
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, NutritionEMRModel?>> getEMRByAppointmentId(
    String appointmentId,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[NutritionEMRRepo] Operation: getEMRByAppointmentId | Status: started',
        );
        debugPrint('[NutritionEMRRepo] DatabaseId: ${_firestore.databaseId}');
        debugPrint('[NutritionEMRRepo] Appointment ID: $appointmentId');
      }

      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('appointmentId', isEqualTo: appointmentId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '[NutritionEMRRepo] Operation: getEMRByAppointmentId | Status: success | Result: null (not found)',
          );
        }
        return const Right(null);
      }

      final emr = NutritionEMRModel.fromJson(
        querySnapshot.docs.first.data(),
      );

      if (kDebugMode) {
        debugPrint(
          '[NutritionEMRRepo] Operation: getEMRByAppointmentId | Status: success',
        );
        debugPrint(
          '[NutritionEMRRepo] EMR ID: ${emr.id} | Patient ID: ${emr.patientId}',
        );
      }

      return Right(emr);
    } on firebase_core.FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[NutritionEMRRepo] Operation: getEMRByAppointmentId | Status: error',
        );
        debugPrint(
          '[NutritionEMRRepo] FirebaseException: ${e.code} - ${e.message}',
        );
      }
      return Left(
        Failure.firestore('Firebase error: ${e.code} - ${e.message}'),
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[NutritionEMRRepo] Operation: getEMRByAppointmentId | Status: error',
        );
        debugPrint('[NutritionEMRRepo] Exception: $e');
        debugPrint('[NutritionEMRRepo] StackTrace: $stackTrace');
      }
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<NutritionEMRModel>>> getEMRByPatientId(
    String patientId,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[NutritionEMRRepo] Operation: getEMRByPatientId | Status: started',
        );
        debugPrint('[NutritionEMRRepo] DatabaseId: ${_firestore.databaseId}');
        debugPrint('[NutritionEMRRepo] Patient ID: $patientId');
      }

      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('patientId', isEqualTo: patientId)
          .orderBy('createdAt', descending: true)
          .get();

      final emrs = querySnapshot.docs
          .map((doc) => NutritionEMRModel.fromJson(doc.data()))
          .toList();

      if (kDebugMode) {
        debugPrint(
          '[NutritionEMRRepo] Operation: getEMRByPatientId | Status: success',
        );
        debugPrint('[NutritionEMRRepo] Found ${emrs.length} EMR records');
      }

      return Right(emrs);
    } on firebase_core.FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[NutritionEMRRepo] Operation: getEMRByPatientId | Status: error',
        );
        debugPrint(
          '[NutritionEMRRepo] FirebaseException: ${e.code} - ${e.message}',
        );
      }
      return Left(
        Failure.firestore('Firebase error: ${e.code} - ${e.message}'),
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[NutritionEMRRepo] Operation: getEMRByPatientId | Status: error',
        );
        debugPrint('[NutritionEMRRepo] Exception: $e');
        debugPrint('[NutritionEMRRepo] StackTrace: $stackTrace');
      }
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }
}
