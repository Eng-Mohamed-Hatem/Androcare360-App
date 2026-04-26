// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'platform_summary_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlatformSummaryModel {

 int get totalCompletedAppointments; double get totalRevenue; double get totalPendingPayouts; double get averagePerformanceScore; int get activeDoctorsCount;
/// Create a copy of PlatformSummaryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlatformSummaryModelCopyWith<PlatformSummaryModel> get copyWith => _$PlatformSummaryModelCopyWithImpl<PlatformSummaryModel>(this as PlatformSummaryModel, _$identity);

  /// Serializes this PlatformSummaryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlatformSummaryModel&&(identical(other.totalCompletedAppointments, totalCompletedAppointments) || other.totalCompletedAppointments == totalCompletedAppointments)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.totalPendingPayouts, totalPendingPayouts) || other.totalPendingPayouts == totalPendingPayouts)&&(identical(other.averagePerformanceScore, averagePerformanceScore) || other.averagePerformanceScore == averagePerformanceScore)&&(identical(other.activeDoctorsCount, activeDoctorsCount) || other.activeDoctorsCount == activeDoctorsCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalCompletedAppointments,totalRevenue,totalPendingPayouts,averagePerformanceScore,activeDoctorsCount);

@override
String toString() {
  return 'PlatformSummaryModel(totalCompletedAppointments: $totalCompletedAppointments, totalRevenue: $totalRevenue, totalPendingPayouts: $totalPendingPayouts, averagePerformanceScore: $averagePerformanceScore, activeDoctorsCount: $activeDoctorsCount)';
}


}

/// @nodoc
abstract mixin class $PlatformSummaryModelCopyWith<$Res>  {
  factory $PlatformSummaryModelCopyWith(PlatformSummaryModel value, $Res Function(PlatformSummaryModel) _then) = _$PlatformSummaryModelCopyWithImpl;
@useResult
$Res call({
 int totalCompletedAppointments, double totalRevenue, double totalPendingPayouts, double averagePerformanceScore, int activeDoctorsCount
});




}
/// @nodoc
class _$PlatformSummaryModelCopyWithImpl<$Res>
    implements $PlatformSummaryModelCopyWith<$Res> {
  _$PlatformSummaryModelCopyWithImpl(this._self, this._then);

  final PlatformSummaryModel _self;
  final $Res Function(PlatformSummaryModel) _then;

/// Create a copy of PlatformSummaryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalCompletedAppointments = null,Object? totalRevenue = null,Object? totalPendingPayouts = null,Object? averagePerformanceScore = null,Object? activeDoctorsCount = null,}) {
  return _then(_self.copyWith(
totalCompletedAppointments: null == totalCompletedAppointments ? _self.totalCompletedAppointments : totalCompletedAppointments // ignore: cast_nullable_to_non_nullable
as int,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,totalPendingPayouts: null == totalPendingPayouts ? _self.totalPendingPayouts : totalPendingPayouts // ignore: cast_nullable_to_non_nullable
as double,averagePerformanceScore: null == averagePerformanceScore ? _self.averagePerformanceScore : averagePerformanceScore // ignore: cast_nullable_to_non_nullable
as double,activeDoctorsCount: null == activeDoctorsCount ? _self.activeDoctorsCount : activeDoctorsCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PlatformSummaryModel].
extension PlatformSummaryModelPatterns on PlatformSummaryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlatformSummaryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlatformSummaryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlatformSummaryModel value)  $default,){
final _that = this;
switch (_that) {
case _PlatformSummaryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlatformSummaryModel value)?  $default,){
final _that = this;
switch (_that) {
case _PlatformSummaryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalCompletedAppointments,  double totalRevenue,  double totalPendingPayouts,  double averagePerformanceScore,  int activeDoctorsCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlatformSummaryModel() when $default != null:
return $default(_that.totalCompletedAppointments,_that.totalRevenue,_that.totalPendingPayouts,_that.averagePerformanceScore,_that.activeDoctorsCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalCompletedAppointments,  double totalRevenue,  double totalPendingPayouts,  double averagePerformanceScore,  int activeDoctorsCount)  $default,) {final _that = this;
switch (_that) {
case _PlatformSummaryModel():
return $default(_that.totalCompletedAppointments,_that.totalRevenue,_that.totalPendingPayouts,_that.averagePerformanceScore,_that.activeDoctorsCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalCompletedAppointments,  double totalRevenue,  double totalPendingPayouts,  double averagePerformanceScore,  int activeDoctorsCount)?  $default,) {final _that = this;
switch (_that) {
case _PlatformSummaryModel() when $default != null:
return $default(_that.totalCompletedAppointments,_that.totalRevenue,_that.totalPendingPayouts,_that.averagePerformanceScore,_that.activeDoctorsCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlatformSummaryModel extends PlatformSummaryModel {
  const _PlatformSummaryModel({required this.totalCompletedAppointments, required this.totalRevenue, required this.totalPendingPayouts, required this.averagePerformanceScore, required this.activeDoctorsCount}): super._();
  factory _PlatformSummaryModel.fromJson(Map<String, dynamic> json) => _$PlatformSummaryModelFromJson(json);

@override final  int totalCompletedAppointments;
@override final  double totalRevenue;
@override final  double totalPendingPayouts;
@override final  double averagePerformanceScore;
@override final  int activeDoctorsCount;

/// Create a copy of PlatformSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlatformSummaryModelCopyWith<_PlatformSummaryModel> get copyWith => __$PlatformSummaryModelCopyWithImpl<_PlatformSummaryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlatformSummaryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlatformSummaryModel&&(identical(other.totalCompletedAppointments, totalCompletedAppointments) || other.totalCompletedAppointments == totalCompletedAppointments)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.totalPendingPayouts, totalPendingPayouts) || other.totalPendingPayouts == totalPendingPayouts)&&(identical(other.averagePerformanceScore, averagePerformanceScore) || other.averagePerformanceScore == averagePerformanceScore)&&(identical(other.activeDoctorsCount, activeDoctorsCount) || other.activeDoctorsCount == activeDoctorsCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalCompletedAppointments,totalRevenue,totalPendingPayouts,averagePerformanceScore,activeDoctorsCount);

@override
String toString() {
  return 'PlatformSummaryModel(totalCompletedAppointments: $totalCompletedAppointments, totalRevenue: $totalRevenue, totalPendingPayouts: $totalPendingPayouts, averagePerformanceScore: $averagePerformanceScore, activeDoctorsCount: $activeDoctorsCount)';
}


}

/// @nodoc
abstract mixin class _$PlatformSummaryModelCopyWith<$Res> implements $PlatformSummaryModelCopyWith<$Res> {
  factory _$PlatformSummaryModelCopyWith(_PlatformSummaryModel value, $Res Function(_PlatformSummaryModel) _then) = __$PlatformSummaryModelCopyWithImpl;
@override @useResult
$Res call({
 int totalCompletedAppointments, double totalRevenue, double totalPendingPayouts, double averagePerformanceScore, int activeDoctorsCount
});




}
/// @nodoc
class __$PlatformSummaryModelCopyWithImpl<$Res>
    implements _$PlatformSummaryModelCopyWith<$Res> {
  __$PlatformSummaryModelCopyWithImpl(this._self, this._then);

  final _PlatformSummaryModel _self;
  final $Res Function(_PlatformSummaryModel) _then;

/// Create a copy of PlatformSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalCompletedAppointments = null,Object? totalRevenue = null,Object? totalPendingPayouts = null,Object? averagePerformanceScore = null,Object? activeDoctorsCount = null,}) {
  return _then(_PlatformSummaryModel(
totalCompletedAppointments: null == totalCompletedAppointments ? _self.totalCompletedAppointments : totalCompletedAppointments // ignore: cast_nullable_to_non_nullable
as int,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,totalPendingPayouts: null == totalPendingPayouts ? _self.totalPendingPayouts : totalPendingPayouts // ignore: cast_nullable_to_non_nullable
as double,averagePerformanceScore: null == averagePerformanceScore ? _self.averagePerformanceScore : averagePerformanceScore // ignore: cast_nullable_to_non_nullable
as double,activeDoctorsCount: null == activeDoctorsCount ? _self.activeDoctorsCount : activeDoctorsCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
