import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/admin/data/models/audit_log_model.dart';
import 'package:elajtech/features/admin/domain/entities/audit_log.dart';
import 'package:elajtech/features/admin/domain/repositories/admin_repository.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Firestore + Cloud Functions implementation of [AdminRepository].
///
/// **Critical rules enforced here:**
/// - All Firestore ops use the injected [_firestore] instance configured for
///   `databaseId: 'elajtech'` (never [FirebaseFirestore.instance]).
/// - Cloud Functions are called via [_functions] registered for
///   `europe-west1` region (never the default region).
/// - Every mutation writes a document to the `audit_logs` collection.
///
/// **Dependency Injection:**
/// Registered as @LazySingleton via injectable. Retrieved with:
/// ```dart
/// getIt<AdminRepository>()
/// ```
@LazySingleton(as: AdminRepository)
class AdminRepositoryImpl implements AdminRepository {
  /// Creates [AdminRepositoryImpl] with injected Firebase dependencies.
  ///
  /// - [_firestore]: configured for `elajtech` database
  /// - [_functions]: configured for `europe-west1` region
  AdminRepositoryImpl(this._firestore, this._functions);

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  // ————————————————— Collection helpers —————————————————

  /// Reference to the `users` top-level collection.
  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  /// Reference to the `audit_logs` top-level collection.
  CollectionReference<Map<String, dynamic>> get _auditLogs =>
      _firestore.collection('audit_logs');

  // ————————————————— Logging helper —————————————————

  /// Writes a single audit log entry. Errors here are swallowed so that
  /// they never block the primary operation.
  Future<void> _writeAuditLog(AuditLogModel log) async {
    try {
      await _auditLogs.add(log.toJson());
      if (kDebugMode) {
        debugPrint(
          '📋 AdminRepo: audit_log written — '
          'action=${log.action} target=${log.targetId}',
        );
      }
    } on Exception catch (e) {
      debugPrint('⚠️ AdminRepo: Failed to write audit log: $e');
    }
  }

  // ————————————————— Helpers —————————————————

  /// Parses a Firestore [QuerySnapshot] into a [List<UserModel>].
  List<UserModel> _parseUsers(QuerySnapshot<Map<String, dynamic>> snap) => snap
      .docs
      .map((doc) {
        try {
          final data = {...doc.data(), 'id': doc.id};
          return UserModel.fromJson(data);
        } on Exception catch (e) {
          debugPrint('⚠️ AdminRepo: Failed to parse user ${doc.id}: $e');
          return null;
        }
      })
      .whereType<UserModel>()
      .toList();

  // ————————————————— Doctor management —————————————————

  @override
  Future<Either<Failure, List<UserModel>>> getAllDoctors() async {
    try {
      final snap = await _users.where('userType', isEqualTo: 'doctor').get();
      if (kDebugMode) {
        debugPrint('📋 AdminRepo: getAllDoctors → ${snap.docs.length} docs');
      }
      return Right(_parseUsers(snap));
    } on FirebaseException catch (e) {
      return Left(ServerFailure('خطأ في جلب الأطباء: ${e.message}'));
    } on SocketException {
      return const Left(ServerFailure('لا يوجد اتصال بالإنترنت'));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserModel>>> getAllPatients() async {
    try {
      final snap = await _users.where('userType', isEqualTo: 'patient').get();
      if (kDebugMode) {
        debugPrint('📋 AdminRepo: getAllPatients → ${snap.docs.length} docs');
      }
      return Right(_parseUsers(snap));
    } on FirebaseException catch (e) {
      return Left(ServerFailure('خطأ في جلب المرضى: ${e.message}'));
    } on SocketException {
      return const Left(ServerFailure('لا يوجد اتصال بالإنترنت'));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> createDoctor({
    required UserModel doctor,
    required String password,
    required String adminId,
    required String adminName,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '🩺 AdminRepo: createDoctor — email=${doctor.email} '
          'admin=$adminId',
        );
      }

      // Call Cloud Function which creates the Firebase Auth account
      // and the Firestore user document server-side.
      // The function returns { uid: <newDoctorUid> } on success.
      final callable = _functions.httpsCallable('createDoctorAccount');
      final cfResult = await callable.call<dynamic>({
        'email': doctor.email,
        'password': password,
        'fullName': doctor.fullName,
        'phoneNumber': doctor.phoneNumber,
        'licenseNumber': doctor.licenseNumber,
        'specializations': doctor.specializations ?? [],
        'workingHours': doctor.workingHours ?? {},
        'biography': doctor.biography,
        'yearsOfExperience': doctor.yearsOfExperience,
        'consultationFee': doctor.consultationFee,
        'consultationTypes': doctor.consultationTypes ?? [],
        'clinicName': doctor.clinicName,
        'clinicAddress': doctor.clinicAddress,
        'profileImage': doctor.profileImage,
        'adminName': adminName,
      });

      // Extract UID from Cloud Function response. Fall back to email if the
      // CF does not yet return { uid } so existing deployments keep working.
      final resultData = cfResult.data;
      final newDoctorUid =
          (resultData is Map<String, dynamic>
              ? resultData['uid'] as String?
              : null) ??
          doctor.email;

      // Write audit log using the real UID (not email) as targetId
      await _writeAuditLog(
        AuditLogModel(
          id: '',
          adminId: adminId,
          adminName: adminName,
          action: 'create_doctor',
          targetId: newDoctorUid,
          targetType: 'doctor',
          timestamp: DateTime.now(),
          metadata: {'doctorEmail': doctor.email},
        ),
      );

      if (kDebugMode) {
        debugPrint('✅ AdminRepo: createDoctor succeeded');
      }
      return const Right(unit);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('❌ AdminRepo: createDoctor CF error: ${e.code} ${e.message}');
      return Left(
        ServerFailure('فشل إنشاء حساب الطبيب: ${e.message ?? e.code}'),
      );
    } on SocketException {
      return const Left(ServerFailure('لا يوجد اتصال بالإنترنت'));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateDoctorProfile({
    required UserModel updatedDoctor,
    required UserModel previousDoctor,
    required String adminId,
    required String adminName,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '🩺 AdminRepo: updateDoctorProfile — uid=${updatedDoctor.id} '
          'admin=$adminId',
        );
      }

      // Update only admin-editable fields directly (never overwrite
      // sensitive server-controlled fields: userType, isActive, createdAt, id).
      await _users.doc(updatedDoctor.id).update({
        'fullName': updatedDoctor.fullName,
        'phoneNumber': updatedDoctor.phoneNumber,
        'licenseNumber': updatedDoctor.licenseNumber,
        'specializations': updatedDoctor.specializations,
        'biography': updatedDoctor.biography,
        'consultationFee': updatedDoctor.consultationFee,
        'consultationTypes': updatedDoctor.consultationTypes,
        'clinicName': updatedDoctor.clinicName,
        'clinicAddress': updatedDoctor.clinicAddress,
        'yearsOfExperience': updatedDoctor.yearsOfExperience,
        'workingHours': updatedDoctor.workingHours,
        'education': updatedDoctor.education,
        'certificates': updatedDoctor.certificates,
        'profileImage': updatedDoctor.profileImage,
      });

      // Build field diff for audit log
      final diff = AuditLogModel.diffUsers(previousDoctor, updatedDoctor);

      await _writeAuditLog(
        AuditLogModel(
          id: '',
          adminId: adminId,
          adminName: adminName,
          action: 'update_doctor_profile',
          targetId: updatedDoctor.id,
          targetType: 'doctor',
          timestamp: DateTime.now(),
          changes: diff,
        ),
      );

      if (kDebugMode) {
        debugPrint('✅ AdminRepo: updateDoctorProfile succeeded');
      }
      return const Right(unit);
    } on FirebaseException catch (e) {
      debugPrint('❌ AdminRepo: updateDoctorProfile error: ${e.code}');
      return Left(
        ServerFailure('فشل تحديث ملف الطبيب: ${e.message ?? e.code}'),
      );
    } on SocketException {
      return const Left(ServerFailure('لا يوجد اتصال بالإنترنت'));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ————————————————— Account status —————————————————

  @override
  Future<Either<Failure, Unit>> setAccountStatus({
    required String targetUserId,
    required bool isActive,
    required String adminId,
    required String adminName,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '🔐 AdminRepo: Calling setAccountStatus CF — '
          'targetUserId=$targetUserId, isActive=$isActive, adminName=$adminName',
        );
      }

      final callable = _functions.httpsCallable('setAccountStatus');
      await callable.call<dynamic>({
        'targetUserId': targetUserId,
        'isActive': isActive,
        'adminName': adminName,
      });

      // Write audit log with directional action string so the UI can
      // render correct colour/icon for activate vs deactivate.
      await _writeAuditLog(
        AuditLogModel(
          id: '',
          adminId: adminId,
          adminName: adminName,
          action: isActive ? 'reactivate_account' : 'deactivate_account',
          targetId: targetUserId,
          targetType: 'user',
          timestamp: DateTime.now(),
          metadata: {'isActive': isActive},
        ),
      );

      if (kDebugMode) {
        debugPrint('✅ AdminRepo: setAccountStatus succeeded');
      }
      return const Right(unit);
    } on FirebaseFunctionsException catch (e) {
      debugPrint(
        '❌ AdminRepo: setAccountStatus CF error: ${e.code} ${e.message}',
      );

      final message = switch (e.code) {
        'unauthenticated' => 'يجب تسجيل الدخول مرة أخرى لتنفيذ هذا الإجراء',
        'permission-denied' => 'ليس لديك صلاحية أدمن لتنفيذ هذا الإجراء',
        'invalid-argument' => 'بيانات غير صالحة، يرجى التحقق من المدخلات',
        'not-found' => 'المستخدم غير موجود في النظام',
        'internal' => 'حدث خطأ في الخادم، يرجى المحاولة لاحقاً',
        _ =>
          'فشل ${isActive ? 'تفعيل' : 'تعطيل'} الحساب: ${e.message ?? e.code}',
      };

      return Left(ServerFailure(message));
    } on SocketException {
      return const Left(ServerFailure('لا يوجد اتصال بالإنترنت'));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ————————————————— EMR (read-only) —————————————————

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getPatientEmrHistory(
    String patientId,
  ) async {
    const emrCollections = [
      'prescriptions',
      'lab_requests',
      'radiology_requests',
      'device_requests',
      'emr_records',
      'internal_medicine_emrs',
      'physiotherapy_emrs',
      'nutrition_emrs',
      'appointments',
    ];

    try {
      if (kDebugMode) {
        debugPrint(
          '📋 AdminRepo: getPatientEmrHistory — patientId=$patientId',
        );
      }

      final results = <Map<String, dynamic>>[];

      await Future.wait(
        emrCollections.map((col) async {
          try {
            if (kDebugMode) {
              debugPrint('🔍 AdminRepo: Querying collection: $col');
            }

            final orderField = col == 'appointments'
                ? 'appointmentDate'
                : 'createdAt';

            final snap = await _firestore
                .collection(col)
                .where('patientId', isEqualTo: patientId)
                .orderBy(orderField, descending: true)
                .get();

            if (kDebugMode) {
              debugPrint('✅ AdminRepo: Found ${snap.docs.length} docs in $col');
            }

            for (final doc in snap.docs) {
              results.add({
                'collection': col,
                'id': doc.id,
                'data': doc.data(),
              });
            }
          } on FirebaseException catch (e) {
            if (kDebugMode) {
              debugPrint('⚠️ AdminRepo: Firebase error in $col: ${e.code}');
              debugPrint('   • Message: ${e.message}');
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('❌ AdminRepo: Unexpected error in $col: $e');
            }
          }
        }),
      );

      if (kDebugMode) {
        debugPrint(
          '✅ AdminRepo: getPatientEmrHistory → ${results.length} records',
        );
      }
      return Right(results);
    } on SocketException {
      return const Left(ServerFailure('لا يوجد اتصال بالإنترنت'));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ————————————————— Audit logs —————————————————

  @override
  Stream<List<AuditLog>> watchAuditLogs() => _auditLogs
      .orderBy('timestamp', descending: true)
      .limit(200)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((doc) {
              try {
                return AuditLogModel.fromFirestore(doc);
              } on Exception catch (e) {
                debugPrint(
                  '⚠️ AdminRepo: Failed to parse audit_log ${doc.id}: $e',
                );
                return null;
              }
            })
            .whereType<AuditLog>()
            .toList(),
      );
}
