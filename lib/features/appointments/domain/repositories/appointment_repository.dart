import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/core/models/paginated_result.dart';
import 'package:elajtech/shared/models/appointment_model.dart';

/// Appointment Repository Interface
abstract class AppointmentRepository {
  /// Save Appointment (Create or Update)
  Future<Either<Failure, Unit>> saveAppointment(AppointmentModel appointment);

  /// Book Appointment (Atomic Check and Create)
  ///
  /// This method uses a Firestore transaction to ensure no conflicts exist
  /// at the moment of booking.
  Future<Either<Failure, Unit>> bookAppointment(AppointmentModel appointment);

  /// Get Appointments for Patient
  Future<Either<Failure, List<AppointmentModel>>> getAppointmentsForPatient(
    String patientId,
  );

  Future<Either<Failure, PaginatedResult<AppointmentModel>>>
  getAppointmentsForPatientPage(
    String patientId, {
    int limit = 10,
  });

  /// Get Appointments for Doctor
  Future<Either<Failure, List<AppointmentModel>>> getAppointmentsForDoctor(
    String doctorId,
  );

  /// Get doctor's appointments for a specific date via Cloud Function.
  Future<Either<Failure, List<Map<String, dynamic>>>>
  getDoctorAppointmentsViaCloudFunction({
    required String doctorId,
    required DateTime date,
  });

  /// Check Appointment Conflict
  ///
  /// [patientId] معرف المريض
  /// [newAppointment] الموعد المراد حجزه
  ///
  /// يُرجع نتيجة التحقق من التضارب
  Future<Either<Failure, bool>> checkAppointmentConflict({
    required String patientId,
    required AppointmentModel newAppointment,
  });

  /// Get Active Appointments for Patient
  ///
  /// [patientId] معرف المريض
  ///
  /// يُرجع المواعيد النشطة (غير الملغية والمكتملة)
  Future<Either<Failure, List<AppointmentModel>>>
  getActiveAppointmentsForPatient(
    String patientId,
  );

  /// Get Active Appointments for Date
  ///
  /// [date] التاريخ المراد البحث فيه
  ///
  /// يُرجع المواعيد النشطة (غير الملغية) في هذا التاريخ
  Future<Either<Failure, List<AppointmentModel>>> getActiveAppointmentsForDate(
    DateTime date,
  );

  /// مراقبة مواعيد المريض في الوقت الفعلي
  /// Real-time stream of all appointments for the given patient.
  ///
  /// Emits a new list whenever any appointment document changes in Firestore.
  /// Used by the patient's appointments tab to reactively enable the
  /// "Join Meeting" button when the doctor starts a call
  /// (Firestore sets status:'calling', agoraToken, callStartedAt).
  ///
  /// The stream does not complete — callers must cancel the subscription.
  Stream<List<AppointmentModel>> watchAppointmentsForPatient(String patientId);
}
