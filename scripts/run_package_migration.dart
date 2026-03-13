/// One-time legacy migration runner for patient packages.
///
/// Usage:
///   flutter pub run scripts/run_package_migration.dart --dry-run
///   flutter pub run scripts/run_package_migration.dart --run --environment emulator
library;

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/features/packages/data/services/package_migration_service.dart';
import 'package:elajtech/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  final shouldRun = args.contains('--run');
  final isDryRun = !shouldRun;
  var environment = 'dev';

  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--environment' && i + 1 < args.length) {
      environment = args[i + 1].trim().toLowerCase();
    }
  }

  if (!['dev', 'prod', 'emulator'].contains(environment)) {
    stderr
      ..writeln('Invalid environment: $environment')
      ..writeln('Allowed: dev, prod, emulator');
    exit(1);
  }

  try {
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
    final result = await service.runBackfill(isDryRun: isDryRun);

    stdout
      ..writeln('Package migration finished.')
      ..writeln('Mode: ${isDryRun ? 'DRY RUN' : 'LIVE RUN'}')
      ..writeln('Environment: $environment')
      ..writeln('Result: $result');

    if (result.totalErrors > 0) {
      exit(2);
    }

    exit(0);
  } on Exception catch (e, stackTrace) {
    stderr
      ..writeln('Migration failed: $e')
      ..writeln(stackTrace);
    exit(1);
  }
}
