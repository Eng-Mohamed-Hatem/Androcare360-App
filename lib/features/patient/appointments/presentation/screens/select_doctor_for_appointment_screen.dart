import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/patient/appointments/presentation/screens/book_appointment_screen.dart';
import 'package:elajtech/features/patient/home/presentation/widgets/doctor_card.dart';
import 'package:elajtech/shared/providers/registered_doctors_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Select Doctor for Appointment Screen - شاشة اختيار طبيب للحجز
class SelectDoctorForAppointmentScreen extends ConsumerWidget {
  const SelectDoctorForAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(doctorsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('اختر الطبيب')),
      body: doctorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'حدث خطأ في تحميل الأطباء',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(doctorsListProvider),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
        data: (doctors) => doctors.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person_search,
                      size: 80,
                      color: AppColors.textSecondaryLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا يوجد أطباء مسجلين حالياً',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'انتظر حتى يتم تسجيل أطباء جدد',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doctor = doctors[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () async {
                        await Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => BookAppointmentScreen(
                              doctor: doctor,
                              isVideoConsultation: false,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: DoctorCard(doctor: doctor),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
