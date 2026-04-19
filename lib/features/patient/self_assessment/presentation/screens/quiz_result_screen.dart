import 'dart:async';

import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/services/assessment_referral_tracking_service.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/patient/appointments/presentation/screens/select_doctor_for_appointment_screen.dart';
import 'package:elajtech/features/patient/navigation/presentation/screens/patient_main_screen.dart';
import 'package:elajtech/features/patient/self_assessment/data/models/quiz_models.dart';
import 'package:elajtech/features/patient/self_assessment/data/quiz_data.dart';
import 'package:elajtech/shared/providers/registered_doctors_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class QuizResultScreen extends ConsumerWidget {
  const QuizResultScreen({
    required this.quiz,
    required this.answers,
    super.key,
  });
  final QuizModel quiz;
  final Map<int, int> answers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get result based on score strategy
    final results = QuizData.getResults(quiz.id, answers);
    final result = results.isNotEmpty
        ? results.first
        : const QuizResultModel(
            score: 0,
            interpretation: 'نتيجة غير متاحة',
            advice:
                'تعذر إظهار نتيجة هذا التقييم حالياً. يمكنك المحاولة مرة أخرى أو حجز موعد لمناقشة الأعراض مع الطبيب.',
            colorValue: 0xFF607D8B,
          );
    final color = Color(result.colorValue);
    final standardRecommendation = QuizData.getStandardRecommendation(quiz.id);
    final disclaimer = QuizData.getDisclaimer(quiz.id);
    final isStandardRecommendationQuiz =
        quiz.id == QuizData.maleFertilityDelayQuizId ||
        quiz.id == QuizData.stiExposureRiskQuizId;

    // Score to display in the circle
    final displayScore = result.score;
    final maxScore = quiz.questions.fold<int>(
      0,
      (sum, question) =>
          sum +
          question.options
              .map((option) => option.score)
              .reduce((a, b) => a > b ? a : b),
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Score Indicator
              Center(
                child: isStandardRecommendationQuiz
                    ? Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.health_and_safety_outlined,
                          size: 72,
                          color: color,
                        ),
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(
                              value: displayScore / maxScore.toDouble(),
                              strokeWidth: 12,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$displayScore',
                                style: Theme.of(context).textTheme.displayMedium
                                    ?.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'من $maxScore',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 40),

              // Result Title
              Text(
                result.interpretation,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Result Advice
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, size: 32, color: color),
                    const SizedBox(height: 16),
                    Text(
                      result.advice,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 30,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      standardRecommendation,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _EducationCard(
                quizId: quiz.id,
                color: color,
              ),

              const SizedBox(height: 40),

              // Actions
              // Show booking button if score is high enough
              // For PE: >= 9. For IPSS: >= 8 (Moderate/Severe)
              if (_shouldShowBookingButton(quiz.id, displayScore)) ...[
                if (quiz.id == QuizData.stiExposureRiskQuizId) ...[
                  Text(
                    QuizData.getBookingSupportingText(quiz.id, answers),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryLight,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],
                ElevatedButton(
                  onPressed: () async {
                    String? currentUserId;
                    try {
                      currentUserId = ref.read(authProvider).user?.id;
                    } on Object catch (_) {
                      currentUserId = null;
                    }

                    final referralContext = AssessmentReferralContext(
                      referralSessionId: const Uuid().v4(),
                      assessmentId: quiz.id,
                      assessmentTitle: quiz.title,
                      resultBand: QuizData.getResultBand(quiz.id, answers),
                      rawScore: QuizData.getRawScore(answers),
                      referralTargetKey:
                          quiz.id == QuizData.stiExposureRiskQuizId
                          ? AssessmentReferralContext
                                .maleFertilityInfertilityProstateTargetKey
                          : 'general_specialist',
                      completedAt: DateTime.now(),
                      sourceScreen: 'quiz_result_screen',
                      patientId: currentUserId,
                      specializationHints: QuizData.getSpecializationHints(
                        quiz.id,
                      ),
                    );

                    final destination =
                        quiz.id == QuizData.stiExposureRiskQuizId
                        ? SpecialistReferralLandingScreen(
                            referralContext: referralContext,
                          )
                        : SelectDoctorForAppointmentScreen(
                            title: QuizData.getBookingScreenTitle(quiz.id),
                            specializationHints:
                                referralContext.specializationHints,
                            referralContext: referralContext,
                          );

                    await Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => destination,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    quiz.id == QuizData.stiExposureRiskQuizId
                        ? 'احجز موعداً مع أطباء الذكورة والعقم والبروستات'
                        : QuizData.getBookingTitle(quiz.id),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.privacy_tip_outlined,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        disclaimer,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryLight,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              OutlinedButton(
                onPressed: () async {
                  await Navigator.pushAndRemoveUntil<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const PatientMainScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'العودة للرئيسية',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _shouldShowBookingButton(String quizId, int score) {
    if (quizId == QuizData.maleFertilityDelayQuizId ||
        quizId == QuizData.stiExposureRiskQuizId) {
      return true;
    }

    if (quizId == QuizData.prematureEjaculationQuizId) {
      return score >= 9;
    } else if (quizId == QuizData.ipssQuizId) {
      return score >= 8; // Moderate or Severe
    } else if (quizId == QuizData.iief5QuizId) {
      return score < 22; // Anything less than 22 (Normal) needs attention
    } else if (quizId == QuizData.adamQuizId) {
      // For ADAM, logic is complex (Q1 or Q7 or >3 Yes).
      // Since we pass 'score' which is just the count, we need to pass answers to be accurate.
      // However, we calculated 'Interpretation' and 'Color' in QuizData based on the same logic.
      // If Color is Red (0xFFF44336), it's Positive.
      // Let's rely on the widget.answers to re-check specific questions if needed,
      // OR simpler: check if the calculated result suggests it.
      // But _shouldShowBookingButton currently only takes score.
      // Let's re-calculate logic here using widget.answers which is available in the class scope.

      final isQ1Yes = answers[1] == 1;
      final isQ7Yes = answers[7] == 1;
      final isMoreThan3Yes = score > 3;
      return isQ1Yes || isQ7Yes || isMoreThan3Yes;
    }
    return false;
  }
}

class _EducationCard extends StatelessWidget {
  const _EducationCard({required this.quizId, required this.color});

  final String quizId;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final points = switch (quizId) {
      QuizData.maleFertilityDelayQuizId => const [
        'قد تتأثر خصوبة الرجل بعوامل مثل نمط الحياة، بعض الأمراض المزمنة، الحرارة المرتفعة، أو نتائج تحليل السائل المنوي.',
        'يمكن للطبيب أن يحدد ما إذا كانت هناك حاجة لتحاليل إضافية أو مناقشة خيارات علاجية أو تعديل بعض العوامل القابلة للتحسين.',
      ],
      QuizData.stiExposureRiskQuizId => const [
        'بعض العدوى المنقولة جنسياً قد لا تسبب أعراضاً واضحة، لذلك قد تكون الفحوصات مهمة حتى عند غياب الأعراض الشديدة.',
        'الأعراض مثل الإفرازات أو التقرحات أو الحرقة قد تكون لها أسباب مختلفة، والطبيب هو الأقدر على تحديد الفحوصات المناسبة.',
      ],
      _ => const [
        'هذا التقييم يساعدك على فهم أعراضك بشكل أفضل، لكنه لا يغني عن التقييم الطبي المباشر عند الحاجة.',
      ],
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات مفيدة',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Icon(Icons.circle, size: 8, color: color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      point,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SpecialistReferralLandingScreen extends ConsumerStatefulWidget {
  const SpecialistReferralLandingScreen({
    required this.referralContext,
    super.key,
  });

  final AssessmentReferralContext referralContext;

  @override
  ConsumerState<SpecialistReferralLandingScreen> createState() =>
      _SpecialistReferralLandingScreenState();
}

class _SpecialistReferralLandingScreenState
    extends ConsumerState<SpecialistReferralLandingScreen> {
  late final AssessmentReferralTrackingService _trackingService;
  bool _didAdvance = false;

  @override
  void initState() {
    super.initState();
    _trackingService = AssessmentReferralTrackingService.maybeCreate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        _trackingService.logEvent(
          context: widget.referralContext,
          eventName: 'landing_viewed',
          stage: 'landing',
        ),
      );
    });
  }

  @override
  void dispose() {
    if (!_didAdvance) {
      unawaited(
        _trackingService.logEvent(
          context: widget.referralContext,
          eventName: 'referral_abandoned',
          stage: 'landing',
          status: 'abandoned',
        ),
      );
    }
    super.dispose();
  }

  String _supportingCopy() {
    if (widget.referralContext.isHighPriority) {
      return 'نوصي بحجز موعد مع الطبيب المختص في أقرب فرصة مناسبة، خاصة إذا كانت الأعراض مستمرة أو مزعجة.';
    }

    if (widget.referralContext.isMediumPriority) {
      return 'توجد عوامل أو أعراض تستحق التقييم الطبي، ويمكن للطبيب تحديد الفحوصات والخطوات المناسبة لك.';
    }

    return 'إذا رغبت في الاطمئنان أو مناقشة المخاطر بشكل سري، يمكنك المتابعة لحجز موعد مع الطبيب المختص.';
  }

  String _resultBandLabel(String resultBand) {
    switch (resultBand) {
      case 'high':
        return 'أولوية مرتفعة';
      case 'medium':
        return 'أولوية متوسطة';
      default:
        return 'أولوية منخفضة';
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(doctorsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('التوصية الطبية المناسبة')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'حجز سري مع أطباء الذكورة والعقم والبروستات',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _supportingCopy(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.referralContext.assessmentTitle,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'مستوى التوصية: ${_resultBandLabel(widget.referralContext.resultBand)}',
                          ),
                          Text(
                            'درجة التقييم: ${widget.referralContext.rawScore}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: AppColors.textSecondaryLight,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'يتم استخدام نتيجة التقييم لتوجيهك إلى التخصص المناسب فقط. لن يتم عرض تفاصيل إجاباتك داخل شاشة الحجز.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              doctorsAsync.when(
                loading: () => const _ReferralStatusCard(
                  icon: Icons.hourglass_top,
                  title: 'جار التحقق من توفر الأطباء',
                  description: 'نبحث عن أطباء مناسبين لهذا المسار الطبي الآن.',
                  color: AppColors.primary,
                ),
                error: (error, stack) => const _ReferralStatusCard(
                  icon: Icons.info_outline,
                  title: 'تعذر التحقق من التوفر الآن',
                  description:
                      'يمكنك المتابعة لعرض الأطباء المتاحين أو إعادة المحاولة لاحقاً.',
                  color: AppColors.warning,
                ),
                data: (doctors) {
                  final matchedCount = doctors.where((doctor) {
                    final fields = <String>[
                      ...(doctor.specializations ?? const <String>[]),
                      if (doctor.specialty != null &&
                          doctor.specialty!.trim().isNotEmpty)
                        doctor.specialty!,
                      if (doctor.clinicType != null &&
                          doctor.clinicType!.trim().isNotEmpty)
                        doctor.clinicType!,
                    ].join(' ');

                    return doctor.clinicType ==
                            'andrology_infertility_prostate' ||
                        fields.contains('الذكورة') ||
                        fields.contains('العقم') ||
                        fields.contains('البروستات');
                  }).length;

                  if (matchedCount == 0) {
                    return const _ReferralStatusCard(
                      icon: Icons.person_search,
                      title: 'لا يوجد أطباء مطابقون حالياً',
                      description:
                          'يمكنك إعادة المحاولة لاحقاً أو عرض جميع الأطباء المتاحين إذا رغبت.',
                      color: AppColors.warning,
                    );
                  }

                  return _ReferralStatusCard(
                    icon: Icons.check_circle_outline,
                    title: 'تم العثور على $matchedCount طبيب مناسب',
                    description:
                        'سيتم توجيهك الآن إلى قائمة الأطباء المختصين بهذا المسار.',
                    color: AppColors.success,
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  _didAdvance = true;
                  await _trackingService.logEvent(
                    context: widget.referralContext,
                    eventName: 'continue_to_doctors',
                    stage: 'landing',
                  );
                  if (!mounted) {
                    return;
                  }
                  await navigator.push<void>(
                    MaterialPageRoute<void>(
                      builder: (context) => SelectDoctorForAppointmentScreen(
                        title: 'أطباء الذكورة والعقم والبروستات',
                        specializationHints:
                            widget.referralContext.specializationHints,
                        referralContext: widget.referralContext,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_month_outlined),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                label: const Text(
                  'المتابعة إلى حجز الموعد',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('لاحقاً'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReferralStatusCard extends StatelessWidget {
  const _ReferralStatusCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: title,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
