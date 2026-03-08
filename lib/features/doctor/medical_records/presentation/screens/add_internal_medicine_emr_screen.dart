import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/emr/domain/repositories/internal_medicine_emr_repository.dart';
import 'package:elajtech/shared/models/internal_medicine_emr_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

/// Add Internal Medicine EMR Screen
class AddInternalMedicineEMRScreen extends ConsumerStatefulWidget {
  const AddInternalMedicineEMRScreen({
    required this.patientId,
    required this.patientName,
    required this.appointmentId,
    super.key,
  });

  final String patientId;
  final String patientName;
  final String appointmentId;

  @override
  ConsumerState<AddInternalMedicineEMRScreen> createState() =>
      _AddInternalMedicineEMRScreenState();
}

class _AddInternalMedicineEMRScreenState
    extends ConsumerState<AddInternalMedicineEMRScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // System Review selections
  final Map<String, List<String>> _systemReviewSelections = {};
  final Map<String, TextEditingController> _systemOtherControllers = {};

  // Chronic Disease selections
  final Map<String, List<String>> _chronicDiseaseSelections = {};
  final Map<String, TextEditingController> _diseaseOtherControllers = {};

  // ICD-10 selection (now single selection)
  String? _selectedICD10Code;

  // Notes
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    // ═══════════════════════════════════════════════════════════════════════
    // DEBUG LOGGING FOR INTERNAL MEDICINE EMR
    // ═══════════════════════════════════════════════════════════════════════
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('\n══════════════════════════════════════════════════════');
        debugPrint('📋 Internal Medicine EMR Screen Initialized');
        debugPrint('──────────────────────────────────────────────────────');
        debugPrint('👤 Patient Information:');
        debugPrint('   Patient ID: ${widget.patientId}');
        debugPrint('   Patient Name: ${widget.patientName}');
        debugPrint('   Appointment ID: ${widget.appointmentId}');
        debugPrint('──────────────────────────────────────────────────────');
        final user = ref.read(authProvider).user;
        debugPrint('👨‍⚕️ Doctor Information:');
        debugPrint('   Doctor ID: ${user?.id ?? "null"}');
        debugPrint('   Doctor Name: ${user?.fullName ?? "null"}');
        debugPrint(
          '   Specializations: ${user?.specializations?.join(", ") ?? "null"}',
        );
        debugPrint('══════════════════════════════════════════════════════\n');
      });
    }
  }

  void _initializeControllers() {
    // Initialize other text controllers for each system
    for (final system in SystemReviewOptions.systems.keys) {
      _systemOtherControllers[system] = TextEditingController();
      _systemReviewSelections[system] = [];
    }

    // Initialize other text controllers for each disease
    for (final disease in ChronicDiseaseOptions.diseases.keys) {
      _diseaseOtherControllers[disease] = TextEditingController();
      _chronicDiseaseSelections[disease] = [];
    }
  }

  @override
  void dispose() {
    _systemOtherControllers.forEach((_, controller) => controller.dispose());
    _diseaseOtherControllers.forEach((_, controller) => controller.dispose());
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if at least some data is entered
    final hasSystemData = _systemReviewSelections.values.any(
      (list) => list.isNotEmpty,
    );
    final hasDiseaseData = _chronicDiseaseSelections.values.any(
      (list) => list.isNotEmpty,
    );
    final hasICD10 = _selectedICD10Code != null;

    if (!hasSystemData && !hasDiseaseData && !hasICD10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one item from any section'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authProvider).user!;

      // Add "Other" text to selections if provided
      _systemOtherControllers.forEach((system, controller) {
        if (controller.text.trim().isNotEmpty) {
          _systemReviewSelections[system]!.add(
            'Other: ${controller.text.trim()}',
          );
        }
      });

      _diseaseOtherControllers.forEach((disease, controller) {
        if (controller.text.trim().isNotEmpty) {
          _chronicDiseaseSelections[disease]!.add(
            'Other: ${controller.text.trim()}',
          );
        }
      });

      // Remove empty entries
      final systemReview = Map.fromEntries(
        _systemReviewSelections.entries.where(
          (entry) => entry.value.isNotEmpty,
        ),
      );

      final chronicDiseases = Map.fromEntries(
        _chronicDiseaseSelections.entries.where(
          (entry) => entry.value.isNotEmpty,
        ),
      );

      final emr = InternalMedicineEMRModel(
        id: const Uuid().v4(),
        patientId: widget.patientId,
        doctorId: user.id,
        doctorName: user.fullName,
        appointmentId: widget.appointmentId,
        createdAt: DateTime.now(),
        systemReview: systemReview,
        chronicDiseases: chronicDiseases,
        icd10Codes: _selectedICD10Code != null ? [_selectedICD10Code!] : [],
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      final result = await GetIt.I<InternalMedicineEMRRepository>().saveEMR(
        emr,
      );

      result.fold(
        (failure) => throw Exception(failure.message),
        (_) => null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('EMR saved successfully')),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Internal Medicine EMR'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader('A. System Review'),
              ..._buildSystemReviewSections(),
              const SizedBox(height: 24),
              _buildSectionHeader('B. Chronic Disease Groups'),
              ..._buildChronicDiseaseSections(),
              const SizedBox(height: 24),
              _buildSectionHeader('C. ICD-10 Favorites'),
              _buildICD10Section(),
              const SizedBox(height: 24),
              _buildSectionHeader('Additional Notes'),
              _buildTextField('Notes', _notesController, maxLines: 3),
              const SizedBox(height: 32),
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
                      : const Text('Save EMR', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

  List<Widget> _buildSystemReviewSections() {
    return SystemReviewOptions.systems.entries.map((entry) {
      final systemKey = entry.key;
      final symptoms = entry.value;
      final label = SystemReviewOptions.systemLabels[systemKey] ?? systemKey;

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        child: ExpansionTile(
          title: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ...symptoms.map(
                    (symptom) => CheckboxListTile(
                      title: Text(symptom),
                      value: _systemReviewSelections[systemKey]!.contains(
                        symptom,
                      ),
                      onChanged: (checked) {
                        setState(() {
                          if (checked ?? false) {
                            _systemReviewSelections[systemKey]!.add(symptom);
                          } else {
                            _systemReviewSelections[systemKey]!.remove(symptom);
                          }
                        });
                      },
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _systemOtherControllers[systemKey],
                    decoration: const InputDecoration(
                      labelText: 'Other (specify)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildChronicDiseaseSections() {
    return ChronicDiseaseOptions.diseases.entries.map((entry) {
      final diseaseKey = entry.key;
      final items = entry.value;
      final label =
          ChronicDiseaseOptions.diseaseLabels[diseaseKey] ?? diseaseKey;

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        child: ExpansionTile(
          title: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ...items.map(
                    (item) => CheckboxListTile(
                      title: Text(item),
                      value: _chronicDiseaseSelections[diseaseKey]!.contains(
                        item,
                      ),
                      onChanged: (checked) {
                        setState(() {
                          if (checked ?? false) {
                            _chronicDiseaseSelections[diseaseKey]!.add(item);
                          } else {
                            _chronicDiseaseSelections[diseaseKey]!.remove(item);
                          }
                        });
                      },
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _diseaseOtherControllers[diseaseKey],
                    decoration: const InputDecoration(
                      labelText: 'Other (specify)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildICD10Section() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a Diagnosis Code:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            // Migrated to RadioGroup API - Flutter 3.27+ breaking change
            RadioGroup<String>(
              groupValue: _selectedICD10Code,
              onChanged: (value) {
                setState(() {
                  _selectedICD10Code = value;
                });
              },
              child: Column(
                children: ICD10Codes.codes.map((codeData) {
                  final codeWithDesc =
                      '${codeData['code']} - ${codeData['description']}';
                  final code = codeData['code']!;

                  return RadioListTile<String>(
                    title: Text(codeWithDesc),
                    value: code,
                    // Removed groupValue and onChanged - managed by RadioGroup ancestor
                    dense: true,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
            ),
          ],
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
        maxLines: maxLines,
      ),
    );
  }
}
