import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/constants/specialty_constants.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/doctor/medical_records/data/repositories/physiotherapy_emr_repository.dart';
import 'package:elajtech/features/doctor/medical_records/presentation/widgets/physiotherapy_emr_tab.dart';
import 'package:elajtech/features/emr/domain/repositories/emr_repository.dart';
import 'package:elajtech/features/emr/domain/repositories/nutrition_emr_repository.dart';
import 'package:elajtech/shared/models/emr_model.dart';
import 'package:elajtech/shared/models/nutrition_emr_model.dart';
import 'package:elajtech/shared/models/nutrition_questions.dart';
import 'package:elajtech/shared/widgets/smart_text_form_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

class AddEMRScreen extends ConsumerStatefulWidget {
  const AddEMRScreen({
    required this.patientId,
    required this.patientName,
    required this.appointmentId,
    super.key,
  });
  final String patientId;
  final String patientName;
  final String appointmentId;

  @override
  ConsumerState<AddEMRScreen> createState() => _AddEMRScreenState();
}

class _AddEMRScreenState extends ConsumerState<AddEMRScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<PhysiotherapyEMRTabState> _physiotherapyTabKey =
      GlobalKey<PhysiotherapyEMRTabState>();
  bool _isLoading = false;

  // ═════════════════════════════════════════════════════════════════════════
  // SPECIALTY DETECTION WITH FUZZY MATCHING
  // Uses SpecialtyConstants for accurate detection of doctor specialties
  // ═════════════════════════════════════════════════════════════════════════

  /// Check if current doctor is a Physiotherapy specialist
  ///
  /// Uses fuzzy matching to handle variations in Firestore data
  bool get _isPhysiotherapyDoctor {
    final user = ref.read(authProvider).user;
    final specializations = user?.specializations;

    if (kDebugMode) {
      debugPrint('🔍 [EMR] Checking Physiotherapy specialty...');
      debugPrint(
        '   User specializations: ${specializations?.join(", ") ?? "null"}',
      );
    }

    final result = SpecialtyConstants.isPhysiotherapyDoctor(specializations);

    if (kDebugMode) {
      debugPrint('   Result: $result ${result ? "✅" : "❌"}');
    }

    return result;
  }

  /// Check if current doctor is a Nutrition specialist
  ///
  /// Uses fuzzy matching to handle variations in Firestore data
  bool get _isNutritionDoctor {
    final user = ref.read(authProvider).user;
    final specializations = user?.specializations;

    if (kDebugMode) {
      debugPrint('🔍 [EMR] Checking Nutrition specialty...');
      debugPrint(
        '   User specializations: ${specializations?.join(", ") ?? "null"}',
      );
    }

    final result = SpecialtyConstants.isNutritionDoctor(specializations);

    if (kDebugMode) {
      debugPrint('   Result: $result ${result ? "✅" : "❌"}');
    }

    return result;
  }

  /// Check if current doctor is an Internal Medicine specialist
  ///
  /// Uses fuzzy matching to handle variations in Firestore data
  bool get _isInternalMedicineDoctor {
    final user = ref.read(authProvider).user;
    final specializations = user?.specializations;

    if (kDebugMode) {
      debugPrint('🔍 [EMR] Checking Internal Medicine specialty...');
      debugPrint(
        '   User specializations: ${specializations?.join(", ") ?? "null"}',
      );
    }

    final result = SpecialtyConstants.isInternalMedicineDoctor(specializations);

    if (kDebugMode) {
      debugPrint('   Result: $result ${result ? "✅" : "❌"}');
    }

    return result;
  }

  // I. Sexual Function Assessment
  String? _libidoLevel;
  String? _onsetOfErectileDifficulty;
  final TextEditingController _frequencyOfIntercourseController =
      TextEditingController();
  final TextEditingController _penetrationSuccessController =
      TextEditingController();
  String? _erectionRigidity;
  String? _nocturnalMorningErections;
  String? _ejaculatoryFunction;
  String? _orgasmicSatisfaction;
  String? _partnerSatisfaction;
  String? _concernAboutPenileSize;
  String? _opinionAboutPartnerSatisfaction;

  // II. Past Sexual History
  bool? _pastHomosexualExperience;
  bool? _interestedInHomosexuality;
  bool? _historyOfSexualTraumaInChildhood;
  bool? _historyOfPornoAddiction;
  bool? _historyOfMasturbationAddiction;
  bool? _historyOfIllegalSex;
  bool? _historyOfHavingSTDs;
  bool? _historyOfPenileTrauma;
  bool? _historyMedication;
  bool? _historyOfPenileCurvature;

  // Medications & Investigations (New Schema)
  final TextEditingController _pde5IController = TextEditingController();
  final TextEditingController _supplementsController = TextEditingController();
  final TextEditingController _hormonesController = TextEditingController();

  // History of Previous Investigations (Split)
  final TextEditingController _prevHormonesController = TextEditingController();
  final TextEditingController _prevGeneralLabController =
      TextEditingController();

  // Radiology + and/or ICI (Split)
  final TextEditingController _duplexController = TextEditingController();
  final TextEditingController _testicularUSController = TextEditingController();
  final TextEditingController _penileUSController = TextEditingController();
  final TextEditingController _trusController = TextEditingController();
  final TextEditingController _abdominopelvicUSController =
      TextEditingController();

  // III. Infertility Evaluation
  final TextEditingController _durationOfMarriageController =
      TextEditingController();
  final TextEditingController _ageOfWifeController = TextEditingController();
  bool? _multipleWives;
  final TextEditingController _durationOfInfertilityController =
      TextEditingController();
  String? _infertilityType;
  bool? _previousConceptions;
  final TextEditingController _historyOfVaricoceleController =
      TextEditingController();
  final TextEditingController _semenAnalysisSummaryController =
      TextEditingController();
  final TextEditingController _hormonalProfileController =
      TextEditingController();
  final TextEditingController _geneticTestsController = TextEditingController();

  // IV. Prostatic Symptoms
  final TextEditingController _urinaryFrequencyController =
      TextEditingController();
  String? _stream;
  final TextEditingController _nocturiaController = TextEditingController();
  bool? _straining;
  final TextEditingController _psaLevelController = TextEditingController();
  final TextEditingController _trusProstaticController =
      TextEditingController();
  final TextEditingController _uroflowmetryController = TextEditingController();

  // V. Physical Examination
  final TextEditingController _generalAppearanceController =
      TextEditingController();
  final TextEditingController _genitalExamController = TextEditingController();
  final TextEditingController _testicularSizeController =
      TextEditingController();
  final TextEditingController _epididymisVasController =
      TextEditingController();
  final TextEditingController _dreController = TextEditingController();

  // VI. Impression & Management Plan
  final TextEditingController _impressionController = TextEditingController();
  final TextEditingController _investigationsController =
      TextEditingController();
  final TextEditingController _treatmentPlanController =
      TextEditingController();
  final TextEditingController _followUpController = TextEditingController();

  // Nutrition EMR Data
  final Map<String, List<String>> _patientVisitBasicsSelections =
      <String, List<String>>{};
  final Map<String, List<String>> _anthropometricsSelections =
      <String, List<String>>{};
  final Map<String, List<String>> _dietaryIntakeSelections =
      <String, List<String>>{};
  final Map<String, List<String>> _medicalConditionsSelections =
      <String, List<String>>{};
  final Map<String, List<String>> _physicalFindingsSelections =
      <String, List<String>>{};
  final Map<String, List<String>> _biochemicalDataSelections =
      <String, List<String>>{};
  final Map<String, List<String>> _nutritionDiagnosisSelections =
      <String, List<String>>{};
  final Map<String, List<String>> _interventionPlanSelections =
      <String, List<String>>{};
  final TextEditingController _nutritionPrimaryDiagnosisController =
      TextEditingController();
  final TextEditingController _nutritionManagementPlanController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    // ═══════════════════════════════════════════════════════════════════════
    // SPECIALTY DETECTION LOGGING (Debug Mode Only)
    // Logs doctor information and specialty detection results
    // ═════════════════════════════════════════════════════════════════════════════
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final user = ref.read(authProvider).user;

        debugPrint('\n════════════════════════════════════════════════════');
        debugPrint('📋 EMR Screen Initialized');
        debugPrint('──────────────────────────────────────────────────────');
        debugPrint('👨‍⚕️ Doctor Information:');
        debugPrint('   ID: ${user?.id ?? "null"}');
        debugPrint('   Name: ${user?.fullName ?? "null"}');
        debugPrint(
          '   Specializations: ${user?.specializations?.join(", ") ?? "null"}',
        );
        debugPrint('──────────────────────────────────────────────────────');
        debugPrint('🏥 Specialty Detection Results:');
        debugPrint(
          '   Physiotherapy: $_isPhysiotherapyDoctor ${_isPhysiotherapyDoctor ? "✅" : "❌"}',
        );
        debugPrint(
          '   Nutrition: $_isNutritionDoctor ${_isNutritionDoctor ? "✅" : "❌"}',
        );
        debugPrint(
          '   Internal Medicine: $_isInternalMedicineDoctor ${_isInternalMedicineDoctor ? "✅" : "❌"}',
        );
        debugPrint('──────────────────────────────────────────────────────');
        debugPrint('📊 Expected UI Components:');
        if (_isPhysiotherapyDoctor) {
          debugPrint('   ✅ Physiotherapy tab WILL be displayed');
        }
        if (_isNutritionDoctor) {
          debugPrint('   ✅ Nutrition tab WILL be displayed');
        }
        if (!_isPhysiotherapyDoctor &&
            !_isNutritionDoctor &&
            !_isInternalMedicineDoctor) {
          debugPrint('   ⚠️ WARNING: No specialty-specific tabs detected!');
          debugPrint('   Only default Andrology EMR will be shown');
        }
        debugPrint('══════════════════════════════════════════════════\n');
      });
    }
  }

  @override
  void dispose() {
    _frequencyOfIntercourseController.dispose();
    _penetrationSuccessController.dispose();
    _pde5IController.dispose();
    _supplementsController.dispose();
    _hormonesController.dispose();
    _prevHormonesController.dispose();
    _prevGeneralLabController.dispose();
    _duplexController.dispose();
    _testicularUSController.dispose();
    _penileUSController.dispose();
    _trusController.dispose();
    _abdominopelvicUSController.dispose();
    _durationOfMarriageController.dispose();
    _ageOfWifeController.dispose();
    _durationOfInfertilityController.dispose();
    _historyOfVaricoceleController.dispose();
    _semenAnalysisSummaryController.dispose();
    _hormonalProfileController.dispose();
    _geneticTestsController.dispose();
    _urinaryFrequencyController.dispose();
    _nocturiaController.dispose();
    _psaLevelController.dispose();
    _trusProstaticController.dispose();
    _uroflowmetryController.dispose();
    _generalAppearanceController.dispose();
    _genitalExamController.dispose();
    _testicularSizeController.dispose();
    _epididymisVasController.dispose();
    _dreController.dispose();
    _impressionController.dispose();
    _investigationsController.dispose();
    _treatmentPlanController.dispose();
    _followUpController.dispose();
    _nutritionPrimaryDiagnosisController.dispose();
    _nutritionManagementPlanController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // ═════════════════════════════════════════════════════════════════════════
    // NULL SAFETY CHECK: Ensure user is authenticated before proceeding
    // ═════════════════════════════════════════════════════════════════════════
    final user = ref.read(authProvider).user;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يجب تسجيل الدخول أولاً')),
        );
        Navigator.pop(context);
      }
      return;
    }

    // Debug logging before save
    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════════════════');
      debugPrint('📋 [EMR] Starting Save Operation');
      debugPrint('───────────────────────────────────────────────────');
      debugPrint('👤 User Info:');
      debugPrint('   ID: ${user.id}');
      debugPrint('   Name: ${user.fullName}');
      debugPrint('   Type: ${user.userType}');
      debugPrint('📝 Patient Info:');
      debugPrint('   Patient ID: ${widget.patientId}');
      debugPrint('   Appointment ID: ${widget.appointmentId}');
      debugPrint('───────────────────────────────────────────────────');
      debugPrint('🏥 Specialty Detection:');
      debugPrint('   Physiotherapy: $_isPhysiotherapyDoctor');
      debugPrint('   Nutrition: $_isNutritionDoctor');
      debugPrint('═══════════════════════════════════════════════════');
    }

    setState(() => _isLoading = true);

    try {
      // ═════════════════════════════════════════════════════════════════════════
      // SPECIALTY-BASED EXECUTION PATHS (Mutually Exclusive)
      // Each specialty has its own validation and saving logic
      // ═════════════════════════════════════════════════════════════════════════

      if (_isPhysiotherapyDoctor) {
        // ═════════════════════════════════════════════════════════════════════════
        // PATH 1: PHYSIOTHERAPY DOCTOR
        // - Skip ALL Andrology/EMRModel code
        // - Only save PhysiotherapyEMR (no form validation needed)
        // ═════════════════════════════════════════════════════════════════════════
        if (kDebugMode) {
          debugPrint('🏥 [Physiotherapy] Executing Physiotherapy path');
        }

        // Get and save Physiotherapy EMR data directly (no form validation)
        final physioEMRData = _physiotherapyTabKey.currentState?.getEMRData();
        if (physioEMRData != null) {
          if (kDebugMode) {
            debugPrint('   ✅ Physiotherapy EMR data retrieved');
            debugPrint('   📊 Data: $physioEMRData');
          }

          final physioResult = await GetIt.I<PhysiotherapyEMRRepository>()
              .createPhysiotherapyEMR(physioEMRData);
          physioResult.fold(
            (failure) => throw Exception(failure.message),
            (_) => null,
          );

          if (kDebugMode) {
            debugPrint('   ✅ Physiotherapy EMR saved successfully');
          }
        } else {
          if (kDebugMode) {
            debugPrint('   ⚠️ Physiotherapy EMR data is null');
          }
        }
      } else if (_isNutritionDoctor) {
        // ═════════════════════════════════════════════════════════════════════════
        // PATH 2: NUTRITION DOCTOR
        // - Skip ALL Andrology/EMRModel code
        // - Only validate and save NutritionEMR
        // ═════════════════════════════════════════════════════════════════════════
        if (kDebugMode) {
          debugPrint('🥗 [Nutrition] Executing Nutrition path');
        }

        // Validate Andrology form (may be shown for nutrition doctors)
        if (!_formKey.currentState!.validate()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
          );
          setState(() => _isLoading = false);
          return;
        }

        // Secure specializations against null and empty list
        final specialization = (user.specializations?.isNotEmpty ?? false)
            ? user.specializations!.first
            : 'General';

        if (kDebugMode) {
          debugPrint('   📋 Specialization: $specialization');
          debugPrint(
            '   🔍 User specializations list: ${user.specializations?.join(", ") ?? "null"}',
          );
          debugPrint('   ✅ Null-safe specialization extraction applied');
        }

        final nutritionEMR = NutritionEMRModel(
          id: const Uuid().v4(),
          patientId: widget.patientId,
          doctorId: user.id,
          doctorName: user.fullName,
          appointmentId: widget.appointmentId,
          createdAt: DateTime.now(),
          patientVisitBasics: _patientVisitBasicsSelections,
          anthropometrics: _anthropometricsSelections,
          dietaryIntake: _dietaryIntakeSelections,
          medicalConditions: _medicalConditionsSelections,
          physicalFindings: _physicalFindingsSelections,
          biochemicalData: _biochemicalDataSelections,
          nutritionDiagnosis: _nutritionDiagnosisSelections,
          interventionPlan: _interventionPlanSelections,
          primaryDiagnosis:
              _nutritionPrimaryDiagnosisController.text.trim().isEmpty
              ? null
              : _nutritionPrimaryDiagnosisController.text.trim(),
          managementPlan: _nutritionManagementPlanController.text.trim().isEmpty
              ? null
              : _nutritionManagementPlanController.text.trim(),
          specialization: specialization,
        );

        final nutritionResult = await GetIt.I<NutritionEMRRepository>().saveEMR(
          nutritionEMR,
        );
        nutritionResult.fold(
          (failure) => throw Exception(failure.message),
          (_) => null,
        );

        if (kDebugMode) {
          debugPrint('   ✅ Nutrition EMR saved successfully');
        }
      } else {
        // ═════════════════════════════════════════════════════════════════════════
        // PATH 3: ANDROLOGY DOCTOR (Default)
        // - Validate all Andrology fields
        // - Save EMRModel only
        // ═════════════════════════════════════════════════════════════════════════
        if (kDebugMode) {
          debugPrint('👨‍⚕️ [Andrology] Executing Andrology path');
        }

        // Validate Andrology form
        if (!_formKey.currentState!.validate()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
          );
          setState(() => _isLoading = false);
          return;
        }

        // ═════════════════════════════════════════════════════════════════════════
        // DIAGNOSTIC LOGGING: Verify all EMRModel fields before creation
        // ═════════════════════════════════════════════════════════════════════════
        if (kDebugMode) {
          debugPrint(
            '═══════════════════════════════════════════════════════════════',
          );
          debugPrint('🔍 [EMR] Pre-Creation Diagnostic Logging');
          debugPrint(
            '───────────────────────────────────────────────────────────────',
          );
          debugPrint('📋 User Data:');
          debugPrint('   User ID: ${user.id}');
          debugPrint('   User Name: ${user.fullName}');
          debugPrint(
            '   User Specializations: ${user.specializations?.join(", ") ?? "null"}',
          );
          debugPrint(
            '───────────────────────────────────────────────────────────────',
          );
          debugPrint('👤 Patient Data:');
          debugPrint('   Patient ID: ${widget.patientId}');
          debugPrint('   Appointment ID: ${widget.appointmentId}');
          debugPrint(
            '───────────────────────────────────────────────────────────────',
          );
          debugPrint('📝 EMR Fields Status:');

          // I. Sexual Function Assessment
          debugPrint('   I. Sexual Function Assessment:');
          debugPrint('      libidoLevel: ${_libidoLevel ?? "❌ NULL"}');
          debugPrint(
            '      onsetOfErectileDifficulty: ${_onsetOfErectileDifficulty ?? "❌ NULL"}',
          );
          debugPrint(
            '      frequencyOfIntercourseAttempts: "${_frequencyOfIntercourseController.text}"',
          );
          debugPrint(
            '      penetrationSuccess: "${_penetrationSuccessController.text}"',
          );
          debugPrint(
            '      erectionRigidity: ${_erectionRigidity ?? "❌ NULL"}',
          );
          debugPrint(
            '      nocturnalMorningErections: ${_nocturnalMorningErections ?? "❌ NULL"}',
          );
          debugPrint(
            '      ejaculatoryFunction: ${_ejaculatoryFunction ?? "❌ NULL"}',
          );
          debugPrint(
            '      orgasmicSatisfaction: ${_orgasmicSatisfaction ?? "❌ NULL"}',
          );
          debugPrint(
            '      partnerSatisfaction: ${_partnerSatisfaction ?? "❌ NULL"}',
          );
          debugPrint(
            '      concernAboutPenileSize: ${_concernAboutPenileSize ?? "❌ NULL"}',
          );
          debugPrint(
            '      opinionAboutPartnerSatisfaction: ${_opinionAboutPartnerSatisfaction ?? "❌ NULL"}',
          );

          // II. Past Sexual History
          debugPrint('   II. Past Sexual History:');
          debugPrint(
            '      pastHomosexualExperience: ${_pastHomosexualExperience ?? "❌ NULL"}',
          );
          debugPrint(
            '      interestedInHomosexuality: ${_interestedInHomosexuality ?? "❌ NULL"}',
          );
          debugPrint(
            '      historyOfSexualTraumaInChildhood: ${_historyOfSexualTraumaInChildhood ?? "❌ NULL"}',
          );
          debugPrint(
            '      historyOfPornoAddiction: ${_historyOfPornoAddiction ?? "❌ NULL"}',
          );
          debugPrint(
            '      historyOfMasturbationAddiction: ${_historyOfMasturbationAddiction ?? "❌ NULL"}',
          );
          debugPrint(
            '      historyOfIllegalSex: ${_historyOfIllegalSex ?? "❌ NULL"}',
          );
          debugPrint(
            '      historyOfHavingSTDs: ${_historyOfHavingSTDs ?? "❌ NULL"}',
          );
          debugPrint(
            '      historyOfPenileTrauma: ${_historyOfPenileTrauma ?? "❌ NULL"}',
          );
          debugPrint(
            '      historyMedication: ${_historyMedication ?? "❌ NULL"}',
          );
          debugPrint(
            '      historyOfPenileCurvature: ${_historyOfPenileCurvature ?? "❌ NULL"}',
          );

          // III. Infertility Evaluation
          debugPrint('   III. Infertility Evaluation:');
          debugPrint('      multipleWives: ${_multipleWives ?? "❌ NULL"}');
          debugPrint('      infertilityType: ${_infertilityType ?? "❌ NULL"}');
          debugPrint(
            '      previousConceptions: ${_previousConceptions ?? "❌ NULL"}',
          );

          // IV. Prostatic Symptoms
          debugPrint('   IV. Prostatic Symptoms:');
          debugPrint('      stream: ${_stream ?? "❌ NULL"}');
          debugPrint(
            '      strainingOrIncompleteEmptying: ${_straining ?? "❌ NULL"}',
          );

          debugPrint(
            '───────────────────────────────────────────────────────────────',
          );
          debugPrint('🚨 Null Safety Check:');
          final nullFields = <String>[];
          if (_libidoLevel == null) nullFields.add('libidoLevel');
          if (_onsetOfErectileDifficulty == null) {
            nullFields.add('onsetOfErectileDifficulty');
          }
          if (_erectionRigidity == null) {
            nullFields.add('erectionRigidity');
          }
          if (_nocturnalMorningErections == null) {
            nullFields.add('nocturnalMorningErections');
          }
          if (_ejaculatoryFunction == null) {
            nullFields.add('ejaculatoryFunction');
          }
          if (_orgasmicSatisfaction == null) {
            nullFields.add('orgasmicSatisfaction');
          }
          if (_partnerSatisfaction == null) {
            nullFields.add('partnerSatisfaction');
          }
          if (_concernAboutPenileSize == null) {
            nullFields.add('concernAboutPenileSize');
          }
          if (_opinionAboutPartnerSatisfaction == null) {
            nullFields.add('opinionAboutPartnerSatisfaction');
          }
          if (_pastHomosexualExperience == null) {
            nullFields.add('pastHomosexualExperience');
          }
          if (_interestedInHomosexuality == null) {
            nullFields.add('interestedInHomosexuality');
          }
          if (_historyOfSexualTraumaInChildhood == null) {
            nullFields.add('historyOfSexualTraumaInChildhood');
          }
          if (_historyOfPornoAddiction == null) {
            nullFields.add('historyOfPornoAddiction');
          }
          if (_historyOfMasturbationAddiction == null) {
            nullFields.add('historyOfMasturbationAddiction');
          }
          if (_historyOfIllegalSex == null) {
            nullFields.add('historyOfIllegalSex');
          }
          if (_historyOfHavingSTDs == null) {
            nullFields.add('historyOfHavingSTDs');
          }
          if (_historyOfPenileTrauma == null) {
            nullFields.add('historyOfPenileTrauma');
          }
          if (_historyMedication == null) {
            nullFields.add('historyMedication');
          }
          if (_historyOfPenileCurvature == null) {
            nullFields.add('historyOfPenileCurvature');
          }
          if (_multipleWives == null) {
            nullFields.add('multipleWives');
          }
          if (_infertilityType == null) {
            nullFields.add('infertilityType');
          }
          if (_previousConceptions == null) {
            nullFields.add('previousConceptions');
          }
          if (_stream == null) {
            nullFields.add('stream');
          }
          if (_straining == null) {
            nullFields.add('strainingOrIncompleteEmptying');
          }

          if (nullFields.isNotEmpty) {
            debugPrint(
              '   ⚠️ WARNING: ${nullFields.length} null fields detected!',
            );
            debugPrint('   Null fields: ${nullFields.join(", ")}');
            debugPrint(
              '   ❌ EMRModel creation will FAIL without fallback values!',
            );
          } else {
            debugPrint('   ✅ All required fields have values');
          }
          debugPrint(
            '═══════════════════════════════════════════════════════════════',
          );
        }

        // ═════════════════════════════════════════════════════════════════════════
        // NULL SAFETY VALIDATION: Ensure all required fields have values
        // ═════════════════════════════════════════════════════════════════════════
        final requiredFieldsValidation = {
          'libidoLevel': _libidoLevel,
          'onsetOfErectileDifficulty': _onsetOfErectileDifficulty,
          'erectionRigidity': _erectionRigidity,
          'nocturnalMorningErections': _nocturnalMorningErections,
          'ejaculatoryFunction': _ejaculatoryFunction,
          'orgasmicSatisfaction': _orgasmicSatisfaction,
          'partnerSatisfaction': _partnerSatisfaction,
          'concernAboutPenileSize': _concernAboutPenileSize,
          'opinionAboutPartnerSatisfaction': _opinionAboutPartnerSatisfaction,
          'pastHomosexualExperience': _pastHomosexualExperience,
          'interestedInHomosexuality': _interestedInHomosexuality,
          'historyOfSexualTraumaInChildhood': _historyOfSexualTraumaInChildhood,
          'historyOfPornoAddiction': _historyOfPornoAddiction,
          'historyOfMasturbationAddiction': _historyOfMasturbationAddiction,
          'historyOfIllegalSex': _historyOfIllegalSex,
          'historyOfHavingSTDs': _historyOfHavingSTDs,
          'historyOfPenileTrauma': _historyOfPenileTrauma,
          'historyMedication': _historyMedication,
          'historyOfPenileCurvature': _historyOfPenileCurvature,
          'multipleWives': _multipleWives,
          'infertilityType': _infertilityType,
          'previousConceptions': _previousConceptions,
          'stream': _stream,
          'strainingOrIncompleteEmptying': _straining,
        };

        final missingFields = requiredFieldsValidation.entries
            .where((entry) => entry.value == null)
            .map((entry) => entry.key)
            .toList();

        if (missingFields.isNotEmpty) {
          if (kDebugMode) {
            debugPrint(
              '❌ [EMR] Validation Failed: Missing ${missingFields.length} required fields',
            );
            debugPrint('   Missing fields: ${missingFields.join(", ")}');
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'يرجى ملء جميع الحقول المطلوبة: ${missingFields.join(", ")}',
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }

          setState(() => _isLoading = false);
          return;
        }

        // ═════════════════════════════════════════════════════════════════════════
        // EMRModel CREATION: Null-safe with fallback values
        // ═════════════════════════════════════════════════════════════════════════
        final emr = EMRModel(
          id: const Uuid().v4(),
          patientId: widget.patientId,
          doctorId: user.id,
          doctorName: user.fullName,
          appointmentId: widget.appointmentId,
          createdAt: DateTime.now(),

          // I. Sexual Function Assessment (Null-safe with fallback values)
          libidoLevel: _libidoLevel ?? 'Normal',
          onsetOfErectileDifficulty: _onsetOfErectileDifficulty ?? 'Gradual',
          frequencyOfIntercourseAttempts:
              _frequencyOfIntercourseController.text,
          penetrationSuccess: _penetrationSuccessController.text,
          erectionRigidity: _erectionRigidity ?? '3',
          nocturnalMorningErections: _nocturnalMorningErections ?? 'Present',
          ejaculatoryFunction: _ejaculatoryFunction ?? 'Normal',
          orgasmicSatisfaction: _orgasmicSatisfaction ?? 'Normal',
          partnerSatisfaction: _partnerSatisfaction ?? 'Normal',
          concernAboutPenileSize: _concernAboutPenileSize ?? 'Normal',
          opinionAboutPartnerSatisfaction:
              _opinionAboutPartnerSatisfaction ?? 'Normal',

          // II. Past Sexual History (Null-safe with fallback values)
          pastHomosexualExperience: _pastHomosexualExperience ?? false,
          interestedInHomosexuality: _interestedInHomosexuality ?? false,
          historyOfSexualTraumaInChildhood:
              _historyOfSexualTraumaInChildhood ?? false,
          historyOfPornoAddiction: _historyOfPornoAddiction ?? false,
          historyOfMasturbationAddiction:
              _historyOfMasturbationAddiction ?? false,
          historyOfIllegalSex: _historyOfIllegalSex ?? false,
          historyOfHavingSTDs: _historyOfHavingSTDs ?? false,
          historyOfPenileTrauma: _historyOfPenileTrauma ?? false,
          historyMedication: _historyMedication ?? false,
          historyOfPenileCurvature: _historyOfPenileCurvature ?? false,

          // Medications & Investigations
          pde5I: _pde5IController.text,
          supplements: _supplementsController.text,
          hormones: _hormonesController.text,
          previousHormones: _prevHormonesController.text,
          previousGeneralLab: _prevGeneralLabController.text,

          // Radiology
          duplexPenileArteries: _duplexController.text,
          testicularUS: _testicularUSController.text,
          penileUS: _penileUSController.text,
          trus: _trusController.text,
          abdominopelvicUS: _abdominopelvicUSController.text,

          // III. Infertility Evaluation (Null-safe with fallback values)
          durationOfMarriage: _durationOfMarriageController.text,
          ageOfWife: _ageOfWifeController.text,
          multipleWives: _multipleWives ?? false,
          durationOfInfertility: _durationOfInfertilityController.text,
          infertilityType: _infertilityType ?? 'Primary',
          previousConceptions: _previousConceptions ?? false,

          historyOfVaricoceleGenitalSurgery:
              _historyOfVaricoceleController.text,
          semenAnalysisSummary: _semenAnalysisSummaryController.text,
          hormonalProfile: _hormonalProfileController.text,
          geneticOtherTests: _geneticTestsController.text,

          // IV. Prostatic Symptoms (Null-safe with fallback values)
          urinaryFrequency: _urinaryFrequencyController.text,
          stream: _stream ?? 'Normal',
          nocturia: _nocturiaController.text,
          strainingOrIncompleteEmptying: _straining ?? false,

          psaLevelDate: _psaLevelController.text,
          trusProstatic: _trusProstaticController.text,
          uroflowmetry: _uroflowmetryController.text,

          // V. Physical Examination
          generalAppearanceBMI: _generalAppearanceController.text,
          genitalExamination: _genitalExamController.text,
          testicularSizeConsistency: _testicularSizeController.text,
          epididymisVas: _epididymisVasController.text,
          digitalRectalExamination: _dreController.text,

          // VI. Impression & Management Plan
          impressionDiagnosis: _impressionController.text,
          recommendedInvestigations: _investigationsController.text,
          initialTreatmentPlan: _treatmentPlanController.text,
          followUpInterval: _followUpController.text,
        );

        final result = await GetIt.I<EMRRepository>().saveEMR(emr);

        result.fold(
          (failure) => throw Exception(failure.message),
          (_) => null,
        );

        // Debug logging after main EMR save
        if (kDebugMode) {
          debugPrint('✅ [EMR] Main EMR saved successfully');
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم حفظ السجل بنجاح')));
      }
    } on Object catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [EMR] Error during save: $e');
        debugPrint('   Stack trace: ${StackTrace.current}');
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const Divider(thickness: 2, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildSubSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: const TextStyle(
            fontSize: 18, // Make it larger when floating (focused/filled)
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          isDense: true,
        ),
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        key: ValueKey<String?>(value),
        initialValue: value,
        validator: (val) => val == null ? 'مطلوب' : null,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: const TextStyle(
            fontSize: 18,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          isDense: true,
        ),
        items: items
            .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  // Helper for Yes/No Dropdown with explicit selection requirement
  Widget _buildYesNoDropdown(
    String label,
    bool? value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        key: ValueKey<bool?>(value),
        initialValue: value == null ? null : (value ? 'Yes' : 'No'),
        validator: (val) => val == null ? 'مطلوب' : null,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: const TextStyle(
            fontSize: 18,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          isDense: true,
        ),
        items:
            <String>[
                  'Yes',
                  'No',
                ]
                .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                .toList(),
        onChanged: (v) {
          if (v != null) {
            onChanged(v == 'Yes');
          }
        },
      ),
    );
  }

  Widget _buildNutritionTab() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 24),
          _buildSectionHeader('Nutrition Assessment'),

          // Patient Visit Basics
          _buildNutritionSection(
            'Patient Visit Basics',
            NutritionQuestions.patientVisitBasics,
            NutritionQuestions.patientVisitBasicsLabels,
            _patientVisitBasicsSelections,
          ),

          // Anthropometrics
          _buildNutritionSection(
            'Anthropometrics',
            NutritionQuestions.anthropometrics,
            NutritionQuestions.anthropometricsLabels,
            _anthropometricsSelections,
          ),

          // Dietary Intake Assessment
          _buildNutritionSection(
            'Dietary Intake Assessment',
            NutritionQuestions.dietaryIntake,
            NutritionQuestions.dietaryIntakeLabels,
            _dietaryIntakeSelections,
          ),

          // Medical Conditions
          _buildNutritionSection(
            'Medical Conditions',
            NutritionQuestions.medicalConditions,
            NutritionQuestions.medicalConditionsLabels,
            _medicalConditionsSelections,
          ),

          // Nutrition Focused Physical Findings
          _buildNutritionSection(
            'Physical Findings',
            NutritionQuestions.physicalFindings,
            NutritionQuestions.physicalFindingsLabels,
            _physicalFindingsSelections,
          ),

          // Biochemical Data Reviewed
          _buildNutritionSection(
            'Biochemical Data',
            NutritionQuestions.biochemicalData,
            NutritionQuestions.biochemicalDataLabels,
            _biochemicalDataSelections,
          ),

          // Nutrition Diagnosis
          _buildNutritionSection(
            'Nutrition Diagnosis',
            NutritionQuestions.nutritionDiagnosis,
            NutritionQuestions.nutritionDiagnosisLabels,
            _nutritionDiagnosisSelections,
          ),

          // Primary Diagnosis (Smart Field)
          _buildSubSectionHeader('Primary Diagnosis'),
          SmartTextFormField(
            controller: _nutritionPrimaryDiagnosisController,
            label: 'Primary Diagnosis',
          ),

          // Intervention Plan
          _buildNutritionSection(
            'Intervention Plan',
            NutritionQuestions.interventionPlan,
            NutritionQuestions.interventionPlanLabels,
            _interventionPlanSelections,
          ),

          // Management Plan (Smart Field)
          _buildSubSectionHeader('Management Plan'),
          SmartTextFormField(
            controller: _nutritionManagementPlanController,
            label: 'Management Plan',
            maxLines: 4,
            formatType: SmartFormatType.numbered,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSection(
    String title,
    Map<String, List<String>> options,
    Map<String, String> labels,
    Map<String, List<String>> selections,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildSectionHeader(title),
        ...options.entries.map((entry) {
          final key = entry.key;
          final items = entry.value;
          final label = labels[key] ?? key;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            child: ExpansionTile(
              title: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    children: items
                        .map(
                          (item) => CheckboxListTile(
                            title: Text(item),
                            value: selections[key]?.contains(item) ?? false,
                            onChanged: (checked) {
                              setState(() {
                                selections.putIfAbsent(key, () => <String>[]);
                                if (checked ?? false) {
                                  selections[key]!.add(item);
                                } else {
                                  selections[key]!.remove(item);
                                }
                              });
                            },
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Store user in local variable for null safety
    final user = ref.watch(authProvider).user;

    // Null safety protection
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('إضافة سجل EMR')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            // Physiotherapy Tab (Conditional)
            if (_isPhysiotherapyDoctor)
              PhysiotherapyEMRTab(
                key: _physiotherapyTabKey,
                patientId: widget.patientId,
                doctorId: user.id,
                doctorName: user.fullName,
                appointmentId: widget.appointmentId,
                visitDate: DateTime.now(),
              ),

            // Nutrition Tab (Conditional)
            if (_isNutritionDoctor) _buildNutritionTab(),

            // Andrology EMR (Conditional - only if not physiotherapy or nutrition)
            if (!_isPhysiotherapyDoctor && !_isNutritionDoctor)
              _buildAndrologyForm(),

            // Save Button (Always visible)
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('حفظ السجل', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 48), // Bottom padding
          ],
        ),
      ),
    );
  }

  /// Build Andrology EMR form
  Widget _buildAndrologyForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildSectionHeader('I. Sexual Function Assessment'),
        _buildDropdown('Libido Level', _libidoLevel, <String>[
          'Normal',
          'Reduced',
          'Absent',
        ], (v) => setState(() => _libidoLevel = v)),

        _buildDropdown(
          'Onset of Erectile Difficulty',
          _onsetOfErectileDifficulty,
          <String>['Sudden', 'Gradual'],
          (v) => setState(() => _onsetOfErectileDifficulty = v),
        ),
        _buildTextField(
          'Frequency of Intercourse Attempts',
          _frequencyOfIntercourseController,
        ),
        _buildTextField(
          'Penetration Success (%)',
          _penetrationSuccessController,
        ),
        _buildDropdown(
          'Erection Rigidity (Scale 1-5)',
          _erectionRigidity,
          <String>['1', '2', '3', '4', '5'],
          (v) => setState(() => _erectionRigidity = v),
        ),
        _buildDropdown(
          'Nocturnal/Morning Erections',
          _nocturnalMorningErections,
          <String>['Present', 'Absent', 'Reduced'],
          (v) => setState(() => _nocturnalMorningErections = v),
        ),
        _buildDropdown(
          'Ejaculatory Function',
          _ejaculatoryFunction,
          <String>['Normal', 'Premature', 'Delayed', 'Absent'],
          (v) => setState(() => _ejaculatoryFunction = v),
        ),
        _buildDropdown(
          'Orgasmic Satisfaction',
          _orgasmicSatisfaction,
          <String>['Normal', 'Reduced', 'Absent'],
          (v) => setState(() => _orgasmicSatisfaction = v),
        ),
        _buildDropdown(
          'Partner Satisfaction',
          _partnerSatisfaction,
          <String>['Normal', 'Reduced', 'Absent'],
          (v) => setState(() => _partnerSatisfaction = v),
        ),
        _buildDropdown(
          'Concern about Penile Size',
          _concernAboutPenileSize,
          <String>['Normal', 'Reduced', 'Absent'],
          (v) => setState(() => _concernAboutPenileSize = v),
        ),
        _buildDropdown(
          'Opinion about Partner Satisfaction',
          _opinionAboutPartnerSatisfaction,
          <String>['Normal', 'Reduced', 'Absent'],
          (v) => setState(() => _opinionAboutPartnerSatisfaction = v),
        ),

        _buildSectionHeader('II. Past Sexual History'),
        _buildYesNoDropdown(
          'Past Homosexual Experience',
          _pastHomosexualExperience,
          (v) => setState(() => _pastHomosexualExperience = v),
        ),
        _buildYesNoDropdown(
          'Are you interested in homosexuality',
          _interestedInHomosexuality,
          (v) => setState(() => _interestedInHomosexuality = v),
        ),
        _buildYesNoDropdown(
          'History of Sexual trauma in childhood',
          _historyOfSexualTraumaInChildhood,
          (v) => setState(() => _historyOfSexualTraumaInChildhood = v),
        ),
        _buildYesNoDropdown(
          'History of porno addiction',
          _historyOfPornoAddiction,
          (v) => setState(() => _historyOfPornoAddiction = v),
        ),
        _buildYesNoDropdown(
          'History of masturbation addiction',
          _historyOfMasturbationAddiction,
          (v) => setState(() => _historyOfMasturbationAddiction = v),
        ),
        _buildYesNoDropdown(
          'History of illegal sex',
          _historyOfIllegalSex,
          (v) => setState(() => _historyOfIllegalSex = v),
        ),
        _buildYesNoDropdown(
          'History of having STDs',
          _historyOfHavingSTDs,
          (v) => setState(() => _historyOfHavingSTDs = v),
        ),
        _buildYesNoDropdown(
          'History of Penile Trauma',
          _historyOfPenileTrauma,
          (v) => setState(() => _historyOfPenileTrauma = v),
        ),
        _buildYesNoDropdown(
          'History Medication',
          _historyMedication,
          (v) => setState(() => _historyMedication = v),
        ),
        _buildYesNoDropdown(
          'History of Penile Curvature',
          _historyOfPenileCurvature,
          (v) => setState(() => _historyOfPenileCurvature = v),
        ),

        _buildSubSectionHeader('Medications'),
        _buildTextField('PDE5 - I', _pde5IController),
        _buildTextField('Supplements', _supplementsController),
        _buildTextField('Hormones', _hormonesController),

        _buildSubSectionHeader('History of Previous Investigations'),
        _buildTextField('Hormones', _prevHormonesController),
        _buildTextField('General Lab', _prevGeneralLabController),

        _buildSubSectionHeader('Radiology + and/or ICI'),
        _buildTextField('Duplex Penile Arteries', _duplexController),
        _buildTextField('Testicular U/S', _testicularUSController),
        _buildTextField('Penile U/S', _penileUSController),
        _buildTextField('TRUS', _trusController),
        _buildTextField('Abdominopelvic U/S', _abdominopelvicUSController),

        _buildSectionHeader('III. Infertility Evaluation'),
        _buildTextField(
          'Duration of Marriage (Years)',
          _durationOfMarriageController,
        ),
        _buildTextField('Age of Wife (Years)', _ageOfWifeController),
        _buildYesNoDropdown(
          'Multiple Wives',
          _multipleWives,
          (v) => setState(() => _multipleWives = v),
        ),
        _buildTextField(
          'Duration of Infertility (Years)',
          _durationOfInfertilityController,
        ),
        _buildDropdown(
          'Infertility Type',
          _infertilityType,
          <String>['Primary', 'Secondary'],
          (v) => setState(() => _infertilityType = v),
        ),
        _buildYesNoDropdown(
          'Previous Conceptions',
          _previousConceptions,
          (v) => setState(() => _previousConceptions = v),
        ),
        _buildTextField(
          'History of Varicocele / Genital Surgery',
          _historyOfVaricoceleController,
        ),
        _buildTextField(
          'Semen Analysis Summary',
          _semenAnalysisSummaryController,
          maxLines: 2,
        ),
        _buildTextField(
          'Hormonal Profile (FSH, LH, etc.)',
          _hormonalProfileController,
        ),
        _buildTextField('Genetic / Other Tests', _geneticTestsController),

        _buildSectionHeader('IV. Prostatic Symptoms'),
        _buildTextField(
          'Urinary Frequency (Day/Night)',
          _urinaryFrequencyController,
        ),
        _buildDropdown('Stream', _stream, <String>[
          'Normal',
          'Weak',
          'Intermittent',
        ], (v) => setState(() => _stream = v)),
        _buildTextField('Nocturia (Times/Night)', _nocturiaController),
        _buildYesNoDropdown(
          'Straining or Incomplete Emptying',
          _straining,
          (v) => setState(() => _straining = v),
        ),
        _buildTextField('PSA Level / Date', _psaLevelController),
        _buildTextField('TRUS', _trusProstaticController),
        _buildTextField('Uroflowmetry', _uroflowmetryController),

        _buildSectionHeader('V. Physical Examination'),
        _buildTextField(
          'General Appearance / BMI',
          _generalAppearanceController,
        ),
        _buildTextField('Genital Examination', _genitalExamController),
        _buildTextField(
          'Testicular Size and Consistency',
          _testicularSizeController,
        ),
        _buildTextField('Epididymis / Vas', _epididymisVasController),
        _buildTextField('Digital Rectal Examination (DRE)', _dreController),

        _buildSectionHeader('VI. Impression & Management Plan'),
        _buildTextField(
          'Impression / Diagnosis',
          _impressionController,
          maxLines: 2,
        ),
        _buildTextField(
          'Recommended Investigations',
          _investigationsController,
          maxLines: 2,
        ),
        _buildTextField(
          'Initial Treatment Plan',
          _treatmentPlanController,
          maxLines: 3,
        ),
        _buildTextField('Follow-up Interval', _followUpController),
      ],
    );
  }
}
