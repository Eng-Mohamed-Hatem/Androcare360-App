import 'package:elajtech/shared/utils/json_helpers.dart';

/// Radiology Request Model - نموذج طلب الأشعة
class RadiologyRequestModel {
  RadiologyRequestModel({
    required this.id,
    required this.appointmentId,
    required this.doctorId,
    required this.doctorName,
    required this.patientId,
    required this.patientName,
    required this.scanTypes,
    required this.createdAt,
    this.notes,
  });

  factory RadiologyRequestModel.fromJson(Map<String, dynamic> json) =>
      RadiologyRequestModel(
        id: json['id'] as String,
        appointmentId: json['appointmentId'] as String,
        doctorId: json['doctorId'] as String,
        doctorName: json['doctorName'] as String,
        patientId: json['patientId'] as String,
        patientName: json['patientName'] as String,
        scanTypes: List<String>.from(json['scanTypes'] as List),
        notes: json['notes'] as String?,
        createdAt: JsonHelpers.parseDateTime(json['createdAt']),
      );
  final String id;
  final String appointmentId;
  final String doctorId;
  final String doctorName;
  final String patientId;
  final String patientName;
  final List<String> scanTypes; // e.g. MRI, X-Ray, etc.
  final String? notes;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'appointmentId': appointmentId,
    'doctorId': doctorId,
    'doctorName': doctorName,
    'patientId': patientId,
    'patientName': patientName,
    'scanTypes': scanTypes,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };
}
