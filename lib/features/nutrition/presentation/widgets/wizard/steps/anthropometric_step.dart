import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';

import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/constants/app_text_styles.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/nutrition/domain/entities/nutrition_emr_entity.dart';
import 'package:elajtech/features/nutrition/presentation/state/nutrition_state_providers.dart';
import 'package:elajtech/features/nutrition/presentation/widgets/wizard/comprehensive_nutrition_checklist.dart';

/// Anthropometric Step - Simplified Single-Screen Nutrition EMR
///
/// Comprehensive body measurements collection with real-time calculations
///
/// **Required Fields:**
/// - Height (سم): 50-250
/// - Weight (kg): 20-300
/// - Waist circumference (cm)
/// - Hip circumference (optional for WHR calculation)
///
/// **Features:**
/// - Real-time BMI calculation
/// - Real-time WHR calculation
/// - Visual health indicators with color coding
/// - Direct save functionality
/// - LTR layout for numbers
/// - RTL support for Arabic labels
class AnthropometricStep extends ConsumerStatefulWidget {
  const AnthropometricStep({super.key});

  @override
  ConsumerState<AnthropometricStep> createState() => _AnthropometricStepState();
}

class _AnthropometricStepState extends ConsumerState<AnthropometricStep> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipController = TextEditingController();

  // Focus Nodes
  final _heightFocus = FocusNode();
  final _weightFocus = FocusNode();
  final _waistFocus = FocusNode();
  final _hipFocus = FocusNode();

  // Calculated values
  double? _bmi;
  double? _whr;

  bool _isSaving = false;
  bool _shouldPopulateControllers = true;

  @override
  void initState() {
    super.initState();

    // Add listeners for real-time calculations
    _heightController.addListener(_calculateMetrics);
    _weightController.addListener(_calculateMetrics);
    _waistController.addListener(_calculateMetrics);
    _hipController.addListener(_calculateMetrics);
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _waistController.dispose();
    _hipController.dispose();
    _heightFocus.dispose();
    _weightFocus.dispose();
    _waistFocus.dispose();
    _hipFocus.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Populate controllers with loaded EMR data
    final emrState = ref.watch(nutritionEMRNotifierProvider);
    final emr = emrState.emrOrNull;

    if (emr != null && _shouldPopulateControllers) {
      _populateControllers(emr);
      _shouldPopulateControllers = false;
    }
  }

  /// Populate text controllers with loaded EMR data.
  ///
  /// This method safely populates the text controllers with values from the
  /// loaded EMR entity, avoiding overwriting user input.
  ///
  /// **Parameters:**
  /// - [emr]: The loaded EMR entity containing measurement values
  void _populateControllers(NutritionEMREntity emr) {
    // Only update if controllers are empty to avoid overwriting user input
    if (_heightController.text.isEmpty && emr.heightValue != null) {
      _heightController.text = emr.heightValue!.toStringAsFixed(1);
    }
    if (_weightController.text.isEmpty && emr.weightValue != null) {
      _weightController.text = emr.weightValue!.toStringAsFixed(1);
    }
    if (_waistController.text.isEmpty && emr.waistCircumferenceValue != null) {
      _waistController.text = emr.waistCircumferenceValue!.toStringAsFixed(1);
    }
    if (_hipController.text.isEmpty && emr.hipCircumferenceValue != null) {
      _hipController.text = emr.hipCircumferenceValue!.toStringAsFixed(1);
    }

    // Trigger metrics calculation
    _calculateMetrics();
  }

  /// Calculate BMI and WHR in real-time.
  ///
  /// This method is triggered whenever any of the measurement controllers
  /// changes. It calculates:
  /// - BMI (Body Mass Index): weight / (height in meters)²
  /// - WHR (Waist-to-Hip Ratio): waist / hip
  ///
  /// Both values are null if required inputs are missing or invalid.
  void _calculateMetrics() {
    setState(() {
      // Calculate BMI
      final height = double.tryParse(_heightController.text);
      final weight = double.tryParse(_weightController.text);

      if (height != null && weight != null && height > 0) {
        final heightInMeters = height / 100;
        _bmi = weight / (heightInMeters * heightInMeters);
      } else {
        _bmi = null;
      }

      // Calculate WHR
      final waist = double.tryParse(_waistController.text);
      final hip = double.tryParse(_hipController.text);

      if (waist != null && hip != null && hip > 0) {
        _whr = waist / hip;
      } else {
        _whr = null;
      }
    });
  }

  /// Save medical record to Firestore.
  ///
  /// This method validates the form, checks lock status, updates the EMR
  /// entity with anthropometric measurements, and persists it to Firestore.
  ///
  /// **Flow:**
  /// 1. Validate form inputs
  /// 2. Check if record is locked (24h rule)
  /// 3. Parse numeric values from controllers
  /// 4. Update EMR entity with measurements
  /// 5. Save to Firestore via NutritionEMRNotifier
  /// 6. Show success/error feedback
  /// 7. Close screen on success
  ///
  /// **Throws:** Exception if save fails or user is not authenticated
  Future<void> _saveMedicalRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ✅ Validation: Check if record is locked before attempting to save
    final emrState = ref.read(nutritionEMRNotifierProvider);
    if (emrState.emrOrNull != null && emrState.emrOrNull!.isCurrentlyLocked) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '⚠️ السجل مقفل ولا يمكن تعديله بعد مرور 24 ساعة من تاريخ الموعد',
            ),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final user = ref.read(authProvider).user;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get current EMR
      final currentEmr = emrState.emrOrNull!;

      // Parse numeric values from controllers
      final height = double.tryParse(_heightController.text);
      final weight = double.tryParse(_weightController.text);
      final waist = double.tryParse(_waistController.text);
      final hip = double.tryParse(_hipController.text);

      final notifier = ref.read(nutritionEMRNotifierProvider.notifier);

      // ✅ FIX: Create updated EMR with numeric values AND checkboxes in ONE copyWith call
      final updatedEmr = currentEmr.copyWith(
        // Numeric values
        heightValue: height,
        weightValue: weight,
        waistCircumferenceValue: waist,
        hipCircumferenceValue: hip,
        // Boolean checkboxes
        heightMeasured: true,
        weightMeasured: true,
        bmiCalculated: true,
        waistCircumferenceMeasured: true,
        weightChangeDocumented: true,
        updatedAt: DateTime.now(),
      );

      // ✅ FIX: Use the safe updateWholeEntity method instead of direct state access
      notifier.updateWholeEntity(updatedEmr);

      // ✅ Save the EMR to Firestore with smart Upsert
      final saved = await notifier.saveManually();

      if (saved && mounted) {
        // ✅ Read the final state to get operation type
        final finalState = ref.read(nutritionEMRNotifierProvider);
        final isCreate = finalState.lastOperationType == 'created';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isCreate ? Icons.check_circle : Icons.edit,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isCreate
                        ? 'تم إنشاء السجل الطبي بنجاح ✅'
                        : 'تم تحديث السجل الطبي بنجاح 🔄',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: isCreate ? Colors.green : Colors.blue,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Close the screen after successful save
        Navigator.of(context).pop();
      } else if (!saved && mounted) {
        throw Exception('Failed to save EMR');
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطأ في الحفظ: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final emrState = ref.watch(nutritionEMRNotifierProvider);
    final emr = emrState.emrOrNull;

    if (emr == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        /// Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FadeInUp(
              duration: const Duration(milliseconds: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    _buildHeader(),
                    const SizedBox(height: 24),

                    // Height Field
                    _buildHeightField(),
                    const SizedBox(height: 16),

                    // Weight Field
                    _buildWeightField(),
                    const SizedBox(height: 16),

                    // BMI Card
                    if (_bmi != null) ...[
                      _buildBMICard(),
                      const SizedBox(height: 16),
                    ],

                    // Waist Circumference Field
                    _buildWaistField(),
                    const SizedBox(height: 16),

                    // Hip Circumference Field
                    _buildHipField(),
                    const SizedBox(height: 16),

                    // WHR Card
                    if (_whr != null) ...[
                      _buildWHRCard(),
                      const SizedBox(height: 24),
                    ],

                    // Divider between measurements and checklist
                    const Divider(height: 32, thickness: 2),
                    const SizedBox(height: 8),

                    // ═════════════════════════════════════════════════════════════════════
                    // COMPREHENSIVE MEDICAL CHECKLIST
                    // ═════════════════════════════════════════════════════════════════════
                    const ComprehensiveNutritionChecklist(),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Save Button - Hide completely when record is locked
        if (!emr.isCurrentlyLocked)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveMedicalRecord,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'جاري الحفظ...' : 'حفظ السجل الطبي'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.borderLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Build section header with icon and description.
  ///
  /// Returns a widget displaying the anthropometric measurements section
  /// header with an icon, title, and description.
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.straighten,
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
                    'القياسات الجسمية',
                    style: AppTextStyles.h5.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'قياس الوزن والطول ومؤشر كتلة الجسم',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build height input field with validation.
  ///
  /// Returns a TextFormField for entering height in centimeters (50-250 range).
  /// Uses LTR text direction for proper number input.
  Widget _buildHeightField() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextFormField(
        controller: _heightController,
        focusNode: _heightFocus,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        decoration: InputDecoration(
          labelText: 'Height (cm) | الطول (سم)',
          hintText: 'e.g., 170.5',
          prefixIcon: const Icon(Icons.height, color: AppColors.primary),
          suffixText: 'cm',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال الطول';
          }
          final height = double.tryParse(value);
          if (height == null) {
            return 'الرجاء إدخال رقم صحيح';
          }
          if (height < 50 || height > 250) {
            return 'الطول يجب أن يكون بين 50 و 250 سم';
          }
          return null;
        },
        onFieldSubmitted: (_) => _weightFocus.requestFocus(),
      ),
    );
  }

  /// Build weight input field with validation.
  ///
  /// Returns a TextFormField for entering weight in kilograms (20-300 range).
  /// Uses LTR text direction for proper number input.
  Widget _buildWeightField() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextFormField(
        controller: _weightController,
        focusNode: _weightFocus,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        decoration: InputDecoration(
          labelText: 'Weight (kg) | الوزن (كجم)',
          hintText: 'e.g., 75.5',
          prefixIcon: const Icon(
            Icons.monitor_weight,
            color: AppColors.primary,
          ),
          suffixText: 'kg',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال الوزن';
          }
          final weight = double.tryParse(value);
          if (weight == null) {
            return 'الرجاء إدخال رقم صحيح';
          }
          if (weight < 20 || weight > 300) {
            return 'الوزن يجب أن يكون بين 20 و 300 كجم';
          }
          return null;
        },
        onFieldSubmitted: (_) => _waistFocus.requestFocus(),
      ),
    );
  }

  /// Build waist circumference input field with validation.
  ///
  /// Returns a TextFormField for entering waist circumference in centimeters
  /// (40-200 range). Uses LTR text direction for proper number input.
  Widget _buildWaistField() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextFormField(
        controller: _waistController,
        focusNode: _waistFocus,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        decoration: InputDecoration(
          labelText: 'Waist Circumference (cm) | محيط الخصر (سم)',
          hintText: 'e.g., 85.0',
          prefixIcon: const Icon(
            Icons.settings_ethernet,
            color: AppColors.primary,
          ),
          suffixText: 'cm',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال محيط الخصر';
          }
          final waist = double.tryParse(value);
          if (waist == null) {
            return 'الرجاء إدخال رقم صحيح';
          }
          if (waist < 40 || waist > 200) {
            return 'محيط الخصر يجب أن يكون بين 40 و 200 سم';
          }
          return null;
        },
        onFieldSubmitted: (_) => _hipFocus.requestFocus(),
      ),
    );
  }

  /// Build hip circumference input field with validation.
  ///
  /// Returns an optional TextFormField for entering hip circumference in
  /// centimeters (50-200 range). Uses LTR text direction for proper
  /// number input.
  Widget _buildHipField() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextFormField(
        controller: _hipController,
        focusNode: _hipFocus,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        decoration: InputDecoration(
          labelText: 'Hip Circumference (cm) | محيط الورك (سم) - اختياري',
          hintText: 'e.g., 100.0',
          prefixIcon: const Icon(
            Icons.settings_ethernet,
            color: AppColors.primary,
          ),
          suffixText: 'cm',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return null; // Optional field
          }
          final hip = double.tryParse(value);
          if (hip == null) {
            return 'الرجاء إدخال رقم صحيح';
          }
          if (hip < 50 || hip > 200) {
            return 'محيط الورك يجب أن يكون بين 50 و 200 سم';
          }
          return null;
        },
      ),
    );
  }

  /// Build BMI card with visual health indicator.
  ///
  /// Returns a card displaying the calculated BMI value, category,
  /// and a visual progress bar showing where the BMI falls on the scale.
  ///
  /// **Throws:** AssertionError if _bmi is null
  Widget _buildBMICard() {
    final bmiCategory = _getBMICategory(_bmi!);
    final bmiColor = _getBMIColor(_bmi!);

    return FadeIn(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bmiColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: bmiColor.withValues(alpha: 0.3), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Body Mass Index (BMI)',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: bmiColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    bmiCategory,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _bmi!.toStringAsFixed(1),
                    style: AppTextStyles.h3.copyWith(
                      color: bmiColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'kg/m²',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Visual Progress Bar
            _buildBMIProgressBar(_bmi!),
            const SizedBox(height: 12),
            // BMI Scale Labels
            _buildBMIScaleLabels(),
          ],
        ),
      ),
    );
  }

  /// Build BMI progress bar visual indicator.
  ///
  /// Creates a gradient bar showing the BMI scale from underweight
  /// to obese, with an indicator positioned at the current BMI value.
  ///
  /// **Parameters:**
  /// - [bmi]: The calculated BMI value to display
  Widget _buildBMIProgressBar(double bmi) {
    // Calculate position (0-1) for BMI range 10-40
    final position = ((bmi - 10) / 30).clamp(0.0, 1.0);

    return Stack(
      children: [
        // Background gradient bar
        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF2196F3), // Blue (Underweight)
                Color(0xFF4CAF50), // Green (Normal)
                Color(0xFFFF9800), // Orange (Overweight)
                Color(0xFFF44336), // Red (Obese)
              ],
            ),
          ),
        ),
        // Indicator
        Positioned(
          left: position * (MediaQuery.of(context).size.width - 88),
          top: -4,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: _getBMIColor(bmi), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build BMI scale labels.
  ///
  /// Returns a row of text labels showing the BMI category ranges:
  /// - Underweight: < 18.5
  /// - Normal: 18.5-24.9
  /// - Overweight: 25-29.9
  /// - Obese: ≥ 30
  Widget _buildBMIScaleLabels() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '< 18.5',
          style: TextStyle(fontSize: 10, color: Color(0xFF2196F3)),
        ),
        Text(
          '18.5-24.9',
          style: TextStyle(fontSize: 10, color: Color(0xFF4CAF50)),
        ),
        Text(
          '25-29.9',
          style: TextStyle(fontSize: 10, color: Color(0xFFFF9800)),
        ),
        Text('≥ 30', style: TextStyle(fontSize: 10, color: Color(0xFFF44336))),
      ],
    );
  }

  /// Build WHR card with visual health indicator.
  ///
  /// Returns a card displaying the calculated WHR value, category,
  /// and a description of the health implications.
  ///
  /// **Throws:** AssertionError if _whr is null
  Widget _buildWHRCard() {
    final whrCategory = _getWHRCategory(_whr!);
    final whrColor = _getWHRColor(_whr!);

    return FadeIn(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: whrColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: whrColor.withValues(alpha: 0.3), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Waist-to-Hip Ratio (WHR)',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: whrColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    whrCategory,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                _whr!.toStringAsFixed(2),
                style: AppTextStyles.h3.copyWith(
                  color: whrColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getWHRDescription(_whr!),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get BMI category based on value.
  ///
  /// Returns the Arabic category label for the given BMI value:
  /// - < 18.5: نحافة (Underweight)
  /// - 18.5-24.9: طبيعي (Normal)
  /// - 25-29.9: وزن زائد (Overweight)
  /// - ≥ 30: سمنة (Obese)
  ///
  /// **Parameters:**
  /// - [bmi]: The BMI value to categorize
  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'نحافة';
    if (bmi < 25) return 'طبيعي';
    if (bmi < 30) return 'وزن زائد';
    return 'سمنة';
  }

  /// Get BMI color for visual indication.
  ///
  /// Returns the color corresponding to the BMI category:
  /// - < 18.5: Blue (Underweight)
  /// - 18.5-24.9: Green (Normal)
  /// - 25-29.9: Orange (Overweight)
  /// - ≥ 30: Red (Obese)
  ///
  /// **Parameters:**
  /// - [bmi]: The BMI value to get color for
  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return const Color(0xFF2196F3); // Blue
    if (bmi < 25) return const Color(0xFF4CAF50); // Green
    if (bmi < 30) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }

  /// Get WHR category based on value.
  ///
  /// Returns the Arabic category label for the given WHR value:
  /// - < 0.85: منخفض (Low)
  /// - 0.85-0.94: معتدل (Moderate)
  /// - ≥ 0.95: مرتفع (High)
  ///
  /// **Note:** Simplified for both males and females
  ///
  /// **Parameters:**
  /// - [whr]: The WHR value to categorize
  String _getWHRCategory(double whr) {
    // For both males and females (simplified)
    if (whr < 0.85) return 'منخفض';
    if (whr < 0.95) return 'معتدل';
    return 'مرتفع';
  }

  /// Get WHR color for visual indication.
  ///
  /// Returns the color corresponding to the WHR category:
  /// - < 0.85: Green (Low risk)
  /// - 0.85-0.94: Orange (Moderate risk)
  /// - ≥ 0.95: Red (High risk)
  ///
  /// **Parameters:**
  /// - [whr]: The WHR value to get color for
  Color _getWHRColor(double whr) {
    if (whr < 0.85) return const Color(0xFF4CAF50); // Green
    if (whr < 0.95) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }

  /// Get WHR health description.
  ///
  /// Returns an Arabic description of the health implications
  /// for the given WHR value.
  ///
  /// **Parameters:**
  /// - [whr]: The WHR value to get description for
  String _getWHRDescription(double whr) {
    if (whr < 0.85) {
      return 'توزيع دهون صحي على الجسم';
    } else if (whr < 0.95) {
      return 'توزيع دهون معتدل - مراقبة مطلوبة';
    } else {
      return 'توزيع دهون غير صحي - خطر أمراض القلب';
    }
  }
}
