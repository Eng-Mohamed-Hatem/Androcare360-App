import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/patient/home/data/models/medical_screening_model.dart';
import 'package:elajtech/features/patient/home/domain/repositories/medical_screening_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: MedicalScreeningRepository)
class MedicalScreeningRepositoryImpl implements MedicalScreeningRepository {
  MedicalScreeningRepositoryImpl()
    : _firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'elajtech',
      );
  final FirebaseFirestore _firestore;

  @override
  Future<Either<Failure, MedicalScreeningModel?>> getMedicalScreening(
    String patientId,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint(
          'Action: Fetch Medical Screening | Patient ID: $patientId | Path: users/$patientId/medicalScreening/data',
        );
      }

      final doc = await _firestore
          .collection('users')
          .doc(patientId)
          .collection('medicalScreening')
          .doc('data')
          .get();

      if (doc.exists && doc.data() != null) {
        return Right(MedicalScreeningModel.fromJson(doc.data()!));
      } else {
        if (kDebugMode) {
          debugPrint('Medical Screening document not found for $patientId');
        }
        return const Right(null);
      }
    } on FirebaseException catch (e, stackTrace) {
      debugPrint(
        'FirebaseError in getMedicalScreening [${e.code}]: ${e.message}\nPath: users/$patientId/medicalScreening/data\n$stackTrace',
      );
      return Left(
        ServerFailure(e.message ?? 'Unknown Firebase Error'),
      );
    } catch (e, stackTrace) {
      debugPrint('General Error in getMedicalScreening: $e\n$stackTrace');
      return const Left(
        ServerFailure('Failed to fetch medical screening data'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> saveMedicalScreening(
    String patientId,
    MedicalScreeningModel data,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint(
          'Action: Save/Update Medical Screening | Patient ID: $patientId | Path: users/$patientId/medicalScreening/data',
        );
      }

      await _firestore
          .collection('users')
          .doc(patientId)
          .collection('medicalScreening')
          .doc('data')
          .set(data.toJson());

      if (kDebugMode) {
        debugPrint('Successfully saved medical screening for $patientId');
      }

      return const Right(unit);
    } on FirebaseException catch (e, stackTrace) {
      debugPrint(
        'FirebaseError in saveMedicalScreening [${e.code}]: ${e.message}\nPath: users/$patientId/medicalScreening/data\n$stackTrace',
      );
      return Left(
        ServerFailure(e.message ?? 'Unknown Firebase Error'),
      );
    } catch (e, stackTrace) {
      debugPrint('General Error in saveMedicalScreening: $e\n$stackTrace');
      return const Left(
        ServerFailure('Failed to save medical screening data'),
      );
    }
  }
}
