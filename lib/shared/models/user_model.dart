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

import 'package:elajtech/shared/utils/json_helpers.dart';

class UserModel {
  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.userType,
    required this.createdAt,
    this.isActive = true,
    this.phoneNumber,
    this.username,
    this.profileImage,
    this.licenseNumber,
    this.specializations,
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
        : json['specialization'] != null
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

  /// Name of the clinic where doctor practices
  final String? clinicName;

  /// Physical address of the clinic
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

  /// Timestamp when the user account was created
  final DateTime createdAt;

  /// Firebase Cloud Messaging token for push notifications
  final String? fcmToken;

  /// Timestamp when the FCM token was last updated
  final DateTime? fcmTokenUpdatedAt;

  /// Converts this UserModel to JSON format for Firestore storage.
  ///
  /// This method serializes all user data into a Map suitable for
  /// storing in Firestore or sending via API. Note that the specializations
  /// field is stored as 'specialization' (singular) for backward compatibility.
  ///
  /// Returns a Map<String, dynamic> containing all user data.
  Map<String, dynamic> toJson() => {
    'id': id,
    'fcmToken': fcmToken,
    'fcmTokenUpdatedAt': fcmTokenUpdatedAt?.toIso8601String(),
    'email': email,
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    'username': username,
    'isActive': isActive,
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
  };

  /// Creates a copy of this UserModel with the specified fields replaced.
  ///
  /// This method allows creating a modified copy of the user while
  /// preserving all other fields. Useful for updating profile information,
  /// FCM tokens, or doctor-specific details.
  ///
  /// All parameters are optional. If a parameter is not provided, the
  /// corresponding field from the original model is used.
  ///
  /// Returns a new UserModel instance with the updated fields.
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? username,
    bool? isActive,
    UserType? userType,
    String? profileImage,
    String? licenseNumber,
    List<String>? specializations,
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
  }) => UserModel(
    id: id ?? this.id,
    fcmToken: fcmToken ?? this.fcmToken,
    fcmTokenUpdatedAt: fcmTokenUpdatedAt ?? this.fcmTokenUpdatedAt,
    email: email ?? this.email,
    fullName: fullName ?? this.fullName,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    username: username ?? this.username,
    isActive: isActive ?? this.isActive,
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
///   case UserType.admin:   /* show admin features */  break;
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
