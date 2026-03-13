# Data Model: Patient Packages Update

## Domain Layer

### [MODIFY] PatientPackageEntity (`lib/features/packages/domain/entities/patient_package_entity.dart`)

Add the following field:
```dart
final List<PackageServiceItem> packageServices;
```

Updated Constructor:
```dart
const PatientPackageEntity({
    required this.id,
    required this.patientId,
    required this.packageId,
    required this.packageName, // Already exists, but ensure usage
    required this.packageServices, // [NEW]
    // ... other fields
});
```

## Data Layer

### [MODIFY] PatientPackageModel (`lib/features/packages/data/models/patient_package_model.dart`)

- Update `fromFirestore` methods to parse `packageServices`.
- Update `toFirestore` to include `packageServices`.
- Ensure standard Firestore mapping rules (safety checks) are applied.

### [NEW] Package Migration Utility
A service or static method to perform the backfill:
- Fetch all `patient_packages` where `packageServices` is null.
- For each, fetch source `PackageEntity` from `clinics/{clinicId}/packages/{packageId}`.
- Update `patient_packages` with `packageName` and `packageServices`.
