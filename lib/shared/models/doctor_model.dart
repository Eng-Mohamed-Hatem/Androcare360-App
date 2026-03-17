/// Represents a doctor's profile in the AndroCare360 system.
///
/// This model stores doctor-specific information including specializations,
/// experience, ratings, availability, and consultation details. It is used
/// for displaying doctor listings and managing appointment bookings.
///
/// **Firestore Collection:** `users` (with userType = 'doctor')
///
/// **Specializations Field:**
/// The specializations list contains the doctor's medical specialties in Arabic.
/// Always check if the list is not empty before accessing:
/// ```dart
/// final specialty = doctor.specializations.isNotEmpty
///     ? doctor.specializations.first
///     : 'عام';
/// ```
///
/// **Usage Example:**
/// ```dart
/// final doctor = DoctorModel(
///   id: 'doctor_123',
///   fullName: 'د. أحمد محمد',
///   specializations: ['أمراض البروستات', 'جراحة مسالك'],
///   yearsOfExperience: 15,
///   rating: 4.8,
///   reviewsCount: 120,
///   availableDays: ['الأحد', 'الاثنين', 'الأربعاء'],
///   isAvailableForVideo: true,
///   isAvailableInClinic: true,
///   consultationFee: 300.0,
///   bio: 'استشاري أمراض البروستات والمسالك البولية',
/// );
/// ```
class DoctorModel {
  DoctorModel({
    required this.id,
    required this.fullName,
    required this.specializations,
    required this.yearsOfExperience,
    required this.rating,
    required this.reviewsCount,
    required this.availableDays,
    required this.isAvailableForVideo,
    required this.isAvailableInClinic,
    required this.consultationFee,
    this.profileImage,
    this.bio,
    this.workingHours,
  });

  /// Creates a DoctorModel from JSON data.
  ///
  /// This factory constructor parses JSON data from Firestore and creates
  /// a DoctorModel instance. It handles backward compatibility for the
  /// specialization field (supports both single string and list formats).
  ///
  /// Parameters:
  /// - [json]: Map containing doctor data with all required fields
  ///
  /// Returns a fully initialized DoctorModel instance.
  factory DoctorModel.fromJson(Map<String, dynamic> json) => DoctorModel(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    specializations: (json['specialization'] is List)
        ? (json['specialization'] as List<dynamic>)
              .map((e) => e as String)
              .toList()
        : [json['specialization'] as String? ?? 'عام'],
    yearsOfExperience: json['yearsOfExperience'] as int,
    rating: (json['rating'] as num).toDouble(),
    reviewsCount: json['reviewsCount'] as int,
    profileImage: json['profileImage'] as String?,
    bio: json['bio'] as String?,
    availableDays: (json['availableDays'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
    workingHours: json['workingHours'] != null
        ? (json['workingHours'] as Map<String, dynamic>).map(
            (k, v) => MapEntry(
              k,
              (v as List<dynamic>).map((e) => e as String).toList(),
            ),
          )
        : null,
    isAvailableForVideo: json['isAvailableForVideo'] as bool,
    isAvailableInClinic: json['isAvailableInClinic'] as bool,
    consultationFee: (json['consultationFee'] as num).toDouble(),
  );

  /// Unique identifier for the doctor (matches user ID)
  final String id;

  /// Full name of the doctor (e.g., 'د. أحمد محمد')
  final String fullName;

  /// List of medical specializations in Arabic
  ///
  /// **Safe Access Pattern:**
  /// ```dart
  /// final specialty = doctor.specializations.isNotEmpty
  ///     ? doctor.specializations.first
  ///     : 'عام';
  /// ```
  final List<String> specializations;

  /// Years of medical experience
  final int yearsOfExperience;

  /// Average rating from patient reviews (0.0 to 5.0)
  final double rating;

  /// Total number of patient reviews
  final int reviewsCount;

  /// URL to doctor's profile image (optional)
  final String? profileImage;

  /// Professional biography or description (optional)
  final String? bio;

  /// List of available days for appointments (e.g., ['الأحد', 'الاثنين'])
  final List<String> availableDays;

  /// Working hours schedule organized by day
  ///
  /// Example structure:
  /// ```dart
  /// {
  ///   'الأحد': ['09:00 ص', '10:00 ص', '11:00 ص'],
  ///   'الاثنين': ['09:00 ص', '10:00 ص'],
  /// }
  /// ```
  final Map<String, List<String>>? workingHours;

  /// Indicates if doctor offers video consultations
  final bool isAvailableForVideo;

  /// Indicates if doctor offers in-clinic appointments
  final bool isAvailableInClinic;

  /// Consultation fee in SAR
  final double consultationFee;

  /// Returns the primary specialization of the doctor.
  ///
  /// This getter safely accesses the first specialization in the list,
  /// providing a fallback value of 'عام' (General) if the list is empty.
  ///
  /// Returns the first specialization or 'عام' if none available.
  String get mainSpecialization =>
      specializations.isNotEmpty ? specializations.first : 'عام';

  /// Returns a formatted string of all specializations joined by Arabic comma.
  ///
  /// Example: 'أمراض البروستات، جراحة مسالك'
  ///
  /// Returns comma-separated specializations string.
  String get specializationsFormatted => specializations.join('، ');

  /// Converts this DoctorModel to JSON format for Firestore storage.
  ///
  /// This method serializes all doctor data into a Map suitable for
  /// storing in Firestore or sending via API.
  ///
  /// Returns a `Map<String, dynamic>` containing all doctor data.
  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'specialization': specializations,
    'yearsOfExperience': yearsOfExperience,
    'rating': rating,
    'reviewsCount': reviewsCount,
    'profileImage': profileImage,
    'bio': bio,
    'availableDays': availableDays,
    'workingHours': workingHours,
    'isAvailableForVideo': isAvailableForVideo,
    'isAvailableInClinic': isAvailableInClinic,
    'consultationFee': consultationFee,
  };
}

/// Provides mock doctor data for testing and development.
///
/// This class generates sample doctor profiles for use in UI development
/// and testing scenarios without requiring actual Firestore data.
class MockDoctors {
  /// Returns a list of mock doctor profiles.
  ///
  /// Parameters:
  /// - [registeredUsers]: Optional list of registered users (for future use)
  ///
  /// Returns a list of DoctorModel instances with sample data.
  static List<DoctorModel> getDoctors([List<dynamic>? registeredUsers]) => [
    DoctorModel(
      id: 'doctor_ahmed_001', // Fixed ID matching registration
      fullName: 'د. أحمد محمد',
      specializations: ['أمراض البروستات', 'جراحة مسالك'],
      yearsOfExperience: 15,
      rating: 4.8,
      reviewsCount: 120,
      bio: 'استشاري أمراض البروستات والمسالك البولية',
      availableDays: ['الأحد', 'الاثنين', 'الأربعاء'],
      isAvailableForVideo: true,
      isAvailableInClinic: true,
      consultationFee: 300,
    ),
    DoctorModel(
      id: '2',
      fullName: 'د. سارة علي',
      specializations: ['تأخر الإنجاب', 'نساء وتوليد'],
      yearsOfExperience: 12,
      rating: 4.9,
      reviewsCount: 95,
      bio: 'استشارية العقم والإنجاب المساعد',
      availableDays: ['السبت', 'الاثنين', 'الخميس'],
      isAvailableForVideo: true,
      isAvailableInClinic: true,
      consultationFee: 350,
    ),
    DoctorModel(
      id: '3',
      fullName: 'د. خالد عبدالله',
      specializations: ['جراحات الذكورة', 'عقم الرجال'],
      yearsOfExperience: 20,
      rating: 4.7,
      reviewsCount: 150,
      bio: 'استشاري جراحة المسالك البولية والذكورة',
      availableDays: ['الأحد', 'الثلاثاء', 'الخميس'],
      isAvailableForVideo: false,
      isAvailableInClinic: true,
      consultationFee: 400,
    ),
  ];
}
