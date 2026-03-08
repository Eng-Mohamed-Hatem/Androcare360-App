// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'physiotherapy_emr.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PhysiotherapyEMR _$PhysiotherapyEMRFromJson(
  Map<String, dynamic> json,
) => _PhysiotherapyEMR(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  doctorId: json['doctorId'] as String,
  doctorName: json['doctorName'] as String,
  appointmentId: json['appointmentId'] as String,
  visitDate: DateTime.parse(json['visitDate'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  basics: (json['basics'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
  ),
  painAssessment: (json['painAssessment'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
  ),
  functionalAssessment: (json['functionalAssessment'] as Map<String, dynamic>)
      .map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
  systemsReview: (json['systemsReview'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
  ),
  rangeOfMotion: (json['rangeOfMotion'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
  ),
  strengthAssessment: (json['strengthAssessment'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
  ),
  devicesEquipment: (json['devicesEquipment'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
  ),
  treatmentPlan: (json['treatmentPlan'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
  ),
  primaryDiagnosis: json['primaryDiagnosis'] as String?,
  managementPlan: json['managementPlan'] as String?,
  specialization:
      json['specialization'] as String? ?? 'عيادة العلاج الطبيعي والتأهيل',
);

Map<String, dynamic> _$PhysiotherapyEMRToJson(_PhysiotherapyEMR instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'doctorId': instance.doctorId,
      'doctorName': instance.doctorName,
      'appointmentId': instance.appointmentId,
      'visitDate': instance.visitDate.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'basics': instance.basics,
      'painAssessment': instance.painAssessment,
      'functionalAssessment': instance.functionalAssessment,
      'systemsReview': instance.systemsReview,
      'rangeOfMotion': instance.rangeOfMotion,
      'strengthAssessment': instance.strengthAssessment,
      'devicesEquipment': instance.devicesEquipment,
      'treatmentPlan': instance.treatmentPlan,
      'primaryDiagnosis': instance.primaryDiagnosis,
      'managementPlan': instance.managementPlan,
      'specialization': instance.specialization,
    };
