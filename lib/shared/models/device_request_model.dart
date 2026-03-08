import 'package:elajtech/shared/utils/json_helpers.dart';

/// Device Request Model - نموذج طلب الأجهزة الطبية
class DeviceRequestModel {
  DeviceRequestModel({
    required this.id,
    required this.appointmentId,
    required this.doctorId,
    required this.doctorName,
    required this.patientId,
    required this.patientName,
    required this.deviceNames,
    required this.createdAt,
    this.notes,
  });

  factory DeviceRequestModel.fromJson(Map<String, dynamic> json) =>
      DeviceRequestModel(
        id: json['id'] as String,
        appointmentId: json['appointmentId'] as String,
        doctorId: json['doctorId'] as String,
        doctorName: json['doctorName'] as String,
        patientId: json['patientId'] as String,
        patientName: json['patientName'] as String,
        deviceNames: List<String>.from(json['deviceNames'] as List),
        notes: json['notes'] as String?,
        createdAt: JsonHelpers.parseDateTime(json['createdAt']),
      );
  final String id;
  final String appointmentId;
  final String doctorId;
  final String doctorName;
  final String patientId;
  final String patientName;
  final List<String> deviceNames;
  final String? notes;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'appointmentId': appointmentId,
    'doctorId': doctorId,
    'doctorName': doctorName,
    'patientId': patientId,
    'patientName': patientName,
    'deviceNames': deviceNames,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };
}
