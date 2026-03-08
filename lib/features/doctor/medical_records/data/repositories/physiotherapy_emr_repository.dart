import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/doctor/medical_records/data/models/physiotherapy_emr_model.dart';
import 'package:elajtech/features/doctor/medical_records/domain/entities/physiotherapy_emr.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:injectable/injectable.dart';

/// Physical Therapy EMR Repository
///
/// Handles all Firestore operations for physiotherapy EMR records
/// Uses custom database ID 'elajtech' as per project requirements
@lazySingleton
class PhysiotherapyEMRRepository {
  PhysiotherapyEMRRepository()
    : _firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'elajtech',
      ) {
    // Firestore is initialized via initializer list
  }

  final FirebaseFirestore _firestore;
  static const String _collectionName = 'physiotherapy_emrs';

  /// Create a new Physical Therapy EMR record
  ///
  /// Returns [Right(void)] on success or [Left(Failure)] on error
  Future<Either<Failure, void>> createPhysiotherapyEMR(
    PhysiotherapyEMR emr,
  ) async {
    try {
      // Validate appointmentId
      if (emr.appointmentId.isEmpty) {
        return const Left(
          ServerFailure('Appointment ID is required'),
        );
      }

      // Convert entity to Firestore document
      final data = PhysiotherapyEMRModel.toFirestore(emr);

      // Save to Firestore
      await _firestore.collection(_collectionName).doc(emr.id).set(data);

      return const Right(null);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return const Left(
          ServerFailure(
            'Permission denied. You may not have access to create this EMR or the 24-hour window has expired.',
          ),
        );
      }
      return Left(ServerFailure('Firebase error: ${e.message}'));
    } on SocketException {
      return const Left(ServerFailure('No internet connection'));
    } on Exception catch (e) {
      return Left(ServerFailure('Failed to create physiotherapy EMR: $e'));
    }
  }

  /// Update an existing Physical Therapy EMR record
  ///
  /// Returns [Right(void)] on success or [Left(Failure)] on error
  Future<Either<Failure, void>> updatePhysiotherapyEMR(
    PhysiotherapyEMR emr,
  ) async {
    try {
      // Convert entity to Firestore document
      final data = PhysiotherapyEMRModel.toFirestore(emr);

      // Update in Firestore
      await _firestore.collection(_collectionName).doc(emr.id).update(data);

      return const Right(null);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return const Left(
          ServerFailure(
            'Permission denied. The 24-hour window for editing may have expired.',
          ),
        );
      }
      return Left(ServerFailure('Firebase error: ${e.message}'));
    } on SocketException {
      return const Left(ServerFailure('No internet connection'));
    } on Exception catch (e) {
      return Left(ServerFailure('Failed to update physiotherapy EMR: $e'));
    }
  }

  /// Get Physical Therapy EMR by visit/appointment ID
  ///
  /// Returns [Right(PhysiotherapyEMR?)] on success or [Left(Failure)] on error
  Future<Either<Failure, PhysiotherapyEMR?>> getPhysiotherapyEMRByVisit(
    String appointmentId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('appointmentId', isEqualTo: appointmentId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return const Right(null);
      }

      final emr = PhysiotherapyEMRModel.fromFirestore(
        querySnapshot.docs.first,
      );

      return Right(emr);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Firebase error: ${e.message}'));
    } on SocketException {
      return const Left(ServerFailure('No internet connection'));
    } on Exception catch (e) {
      return Left(
        ServerFailure('Failed to get physiotherapy EMR by visit: $e'),
      );
    }
  }

  /// Get all Physical Therapy EMR records for a patient
  ///
  /// Returns [Right(List<PhysiotherapyEMR>)] on success or [Left(Failure)] on error
  Future<Either<Failure, List<PhysiotherapyEMR>>>
  getPatientPhysiotherapyHistory(
    String patientId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('patientId', isEqualTo: patientId)
          .orderBy('visitDate', descending: true)
          .get();

      final emrs = querySnapshot.docs
          .map(PhysiotherapyEMRModel.fromFirestore)
          .toList();

      return Right(emrs);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Firebase error: ${e.message}'));
    } on SocketException {
      return const Left(ServerFailure('No internet connection'));
    } on Exception catch (e) {
      return Left(
        ServerFailure('Failed to get patient physiotherapy history: $e'),
      );
    }
  }

  /// Get all Physical Therapy EMR records created by a specific doctor
  ///
  /// Returns [Right(List<PhysiotherapyEMR>)] on success or [Left(Failure)] on error
  Future<Either<Failure, List<PhysiotherapyEMR>>> getDoctorPhysiotherapyEMRs(
    String doctorId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('visitDate', descending: true)
          .get();

      final emrs = querySnapshot.docs
          .map(PhysiotherapyEMRModel.fromFirestore)
          .toList();

      return Right(emrs);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Firebase error: ${e.message}'));
    } on SocketException {
      return const Left(ServerFailure('No internet connection'));
    } on Exception catch (e) {
      return Left(
        ServerFailure('Failed to get doctor physiotherapy EMRs: $e'),
      );
    }
  }
}
