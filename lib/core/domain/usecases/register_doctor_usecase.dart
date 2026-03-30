import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';

/// Register Doctor Use Case interface
///
/// This use case handles registering new doctor accounts with pending
/// approval state. It validates the doctor's information (specialty,
/// phone number) before creating the account.
///
/// **Arabic**: حالة استخدام تسجيل الأطباء
/// **English**: Use case for doctor registration with validation
///
/// **Business Rules:**
/// - Specialty must be from predefined list (checked in repository)
/// - Phone number must be in E.164 format (checked in repository)
/// - New accounts start with isActive=false, isApproved=false (pending state)
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
// ignore: one_member_abstracts, use case contract is kept explicit for DI and testing
abstract interface class RegisterDoctorUseCase {
  /// Registers a new doctor with validation and pending approval state.
  ///
  /// **Arabic**: ينشئ حساب طبيب جديد بحالة "بانتظار الموافقة".
  /// **English**: Creates a new doctor account in pending approval state.
  ///
  /// This method creates a new doctor account in Firestore with:
  /// - Pending approval state (isActive=false, isApproved=false)
  /// - Selected specialty from predefined Arabic list
  /// - Phone number in E.164 international format
  ///
  /// **Parameters:**
  /// - [fullName]: Doctor's full name
  /// - [email]: Doctor's email address
  /// - [phoneNumber]: Phone number in E.164 format
  /// - [specialty]: Selected specialty from predefined Arabic list
  ///
  /// **Returns:** `Either<Failure, Unit>` - Success if doctor registered
  ///
  /// **Failure cases:**
  /// - Validation error: Invalid specialty or phone number format
  /// - Server error: Firestore write failed
  /// - Auth error: Email already exists or invalid
  Future<Either<Failure, Unit>> call({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String specialty,
  });
}
