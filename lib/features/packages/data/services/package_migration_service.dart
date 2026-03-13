import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Service to backfill missing fields in legacy patient package records.
///
/// Target records:
/// `patients/{patientId}/packages/{patientPackageId}`
///
/// Source records:
/// `clinics/{clinicId}/packages/{packageId}`
@lazySingleton
class PackageMigrationService {
  PackageMigrationService(this._firestore);

  final FirebaseFirestore _firestore;

  /// Backfills `packageName` and `packageServices` for legacy records.
  ///
  /// If [isDryRun] is true, no writes are made and only counters/logging are produced.
  Future<MigrationResult> runBackfill({bool isDryRun = true}) async {
    var totalProcessed = 0;
    var totalUpdated = 0;
    var totalErrors = 0;
    final startedAt = DateTime.now();

    try {
      if (kDebugMode) {
        debugPrint(
          '[PackageMigrationService] Starting backfill migration (dryRun: $isDryRun)...',
        );
      }

      final snapshots = await _firestore.collectionGroup('packages').get();

      if (kDebugMode) {
        debugPrint(
          '[PackageMigrationService] Found ${snapshots.docs.length} total package records.',
        );
      }

      // Cache source package definitions to reduce Firestore reads.
      final sourcePackageCache = <String, Map<String, dynamic>>{};

      for (final doc in snapshots.docs) {
        // Only process purchased patient package documents.
        if (!doc.reference.path.startsWith('patients/')) {
          continue;
        }

        totalProcessed++;
        final data = doc.data();
        final existingName = data['packageName'] as String?;
        final existingServices = data['packageServices'] as List<dynamic>?;

        final alreadyMigrated =
            existingName != null &&
            existingServices != null &&
            existingServices.isNotEmpty;
        if (alreadyMigrated) {
          continue;
        }

        final packageId = data['packageId'] as String?;
        final clinicId = data['clinicId'] as String?;

        if (packageId == null || clinicId == null) {
          if (kDebugMode) {
            debugPrint(
              '[PackageMigrationService] Skipping doc ${doc.id}: Missing packageId or clinicId.',
            );
          }
          totalErrors++;
          continue;
        }

        try {
          final cacheKey = '$clinicId/$packageId';
          var sourceData = sourcePackageCache[cacheKey];

          if (sourceData == null) {
            final sourceDoc = await _firestore
                .collection('clinics')
                .doc(clinicId)
                .collection('packages')
                .doc(packageId)
                .get();

            if (sourceDoc.exists) {
              sourceData = sourceDoc.data();
              if (sourceData != null) {
                sourcePackageCache[cacheKey] = sourceData;
              }
            }
          }

          if (sourceData == null) {
            if (kDebugMode) {
              debugPrint(
                '[PackageMigrationService] Warning: Source package $cacheKey not found.',
              );
            }
            totalErrors++;
            continue;
          }

          final sourceName = sourceData['name'] as String? ?? 'Unnamed Package';
          final sourceServices = sourceData['services'] as List<dynamic>? ?? [];

          final updates = <String, dynamic>{
            'packageName': sourceName,
            'packageServices': sourceServices,
            'updatedAt': FieldValue.serverTimestamp(),
            'migrationDate': FieldValue.serverTimestamp(),
            'migrationVersion': 'patient-packages-v1',
          };

          if (isDryRun) {
            if (kDebugMode) {
              debugPrint(
                '[DRY RUN] Would update ${doc.reference.path} with name: $sourceName, services count: ${sourceServices.length}',
              );
            }
          } else {
            await doc.reference.update(updates);
            if (kDebugMode) {
              debugPrint(
                '[PackageMigrationService] Updated ${doc.reference.path}',
              );
            }
          }

          totalUpdated++;
        } on Exception catch (e) {
          if (kDebugMode) {
            debugPrint(
              '[PackageMigrationService] Error processing doc ${doc.id}: $e',
            );
          }
          totalErrors++;
        }
      }

      return MigrationResult(
        totalProcessed: totalProcessed,
        totalUpdated: totalUpdated,
        totalErrors: totalErrors,
        isDryRun: isDryRun,
        startedAt: startedAt,
        completedAt: DateTime.now(),
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('[PackageMigrationService] Fatal migration error: $e');
      }
      rethrow;
    }
  }
}

class MigrationResult {
  MigrationResult({
    required this.totalProcessed,
    required this.totalUpdated,
    required this.totalErrors,
    required this.isDryRun,
    required this.startedAt,
    required this.completedAt,
  });

  final int totalProcessed;
  final int totalUpdated;
  final int totalErrors;
  final bool isDryRun;
  final DateTime startedAt;
  final DateTime completedAt;

  Duration get duration => completedAt.difference(startedAt);

  @override
  String toString() =>
      'MigrationResult(total: $totalProcessed, updated: $totalUpdated, errors: $totalErrors, isDryRun: $isDryRun, durationMs: ${duration.inMilliseconds})';
}
