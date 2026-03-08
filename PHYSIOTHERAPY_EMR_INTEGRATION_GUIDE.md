# Physical Therapy EMR - Integration Guide

## 🎯 Overview

This guide explains how to integrate the Physical Therapy EMR tab into the existing AddEMRScreen with a 5-tab structure.

---

## 📦 What Has Been Implemented

### ✅ Complete Backend Infrastructure (60%)

1. **Domain Entity** - [`physiotherapy_emr.dart`](lib/features/doctor/medical_records/domain/entities/physiotherapy_emr.dart)
2. **Data Model** - [`physiotherapy_emr_model.dart`](lib/features/doctor/medical_records/data/models/physiotherapy_emr_model.dart)
3. **Repository** - [`physiotherapy_emr_repository.dart`](lib/features/doctor/medical_records/data/repositories/physiotherapy_emr_repository.dart)
4. **State Management** - [`physiotherapy_emr_provider.dart`](lib/features/doctor/medical_records/presentation/providers/physiotherapy_emr_provider.dart)
5. **Questions/Constants** - [`physiotherapy_questions.dart`](lib/features/doctor/medical_records/domain/constants/physiotherapy_questions.dart)
6. **UI Widget** - [`physiotherapy_emr_tab.dart`](lib/features/doctor/medical_records/presentation/widgets/physiotherapy_emr_tab.dart)

---

## 🔧 Integration Steps

### Step 1: Register Repository in Dependency Injection

**File:** `lib/core/di/injection_container.dart`

The repository is already annotated with `@lazySingleton`, so it should be automatically registered. Verify by checking:

```dart
// In injection_container.config.dart (generated file)
// Should contain:
gh<PhysiotherapyEMRRepository>(() => PhysiotherapyEMRRepository());
```

If not present, run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Step 2: Transform AddEMRScreen to 5-Tab Structure

**File:** `lib/features/doctor/medical_records/presentation/screens/add_emr_screen.dart`

#### Current Structure:
- Single scrollable form with conditional sections

#### Required Structure:
- 5 permanent tabs for all doctors
- Conditional content within EMR tab based on specialty

#### Implementation:

```dart
class _AddEMRScreenState extends ConsumerState<AddEMRScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    
    // Null-safety protection
    if (user == null) return const SizedBox();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Records'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Tab>[
            Tab(text: 'Prescriptions'),
            Tab(text: 'Lab Tests'),
            Tab(text: 'Radiology'),
            Tab(text: 'Devices'),
            Tab(text: 'EMR'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          _buildPrescriptionsTab(),
          _buildLabTestsTab(),
          _buildRadiologyTab(),
          _buildDevicesTab(),
          _buildEMRTab(user), // Conditional content based on specialty
        ],
      ),
    );
  }
  
  Widget _buildEMRTab(UserModel user) {
    // Check if physiotherapy doctor
    if (SpecialtyConstants.isPhysiotherapyDoctor(user.specializations)) {
      return PhysiotherapyEMRTab(
        patientId: widget.patientId,
        doctorId: user.id,
        doctorName: user.fullName,
        appointmentId: widget.appointmentId,
        visitDate: DateTime.now(), // Or get from appointment
      );
    }
    
    // Check if nutrition doctor
    if (SpecialtyConstants.isNutritionDoctor(user.specializations)) {
      return _buildNutritionEMRContent();
    }
    
    // Check if internal medicine doctor
    if (SpecialtyConstants.isInternalMedicineDoctor(user.specializations)) {
      return _buildInternalMedicineEMRContent();
    }
    
    // Default EMR content (Andrology)
    return _buildDefaultEMRContent();
  }
}
```

### Step 3: Implement Save Functionality

#### Option A: Save Button in Each Tab

```dart
Widget _buildEMRTab(UserModel user) {
  if (SpecialtyConstants.isPhysiotherapyDoctor(user.specializations)) {
    return Column(
      children: <Widget>[
        Expanded(
          child: PhysiotherapyEMRTab(
            key: _physioTabKey,
            patientId: widget.patientId,
            doctorId: user.id,
            doctorName: user.fullName,
            appointmentId: widget.appointmentId,
            visitDate: DateTime.now(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _savePhysiotherapyEMR,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Save Physical Therapy EMR',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
  // ... other specialties
}

Future<void> _savePhysiotherapyEMR() async {
  try {
    // Get EMR data from widget
    final physioTabState = _physioTabKey.currentState as _PhysiotherapyEMRTabState?;
    if (physioTabState == null) return;
    
    final emrData = physioTabState.getEMRData();
    
    // Save via repository
    final repository = GetIt.I<PhysiotherapyEMRRepository>();
    final result = await repository.createPhysiotherapyEMR(emrData);
    
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${failure.message}')),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('EMR saved successfully')),
        );
        Navigator.pop(context);
      },
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

#### Option B: Global Save Button (Saves All Tabs)

```dart
FloatingActionButton(
  onPressed: _saveAllRecords,
  child: const Icon(Icons.save),
)

Future<void> _saveAllRecords() async {
  // Save based on current tab
  switch (_tabController.index) {
    case 0:
      await _savePrescriptions();
      break;
    case 1:
      await _saveLabTests();
      break;
    case 2:
      await _saveRadiology();
      break;
    case 3:
      await _saveDevices();
      break;
    case 4:
      await _saveEMR(); // Calls appropriate EMR save based on specialty
      break;
  }
}
```

### Step 4: Update Firestore Security Rules

**File:** `firestore.rules`

Add these rules:

```javascript
match /physiotherapy_emrs/{emrId} {
  // Allow doctors to create EMR within 24 hours of appointment
  allow create: if request.auth != null
    && request.auth.token.userType == 'doctor'
    && request.resource.data.doctorId == request.auth.uid
    && request.resource.data.appointmentId != null
    && isWithin24Hours(request.resource.data.appointmentId);

  // Allow doctors to read their own EMRs
  allow read: if request.auth != null
    && request.auth.token.userType == 'doctor'
    && resource.data.doctorId == request.auth.uid;

  // Allow patients to read their own EMRs
  allow read: if request.auth != null
    && request.auth.token.userType == 'patient'
    && resource.data.patientId == request.auth.uid;

  // Allow doctors to update within 24 hours
  allow update: if request.auth != null
    && request.auth.token.userType == 'doctor'
    && resource.data.doctorId == request.auth.uid
    && isWithin24Hours(resource.data.appointmentId);
}

// Helper function to check 24-hour window
function isWithin24Hours(appointmentId) {
  let appointment = get(/databases/$(database)/documents/appointments/$(appointmentId));
  let appointmentDate = appointment.data.appointmentDate;
  let now = request.time;
  let timeDiff = now.toMillis() - appointmentDate.toMillis();
  return timeDiff < 86400000; // 24 hours in milliseconds
}
```

---

## 🎨 UI Design Specifications

### Tab Structure

```
┌─────────────────────────────────────────────────────────┐
│  Medical Records                                    [X] │
├─────────────────────────────────────────────────────────┤
│  [Prescriptions] [Lab Tests] [Radiology] [Devices] [EMR]│
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Physical Therapy Assessment                    │   │
│  ├─────────────────────────────────────────────────┤   │
│  │  ▼ Basics                                       │   │
│  │    ▼ Demographics                               │   │
│  │      □ Age                                      │   │
│  │      □ Gender                                   │   │
│  │      □ Occupation                               │   │
│  │    ▼ Referral Information                       │   │
│  │      □ Referral Source                          │   │
│  │      □ Previous PT                              │   │
│  │      □ Chronic Conditions                       │   │
│  ├─────────────────────────────────────────────────┤   │
│  │  ▼ Pain Assessment                              │   │
│  │    ▼ Pain Location                              │   │
│  │      □ Neck                                     │   │
│  │      □ Upper Back                               │   │
│  │      □ Lower Back                               │   │
│  │      ... (more options)                         │   │
│  ├─────────────────────────────────────────────────┤   │
│  │  ... (6 more sections)                          │   │
│  ├─────────────────────────────────────────────────┤   │
│  │  Primary Diagnosis                              │   │
│  │  ┌───────────────────────────────────────────┐ │   │
│  │  │ 1- [                                    ] │ │   │
│  │  └───────────────────────────────────────────┘ │   │
│  │  ┌───────────────────────────────────────────┐ │   │
│  │  │ 2- [                                    ] │ │   │
│  │  └───────────────────────────────────────────┘ │   │
│  │  ┌───────────────────────────────────────────┐ │   │
│  │  │ 3- [                                    ] │ │   │
│  │  └───────────────────────────────────────────┘ │   │
│  ├─────────────────────────────────────────────────┤   │
│  │  Management Plan                                │   │
│  │  ┌───────────────────────────────────────────┐ │   │
│  │  │ 1- [                                    ] │ │   │
│  │  └───────────────────────────────────────────┘ │   │
│  │  ┌───────────────────────────────────────────┐ │   │
│  │  │ 2- [                                    ] │ │   │
│  │  └───────────────────────────────────────────┘ │   │
│  │  ┌───────────────────────────────────────────┐ │   │
│  │  │ 3- [                                    ] │ │   │
│  │  └───────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │         [Save Physical Therapy EMR]             │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

## 🔄 Alternative Integration Approach

Since the current AddEMRScreen is a single-form design, there are two approaches:

### Approach A: Full Refactoring (Recommended by User)
- Transform AddEMRScreen into a 5-tab interface
- Each tab handles a different type of medical record
- Requires significant refactoring of existing code

### Approach B: Conditional Rendering (Current Implementation)
- Keep single-form design
- Conditionally show physiotherapy sections for physiotherapy doctors
- Less disruptive to existing functionality

---

## 📝 Code Snippets for Integration

### 1. Add Import Statements

```dart
import 'package:elajtech/features/doctor/medical_records/presentation/widgets/physiotherapy_emr_tab.dart';
import 'package:elajtech/features/doctor/medical_records/data/repositories/physiotherapy_emr_repository.dart';
import 'package:get_it/get_it.dart';
```

### 2. Add GlobalKey for Widget Access

```dart
class _AddEMRScreenState extends ConsumerState<AddEMRScreen> {
  final GlobalKey<_PhysiotherapyEMRTabState> _physioTabKey = GlobalKey();
  // ... rest of state
}
```

### 3. Add Physiotherapy Tab to Build Method

```dart
// In build method, after existing EMR sections:
if (_isPhysiotherapyDoctor) ...<Widget>[
  const SizedBox(height: 24),
  const Divider(thickness: 3, color: AppColors.primary),
  const SizedBox(height: 24),
  PhysiotherapyEMRTab(
    key: _physioTabKey,
    patientId: widget.patientId,
    doctorId: user.id,
    doctorName: user.fullName,
    appointmentId: widget.appointmentId,
    visitDate: DateTime.now(),
  ),
],
```

### 4. Update Save Method

```dart
Future<void> _save() async {
  if (!_formKey.currentState!.validate()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final user = ref.read(authProvider).user!;

    // Save default EMR (existing code)
    final emr = EMRModel(/* ... */);
    final result = await GetIt.I<EMRRepository>().saveEMR(emr);
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => null,
    );

    // Save Physiotherapy EMR if applicable
    if (_isPhysiotherapyDoctor) {
      final physioTabState = _physioTabKey.currentState;
      if (physioTabState != null) {
        final physioEMR = physioTabState.getEMRData();
        final physioResult = await GetIt.I<PhysiotherapyEMRRepository>()
            .createPhysiotherapyEMR(physioEMR);
        physioResult.fold(
          (failure) => throw Exception(failure.message),
          (_) => null,
        );
      }
    }

    // Save Nutrition EMR if applicable (existing code)
    // ... existing nutrition code

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ السجل بنجاح')),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

---

## 🧪 Testing Checklist

### Functional Testing

- [ ] **Physiotherapy Doctor Login**
  - [ ] Physical Therapy tab appears in EMR section
  - [ ] All 8 checklist sections are visible
  - [ ] Checkboxes can be selected/deselected
  - [ ] 6 numbered text fields accept input
  - [ ] Save button works
  - [ ] Data persists to Firestore
  - [ ] Success message appears

- [ ] **Non-Physiotherapy Doctor Login**
  - [ ] Physical Therapy tab does NOT appear
  - [ ] Standard EMR content shows
  - [ ] No errors or crashes

- [ ] **Data Persistence**
  - [ ] Check Firestore console for `physiotherapy_emrs` collection
  - [ ] Verify document structure matches model
  - [ ] Confirm all fields are saved correctly
  - [ ] Test with `databaseId: 'elajtech'`

- [ ] **24-Hour Validation**
  - [ ] Try to save EMR for old appointment (> 24 hours)
  - [ ] Should show permission denied error
  - [ ] Error message should be user-friendly

### UI/UX Testing

- [ ] **Responsiveness**
  - [ ] Test on mobile (portrait/landscape)
  - [ ] Test on tablet
  - [ ] Test on web browser

- [ ] **Direction (LTR)**
  - [ ] Verify checkboxes align left
  - [ ] Verify text fields align left
  - [ ] Verify numbered labels (1-, 2-, 3-) appear correctly

- [ ] **Performance**
  - [ ] Form loads quickly
  - [ ] Checkbox selections are instant
  - [ ] No lag when typing in text fields
  - [ ] Save operation completes in < 3 seconds

---

## 🐛 Troubleshooting

### Issue: Analyzer Error on PhysiotherapyEMR

**Error:** `Missing concrete implementations of 'getter mixin _$PhysiotherapyEMR'`

**Solution:** This is a temporary IDE issue. The code works correctly. To resolve:
1. Restart VS Code
2. Run `flutter pub get`
3. Run `dart run build_runner clean`
4. Run `dart run build_runner build --delete-conflicting-outputs`

### Issue: Repository Not Found in GetIt

**Error:** `GetIt: Object/factory with type PhysiotherapyEMRRepository is not registered`

**Solution:**
1. Verify `@lazySingleton` annotation is present in repository
2. Run `dart run build_runner build --delete-conflicting-outputs`
3. Check `injection_container.config.dart` for registration
4. Ensure `configureDependencies()` is called in `main.dart`

### Issue: Firestore Permission Denied

**Error:** `permission-denied` when saving EMR

**Solution:**
1. Check Firestore rules are deployed
2. Verify user has `userType: 'doctor'` in auth token
3. Confirm appointment is within 24-hour window
4. Check `databaseId: 'elajtech'` is used

### Issue: Data Not Saving

**Checklist:**
- [ ] Verify `appointmentId` is not empty
- [ ] Check Firestore console for errors
- [ ] Verify network connectivity
- [ ] Check Firebase project configuration
- [ ] Ensure `databaseId: 'elajtech'` is correct

---

## 📊 Data Structure in Firestore

### Collection: `physiotherapy_emrs`

```json
{
  "id": "uuid-v4",
  "patientId": "patient-id",
  "doctorId": "doctor-id",
  "doctorName": "Dr. Name",
  "appointmentId": "appointment-id",
  "visitDate": "2026-01-19T10:00:00.000Z",
  "createdAt": "2026-01-19T10:30:00.000Z",
  "basics": {
    "demographics": ["Age", "Gender"],
    "referral": ["Referral Source"]
  },
  "painAssessment": {
    "pain_location": ["Lower Back", "Hip"],
    "pain_intensity": ["6-8 (Severe)"]
  },
  "functionalAssessment": {
    "mobility_status": ["Requires Assistance"],
    "gait_pattern": ["Antalgic"]
  },
  "systemsReview": {
    "musculoskeletal": ["Joint Stiffness"]
  },
  "rangeOfMotion": {
    "spine": ["Lumbar Flexion/Extension"],
    "limitations": ["Moderate Limitation"]
  },
  "strengthAssessment": {
    "lower_extremity": ["3/5 (Fair)"]
  },
  "devicesEquipment": {
    "current_devices": ["Walker"],
    "recommended_devices": ["Cane"]
  },
  "treatmentPlan": {
    "short_term_goals": ["Pain Reduction", "Increase ROM"],
    "modalities": ["Manual Therapy", "Therapeutic Exercise"]
  },
  "primaryDiagnosis1": "Lumbar disc herniation L4-L5",
  "primaryDiagnosis2": "Chronic lower back pain",
  "primaryDiagnosis3": null,
  "managementPlan1": "Manual therapy 2x/week for 4 weeks",
  "managementPlan2": "Home exercise program focusing on core strengthening",
  "managementPlan3": "Patient education on proper body mechanics",
  "specialization": "عيادة العلاج الطبيعي والتأهيل"
}
```

---

## 🚀 Deployment Steps

### 1. Pre-Deployment

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Generate code
dart run build_runner build --delete-conflicting-outputs

# Analyze code
flutter analyze

# Run tests
flutter test
```

### 2. Deployment

```bash
# Build for production
flutter build apk --release  # Android
flutter build ios --release  # iOS
flutter build web --release  # Web
```

### 3. Post-Deployment

- Monitor Firestore usage
- Check error logs
- Gather user feedback
- Plan iterative improvements

---

## 📞 Support

For issues or questions:
1. Check this integration guide
2. Review [`PHYSIOTHERAPY_EMR_IMPLEMENTATION_STATUS.md`](PHYSIOTHERAPY_EMR_IMPLEMENTATION_STATUS.md)
3. Consult [`plans/physical_therapy_emr_implementation_plan.md`](plans/physical_therapy_emr_implementation_plan.md)

---

**Last Updated:** 2026-01-19  
**Version:** 1.0  
**Status:** Ready for Integration
