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
}
