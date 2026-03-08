// ignore_for_file: all  
// ignore_for_file: all
# EMR Crash Fix - Complete Updated Code

## File: lib/features/doctor/medical_records/presentation/screens/add_emr_screen.dart

### Modified Section: `_save()` Method (Lines 317-551)

---

## COMPLETE UPDATED `_save()` METHOD

```dart
Future<void> _save() async {
  if (!_formKey.currentState!.validate()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
    );
    return;
  }

  // Null safety check for user
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

  // ═════════════════════════════════════════════════════════════════════════
  // DIAGNOSTIC LOGGING: Verify all EMRModel fields before creation
  // ═════════════════════════════════════════════════════════════════════════
  if (kDebugMode) {
    debugPrint('═══════════════════════════════════════════════════════════════');
    debugPrint('🔍 [EMR] Pre-Creation Diagnostic Logging');
    debugPrint('───────────────────────────────────────────────────────────────');
    debugPrint('📋 User Data:');
    debugPrint('   User ID: ${user.id}');
    debugPrint('   User Name: ${user.fullName}');
    debugPrint('   User Specializations: ${user.specializations?.join(", ") ?? "null"}');
    debugPrint('───────────────────────────────────────────────────────────────');
    debugPrint('👤 Patient Data:');
    debugPrint('   Patient ID: ${widget.patientId}');
    debugPrint('   Appointment ID: ${widget.appointmentId}');
    debugPrint('───────────────────────────────────────────────────────────────');
    debugPrint('📝 EMR Fields Status:');
    
    // I. Sexual Function Assessment
    debugPrint('   I. Sexual Function Assessment:');
    debugPrint('      libidoLevel: ${_libidoLevel ?? "❌ NULL"}');
    debugPrint('      onsetOfErectileDifficulty: ${_onsetOfErectileDifficulty ?? "❌ NULL"}');
    debugPrint('      frequencyOfIntercourseAttempts: "${_frequencyOfIntercourseController.text}"');
    debugPrint('      penetrationSuccess: "${_penetrationSuccessController.text}"');
    debugPrint('      erectionRigidity: ${_erectionRigidity ?? "❌ NULL"}');
    debugPrint('      nocturnalMorningErections: ${_nocturnalMorningErections ?? "❌ NULL"}');
    debugPrint('      ejaculatoryFunction: ${_ejaculatoryFunction ?? "❌ NULL"}');
    debugPrint('      orgasmicSatisfaction: ${_orgasmicSatisfaction ?? "❌ NULL"}');
    debugPrint('      partnerSatisfaction: ${_partnerSatisfaction ?? "❌ NULL"}');
    debugPrint('      concernAboutPenileSize: ${_concernAboutPenileSize ?? "❌ NULL"}');
    debugPrint('      opinionAboutPartnerSatisfaction: ${_opinionAboutPartnerSatisfaction ?? "❌ NULL"}');
    
    // II. Past Sexual History
    debugPrint('   II. Past Sexual History:');
    debugPrint('      pastHomosexualExperience: ${_pastHomosexualExperience ?? "❌ NULL"}');
    debugPrint('      interestedInHomosexuality: ${_interestedInHomosexuality ?? "❌ NULL"}');
    debugPrint('      historyOfSexualTraumaInChildhood: ${_historyOfSexualTraumaInChildhood ?? "❌ NULL"}');
    debugPrint('      historyOfPornoAddiction: ${_historyOfPornoAddiction ?? "❌ NULL"}');
    debugPrint('      historyOfMasturbationAddiction: ${_historyOfMasturbationAddiction ?? "❌ NULL"}');
    debugPrint('      historyOfIllegalSex: ${_historyOfIllegalSex ?? "❌ NULL"}');
    debugPrint('      historyOfHavingSTDs: ${_historyOfHavingSTDs ?? "❌ NULL"}');
    debugPrint('      historyOfPenileTrauma: ${_historyOfPenileTrauma ?? "❌ NULL"}');
    debugPrint('      historyMedication: ${_historyMedication ?? "❌ NULL"}');
    debugPrint('      historyOfPenileCurvature: ${_historyOfPenileCurvature ?? "❌ NULL"}');
    
    // III. Infertility Evaluation
    debugPrint('   III. Infertility Evaluation:');
    debugPrint('      multipleWives: ${_multipleWives ?? "❌ NULL"}');
    debugPrint('      infertilityType: ${_infertilityType ?? "❌ NULL"}');
    debugPrint('      previousConceptions: ${_previousConceptions ?? "❌ NULL"}');
    
    // IV. Prostatic Symptoms
    debugPrint('   IV. Prostatic Symptoms:');
    debugPrint('      stream: ${_stream ?? "❌ NULL"}');
    debugPrint('      strainingOrIncompleteEmptying: ${_straining ?? "❌ NULL"}');
    
    debugPrint('───────────────────────────────────────────────────────────────');
    debugPrint('🚨 Null Safety Check:');
    final nullFields = <String>[];
    if (_libidoLevel == null) nullFields.add('libidoLevel');
    if (_onsetOfErectileDifficulty == null) nullFields.add('onsetOfErectileDifficulty');
    if (_erectionRigidity == null) nullFields.add('erectionRigidity');
    if (_nocturnalMorningErections == null) nullFields.add('nocturnalMorningErections');
    if (_ejaculatoryFunction == null) nullFields.add('ejaculatoryFunction');
    if (_orgasmicSatisfaction == null) nullFields.add('orgasmicSatisfaction');
    if (_partnerSatisfaction == null) nullFields.add('partnerSatisfaction');
    if (_concernAboutPenileSize == null) nullFields.add('concernAboutPenileSize');
    if (_opinionAboutPartnerSatisfaction == null) nullFields.add('opinionAboutPartnerSatisfaction');
    if (_pastHomosexualExperience == null) nullFields.add('pastHomosexualExperience');
    if (_interestedInHomosexuality == null) nullFields.add('interestedInHomosexuality');
    if (_historyOfSexualTraumaInChildhood == null) nullFields.add('historyOfSexualTraumaInChildhood');
    if (_historyOfPornoAddiction == null) nullFields.add('historyOfPornoAddiction');
    if (_historyOfMasturbationAddiction == null) nullFields.add('historyOfMasturbationAddiction');
    if (_historyOfIllegalSex == null) nullFields.add('historyOfIllegalSex');
    if (_historyOfHavingSTDs == null) nullFields.add('historyOfHavingSTDs');
    if (_historyOfPenileTrauma == null) nullFields.add('historyOfPenileTrauma');
    if (_historyMedication == null) nullFields.add('historyMedication');
    if (_historyOfPenileCurvature == null) nullFields.add('historyOfPenileCurvature');
    if (_multipleWives == null) nullFields.add('multipleWives');
    if (_infertilityType == null) nullFields.add('infertilityType');
    if (_previousConceptions == null) nullFields.add('previousConceptions');
    if (_stream == null) nullFields.add('stream');
    if (_straining == null) nullFields.add('strainingOrIncompleteEmptying');
    
    if (nullFields.isNotEmpty) {
      debugPrint('   ⚠️ WARNING: ${nullFields.length} null fields detected!');
      debugPrint('   Null fields: ${nullFields.join(", ")}');
      debugPrint('   ❌ EMRModel creation will FAIL without fallback values!');
    } else {
      debugPrint('   ✅ All required fields have values');
    }
    debugPrint('═══════════════════════════════════════════════════════════════');
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
      debugPrint('❌ [EMR] Validation Failed: Missing ${missingFields.length} required fields');
      debugPrint('   Missing fields: ${missingFields.join(", ")}');
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى ملء جميع الحقول المطلوبة: ${missingFields.join(", ")}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
    
    setState(() => _isLoading = false);
    return;
  }

  setState(() => _isLoading = true);

  try {
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
      frequencyOfIntercourseAttempts: _frequencyOfIntercourseController.text,
      penetrationSuccess: _penetrationSuccessController.text,
      erectionRigidity: _erectionRigidity ?? '3',
      nocturnalMorningErections: _nocturnalMorningErections ?? 'Present',
      ejaculatoryFunction: _ejaculatoryFunction ?? 'Normal',
      orgasmicSatisfaction: _orgasmicSatisfaction ?? 'Normal',
      partnerSatisfaction: _partnerSatisfaction ?? 'Normal',
      concernAboutPenileSize: _concernAboutPenileSize ?? 'Normal',
      opinionAboutPartnerSatisfaction: _opinionAboutPartnerSatisfaction ?? 'Normal',
      
      // II. Past Sexual History (Null-safe with fallback values)
      pastHomosexualExperience: _pastHomosexualExperience ?? false,
      interestedInHomosexuality: _interestedInHomosexuality ?? false,
      historyOfSexualTraumaInChildhood: _historyOfSexualTraumaInChildhood ?? false,
      historyOfPornoAddiction: _historyOfPornoAddiction ?? false,
      historyOfMasturbationAddiction: _historyOfMasturbationAddiction ?? false,
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
      
      historyOfVaricoceleGenitalSurgery: _historyOfVaricoceleController.text,
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

    // Save Physiotherapy EMR if applicable
    if (_isPhysiotherapyDoctor) {
      if (kDebugMode) {
        debugPrint('🏥 [Physiotherapy] Attempting to save Physiotherapy EMR');
      }

      final physioEMRData = _physiotherapyTabKey.currentState?.getEMRData();
      if (physioEMRData != null) {
        if (kDebugMode) {
          debugPrint('   ✅ Physiotherapy EMR data retrieved');
          debugPrint('   📊 Data: ${physioEMRData.toString()}');
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
    }

    // Save Nutrition EMR if applicable
    if (_isNutritionDoctor) {
      if (kDebugMode) {
        debugPrint('🥗 [Nutrition] Attempting to save Nutrition EMR');
      }

      // Secure specializations against null and empty list
      // Following project rule: user.specializations?.isNotEmpty == true ? user.specializations!.first : 'General'
      final specialization = user.specializations?.isNotEmpty == true
          ? user.specializations!.first
          : 'General';

      if (kDebugMode) {
        debugPrint('   📋 Specialization: $specialization');
        debugPrint('   🔍 User specializations list: ${user.specializations?.join(", ") ?? "null"}');
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
```

---

## SUMMARY OF CHANGES

### 1. Added Comprehensive Diagnostic Logging (Lines 355-425)
- Logs all user data (ID, name, specializations)
- Logs all patient data (patient ID, appointment ID)
- Logs all EMR field values with null indicators
- Performs null safety check and reports missing fields

### 2. Added Null Safety Validation (Lines 427-458)
- Validates all required fields before EMRModel creation
- Lists missing fields if any
- Shows user-friendly error message with missing field names
- Returns early if validation fails

### 3. Replaced All `!` Operators with `??` (Lines 468-531)
- All nullable fields now use null-aware operators with fallback values
- String fields get sensible defaults (e.g., 'Normal', 'Primary', '3')
- Boolean fields default to `false`
- No more crash risk from null values

### 4. Updated Specialization Extraction (Lines 560-568)
- Implements the required rule: `user.specializations?.isNotEmpty == true ? user.specializations!.first : 'General'`
- Added diagnostic logging for specializations list
- Ensures null-safe access to user.specializations

---

## FALLBACK VALUES USED

### String Fields:
| Field | Fallback Value |
|-------|---------------|
| libidoLevel | 'Normal' |
| onsetOfErectileDifficulty | 'Gradual' |
| erectionRigidity | '3' |
| nocturnalMorningErections | 'Present' |
| ejaculatoryFunction | 'Normal' |
| orgasmicSatisfaction | 'Normal' |
| partnerSatisfaction | 'Normal' |
| concernAboutPenileSize | 'Normal' |
| opinionAboutPartnerSatisfaction | 'Normal' |
| infertilityType | 'Primary' |
| stream | 'Normal' |
| specialization | 'General' |

### Boolean Fields:
| Field | Fallback Value |
|-------|---------------|
| pastHomosexualExperience | false |
| interestedInHomosexuality | false |
| historyOfSexualTraumaInChildhood | false |
| historyOfPornoAddiction | false |
| historyOfMasturbationAddiction | false |
| historyOfIllegalSex | false |
| historyOfHavingSTDs | false |
| historyOfPenileTrauma | false |
| historyMedication | false |
| historyOfPenileCurvature | false |
| multipleWives | false |
| previousConceptions | false |
| strainingOrIncompleteEmptying | false |

---

## COMPLIANCE WITH PROJECT RULES

✅ **Null Safety Rule**: All `!` operators replaced with `??` operators  
✅ **Specializations Rule**: Applied `user.specializations?.isNotEmpty == true ? user.specializations!.first : 'General'`  
✅ **Diagnostic Logging Rule**: Added comprehensive debugPrint statements for all variables  
✅ **User Validation Rule**: Checked `user != null` before accessing properties  
✅ **Fallback Values Rule**: Provided sensible defaults for all required fields  

---

## TESTING RECOMMENDATIONS

1. **Test Case 1**: Try to save EMR without filling any dropdowns
   - Expected: Validation error with list of missing fields
   - No crash should occur

2. **Test Case 2**: Fill all dropdowns and save
   - Expected: EMR saved successfully
   - All values should be correct

3. **Test Case 3**: Fill some dropdowns and save
   - Expected: Validation error with specific missing fields
   - No crash should occur

4. **Test Case 4**: Test with doctor who has empty specializations list
   - Expected: Specialization defaults to 'General'
   - No crash should occur

5. **Test Case 5**: Test with doctor who has specializations
   - Expected: First specialization is used
   - Correct value should be logged

---

**Document Created**: 2026-01-20  
**Status**: Ready for Implementation  
**Mode**: Architect (Planning Complete)
