// ignore_for_file: all  
// ignore_for_file: all
# 🏗️ Nutrition EMR Presentation Layer - Executive Architecture Plan

## 📋 Document Control

| Property | Value |
|----------|-------|
| **Project** | Androcare360 - Nutrition Clinic EMR |
| **Phase** | Phase 3: Presentation Layer Implementation |
| **Status** | Architecture Design - Awaiting Approval |
| **Created** | 2026-01-22 |
| **Owner** | Kilo Code Architect |
| **Database** | elajtech (databaseId) |
| **Collection** | nutrition_emrs |

---

## 🎯 Executive Summary

This document outlines the comprehensive architecture for the **Nutrition EMR Presentation Layer**, featuring a hybrid Wizard/Tabbed interface with advanced state management, 24-hour lock mechanism, and intelligent auto-save functionality. The implementation follows Clean Architecture principles and integrates seamlessly with the existing Data and Domain layers.

### Key Deliverables

1. **State Management Layer** (Riverpod-based)
   - `NutritionEMRNotifier` - Core state management
   - `NutritionWizardStateNotifier` - Wizard navigation control
   - `NutritionViewModeProvider` - View/Edit mode management

2. **UI Components Layer**
   - `NutritionClinicScreen` - Main entry point
   - `NutritionWizardView` - 8-step wizard interface
   - `NutritionTabbedView` - Quick access tabbed interface
   - Reusable widgets for checkboxes, chips, and indicators

3. **Supporting Systems**
   - Lock status tracking and warnings
   - Dirty flag detection for unsaved changes
   - Auto-save draft mechanism (30-second intervals)
   - Offline mode support

---

## 📊 Current Architecture Analysis

### ✅ Completed Layers (Review)

#### Domain Layer
- **Entity**: [`NutritionEMREntity`](lib/features/nutrition/domain/entities/nutrition_emr_entity.dart:1)
  - 32 boolean checkbox fields across 8 sections
  - Computed properties: `completionPercentage`, `isCurrentlyLocked`, `remainingEditHours`
  - Freezed immutability with JSON serialization
  - Built-in audit log support

- **Repository Interface**: [`NutritionEMRRepository`](lib/features/nutrition/domain/repositories/nutrition_emr_repository.dart:1)
  - CRUD operations with Either<Failure, T> pattern
  - Lock management methods
  - Real-time stream support

#### Data Layer
- **Model**: [`NutritionEMRModel`](lib/features/nutrition/data/models/nutrition_emr_model.dart:1)
  - Bidirectional Entity ↔ Firestore conversion
  - Server timestamp injection
  - Safe null handling

- **Repository Implementation**: [`NutritionEMRRepositoryImpl`](lib/features/nutrition/data/repositories/nutrition_emr_repository_impl.dart:1)
  - Firestore operations with `databaseId: 'elajtech'`
  - Comprehensive debug logging
  - Exception handling with Dartz Either

### 🔍 Patterns from Existing Codebase

From [`PhysiotherapyEMRTab`](lib/features/doctor/medical_records/presentation/widgets/physiotherapy_emr_tab.dart:1) analysis:

1. **State Management Pattern**:
   - Uses `StateNotifier<State>` (not AsyncNotifier)
   - Custom state class with copyWith method
   - GetIt integration via Provider

2. **Lock Mechanism**:
   - Date-based locking (comparing visit date to today)
   - Automatic View Mode activation when locked
   - Edit button hidden when locked

3. **UI Structure**:
   - ExpansionTile for checkbox sections
   - Chips for read-only display
   - Separate View Mode and Edit Mode rendering

4. **Lifecycle Management**:
   - Load existing EMR in `initState` with `addPostFrameCallback`
   - Auto-activate View Mode if EMR exists
   - Initialize new EMR if none exists

---

## 🏛️ Presentation Layer Architecture Design

### 1. State Management Layer

#### 1.1 NutritionEMRState Class

```dart
/// State container for Nutrition EMR operations
class NutritionEMRState {
  const NutritionEMRState({
    this.emr,
    this.isLoading = false,
    this.error,
    this.isSaved = false,
    this.isDirty = false,
    this.lastAutoSaveTime,
  });

  final NutritionEMREntity? emr;
  final bool isLoading;
  final String? error;
  final bool isSaved;
  final bool isDirty; // Tracks unsaved changes
  final DateTime? lastAutoSaveTime;

  NutritionEMRState copyWith({...}) {...}
}
```

**Features:**
- Tracks loading, error, and save states
- `isDirty` flag for unsaved changes detection
- `lastAutoSaveTime` for auto-save tracking

#### 1.2 NutritionEMRNotifier

```dart
/// Core state notifier for Nutrition EMR management
class NutritionEMRNotifier extends StateNotifier<NutritionEMRState> {
  NutritionEMRNotifier(this._repository) : super(const NutritionEMRState()) {
    _startAutoSaveTimer(); // Initialize auto-save on creation
  }

  final NutritionEMRRepository _repository;
  Timer? _autoSaveTimer;

  // Core CRUD Operations
  Future<void> loadEMRByAppointment(String appointmentId) {...}
  Future<void> saveEMR({bool isDraft = false}) {...}
  
  // Checkbox Update with Optimistic UI
  void updateCheckbox(String fieldName, bool value) {
    if (state.emr == null || state.emr!.isCurrentlyLocked) return;
    
    // Optimistic update
    final updatedEMR = _updateCheckboxField(state.emr!, fieldName, value);
    state = state.copyWith(
      emr: updatedEMR,
      isDirty: true,
      isSaved: false,
    );
  }

  // Auto-save system
  void _startAutoSaveTimer() {
    _autoSaveTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _autoSaveDraft(),
    );
  }

  Future<void> _autoSaveDraft() async {
    if (!state.isDirty || state.emr == null) return;
    await saveEMR(isDraft: true);
  }

  // Lock management
  bool get isLocked => state.emr?.isCurrentlyLocked ?? false;
  int get remainingHours => state.emr?.remainingEditHours ?? 0;

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }
}
```

**Key Methods:**
1. **loadEMRByAppointment**: Fetches existing EMR or creates new
2. **saveEMR**: Saves with audit log entry, supports draft mode
3. **updateCheckbox**: Optimistic UI update with dirty flag
4. **_autoSaveDraft**: Background save every 30 seconds

#### 1.3 NutritionWizardState & Notifier

```dart
/// Wizard navigation state
class NutritionWizardState {
  const NutritionWizardState({
    this.currentStep = 0,
    this.completedSteps = const {},
    this.visitedSteps = const {},
  });

  final int currentStep;
  final Set<int> completedSteps;
  final Set<int> visitedSteps;

  bool isStepComplete(int step) => completedSteps.contains(step);
  bool canProceedToNext(int currentStep) {
    // Validation logic per step
  }
}

/// Wizard navigation controller
class NutritionWizardNotifier extends StateNotifier<NutritionWizardState> {
  NutritionWizardNotifier(this._emrRef) : super(const NutritionWizardState());

  final Ref _emrRef;

  void goToStep(int step) {...}
  void nextStep() {...}
  void previousStep() {...}
  
  bool _validateStep(int step) {
    final emr = _emrRef.read(nutritionEMRNotifierProvider).emr;
    if (emr == null) return false;

    switch (step) {
      case 0: // Step 1: Anthropometric
        return emr.weightMeasured || emr.heightMeasured;
      case 1: // Step 2: Medical History
        return emr.medicalHistoryReviewed;
      // ... other steps
    }
  }

  void markStepComplete(int step) {...}
}
```

**Features:**
- Tracks current step, completed steps, visited steps
- Step validation before navigation
- Prevents skipping required steps

#### 1.4 NutritionViewModeProvider

```dart
/// State for view/edit mode management
class NutritionViewMode {
  const NutritionViewMode({
    this.isViewMode = false,
    this.useWizard = true, // Wizard vs Tabbed
  });

  final bool isViewMode;
  final bool useWizard;
}

/// Simple state notifier for view mode
class NutritionViewModeNotifier extends StateNotifier<NutritionViewMode> {
  NutritionViewModeNotifier() : super(const NutritionViewMode());

  void setViewMode(bool value) {
    state = NutritionViewMode(
      isViewMode: value,
      useWizard: state.useWizard,
    );
  }

  void setWizardMode(bool value) {
    state = NutritionViewMode(
      isViewMode: state.isViewMode,
      useWizard: value,
    );
  }
}
```

**Provider Declarations:**

```dart
// Repository provider
final nutritionEMRRepositoryProvider = Provider<NutritionEMRRepository>(
  (ref) => GetIt.I<NutritionEMRRepository>(),
);

// EMR state provider with autoDispose for memory management
final nutritionEMRNotifierProvider = StateNotifierProvider.autoDispose<
    NutritionEMRNotifier, NutritionEMRState>(
  (ref) {
    final repository = ref.watch(nutritionEMRRepositoryProvider);
    return NutritionEMRNotifier(repository);
  },
);

// Wizard state provider with family for appointmentId
final nutritionWizardNotifierProvider = StateNotifierProvider.autoDispose
    .family<NutritionWizardNotifier, NutritionWizardState, String>(
  (ref, appointmentId) {
    return NutritionWizardNotifier(ref);
  },
);

// View mode provider
final nutritionViewModeProvider = StateNotifierProvider.autoDispose<
    NutritionViewModeNotifier, NutritionViewMode>(
  (ref) => NutritionViewModeNotifier(),
);
```

---

### 2. UI Component Architecture

#### 2.1 Component Hierarchy

```
NutritionClinicScreen (Main Entry)
├── AppBar (Dynamic)
│   ├── Patient Info Display
│   ├── Save Status Indicator
│   └── Lock Status Badge
│
├── Body (Conditional)
│   ├── IF isFirstVisit OR forceWizard
│   │   └── NutritionWizardView
│   │       ├── WizardProgressIndicator
│   │       ├── WizardStepContent
│   │       │   ├── Step1: AnthropometricStep
│   │       │   ├── Step2: MedicalHistoryStep
│   │       │   ├── Step3: DietaryAssessmentStep
│   │       │   ├── Step4: LifestyleStep
│   │       │   ├── Step5: ClinicalFindingsStep
│   │       │   ├── Step6: LabResultsStep
│   │       │   ├── Step7: NutritionDiagnosisStep
│   │       │   └── Step8: InitialPlanStep
│   │       └── WizardNavigationBar
│   │
│   └── ELSE
│       └── NutritionTabbedView
│           ├── TabBar (8 tabs)
│           └── TabBarView
│               ├── Tab1: AnthropometricTab
│               ├── Tab2: MedicalHistoryTab
│               ├── Tab3: DietaryAssessmentTab
│               ├── Tab4: LifestyleTab
│               ├── Tab5: ClinicalFindingsTab
│               ├── Tab6: LabResultsTab
│               ├── Tab7: NutritionDiagnosisTab
│               └── Tab8: InitialPlanTab
│
└── FloatingActionButton (Context-aware)
    ├── IF isLocked: Hide
    ├── IF isDirty: Icon.save (Pulsing animation)
    └── ELSE: Icon.check
```

#### 2.2 NutritionClinicScreen (Main Entry Point)

```dart
/// Main screen for Nutrition EMR management
class NutritionClinicScreen extends ConsumerStatefulWidget {
  const NutritionClinicScreen({
    required this.patientId,
    required this.patientName,
    required this.fileNumber,
    required this.appointmentId,
    required this.visitDate,
    super.key,
  });

  final String patientId;
  final String patientName;
  final String fileNumber;
  final String appointmentId;
  final DateTime visitDate;

  @override
  ConsumerState<NutritionClinicScreen> createState() =>
      _NutritionClinicScreenState();
}

class _NutritionClinicScreenState
    extends ConsumerState<NutritionClinicScreen> {
  
  @override
  void initState() {
    super.initState();
    
    // Load EMR after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref
          .read(nutritionEMRNotifierProvider.notifier)
          .loadEMRByAppointment(widget.appointmentId);
      
      // Wait for state update
      await Future.delayed(const Duration(milliseconds: 100));
      
      final state = ref.read(nutritionEMRNotifierProvider);
      
      if (state.emr != null) {
        // Activate view mode if EMR exists
        ref.read(nutritionViewModeProvider.notifier).setViewMode(true);
        
        // Use wizard mode only for first visits
        ref
            .read(nutritionViewModeProvider.notifier)
            .setWizardMode(state.emr!.isFirstVisit);
      } else {
        // Initialize new EMR
        ref.read(nutritionEMRNotifierProvider.notifier).initializeEMR(
              id: const Uuid().v4(),
              patientId: widget.patientId,
              nutritionistId: currentUserId,
              nutritionistName: currentUserName,
              appointmentId: widget.appointmentId,
              visitDate: widget.visitDate,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final emrState = ref.watch(nutritionEMRNotifierProvider);
    final viewMode = ref.watch(nutritionViewModeProvider);
    
    return WillPopScope(
      onWillPop: () async {
        // Warn if unsaved changes
        if (emrState.isDirty) {
          return await _showUnsavedChangesDialog();
        }
        return true;
      },
      child: Scaffold(
        appBar: _buildAppBar(emrState),
        body: _buildBody(emrState, viewMode),
        floatingActionButton: _buildFAB(emrState),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(NutritionEMRState state) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.patientName),
          Text(
            'File: ${widget.fileNumber}',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          ),
        ],
      ),
      actions: [
        // Save status indicator
        if (state.isDirty)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Chip(
              label: Text('Unsaved'),
              backgroundColor: Colors.orange,
            ),
          ),
        
        // Lock status
        if (state.emr?.isCurrentlyLocked ?? false)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.lock, color: Colors.red),
          )
        else if (state.emr != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              label: Text('${state.emr!.remainingEditHours}h left'),
              backgroundColor: Colors.green,
            ),
          ),
      ],
    );
  }

  Widget _buildBody(NutritionEMRState emrState, NutritionViewMode viewMode) {
    // Loading state
    if (emrState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (emrState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Error: ${emrState.error}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref
                  .read(nutritionEMRNotifierProvider.notifier)
                  .loadEMRByAppointment(widget.appointmentId),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Locked state with no data
    if ((emrState.emr?.isCurrentlyLocked ?? false) && emrState.emr == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Record is locked'),
          ],
        ),
      );
    }

    // Main content - Wizard or Tabbed
    if (viewMode.useWizard) {
      return NutritionWizardView(
        appointmentId: widget.appointmentId,
        isViewMode: viewMode.isViewMode,
      );
    } else {
      return NutritionTabbedView(
        appointmentId: widget.appointmentId,
        isViewMode: viewMode.isViewMode,
      );
    }
  }

  Widget? _buildFAB(NutritionEMRState state) {
    if (state.emr?.isCurrentlyLocked ?? true) return null;
    
    return FloatingActionButton.extended(
      onPressed: () async {
        await ref.read(nutritionEMRNotifierProvider.notifier).saveEMR();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved successfully')),
          );
        }
      },
      icon: Icon(state.isDirty ? Icons.save : Icons.check),
      label: Text(state.isDirty ? 'Save' : 'Saved'),
      backgroundColor: state.isDirty ? Colors.orange : Colors.green,
    );
  }

  Future<bool> _showUnsavedChangesDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
  }
}
```

**Key Features:**
1. **Dynamic AppBar**: Shows patient info, save status, lock indicator
2. **WillPopScope**: Prevents accidental exit with unsaved changes
3. **Conditional Rendering**: Wizard vs Tabbed based on visit type
4. **Loading/Error States**: Proper UI feedback
5. **Context-aware FAB**: Changes color/icon based on save status

#### 2.3 NutritionWizardView (8-Step Wizard)

```dart
/// Wizard-based EMR interface for first visits
class NutritionWizardView extends ConsumerWidget {
  const NutritionWizardView({
    required this.appointmentId,
    required this.isViewMode,
    super.key,
  });

  final String appointmentId;
  final bool isViewMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wizardState = ref.watch(
      nutritionWizardNotifierProvider(appointmentId),
    );
    final emrState = ref.watch(nutritionEMRNotifierProvider);

    return Column(
      children: [
        // Progress indicator
        _buildProgressIndicator(wizardState),
        
        // Step content
        Expanded(
          child: PageView.builder(
            controller: PageController(initialPage: wizardState.currentStep),
            onPageChanged: (page) {
              ref
                  .read(nutritionWizardNotifierProvider(appointmentId).notifier)
                  .goToStep(page);
            },
            itemCount: 8,
            itemBuilder: (context, index) {
              return _buildStepContent(index, emrState.emr, isViewMode, ref);
            },
          ),
        ),
        
        // Navigation bar
        if (!isViewMode) _buildNavigationBar(context, ref, wizardState),
      ],
    );
  }

  Widget _buildProgressIndicator(NutritionWizardState wizardState) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(8, (index) {
          final isActive = index == wizardState.currentStep;
          final isComplete = wizardState.isStepComplete(index);
          
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isComplete
                    ? Colors.green
                    : isActive
                        ? Colors.blue
                        : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(
    int step,
    NutritionEMREntity? emr,
    bool isViewMode,
    WidgetRef ref,
  ) {
    if (emr == null) {
      return const Center(child: Text('No data'));
    }

    switch (step) {
      case 0:
        return AnthropometricStep(emr: emr, isViewMode: isViewMode);
      case 1:
        return MedicalHistoryStep(emr: emr, isViewMode: isViewMode);
      case 2:
        return DietaryAssessmentStep(emr: emr, isViewMode: isViewMode);
      case 3:
        return LifestyleStep(emr: emr, isViewMode: isViewMode);
      case 4:
        return ClinicalFindingsStep(emr: emr, isViewMode: isViewMode);
      case 5:
        return LabResultsStep(emr: emr, isViewMode: isViewMode);
      case 6:
        return NutritionDiagnosisStep(emr: emr, isViewMode: isViewMode);
      case 7:
        return InitialPlanStep(emr: emr, isViewMode: isViewMode);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNavigationBar(
    BuildContext context,
    WidgetRef ref,
    NutritionWizardState wizardState,
  ) {
    final canGoNext = wizardState.currentStep < 7 &&
        wizardState.canProceedToNext(wizardState.currentStep);
    final canGoBack = wizardState.currentStep > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button
          if (canGoBack)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => ref
                    .read(
                      nutritionWizardNotifierProvider(appointmentId).notifier,
                    )
                    .previousStep(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
              ),
            ),
          
          const SizedBox(width: 16),
          
          // Next/Submit button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: canGoNext
                  ? () => ref
                      .read(
                        nutritionWizardNotifierProvider(appointmentId).notifier,
                      )
                      .nextStep()
                  : null,
              icon: Icon(
                wizardState.currentStep == 7 ? Icons.check : Icons.arrow_forward,
              ),
              label: Text(
                wizardState.currentStep == 7 ? 'Complete' : 'Next',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

**Features:**
1. **Progress Indicator**: Visual representation of 8 steps
2. **PageView**: Swipeable steps with smooth transitions
3. **Dynamic Navigation**: Previous/Next buttons with validation
4. **Step Validation**: Cannot proceed without required fields

#### 2.4 Step Widgets (Example: AnthropometricStep)

```dart
/// Step 1: Anthropometric Measurements
class AnthropometricStep extends ConsumerWidget {
  const AnthropometricStep({
    required this.emr,
    required this.isViewMode,
    super.key,
  });

  final NutritionEMREntity emr;
  final bool isViewMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step title
            const Text(
              'Step 1: Anthropometric Measurements',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Document patient\'s body measurements and vital signs',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const Divider(height: 32),

            // Checkboxes
            if (isViewMode)
              _buildViewMode()
            else
              _buildEditMode(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildEditMode(WidgetRef ref) {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Body weight measured (kg)'),
          subtitle: const Text('Record current body weight'),
          value: emr.weightMeasured,
          onChanged: (value) {
            ref
                .read(nutritionEMRNotifierProvider.notifier)
                .updateCheckbox('weightMeasured', value ?? false);
          },
          secondary: const Icon(Icons.monitor_weight, color: AppColors.primary),
        ),
        CheckboxListTile(
          title: const Text('Height measured (cm)'),
          subtitle: const Text('Record current height/stature'),
          value: emr.heightMeasured,
          onChanged: (value) {
            ref
                .read(nutritionEMRNotifierProvider.notifier)
                .updateCheckbox('heightMeasured', value ?? false);
          },
          secondary: const Icon(Icons.height, color: AppColors.primary),
        ),
        CheckboxListTile(
          title: const Text('BMI calculated'),
          subtitle: const Text('Body Mass Index (Weight/Height²)'),
          value: emr.bmiCalculated,
          onChanged: (value) {
            ref
                .read(nutritionEMRNotifierProvider.notifier)
                .updateCheckbox('bmiCalculated', value ?? false);
          },
          secondary: const Icon(Icons.calculate, color: AppColors.primary),
        ),
        CheckboxListTile(
          title: const Text('Waist circumference measured (cm)'),
          subtitle: const Text('Abdominal obesity indicator'),
          value: emr.waistCircumferenceMeasured,
          onChanged: (value) {
            ref
                .read(nutritionEMRNotifierProvider.notifier)
                .updateCheckbox('waistCircumferenceMeasured', value ?? false);
          },
          secondary: const Icon(Icons.straighten, color: AppColors.primary),
        ),
        CheckboxListTile(
          title: const Text('Weight change documented'),
          subtitle: const Text('Recent weight change (last 6 months)'),
          value: emr.weightChangeDocumented,
          onChanged: (value) {
            ref
                .read(nutritionEMRNotifierProvider.notifier)
                .updateCheckbox('weightChangeDocumented', value ?? false);
          },
          secondary: const Icon(Icons.trending_up, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildViewMode() {
    final checkedItems = <String>[];
    
    if (emr.weightMeasured) checkedItems.add('Weight measured');
    if (emr.heightMeasured) checkedItems.add('Height measured');
    if (emr.bmiCalculated) checkedItems.add('BMI calculated');
    if (emr.waistCircumferenceMeasured) {
      checkedItems.add('Waist circumference');
    }
    if (emr.weightChangeDocumented) checkedItems.add('Weight change documented');

    if (checkedItems.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'No measurements recorded',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: checkedItems.map((item) {
        return Chip(
          label: Text(item),
          avatar: const Icon(Icons.check_circle, color: Colors.green, size: 20),
          backgroundColor: Colors.green.withValues(alpha: 0.1),
        );
      }).toList(),
    );
  }
}
```

**Key Features:**
1. **LTR Direction**: English medical terminology
2. **Conditional Rendering**: Edit vs View mode
3. **Icons**: Visual indicators for each measurement
4. **Subtitles**: Additional context for each field
5. **Chips in View Mode**: Clean, visual display of checked items

---

### 3. Advanced Features Implementation

#### 3.1 Auto-Save Mechanism

```dart
/// Auto-save timer in NutritionEMRNotifier
Timer? _autoSaveTimer;
DateTime? _lastAutoSave;

void _startAutoSaveTimer() {
  _autoSaveTimer = Timer.periodic(
    const Duration(seconds: 30),
    (_) async {
      if (!state.isDirty) return;
      
      if (kDebugMode) {
        debugPrint('[NutritionEMR] Auto-saving draft...');
      }
      
      await saveEMR(isDraft: true);
      
      _lastAutoSave = DateTime.now();
      state = state.copyWith(lastAutoSaveTime: _lastAutoSave);
    },
  );
}
```

**Features:**
- Runs every 30 seconds
- Only saves if `isDirty` is true
- Updates `lastAutoSaveTime` for UI display
- Silent operation (no user notification)

#### 3.2 Lock Status Warning System

```dart
/// Lock warning dialog
Future<void> _showLockWarning(BuildContext context, int hoursRemaining) async {
  if (hoursRemaining > 6) return; // Only warn if < 6 hours remaining
  
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange),
          SizedBox(width: 8),
          Text('Time Warning'),
        ],
      ),
      content: Text(
        'This record will lock in $hoursRemaining hours. '
        'Please complete your documentation soon.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
```

**Triggers:**
- On screen init if < 6 hours remaining
- Every hour while screen is active (via timer)

#### 3.3 Dirty Flag Detection

```dart
/// Detect unsaved changes
bool get isDirty {
  // Compare current state with last saved state
  // or check if any checkboxes have been toggled
  return state.isDirty;
}

/// Update dirty flag on any change
void updateCheckbox(String fieldName, bool value) {
  // ... update logic ...
  state = state.copyWith(isDirty: true);
}

/// Clear dirty flag after save
Future<void> saveEMR({bool isDraft = false}) async {
  // ... save logic ...
  state = state.copyWith(isDirty: false, isSaved: true);
}
```

#### 3.4 Offline Mode Support

```dart
/// Check connectivity before save
Future<void> saveEMR({bool isDraft = false}) async {
  // Check internet connection
  final connectivityResult = await Connectivity().checkConnectivity();
  
  if (connectivityResult == ConnectivityResult.none) {
    // Queue for later sync
    await _queueForOfflineSync();
    
    state = state.copyWith(
      error: 'Saved locally. Will sync when online.',
      isSaved: true,
    );
    return;
  }
  
  // Proceed with normal save
  // ...
}
```

---

### 4. Responsive Design & Accessibility

#### 4.1 Responsive Breakpoints

```dart
/// Responsive helper
class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;
  
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;
  
  static double getStepPadding(BuildContext context) {
    if (isDesktop(context)) return 48;
    if (isTablet(context)) return 32;
    return 16;
  }
}
```

#### 4.2 Accessibility Features

```dart
/// Semantic labels for screen readers
CheckboxListTile(
  title: const Text('Weight measured'),
  value: emr.weightMeasured,
  onChanged: (value) {...},
  // Accessibility
  semanticLabel: 'Weight measured checkbox. '
      'Check to indicate body weight has been recorded.',
  dense: false, // Larger touch target
)

/// Focus management
final focusNode = FocusNode();

@override
void initState() {
  super.initState();
  // Auto-focus first input
  WidgetsBinding.instance.addPostFrameCallback((_) {
    focusNode.requestFocus();
  });
}
```

#### 4.3 Dark Mode Support

```dart
/// Theme-aware colors
final backgroundColor = Theme.of(context).brightness == Brightness.dark
    ? Colors.grey[900]
    : Colors.white;

final textColor = Theme.of(context).brightness == Brightness.dark
    ? Colors.white
    : Colors.black;

/// Use theme colors consistently
Container(
  color: Theme.of(context).scaffoldBackgroundColor,
  child: Text(
    'Nutrition EMR',
    style: Theme.of(context).textTheme.headlineMedium,
  ),
)
```

---

### 5. Performance Optimizations

#### 5.1 Const Constructors

```dart
// Good: Uses const for static widgets
const Text('Static text')
const SizedBox(height: 16)
const Icon(Icons.check)

// Bad: Avoids const
Text('Static text')
SizedBox(height: 16)
Icon(Icons.check)
```

#### 5.2 Selective Rebuilds with select()

```dart
/// Watch only specific fields
final isLocked = ref.watch(
  nutritionEMRNotifierProvider.select((state) => state.emr?.isCurrentlyLocked),
);

/// This rebuilds only when isLocked changes, not on every state change
```

#### 5.3 ListView.builder for Long Lists

```dart
/// Use builder for efficiency
ListView.builder(
  itemCount: sections.length,
  itemBuilder: (context, index) {
    return SectionWidget(section: sections[index]);
  },
)

/// Avoid: Building all widgets upfront
ListView(
  children: sections.map((s) => SectionWidget(section: s)).toList(),
)
```

---

## 📝 File Structure

```
lib/features/nutrition/
├── domain/
│   ├── entities/
│   │   └── nutrition_emr_entity.dart ✅ (Already exists)
│   └── repositories/
│       └── nutrition_emr_repository.dart ✅ (Already exists)
│
├── data/
│   ├── models/
│   │   └── nutrition_emr_model.dart ✅ (Already exists)
│   └── repositories/
│       └── nutrition_emr_repository_impl.dart ✅ (Already exists)
│
└── presentation/
    ├── providers/
    │   ├── nutrition_emr_notifier.dart 🆕
    │   ├── nutrition_wizard_notifier.dart 🆕
    │   └── nutrition_view_mode_provider.dart 🆕
    │
    ├── screens/
    │   └── nutrition_clinic_screen.dart 🆕
    │
    ├── views/
    │   ├── nutrition_wizard_view.dart 🆕
    │   └── nutrition_tabbed_view.dart 🆕
    │
    └── widgets/
        ├── steps/
        │   ├── anthropometric_step.dart 🆕
        │   ├── medical_history_step.dart 🆕
        │   ├── dietary_assessment_step.dart 🆕
        │   ├── lifestyle_step.dart 🆕
        │   ├── clinical_findings_step.dart 🆕
        │   ├── lab_results_step.dart 🆕
        │   ├── nutrition_diagnosis_step.dart 🆕
        │   └── initial_plan_step.dart 🆕
        │
        ├── tabs/
        │   └── [Same as steps but for tabbed view]
        │
        └── common/
            ├── lock_indicator_widget.dart 🆕
            ├── save_status_indicator.dart 🆕
            ├── progress_indicator_widget.dart 🆕
            └── empty_state_widget.dart 🆕
```

**Legend:**
- ✅ Already implemented
- 🆕 To be created in Phase 3

**Total New Files:** 24 files

---

## 🎨 UI Design Specifications

### Color Coding System

| Status | Color | Usage |
|--------|-------|-------|
| **Normal** | Green (#4CAF50) | Completed sections, saved state |
| **Warning** | Orange (#FF9800) | Unsaved changes, low time remaining |
| **Critical** | Red (#F44336) | Locked records, errors |
| **Info** | Blue (#2196F3) | Current step, active elements |
| **Neutral** | Grey (#9E9E9E) | Disabled, empty states |

### Typography

```dart
// Headings
TextStyle(fontSize: 24, fontWeight: FontWeight.bold) // Section titles
TextStyle(fontSize: 18, fontWeight: FontWeight.bold) // Subsections
TextStyle(fontSize: 16, fontWeight: FontWeight.w600) // List tiles

// Body text
TextStyle(fontSize: 16, fontWeight: FontWeight.normal) // Standard text
TextStyle(fontSize: 14, color: Colors.grey) // Subtitles
TextStyle(fontSize: 12, fontWeight: FontWeight.w300) // Captions
```

### Spacing System

```dart
// Vertical spacing
const SizedBox(height: 4)  // Tight
const SizedBox(height: 8)  // Compact
const SizedBox(height: 16) // Standard
const SizedBox(height: 24) // Relaxed
const SizedBox(height: 32) // Loose
const SizedBox(height: 48) // Section break

// Padding
const EdgeInsets.all(8)   // Compact
const EdgeInsets.all(16)  // Standard
const EdgeInsets.all(24)  // Comfortable
```

---

## 🔄 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    NutritionClinicScreen                         │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                  initState()                              │   │
│  │  1. Load EMR by appointmentId                            │   │
│  │  2. If exists → Activate View Mode                        │   │
│  │  3. If new → Initialize EMR                              │   │
│  └──────────────────────────────────────────────────────────┘   │
│                            ↓                                     │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │        ref.watch(nutritionEMRNotifierProvider)           │   │
│  │              ↓                ↓                ↓          │   │
│  │          isLoading         error             emr          │   │
│  └──────────────────────────────────────────────────────────┘   │
│                            ↓                                     │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Conditional Rendering:                                   │   │
│  │    - If loading → CircularProgressIndicator              │   │
│  │    - If error → Error widget with retry                  │   │
│  │    - If emr == null && locked → Lock message             │   │
│  │    - Else → Wizard or Tabbed View                        │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                            ↓
        ┌───────────────────┴───────────────────┐
        ↓                                       ↓
┌────────────────────┐              ┌────────────────────┐
│ NutritionWizardView│              │NutritionTabbedView │
│  (First Visit)     │              │  (Follow-up)       │
└────────┬───────────┘              └─────────┬──────────┘
         │                                    │
         ↓                                    ↓
┌────────────────────┐              ┌────────────────────┐
│ 8 Step Widgets     │              │ 8 Tab Widgets      │
│ - AnthropometricStep│              │ - AnthropometricTab│
│ - MedicalHistoryStep│              │ - MedicalHistoryTab│
│ - ... (6 more)     │              │ - ... (6 more)     │
└────────┬───────────┘              └─────────┬──────────┘
         │                                    │
         └────────────────┬───────────────────┘
                          ↓
              ┌───────────────────────┐
              │  User Interaction:    │
              │  - Toggle checkbox    │
              │  - Input text         │
              │  - Navigate steps     │
              └───────────┬───────────┘
                          ↓
    ┌──────────────────────────────────────────────────┐
    │  ref.read(nutritionEMRNotifierProvider.notifier) │
    │       .updateCheckbox(fieldName, value)          │
    └──────────────────┬───────────────────────────────┘
                       ↓
           ┌──────────────────────┐
           │ NutritionEMRNotifier │
           │  1. Optimistic update│
           │  2. Set isDirty=true │
           │  3. Notify listeners │
           └──────────┬───────────┘
                      ↓
      ┌───────────────────────────────┐
      │ Auto-save Timer (30s)         │
      │  If isDirty → saveEMR(draft)  │
      └───────────────┬───────────────┘
                      ↓
      ┌───────────────────────────────┐
      │ NutritionEMRRepository        │
      │  → Firestore (elajtech)       │
      │  → Server timestamp           │
      │  → Audit log entry            │
      └───────────────────────────────┘
```

---

## 🧪 Testing Strategy

### Unit Tests

```dart
// Test file: test/features/nutrition/presentation/providers/
//            nutrition_emr_notifier_test.dart

void main() {
  late MockNutritionEMRRepository mockRepository;
  late NutritionEMRNotifier notifier;

  setUp(() {
    mockRepository = MockNutritionEMRRepository();
    notifier = NutritionEMRNotifier(mockRepository);
  });

  group('NutritionEMRNotifier', () {
    test('initial state should be correct', () {
      expect(notifier.state.emr, isNull);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.isDirty, isFalse);
    });

    test('updateCheckbox should set isDirty to true', () {
      // Arrange
      final emr = NutritionEMREntity.createNew(/* ... */);
      notifier.state = NutritionEMRState(emr: emr);

      // Act
      notifier.updateCheckbox('weightMeasured', true);

      // Assert
      expect(notifier.state.isDirty, isTrue);
      expect(notifier.state.emr!.weightMeasured, isTrue);
    });

    test('saveEMR should clear isDirty flag', () async {
      // Arrange
      final emr = NutritionEMREntity.createNew(/* ... */);
      notifier.state = NutritionEMRState(emr: emr, isDirty: true);
      when(() => mockRepository.saveEMR(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      await notifier.saveEMR();

      // Assert
      expect(notifier.state.isDirty, isFalse);
      expect(notifier.state.isSaved, isTrue);
    });

    test('auto-save should trigger after 30 seconds', () async {
      // Arrange
      final emr = NutritionEMREntity.createNew(/* ... */);
      notifier.state = NutritionEMRState(emr: emr, isDirty: true);
      when(() => mockRepository.saveEMR(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      await Future.delayed(const Duration(seconds: 31));

      // Assert
      verify(() => mockRepository.saveEMR(any())).called(1);
    });
  });
}
```

### Widget Tests

```dart
// Test file: test/features/nutrition/presentation/screens/
//            nutrition_clinic_screen_test.dart

void main() {
  testWidgets('should show CircularProgressIndicator when loading',
      (tester) async {
    // Arrange
    final container = ProviderContainer(
      overrides: [
        nutritionEMRNotifierProvider.overrideWith(
          (ref) => MockNutritionEMRNotifier(
            const NutritionEMRState(isLoading: true),
          ),
        ),
      ],
    );

    // Act
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: NutritionClinicScreen(/* ... */),
        ),
      ),
    );

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('should show lock icon when EMR is locked', (tester) async {
    // Arrange
    final lockedEMR = NutritionEMREntity.createNew(/* ... */).copyWith(
      isLocked: true,
    );
    final container = ProviderContainer(
      overrides: [
        nutritionEMRNotifierProvider.overrideWith(
          (ref) => MockNutritionEMRNotifier(
            NutritionEMRState(emr: lockedEMR),
          ),
        ),
      ],
    );

    // Act
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: NutritionClinicScreen(/* ... */),
        ),
      ),
    );

    // Assert
    expect(find.byIcon(Icons.lock), findsOneWidget);
  });
}
```

---

## ⚠️ Critical Implementation Rules

### 1. Database Configuration
```dart
// ❌ NEVER use this
FirebaseFirestore.instance

// ✅ ALWAYS use this (injected via GetIt)
final _firestore = GetIt.I<FirebaseFirestore>(); // databaseId: 'elajtech'
```

### 2. Provider Patterns
```dart
// ✅ Use autoDispose for memory management
final provider = StateNotifierProvider.autoDispose<Notifier, State>((ref) {
  return Notifier();
});

// ✅ Use family for parameterized providers
final provider = StateNotifierProvider.autoDispose.family<
    Notifier, State, String>((ref, appointmentId) {
  return Notifier(appointmentId);
});

// ✅ Use select for targeted rebuilds
final isLocked = ref.watch(
  emrProvider.select((state) => state.emr?.isCurrentlyLocked),
);
```

### 3. Error Handling
```dart
// ✅ Always wrap Firestore calls in try-catch
try {
  final result = await repository.saveEMR(emr);
  result.fold(
    (failure) => state = state.copyWith(error: failure.message),
    (_) => state = state.copyWith(isSaved: true),
  );
} catch (e, stackTrace) {
  if (kDebugMode) {
    debugPrint('Error: $e');
    debugPrint('StackTrace: $stackTrace');
  }
  state = state.copyWith(error: e.toString());
}
```

### 4. Null Safety
```dart
// ❌ Avoid using ! operator
final name = state.emr!.nutritionistName;

// ✅ Use null-aware operators
final name = state.emr?.nutritionistName ?? 'Unknown';

// ✅ Check before accessing
if (state.emr != null) {
  final name = state.emr!.nutritionistName;
}
```

### 5. Performance
```dart
// ✅ Use const constructors
const SizedBox(height: 16)
const Text('Static')

// ✅ Use ListView.builder for lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)

// ✅ Implement shouldRebuild for custom widgets
@override
bool shouldRebuild(covariant OldWidget oldWidget) {
  return oldWidget.value != value;
}
```

---

## 📊 Implementation Phases

### Phase 3.1: State Management (Week 1)
- [ ] Create `nutrition_emr_notifier.dart`
- [ ] Create `nutrition_wizard_notifier.dart`
- [ ] Create `nutrition_view_mode_provider.dart`
- [ ] Write unit tests for all notifiers
- [ ] Integrate with GetIt

**Estimate:** 3-4 days

### Phase 3.2: Main Screen & Wizard Structure (Week 1-2)
- [ ] Create `nutrition_clinic_screen.dart`
- [ ] Create `nutrition_wizard_view.dart`
- [ ] Implement progress indicator
- [ ] Implement navigation bar
- [ ] Add lock warning system

**Estimate:** 4-5 days

### Phase 3.3: Step Widgets (Week 2)
- [ ] Create 8 step widgets (anthropometric, medical history, etc.)
- [ ] Implement edit mode for each step
- [ ] Implement view mode for each step
- [ ] Add validation logic

**Estimate:** 5-6 days

### Phase 3.4: Tabbed View (Week 3)
- [ ] Create `nutrition_tabbed_view.dart`
- [ ] Create 8 tab widgets
- [ ] Implement tab switching
- [ ] Add completion indicators

**Estimate:** 3-4 days

### Phase 3.5: Common Widgets & Polish (Week 3)
- [ ] Create lock indicator widget
- [ ] Create save status indicator
- [ ] Create progress indicator widget
- [ ] Create empty state widget
- [ ] Add animations and transitions

**Estimate:** 2-3 days

### Phase 3.6: Testing & Integration (Week 4)
- [ ] Write widget tests
- [ ] Write integration tests
- [ ] Test on multiple devices
- [ ] Test offline mode
- [ ] Performance testing

**Estimate:** 5-6 days

---

## 🎯 Success Criteria

### Functional Requirements
- [ ] User can create new nutrition EMR
- [ ] User can edit existing EMR within 24-hour window
- [ ] User cannot edit locked EMR
- [ ] Wizard mode works for first visits
- [ ] Tabbed mode works for follow-up visits
- [ ] Auto-save triggers every 30 seconds
- [ ] Unsaved changes warning on exit
- [ ] Lock warning when < 6 hours remaining
- [ ] Offline mode queues changes for sync

### Non-Functional Requirements
- [ ] UI renders in < 100ms on mid-range devices
- [ ] No memory leaks (verified with DevTools)
- [ ] Supports RTL for Arabic text
- [ ] Supports Dark Mode
- [ ] Screen reader accessible
- [ ] Responsive on tablets and phones
- [ ] Smooth animations (60 FPS)

### Code Quality
- [ ] 100% Dart format compliance
- [ ] 0 linter warnings
- [ ] 90%+ unit test coverage
- [ ] 80%+ widget test coverage
- [ ] All public APIs documented
- [ ] No ! operators (null-safe code)

---

## 📚 Dependencies

### Required Packages (Already in pubspec.yaml)
```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  dartz: ^0.10.1
  cloud_firestore: ^5.5.0
  get_it: ^7.7.0
  injectable: ^2.4.4
  uuid: ^4.5.1
  connectivity_plus: ^6.1.2

dev_dependencies:
  freezed: ^2.5.7
  build_runner: ^2.4.13
  json_serializable: ^6.8.0
  mockito: ^5.4.4
```

No new dependencies required!

---

## 🔍 Mockup Descriptions

### Wizard Mode - Step 1 Example

```
┌─────────────────────────────────────────────┐
│  ← Nutrition EMR       | Patient: Ahmed     │ AppBar
│                        | File: #12345       │
│                        | 🟢 23h left        │
├─────────────────────────────────────────────┤
│  Progress: ████████░░░░░░░░░░░░░░░░░░░░░░  │ Progress
│            Step 1/8                         │ Indicator
├─────────────────────────────────────────────┤
│                                             │
│  Step 1: Anthropometric Measurements        │ Step Title
│  Document patient's body measurements       │
│  ─────────────────────────────────────────  │
│                                             │
│  ☑ Body weight measured (kg)                │ Checkboxes
│    Record current body weight               │ with
│                                             │ subtitles
│  ☐ Height measured (cm)                     │
│    Record current height/stature            │
│                                             │
│  ☐ BMI calculated                           │
│    Body Mass Index (Weight/Height²)         │
│                                             │
│  ☐ Waist circumference measured (cm)        │
│    Abdominal obesity indicator              │
│                                             │
│  ☐ Weight change documented                 │
│    Recent weight change (last 6 months)     │
│                                             │
├─────────────────────────────────────────────┤
│                                             │
│  [Previous]           [Next →]              │ Navigation
│                                             │  Buttons
└─────────────────────────────────────────────┘
```

### View Mode - Chips Display

```
┌─────────────────────────────────────────────┐
│  ← Nutrition EMR       | Patient: Ahmed     │
│                    🔒 Record Locked         │
├─────────────────────────────────────────────┤
│                                             │
│  Anthropometric Measurements                │
│  ─────────────────────────────────────────  │
│                                             │
│  ✓ Weight measured  ✓ Height measured      │ Chips
│  ✓ BMI calculated   ✓ Waist circumference  │
│                                             │
│  ─────────────────────────────────────────  │
│                                             │
│  Dietary Assessment                         │
│  ─────────────────────────────────────────  │
│                                             │
│  ℹ No items selected in this section        │ Empty
│                                             │ State
│  ─────────────────────────────────────────  │
│                                             │
└─────────────────────────────────────────────┘
```

---

## 📞 Next Steps

### Immediate Actions Required

1. **Review this architecture plan** - Provide feedback or approval
2. **Clarify any ambiguities** - Ask questions if anything is unclear
3. **Approve file structure** - Confirm the proposed directory layout
4. **Set priorities** - Which features are MVP vs nice-to-have

### After Approval

1. I will create detailed code for `nutrition_emr_notifier.dart`
2. I will create detailed code for `nutrition_wizard_notifier.dart`
3. I will create basic unit tests for both
4. I will present them for review before continuing with UI

---

## ✅ Approval Checklist

- [ ] Architecture design approved
- [ ] State management approach approved
- [ ] UI component hierarchy approved
- [ ] File structure approved
- [ ] Performance optimizations approved
- [ ] Testing strategy approved
- [ ] Ready to proceed with implementation

---

**Document Status:** Draft - Awaiting Client Review

**Next Version:** v1.1 after client feedback

**Contact:** Kilo Code Architect Team
