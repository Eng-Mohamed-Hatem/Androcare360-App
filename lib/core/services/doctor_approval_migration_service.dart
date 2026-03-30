import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Service to backfill isApproved=true for existing active doctor records.
///
/// Target records:
/// `users/{userId}` where userType='doctor' and isActive=true
@lazySingleton
class DoctorApprovalMigrationService {
  DoctorApprovalMigrationService(this._firestore);

  final FirebaseFirestore _firestore;

  /// Backfills isApproved=true for existing active doctors.
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
          '[DoctorApprovalMigrationService] Starting backfill migration (dryRun: $isDryRun)...',
        );
      }

      final query = _firestore
          .collection('users')
          .where('userType', isEqualTo: 'doctor')
          .where('isActive', isEqualTo: true);

      final snapshots = await query.get();

      if (kDebugMode) {
        debugPrint(
          '[DoctorApprovalMigrationService] Found ${snapshots.docs.length} active doctor records.',
        );
      }

      for (final doc in snapshots.docs) {
        totalProcessed++;
        final data = doc.data();
        final existingIsApproved = data['isApproved'] as bool?;

        final alreadyMigrated = existingIsApproved ?? false;
        if (alreadyMigrated) {
          if (kDebugMode) {
            debugPrint(
              '[DoctorApprovalMigrationService] Skipping doc ${doc.id}: Already has isApproved=true.',
            );
          }
          continue;
        }

        try {
          final updates = <String, dynamic>{
            'isApproved': true,
            'updatedAt': FieldValue.serverTimestamp(),
            'migrationDate': FieldValue.serverTimestamp(),
            'migrationVersion': 'doctor-approval-v1',
          };

          if (isDryRun) {
            if (kDebugMode) {
              debugPrint(
                '[DRY RUN] Would update ${doc.reference.path} with isApproved=true',
              );
            }
          } else {
            await doc.reference.update(updates);
            if (kDebugMode) {
              debugPrint(
                '[DoctorApprovalMigrationService] Updated ${doc.reference.path}',
              );
            }
          }

          totalUpdated++;
        } on Exception catch (e) {
          if (kDebugMode) {
            debugPrint(
              '[DoctorApprovalMigrationService] Error processing doc ${doc.id}: $e',
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
        debugPrint(
          '[DoctorApprovalMigrationService] Fatal migration error: $e',
        );
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
