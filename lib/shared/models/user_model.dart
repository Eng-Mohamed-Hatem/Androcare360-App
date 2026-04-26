/// Represents a user in the AndroCare360 system (doctor, patient, or admin).
///
/// This model stores user profile information, authentication details, and
/// role-specific data. It supports patient, doctor, and admin user types.
///
/// **Firestore Collection:** `users`
///
/// **User Types:**
/// - `patient`: Regular patient user with basic profile information
/// - `doctor`: Medical professional with additional credentials and specializations
/// - `admin`: Platform administrator with full system access
///
/// **Specializations Field:**
/// For doctors, the specializations list contains their medical specialties
/// (e.g., 'Nutrition', 'Physiotherapy', 'Internal Medicine'). This field is
/// nullable and should always be checked before access:
/// ```dart
/// final specialty = user.specializations?.isNotEmpty == true
///     ? user.specializations!.first
///     : 'General';
/// ```
///
/// **Approval Flow Fields (Doctor):**
/// - `isApproved`: Admin approval status (true = visible to patients, false = pending)
/// - `approvedAt`: Timestamp of admin approval
/// - `specialty`: Selected specialty from predefined Arabic list
///
/// **Validation Rules:**
/// - Never use the null-check operator (!) on specializations without checking isNotEmpty
/// - Always provide a fallback default value (e.g., 'General') to prevent StateError
/// - Verify user object is not null before accessing any properties
///
/// **Usage Example:**
/// ```dart
/// // Creating a doctor user
/// final doctor = UserModel(
///   id: 'doctor_123',
///   email: 'doctor@example.com',
///   fullName: 'Dr. Sarah Ahmed',
///   userType: UserType.doctor,
///   phoneNumber: '+966500000001',
///   licenseNumber: 'MED-12345',
///   specializations: ['Nutrition', 'Dietetics'],
///   consultationFee: 150.0,
///   consultationTypes: ['video', 'clinic'],
///   createdAt: DateTime.now(),
/// );
///
/// // Creating a patient user
/// final patient = UserModel(
///   id: 'patient_456',
///   email: 'patient@example.com',
///   fullName: 'Ahmed Ali',
///   userType: UserType.patient,
///   phoneNumber: '+966500000002',
///   createdAt: DateTime.now(),
/// );
/// ```
library;

import 'package:elajtech/shared/constants/clinic_types.dart';
import 'package:elajtech/shared/utils/json_helpers.dart';

class UserModel {
  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.userType,
    required this.createdAt,
    this.isActive = true,
    this.isApproved = false,
    this.phoneNumber,
    this.username,
    this.profileImage,
    this.licenseNumber,
    this.specializations,
    this.approvedAt,
    this.specialty,
    this.clinicType,
    this.reviewedAt,
    this.reviewedByAdminId,
    this.reviewedByAdminName,
    this.reviewDecision,
    this.workingHours,
    this.biography,
    this.yearsOfExperience,
    this.consultationFee,
    this.consultationTypes,
    this.clinicName,
    this.clinicAddress,
    this.education,
    this.certificates,
    this.fcmToken,
    this.fcmTokenUpdatedAt,
    this.lastLoginAt,
    this.rating,
    this.reviewsCount,
  });

  /// Creates a UserModel from JSON data.
  ///
  /// This factory constructor parses JSON data from Firestore or API responses
  /// and creates a UserModel instance. It handles backward compatibility for
  /// the specialization field (supports both single string and list formats).
  ///
  /// Parameters:
  /// - [json]: Map containing user data with all required fields
  ///
  /// Returns a fully initialized UserModel instance.
  ///
  /// Throws [FormatException] if date strings are malformed.
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    fcmToken: json['fcmToken'] as String?,
    fcmTokenUpdatedAt: JsonHelpers.parseDateTimeOrNull(
      json['fcmTokenUpdatedAt'],
    ),
    email: json['email'] as String,
    fullName: json['fullName'] as String,
    phoneNumber: json['phoneNumber'] as String?,
    username: json['username'] as String?,
    // Backward compat: missing isActive defaults to true
    isActive: json['isActive'] as bool? ?? true,
    // Backward compat: missing isApproved defaults to true for active doctors (existing data)
    // Otherwise defaults to false for new registrations
    isApproved: json['isApproved'] != null
        ? (json['isApproved'] as bool)
        : ((json['userType'] as String? ?? 'patient') == 'doctor' &&
              (json['isActive'] as bool? ?? true)),
    approvedAt: json['approvedAt'] != null
        ? JsonHelpers.parseDateTime(json['approvedAt'])
        : null,
    specialty: json['specialty'] as String?,
    clinicType: _parseClinicType(json),
    reviewedAt: json['reviewedAt'] != null
        ? JsonHelpers.parseDateTime(json['reviewedAt'])
        : null,
    reviewedByAdminId: json['reviewedByAdminId'] as String?,
    reviewedByAdminName: json['reviewedByAdminName'] as String?,
    reviewDecision: json['reviewDecision'] as String?,
    userType: UserType.values.firstWhere(
      (e) => e.toString() == 'UserType.${json['userType']}',
      orElse: () => UserType.patient,
    ),
    profileImage: json['profileImage'] as String?,
    licenseNumber: json['licenseNumber'] as String?,
    specializations: (json['specializations'] is List)
        ? (json['specializations'] as List<dynamic>)
              .map((e) => e as String)
              .toList()
        : (json['specialization'] is List)
        ? (json['specialization'] as List<dynamic>)
              .map((e) => e as String)
              .toList()
        : (json['specializations'] is String)
        ? [json['specializations'] as String]
        : (json['specialization'] is String)
        ? [json['specialization'] as String]
        : null,
    workingHours: json['workingHours'] != null
        ? (json['workingHours'] as Map<String, dynamic>).map(
            (k, v) => MapEntry(
              k,
              (v as List<dynamic>).map((e) => e as String).toList(),
            ),
          )
        : null,
    biography: json['biography'] as String?,
    yearsOfExperience: json['yearsOfExperience'] as int?,
    consultationFee: (json['consultationFee'] as num?)?.toDouble(),
    consultationTypes: (json['consultationTypes'] is List)
        ? (json['consultationTypes'] as List<dynamic>)
              .map((e) => e as String)
              .toList()
        : null,
    clinicName: json['clinicName'] as String?,
    clinicAddress: json['clinicAddress'] as String?,
    education: (json['education'] is List)
        ? (json['education'] as List<dynamic>)
              .map((e) => Map<String, String>.from(e as Map))
              .toList()
        : null,
    certificates: (json['certificates'] is List)
        ? (json['certificates'] as List<dynamic>)
              .map((e) => Map<String, String>.from(e as Map))
              .toList()
        : null,
    createdAt: JsonHelpers.parseDateTime(json['createdAt']),
    lastLoginAt: JsonHelpers.parseDateTimeOrNull(json['lastLoginAt']),
    rating: (json['rating'] as num?)?.toDouble(),
    reviewsCount: json['reviewsCount'] as int?,
  );

  /// Unique identifier for the user (matches Firebase Auth UID)
  final String id;

  /// User's email address (used for authentication)
  final String email;

  /// Full name of the user (e.g., 'Dr. Sarah Ahmed' or 'Ahmed Ali')
  final String fullName;

  /// Phone number for contact (optional, format: +966XXXXXXXXX)
  final String? phoneNumber;

  /// Username for display (optional, may differ from fullName)
  final String? username;

  /// User role: patient, doctor, or admin
  final UserType userType;

  /// Whether this account is active.
  ///
  /// Admin can deactivate any account. Deactivated accounts:
  /// - Cannot sign in (Firebase Auth disabled)
  /// - Cannot create appointments or join calls (Firestore rules + CF guards)
  /// - Existing EMR records and appointments remain readable per normal permissions
  ///
  /// Defaults to `true` for all newly created accounts and for any existing
  /// Firestore documents that pre-date this field.
  final bool isActive;

  /// Admin approval status for doctor accounts.
  ///
  /// **Only applies to doctors (userType = 'doctor')**
  /// - `true`: Doctor has been reviewed and approved by admin, visible to patients
  /// - `false`: Doctor account is pending admin review, not visible to patients
  ///
  /// Defaults to `false` for all newly created doctor accounts and for any existing
  /// Firestore documents that pre-date this field.
  final bool isApproved;

  /// URL to user's profile image (optional)
  final String? profileImage;

  /// Medical license number (required for doctors, null for patients)
  final String? licenseNumber;

  /// List of medical specializations for doctors (e.g., ['Nutrition', 'Dietetics'])
  ///
  /// **IMPORTANT - Safe Access Pattern:**
  /// Never access this list without checking if it's not empty:
  /// ```dart
  /// final specialty = user.specializations?.isNotEmpty == true
  ///     ? user.specializations!.first
  ///     : 'General';
  /// ```
  ///
  /// **Validation Rule:**
  /// Always provide a fallback default value to prevent StateError on empty lists.
  final List<String>? specializations;

  /// Timestamp when doctor account was approved by admin.
  ///
  /// Only applies to doctors (userType = 'doctor').
  /// Null until approval, then set to DateTime of approval.
  final DateTime? approvedAt;

  /// Doctor's selected specialty from the predefined list (approval flow).
  ///
  /// **Only applies to doctors (userType = 'doctor')**
  /// - Must be one of the allowed Arabic labels:
  ///   - عيادة الذكورة والعقم والبروستات
  ///   - عيادة الأمراض المزمنة
  ///   - عيادة السمنة والتغذية العلاجية
  ///   - عيادة العلاج الطبيعي والتأهيل
  ///   - عيادة الباطنة وطب الأسرة
  ///
  /// This field is required for doctor registration and is validated
  /// against the predefined list in Specialties class.
  final String? specialty;

  /// Canonical database value for the doctor's selected clinic type.
  final String? clinicType;

  /// Timestamp of the most recent admin review action.
  final DateTime? reviewedAt;

  /// Admin ID that processed the doctor application.
  final String? reviewedByAdminId;

  /// Admin display name that processed the doctor application.
  final String? reviewedByAdminName;

  /// Most recent review decision (`approved` or `rejected`).
  final String? reviewDecision;

  /// Working hours schedule for doctors (day -> list of time slots)
  ///
  /// Example:
  /// ```dart
  /// {
  ///   'Sunday': ['09:00 ص', '10:00 ص', '11:00 ص'],
  ///   'Monday': ['09:00 ص', '10:00 ص'],
  /// }
  /// ```
  final Map<String, List<String>>? workingHours;

  /// Professional biography or description (for doctors)
  final String? biography;

  /// Years of medical experience (for doctors)
  final int? yearsOfExperience;

  /// Consultation fee in SAR (for doctors)
  final double? consultationFee;

  /// Types of consultations offered (e.g., ['video', 'clinic'])
  final List<String>? consultationTypes;

  /// Name of clinic where doctor practices
  final String? clinicName;

  /// Physical address of clinic
  final String? clinicAddress;

  /// Educational background (list of degree information)
  ///
  /// Example:
  /// ```dart
  /// [
  ///   {'degree': 'MD', 'institution': 'King Saud University', 'year': '2015'},
  ///   {'degree': 'PhD', 'institution': 'Harvard Medical School', 'year': '2020'},
  /// ]
  /// ```
  final List<Map<String, String>>? education;

  /// Professional certificates and qualifications
  ///
  /// Example:
  /// ```dart
  /// [
  ///   {'name': 'Board Certified Nutritionist', 'issuer': 'Saudi Commission', 'year': '2018'},
  /// ]
  /// ```
  final List<Map<String, String>>? certificates;

  /// Timestamp when user account was created
  final DateTime createdAt;

  /// Firebase Cloud Messaging token for push notifications
  final String? fcmToken;

  /// Timestamp when the FCM token was last updated
  final DateTime? fcmTokenUpdatedAt;

  /// Timestamp of the user's most recent successful login (PR-001).
  /// Used by analytics alerts to detect doctor inactivity.
  final DateTime? lastLoginAt;

  /// Aggregate star rating for doctors (0.0–5.0).
  /// Denormalised from review data; used as the sole patient-rating input
  /// for the analytics performance score calculation.
  final double? rating;

  /// Total number of reviews that contributed to [rating].
  final int? reviewsCount;

  /// Converts this UserModel to JSON format for Firestore storage.
  ///
  /// This method serializes all user data into a Map suitable for
  /// storing in Firestore or sending via API. Note that the specializations
  /// field is stored as 'specialization' (singular) for backward compatibility.
  ///
  /// Returns a `Map<String, dynamic>` containing all user data.
  Map<String, dynamic> toJson() => {
    'id': id,
    'fcmToken': fcmToken,
    'fcmTokenUpdatedAt': fcmTokenUpdatedAt?.toIso8601String(),
    'email': email,
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    'username': username,
    'isActive': isActive,
    'isApproved': isApproved,
    'approvedAt': approvedAt?.toIso8601String(),
    'specialty': specialty,
    'clinicType': clinicType,
    'reviewedAt': reviewedAt?.toIso8601String(),
    'reviewedByAdminId': reviewedByAdminId,
    'reviewedByAdminName': reviewedByAdminName,
    'reviewDecision': reviewDecision,
    'userType': userType.name,
    'profileImage': profileImage,
    'licenseNumber': licenseNumber,
    'specializations': specializations,
    'workingHours': workingHours,
    'biography': biography,
    'yearsOfExperience': yearsOfExperience,
    'consultationFee': consultationFee,
    'consultationTypes': consultationTypes,
    'clinicName': clinicName,
    'clinicAddress': clinicAddress,
    'education': education,
    'certificates': certificates,
    'createdAt': createdAt.toIso8601String(),
    'lastLoginAt': lastLoginAt?.toIso8601String(),
    'rating': rating,
    'reviewsCount': reviewsCount,
  };

  /// Creates a copy of this UserModel with specified fields replaced.
  ///
  /// This method allows creating a modified copy of the user while
  /// preserving all other fields. Useful for updating profile information,
  /// FCM tokens, or doctor-specific details.
  ///
  /// All parameters are optional. If a parameter is not provided, the
  /// corresponding field from the original model is used.
  ///
  /// Returns a new UserModel instance with updated fields.
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? username,
    bool? isActive,
    bool? isApproved,
    UserType? userType,
    String? profileImage,
    String? licenseNumber,
    List<String>? specializations,
    DateTime? approvedAt,
    String? specialty,
    String? clinicType,
    DateTime? reviewedAt,
    String? reviewedByAdminId,
    String? reviewedByAdminName,
    String? reviewDecision,
    Map<String, List<String>>? workingHours,
    String? biography,
    int? yearsOfExperience,
    double? consultationFee,
    List<String>? consultationTypes,
    String? clinicName,
    String? clinicAddress,
    List<Map<String, String>>? education,
    List<Map<String, String>>? certificates,
    DateTime? createdAt,
    String? fcmToken,
    DateTime? fcmTokenUpdatedAt,
    DateTime? lastLoginAt,
    double? rating,
    int? reviewsCount,
  }) => UserModel(
    id: id ?? this.id,
    fcmToken: fcmToken ?? this.fcmToken,
    fcmTokenUpdatedAt: fcmTokenUpdatedAt ?? this.fcmTokenUpdatedAt,
    email: email ?? this.email,
    fullName: fullName ?? this.fullName,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    username: username ?? this.username,
    isActive: isActive ?? this.isActive,
    isApproved: isApproved ?? this.isApproved,
    approvedAt: approvedAt ?? this.approvedAt,
    specialty: specialty ?? this.specialty,
    clinicType: clinicType ?? this.clinicType,
    reviewedAt: reviewedAt ?? this.reviewedAt,
    reviewedByAdminId: reviewedByAdminId ?? this.reviewedByAdminId,
    reviewedByAdminName: reviewedByAdminName ?? this.reviewedByAdminName,
    reviewDecision: reviewDecision ?? this.reviewDecision,
    userType: userType ?? this.userType,
    profileImage: profileImage ?? this.profileImage,
    licenseNumber: licenseNumber ?? this.licenseNumber,
    specializations: specializations ?? this.specializations,
    workingHours: workingHours ?? this.workingHours,
    biography: biography ?? this.biography,
    yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
    consultationFee: consultationFee ?? this.consultationFee,
    consultationTypes: consultationTypes ?? this.consultationTypes,
    clinicName: clinicName ?? this.clinicName,
    clinicAddress: clinicAddress ?? this.clinicAddress,
    education: education ?? this.education,
    certificates: certificates ?? this.certificates,
    createdAt: createdAt ?? this.createdAt,
    lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    rating: rating ?? this.rating,
    reviewsCount: reviewsCount ?? this.reviewsCount,
  );
}

/// Defines the role type of a user in the system.
///
/// **Values:**
/// - `patient`: Regular patient user who books appointments and receives care
/// - `doctor`: Medical professional who provides consultations and manages EMRs
/// - `admin`: Platform administrator with full read/write access to all records
///
/// **Usage:**
/// ```dart
/// switch (user.userType) {
///   case UserType.doctor:  /* show doctor features */ break;
///   case UserType.patient: /* show patient features */ break;
///   case UserType.admin:   /* show admin features */ break;
/// }
/// ```
enum UserType {
  /// Patient user role
  patient, // مريض
  /// Doctor user role
  doctor, // طبيب
  /// Platform administrator role — full system access, managed by developers
  admin, // مسؤول النظام
}

String? _parseClinicType(Map<String, dynamic> json) {
  final clinicType = json['clinicType'] as String?;
  if (ClinicTypes.isValid(clinicType)) {
    return clinicType!.trim();
  }

  final specialty = json['specialty'] as String?;
  final mappedFromSpecialty = ClinicTypes.fromArabicLabel(specialty);
  if (mappedFromSpecialty != null) {
    return mappedFromSpecialty;
  }

  final clinicName = json['clinicName'] as String?;
  return ClinicTypes.fromArabicLabel(clinicName);
}
