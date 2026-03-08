import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/shared/models/emr_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// [EmrRecordView] is a shared widget used to display Sexology EMR records
/// in a structured, read-only format for both patients and admins.
///
/// [EmrRecordView] هو ويدجت مشترك يستخدم لعرض سجلات أمراض الذكورة
/// بتنسيق منظم وسهل القراءة للقراءة فقط لكل من المرضى والمسؤولين.
class EmrRecordView extends StatelessWidget {
  /// Creates an [EmrRecordView].
  ///
  /// [record] is the [EMRModel] containing sexology data.
  /// [isReadOnly] hide interactive or editing elements (if any).
  const EmrRecordView({
    required this.record,
    this.isReadOnly = true,
    super.key,
  });

  /// The EMR data to display.
  final EMRModel record;

  /// Whether the view is read-only (e.g., for Admin dashboard).
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _buildHeader(context),
        const SizedBox(height: 16),
        _buildSectionHeader('I. Sexual Function Assessment'),
        _buildItem('Libido Level', record.libidoLevel),
        _buildItem('Onset Difficulty', record.onsetOfErectileDifficulty),
        _buildItem('Frequency', record.frequencyOfIntercourseAttempts),
        _buildItem('Penetration (%)', record.penetrationSuccess),
        _buildItem('Rigidity (1-5)', record.erectionRigidity),
        _buildItem('Nocturnal/Morning', record.nocturnalMorningErections),
        _buildItem('Ejaculation', record.ejaculatoryFunction),
        _buildItem('Orgasmic Satisfaction', record.orgasmicSatisfaction),
        _buildItem('Partner Satisfaction', record.partnerSatisfaction),
        _buildItem('Penile Size Concern', record.concernAboutPenileSize),
        _buildItem(
          'Partner Satisfaction Opinion',
          record.opinionAboutPartnerSatisfaction,
        ),

        _buildSectionHeader('II. Past Sexual History'),
        _buildItem(
          'Past Homosexual',
          record.pastHomosexualExperience.toString(),
          isBool: true,
        ),
        _buildItem(
          'Interested Homosexual',
          record.interestedInHomosexuality.toString(),
          isBool: true,
        ),
        _buildItem(
          'Childhood Trauma',
          record.historyOfSexualTraumaInChildhood.toString(),
          isBool: true,
        ),
        _buildItem(
          'Porno Addiction',
          record.historyOfPornoAddiction.toString(),
          isBool: true,
        ),
        _buildItem(
          'Masturbation Addiction',
          record.historyOfMasturbationAddiction.toString(),
          isBool: true,
        ),
        _buildItem(
          'Illegal Sex',
          record.historyOfIllegalSex.toString(),
          isBool: true,
        ),
        _buildItem('STDs', record.historyOfHavingSTDs.toString(), isBool: true),
        _buildItem(
          'Penile Trauma',
          record.historyOfPenileTrauma.toString(),
          isBool: true,
        ),
        _buildItem(
          'Medication History',
          record.historyMedication.toString(),
          isBool: true,
        ),
        _buildItem(
          'Curvature',
          record.historyOfPenileCurvature.toString(),
          isBool: true,
        ),

        const SizedBox(height: 8),
        _buildSubSectionHeader('Medications'),
        _buildItem('PDE5-I', record.pde5I),
        _buildItem('Supplements', record.supplements),
        _buildItem('Hormones', record.hormones),

        _buildSubSectionHeader('Previous Investigations'),
        _buildItem('Hormones', record.previousHormones),
        _buildItem('General Lab', record.previousGeneralLab),

        _buildSubSectionHeader('Radiology + ICI'),
        _buildItem('Duplex Penile Arteries', record.duplexPenileArteries),
        _buildItem('Testicular U/S', record.testicularUS),
        _buildItem('Penile U/S', record.penileUS),
        _buildItem('TRUS', record.trus),
        _buildItem('Abdominopelvic U/S', record.abdominopelvicUS),

        _buildSectionHeader('III. Infertility Evaluation'),
        _buildItem('Marriage Duration', record.durationOfMarriage),
        _buildItem('Wife Age', record.ageOfWife),
        _buildItem(
          'Multiple Wives',
          record.multipleWives.toString(),
          isBool: true,
        ),
        _buildItem('Infertility Duration', record.durationOfInfertility),
        _buildItem('Type', record.infertilityType),
        _buildItem(
          'Previous Conceptions',
          record.previousConceptions.toString(),
          isBool: true,
        ),
        _buildItem(
          'Varicocele/Genital Surgery',
          record.historyOfVaricoceleGenitalSurgery,
        ),
        _buildItem('Semen Analysis', record.semenAnalysisSummary),
        _buildItem('Hormonal Profile', record.hormonalProfile),
        _buildItem('Genetic Tests', record.geneticOtherTests),

        _buildSectionHeader('IV. Prostatic Symptoms'),
        _buildItem('Frequency', record.urinaryFrequency),
        _buildItem('Stream', record.stream),
        _buildItem('Nocturia', record.nocturia),
        _buildItem(
          'Straining',
          record.strainingOrIncompleteEmptying.toString(),
          isBool: true,
        ),
        _buildItem('PSA', record.psaLevelDate),
        _buildItem('TRUS', record.trusProstatic),
        _buildItem('Uroflowmetry', record.uroflowmetry),

        _buildSectionHeader('V. Physical Examination'),
        _buildItem('General/BMI', record.generalAppearanceBMI),
        _buildItem('Genital Exam', record.genitalExamination),
        _buildItem('Testicular', record.testicularSizeConsistency),
        _buildItem('Epididymis/Vas', record.epididymisVas),
        _buildItem('DRE', record.digitalRectalExamination),

        _buildSectionHeader('VI. Impression & Plan'),
        _buildItem('Impression', record.impressionDiagnosis),
        _buildItem('Recommended Inv.', record.recommendedInvestigations),
        _buildItem('Treatment Plan', record.initialTreatmentPlan),
        _buildItem('Follow-up', record.followUpInterval),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Sexology EMR',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          DateFormat('yyyy/MM/dd').format(record.createdAt),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
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
        const Divider(thickness: 1.5, color: AppColors.primary),
      ],
    ),
  );

  Widget _buildSubSectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 8),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        decoration: TextDecoration.underline,
      ),
    ),
  );

  Widget _buildItem(String label, String value, {bool isBool = false}) {
    if ((value.isEmpty || value == 'false') && !isBool) {
      return const SizedBox.shrink();
    }

    if (isBool) {
      if (value == 'true') {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
