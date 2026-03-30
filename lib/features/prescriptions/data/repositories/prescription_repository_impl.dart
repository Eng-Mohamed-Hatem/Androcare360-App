import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/constants/app_constants.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/core/models/paginated_result.dart';
import 'package:elajtech/features/prescriptions/domain/repositories/prescription_repository.dart';
import 'package:elajtech/shared/models/prescription_model.dart';
import 'package:injectable/injectable.dart';

/// Prescription Repository implementation for the AndroCare360 system.
///
/// This repository implements the [PrescriptionRepository] interface and handles
/// all Firestore operations for medical prescriptions management.
///
/// **CRITICAL DATABASE RULES:**
/// - Must use `databaseId: 'elajtech'` for ALL Firestore operations
/// - Never use FirebaseFirestore.instance directly
/// - Collection name: Defined in AppConstants.collections.prescriptions
/// - All operations include comprehensive error handling
/// - appointmentId is required for all save operations
///
/// **Dependency Injection:**
/// Registered as @LazySingleton with injectable package. Access via:
/// ```dart
/// final repository = getIt<PrescriptionRepository>();
/// ```
///
/// **Error Handling:**
/// All methods return `Either<Failure, T>` from dartz package:
/// - Left(Failure): Operation failed with specific failure type
/// - Right(T): Operation succeeded with result
///
/// **Failure Types:**
/// - ServerFailure: Firestore operation errors or unexpected exceptions
///
/// **Security Rules:**
/// - appointmentId validation (must not be empty)
/// - 24-hour edit window enforcement via Firestore security rules
/// - permission-denied error triggers Arabic error message
///
/// **Special Features:**
/// - Bilingual Error Messages: Arabic messages for user-facing errors
/// - 24-Hour Window: Prescriptions can only be added/edited within 24 hours of appointment
/// - Multiple Query Options: By patient, doctor, or appointment
///
/// **Usage Example:**
/// ```dart
/// final repository = getIt<PrescriptionRepository>();
///
/// // Save prescription
/// final prescription = PrescriptionModel(
///   id: 'rx_123',
///   appointmentId: 'apt_456',
///   patientId: 'patient_789',
///   doctorId: 'doctor_101',
///   medications: [...],
///   // ... other fields
/// );
///
/// final result = await repository.savePrescription(prescription);
/// result.fold(
///   (failure) => showError(failure.message),
///   (_) => showSuccess('وصفة طبية محفوظة'),
/// );
/// ```
@LazySingleton(as: PrescriptionRepository)
class PrescriptionRepositoryImpl implements PrescriptionRepository {
  /// Constructor with dependency injection.
  ///
  /// The [_firestore] instance is injected by GetIt and configured with
  /// `databaseId: 'elajtech'` in firebase_module.dart.
  ///
  /// Parameters:
  /// - _firestore: Configured FirebaseFirestore instance (injected)
  PrescriptionRepositoryImpl(this._firestore);
  final FirebaseFirestore _firestore;

  /// Save or update a prescription.
  ///
  /// Persists a prescription to Firestore with validation and 24-hour window enforcement.
  ///
  /// **Validation:**
  /// - appointmentId must not be empty
  /// - Firestore security rules enforce 24-hour edit window
  ///
  /// **24-Hour Window:**
  /// - Prescriptions can only be added/edited within 24 hours of appointment
  /// - After 24 hours, permission-denied error is returned with Arabic message
  ///
  /// Parameters:
  /// - prescription: PrescriptionModel to save (required)
  ///
  /// Returns:
  /// - Right(Unit): Prescription saved successfully
  /// - Left(ServerFailure): Operation failed
  ///   - 'appointmentId مطلوب لحفظ الوصفة الطبية': appointmentId is empty
  ///   - 'عذراً، انتهت المدة المسموح بها...': 24-hour window expired
  ///
  /// Example:
  /// ```dart
  /// final prescription = PrescriptionModel(
  ///   id: 'rx_123',
  ///   appointmentId: 'apt_456',
  ///   patientId: 'patient_789',
  ///   medications: [
  ///     Medication(name: 'Aspirin', dosage: '100mg', frequency: 'Once daily'),
  ///   ],
  /// );
  ///
  /// final result = await repository.savePrescription(prescription);
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (_) => showSuccess('Prescription saved'),
  /// );
  /// ```
  @override
  Future<Either<Failure, Unit>> savePrescription(
    PrescriptionModel prescription,
  ) async {
    try {
      // ✅ التحقق من أن appointmentId غير فارغ
      if (prescription.appointmentId.isEmpty) {
        return const Left(
          ServerFailure('appointmentId مطلوب لحفظ الوصفة الطبية'),
        );
      }

      await _firestore
          .collection(AppConstants.collections.prescriptions)
          .doc(prescription.id)
          .set(prescription.toJson());
      return const Right(unit);
    } on FirebaseException catch (e) {
      // ✅ معالجة خطأ permission-denied (انتهاء 24 ساعة)
      if (e.code == 'permission-denied') {
        return const Left(
          ServerFailure(
            'عذراً، انتهت المدة المسموح بها لإضافة أو تعديل البيانات الطبية لهذا الموعد (24 ساعة)',
          ),
        );
      }
      return Left(ServerFailure(e.toString()));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Retrieve all prescriptions for a specific patient.
  ///
  /// Queries prescriptions collection for all prescriptions belonging to
  /// the specified patient, ordered by creation date (newest first).
  ///
  /// Parameters:
  /// - patientId: Unique patient identifier (required)
  ///
  /// Returns:
  /// - `Right(List<PrescriptionModel>)`: List of prescriptions (may be empty)
  /// - `Left(ServerFailure)`: Firestore operation failed
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.getPrescriptionsForPatient('patient_789');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (prescriptions) => displayPrescriptionHistory(prescriptions),
  /// );
  /// ```
  @override
  Future<Either<Failure, List<PrescriptionModel>>> getPrescriptionsForPatient(
    String patientId,
  ) async {
    try {
      final query = await _firestore
          .collection(AppConstants.collections.prescriptions)
          .where('patientId', isEqualTo: patientId)
          .orderBy('createdAt', descending: true)
          .get();

      final prescriptions = query.docs
          .map((doc) => PrescriptionModel.fromJson(doc.data()))
          .toList();

      return Right(prescriptions);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<PrescriptionModel>>>
  getPrescriptionsForPatientPage(
    String patientId, {
    int limit = 10,
  }) async {
    try {
      final query = await _firestore
          .collection(AppConstants.collections.prescriptions)
          .where('patientId', isEqualTo: patientId)
          .orderBy('createdAt', descending: true)
          .limit(limit + 1)
          .get();

      final hasMore = query.docs.length > limit;
      final prescriptions = query.docs
          .take(limit)
          .map((doc) => PrescriptionModel.fromJson(doc.data()))
          .toList();

      return Right(PaginatedResult(items: prescriptions, hasMore: hasMore));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Retrieve all prescriptions created by a specific doctor.
  ///
  /// Queries prescriptions collection for all prescriptions created by
  /// the specified doctor, ordered by creation date (newest first).
  ///
  /// Parameters:
  /// - doctorId: Unique doctor identifier (required)
  ///
  /// Returns:
  /// - `Right(List<PrescriptionModel>)`: List of prescriptions (may be empty)
  /// - `Left(ServerFailure)`: Firestore operation failed
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.getPrescriptionsByDoctor('doctor_101');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (prescriptions) => displayDoctorPrescriptions(prescriptions),
  /// );
  /// ```
  @override
  Future<Either<Failure, List<PrescriptionModel>>> getPrescriptionsByDoctor(
    String doctorId,
  ) async {
    try {
      final query = await _firestore
          .collection(AppConstants.collections.prescriptions)
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('createdAt', descending: true)
          .get();

      final prescriptions = query.docs
          .map((doc) => PrescriptionModel.fromJson(doc.data()))
          .toList();

      return Right(prescriptions);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Retrieve all prescriptions for a specific appointment.
  ///
  /// Queries prescriptions collection for all prescriptions associated with
  /// the specified appointment.
  ///
  /// Parameters:
  /// - appointmentId: Unique appointment identifier (required)
  ///
  /// Returns:
  /// - `Right(List<PrescriptionModel>)`: List of prescriptions (may be empty)
  /// - `Left(ServerFailure)`: Firestore operation failed
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.getPrescriptionsByAppointmentId('apt_456');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (prescriptions) => displayAppointmentPrescriptions(prescriptions),
  /// );
  /// ```
  @override
  Future<Either<Failure, List<PrescriptionModel>>>
  getPrescriptionsByAppointmentId(String appointmentId) async {
    try {
      final query = await _firestore
          .collection(AppConstants.collections.prescriptions)
          .where('appointmentId', isEqualTo: appointmentId)
          .get();

      final prescriptions = query.docs
          .map((doc) => PrescriptionModel.fromJson(doc.data()))
          .toList();

      return Right(prescriptions);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
