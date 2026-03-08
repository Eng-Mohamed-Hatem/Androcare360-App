import 'package:elajtech/core/constants/app_colors.dart';
// import 'package:elajtech/core/services/firestore_service.dart'; // Unused
import 'package:elajtech/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:elajtech/features/medical_records/presentation/screens/appointment_medical_record_screen.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class DoctorPatientHistoryScreen extends ConsumerStatefulWidget {
  const DoctorPatientHistoryScreen({
    required this.patientId,
    required this.patientName,
    super.key,
  });
  final String patientId;
  final String patientName;

  @override
  ConsumerState<DoctorPatientHistoryScreen> createState() =>
      _DoctorPatientHistoryScreenState();
}

class _DoctorPatientHistoryScreenState
    extends ConsumerState<DoctorPatientHistoryScreen> {
  late Future<List<AppointmentModel>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _getAppointments();
  }

  Future<List<AppointmentModel>> _getAppointments() async {
    final result = await GetIt.I<AppointmentRepository>()
        .getAppointmentsForPatient(widget.patientId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (list) => list,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('سجل المواعيد', style: TextStyle(fontSize: 16)),
          Text(
            widget.patientName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
    body: FutureBuilder<List<AppointmentModel>>(
      future: _appointmentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('حدث خطأ: ${snapshot.error}'));
        }

        final appointments = snapshot.data ?? [];

        if (appointments.isEmpty) {
          return const Center(
            child: Text('لا توجد مواعيد سابقة لهذا المريض'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            final isCompleted =
                appointment.status == AppointmentStatus.completed;
            final isCancelled =
                appointment.status == AppointmentStatus.cancelled;

            Color statusColor = Colors.orange;
            var statusText = 'قيد الانتظار';

            if (isCompleted) {
              statusColor = Colors.green;
              statusText = 'مكتمل';
            } else if (isCancelled) {
              statusColor = Colors.red;
              statusText = 'ملغي';
            } else if (appointment.status == AppointmentStatus.confirmed) {
              statusColor = Colors.blue;
              statusText = 'مؤكد';
            }

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.borderLight),
              ),
              child: InkWell(
                onTap: () async {
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => AppointmentMedicalRecordScreen(
                        appointment: appointment,
                        patientName: widget.patientName,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat(
                              'yyyy/MM/dd',
                            ).format(appointment.appointmentDate),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            appointment.timeSlot,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.person_outline,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'د. ${appointment.doctorName}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.medical_services_outlined,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            appointment.specialization,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ),
  );
}
