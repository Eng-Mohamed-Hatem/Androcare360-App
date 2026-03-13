# Quality Checklist: Patient "My Packages" Enhancement

## Data Integrity & Persistence
- [ ] `PatientPackageRepositoryImpl.createPatientPackage` includes `packageName` in the Firestore write.
- [ ] `PatientPackageEntity` correctly snapshots `description`, `shortDescription`, and `validityDays`.
- [ ] All new fields have sensible defaults for legacy records in `PatientPackageModel`.
- [ ] Firestore `databaseId: 'elajtech'` is used for all operations.

## UI / Presentation
- [ ] "My Packages" list shows the human-readable `packageName` as the primary title.
- [ ] "Package Details" header shows the correct human-readable `packageName`.
- [ ] "Package Info" section is present and displays snapped description/validity.
- [ ] "Included Services" section shows every service defined in the package snapshot.
- [ ] Usage ratio `X / Y` is wrapped in `Directionality(textDirection: TextDirection.ltr)`.
- [ ] Progress bars are percentage-based and handle 0% (no usage) and 100% (full usage) correctly.

## Security & Privacy (R2)
- [ ] `notes` field is confirmed to be `null` in the patient profile and details screens.
- [ ] Authentication state is watched via `ref.watch(authProvider).user` with appropriate guards.

## Testing & Quality
- [ ] New widget tests cover:
    - [ ] Empty usage state.
    - [ ] Partial usage state.
    - [ ] Full usage state.
- [ ] `flutter analyze` runs without any errors or warnings.
- [ ] `flutter test` completes with 100% pass rate for the packages module.
- [ ] `build_runner` has been executed after model/entity updates.

## Documentation
- [ ] All new public methods and entities have bilingual DartDoc (Arabic/English).
- [ ] DartDoc includes usage examples.
