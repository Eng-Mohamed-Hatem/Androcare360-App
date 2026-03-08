import 'package:elajtech/shared/utils/json_helpers.dart';

/// Lab Request Model - نموذج طلب التحليل
class LabRequestModel {
  LabRequestModel({
    required this.id,
    required this.appointmentId,
    required this.doctorId,
    required this.doctorName,
    required this.patientId,
    required this.patientName,
    required this.testNames,
    required this.createdAt,
    this.notes,
  });

  factory LabRequestModel.fromJson(Map<String, dynamic> json) =>
      LabRequestModel(
        id: json['id'] as String,
        appointmentId: json['appointmentId'] as String,
        doctorId: json['doctorId'] as String,
        doctorName: json['doctorName'] as String,
        patientId: json['patientId'] as String,
        patientName: json['patientName'] as String,
        testNames: List<String>.from(json['testNames'] as List),
        notes: json['notes'] as String?,
        createdAt: JsonHelpers.parseDateTime(json['createdAt']),
      );
  final String id;
  final String appointmentId;
  final String doctorId;
  final String doctorName;
  final String patientId;
  final String patientName;
  final List<String> testNames;
  final String? notes;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'appointmentId': appointmentId,
    'doctorId': doctorId,
    'doctorName': doctorName,
    'patientId': patientId,
    'patientName': patientName,
    'testNames': testNames,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };
}
