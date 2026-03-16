import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/constants/app_constants.dart';
import 'package:elajtech/core/domain/entities/pending_doctor_list_item.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/core/data/repositories/admin_approval_repository.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// مستودع مراجعة واعتماد الأطباء للمسؤول.
///
/// Admin approval repository implementation for AndroCare360 system.
///
/// This repository implements [AdminApprovalRepository] and handles
/// admin operations related to doctor registration approval, including
/// approving, rejecting, and retrieving pending doctors.
///
/// **CRITICAL DATABASE RULES:**
/// - Firestore is automatically configured with databaseId: 'elajtech' via DI
/// - Never use FirebaseFirestore.instance directly (use injected _firestore)
/// - Collection name: 'users' (from AppConstants.collections.users)
/// - All operations include comprehensive error handling
/// - All write operations are logged for debugging
///
/// **Approval Flow:**
/// - approveDoctor: Sets isApproved=true, isActive=true, approvedAt=now()
/// - rejectDoctor: Deletes the doctor document permanently
/// - getPendingDoctors: Queries doctors with userType='doctor' and isApproved=false
///
/// **Dependency Injection:**
/// Registered as @LazySingleton with injectable package. Access via:
/// ```dart
/// final repository = getIt<AdminApprovalRepository>();
/// ```
///
/// **Error Handling:**
/// All methods return `Either<Failure, T>` from dartz package:
/// - Left(Failure): Operation failed with specific error message
/// - Right(T): Operation succeeded with result
///
/// **Usage Example:**
/// ```dart
/// // Get pending doctors for admin review
/// final result = await repository.getPendingDoctors();
/// result.fold(
///   (failure) => showError(failure.message),
///   (doctors) => displayPendingDoctors(doctors),
/// );
///
/// // Approve a doctor
/// await repository.approveDoctor('doctor_123');
///
/// // Reject a doctor
/// await repository.rejectDoctor('doctor_123');
/// ```
@LazySingleton(as: AdminApprovalRepository)
class AdminApprovalRepositoryImpl implements AdminApprovalRepository {
  /// Creates an AdminApprovalRepositoryImpl instance with injected dependencies.
  ///
  /// Parameters:
  /// - [_firestore]: Firestore instance configured with databaseId: 'elajtech'
  AdminApprovalRepositoryImpl(
    this._firestore,
  );

  /// Firestore instance configured for 'elajtech' database
  final FirebaseFirestore _firestore;

  static final String _usersCollection = AppConstants.collections.users;

  @override
  Future<Either<Failure, List<PendingDoctorListItem>>>
  getPendingDoctors() async {
    try {
      if (kDebugMode) {
        debugPrint(
          '📲 [AdminApprovalRepository] Fetching pending doctors',
        );
      }

      final snapshot = await _firestore
          .collection(_usersCollection)
          .where('userType', isEqualTo: 'doctor')
          .where('isApproved', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      final pendingDoctors = <PendingDoctorListItem>[];
      for (final doc in snapshot.docs) {
        try {
          final user = UserModel.fromJson(doc.data());
          pendingDoctors.add(PendingDoctorListItem.fromUserModel(user));
        } on FormatException catch (e, stackTrace) {
          if (kDebugMode) {
            debugPrint(
              '[AdminApprovalRepository] Failed to parse doctor '
              'doctorId=${doc.id}: $e',
            );
            debugPrintStack(stackTrace: stackTrace);
          }
        } on Exception catch (e, stackTrace) {
          if (kDebugMode) {
            debugPrint(
              '[AdminApprovalRepository] Invalid doctor payload '
              'doctorId=${doc.id}: $e',
            );
            debugPrintStack(stackTrace: stackTrace);
          }
        }
      }

      if (kDebugMode) {
        debugPrint(
          '✅ [AdminApprovalRepository] Found ${pendingDoctors.length} pending doctors',
        );
      }

      return Right(pendingDoctors);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AdminApprovalRepository] FirebaseException: ${e.code} - ${e.message}',
        );
      }
      return Left(ServerFailure(_mapFirestoreError(e)));
    } on SocketException {
      if (kDebugMode) {
        debugPrint(
          '❌ [AdminApprovalRepository] SocketException: No internet connection',
        );
      }
      return const Left(
        ServerFailure('لا يوجد اتصال بالإنترنت'),
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AdminApprovalRepository] Unexpected error: $e',
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> approveDoctor(String doctorId) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '📲 [AdminApprovalRepository] Approving doctor: $doctorId',
        );
        debugPrint(
          '[AdminApprovalRepository] action=approve doctorId=$doctorId',
        );
      }

      final approvedAt = DateTime.now();
      final doctorRef = _firestore.collection(_usersCollection).doc(doctorId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(doctorRef);
        final data = snapshot.data();

        if (!snapshot.exists || data == null) {
          throw const _ApprovalStateException('not-found');
        }

        final userType = data['userType'] as String?;
        final isApproved = data['isApproved'] as bool? ?? false;
        final isActive = data['isActive'] as bool? ?? true;

        if (userType != 'doctor') {
          throw const _ApprovalStateException('invalid-user-type');
        }

        if (isApproved || isActive) {
          throw const _ApprovalStateException('already-resolved');
        }

        transaction.update(doctorRef, {
          'isApproved': true,
          'isActive': true,
          'approvedAt': approvedAt.toIso8601String(),
        });
      });

      if (kDebugMode) {
        debugPrint(
          '✅ [AdminApprovalRepository] Doctor approved successfully',
        );
        debugPrint(
          '  - isApproved: true',
        );
        debugPrint(
          '  - isActive: true',
        );
        debugPrint(
          '  - approvedAt: $approvedAt',
        );
      }

      return const Right(unit);
    } on _ApprovalStateException catch (e) {
      return Left(ServerFailure(_mapApprovalStateError(e.code)));
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AdminApprovalRepository] FirebaseException: ${e.code} - ${e.message}',
        );
      }
      return Left(ServerFailure(_mapFirestoreError(e)));
    } on SocketException {
      if (kDebugMode) {
        debugPrint(
          '❌ [AdminApprovalRepository] SocketException: No internet connection',
        );
      }
      return const Left(
        ServerFailure('لا يوجد اتصال بالإنترنت'),
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AdminApprovalRepository] Unexpected error: $e',
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> rejectDoctor(String doctorId) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '📲 [AdminApprovalRepository] Rejecting doctor: $doctorId',
        );
        debugPrint(
          '[AdminApprovalRepository] action=reject doctorId=$doctorId',
        );
      }

      final doctorRef = _firestore.collection(_usersCollection).doc(doctorId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(doctorRef);
        final data = snapshot.data();

        if (!snapshot.exists || data == null) {
          throw const _ApprovalStateException('not-found');
        }

        final userType = data['userType'] as String?;
        final isApproved = data['isApproved'] as bool? ?? false;
        final isActive = data['isActive'] as bool? ?? true;

        if (userType != 'doctor') {
          throw const _ApprovalStateException('invalid-user-type');
        }

        if (isApproved || isActive) {
          throw const _ApprovalStateException('already-resolved');
        }

        transaction.delete(doctorRef);
      });

      if (kDebugMode) {
        debugPrint(
          '✅ [AdminApprovalRepository] Doctor rejected and deleted successfully',
        );
      }

      return const Right(unit);
    } on _ApprovalStateException catch (e) {
      return Left(ServerFailure(_mapApprovalStateError(e.code)));
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AdminApprovalRepository] FirebaseException: ${e.code} - ${e.message}',
        );
      }
      return Left(ServerFailure(_mapFirestoreError(e)));
    } on SocketException {
      if (kDebugMode) {
        debugPrint(
          '❌ [AdminApprovalRepository] SocketException: No internet connection',
        );
      }
      return const Left(
        ServerFailure('لا يوجد اتصال بالإنترنت'),
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AdminApprovalRepository] Unexpected error: $e',
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  String _mapFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'ليس لديك صلاحية للقيام بهذه العملية';
      case 'not-found':
        return 'المستخدم غير موجود';
      case 'already-exists':
        return 'المستخدم موجود بالفعل';
      case 'unavailable':
        return 'الخدمة غير متاحة حالياً';
      case 'deadline-exceeded':
        return 'انتهت مهلة العملية';
      default:
        return e.message ?? 'حدث خطأ أثناء حفظ البيانات';
    }
  }

  String _mapApprovalStateError(String code) {
    switch (code) {
      case 'not-found':
        return 'المستخدم غير موجود';
      case 'invalid-user-type':
        return 'الطلب لا يخص حساب طبيب صالح للمراجعة';
      case 'already-resolved':
        return 'تمت معالجة هذا الطلب بالفعل من مسؤول آخر';
      default:
        return 'حدث خطأ أثناء معالجة طلب الطبيب';
    }
  }
}

class _ApprovalStateException implements Exception {
  const _ApprovalStateException(this.code);

  final String code;
}
