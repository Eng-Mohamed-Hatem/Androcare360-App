import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:elajtech/features/packages/data/models/patient_package_model.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';

import 'patient_package_model_test.mocks.dart';

@GenerateMocks([DocumentSnapshot])
void main() {
  group('PatientPackageModel', () {
    final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

    final testData = {
      'patientId': 'p123',
      'packageId': 'pkg456',
      'packageName': 'باقة تجريبية',
      'clinicId': 'andrology',
      'category': 'Andrology_Infertility_Prostate',
      'status': 'ACTIVE',
      'purchaseDate': Timestamp.fromDate(DateTime(2026, 3, 10)),
      'expiryDate': Timestamp.fromDate(DateTime(2026, 6, 10)),
      'totalServicesCount': 5,
      'usedServicesCount': 0,
      'isTestPurchase': true,
      'servicesUsage': [
        {'serviceId': 's1', 'usedCount': 0},
      ],
      'packageServices': [
        {
          'serviceId': 's1',
          'serviceType': 'LAB',
          'displayName': 'تحليل دم',
          'quantity': 1,
        },
      ],
      'paymentTransactionId': 'TEST_TXN_123',
      'createdAt': Timestamp.fromDate(DateTime(2026, 3, 10)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 3, 10)),
    };

    test('should correctly parse fromFirestore with isTestPurchase: true', () {
      // Arrange
      when(mockSnapshot.exists).thenReturn(true);
      when(mockSnapshot.id).thenReturn('pp_abc');
      when(mockSnapshot.data()).thenReturn(testData);

      // Act
      final model = PatientPackageModel.fromFirestoreForPatient(mockSnapshot);

      // Assert
      expect(model, isNotNull);
      expect(model!.isTestPurchase, isTrue);
      expect(model.paymentTransactionId, 'TEST_TXN_123');
      expect(model.packageServices, isNotEmpty);
      expect(model.packageServices.first.displayName, 'تحليل دم');
    });

    test('should default isTestPurchase to false when field is missing', () {
      // Arrange
      final dataMissingFlag = Map<String, dynamic>.from(testData)
        ..remove('isTestPurchase');
      when(mockSnapshot.exists).thenReturn(true);
      when(mockSnapshot.id).thenReturn('pp_abc');
      when(mockSnapshot.data()).thenReturn(dataMissingFlag);

      // Act
      final model = PatientPackageModel.fromFirestoreForPatient(mockSnapshot);

      // Assert
      expect(model, isNotNull);
      expect(model!.isTestPurchase, isFalse);
    });

    test(
      'should correctly parse fromFirestore when dates are ISO Strings (TPP-017)',
      () {
        // Arrange
        final isoData = Map<String, dynamic>.from(testData)
          ..['purchaseDate'] = '2026-03-10T12:00:00.000Z'
          ..['expiryDate'] = '2026-06-10T12:00:00.000Z'
          ..['createdAt'] = '2026-03-10T10:00:00.000Z'
          ..['updatedAt'] = '2026-03-10T11:00:00.000Z';

        when(mockSnapshot.exists).thenReturn(true);
        when(mockSnapshot.id).thenReturn('pp_iso');
        when(mockSnapshot.data()).thenReturn(isoData);

        // Act
        final model = PatientPackageModel.fromFirestoreForPatient(mockSnapshot);

        // Assert
        expect(model, isNotNull);
        expect(model!.purchaseDate, isA<DateTime>());
        expect(model.purchaseDate.year, 2026);
        expect(model.purchaseDate.month, 3);
        expect(model.purchaseDate.day, 10);
      },
    );

    test('toFirestore should include isTestPurchase', () {
      // Arrange
      final model = PatientPackageModel(
        id: 'pp_abc',
        patientId: 'p123',
        packageId: 'pkg456',
        packageName: 'باقة تجريبية',
        clinicId: 'andrology',
        category: PackageCategory.andrologyInfertilityProstate,
        status: PatientPackageStatus.active,
        purchaseDate: DateTime(2026, 3, 10),
        expiryDate: DateTime(2026, 6, 10),
        totalServicesCount: 5,
        usedServicesCount: 0,
        isTestPurchase: true,
        createdAt: DateTime(2026, 3, 10),
        updatedAt: DateTime(2026, 3, 10),
        paymentTransactionId: 'TEST_TXN_123',
      );

      // Act
      final result = model.toFirestore();

      // Assert
      expect(result['isTestPurchase'], isTrue);
      expect(result.containsKey('packageServices'), isTrue);
    });
  });
}
