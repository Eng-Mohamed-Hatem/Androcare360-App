// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medical_screening_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MedicalScreeningModel {

 bool get diabetes; bool get hypertension; bool get heartDiseases; bool get prostate; bool get jointDiseases; bool get obesity; bool get previousSurgeries; bool get smokingOrAlcohol; bool get allergicDiseases; bool get kidneyDiseases; bool get previousAccidents;
/// Create a copy of MedicalScreeningModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicalScreeningModelCopyWith<MedicalScreeningModel> get copyWith => _$MedicalScreeningModelCopyWithImpl<MedicalScreeningModel>(this as MedicalScreeningModel, _$identity);

  /// Serializes this MedicalScreeningModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicalScreeningModel&&(identical(other.diabetes, diabetes) || other.diabetes == diabetes)&&(identical(other.hypertension, hypertension) || other.hypertension == hypertension)&&(identical(other.heartDiseases, heartDiseases) || other.heartDiseases == heartDiseases)&&(identical(other.prostate, prostate) || other.prostate == prostate)&&(identical(other.jointDiseases, jointDiseases) || other.jointDiseases == jointDiseases)&&(identical(other.obesity, obesity) || other.obesity == obesity)&&(identical(other.previousSurgeries, previousSurgeries) || other.previousSurgeries == previousSurgeries)&&(identical(other.smokingOrAlcohol, smokingOrAlcohol) || other.smokingOrAlcohol == smokingOrAlcohol)&&(identical(other.allergicDiseases, allergicDiseases) || other.allergicDiseases == allergicDiseases)&&(identical(other.kidneyDiseases, kidneyDiseases) || other.kidneyDiseases == kidneyDiseases)&&(identical(other.previousAccidents, previousAccidents) || other.previousAccidents == previousAccidents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,diabetes,hypertension,heartDiseases,prostate,jointDiseases,obesity,previousSurgeries,smokingOrAlcohol,allergicDiseases,kidneyDiseases,previousAccidents);

@override
String toString() {
  return 'MedicalScreeningModel(diabetes: $diabetes, hypertension: $hypertension, heartDiseases: $heartDiseases, prostate: $prostate, jointDiseases: $jointDiseases, obesity: $obesity, previousSurgeries: $previousSurgeries, smokingOrAlcohol: $smokingOrAlcohol, allergicDiseases: $allergicDiseases, kidneyDiseases: $kidneyDiseases, previousAccidents: $previousAccidents)';
}


}

/// @nodoc
abstract mixin class $MedicalScreeningModelCopyWith<$Res>  {
  factory $MedicalScreeningModelCopyWith(MedicalScreeningModel value, $Res Function(MedicalScreeningModel) _then) = _$MedicalScreeningModelCopyWithImpl;
@useResult
$Res call({
 bool diabetes, bool hypertension, bool heartDiseases, bool prostate, bool jointDiseases, bool obesity, bool previousSurgeries, bool smokingOrAlcohol, bool allergicDiseases, bool kidneyDiseases, bool previousAccidents
});




}
/// @nodoc
class _$MedicalScreeningModelCopyWithImpl<$Res>
    implements $MedicalScreeningModelCopyWith<$Res> {
  _$MedicalScreeningModelCopyWithImpl(this._self, this._then);

  final MedicalScreeningModel _self;
  final $Res Function(MedicalScreeningModel) _then;

/// Create a copy of MedicalScreeningModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? diabetes = null,Object? hypertension = null,Object? heartDiseases = null,Object? prostate = null,Object? jointDiseases = null,Object? obesity = null,Object? previousSurgeries = null,Object? smokingOrAlcohol = null,Object? allergicDiseases = null,Object? kidneyDiseases = null,Object? previousAccidents = null,}) {
  return _then(_self.copyWith(
diabetes: null == diabetes ? _self.diabetes : diabetes // ignore: cast_nullable_to_non_nullable
as bool,hypertension: null == hypertension ? _self.hypertension : hypertension // ignore: cast_nullable_to_non_nullable
as bool,heartDiseases: null == heartDiseases ? _self.heartDiseases : heartDiseases // ignore: cast_nullable_to_non_nullable
as bool,prostate: null == prostate ? _self.prostate : prostate // ignore: cast_nullable_to_non_nullable
as bool,jointDiseases: null == jointDiseases ? _self.jointDiseases : jointDiseases // ignore: cast_nullable_to_non_nullable
as bool,obesity: null == obesity ? _self.obesity : obesity // ignore: cast_nullable_to_non_nullable
as bool,previousSurgeries: null == previousSurgeries ? _self.previousSurgeries : previousSurgeries // ignore: cast_nullable_to_non_nullable
as bool,smokingOrAlcohol: null == smokingOrAlcohol ? _self.smokingOrAlcohol : smokingOrAlcohol // ignore: cast_nullable_to_non_nullable
as bool,allergicDiseases: null == allergicDiseases ? _self.allergicDiseases : allergicDiseases // ignore: cast_nullable_to_non_nullable
as bool,kidneyDiseases: null == kidneyDiseases ? _self.kidneyDiseases : kidneyDiseases // ignore: cast_nullable_to_non_nullable
as bool,previousAccidents: null == previousAccidents ? _self.previousAccidents : previousAccidents // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicalScreeningModel].
extension MedicalScreeningModelPatterns on MedicalScreeningModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicalScreeningModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicalScreeningModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicalScreeningModel value)  $default,){
final _that = this;
switch (_that) {
case _MedicalScreeningModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicalScreeningModel value)?  $default,){
final _that = this;
switch (_that) {
case _MedicalScreeningModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool diabetes,  bool hypertension,  bool heartDiseases,  bool prostate,  bool jointDiseases,  bool obesity,  bool previousSurgeries,  bool smokingOrAlcohol,  bool allergicDiseases,  bool kidneyDiseases,  bool previousAccidents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicalScreeningModel() when $default != null:
return $default(_that.diabetes,_that.hypertension,_that.heartDiseases,_that.prostate,_that.jointDiseases,_that.obesity,_that.previousSurgeries,_that.smokingOrAlcohol,_that.allergicDiseases,_that.kidneyDiseases,_that.previousAccidents);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool diabetes,  bool hypertension,  bool heartDiseases,  bool prostate,  bool jointDiseases,  bool obesity,  bool previousSurgeries,  bool smokingOrAlcohol,  bool allergicDiseases,  bool kidneyDiseases,  bool previousAccidents)  $default,) {final _that = this;
switch (_that) {
case _MedicalScreeningModel():
return $default(_that.diabetes,_that.hypertension,_that.heartDiseases,_that.prostate,_that.jointDiseases,_that.obesity,_that.previousSurgeries,_that.smokingOrAlcohol,_that.allergicDiseases,_that.kidneyDiseases,_that.previousAccidents);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool diabetes,  bool hypertension,  bool heartDiseases,  bool prostate,  bool jointDiseases,  bool obesity,  bool previousSurgeries,  bool smokingOrAlcohol,  bool allergicDiseases,  bool kidneyDiseases,  bool previousAccidents)?  $default,) {final _that = this;
switch (_that) {
case _MedicalScreeningModel() when $default != null:
return $default(_that.diabetes,_that.hypertension,_that.heartDiseases,_that.prostate,_that.jointDiseases,_that.obesity,_that.previousSurgeries,_that.smokingOrAlcohol,_that.allergicDiseases,_that.kidneyDiseases,_that.previousAccidents);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MedicalScreeningModel extends MedicalScreeningModel {
  const _MedicalScreeningModel({this.diabetes = false, this.hypertension = false, this.heartDiseases = false, this.prostate = false, this.jointDiseases = false, this.obesity = false, this.previousSurgeries = false, this.smokingOrAlcohol = false, this.allergicDiseases = false, this.kidneyDiseases = false, this.previousAccidents = false}): super._();
  factory _MedicalScreeningModel.fromJson(Map<String, dynamic> json) => _$MedicalScreeningModelFromJson(json);

@override@JsonKey() final  bool diabetes;
@override@JsonKey() final  bool hypertension;
@override@JsonKey() final  bool heartDiseases;
@override@JsonKey() final  bool prostate;
@override@JsonKey() final  bool jointDiseases;
@override@JsonKey() final  bool obesity;
@override@JsonKey() final  bool previousSurgeries;
@override@JsonKey() final  bool smokingOrAlcohol;
@override@JsonKey() final  bool allergicDiseases;
@override@JsonKey() final  bool kidneyDiseases;
@override@JsonKey() final  bool previousAccidents;

/// Create a copy of MedicalScreeningModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicalScreeningModelCopyWith<_MedicalScreeningModel> get copyWith => __$MedicalScreeningModelCopyWithImpl<_MedicalScreeningModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MedicalScreeningModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicalScreeningModel&&(identical(other.diabetes, diabetes) || other.diabetes == diabetes)&&(identical(other.hypertension, hypertension) || other.hypertension == hypertension)&&(identical(other.heartDiseases, heartDiseases) || other.heartDiseases == heartDiseases)&&(identical(other.prostate, prostate) || other.prostate == prostate)&&(identical(other.jointDiseases, jointDiseases) || other.jointDiseases == jointDiseases)&&(identical(other.obesity, obesity) || other.obesity == obesity)&&(identical(other.previousSurgeries, previousSurgeries) || other.previousSurgeries == previousSurgeries)&&(identical(other.smokingOrAlcohol, smokingOrAlcohol) || other.smokingOrAlcohol == smokingOrAlcohol)&&(identical(other.allergicDiseases, allergicDiseases) || other.allergicDiseases == allergicDiseases)&&(identical(other.kidneyDiseases, kidneyDiseases) || other.kidneyDiseases == kidneyDiseases)&&(identical(other.previousAccidents, previousAccidents) || other.previousAccidents == previousAccidents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,diabetes,hypertension,heartDiseases,prostate,jointDiseases,obesity,previousSurgeries,smokingOrAlcohol,allergicDiseases,kidneyDiseases,previousAccidents);

@override
String toString() {
  return 'MedicalScreeningModel(diabetes: $diabetes, hypertension: $hypertension, heartDiseases: $heartDiseases, prostate: $prostate, jointDiseases: $jointDiseases, obesity: $obesity, previousSurgeries: $previousSurgeries, smokingOrAlcohol: $smokingOrAlcohol, allergicDiseases: $allergicDiseases, kidneyDiseases: $kidneyDiseases, previousAccidents: $previousAccidents)';
}


}

/// @nodoc
abstract mixin class _$MedicalScreeningModelCopyWith<$Res> implements $MedicalScreeningModelCopyWith<$Res> {
  factory _$MedicalScreeningModelCopyWith(_MedicalScreeningModel value, $Res Function(_MedicalScreeningModel) _then) = __$MedicalScreeningModelCopyWithImpl;
@override @useResult
$Res call({
 bool diabetes, bool hypertension, bool heartDiseases, bool prostate, bool jointDiseases, bool obesity, bool previousSurgeries, bool smokingOrAlcohol, bool allergicDiseases, bool kidneyDiseases, bool previousAccidents
});




}
/// @nodoc
class __$MedicalScreeningModelCopyWithImpl<$Res>
    implements _$MedicalScreeningModelCopyWith<$Res> {
  __$MedicalScreeningModelCopyWithImpl(this._self, this._then);

  final _MedicalScreeningModel _self;
  final $Res Function(_MedicalScreeningModel) _then;

/// Create a copy of MedicalScreeningModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? diabetes = null,Object? hypertension = null,Object? heartDiseases = null,Object? prostate = null,Object? jointDiseases = null,Object? obesity = null,Object? previousSurgeries = null,Object? smokingOrAlcohol = null,Object? allergicDiseases = null,Object? kidneyDiseases = null,Object? previousAccidents = null,}) {
  return _then(_MedicalScreeningModel(
diabetes: null == diabetes ? _self.diabetes : diabetes // ignore: cast_nullable_to_non_nullable
as bool,hypertension: null == hypertension ? _self.hypertension : hypertension // ignore: cast_nullable_to_non_nullable
as bool,heartDiseases: null == heartDiseases ? _self.heartDiseases : heartDiseases // ignore: cast_nullable_to_non_nullable
as bool,prostate: null == prostate ? _self.prostate : prostate // ignore: cast_nullable_to_non_nullable
as bool,jointDiseases: null == jointDiseases ? _self.jointDiseases : jointDiseases // ignore: cast_nullable_to_non_nullable
as bool,obesity: null == obesity ? _self.obesity : obesity // ignore: cast_nullable_to_non_nullable
as bool,previousSurgeries: null == previousSurgeries ? _self.previousSurgeries : previousSurgeries // ignore: cast_nullable_to_non_nullable
as bool,smokingOrAlcohol: null == smokingOrAlcohol ? _self.smokingOrAlcohol : smokingOrAlcohol // ignore: cast_nullable_to_non_nullable
as bool,allergicDiseases: null == allergicDiseases ? _self.allergicDiseases : allergicDiseases // ignore: cast_nullable_to_non_nullable
as bool,kidneyDiseases: null == kidneyDiseases ? _self.kidneyDiseases : kidneyDiseases // ignore: cast_nullable_to_non_nullable
as bool,previousAccidents: null == previousAccidents ? _self.previousAccidents : previousAccidents // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
