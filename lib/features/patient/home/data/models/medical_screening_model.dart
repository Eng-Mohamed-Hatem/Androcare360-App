import 'package:freezed_annotation/freezed_annotation.dart';

part 'medical_screening_model.freezed.dart';
part 'medical_screening_model.g.dart';

/// نموذج الفحص الطبي المبدئي للمريض
/// Medical Screening Model
@freezed
abstract class MedicalScreeningModel with _$MedicalScreeningModel {
  const factory MedicalScreeningModel({
    @Default(false) bool diabetes,
    @Default(false) bool hypertension,
    @Default(false) bool heartDiseases,
    @Default(false) bool prostate,
    @Default(false) bool jointDiseases,
    @Default(false) bool obesity,
    @Default(false) bool previousSurgeries,
    @Default(false) bool smokingOrAlcohol,
    @Default(false) bool allergicDiseases,
    @Default(false) bool kidneyDiseases,
    @Default(false) bool previousAccidents,
  }) = _MedicalScreeningModel;
  const MedicalScreeningModel._();

  factory MedicalScreeningModel.fromJson(Map<String, dynamic> json) =>
      _$MedicalScreeningModelFromJson(json);
}
