import 'package:cached_network_image/cached_network_image.dart';
import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/patient/home/presentation/screens/doctor_details_screen.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter/material.dart';

/// Doctor Card Widget - بطاقة الطبيب
class DoctorCard extends StatelessWidget {
  const DoctorCard({required this.doctor, super.key});
  final UserModel doctor;

  @override
  Widget build(BuildContext context) {
    // Helper helpers
    final isAvailableForVideo =
        doctor.consultationTypes?.contains('video') ?? false;
    final isAvailableInClinic =
        doctor.consultationTypes?.contains('clinic') ?? false;
    final specializationsFormatted =
        doctor.specializations?.join('، ') ?? 'عام';
    final yearsOfExperience = doctor.yearsOfExperience ?? 0;

    return InkWell(
      onTap: () async {
        await Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (context) => DoctorDetailsScreen(doctor: doctor),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Doctor Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: doctor.profileImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: doctor.profileImage!,
                        fit: BoxFit.cover,
                        width: 80,
                        height: 80,
                        placeholder: (context, url) => const Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.primary,
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.primary,
                    ),
            ),
            const SizedBox(width: 16),

            // Doctor Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    doctor.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Specialization
                  Text(
                    specializationsFormatted,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Experience & Rating
                  Row(
                    children: [
                      // Experience
                      const Icon(
                        Icons.work_outline,
                        size: 16,
                        color: AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '$yearsOfExperience سنة خبرة',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Rating (Mocked for now as per design)
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '4.8 (120)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Availability Badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (isAvailableForVideo)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.videocam,
                                size: 12,
                                color: AppColors.info,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'فيديو',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.info,
                                      fontSize: 10,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      if (isAvailableInClinic)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.local_hospital,
                                size: 12,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'عيادة',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.success,
                                      fontSize: 10,
                                    ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow Icon
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }
}
