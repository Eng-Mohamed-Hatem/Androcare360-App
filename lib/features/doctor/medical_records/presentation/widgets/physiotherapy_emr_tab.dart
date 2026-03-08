import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/doctor/medical_records/domain/constants/physiotherapy_questions.dart';
import 'package:elajtech/features/doctor/medical_records/domain/entities/physiotherapy_emr.dart';
import 'package:elajtech/features/doctor/medical_records/presentation/providers/physiotherapy_emr_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

/// Physical Therapy EMR Tab Widget
///
/// Displays comprehensive physical therapy assessment form with:
/// - Dynamic checklist sections based on physiotherapyQuestions Map
/// - 2 unified multi-line text fields (primary diagnosis, management plan)
/// - English medical terminology with LTR direction
class PhysiotherapyEMRTab extends ConsumerStatefulWidget {
  const PhysiotherapyEMRTab({
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.appointmentId,
    required this.visitDate,
    super.key,
  });

  final String patientId;
  final String doctorId;
  final String doctorName;
  final String appointmentId;
  final DateTime visitDate;

  @override
  ConsumerState<PhysiotherapyEMRTab> createState() =>
      PhysiotherapyEMRTabState();
}

class PhysiotherapyEMRTabState extends ConsumerState<PhysiotherapyEMRTab> {
  // Text controllers for unified text fields
  final _primaryDiagnosisController = TextEditingController();
  final _managementPlanController = TextEditingController();

  // Local state for checkbox selections - unified Map with section titles as keys
  final Map<String, List<String>> _selections = <String, List<String>>{};

  bool get _isLocked {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final visit = DateTime(
      widget.visitDate.year,
      widget.visitDate.month,
      widget.visitDate.day,
    );
    return today.isAfter(visit);
  }

  @override
  void initState() {
    super.initState();

    if (kDebugMode) {
      debugPrint('[PhysioEMRTab] Initializing PhysiotherapyEMRTab');
      debugPrint('   Patient ID: ${widget.patientId}');
      debugPrint('   Doctor ID: ${widget.doctorId}');
      debugPrint('   Appointment ID: ${widget.appointmentId}');
    }

    // Check for existing EMR and load it
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Try to load existing EMR by appointment ID
      await ref
          .read(physiotherapyEMRNotifierProvider.notifier)
          .loadEMRByAppointment(widget.appointmentId);

      // Wait a bit for state to update, then check if EMR exists
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final state = ref.read(physiotherapyEMRNotifierProvider);

      if (state.emr != null) {
        if (kDebugMode) {
          debugPrint('[PhysioEMRTab] Existing EMR found, activating View Mode');
        }
        // Activate view mode if EMR exists
        ref.read(physiotherapyEMRNotifierProvider.notifier).setViewMode(true);

        if (_isLocked) {
          debugPrint('[PhysioEMR] Record is locked due to date expiration.');
        }
      } else {
        if (_isLocked) {
          debugPrint('[PhysioEMR] Record is locked due to date expiration.');
        } else {
          if (kDebugMode) {
            debugPrint(
              '[PhysioEMRTab] No existing EMR, initializing for editing',
            );
          }
          // Initialize new EMR if none exists
          ref
              .read(physiotherapyEMRNotifierProvider.notifier)
              .initializeEMR(
                id: const Uuid().v4(),
                patientId: widget.patientId,
                doctorId: widget.doctorId,
                doctorName: widget.doctorName,
                appointmentId: widget.appointmentId,
                visitDate: widget.visitDate,
              );
        }
      }
    });
  }

  @override
  void dispose() {
    _primaryDiagnosisController.dispose();
    _managementPlanController.dispose();
    super.dispose();
  }

  /// Build section header with divider
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

  /// Build checklist section with ExpansionTile for a given section title
  Widget _buildChecklistSection(String sectionTitle) {
    final questions =
        PhysiotherapyQuestions.physiotherapyQuestions[sectionTitle];
    if (questions == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ExpansionTile(
        title: Text(
          sectionTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.primary,
          ),
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ...questions.map((question) {
                  return CheckboxListTile(
                    title: Text(question),
                    value:
                        _selections[sectionTitle]?.contains(question) ?? false,
                    onChanged: (checked) {
                      setState(() {
                        _selections.putIfAbsent(sectionTitle, () => <String>[]);
                        if (checked ?? false) {
                          _selections[sectionTitle]!.add(question);
                        } else {
                          _selections[sectionTitle]!.remove(question);
                        }
                      });
                    },
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build unified multi-line text field section
  Widget _buildUnifiedTextField(
    String sectionTitle,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildSectionHeader(sectionTitle),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
            controller: controller,
            maxLines: 5,
            minLines: 3,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              labelText: sectionTitle,
              labelStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.all(16),
              hintText: 'Enter $sectionTitle details...',
            ),
          ),
        ),
      ],
    );
  }

  /// Get current EMR data for saving
  PhysiotherapyEMR _getCurrentEMRData() {
    return PhysiotherapyEMR(
      id: const Uuid().v4(),
      patientId: widget.patientId,
      doctorId: widget.doctorId,
      doctorName: widget.doctorName,
      appointmentId: widget.appointmentId,
      visitDate: widget.visitDate,
      createdAt: DateTime.now(),
      basics: <String, List<String>>{
        'selected': _selections['Patient & Visit Basics'] ?? <String>[],
      },
      painAssessment: <String, List<String>>{
        'selected': _selections['Pain Assessment'] ?? <String>[],
      },
      functionalAssessment: <String, List<String>>{
        'selected': _selections['Functional Status'] ?? <String>[],
      },
      systemsReview: <String, List<String>>{
        'selected': _selections['Systems Screening'] ?? <String>[],
      },
      rangeOfMotion: <String, List<String>>{
        'selected': _selections['Range of Motion'] ?? <String>[],
      },
      strengthAssessment: <String, List<String>>{
        'selected': _selections['Strength Testing'] ?? <String>[],
      },
      devicesEquipment: <String, List<String>>{
        'selected': _selections['Assistive Devices'] ?? <String>[],
      },
      treatmentPlan: <String, List<String>>{
        'selected': _selections['Plan'] ?? <String>[],
      },
      primaryDiagnosis: _primaryDiagnosisController.text.trim().isEmpty
          ? null
          : _primaryDiagnosisController.text.trim(),
      managementPlan: _managementPlanController.text.trim().isEmpty
          ? null
          : _managementPlanController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(physiotherapyEMRNotifierProvider);

    // Handle loading state
    if (state.isLoading) {
      return const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Handle error state
    if (state.error != null) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${state.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(physiotherapyEMRNotifierProvider.notifier)
                    .loadEMRByAppointment(widget.appointmentId),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Switch between View Mode and Edit Mode
    if ((state.isViewMode && state.emr != null) ||
        (_isLocked && state.emr != null)) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildSectionHeader('Physical Therapy Assessment'),
              const SizedBox(height: 8),

              // View Mode Content
              _buildViewModeContent(state.emr!),

              const SizedBox(height: 48), // Bottom padding
            ],
          ),
        ),
      );
    }

    if (_isLocked && state.emr == null) {
      return const Center(
        child: Text(
          'Record is locked due to date expiration.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // Edit Mode (Default)
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header
            _buildSectionHeader('Physical Therapy Assessment'),
            const SizedBox(height: 8),

            // Dynamic checklist sections based on physiotherapyQuestions Map
            ...PhysiotherapyQuestions.physiotherapyQuestions.entries.map((
              entry,
            ) {
              return _buildChecklistSection(entry.key);
            }),

            const SizedBox(height: 24),

            // Primary Diagnosis (Unified multi-line text field)
            _buildUnifiedTextField(
              'Primary Diagnosis',
              _primaryDiagnosisController,
            ),

            const SizedBox(height: 24),

            // Management Plan (Unified multi-line text field)
            _buildUnifiedTextField(
              'Management Plan',
              _managementPlanController,
            ),

            const SizedBox(height: 48), // Bottom padding
          ],
        ),
      ),
    );
  }

  /// Public method to get current EMR data (called from parent screen)
  PhysiotherapyEMR getEMRData() => _getCurrentEMRData();

  /// Build View Mode content - read-only summary of EMR data
  Widget _buildViewModeContent(PhysiotherapyEMR emr) {
    if (kDebugMode) {
      debugPrint('[PhysioEMRTab] Building view mode content');
      debugPrint('[PhysioEMRTab] View mode data: ${emr.toJson()}');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // 1. Patient & Visit Basics
        _buildSelectedItemsSection(
          'Patient & Visit Basics',
          emr.basics['selected'] ?? <String>[],
        ),

        // 2. Pain Assessment
        _buildSelectedItemsSection(
          'Pain Assessment',
          emr.painAssessment['selected'] ?? <String>[],
        ),

        // 3. Functional Status
        _buildSelectedItemsSection(
          'Functional Status',
          emr.functionalAssessment['selected'] ?? <String>[],
        ),

        // 4. Systems Screening
        _buildSelectedItemsSection(
          'Systems Screening',
          emr.systemsReview['selected'] ?? <String>[],
        ),

        // 5. Range of Motion
        _buildSelectedItemsSection(
          'Range of Motion',
          emr.rangeOfMotion['selected'] ?? <String>[],
        ),

        // 6. Strength Testing
        _buildSelectedItemsSection(
          'Strength Testing',
          emr.strengthAssessment['selected'] ?? <String>[],
        ),

        // 7. Assistive Devices
        _buildSelectedItemsSection(
          'Assistive Devices',
          emr.devicesEquipment['selected'] ?? <String>[],
        ),

        // 8. Plan
        _buildSelectedItemsSection(
          'Plan',
          emr.treatmentPlan['selected'] ?? <String>[],
        ),

        // Primary Diagnosis
        if (emr.primaryDiagnosis != null && emr.primaryDiagnosis!.isNotEmpty)
          _buildTextSection('Primary Diagnosis', emr.primaryDiagnosis!),

        // Management Plan
        if (emr.managementPlan != null && emr.managementPlan!.isNotEmpty)
          _buildTextSection('Management Plan', emr.managementPlan!),

        const SizedBox(height: 16),

        // Edit Button
        if (!_isLocked) _buildEditButton(),
      ],
    );
  }

  /// Build selected items section with chips
  Widget _buildSelectedItemsSection(
    String sectionTitle,
    List<String> selectedItems,
  ) {
    if (selectedItems.isEmpty) {
      return _buildEmptySectionMessage(sectionTitle);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sectionTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedItems.map(_buildSelectedChip).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty section message
  Widget _buildEmptySectionMessage(String sectionTitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No items selected in $sectionTitle',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build selected chip widget
  Widget _buildSelectedChip(String item) {
    return Chip(
      label: Text(
        item,
        style: const TextStyle(fontSize: 14),
      ),
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      side: const BorderSide(color: AppColors.primary),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  /// Build text section for diagnosis and management plan
  Widget _buildTextSection(String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  /// Build edit button to switch back to edit mode
  Widget _buildEditButton() {
    return ElevatedButton.icon(
      onPressed: () {
        if (kDebugMode) {
          debugPrint(
            '[PhysioEMRTab] Edit button pressed - switching to edit mode',
          );
        }
        ref.read(physiotherapyEMRNotifierProvider.notifier).setViewMode(false);
      },
      icon: const Icon(Icons.edit),
      label: const Text('Edit EMR'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }
}
