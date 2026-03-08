/// Unit tests for PatientPackageModel — T014 / R2 enforcement
///
/// Focuses on the R2 notes isolation rule:
/// - fromFirestoreForPatient: notes must always be null
/// - fromFirestoreForAdmin: notes must be preserved
/// Also tests the 3 Firestore safety guards on each factory.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/features/packages/data/models/patient_package_model.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'patient_package_model_test.mocks.dart';

@GenerateMocks([DocumentSnapshot, Timestamp])
void main() {
  late MockDocumentSnapshot mockSnapshot;

  /// Returns a ready-to-use data map for a patient package document.
  Map<String, dynamic> validData({String? notes}) => {
    'patientId': 'uid_patient_001',
    'packageId': 'pkg_001',
    'clinicId': 'andrology',
    'category': 'ANDROLOGY_INFERTILITY_PROSTATE',
    'status': 'ACTIVE',
    'purchaseDate': Timestamp.fromDate(DateTime(2026, 3)),
    'expiryDate': Timestamp.fromDate(DateTime(2026, 6)),
    'totalServicesCount': 5,
    'usedServicesCount': 1,
    'servicesUsage': <Map<String, dynamic>>[],
    'paymentTransactionId': 'TXN_001',
    'notes': ?notes,
  };

  setUp(() {
    mockSnapshot = MockDocumentSnapshot();
    when(mockSnapshot.id).thenReturn('pp_001');
    when(mockSnapshot.exists).thenReturn(true);
  });

  group('PatientPackageModel.fromFirestoreForPatient (R2)', () {
    test(
      'notes is always null even when Firestore document contains notes',
      () {
        when(mockSnapshot.data()).thenReturn(
          validData(notes: 'الدكتور يُوصي بمتابعة شهرية'),
        );

        final model = PatientPackageModel.fromFirestoreForPatient(mockSnapshot);

        expect(model, isNotNull);
        expect(
          model!.notes,
          isNull,
          reason: 'R2: notes must be null in patient-facing model',
        );
      },
    );

    test(
      'notes is null when Firestore document does not contain notes field',
      () {
        when(mockSnapshot.data()).thenReturn(validData());

        final model = PatientPackageModel.fromFirestoreForPatient(mockSnapshot);

        expect(model, isNotNull);
        expect(model!.notes, isNull);
      },
    );

    test(
      'returns null when snapshot does not exist (guard 1)',
      () {
        when(mockSnapshot.exists).thenReturn(false);

        final model = PatientPackageModel.fromFirestoreForPatient(mockSnapshot);

        expect(model, isNull);
      },
    );

    test(
      'returns null when data() is null (guard 2)',
      () {
        when(mockSnapshot.data()).thenReturn(null);

        final model = PatientPackageModel.fromFirestoreForPatient(mockSnapshot);

        expect(model, isNull);
      },
    );

    test(
      'maps status correctly from Firestore string',
      () {
        when(mockSnapshot.data()).thenReturn(validData());

        final model = PatientPackageModel.fromFirestoreForPatient(mockSnapshot);

        expect(model!.status, PatientPackageStatus.active);
      },
    );

    test(
      'progressFraction computed correctly',
      () {
        when(mockSnapshot.data()).thenReturn(
          validData()
            ..['totalServicesCount'] = 4
            ..['usedServicesCount'] = 1,
        );

        final model = PatientPackageModel.fromFirestoreForPatient(mockSnapshot);

        expect(model!.progressFraction, closeTo(0.25, 0.001));
      },
    );
  });

  group('PatientPackageModel.fromFirestoreForAdmin (R2)', () {
    test(
      'notes is preserved when Firestore document contains notes',
      () {
        const notesContent = 'الدكتور يُوصي بمتابعة شهرية';
        when(mockSnapshot.data()).thenReturn(
          validData(notes: notesContent),
        );

        final model = PatientPackageModel.fromFirestoreForAdmin(mockSnapshot);

        expect(model, isNotNull);
        expect(
          model!.notes,
          equals(notesContent),
          reason: 'R2: notes must be included in admin-facing model',
        );
      },
    );

    test(
      'notes is null when Firestore document does not contain notes field',
      () {
        when(mockSnapshot.data()).thenReturn(validData());

        final model = PatientPackageModel.fromFirestoreForAdmin(mockSnapshot);

        expect(model, isNotNull);
        expect(model!.notes, isNull);
      },
    );

    test(
      'returns null when snapshot does not exist (guard 1)',
      () {
        when(mockSnapshot.exists).thenReturn(false);

        final model = PatientPackageModel.fromFirestoreForAdmin(mockSnapshot);

        expect(model, isNull);
      },
    );
  });
}
