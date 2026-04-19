import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppointmentStatus serialisation', () {
    const statusMappings = <AppointmentStatus, String>{
      AppointmentStatus.pending: 'pending',
      AppointmentStatus.confirmed: 'confirmed',
      AppointmentStatus.scheduled: 'scheduled',
      AppointmentStatus.calling: 'calling',
      AppointmentStatus.inProgress: 'in_progress',
      AppointmentStatus.missed: 'missed',
      AppointmentStatus.declined: 'declined',
      AppointmentStatus.endedPendingConfirmation: 'ended_pending_confirmation',
      AppointmentStatus.completed: 'completed',
      AppointmentStatus.notCompleted: 'not_completed',
      AppointmentStatus.cancelled: 'cancelled',
    };

    AppointmentModel buildAppointment(AppointmentStatus status) {
      return AppointmentModel(
        id: 'appointment-1',
        patientId: 'patient-1',
        patientName: 'Test Patient',
        patientPhone: '+201000000000',
        doctorId: 'doctor-1',
        doctorName: 'Test Doctor',
        specialization: 'Nutrition',
        appointmentDate: DateTime.utc(2026, 3, 31),
        timeSlot: '10:00 AM',
        type: AppointmentType.video,
        status: status,
        fee: 200,
        createdAt: DateTime.utc(2026, 3, 30),
        callSessionId: 'channel_appointment-1',
        confirmationDeadlineAt: DateTime.utc(2026, 4),
      );
    }

    test('round-trips all known Firestore status values via JSON', () {
      for (final entry in statusMappings.entries) {
        final appointment = buildAppointment(entry.key);

        final json = appointment.toJson();
        final restored = AppointmentModel.fromJson(json);

        expect(json['status'], entry.value);
        expect(restored.status, entry.key);
        expect(restored.callSessionId, 'channel_appointment-1');
        expect(
          restored.confirmationDeadlineAt,
          DateTime.utc(2026, 4),
        );
      }
    });

    test('falls back to pending for unknown status strings', () {
      final restored = AppointmentModel.fromJson({
        'id': 'appointment-1',
        'patientId': 'patient-1',
        'patientName': 'Test Patient',
        'patientPhone': '+201000000000',
        'doctorId': 'doctor-1',
        'doctorName': 'Test Doctor',
        'specialization': 'Nutrition',
        'appointmentDate': DateTime.utc(2026, 3, 31).toIso8601String(),
        'timeSlot': '10:00 AM',
        'type': 'video',
        'status': 'unexpected_status',
        'fee': 200,
        'createdAt': DateTime.utc(2026, 3, 30).toIso8601String(),
      });

      expect(restored.status, AppointmentStatus.pending);
    });

    test(
      'parses Firestore documents with new status values and fields',
      () async {
        final firestore = FakeFirebaseFirestore();
        final deadline = DateTime.utc(2026, 4, 1, 12);

        await firestore.collection('appointments').doc('appointment-doc').set({
          'patientId': 'patient-1',
          'patientName': 'Test Patient',
          'patientPhone': '+201000000000',
          'doctorId': 'doctor-1',
          'doctorName': 'Test Doctor',
          'specialization': 'Nutrition',
          'appointmentDate': Timestamp.fromDate(DateTime.utc(2026, 3, 31)),
          'timeSlot': '10:00 AM',
          'type': 'video',
          'status': 'ended_pending_confirmation',
          'fee': 200,
          'createdAt': Timestamp.fromDate(DateTime.utc(2026, 3, 30)),
          'callSessionId': 'channel_appointment-doc',
          'confirmationDeadlineAt': Timestamp.fromDate(deadline),
        });

        final snapshot = await firestore
            .collection('appointments')
            .doc('appointment-doc')
            .get();

        final appointment = AppointmentModel.fromFirestore(snapshot);

        expect(appointment.id, 'appointment-doc');
        expect(
          appointment.status,
          AppointmentStatus.endedPendingConfirmation,
        );
        expect(appointment.callSessionId, 'channel_appointment-doc');
        expect(appointment.confirmationDeadlineAt?.toUtc(), deadline);
      },
    );
  });
}
