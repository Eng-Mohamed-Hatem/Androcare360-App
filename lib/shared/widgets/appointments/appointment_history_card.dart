import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// [AppointmentHistoryCard] is a shared widget used to display appointment details
/// in a consistent format across the patient's medical records and admin dashboard.
///
/// [AppointmentHistoryCard] هو ويدجت مشترك يستخدم لعرض تفاصيل المواعيد
/// بتنسيق موحد في سجلات المريض الطبية ولوحة تحكم المسؤول.
class AppointmentHistoryCard extends StatelessWidget {
  /// Creates an [AppointmentHistoryCard].
  const AppointmentHistoryCard({
    required this.appointment,
    super.key,
  });

  /// The appointment data to display.
  final AppointmentModel appointment;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Date Box
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('dd').format(appointment.appointmentDate),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    DateFormat('MMM', 'ar').format(appointment.appointmentDate),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'د. ${appointment.doctorName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appointment.specialization,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat(
                          'hh:mm a',
                          'ar',
                        ).format(appointment.fullDateTime),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(
                  appointment.status,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getStatusColor(appointment.status),
                ),
              ),
              child: Text(
                _getStatusLabel(appointment.status),
                style: TextStyle(
                  color: _getStatusColor(appointment.status),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return 'انتظار';
      case AppointmentStatus.confirmed:
        return 'مؤكد';
      case AppointmentStatus.scheduled:
        return 'مجدول';
      case AppointmentStatus.completed:
        return 'مكتمل';
      case AppointmentStatus.cancelled:
        return 'ملغي';
      case AppointmentStatus.missed:
        return 'فائت';
    }
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return Colors.blue;
      case AppointmentStatus.scheduled:
        return Colors.purple;
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.missed:
        return AppColors.error;
    }
  }
}
