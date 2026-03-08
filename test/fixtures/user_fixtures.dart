/// Test fixtures for UserModel
///
/// Provides factory methods for creating test user data with realistic values.
/// These fixtures are used across unit, widget, and integration tests.
library;

import 'package:elajtech/shared/models/user_model.dart';

/// Provides test fixtures for User model
class UserFixtures {
  /// Creates a doctor user for testing
  ///
  /// Parameters:
  /// - [id]: Optional custom ID (defaults to 'doctor_test_001')
  /// - [fullName]: Optional custom name (defaults to 'Dr. Test Doctor')
  /// - [specializations]: Optional specializations list (defaults to ['Nutrition'])
  /// - [email]: Optional email (defaults to 'doctor@test.com')
  ///
  /// Returns a fully populated UserModel with doctor role
  static UserModel createDoctor({
    String? id,
    String? fullName,
    List<String>? specializations,
    String? email,
    bool isActive = true,
  }) {
    return UserModel(
      id: id ?? 'doctor_test_001',
      fullName: fullName ?? 'Dr. Test Doctor',
      email: email ?? 'doctor@test.com',
      phoneNumber: '+966500000001',
      userType: UserType.doctor,
      isActive: isActive,
      specializations: specializations ?? ['Nutrition'],
      licenseNumber: 'LIC-12345',
      biography: 'Experienced nutritionist with 10 years of practice',
      yearsOfExperience: 10,
      consultationFee: 200,
      consultationTypes: ['video', 'clinic'],
      clinicName: 'Test Nutrition Clinic',
      clinicAddress: 'Riyadh, Saudi Arabia',
      workingHours: {
        'Sunday': ['09:00 AM', '05:00 PM'],
        'Monday': ['09:00 AM', '05:00 PM'],
        'Tuesday': ['09:00 AM', '05:00 PM'],
        'Wednesday': ['09:00 AM', '05:00 PM'],
        'Thursday': ['09:00 AM', '05:00 PM'],
      },
      education: [
        {
          'degree': 'MD',
          'institution': 'King Saud University',
          'year': '2010',
        },
      ],
      certificates: [
        {
          'name': 'Board Certified Nutritionist',
          'issuer': 'Saudi Commission',
          'year': '2012',
        },
      ],
      createdAt: DateTime(2024),
      fcmToken: 'test_fcm_token_doctor',
    );
  }

  /// Creates a physiotherapy doctor for testing
  static UserModel createPhysiotherapyDoctor({
    String? id,
    String? fullName,
  }) {
    return createDoctor(
      id: id ?? 'doctor_physio_001',
      fullName: fullName ?? 'Dr. Physio Test',
      specializations: ['Physiotherapy'],
      email: 'physio@test.com',
    ).copyWith(
      clinicName: 'Test Physiotherapy Clinic',
      biography: 'Experienced physiotherapist specializing in sports injuries',
    );
  }

  /// Creates an admin user for testing
  ///
  /// Parameters:
  /// - [id]: Optional custom ID (defaults to 'admin_test_001')
  /// - [fullName]: Optional custom name (defaults to 'Test Admin')
  /// - [email]: Optional email (defaults to 'admin@test.com')
  /// - [isActive]: Whether the account is active (defaults to true)
  ///
  /// Returns a fully populated UserModel with admin role
  static UserModel createAdmin({
    String? id,
    String? fullName,
    String? email,
    bool isActive = true,
  }) {
    return UserModel(
      id: id ?? 'admin_test_001',
      fullName: fullName ?? 'Test Admin',
      email: email ?? 'admin@test.com',
      phoneNumber: '+966500000000',
      userType: UserType.admin,
      isActive: isActive,
      createdAt: DateTime(2024),
      fcmToken: 'test_fcm_token_admin',
    );
  }

  /// Creates a patient user for testing
  ///
  /// Parameters:
  /// - [id]: Optional custom ID (defaults to 'patient_test_001')
  /// - [fullName]: Optional custom name (defaults to 'Test Patient')
  /// - [email]: Optional email (defaults to 'patient@test.com')
  ///
  /// Returns a fully populated UserModel with patient role
  static UserModel createPatient({
    String? id,
    String? fullName,
    String? email,
    bool isActive = true,
  }) {
    return UserModel(
      id: id ?? 'patient_test_001',
      fullName: fullName ?? 'Test Patient',
      email: email ?? 'patient@test.com',
      phoneNumber: '+966500000002',
      userType: UserType.patient,
      isActive: isActive,
      createdAt: DateTime(2024),
      fcmToken: 'test_fcm_token_patient',
    );
  }

  /// Creates a second patient for testing multi-patient scenarios
  static UserModel createSecondPatient() {
    return createPatient(
      id: 'patient_test_002',
      fullName: 'Test Patient Two',
      email: 'patient2@test.com',
    ).copyWith(
      phoneNumber: '+966500000003',
      fcmToken: 'test_fcm_token_patient2',
    );
  }

  /// Creates a list of multiple doctors with different specializations
  static List<UserModel> createMultipleDoctors() {
    return [
      createDoctor(
        id: 'doctor_nutrition_001',
        fullName: 'Dr. Nutrition Specialist',
        specializations: ['Nutrition'],
      ),
      createPhysiotherapyDoctor(
        id: 'doctor_physio_001',
        fullName: 'Dr. Physio Specialist',
      ),
      createDoctor(
        id: 'doctor_general_001',
        fullName: 'Dr. General Practitioner',
        specializations: ['General Medicine'],
      ),
    ];
  }

  /// Creates a list of multiple patients
  static List<UserModel> createMultiplePatients() {
    return [
      createPatient(id: 'patient_001', fullName: 'Patient One'),
      createPatient(id: 'patient_002', fullName: 'Patient Two'),
      createPatient(id: 'patient_003', fullName: 'Patient Three'),
    ];
  }
}
