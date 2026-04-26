// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'performance_score_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PerformanceScoreModel {

 double get totalScore; double get completionRateScore; double get patientRatingScore; double get punctualityScore; double get emrSpeedScore; bool get hasIncompleteData; List<String> get missingDimensions; bool get isOverviewScore;
/// Create a copy of PerformanceScoreModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PerformanceScoreModelCopyWith<PerformanceScoreModel> get copyWith => _$PerformanceScoreModelCopyWithImpl<PerformanceScoreModel>(this as PerformanceScoreModel, _$identity);

  /// Serializes this PerformanceScoreModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PerformanceScoreModel&&(identical(other.totalScore, totalScore) || other.totalScore == totalScore)&&(identical(other.completionRateScore, completionRateScore) || other.completionRateScore == completionRateScore)&&(identical(other.patientRatingScore, patientRatingScore) || other.patientRatingScore == patientRatingScore)&&(identical(other.punctualityScore, punctualityScore) || other.punctualityScore == punctualityScore)&&(identical(other.emrSpeedScore, emrSpeedScore) || other.emrSpeedScore == emrSpeedScore)&&(identical(other.hasIncompleteData, hasIncompleteData) || other.hasIncompleteData == hasIncompleteData)&&const DeepCollectionEquality().equals(other.missingDimensions, missingDimensions)&&(identical(other.isOverviewScore, isOverviewScore) || other.isOverviewScore == isOverviewScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalScore,completionRateScore,patientRatingScore,punctualityScore,emrSpeedScore,hasIncompleteData,const DeepCollectionEquality().hash(missingDimensions),isOverviewScore);

@override
String toString() {
  return 'PerformanceScoreModel(totalScore: $totalScore, completionRateScore: $completionRateScore, patientRatingScore: $patientRatingScore, punctualityScore: $punctualityScore, emrSpeedScore: $emrSpeedScore, hasIncompleteData: $hasIncompleteData, missingDimensions: $missingDimensions, isOverviewScore: $isOverviewScore)';
}


}

/// @nodoc
abstract mixin class $PerformanceScoreModelCopyWith<$Res>  {
  factory $PerformanceScoreModelCopyWith(PerformanceScoreModel value, $Res Function(PerformanceScoreModel) _then) = _$PerformanceScoreModelCopyWithImpl;
@useResult
$Res call({
 double totalScore, double completionRateScore, double patientRatingScore, double punctualityScore, double emrSpeedScore, bool hasIncompleteData, List<String> missingDimensions, bool isOverviewScore
});




}
/// @nodoc
class _$PerformanceScoreModelCopyWithImpl<$Res>
    implements $PerformanceScoreModelCopyWith<$Res> {
  _$PerformanceScoreModelCopyWithImpl(this._self, this._then);

  final PerformanceScoreModel _self;
  final $Res Function(PerformanceScoreModel) _then;

/// Create a copy of PerformanceScoreModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalScore = null,Object? completionRateScore = null,Object? patientRatingScore = null,Object? punctualityScore = null,Object? emrSpeedScore = null,Object? hasIncompleteData = null,Object? missingDimensions = null,Object? isOverviewScore = null,}) {
  return _then(_self.copyWith(
totalScore: null == totalScore ? _self.totalScore : totalScore // ignore: cast_nullable_to_non_nullable
as double,completionRateScore: null == completionRateScore ? _self.completionRateScore : completionRateScore // ignore: cast_nullable_to_non_nullable
as double,patientRatingScore: null == patientRatingScore ? _self.patientRatingScore : patientRatingScore // ignore: cast_nullable_to_non_nullable
as double,punctualityScore: null == punctualityScore ? _self.punctualityScore : punctualityScore // ignore: cast_nullable_to_non_nullable
as double,emrSpeedScore: null == emrSpeedScore ? _self.emrSpeedScore : emrSpeedScore // ignore: cast_nullable_to_non_nullable
as double,hasIncompleteData: null == hasIncompleteData ? _self.hasIncompleteData : hasIncompleteData // ignore: cast_nullable_to_non_nullable
as bool,missingDimensions: null == missingDimensions ? _self.missingDimensions : missingDimensions // ignore: cast_nullable_to_non_nullable
as List<String>,isOverviewScore: null == isOverviewScore ? _self.isOverviewScore : isOverviewScore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PerformanceScoreModel].
extension PerformanceScoreModelPatterns on PerformanceScoreModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PerformanceScoreModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PerformanceScoreModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PerformanceScoreModel value)  $default,){
final _that = this;
switch (_that) {
case _PerformanceScoreModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PerformanceScoreModel value)?  $default,){
final _that = this;
switch (_that) {
case _PerformanceScoreModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double totalScore,  double completionRateScore,  double patientRatingScore,  double punctualityScore,  double emrSpeedScore,  bool hasIncompleteData,  List<String> missingDimensions,  bool isOverviewScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PerformanceScoreModel() when $default != null:
return $default(_that.totalScore,_that.completionRateScore,_that.patientRatingScore,_that.punctualityScore,_that.emrSpeedScore,_that.hasIncompleteData,_that.missingDimensions,_that.isOverviewScore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double totalScore,  double completionRateScore,  double patientRatingScore,  double punctualityScore,  double emrSpeedScore,  bool hasIncompleteData,  List<String> missingDimensions,  bool isOverviewScore)  $default,) {final _that = this;
switch (_that) {
case _PerformanceScoreModel():
return $default(_that.totalScore,_that.completionRateScore,_that.patientRatingScore,_that.punctualityScore,_that.emrSpeedScore,_that.hasIncompleteData,_that.missingDimensions,_that.isOverviewScore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double totalScore,  double completionRateScore,  double patientRatingScore,  double punctualityScore,  double emrSpeedScore,  bool hasIncompleteData,  List<String> missingDimensions,  bool isOverviewScore)?  $default,) {final _that = this;
switch (_that) {
case _PerformanceScoreModel() when $default != null:
return $default(_that.totalScore,_that.completionRateScore,_that.patientRatingScore,_that.punctualityScore,_that.emrSpeedScore,_that.hasIncompleteData,_that.missingDimensions,_that.isOverviewScore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PerformanceScoreModel extends PerformanceScoreModel {
  const _PerformanceScoreModel({required this.totalScore, required this.completionRateScore, required this.patientRatingScore, required this.punctualityScore, required this.emrSpeedScore, required this.hasIncompleteData, final  List<String> missingDimensions = const [], this.isOverviewScore = false}): _missingDimensions = missingDimensions,super._();
  factory _PerformanceScoreModel.fromJson(Map<String, dynamic> json) => _$PerformanceScoreModelFromJson(json);

@override final  double totalScore;
@override final  double completionRateScore;
@override final  double patientRatingScore;
@override final  double punctualityScore;
@override final  double emrSpeedScore;
@override final  bool hasIncompleteData;
 final  List<String> _missingDimensions;
@override@JsonKey() List<String> get missingDimensions {
  if (_missingDimensions is EqualUnmodifiableListView) return _missingDimensions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_missingDimensions);
}

@override@JsonKey() final  bool isOverviewScore;

/// Create a copy of PerformanceScoreModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PerformanceScoreModelCopyWith<_PerformanceScoreModel> get copyWith => __$PerformanceScoreModelCopyWithImpl<_PerformanceScoreModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PerformanceScoreModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PerformanceScoreModel&&(identical(other.totalScore, totalScore) || other.totalScore == totalScore)&&(identical(other.completionRateScore, completionRateScore) || other.completionRateScore == completionRateScore)&&(identical(other.patientRatingScore, patientRatingScore) || other.patientRatingScore == patientRatingScore)&&(identical(other.punctualityScore, punctualityScore) || other.punctualityScore == punctualityScore)&&(identical(other.emrSpeedScore, emrSpeedScore) || other.emrSpeedScore == emrSpeedScore)&&(identical(other.hasIncompleteData, hasIncompleteData) || other.hasIncompleteData == hasIncompleteData)&&const DeepCollectionEquality().equals(other._missingDimensions, _missingDimensions)&&(identical(other.isOverviewScore, isOverviewScore) || other.isOverviewScore == isOverviewScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalScore,completionRateScore,patientRatingScore,punctualityScore,emrSpeedScore,hasIncompleteData,const DeepCollectionEquality().hash(_missingDimensions),isOverviewScore);

@override
String toString() {
  return 'PerformanceScoreModel(totalScore: $totalScore, completionRateScore: $completionRateScore, patientRatingScore: $patientRatingScore, punctualityScore: $punctualityScore, emrSpeedScore: $emrSpeedScore, hasIncompleteData: $hasIncompleteData, missingDimensions: $missingDimensions, isOverviewScore: $isOverviewScore)';
}


}

/// @nodoc
abstract mixin class _$PerformanceScoreModelCopyWith<$Res> implements $PerformanceScoreModelCopyWith<$Res> {
  factory _$PerformanceScoreModelCopyWith(_PerformanceScoreModel value, $Res Function(_PerformanceScoreModel) _then) = __$PerformanceScoreModelCopyWithImpl;
@override @useResult
$Res call({
 double totalScore, double completionRateScore, double patientRatingScore, double punctualityScore, double emrSpeedScore, bool hasIncompleteData, List<String> missingDimensions, bool isOverviewScore
});




}
/// @nodoc
class __$PerformanceScoreModelCopyWithImpl<$Res>
    implements _$PerformanceScoreModelCopyWith<$Res> {
  __$PerformanceScoreModelCopyWithImpl(this._self, this._then);

  final _PerformanceScoreModel _self;
  final $Res Function(_PerformanceScoreModel) _then;

/// Create a copy of PerformanceScoreModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalScore = null,Object? completionRateScore = null,Object? patientRatingScore = null,Object? punctualityScore = null,Object? emrSpeedScore = null,Object? hasIncompleteData = null,Object? missingDimensions = null,Object? isOverviewScore = null,}) {
  return _then(_PerformanceScoreModel(
totalScore: null == totalScore ? _self.totalScore : totalScore // ignore: cast_nullable_to_non_nullable
as double,completionRateScore: null == completionRateScore ? _self.completionRateScore : completionRateScore // ignore: cast_nullable_to_non_nullable
as double,patientRatingScore: null == patientRatingScore ? _self.patientRatingScore : patientRatingScore // ignore: cast_nullable_to_non_nullable
as double,punctualityScore: null == punctualityScore ? _self.punctualityScore : punctualityScore // ignore: cast_nullable_to_non_nullable
as double,emrSpeedScore: null == emrSpeedScore ? _self.emrSpeedScore : emrSpeedScore // ignore: cast_nullable_to_non_nullable
as double,hasIncompleteData: null == hasIncompleteData ? _self.hasIncompleteData : hasIncompleteData // ignore: cast_nullable_to_non_nullable
as bool,missingDimensions: null == missingDimensions ? _self._missingDimensions : missingDimensions // ignore: cast_nullable_to_non_nullable
as List<String>,isOverviewScore: null == isOverviewScore ? _self.isOverviewScore : isOverviewScore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
