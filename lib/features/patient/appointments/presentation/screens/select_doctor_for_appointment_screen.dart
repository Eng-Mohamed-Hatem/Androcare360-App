import 'dart:async';

import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/services/assessment_referral_tracking_service.dart';
import 'package:elajtech/features/patient/appointments/presentation/screens/book_appointment_screen.dart';
import 'package:elajtech/features/patient/home/presentation/widgets/doctor_card.dart';
import 'package:elajtech/features/patient/self_assessment/data/models/quiz_models.dart';
import 'package:elajtech/shared/constants/clinic_types.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:elajtech/shared/providers/registered_doctors_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Select Doctor for Appointment Screen - شاشة اختيار طبيب للحجز
class SelectDoctorForAppointmentScreen extends ConsumerStatefulWidget {
  const SelectDoctorForAppointmentScreen({
    super.key,
    this.title,
    this.specializationHints = const [],
    this.referralContext,
  });

  final String? title;
  final List<String> specializationHints;
  final AssessmentReferralContext? referralContext;

  @override
  ConsumerState<SelectDoctorForAppointmentScreen> createState() =>
      _SelectDoctorForAppointmentScreenState();
}

class _SelectDoctorForAppointmentScreenState
    extends ConsumerState<SelectDoctorForAppointmentScreen> {
  bool _showAllDoctorsFallback = false;
  late final AssessmentReferralTrackingService _trackingService;
  bool _didAdvance = false;

  @override
  void initState() {
    super.initState();
    _trackingService = AssessmentReferralTrackingService.maybeCreate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final referralContext = widget.referralContext;
      if (referralContext == null) {
        return;
      }

      unawaited(
        _trackingService.logEvent(
          context: referralContext,
          eventName: 'doctor_selection_viewed',
          stage: 'doctor_selection',
        ),
      );
    });
  }

  @override
  void dispose() {
    final referralContext = widget.referralContext;
    if (referralContext != null && !_didAdvance) {
      unawaited(
        _trackingService.logEvent(
          context: referralContext,
          eventName: 'referral_abandoned',
          stage: 'doctor_selection',
          status: 'abandoned',
        ),
      );
    }
    super.dispose();
  }

  String _normalize(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('ال', '')
        .replaceAll(RegExp(r'ه$'), 'ة')
        .toLowerCase();
  }

  List<String> _doctorSearchableFields(UserModel doctor) {
    return <String>[
      ...(doctor.specializations ?? const <String>[]),
      if (doctor.specialty != null && doctor.specialty!.trim().isNotEmpty)
        doctor.specialty!,
      if (doctor.clinicType != null && doctor.clinicType!.trim().isNotEmpty)
        doctor.clinicType!,
      if (doctor.clinicType != null && ClinicTypes.isValid(doctor.clinicType))
        ClinicTypes.arabicLabel(doctor.clinicType!),
      if (doctor.clinicType != null && ClinicTypes.isValid(doctor.clinicType))
        ClinicTypes.englishLabel(doctor.clinicType!),
    ];
  }

  bool _matchesReferralTarget(UserModel doctor) {
    if (widget.referralContext?.referralTargetKey !=
        AssessmentReferralContext.maleFertilityInfertilityProstateTargetKey) {
      return false;
    }

    if (doctor.clinicType == ClinicTypes.andrologyInfertilityProstate) {
      return true;
    }

    const targetFields = <String>[
      'طب الذكورة',
      'تأخر الإنجاب والعقم لدى الرجال',
      'تأخر الإنجاب',
      'العقم',
      'صحة البروستات',
      'البروستات',
      'عيادة الذكورة والعقم والبروستات',
      'andrology',
      'infertility',
      'prostate',
    ];

    final normalizedTargets = targetFields.map(_normalize).toList();
    return _doctorSearchableFields(
      doctor,
    ).map(_normalize).any((field) => normalizedTargets.any(field.contains));
  }

  List<UserModel> _filterDoctors(List<UserModel> doctors) {
    if (_showAllDoctorsFallback) {
      return doctors;
    }

    if (widget.referralContext?.referralTargetKey ==
        AssessmentReferralContext.maleFertilityInfertilityProstateTargetKey) {
      return doctors.where(_matchesReferralTarget).toList();
    }

    if (widget.specializationHints.isEmpty) {
      return doctors;
    }

    final normalizedHints = widget.specializationHints.map(_normalize).toList();

    return doctors.where((doctor) {
      final searchableFields = _doctorSearchableFields(doctor);

      return searchableFields.any((field) {
        final normalizedField = _normalize(field);
        return normalizedHints.any(normalizedField.contains);
      });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(doctorsListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'اختر الطبيب')),
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
        data: (doctors) {
          final displayedDoctors = _filterDoctors(doctors);

          return displayedDoctors.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
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
                          doctors.isEmpty
                              ? 'لا يوجد أطباء مسجلين حالياً'
                              : 'لا يوجد أطباء مطابقون لهذا التخصص حالياً',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          doctors.isEmpty
                              ? 'انتظر حتى يتم تسجيل أطباء جدد'
                              : 'يمكنك المحاولة لاحقاً أو عرض جميع الأطباء المتاحين.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        if (doctors.isNotEmpty && !_showAllDoctorsFallback) ...[
                          const SizedBox(height: 20),
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _showAllDoctorsFallback = true;
                              });
                            },
                            child: const Text('عرض جميع الأطباء المتاحين'),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: displayedDoctors.length,
                  itemBuilder: (context, index) {
                    final doctor = displayedDoctors[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () async {
                          final navigator = Navigator.of(context);
                          final referralContext = widget.referralContext;
                          if (referralContext != null) {
                            _didAdvance = true;
                            await _trackingService.logEvent(
                              context: referralContext,
                              eventName: 'doctor_selected',
                              stage: 'doctor_selection',
                              metadata: {
                                'doctorId': doctor.id,
                                'doctorName': doctor.fullName,
                              },
                            );
                          }
                          if (!mounted) {
                            return;
                          }

                          await navigator.push<void>(
                            MaterialPageRoute<void>(
                              builder: (context) => BookAppointmentScreen(
                                doctor: doctor,
                                isVideoConsultation: false,
                                referralContext: widget.referralContext,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: DoctorCard(doctor: doctor),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
