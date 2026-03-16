import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// UpdatePackageServiceUsageUseCase
///
/// **English**: Safely updates the usage count for a specific service in a patient's package.
///
/// **Constraints (R3)**:
/// - Uses `FirebaseFirestore.runTransaction()` to read-then-write atomically.
/// - Increments `usedCount` for the target service.
/// - Recalculates `usedServicesCount` by counting how many services have `usedCount >= quantity`.
/// - Requires fetching the original package definition to read `quantity` because it is not copied into `ServiceUsageItem`.
@lazySingleton
class UpdatePackageServiceUsageUseCase {
  UpdatePackageServiceUsageUseCase(this._firestore);
  final FirebaseFirestore _firestore;

  Future<Either<Failure, Unit>> call({
    required String patientId,
    required String patientPackageId,
    required String serviceId,
  }) async {
    try {
      final patientPackageRef = _firestore
          .collection('patients')
          .doc(patientId)
          .collection('packages')
          .doc(patientPackageId);

      await _firestore.runTransaction<void>((transaction) async {
        // 1. Read PatientPackage
        final ppSnapshot = await transaction.get(patientPackageRef);
        if (!ppSnapshot.exists || ppSnapshot.data() == null) {
          throw Exception('PatientPackageNotFound');
        }

        final ppData = ppSnapshot.data()!;
        final clinicId = ppData['clinicId'] as String?;
        final packageId = ppData['packageId'] as String?;

        if (clinicId == null || packageId == null) {
          throw Exception('InvalidPatientPackageData');
        }

        // 2. Read Original Package to get quantities
        final packageRef = _firestore
            .collection('clinics')
            .doc(clinicId)
            .collection('packages')
            .doc(packageId);

        final pkgSnapshot = await transaction.get(packageRef);
        if (!pkgSnapshot.exists || pkgSnapshot.data() == null) {
          throw Exception('OriginalPackageNotFound');
        }

        final pkgData = pkgSnapshot.data()!;
        final servicesList = List<Map<String, dynamic>>.from(
          (pkgData['services'] as Iterable<dynamic>?) ?? [],
        );

        // Map serviceId -> quantity
        final quantitiesMap = <String, int>{};
        for (final s in servicesList) {
          final sId = s['serviceId'] as String?;
          final quantity = (s['quantity'] as num?)?.toInt() ?? 1;
          if (sId != null) quantitiesMap[sId] = quantity;
        }

        if (!quantitiesMap.containsKey(serviceId)) {
          throw Exception('ServiceNotFoundInPackageDef');
        }

        // 3. Update servicesUsage in PatientPackage
        final servicesUsageRaw = ppData['servicesUsage'];
        final servicesUsageList = servicesUsageRaw is Iterable
            ? List<Map<String, dynamic>>.from(servicesUsageRaw)
            : <Map<String, dynamic>>[];

        final idx = servicesUsageList.indexWhere(
          (s) => s['serviceId'] == serviceId,
        );

        if (idx == -1) {
          // Add new usage item
          servicesUsageList.add({
            'serviceId': serviceId,
            'usedCount': 1,
            'lastUsedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Increment existing usage item
          final currentItem = servicesUsageList[idx];
          final newCount = (currentItem['usedCount'] as num?)?.toInt() ?? 0;
          servicesUsageList[idx] = {
            ...currentItem,
            'usedCount': newCount + 1,
            'lastUsedAt': FieldValue.serverTimestamp(),
          };
        }

        // 4. Recompute usedServicesCount
        var newUsedServicesCount = 0;
        for (final usage in servicesUsageList) {
          final uId = usage['serviceId'] as String?;
          final uCount = (usage['usedCount'] as num?)?.toInt() ?? 0;
          if (uId != null && quantitiesMap.containsKey(uId)) {
            final targetQty = quantitiesMap[uId]!;
            if (uCount >= targetQty) {
              newUsedServicesCount++;
            }
          }
        }

        // 5. Write back to PatientPackage
        transaction.update(patientPackageRef, {
          'servicesUsage': servicesUsageList,
          'usedServicesCount': newUsedServicesCount,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      return const Right(unit);
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('[UpdatePackageServiceUsageUseCase] Error: $e');
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
