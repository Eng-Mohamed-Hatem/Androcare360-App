import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/constants/app_strings.dart';
import 'package:elajtech/features/patient/home/data/models/medical_screening_model.dart';
import 'package:elajtech/features/patient/home/presentation/providers/medical_screening_provider.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MedicalScreeningScreen extends ConsumerStatefulWidget {
  const MedicalScreeningScreen({super.key});

  @override
  ConsumerState<MedicalScreeningScreen> createState() =>
      _MedicalScreeningScreenState();
}

class _MedicalScreeningScreenState
    extends ConsumerState<MedicalScreeningScreen> {
  late MedicalScreeningModel _draftModel;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _draftModel = const MedicalScreeningModel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _isInit = true;
      final patientId = ref.read(authProvider).user?.id;
      if (patientId != null) {
        Future.microtask(() {
          ref.read(medicalScreeningProvider.notifier).loadData(patientId);
        });
      }
    }
  }

  void _updateDraft(MedicalScreeningModel model) {
    setState(() {
      _draftModel = model;
    });
  }

  void _onSave(String patientId) {
    ref
        .read(medicalScreeningProvider.notifier)
        .saveData(patientId, _draftModel);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicalScreeningProvider);
    final patientId = ref.watch(authProvider).user?.id;

    if (patientId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.medicalScreening)),
        body: const Center(child: Text(AppStrings.error)),
      );
    }

    if (state.isLoading && state.model == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.medicalScreening)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Synchronize draft model when the state model changes
    ref.listen(medicalScreeningProvider, (previous, next) {
      if (next.model != null && previous?.model != next.model) {
        if (!mounted) return;
        setState(() {
          _draftModel = next.model!;
        });
      }
    });

    // Populate draft model on initial load if data is already available
    // and hasn't been synced yet (avoiding overwriting user changes)
    if (state.model != null &&
        !state.isEditMode &&
        _draftModel == const MedicalScreeningModel() &&
        !state.isLoading) {
      _draftModel = state.model!;
    }

    ref.listen(medicalScreeningProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
      if (next.isSuccess && previous?.isSuccess != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.medicalScreeningSavedSuccessfully),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.comprehensiveHealthScreening),
      ),
      body: state.isLoading && state.model == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.isEditMode)
                    _buildEditForm(context, state)
                  else
                    _buildReadOnlyView(context, state),
                ],
              ),
            ),
      bottomNavigationBar: state.isLoading && state.model == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: state.isEditMode
                    ? ElevatedButton(
                        onPressed: state.isLoading
                            ? null
                            : () => _onSave(patientId),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: state.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(AppStrings.save),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          ref
                              .read(medicalScreeningProvider.notifier)
                              .toggleEditMode();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.secondary,
                        ),
                        child: const Text(AppStrings.editData),
                      ),
              ),
            ),
    );
  }

  Widget _buildEditForm(BuildContext context, MedicalScreeningState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.medicalScreeningIntro,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        _buildCheckbox(
          title: AppStrings.diabetes,
          value: _draftModel.diabetes,
          onChanged: (val) => _updateDraft(
            _draftModel.copyWith(diabetes: val ?? false),
          ),
        ),
        _buildCheckbox(
          title: AppStrings.hypertension,
          value: _draftModel.hypertension,
          onChanged: (val) => _updateDraft(
            _draftModel.copyWith(hypertension: val ?? false),
          ),
        ),
        _buildCheckbox(
          title: AppStrings.heartDiseases,
          value: _draftModel.heartDiseases,
          onChanged: (val) => _updateDraft(
            _draftModel.copyWith(heartDiseases: val ?? false),
          ),
        ),
        _buildCheckbox(
          title: AppStrings.prostate,
          value: _draftModel.prostate,
          onChanged: (val) => _updateDraft(
            _draftModel.copyWith(prostate: val ?? false),
          ),
        ),
        _buildCheckbox(
          title: AppStrings.jointDiseases,
          value: _draftModel.jointDiseases,
          onChanged: (val) => _updateDraft(
            _draftModel.copyWith(jointDiseases: val ?? false),
          ),
        ),
        _buildCheckbox(
          title: AppStrings.obesity,
          value: _draftModel.obesity,
          onChanged: (val) => _updateDraft(
            _draftModel.copyWith(obesity: val ?? false),
          ),
        ),
        _buildCheckbox(
          title: AppStrings.previousSurgeries,
          value: _draftModel.previousSurgeries,
          onChanged: (val) => _updateDraft(
            _draftModel.copyWith(previousSurgeries: val ?? false),
          ),
        ),
        _buildCheckbox(
          title: AppStrings.smokingOrAlcohol,
          value: _draftModel.smokingOrAlcohol,
          onChanged: (val) => _updateDraft(
            _draftModel.copyWith(smokingOrAlcohol: val ?? false),
          ),
        ),
        _buildCheckbox(
          title: AppStrings.allergicDiseases,
          value: _draftModel.allergicDiseases,
          onChanged: (val) => _updateDraft(
            _draftModel.copyWith(allergicDiseases: val ?? false),
          ),
        ),
        _buildCheckbox(
          title: AppStrings.kidneyDiseases,
          value: _draftModel.kidneyDiseases,
          onChanged: (val) => _updateDraft(
            _draftModel.copyWith(kidneyDiseases: val ?? false),
          ),
        ),
        _buildCheckbox(
          title: AppStrings.previousAccidents,
          value: _draftModel.previousAccidents,
          onChanged: (val) => _updateDraft(
            _draftModel.copyWith(previousAccidents: val ?? false),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyView(BuildContext context, MedicalScreeningState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.model != null) _buildInfoBanner(context),
        const SizedBox(height: 16),
        _buildSectionHeader(context, AppStrings.chronicDiseases),
        _buildReadOnlyItem(AppStrings.diabetes, _draftModel.diabetes),
        _buildReadOnlyItem(AppStrings.hypertension, _draftModel.hypertension),
        _buildReadOnlyItem(AppStrings.heartDiseases, _draftModel.heartDiseases),
        _buildReadOnlyItem(
          AppStrings.kidneyDiseases,
          _draftModel.kidneyDiseases,
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(context, AppStrings.specializedConditions),
        _buildReadOnlyItem(AppStrings.prostate, _draftModel.prostate),
        _buildReadOnlyItem(AppStrings.jointDiseases, _draftModel.jointDiseases),
        _buildReadOnlyItem(
          AppStrings.allergicDiseases,
          _draftModel.allergicDiseases,
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(context, AppStrings.lifestyleAndHistory),
        _buildReadOnlyItem(AppStrings.obesity, _draftModel.obesity),
        _buildReadOnlyItem(
          AppStrings.previousSurgeries,
          _draftModel.previousSurgeries,
        ),
        _buildReadOnlyItem(
          AppStrings.previousAccidents,
          _draftModel.previousAccidents,
        ),
        _buildReadOnlyItem(
          AppStrings.smokingOrAlcohol,
          _draftModel.smokingOrAlcohol,
        ),
      ],
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppStrings.medicalScreeningSavedInfo,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildReadOnlyItem(String title, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(title),
        trailing: Chip(
          label: Text(
            value ? AppStrings.yes : AppStrings.no,
            style: TextStyle(
              color: value ? AppColors.success : AppColors.textSecondaryLight,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          backgroundColor: value
              ? AppColors.success.withOpacity(0.1)
              : AppColors.textSecondaryLight.withOpacity(0.1),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildCheckbox({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
}
