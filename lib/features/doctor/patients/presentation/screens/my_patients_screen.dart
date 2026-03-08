import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/doctor/patients/presentation/screens/doctor_patient_history_screen.dart';
import 'package:elajtech/features/user/domain/repositories/user_repository.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

final AutoDisposeFutureProvider<List<UserModel>> allPatientsProvider =
    FutureProvider.autoDispose<List<UserModel>>((ref) async {
      final repository = GetIt.I<UserRepository>();
      final result = await repository.getAllPatients();
      return result.fold(
        (l) => [], // Handle error gracefully or return empty
        (r) => r,
      );
    });

class MyPatientsScreen extends ConsumerWidget {
  const MyPatientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(allPatientsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('قائمة المرضى')),
      body: patientsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
        data: (patients) {
          if (patients.isEmpty) {
            return const Center(child: Text('لا يوجد مرضى مسجلين حالياً'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final patient = patients[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(patient.fullName),
                  subtitle: Text(patient.phoneNumber ?? 'لا يوجد رقم هاتف'),
                  trailing: IconButton(
                    icon: const Icon(Icons.history, color: AppColors.primary),
                    tooltip: 'سجل المواعيد',
                    onPressed: () async {
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => DoctorPatientHistoryScreen(
                            patientId: patient.id,
                            patientName: patient.fullName,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
