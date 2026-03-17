/// Integration test for patient package migration.
///
/// Usage:
///   flutter test test/integration/package_migration_test.dart --dart-define=DRY_RUN=true
///   flutter test test/integration/package_migration_test.dart --dart-define=DRY_RUN=false
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/features/packages/data/services/package_migration_service.dart';
import 'package:elajtech/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const environment = String.fromEnvironment('ENVIRONMENT');
  final shouldSkip = !['dev', 'prod', 'emulator'].contains(environment);

  if (shouldSkip) {
    testWidgets(
      'Run patient package migration',
      (tester) async {},
      skip: true,
    );
    return;
  }

  testWidgets('Run patient package migration', (tester) async {
    const isDryRun = bool.fromEnvironment('DRY_RUN', defaultValue: true);

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final firestore = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'elajtech',
    );

    if (environment == 'emulator') {
      firestore.useFirestoreEmulator('localhost', 8080);
    }

    final service = PackageMigrationService(firestore);
    final result = isDryRun
        ? await service.runBackfill()
        : await service.runBackfill(isDryRun: false);

    print('Package migration finished.');
    print('Mode: ${isDryRun ? "DRY RUN" : "LIVE RUN"}');
    print('Environment: $environment');
    print('Result: $result');

    expect(result.totalErrors, 0, reason: 'Migration should not have errors');
  });
}
