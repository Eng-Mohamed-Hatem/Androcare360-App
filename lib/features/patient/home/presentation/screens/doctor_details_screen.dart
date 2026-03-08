import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/patient/appointments/presentation/screens/book_appointment_screen.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:elajtech/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class DoctorDetailsScreen extends StatelessWidget {
  const DoctorDetailsScreen({required this.doctor, super.key});
  final UserModel doctor;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8F9FD),
    body: CustomScrollView(
      slivers: [
        // App Bar with Image
        SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          backgroundColor: AppColors.primary,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: doctor.profileImage != null
                            ? NetworkImage(doctor.profileImage!)
                            : null,
                        child: doctor.profileImage == null
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            title: Text(doctor.fullName),
            centerTitle: true,
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            child: const Icon(
                              Icons.star,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'التقييم العام',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Row(
                                children: [
                                  const Text(
                                    '4.8',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber[700],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.grey[200],
                          ),
                          const Spacer(),
                          // Experience
                          CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            child: const Icon(
                              Icons.work_outline,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'الخبرة',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '${doctor.yearsOfExperience ?? 0} سنوات',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Biography
                const Text(
                  'نبذة عن الطبيب',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  doctor.biography ?? 'لا توجد نبذة متاحة',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 24),

                // Clinic Information
                if (doctor.clinicName != null ||
                    doctor.clinicAddress != null) ...[
                  const Text(
                    'معلومات العيادة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        if (doctor.clinicName != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.local_hospital,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  doctor.clinicName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (doctor.clinicName != null &&
                            doctor.clinicAddress != null)
                          const Divider(height: 24),
                        if (doctor.clinicAddress != null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  doctor.clinicAddress!,
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Specializations
                if (doctor.specializations != null &&
                    doctor.specializations!.isNotEmpty) ...[
                  const Text(
                    'التخصصات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: doctor.specializations!.map((spec) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          spec,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Working Hours
                if (doctor.workingHours != null &&
                    doctor.workingHours!.isNotEmpty) ...[
                  const Text(
                    'مواعيد العمل',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...doctor.workingHours!.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${entry.key}: ',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.value.join('، '),
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                ],

                // Consultation Types
                const Text(
                  'أنواع الاستشارات المتاحة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (doctor.consultationTypes?.contains('clinic') ?? false)
                      const Expanded(
                        child: _ConsultationTypeCard(
                          icon: Icons.apartment,
                          title: 'في العيادة',
                          color: AppColors.primary,
                        ),
                      ),
                    if ((doctor.consultationTypes?.contains('clinic') ??
                            false) &&
                        (doctor.consultationTypes?.contains('video') ?? false))
                      const SizedBox(width: 12),
                    if (doctor.consultationTypes?.contains('video') ?? false)
                      const Expanded(
                        child: _ConsultationTypeCard(
                          icon: Icons.videocam,
                          title: 'استشارة فيديو',
                          color: AppColors.secondary,
                        ),
                      ),
                    if (doctor.consultationTypes == null ||
                        doctor.consultationTypes!.isEmpty)
                      const Expanded(
                        child: Text(
                          'غير محدد',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 32),

                // Book Appointment Button
                CustomButton(
                  text: 'حجز موعد',
                  onPressed: () async {
                    final types = doctor.consultationTypes ?? [];
                    final hasVideo = types.contains('video');
                    final hasClinic = types.contains('clinic');

                    if (hasVideo && hasClinic) {
                      // Show selection dialog
                      await showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('اختر نوع الاستشارة'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(
                                  Icons.videocam,
                                  color: AppColors.secondary,
                                ),
                                title: const Text('استشارة فيديو'),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (context) =>
                                          BookAppointmentScreen(
                                            doctor: doctor,
                                            isVideoConsultation: true,
                                          ),
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.apartment,
                                  color: AppColors.primary,
                                ),
                                title: const Text('زيارة عيادة'),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (context) =>
                                          BookAppointmentScreen(
                                            doctor: doctor,
                                            isVideoConsultation: false,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (hasVideo) {
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => BookAppointmentScreen(
                            doctor: doctor,
                            isVideoConsultation: true,
                          ),
                        ),
                      );
                    } else {
                      // Default to clinic (or if only clinic is available)
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => BookAppointmentScreen(
                            doctor: doctor,
                            isVideoConsultation: false,
                          ),
                        ),
                      );
                    }
                  },
                  icon: Icons.calendar_today,
                ),
                const SizedBox(
                  height: 150,
                ), // مساحة آمنة للشريط السفلي (80px height + padding)
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _ConsultationTypeCard extends StatelessWidget {
  const _ConsultationTypeCard({
    required this.icon,
    required this.title,
    required this.color,
  });
  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
