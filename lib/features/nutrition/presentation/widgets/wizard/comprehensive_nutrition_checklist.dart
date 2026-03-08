import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';

import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/constants/app_text_styles.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/nutrition/domain/entities/nutrition_emr_entity.dart';
import 'package:elajtech/features/nutrition/presentation/state/nutrition_state_providers.dart';

/// Comprehensive Nutrition Checklist Widget
///
/// A complete medical checklist organized into 8 clinical sections
/// following SOAP Notes and Nutrition Care Process standards.
///
/// **Features:**
/// - 36 checkbox items across 8 sections
/// - Real-time state management with Riverpod
/// - Expandable/collapsible sections with ExpansionTile
/// - Bilingual labels (English/Arabic)
/// - LTR layout for English text
/// - Responsive design with MediaQuery
/// - Professional medical UI/UX
///
/// **Sections:**
/// 1. Patient and Visit Basics (4 items)
/// 2. Anthropometric Measurements (5 items)
/// 3. Dietary Intake Assessment (4 items)
/// 4. Medical Conditions Review (6 items)
/// 5. Nutrition Focused Physical Findings (5 items)
/// 6. Biochemical Data Review (5 items)
/// 7. Nutrition Diagnosis (3 items)
/// 8. Intervention Plan (4 items)
class ComprehensiveNutritionChecklist extends ConsumerWidget {
  const ComprehensiveNutritionChecklist({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emrState = ref.watch(nutritionEMRNotifierProvider);
    final emr = emrState.emrOrNull;

    if (emr == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 16),

          // Divider
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 16),

          // Section 1: Patient and Visit Basics
          _buildSection1(context, ref, emr),
          const SizedBox(height: 12),

          // Section 2: Anthropometric Measurements
          _buildSection2(context, ref, emr),
          const SizedBox(height: 12),

          // Section 3: Dietary Intake Assessment
          _buildSection3(context, ref, emr),
          const SizedBox(height: 12),

          // Section 4: Medical Conditions Review
          _buildSection4(context, ref, emr),
          const SizedBox(height: 12),

          // Section 5: Nutrition Focused Physical Findings
          _buildSection5(context, ref, emr),
          const SizedBox(height: 12),

          // Section 6: Biochemical Data Review
          _buildSection6(context, ref, emr),
          const SizedBox(height: 12),

          // Section 7: Nutrition Diagnosis
          _buildSection7(context, ref, emr),
          const SizedBox(height: 12),

          // Section 8: Intervention Plan
          _buildSection8(context, ref, emr),
        ],
      ),
    );
  }

  /// Build Header
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.checklist_rtl,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Medical Checklist | القائمة الطبية',
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Complete all required items | أكمل جميع البنود المطلوبة',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Section 1: Patient and Visit Basics
  Widget _buildSection1(
    BuildContext context,
    WidgetRef ref,
    NutritionEMREntity emr,
  ) {
    return _buildExpansionSection(
      context: context,
      ref: ref,
      title: 'Patient and Visit Basics',
      subtitle: 'معلومات المريض والزيارة',
      icon: Icons.person_outline,
      items: [
        _ChecklistItem(
          fieldName: 'isIdentityVerified',
          title: 'Patient Identity Verified',
          subtitle: 'تم التحقق من هوية المريض',
          value: emr.isIdentityVerified,
        ),
        _ChecklistItem(
          fieldName: 'isConsentObtained',
          title: 'Informed Consent Obtained',
          subtitle: 'تم الحصول على الموافقة المستنيرة',
          value: emr.isConsentObtained,
        ),
        _ChecklistItem(
          fieldName: 'isReasonForVisitDocumented',
          title: 'Reason for Visit Documented',
          subtitle: 'تم توثيق سبب الزيارة',
          value: emr.isReasonForVisitDocumented,
        ),
        _ChecklistItem(
          fieldName: 'isDiagnosisReviewed',
          title: 'Diagnosis Reviewed',
          subtitle: 'تم مراجعة التشخيص',
          value: emr.isDiagnosisReviewed,
        ),
      ],
    );
  }

  /// Section 2: Anthropometric Measurements
  Widget _buildSection2(
    BuildContext context,
    WidgetRef ref,
    NutritionEMREntity emr,
  ) {
    return _buildExpansionSection(
      context: context,
      ref: ref,
      title: 'Anthropometric Measurements',
      subtitle: 'القياسات الجسمية',
      icon: Icons.straighten,
      items: [
        _ChecklistItem(
          fieldName: 'isWeightMeasured',
          title: 'Weight Measured',
          subtitle: 'تم قياس الوزن',
          value: emr.isWeightMeasured,
        ),
        _ChecklistItem(
          fieldName: 'isHeightMeasured',
          title: 'Height Measured',
          subtitle: 'تم قياس الطول',
          value: emr.isHeightMeasured,
        ),
        _ChecklistItem(
          fieldName: 'isBMICalculated',
          title: 'BMI Calculated',
          subtitle: 'تم حساب مؤشر كتلة الجسم',
          value: emr.isBMICalculated,
        ),
        _ChecklistItem(
          fieldName: 'isWaistCircumferenceMeasured',
          title: 'Waist Circumference Measured',
          subtitle: 'تم قياس محيط الخصر',
          value: emr.isWaistCircumferenceMeasured,
        ),
        _ChecklistItem(
          fieldName: 'isRecentWeightChangeDocumented',
          title: 'Recent Weight Change Documented',
          subtitle: 'تم توثيق التغيرات الوزنية الأخيرة',
          value: emr.isRecentWeightChangeDocumented,
        ),
      ],
    );
  }

  /// Section 3: Dietary Intake Assessment
  Widget _buildSection3(
    BuildContext context,
    WidgetRef ref,
    NutritionEMREntity emr,
  ) {
    return _buildExpansionSection(
      context: context,
      ref: ref,
      title: 'Dietary Intake Assessment',
      subtitle: 'تقييم المدخول الغذائي',
      icon: Icons.restaurant,
      items: [
        _ChecklistItem(
          fieldName: 'is24HourRecallCompleted',
          title: '24-Hour Dietary Recall Completed',
          subtitle: 'استدعاء الطعام خلال 24 ساعة',
          value: emr.is24HourRecallCompleted,
        ),
        _ChecklistItem(
          fieldName: 'isFoodFrequencyAssessed',
          title: 'Food Frequency Assessed',
          subtitle: 'تم تقييم تكرار الطعام',
          value: emr.isFoodFrequencyAssessed,
        ),
        _ChecklistItem(
          fieldName: 'isAllergiesIntolerancesChecked',
          title: 'Allergies & Intolerances Checked',
          subtitle: 'فحص الحساسيات وعدم التحمل الغذائي',
          value: emr.isAllergiesIntolerancesChecked,
        ),
        _ChecklistItem(
          fieldName: 'isSupplementsDocumented',
          title: 'Dietary Supplements Documented',
          subtitle: 'تم توثيق المكملات الغذائية',
          value: emr.isSupplementsDocumented,
        ),
      ],
    );
  }

  /// Section 4: Medical Conditions Review
  Widget _buildSection4(
    BuildContext context,
    WidgetRef ref,
    NutritionEMREntity emr,
  ) {
    return _buildExpansionSection(
      context: context,
      ref: ref,
      title: 'Medical Conditions Review',
      subtitle: 'مراجعة الحالات الطبية',
      icon: Icons.medical_services_outlined,
      items: [
        _ChecklistItem(
          fieldName: 'isDiabetesAssessed',
          title: 'Diabetes Mellitus Assessed',
          subtitle: 'تم تقييم مرض السكري',
          value: emr.isDiabetesAssessed,
        ),
        _ChecklistItem(
          fieldName: 'isHypertensionAssessed',
          title: 'Hypertension Assessed',
          subtitle: 'تم تقييم ارتفاع ضغط الدم',
          value: emr.isHypertensionAssessed,
        ),
        _ChecklistItem(
          fieldName: 'isDyslipidemiaAssessed',
          title: 'Dyslipidemia Assessed',
          subtitle: 'تم تقييم اضطرابات الدهون',
          value: emr.isDyslipidemiaAssessed,
        ),
        _ChecklistItem(
          fieldName: 'isObesityAssessed',
          title: 'Obesity Assessed',
          subtitle: 'تم تقييم السمنة',
          value: emr.isObesityAssessed,
        ),
        _ChecklistItem(
          fieldName: 'isCKDAssessed',
          title: 'Chronic Kidney Disease Assessed',
          subtitle: 'تم تقييم القصور الكلوي المزمن',
          value: emr.isCKDAssessed,
        ),
        _ChecklistItem(
          fieldName: 'isGIDisordersAssessed',
          title: 'GI Disorders Assessed',
          subtitle: 'تم تقييم اضطرابات الجهاز الهضمي',
          value: emr.isGIDisordersAssessed,
        ),
      ],
    );
  }

  /// Section 5: Nutrition Focused Physical Findings
  Widget _buildSection5(
    BuildContext context,
    WidgetRef ref,
    NutritionEMREntity emr,
  ) {
    return _buildExpansionSection(
      context: context,
      ref: ref,
      title: 'Nutrition Focused Physical Findings',
      subtitle: 'الفحوصات الجسدية المرتبطة بالتغذية',
      icon: Icons.visibility_outlined,
      items: [
        _ChecklistItem(
          fieldName: 'isMuscleWastingAssessed',
          title: 'Muscle Wasting Assessed',
          subtitle: 'تم تقييم فقدان الكتلة العضلية',
          value: emr.isMuscleWastingAssessed,
        ),
        _ChecklistItem(
          fieldName: 'isFatLossAssessed',
          title: 'Fat Loss/Gain Assessed',
          subtitle: 'تم تقييم فقدان أو زيادة الدهون',
          value: emr.isFatLossAssessed,
        ),
        _ChecklistItem(
          fieldName: 'isEdemaAssessed',
          title: 'Edema Assessed',
          subtitle: 'تم تقييم الوذمة',
          value: emr.isEdemaAssessed,
        ),
        _ChecklistItem(
          fieldName: 'isAppetiteAssessed',
          title: 'Appetite Level Assessed',
          subtitle: 'تم تقييم مستوى الشهية',
          value: emr.isAppetiteAssessed,
        ),
        _ChecklistItem(
          fieldName: 'isChewingSwallowingAssessed',
          title: 'Chewing/Swallowing Difficulties Assessed',
          subtitle: 'تم تقييم مشاكل المضغ والبلع',
          value: emr.isChewingSwallowingAssessed,
        ),
      ],
    );
  }

  /// Section 6: Biochemical Data Review
  Widget _buildSection6(
    BuildContext context,
    WidgetRef ref,
    NutritionEMREntity emr,
  ) {
    return _buildExpansionSection(
      context: context,
      ref: ref,
      title: 'Biochemical Data Review',
      subtitle: 'مراجعة البيانات الكيميائية الحيوية',
      icon: Icons.science_outlined,
      items: [
        _ChecklistItem(
          fieldName: 'isGlucoseA1cReviewed',
          title: 'Blood Glucose & HbA1c Reviewed',
          subtitle: 'تم مراجعة سكر الدم والسكر التراكمي',
          value: emr.isGlucoseA1cReviewed,
        ),
        _ChecklistItem(
          fieldName: 'isLipidProfileReviewed',
          title: 'Lipid Profile Reviewed',
          subtitle: 'تم مراجعة ملف الدهون',
          value: emr.isLipidProfileReviewed,
        ),
        _ChecklistItem(
          fieldName: 'isElectrolytesReviewed',
          title: 'Electrolytes Reviewed',
          subtitle: 'تم مراجعة الكهارل',
          value: emr.isElectrolytesReviewed,
        ),
        _ChecklistItem(
          fieldName: 'isRenalFunctionReviewed',
          title: 'Renal Function Reviewed',
          subtitle: 'تم مراجعة وظائف الكلى',
          value: emr.isRenalFunctionReviewed,
        ),
        _ChecklistItem(
          fieldName: 'isMicronutrientsReviewed',
          title: 'Micronutrients Reviewed',
          subtitle: 'تم مراجعة المغذيات الدقيقة',
          value: emr.isMicronutrientsReviewed,
        ),
      ],
    );
  }

  /// Section 7: Nutrition Diagnosis
  Widget _buildSection7(
    BuildContext context,
    WidgetRef ref,
    NutritionEMREntity emr,
  ) {
    return _buildExpansionSection(
      context: context,
      ref: ref,
      title: 'Nutrition Diagnosis',
      subtitle: 'التشخيص الغذائي',
      icon: Icons.assignment_outlined,
      items: [
        _ChecklistItem(
          fieldName: 'isInadequateIntakeDiagnosed',
          title: 'Inadequate Intake Diagnosed',
          subtitle: 'تم تشخيص النقص الغذائي',
          value: emr.isInadequateIntakeDiagnosed,
        ),
        _ChecklistItem(
          fieldName: 'isExcessiveIntakeDiagnosed',
          title: 'Excessive Intake Diagnosed',
          subtitle: 'تم تشخيص الإفراط الغذائي',
          value: emr.isExcessiveIntakeDiagnosed,
        ),
        _ChecklistItem(
          fieldName: 'isFoodKnowledgeDeficitIdentified',
          title: 'Food/Nutrition Knowledge Deficit',
          subtitle: 'تم تحديد نقص المعرفة الغذائية',
          value: emr.isFoodKnowledgeDeficitIdentified,
        ),
      ],
    );
  }

  /// Section 8: Intervention Plan
  Widget _buildSection8(
    BuildContext context,
    WidgetRef ref,
    NutritionEMREntity emr,
  ) {
    return _buildExpansionSection(
      context: context,
      ref: ref,
      title: 'Intervention Plan',
      subtitle: 'خطة التدخل',
      icon: Icons.local_hospital_outlined,
      items: [
        _ChecklistItem(
          fieldName: 'isCaloriePrescriptionSet',
          title: 'Calorie Prescription Set',
          subtitle: 'تم تحديد السعرات الحرارية',
          value: emr.isCaloriePrescriptionSet,
        ),
        _ChecklistItem(
          fieldName: 'isMacronutrientDistributionPlanned',
          title: 'Macronutrient Distribution Planned',
          subtitle: 'تم تحديد توزيع المغذيات الكبرى',
          value: emr.isMacronutrientDistributionPlanned,
        ),
        _ChecklistItem(
          fieldName: 'isEducationProvided',
          title: 'Nutrition Education Provided',
          subtitle: 'تم تقديم التثقيف الغذائي',
          value: emr.isEducationProvided,
        ),
        _ChecklistItem(
          fieldName: 'isFollowUpPlanEstablished',
          title: 'Follow-up Plan Established',
          subtitle: 'تم وضع خطة المتابعة',
          value: emr.isFollowUpPlanEstablished,
        ),
      ],
    );
  }

  /// Build Expansion Section with Checkboxes
  Widget _buildExpansionSection({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<_ChecklistItem> items,
  }) {
    // Calculate section completion
    final completedCount = items.where((item) => item.value).length;
    final totalCount = items.length;
    final percentage = (completedCount / totalCount * 100).toInt();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: percentage == 100
                    ? Colors.green.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: percentage == 100 ? Colors.green : AppColors.primary,
                size: 20,
              ),
            ),
            title: Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: AppColors.borderLight,
                  color: percentage == 100 ? Colors.green : AppColors.primary,
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedCount of $totalCount completed ($percentage%)',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondaryLight,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            children: [
              const Divider(height: 1),
              ...items.map(
                (item) => _buildCheckboxTile(
                  context: context,
                  ref: ref,
                  item: item,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build Individual Checkbox Tile
  Widget _buildCheckboxTile({
    required BuildContext context,
    required WidgetRef ref,
    required _ChecklistItem item,
  }) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        value: item.value,
        onChanged: (bool? newValue) {
          if (newValue != null) {
            final user = ref.read(authProvider).user;
            if (user == null) return;

            final notifier = ref.read(nutritionEMRNotifierProvider.notifier);
            notifier.updateField(
              fieldName: item.fieldName,
              value: newValue,
              userId: user.id,
              userName: user.fullName,
            );
          }
        },
        title: Text(
          item.title,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        subtitle: Text(
          item.subtitle,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
        activeColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
      ),
    );
  }
}

/// Internal class to represent checklist items
class _ChecklistItem {
  const _ChecklistItem({
    required this.fieldName,
    required this.title,
    required this.subtitle,
    required this.value,
  });
  final String fieldName;
  final String title;
  final String subtitle;
  final bool value;
}
