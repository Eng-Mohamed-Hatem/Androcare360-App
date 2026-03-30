import 'package:dartz/dartz.dart';
import 'package:elajtech/core/domain/entities/pending_doctor_list_item.dart';
import 'package:elajtech/core/error/failures.dart';

/// Get Pending Doctors Use Case interface
///
/// This use case retrieves all pending doctor registrations
/// that are awaiting admin approval. It returns a list of
/// simplified doctor items for the admin UI.
///
/// **Arabic**: حالة استخدام جلب الأطباء المعلقين
/// **English**: Use case for retrieving pending doctors for admin review
///
/// **Business Rules:**
/// - Only admins can view pending doctors (role-based access control)
/// - Returns doctors where userType='doctor' and isApproved=false
/// - Results are ordered by createdAt (newest first)
/// - Returns simplified PendingDoctorListItem view model
///
/// **Usage Example:**
/// ```dart
/// final useCase = getIt<GetPendingDoctorsUseCase>();
/// final result = await useCase.call();
/// result.fold(
///   (failure) => showError(failure.message),
///   (doctors) => displayPendingDoctors(doctors),
/// );
/// ```
// ignore: one_member_abstracts, use case contract is kept explicit for DI and testing
abstract interface class GetPendingDoctorsUseCase {
  /// Gets all pending doctors awaiting admin approval.
  ///
  /// Returns doctors where:
  /// - userType = 'doctor'
  /// - isApproved = false
  ///
  /// Results are ordered by createdAt (newest first).
  ///
  /// **Returns:** `Either<Failure, List<PendingDoctorListItem>>`
  ///
  /// **Failure cases:**
  /// - Server error: Firestore query failed
  Future<Either<Failure, List<PendingDoctorListItem>>> call();
}
