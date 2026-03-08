/// Test fixtures for AppointmentModel
///
/// Provides factory methods for creating test appointment data with realistic values.
/// These fixtures are used across unit, widget, and integration tests.
library;

import 'package:elajtech/shared/models/appointment_model.dart';

/// Provides test fixtures for Appointment model
class AppointmentFixtures {
  /// Creates a pending appointment for testing
  ///
  /// Parameters:
  /// - [id]: Optional custom ID (defaults to 'apt_pending_001')
  /// - [doctorId]: Optional doctor ID (defaults to 'doctor_test_001')
  /// - [patientId]: Optional patient ID (defaults to 'patient_test_001')
  /// - [appointmentDate]: Optional date (defaults to tomorrow)
  ///
  /// Returns an AppointmentModel with pending status
  static AppointmentModel createPendingAppointment({
    String? id,
    String? doctorId,
    String? patientId,
    DateTime? appointmentDate,
  }) {
    final date = appointmentDate ?? DateTime.now().add(const Duration(days: 1));

    return AppointmentModel(
      id: id ?? 'apt_pending_001',
      patientId: patientId ?? 'patient_test_001',
      patientName: 'Test Patient',
      patientPhone: '+966500000002',
      doctorId: doctorId ?? 'doctor_test_001',
      doctorName: 'Dr. Test Doctor',
      specialization: 'Nutrition',
      appointmentDate: date,
      timeSlot: '10:00 AM',
      type: AppointmentType.video,
      status: AppointmentStatus.pending,
      fee: 200,
      createdAt: DateTime.now(),
      notes: 'Test appointment - pending confirmation',
    );
  }

  /// Creates a confirmed appointment for testing
  ///
  /// Parameters:
  /// - [id]: Optional custom ID (defaults to 'apt_confirmed_001')
  /// - [channelName]: Optional Agora channel name
  /// - [agoraToken]: Optional Agora token
  /// - [doctorId]: Optional doctor ID
  /// - [patientId]: Optional patient ID
  /// - [patientName]: Optional patient name (defaults to 'Test Patient')
  ///
  /// Returns an AppointmentModel with confirmed status and Agora details
  static AppointmentModel createConfirmedAppointment({
    String? id,
    String? channelName,
    String? agoraToken,
    String? doctorId,
    String? patientId,
    String? patientName,
  }) {
    final appointmentDate = DateTime.now().add(const Duration(hours: 2));

    return AppointmentModel(
      id: id ?? 'apt_confirmed_001',
      patientId: patientId ?? 'patient_test_001',
      patientName: patientName ?? 'Test Patient',
      patientPhone: '+966500000002',
      doctorId: doctorId ?? 'doctor_test_001',
      doctorName: 'Dr. Test Doctor',
      specialization: 'Nutrition',
      appointmentDate: appointmentDate,
      timeSlot: '02:00 PM',
      type: AppointmentType.video,
      status: AppointmentStatus.confirmed,
      fee: 200,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      notes: 'Test appointment - confirmed',
      agoraChannelName: channelName ?? 'test_channel_001',
      agoraToken: agoraToken ?? 'test_token_123',
      agoraUid: 12345,
      scheduledDateTime: appointmentDate,
      appointmentTimestamp: appointmentDate,
    );
  }

  /// Creates a scheduled appointment for testing
  static AppointmentModel createScheduledAppointment({
    String? id,
    String? doctorId,
    String? patientId,
  }) {
    final appointmentDate = DateTime.now().add(const Duration(days: 3));

    return AppointmentModel(
      id: id ?? 'apt_scheduled_001',
      patientId: patientId ?? 'patient_test_001',
      patientName: 'Test Patient',
      patientPhone: '+966500000002',
      doctorId: doctorId ?? 'doctor_test_001',
      doctorName: 'Dr. Test Doctor',
      specialization: 'Nutrition',
      appointmentDate: appointmentDate,
      timeSlot: '11:00 AM',
      type: AppointmentType.video,
      status: AppointmentStatus.scheduled,
      fee: 200,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      scheduledDateTime: appointmentDate,
      appointmentTimestamp: appointmentDate,
    );
  }

  /// Creates a completed appointment for testing
  static AppointmentModel createCompletedAppointment({
    String? id,
    String? doctorId,
    String? patientId,
  }) {
    final appointmentDate = DateTime.now().subtract(const Duration(days: 1));

    return AppointmentModel(
      id: id ?? 'apt_completed_001',
      patientId: patientId ?? 'patient_test_001',
      patientName: 'Test Patient',
      patientPhone: '+966500000002',
      doctorId: doctorId ?? 'doctor_test_001',
      doctorName: 'Dr. Test Doctor',
      specialization: 'Nutrition',
      appointmentDate: appointmentDate,
      timeSlot: '10:00 AM',
      type: AppointmentType.video,
      status: AppointmentStatus.completed,
      fee: 200,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      notes: 'Appointment completed successfully',
      agoraChannelName: 'completed_channel_001',
      scheduledDateTime: appointmentDate,
      appointmentTimestamp: appointmentDate,
    );
  }

  /// Creates a cancelled appointment for testing
  static AppointmentModel createCancelledAppointment({
    String? id,
    String? doctorId,
    String? patientId,
  }) {
    final appointmentDate = DateTime.now().add(const Duration(days: 1));

    return AppointmentModel(
      id: id ?? 'apt_cancelled_001',
      patientId: patientId ?? 'patient_test_001',
      patientName: 'Test Patient',
      patientPhone: '+966500000002',
      doctorId: doctorId ?? 'doctor_test_001',
      doctorName: 'Dr. Test Doctor',
      specialization: 'Nutrition',
      appointmentDate: appointmentDate,
      timeSlot: '03:00 PM',
      type: AppointmentType.video,
      status: AppointmentStatus.cancelled,
      fee: 200,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      notes: 'Cancelled by patient',
    );
  }

  /// Creates a clinic appointment (not video) for testing
  static AppointmentModel createClinicAppointment({
    String? id,
    String? doctorId,
    String? patientId,
  }) {
    final appointmentDate = DateTime.now().add(const Duration(days: 2));

    return AppointmentModel(
      id: id ?? 'apt_clinic_001',
      patientId: patientId ?? 'patient_test_001',
      patientName: 'Test Patient',
      patientPhone: '+966500000002',
      doctorId: doctorId ?? 'doctor_test_001',
      doctorName: 'Dr. Test Doctor',
      specialization: 'Nutrition',
      appointmentDate: appointmentDate,
      timeSlot: '09:00 AM',
      type: AppointmentType.clinic,
      status: AppointmentStatus.confirmed,
      fee: 150,
      createdAt: DateTime.now(),
      notes: 'In-person clinic visit',
    );
  }

  /// Creates a physiotherapy appointment for testing
  static AppointmentModel createPhysiotherapyAppointment({
    String? id,
    String? doctorId,
    String? patientId,
    AppointmentStatus? status,
  }) {
    final appointmentDate = DateTime.now().add(const Duration(days: 1));

    return AppointmentModel(
      id: id ?? 'apt_physio_001',
      patientId: patientId ?? 'patient_test_001',
      patientName: 'Test Patient',
      patientPhone: '+966500000002',
      doctorId: doctorId ?? 'doctor_physio_001',
      doctorName: 'Dr. Physio Test',
      specialization: 'Physiotherapy',
      appointmentDate: appointmentDate,
      timeSlot: '11:00 AM',
      type: AppointmentType.video,
      status: status ?? AppointmentStatus.confirmed,
      fee: 250,
      createdAt: DateTime.now(),
      notes: 'Physiotherapy consultation',
    );
  }

  /// Creates a list of multiple appointments with different statuses
  static List<AppointmentModel> createMultipleAppointments({
    String? doctorId,
    String? patientId,
  }) {
    return [
      createPendingAppointment(
        id: 'apt_001',
        doctorId: doctorId,
        patientId: patientId,
      ),
      createConfirmedAppointment(
        id: 'apt_002',
        doctorId: doctorId,
        patientId: patientId,
      ),
      createScheduledAppointment(
        id: 'apt_003',
        doctorId: doctorId,
        patientId: patientId,
      ),
      createCompletedAppointment(
        id: 'apt_004',
        doctorId: doctorId,
        patientId: patientId,
      ),
    ];
  }

  /// Creates appointments for conflict testing (same time slot)
  static List<AppointmentModel> createConflictingAppointments({
    required String doctorId,
  }) {
    final appointmentDate = DateTime.now().add(const Duration(days: 1));
    const timeSlot = '10:00 AM';

    return [
      AppointmentModel(
        id: 'apt_conflict_001',
        patientId: 'patient_001',
        patientName: 'Patient One',
        patientPhone: '+966500000001',
        doctorId: doctorId,
        doctorName: 'Dr. Test Doctor',
        specialization: 'Nutrition',
        appointmentDate: appointmentDate,
        timeSlot: timeSlot,
        type: AppointmentType.video,
        status: AppointmentStatus.confirmed,
        fee: 200,
        createdAt: DateTime.now(),
      ),
      AppointmentModel(
        id: 'apt_conflict_002',
        patientId: 'patient_002',
        patientName: 'Patient Two',
        patientPhone: '+966500000002',
        doctorId: doctorId,
        doctorName: 'Dr. Test Doctor',
        specialization: 'Nutrition',
        appointmentDate: appointmentDate,
        timeSlot: timeSlot,
        type: AppointmentType.video,
        status: AppointmentStatus.pending,
        fee: 200,
        createdAt: DateTime.now(),
      ),
    ];
  }
}
