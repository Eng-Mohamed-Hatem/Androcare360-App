import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/data/repositories/doctor_registration_repository.dart';
import 'package:elajtech/core/domain/usecases/register_doctor_usecase.dart';
import 'package:elajtech/shared/constants/specialties.dart';
import 'package:elajtech/shared/utils/phone_validator.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Register Doctor Use Case implementation
///
/// This use case handles registering new doctor accounts with pending
/// approval state. It validates the doctor's information (specialty,
/// phone number) before creating the account.
///
/// **Arabic**: حالة استخدام تسجيل الأطباء مع إشعار البريد للمسؤول.
/// **English**: Use case implementation for doctor registration with validation and admin email trigger.
///
/// **Business Rules:**
/// - Specialty must be from predefined list (validated against Specialties.allowedValues)
/// - Phone number must be in E.164 format (validated using PhoneValidator)
/// - New accounts start with isActive=false, isApproved=false (pending state)
/// - Admin notification uses Cloud Functions in `europe-west1`
/// - Email failures are logged and must not block registration
///
/// **Dependency Injection:**
/// Registered as @LazySingleton with injectable package. Access via:
/// ```dart
/// final useCase = getIt<RegisterDoctorUseCase>();
/// ```
///
/// **Usage Example:**
/// ```dart
/// final useCase = getIt<RegisterDoctorUseCase>();
/// final result = await useCase.call(
///   fullName: 'Dr. Ahmed',
///   email: 'doctor@example.com',
///   phoneNumber: '+201234567890',
///   specialty: 'عيادة السمنة والتغذية العلاجية',
/// );
/// result.fold(
///   (failure) => showError(failure.message),
///   (_) => showSuccessMessage(),
/// );
/// ```
@LazySingleton(as: RegisterDoctorUseCase)
class RegisterDoctorUseCaseImpl implements RegisterDoctorUseCase {
  /// Creates a RegisterDoctorUseCaseImpl instance with injected dependencies.
  RegisterDoctorUseCaseImpl(
    this._repository,
    this._functions,
  );

  /// Doctor registration repository
  final DoctorRegistrationRepository _repository;

  /// Firebase Functions instance configured for europe-west1.
  final FirebaseFunctions _functions;

  @override
  Future<Either<Failure, Unit>> call({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String specialty,
  }) async {
    if (kDebugMode) {
      debugPrint('📲 [RegisterDoctorUseCase] Starting doctor registration');
      debugPrint('  - Full Name: $fullName');
      debugPrint('  - Email: $email');
      debugPrint('  - Phone: $phoneNumber');
      debugPrint('  - Specialty: $specialty');
    }

    final phoneValidation = PhoneValidator.validate(phoneNumber);
    if (phoneValidation != null) {
      if (kDebugMode) {
        debugPrint(
          '❌ [RegisterDoctorUseCase] Phone validation failed: $phoneValidation',
        );
      }
      return Left(ServerFailure(phoneValidation));
    }

    if (!Specialties.isValid(specialty)) {
      const errorMessage = 'التخصص غير صحيح، يرجى اختيار تخصص من القائمة';
      if (kDebugMode) {
        debugPrint(
          '❌ [RegisterDoctorUseCase] Specialty validation failed: $specialty',
        );
      }
      return const Left(ServerFailure(errorMessage));
    }

    final repositoryResult = await _repository.registerDoctor(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      specialty: specialty,
    );

    if (repositoryResult.isLeft()) {
      final failure = repositoryResult.swap().getOrElse(() {
        return const ServerFailure('Unknown registration failure');
      });
      if (kDebugMode) {
        debugPrint(
          '❌ [RegisterDoctorUseCase] Registration failed: ${failure.message}',
        );
      }
      return Left(failure);
    }

    final doctorId = repositoryResult.getOrElse(() => '');
    if (kDebugMode) {
      debugPrint(
        '✅ [RegisterDoctorUseCase] Doctor registered successfully with pending approval',
      );
    }

    try {
      if (kDebugMode) {
        debugPrint(
          '[RegisterDoctorUseCase] Calling sendAdminNotification',
        );
        debugPrint('  - functionName: sendAdminNotification');
        debugPrint('  - userId: $doctorId');
        debugPrint('  - patientId: N/A');
        debugPrint('  - appointmentId: N/A');
        debugPrint('  - permissionsState: pending_admin_approval');
      }

      await _functions.httpsCallable('sendAdminNotification').call<void>({
        'doctorId': doctorId,
        'name': fullName,
        'phoneNumber': phoneNumber,
        'specialty': specialty,
        'registrationDate': DateTime.now().toIso8601String(),
      });
    } on FirebaseFunctionsException catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [RegisterDoctorUseCase] sendAdminNotification failed: $error',
        );
        debugPrintStack(stackTrace: stackTrace);
      }
    }

    return const Right(unit);
  }
}
