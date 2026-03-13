import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elajtech/features/packages/data/services/package_migration_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late PackageMigrationService migrationService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    migrationService = PackageMigrationService(fakeFirestore);
  });

  test(
    'should skip records that already have packageName and packageServices',
    () async {
      // Arrange
      await fakeFirestore
          .collection('patients')
          .doc('p123')
          .collection('packages')
          .doc('pp1')
          .set({
            'packageName': 'Existing Name',
            'packageServices': [
              {'serviceId': 's1'},
            ],
            'packageId': 'pkg1',
            'clinicId': 'clinic1',
          });

      // Act
      final result = await migrationService.runBackfill();

      // Assert
      // Only 1 in patients should be processed
      expect(result.totalProcessed, 1);
      expect(result.totalUpdated, 0);
    },
  );

  test(
    'should identify records needing backfill and update them (non-dry-run)',
    () async {
      // Arrange
      // 1. Create source package definition
      await fakeFirestore
          .collection('clinics')
          .doc('clinic1')
          .collection('packages')
          .doc('pkg1')
          .set({
            'name': 'Source Package',
            'services': [
              {
                'serviceId': 's1',
                'serviceType': 'LAB',
                'displayName': 'Service 1',
              },
            ],
          });

      // 2. Create legacy patient package
      final docRef = fakeFirestore
          .collection('patients')
          .doc('p123')
          .collection('packages')
          .doc('pp1');

      await docRef.set({
        'packageId': 'pkg1',
        'clinicId': 'clinic1',
        'status': 'ACTIVE',
      });

      // Act
      final result = await migrationService.runBackfill(isDryRun: false);

      // Assert
      // Only 1 in patients should be processed
      expect(result.totalProcessed, 1);
      expect(result.totalUpdated, 1);
      expect(result.totalErrors, 0);

      // Verify Firestore content
      final updatedDoc = await docRef.get();
      expect(updatedDoc.data()?['packageName'], 'Source Package');
      final services = updatedDoc.data()?['packageServices'] as List;
      expect(services.length, 1);
      final firstService = services.first as Map<String, dynamic>;
      expect(firstService['serviceId'], 's1');
      expect(
        updatedDoc.data()?['migrationVersion'],
        'patient-packages-v1',
      );
    },
  );

  test('should handle missing source package gracefully', () async {
    // Arrange
    await fakeFirestore
        .collection('patients')
        .doc('p123')
        .collection('packages')
        .doc('pp1')
        .set({
          'packageId': 'non_existent',
          'clinicId': 'clinic1',
        });

    // Act
    final result = await migrationService.runBackfill(isDryRun: false);

    // Assert
    expect(result.totalProcessed, 1);
    expect(result.totalUpdated, 0);
    expect(result.totalErrors, 1);
  });
}
