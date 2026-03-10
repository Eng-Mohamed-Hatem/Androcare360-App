// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PackageService _$PackageServiceFromJson(Map<String, dynamic> json) =>
    _PackageService(
      id: json['id'] as String,
      serviceName: json['serviceName'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
    );

Map<String, dynamic> _$PackageServiceToJson(_PackageService instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serviceName': instance.serviceName,
      'description': instance.description,
      'price': instance.price,
      'durationMinutes': instance.durationMinutes,
    };
