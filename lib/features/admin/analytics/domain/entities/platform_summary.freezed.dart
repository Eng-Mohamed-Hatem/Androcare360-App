// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'platform_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlatformSummary {

/// إجمالي المواعيد المكتملة في الفترة
 int get totalCompletedAppointments;/// إجمالي الإيرادات (SAR)
 double get totalRevenue;/// إجمالي المستحقات المعلقة (SAR)
 double get totalPendingPayouts;/// متوسط نقطة الأداء عبر الأطباء النشطين
 double get averagePerformanceScore;/// عدد الأطباء النشطين (isActive=true, userType=doctor)
 int get activeDoctorsCount;/// الفترة الزمنية لهذا الملخص
 AnalyticsDateRange get period;
/// Create a copy of PlatformSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlatformSummaryCopyWith<PlatformSummary> get copyWith => _$PlatformSummaryCopyWithImpl<PlatformSummary>(this as PlatformSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlatformSummary&&(identical(other.totalCompletedAppointments, totalCompletedAppointments) || other.totalCompletedAppointments == totalCompletedAppointments)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.totalPendingPayouts, totalPendingPayouts) || other.totalPendingPayouts == totalPendingPayouts)&&(identical(other.averagePerformanceScore, averagePerformanceScore) || other.averagePerformanceScore == averagePerformanceScore)&&(identical(other.activeDoctorsCount, activeDoctorsCount) || other.activeDoctorsCount == activeDoctorsCount)&&(identical(other.period, period) || other.period == period));
}


@override
int get hashCode => Object.hash(runtimeType,totalCompletedAppointments,totalRevenue,totalPendingPayouts,averagePerformanceScore,activeDoctorsCount,period);

@override
String toString() {
  return 'PlatformSummary(totalCompletedAppointments: $totalCompletedAppointments, totalRevenue: $totalRevenue, totalPendingPayouts: $totalPendingPayouts, averagePerformanceScore: $averagePerformanceScore, activeDoctorsCount: $activeDoctorsCount, period: $period)';
}


}

/// @nodoc
abstract mixin class $PlatformSummaryCopyWith<$Res>  {
  factory $PlatformSummaryCopyWith(PlatformSummary value, $Res Function(PlatformSummary) _then) = _$PlatformSummaryCopyWithImpl;
@useResult
$Res call({
 int totalCompletedAppointments, double totalRevenue, double totalPendingPayouts, double averagePerformanceScore, int activeDoctorsCount, AnalyticsDateRange period
});


$AnalyticsDateRangeCopyWith<$Res> get period;

}
/// @nodoc
class _$PlatformSummaryCopyWithImpl<$Res>
    implements $PlatformSummaryCopyWith<$Res> {
  _$PlatformSummaryCopyWithImpl(this._self, this._then);

  final PlatformSummary _self;
  final $Res Function(PlatformSummary) _then;

/// Create a copy of PlatformSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalCompletedAppointments = null,Object? totalRevenue = null,Object? totalPendingPayouts = null,Object? averagePerformanceScore = null,Object? activeDoctorsCount = null,Object? period = null,}) {
  return _then(_self.copyWith(
totalCompletedAppointments: null == totalCompletedAppointments ? _self.totalCompletedAppointments : totalCompletedAppointments // ignore: cast_nullable_to_non_nullable
as int,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,totalPendingPayouts: null == totalPendingPayouts ? _self.totalPendingPayouts : totalPendingPayouts // ignore: cast_nullable_to_non_nullable
as double,averagePerformanceScore: null == averagePerformanceScore ? _self.averagePerformanceScore : averagePerformanceScore // ignore: cast_nullable_to_non_nullable
as double,activeDoctorsCount: null == activeDoctorsCount ? _self.activeDoctorsCount : activeDoctorsCount // ignore: cast_nullable_to_non_nullable
as int,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as AnalyticsDateRange,
  ));
}
/// Create a copy of PlatformSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsDateRangeCopyWith<$Res> get period {
  
  return $AnalyticsDateRangeCopyWith<$Res>(_self.period, (value) {
    return _then(_self.copyWith(period: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlatformSummary].
extension PlatformSummaryPatterns on PlatformSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlatformSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlatformSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlatformSummary value)  $default,){
final _that = this;
switch (_that) {
case _PlatformSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlatformSummary value)?  $default,){
final _that = this;
switch (_that) {
case _PlatformSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalCompletedAppointments,  double totalRevenue,  double totalPendingPayouts,  double averagePerformanceScore,  int activeDoctorsCount,  AnalyticsDateRange period)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlatformSummary() when $default != null:
return $default(_that.totalCompletedAppointments,_that.totalRevenue,_that.totalPendingPayouts,_that.averagePerformanceScore,_that.activeDoctorsCount,_that.period);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalCompletedAppointments,  double totalRevenue,  double totalPendingPayouts,  double averagePerformanceScore,  int activeDoctorsCount,  AnalyticsDateRange period)  $default,) {final _that = this;
switch (_that) {
case _PlatformSummary():
return $default(_that.totalCompletedAppointments,_that.totalRevenue,_that.totalPendingPayouts,_that.averagePerformanceScore,_that.activeDoctorsCount,_that.period);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalCompletedAppointments,  double totalRevenue,  double totalPendingPayouts,  double averagePerformanceScore,  int activeDoctorsCount,  AnalyticsDateRange period)?  $default,) {final _that = this;
switch (_that) {
case _PlatformSummary() when $default != null:
return $default(_that.totalCompletedAppointments,_that.totalRevenue,_that.totalPendingPayouts,_that.averagePerformanceScore,_that.activeDoctorsCount,_that.period);case _:
  return null;

}
}

}

/// @nodoc


class _PlatformSummary implements PlatformSummary {
  const _PlatformSummary({required this.totalCompletedAppointments, required this.totalRevenue, required this.totalPendingPayouts, required this.averagePerformanceScore, required this.activeDoctorsCount, required this.period});
  

/// إجمالي المواعيد المكتملة في الفترة
@override final  int totalCompletedAppointments;
/// إجمالي الإيرادات (SAR)
@override final  double totalRevenue;
/// إجمالي المستحقات المعلقة (SAR)
@override final  double totalPendingPayouts;
/// متوسط نقطة الأداء عبر الأطباء النشطين
@override final  double averagePerformanceScore;
/// عدد الأطباء النشطين (isActive=true, userType=doctor)
@override final  int activeDoctorsCount;
/// الفترة الزمنية لهذا الملخص
@override final  AnalyticsDateRange period;

/// Create a copy of PlatformSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlatformSummaryCopyWith<_PlatformSummary> get copyWith => __$PlatformSummaryCopyWithImpl<_PlatformSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlatformSummary&&(identical(other.totalCompletedAppointments, totalCompletedAppointments) || other.totalCompletedAppointments == totalCompletedAppointments)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.totalPendingPayouts, totalPendingPayouts) || other.totalPendingPayouts == totalPendingPayouts)&&(identical(other.averagePerformanceScore, averagePerformanceScore) || other.averagePerformanceScore == averagePerformanceScore)&&(identical(other.activeDoctorsCount, activeDoctorsCount) || other.activeDoctorsCount == activeDoctorsCount)&&(identical(other.period, period) || other.period == period));
}


@override
int get hashCode => Object.hash(runtimeType,totalCompletedAppointments,totalRevenue,totalPendingPayouts,averagePerformanceScore,activeDoctorsCount,period);

@override
String toString() {
  return 'PlatformSummary(totalCompletedAppointments: $totalCompletedAppointments, totalRevenue: $totalRevenue, totalPendingPayouts: $totalPendingPayouts, averagePerformanceScore: $averagePerformanceScore, activeDoctorsCount: $activeDoctorsCount, period: $period)';
}


}

/// @nodoc
abstract mixin class _$PlatformSummaryCopyWith<$Res> implements $PlatformSummaryCopyWith<$Res> {
  factory _$PlatformSummaryCopyWith(_PlatformSummary value, $Res Function(_PlatformSummary) _then) = __$PlatformSummaryCopyWithImpl;
@override @useResult
$Res call({
 int totalCompletedAppointments, double totalRevenue, double totalPendingPayouts, double averagePerformanceScore, int activeDoctorsCount, AnalyticsDateRange period
});


@override $AnalyticsDateRangeCopyWith<$Res> get period;

}
/// @nodoc
class __$PlatformSummaryCopyWithImpl<$Res>
    implements _$PlatformSummaryCopyWith<$Res> {
  __$PlatformSummaryCopyWithImpl(this._self, this._then);

  final _PlatformSummary _self;
  final $Res Function(_PlatformSummary) _then;

/// Create a copy of PlatformSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalCompletedAppointments = null,Object? totalRevenue = null,Object? totalPendingPayouts = null,Object? averagePerformanceScore = null,Object? activeDoctorsCount = null,Object? period = null,}) {
  return _then(_PlatformSummary(
totalCompletedAppointments: null == totalCompletedAppointments ? _self.totalCompletedAppointments : totalCompletedAppointments // ignore: cast_nullable_to_non_nullable
as int,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,totalPendingPayouts: null == totalPendingPayouts ? _self.totalPendingPayouts : totalPendingPayouts // ignore: cast_nullable_to_non_nullable
as double,averagePerformanceScore: null == averagePerformanceScore ? _self.averagePerformanceScore : averagePerformanceScore // ignore: cast_nullable_to_non_nullable
as double,activeDoctorsCount: null == activeDoctorsCount ? _self.activeDoctorsCount : activeDoctorsCount // ignore: cast_nullable_to_non_nullable
as int,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as AnalyticsDateRange,
  ));
}

/// Create a copy of PlatformSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsDateRangeCopyWith<$Res> get period {
  
  return $AnalyticsDateRangeCopyWith<$Res>(_self.period, (value) {
    return _then(_self.copyWith(period: value));
  });
}
}

// dart format on
