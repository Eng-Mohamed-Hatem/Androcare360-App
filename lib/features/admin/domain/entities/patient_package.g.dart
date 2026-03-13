// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_package.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PatientPackage _$PatientPackageFromJson(Map<String, dynamic> json) =>
    _PatientPackage(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      packageType: json['packageType'] as String,
      services: (json['services'] as List<dynamic>)
          .map((e) => PackageService.fromJson(e as Map<String, dynamic>))
          .toList(),
      servicesUsage: (json['servicesUsage'] as List<dynamic>)
          .map((e) => PackageServiceUsage.fromJson(e as Map<String, dynamic>))
          .toList(),
      usedServicesCount: (json['usedServicesCount'] as num).toInt(),
      documents: (json['documents'] as List<dynamic>)
          .map((e) => PackageDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$PatientPackageToJson(_PatientPackage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'packageType': instance.packageType,
      'services': instance.services,
      'servicesUsage': instance.servicesUsage,
      'usedServicesCount': instance.usedServicesCount,
      'documents': instance.documents,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isActive': instance.isActive,
      'notes': instance.notes,
    };
