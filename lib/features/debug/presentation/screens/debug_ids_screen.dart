import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/shared/models/doctor_model.dart';
import 'package:elajtech/shared/providers/appointments_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Debug Screen to check IDs
class DebugIdsScreen extends ConsumerWidget {
  const DebugIdsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final allAppointments = ref.watch(appointmentsProvider);
    final doctors = MockDoctors.getDoctors();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug - IDs'),
        backgroundColor: AppColors.error,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current User Info
            _Section(
              title: 'Current User (Logged In)',
              children: [
                _InfoRow('Name', user?.fullName ?? 'No user'),
                _InfoRow('ID', user?.id ?? 'N/A'),
                _InfoRow('Type', user?.userType.toString() ?? 'N/A'),
                _InfoRow('Email', user?.email ?? 'N/A'),
              ],
            ),

            const SizedBox(height: 24),

            // Doctors List
            _Section(
              title: 'Doctors in List',
              children: doctors
                  .map(
                    (doctor) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow('Name', doctor.fullName),
                        _InfoRow('ID', doctor.id),
                        const Divider(),
                      ],
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 24),

            // All Appointments
            _Section(
              title: 'All Appointments (${allAppointments.length})',
              children: allAppointments.isEmpty
                  ? [const Text('No appointments')]
                  : allAppointments
                        .map(
                          (apt) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _InfoRow('Patient', apt.patientName),
                              _InfoRow('Patient ID', apt.patientId),
                              _InfoRow('Doctor', apt.doctorName),
                              _InfoRow('Doctor ID', apt.doctorId),
                              _InfoRow(
                                'Date',
                                apt.appointmentDate.toString().substring(0, 10),
                              ),
                              _InfoRow('Status', apt.status.toString()),
                              const Divider(thickness: 2),
                            ],
                          ),
                        )
                        .toList(),
            ),

            const SizedBox(height: 24),

            // Filtered Appointments for Current User
            if (user != null) ...[
              _Section(
                title: 'Appointments for Current User ID: ${user.id}',
                children: [
                  Text(
                    'Matching appointments: ${allAppointments.where((apt) => apt.doctorId == user.id).length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...allAppointments
                      .where((apt) => apt.doctorId == user.id)
                      .map(
                        (apt) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InfoRow('Patient', apt.patientName),
                            _InfoRow(
                              'Date',
                              apt.appointmentDate.toString().substring(0, 10),
                            ),
                            const Divider(),
                          ],
                        ),
                      ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.borderLight),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ],
    ),
  );
}
