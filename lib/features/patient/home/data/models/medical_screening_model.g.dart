// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_screening_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MedicalScreeningModel _$MedicalScreeningModelFromJson(
  Map<String, dynamic> json,
) => _MedicalScreeningModel(
  diabetes: json['diabetes'] as bool? ?? false,
  hypertension: json['hypertension'] as bool? ?? false,
  heartDiseases: json['heartDiseases'] as bool? ?? false,
  prostate: json['prostate'] as bool? ?? false,
  jointDiseases: json['jointDiseases'] as bool? ?? false,
  obesity: json['obesity'] as bool? ?? false,
  previousSurgeries: json['previousSurgeries'] as bool? ?? false,
  smokingOrAlcohol: json['smokingOrAlcohol'] as bool? ?? false,
  allergicDiseases: json['allergicDiseases'] as bool? ?? false,
  kidneyDiseases: json['kidneyDiseases'] as bool? ?? false,
  previousAccidents: json['previousAccidents'] as bool? ?? false,
);

Map<String, dynamic> _$MedicalScreeningModelToJson(
  _MedicalScreeningModel instance,
) => <String, dynamic>{
  'diabetes': instance.diabetes,
  'hypertension': instance.hypertension,
  'heartDiseases': instance.heartDiseases,
  'prostate': instance.prostate,
  'jointDiseases': instance.jointDiseases,
  'obesity': instance.obesity,
  'previousSurgeries': instance.previousSurgeries,
  'smokingOrAlcohol': instance.smokingOrAlcohol,
  'allergicDiseases': instance.allergicDiseases,
  'kidneyDiseases': instance.kidneyDiseases,
  'previousAccidents': instance.previousAccidents,
};
