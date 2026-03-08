import 'package:elajtech/shared/utils/json_helpers.dart';

/// Prescription Model - نموذج الوصفة الطبية
class PrescriptionModel {
  PrescriptionModel({
    required this.id,
    required this.appointmentId,
    required this.doctorId,
    required this.doctorName,
    required this.patientId,
    required this.patientName,
    required this.patientAge,
    required this.patientMaritalStatus,
    required this.patientPhone,
    required this.diagnosis,
    required this.medicines,
    required this.createdAt,
    this.notes,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) =>
      PrescriptionModel(
        id: json['id'] as String,
        appointmentId: json['appointmentId'] as String,
        doctorId: json['doctorId'] as String,
        doctorName: json['doctorName'] as String,
        patientId: json['patientId'] as String,
        patientName: json['patientName'] as String,
        patientAge: json['patientAge'] as int,
        patientMaritalStatus: json['patientMaritalStatus'] as String,
        patientPhone: json['patientPhone'] as String,
        diagnosis: json['diagnosis'] as String,
        medicines: (json['medicines'] as List<dynamic>)
            .map((m) => Medicine.fromJson(m as Map<String, dynamic>))
            .toList(),
        notes: json['notes'] as String?,
        createdAt: JsonHelpers.parseDateTime(json['createdAt']),
      );
  final String id;
  final String appointmentId;
  final String doctorId;
  final String doctorName; // Added
  final String patientId;
  final String patientName; // Added
  final int patientAge; // Added
  final String patientMaritalStatus; // Added
  final String patientPhone; // Added
  final String diagnosis; // Added
  final List<Medicine> medicines;
  final String? notes;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'appointmentId': appointmentId,
    'doctorId': doctorId,
    'doctorName': doctorName,
    'patientId': patientId,
    'patientName': patientName,
    'patientAge': patientAge,
    'patientMaritalStatus': patientMaritalStatus,
    'patientPhone': patientPhone,
    'diagnosis': diagnosis,
    'medicines': medicines.map((m) => m.toJson()).toList(),
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };
}

/// Medicine Model - نموذج الدواء
class Medicine {
  // Added

  Medicine({
    required this.name,
    required this.type,
    required this.duration,
    required this.frequency,
    this.notes,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
    name: json['name'] as String,
    type: MedicineType.values.firstWhere(
      (e) => e.toString() == 'MedicineType.${json['type']}',
    ),
    duration: json['duration'] as String,
    frequency: json['frequency'] as String,
    notes: json['notes'] as String?,
  );
  final String name;
  final MedicineType type; // Added
  final String
  duration; // Changed to String to support "1 week", "2 weeks", etc.
  final String frequency; // Changed to String/Enum for "1x daily", etc.
  final String? notes;

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type.name,
    'duration': duration,
    'frequency': frequency,
    'notes': notes,
  };
}

/// Medicine Type - نوع الدواء
enum MedicineType {
  tablet, // أقراص
  syrup, // شراب
  injection, // حقن
}

/// Mock Prescriptions (Updated to match new structure if needed, or removing for now to avoid errors)
class MockPrescriptions {
  static List<PrescriptionModel> getPrescriptions() => [];
}
