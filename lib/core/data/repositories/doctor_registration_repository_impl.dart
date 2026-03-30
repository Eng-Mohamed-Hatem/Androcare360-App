import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/constants/app_constants.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/core/data/repositories/doctor_registration_repository.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// تنفيذ مستودع تسجيل الأطباء في AndroCare360.
///
/// Doctor Registration Repository implementation for AndroCare360 system.
///
/// **Arabic**: يدير إنشاء حساب الطبيب بصيغة انتظار المراجعة الإدارية.
/// **English**: Handles doctor account creation in pending-approval mode.
///
/// This repository implements [DoctorRegistrationRepository] interface and handles
/// doctor registration operations, including creating new doctor accounts with
/// pending approval state.
///
/// **CRITICAL DATABASE RULES:**
/// - Firestore is automatically configured with databaseId: 'elajtech' via DI
/// - Never use FirebaseFirestore.instance directly (use injected _firestore)
/// - Collection name: 'users' (from AppConstants.collections.users)
/// - All operations include comprehensive error handling
/// - All write operations are logged for debugging
///
/// **Approval Flow:**
/// - New doctor accounts are created with pending approval state
/// - isActive: false (cannot login until approved)
/// - isApproved: false (not visible to patients)
/// - approvedAt: null (set when admin approves)
///
/// **Dependency Injection:**
/// Registered as @LazySingleton with injectable package. Access via:
/// ```dart
/// final repository = getIt<DoctorRegistrationRepository>();
/// ```
///
/// **Error Handling:**
/// All methods return `Either<Failure, T>` from dartz package:
/// - Left(Failure): Operation failed with specific error message
/// - Right(T): Operation succeeded with result
///
/// **Usage Example:**
/// ```dart
/// final result = await repository.registerDoctor(
///   fullName: 'Dr. Ahmed',
///   email: 'doctor@example.com',
///   phoneNumber: '+201234567890',
///   specialty: 'عيادة السمنة والتغذية العلاجية',
/// );
/// result.fold(
///   (failure) => showError(failure.message),
///   (user) => showSuccessMessage(),
/// );
/// ```
@LazySingleton(as: DoctorRegistrationRepository)
class DoctorRegistrationRepositoryImpl implements DoctorRegistrationRepository {
  /// Creates a DoctorRegistrationRepositoryImpl instance with injected dependencies.
  ///
  /// Parameters:
  /// - [_firebaseAuth]: Firebase Authentication instance
  /// - [_firestore]: Firestore instance configured with databaseId: 'elajtech'
  DoctorRegistrationRepositoryImpl(
    this._firebaseAuth,
    this._firestore,
  );

  /// Firebase Authentication instance for creating auth users
  final FirebaseAuth _firebaseAuth;

  /// Firestore instance configured for 'elajtech' database
  final FirebaseFirestore _firestore;

  @override
  Future<Either<Failure, String>> registerDoctor({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String specialty,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '📲 [DoctorRegistrationRepository] Starting doctor registration',
        );
        debugPrint(
          '  - Full Name: $fullName',
        );
        debugPrint(
          '  - Email: $email',
        );
        debugPrint(
          '  - Phone: $phoneNumber',
        );
        debugPrint(
          '  - Specialty: $specialty',
        );
      }

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: _generateTempPassword(),
      );

      final userId = userCredential.user?.uid;

      if (userId == null) {
        if (kDebugMode) {
          debugPrint(
            '❌ [DoctorRegistrationRepository] Failed to get user ID from auth',
          );
        }
        return const Left(
          ServerFailure('فشل إنشاء الحساب، يرجى المحاولة مرة أخرى'),
        );
      }

      final doctor = UserModel(
        id: userId,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        userType: UserType.doctor,
        specialty: specialty,
        isActive: false,
        createdAt: DateTime.now(),
      );

      if (kDebugMode) {
        debugPrint(
          '📝 [DoctorRegistrationRepository] Writing doctor to Firestore',
        );
        debugPrint('  - userId: $userId');
        debugPrint('  - patientId: N/A');
        debugPrint('  - appointmentId: N/A');
        debugPrint('  - permissionsState: pending_admin_approval');
        debugPrint('  - specialty: $specialty');
        debugPrint('  - phoneNumber: $phoneNumber');
        debugPrint('  - isActive: false (pending approval)');
        debugPrint('  - isApproved: false (pending approval)');
      }

      await _firestore
          .collection(AppConstants.collections.users)
          .doc(userId)
          .set(doctor.toJson());

      if (kDebugMode) {
        debugPrint(
          '✅ [DoctorRegistrationRepository] Doctor registered successfully',
        );
      }

      return Right(userId);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ [DoctorRegistrationRepository] FirebaseAuthException: ${e.code} - ${e.message}',
        );
      }
      return Left(ServerFailure(_mapFirebaseAuthError(e)));
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ [DoctorRegistrationRepository] FirebaseException: ${e.code} - ${e.message}',
        );
      }
      return Left(ServerFailure(_mapFirestoreError(e)));
    } on SocketException {
      if (kDebugMode) {
        debugPrint(
          '❌ [DoctorRegistrationRepository] SocketException: No internet connection',
        );
      }
      return const Left(
        ServerFailure('لا يوجد اتصال بالإنترنت'),
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ [DoctorRegistrationRepository] Unexpected error: $e',
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  String _generateTempPassword() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return 'temp_$random';
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'operation-not-allowed':
        return 'هذا العملية غير مسموحة';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      default:
        return e.message ?? 'حدث خطأ غير معروف';
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
}
