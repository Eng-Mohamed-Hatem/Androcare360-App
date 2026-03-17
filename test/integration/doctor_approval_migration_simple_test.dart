/// Simple integration test for doctor approval migration.
///
/// Usage:
///   flutter test test/integration/doctor_approval_migration_simple_test.dart --dart-define=DRY_RUN=true
///   flutter test test/integration/doctor_approval_migration_simple_test.dart --dart-define=DRY_RUN=false
@TestOn('vm')
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/core/services/doctor_approval_migration_service.dart';
import 'package:elajtech/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const environment = String.fromEnvironment('ENVIRONMENT');
  final shouldSkip = !['dev', 'prod', 'emulator'].contains(environment);

  if (shouldSkip) {
    test(
      'Run doctor approval migration',
      () async {},
      skip:
          'Set --dart-define=ENVIRONMENT=dev|prod|emulator to run this migration test.',
    );
    return;
  }

  test('Run doctor approval migration', () async {
    const isDryRun = bool.fromEnvironment('DRY_RUN', defaultValue: true);

    print('Initializing Firebase with environment: $environment');
    await Firebase.initializeApp(
      name: 'migration-test',
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');

    print('Creating Firestore instance');
    final firestore = FirebaseFirestore.instanceFor(
      app: Firebase.app('migration-test'),
      databaseId: 'elajtech',
    );

    if (environment == 'emulator') {
      print('Connecting to Firestore emulator at localhost:8080');
      firestore.useFirestoreEmulator('localhost', 8080);
      print('Connected to emulator');
    }

    print('Starting migration service...');
    final service = DoctorApprovalMigrationService(firestore);
    final result = isDryRun
        ? await service.runBackfill()
        : await service.runBackfill(isDryRun: false);

    print('Doctor approval migration finished.');
    print('Mode: ${isDryRun ? "DRY RUN" : "LIVE RUN"}');
    print('Environment: $environment');
    print('Result: $result');

    expect(result.totalErrors, 0, reason: 'Migration should not have errors');
  });
}
