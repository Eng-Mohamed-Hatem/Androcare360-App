// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PackageDocument _$PackageDocumentFromJson(Map<String, dynamic> json) =>
    _PackageDocument(
      id: json['id'] as String,
      documentUrl: json['documentUrl'] as String,
      fileName: json['fileName'] as String,
      mimeType: json['mimeType'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
      uploadedBy: json['uploadedBy'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$PackageDocumentToJson(_PackageDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'documentUrl': instance.documentUrl,
      'fileName': instance.fileName,
      'mimeType': instance.mimeType,
      'fileSize': instance.fileSize,
      'uploadedBy': instance.uploadedBy,
      'uploadedAt': instance.uploadedAt.toIso8601String(),
      'note': instance.note,
    };
