class AppConstants {
  const AppConstants._();

  static const String appName = 'AndroCare360';

  /// Firebase Collection Names
  static const FirestoreCollections collections = FirestoreCollections();
}

class FirestoreCollections {
  const FirestoreCollections();

  String get users => 'users';
  String get appointments => 'appointments';
  String get doctors => 'doctors';
  String get patients => 'patients';
  String get prescriptions => 'prescriptions';
  String get labRequests => 'lab_requests';
  String get radiologyRequests => 'radiology_requests';
  String get deviceRequests => 'device_requests';
  String get notifications => 'notifications';
  String get emrRecords => 'emr_records';
  String get chats => 'chats';
  String get messages => 'messages';
  String get assessmentReferralEvents => 'assessment_referral_events';
}

/// Centralized list of allowed medical specializations and clinic names.
///
/// Both the specialization dropdown and the clinic name dropdown in the
/// admin doctor form use this exact list. Values are stored as-is in
/// Firestore (plain Arabic strings), so existing documents are compatible.
class MedicalSpecializations {
  const MedicalSpecializations._();

  /// The five allowed specialization / clinic name values.
  static const List<String> values = [
    'الذكورة و العقم و البروستات',
    'السمنة و التغذية العلاجية',
    'العلاج الطبيعي و التأهيل',
    'الباطنة و طب الأسرة',
    'الأمراض المزمنة',
  ];
}
