// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_service_usage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PackageServiceUsage _$PackageServiceUsageFromJson(Map<String, dynamic> json) =>
    _PackageServiceUsage(
      serviceId: json['serviceId'] as String,
      usedAt: DateTime.parse(json['usedAt'] as String),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$PackageServiceUsageToJson(
  _PackageServiceUsage instance,
) => <String, dynamic>{
  'serviceId': instance.serviceId,
  'usedAt': instance.usedAt.toIso8601String(),
  'note': instance.note,
};
