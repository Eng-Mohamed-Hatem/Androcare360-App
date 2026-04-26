// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'doctor_analytics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DoctorAnalytics {

// ── required fields ────────────────────────────────────────────────────
 String get doctorId; String get doctorName; String get specialty; bool get isActive; int get totalAppointments; int get completedAppointments; int get cancelledAppointments; int get noShowAppointments; double get completionRate; FinancialSummary get financialSummary; PerformanceScore get performanceScore; double get pendingPayout; AnalyticsDateRange get period;// ── optional / defaulted fields ────────────────────────────────────────
 String? get profileImage; double? get averageResponseTime; double? get patientRetentionRate; DateTime? get lastLoginAt; PayoutStatus get payoutStatus;
/// Create a copy of DoctorAnalytics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoctorAnalyticsCopyWith<DoctorAnalytics> get copyWith => _$DoctorAnalyticsCopyWithImpl<DoctorAnalytics>(this as DoctorAnalytics, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoctorAnalytics&&(identical(other.doctorId, doctorId) || other.doctorId == doctorId)&&(identical(other.doctorName, doctorName) || other.doctorName == doctorName)&&(identical(other.specialty, specialty) || other.specialty == specialty)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.totalAppointments, totalAppointments) || other.totalAppointments == totalAppointments)&&(identical(other.completedAppointments, completedAppointments) || other.completedAppointments == completedAppointments)&&(identical(other.cancelledAppointments, cancelledAppointments) || other.cancelledAppointments == cancelledAppointments)&&(identical(other.noShowAppointments, noShowAppointments) || other.noShowAppointments == noShowAppointments)&&(identical(other.completionRate, completionRate) || other.completionRate == completionRate)&&(identical(other.financialSummary, financialSummary) || other.financialSummary == financialSummary)&&(identical(other.performanceScore, performanceScore) || other.performanceScore == performanceScore)&&(identical(other.pendingPayout, pendingPayout) || other.pendingPayout == pendingPayout)&&(identical(other.period, period) || other.period == period)&&(identical(other.profileImage, profileImage) || other.profileImage == profileImage)&&(identical(other.averageResponseTime, averageResponseTime) || other.averageResponseTime == averageResponseTime)&&(identical(other.patientRetentionRate, patientRetentionRate) || other.patientRetentionRate == patientRetentionRate)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt)&&(identical(other.payoutStatus, payoutStatus) || other.payoutStatus == payoutStatus));
}


@override
int get hashCode => Object.hash(runtimeType,doctorId,doctorName,specialty,isActive,totalAppointments,completedAppointments,cancelledAppointments,noShowAppointments,completionRate,financialSummary,performanceScore,pendingPayout,period,profileImage,averageResponseTime,patientRetentionRate,lastLoginAt,payoutStatus);

@override
String toString() {
  return 'DoctorAnalytics(doctorId: $doctorId, doctorName: $doctorName, specialty: $specialty, isActive: $isActive, totalAppointments: $totalAppointments, completedAppointments: $completedAppointments, cancelledAppointments: $cancelledAppointments, noShowAppointments: $noShowAppointments, completionRate: $completionRate, financialSummary: $financialSummary, performanceScore: $performanceScore, pendingPayout: $pendingPayout, period: $period, profileImage: $profileImage, averageResponseTime: $averageResponseTime, patientRetentionRate: $patientRetentionRate, lastLoginAt: $lastLoginAt, payoutStatus: $payoutStatus)';
}


}

/// @nodoc
abstract mixin class $DoctorAnalyticsCopyWith<$Res>  {
  factory $DoctorAnalyticsCopyWith(DoctorAnalytics value, $Res Function(DoctorAnalytics) _then) = _$DoctorAnalyticsCopyWithImpl;
@useResult
$Res call({
 String doctorId, String doctorName, String specialty, bool isActive, int totalAppointments, int completedAppointments, int cancelledAppointments, int noShowAppointments, double completionRate, FinancialSummary financialSummary, PerformanceScore performanceScore, double pendingPayout, AnalyticsDateRange period, String? profileImage, double? averageResponseTime, double? patientRetentionRate, DateTime? lastLoginAt, PayoutStatus payoutStatus
});


$FinancialSummaryCopyWith<$Res> get financialSummary;$PerformanceScoreCopyWith<$Res> get performanceScore;$AnalyticsDateRangeCopyWith<$Res> get period;

}
/// @nodoc
class _$DoctorAnalyticsCopyWithImpl<$Res>
    implements $DoctorAnalyticsCopyWith<$Res> {
  _$DoctorAnalyticsCopyWithImpl(this._self, this._then);

  final DoctorAnalytics _self;
  final $Res Function(DoctorAnalytics) _then;

/// Create a copy of DoctorAnalytics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? doctorId = null,Object? doctorName = null,Object? specialty = null,Object? isActive = null,Object? totalAppointments = null,Object? completedAppointments = null,Object? cancelledAppointments = null,Object? noShowAppointments = null,Object? completionRate = null,Object? financialSummary = null,Object? performanceScore = null,Object? pendingPayout = null,Object? period = null,Object? profileImage = freezed,Object? averageResponseTime = freezed,Object? patientRetentionRate = freezed,Object? lastLoginAt = freezed,Object? payoutStatus = null,}) {
  return _then(_self.copyWith(
doctorId: null == doctorId ? _self.doctorId : doctorId // ignore: cast_nullable_to_non_nullable
as String,doctorName: null == doctorName ? _self.doctorName : doctorName // ignore: cast_nullable_to_non_nullable
as String,specialty: null == specialty ? _self.specialty : specialty // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,totalAppointments: null == totalAppointments ? _self.totalAppointments : totalAppointments // ignore: cast_nullable_to_non_nullable
as int,completedAppointments: null == completedAppointments ? _self.completedAppointments : completedAppointments // ignore: cast_nullable_to_non_nullable
as int,cancelledAppointments: null == cancelledAppointments ? _self.cancelledAppointments : cancelledAppointments // ignore: cast_nullable_to_non_nullable
as int,noShowAppointments: null == noShowAppointments ? _self.noShowAppointments : noShowAppointments // ignore: cast_nullable_to_non_nullable
as int,completionRate: null == completionRate ? _self.completionRate : completionRate // ignore: cast_nullable_to_non_nullable
as double,financialSummary: null == financialSummary ? _self.financialSummary : financialSummary // ignore: cast_nullable_to_non_nullable
as FinancialSummary,performanceScore: null == performanceScore ? _self.performanceScore : performanceScore // ignore: cast_nullable_to_non_nullable
as PerformanceScore,pendingPayout: null == pendingPayout ? _self.pendingPayout : pendingPayout // ignore: cast_nullable_to_non_nullable
as double,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as AnalyticsDateRange,profileImage: freezed == profileImage ? _self.profileImage : profileImage // ignore: cast_nullable_to_non_nullable
as String?,averageResponseTime: freezed == averageResponseTime ? _self.averageResponseTime : averageResponseTime // ignore: cast_nullable_to_non_nullable
as double?,patientRetentionRate: freezed == patientRetentionRate ? _self.patientRetentionRate : patientRetentionRate // ignore: cast_nullable_to_non_nullable
as double?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,payoutStatus: null == payoutStatus ? _self.payoutStatus : payoutStatus // ignore: cast_nullable_to_non_nullable
as PayoutStatus,
  ));
}
/// Create a copy of DoctorAnalytics
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FinancialSummaryCopyWith<$Res> get financialSummary {
  
  return $FinancialSummaryCopyWith<$Res>(_self.financialSummary, (value) {
    return _then(_self.copyWith(financialSummary: value));
  });
}/// Create a copy of DoctorAnalytics
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PerformanceScoreCopyWith<$Res> get performanceScore {
  
  return $PerformanceScoreCopyWith<$Res>(_self.performanceScore, (value) {
    return _then(_self.copyWith(performanceScore: value));
  });
}/// Create a copy of DoctorAnalytics
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsDateRangeCopyWith<$Res> get period {
  
  return $AnalyticsDateRangeCopyWith<$Res>(_self.period, (value) {
    return _then(_self.copyWith(period: value));
  });
}
}


/// Adds pattern-matching-related methods to [DoctorAnalytics].
extension DoctorAnalyticsPatterns on DoctorAnalytics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DoctorAnalytics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DoctorAnalytics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DoctorAnalytics value)  $default,){
final _that = this;
switch (_that) {
case _DoctorAnalytics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DoctorAnalytics value)?  $default,){
final _that = this;
switch (_that) {
case _DoctorAnalytics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String doctorId,  String doctorName,  String specialty,  bool isActive,  int totalAppointments,  int completedAppointments,  int cancelledAppointments,  int noShowAppointments,  double completionRate,  FinancialSummary financialSummary,  PerformanceScore performanceScore,  double pendingPayout,  AnalyticsDateRange period,  String? profileImage,  double? averageResponseTime,  double? patientRetentionRate,  DateTime? lastLoginAt,  PayoutStatus payoutStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DoctorAnalytics() when $default != null:
return $default(_that.doctorId,_that.doctorName,_that.specialty,_that.isActive,_that.totalAppointments,_that.completedAppointments,_that.cancelledAppointments,_that.noShowAppointments,_that.completionRate,_that.financialSummary,_that.performanceScore,_that.pendingPayout,_that.period,_that.profileImage,_that.averageResponseTime,_that.patientRetentionRate,_that.lastLoginAt,_that.payoutStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String doctorId,  String doctorName,  String specialty,  bool isActive,  int totalAppointments,  int completedAppointments,  int cancelledAppointments,  int noShowAppointments,  double completionRate,  FinancialSummary financialSummary,  PerformanceScore performanceScore,  double pendingPayout,  AnalyticsDateRange period,  String? profileImage,  double? averageResponseTime,  double? patientRetentionRate,  DateTime? lastLoginAt,  PayoutStatus payoutStatus)  $default,) {final _that = this;
switch (_that) {
case _DoctorAnalytics():
return $default(_that.doctorId,_that.doctorName,_that.specialty,_that.isActive,_that.totalAppointments,_that.completedAppointments,_that.cancelledAppointments,_that.noShowAppointments,_that.completionRate,_that.financialSummary,_that.performanceScore,_that.pendingPayout,_that.period,_that.profileImage,_that.averageResponseTime,_that.patientRetentionRate,_that.lastLoginAt,_that.payoutStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String doctorId,  String doctorName,  String specialty,  bool isActive,  int totalAppointments,  int completedAppointments,  int cancelledAppointments,  int noShowAppointments,  double completionRate,  FinancialSummary financialSummary,  PerformanceScore performanceScore,  double pendingPayout,  AnalyticsDateRange period,  String? profileImage,  double? averageResponseTime,  double? patientRetentionRate,  DateTime? lastLoginAt,  PayoutStatus payoutStatus)?  $default,) {final _that = this;
switch (_that) {
case _DoctorAnalytics() when $default != null:
return $default(_that.doctorId,_that.doctorName,_that.specialty,_that.isActive,_that.totalAppointments,_that.completedAppointments,_that.cancelledAppointments,_that.noShowAppointments,_that.completionRate,_that.financialSummary,_that.performanceScore,_that.pendingPayout,_that.period,_that.profileImage,_that.averageResponseTime,_that.patientRetentionRate,_that.lastLoginAt,_that.payoutStatus);case _:
  return null;

}
}

}

/// @nodoc


class _DoctorAnalytics implements DoctorAnalytics {
  const _DoctorAnalytics({required this.doctorId, required this.doctorName, required this.specialty, required this.isActive, required this.totalAppointments, required this.completedAppointments, required this.cancelledAppointments, required this.noShowAppointments, required this.completionRate, required this.financialSummary, required this.performanceScore, required this.pendingPayout, required this.period, this.profileImage, this.averageResponseTime, this.patientRetentionRate, this.lastLoginAt, this.payoutStatus = PayoutStatus.pending});
  

// ── required fields ────────────────────────────────────────────────────
@override final  String doctorId;
@override final  String doctorName;
@override final  String specialty;
@override final  bool isActive;
@override final  int totalAppointments;
@override final  int completedAppointments;
@override final  int cancelledAppointments;
@override final  int noShowAppointments;
@override final  double completionRate;
@override final  FinancialSummary financialSummary;
@override final  PerformanceScore performanceScore;
@override final  double pendingPayout;
@override final  AnalyticsDateRange period;
// ── optional / defaulted fields ────────────────────────────────────────
@override final  String? profileImage;
@override final  double? averageResponseTime;
@override final  double? patientRetentionRate;
@override final  DateTime? lastLoginAt;
@override@JsonKey() final  PayoutStatus payoutStatus;

/// Create a copy of DoctorAnalytics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoctorAnalyticsCopyWith<_DoctorAnalytics> get copyWith => __$DoctorAnalyticsCopyWithImpl<_DoctorAnalytics>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DoctorAnalytics&&(identical(other.doctorId, doctorId) || other.doctorId == doctorId)&&(identical(other.doctorName, doctorName) || other.doctorName == doctorName)&&(identical(other.specialty, specialty) || other.specialty == specialty)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.totalAppointments, totalAppointments) || other.totalAppointments == totalAppointments)&&(identical(other.completedAppointments, completedAppointments) || other.completedAppointments == completedAppointments)&&(identical(other.cancelledAppointments, cancelledAppointments) || other.cancelledAppointments == cancelledAppointments)&&(identical(other.noShowAppointments, noShowAppointments) || other.noShowAppointments == noShowAppointments)&&(identical(other.completionRate, completionRate) || other.completionRate == completionRate)&&(identical(other.financialSummary, financialSummary) || other.financialSummary == financialSummary)&&(identical(other.performanceScore, performanceScore) || other.performanceScore == performanceScore)&&(identical(other.pendingPayout, pendingPayout) || other.pendingPayout == pendingPayout)&&(identical(other.period, period) || other.period == period)&&(identical(other.profileImage, profileImage) || other.profileImage == profileImage)&&(identical(other.averageResponseTime, averageResponseTime) || other.averageResponseTime == averageResponseTime)&&(identical(other.patientRetentionRate, patientRetentionRate) || other.patientRetentionRate == patientRetentionRate)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt)&&(identical(other.payoutStatus, payoutStatus) || other.payoutStatus == payoutStatus));
}


@override
int get hashCode => Object.hash(runtimeType,doctorId,doctorName,specialty,isActive,totalAppointments,completedAppointments,cancelledAppointments,noShowAppointments,completionRate,financialSummary,performanceScore,pendingPayout,period,profileImage,averageResponseTime,patientRetentionRate,lastLoginAt,payoutStatus);

@override
String toString() {
  return 'DoctorAnalytics(doctorId: $doctorId, doctorName: $doctorName, specialty: $specialty, isActive: $isActive, totalAppointments: $totalAppointments, completedAppointments: $completedAppointments, cancelledAppointments: $cancelledAppointments, noShowAppointments: $noShowAppointments, completionRate: $completionRate, financialSummary: $financialSummary, performanceScore: $performanceScore, pendingPayout: $pendingPayout, period: $period, profileImage: $profileImage, averageResponseTime: $averageResponseTime, patientRetentionRate: $patientRetentionRate, lastLoginAt: $lastLoginAt, payoutStatus: $payoutStatus)';
}


}

/// @nodoc
abstract mixin class _$DoctorAnalyticsCopyWith<$Res> implements $DoctorAnalyticsCopyWith<$Res> {
  factory _$DoctorAnalyticsCopyWith(_DoctorAnalytics value, $Res Function(_DoctorAnalytics) _then) = __$DoctorAnalyticsCopyWithImpl;
@override @useResult
$Res call({
 String doctorId, String doctorName, String specialty, bool isActive, int totalAppointments, int completedAppointments, int cancelledAppointments, int noShowAppointments, double completionRate, FinancialSummary financialSummary, PerformanceScore performanceScore, double pendingPayout, AnalyticsDateRange period, String? profileImage, double? averageResponseTime, double? patientRetentionRate, DateTime? lastLoginAt, PayoutStatus payoutStatus
});


@override $FinancialSummaryCopyWith<$Res> get financialSummary;@override $PerformanceScoreCopyWith<$Res> get performanceScore;@override $AnalyticsDateRangeCopyWith<$Res> get period;

}
/// @nodoc
class __$DoctorAnalyticsCopyWithImpl<$Res>
    implements _$DoctorAnalyticsCopyWith<$Res> {
  __$DoctorAnalyticsCopyWithImpl(this._self, this._then);

  final _DoctorAnalytics _self;
  final $Res Function(_DoctorAnalytics) _then;

/// Create a copy of DoctorAnalytics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? doctorId = null,Object? doctorName = null,Object? specialty = null,Object? isActive = null,Object? totalAppointments = null,Object? completedAppointments = null,Object? cancelledAppointments = null,Object? noShowAppointments = null,Object? completionRate = null,Object? financialSummary = null,Object? performanceScore = null,Object? pendingPayout = null,Object? period = null,Object? profileImage = freezed,Object? averageResponseTime = freezed,Object? patientRetentionRate = freezed,Object? lastLoginAt = freezed,Object? payoutStatus = null,}) {
  return _then(_DoctorAnalytics(
doctorId: null == doctorId ? _self.doctorId : doctorId // ignore: cast_nullable_to_non_nullable
as String,doctorName: null == doctorName ? _self.doctorName : doctorName // ignore: cast_nullable_to_non_nullable
as String,specialty: null == specialty ? _self.specialty : specialty // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,totalAppointments: null == totalAppointments ? _self.totalAppointments : totalAppointments // ignore: cast_nullable_to_non_nullable
as int,completedAppointments: null == completedAppointments ? _self.completedAppointments : completedAppointments // ignore: cast_nullable_to_non_nullable
as int,cancelledAppointments: null == cancelledAppointments ? _self.cancelledAppointments : cancelledAppointments // ignore: cast_nullable_to_non_nullable
as int,noShowAppointments: null == noShowAppointments ? _self.noShowAppointments : noShowAppointments // ignore: cast_nullable_to_non_nullable
as int,completionRate: null == completionRate ? _self.completionRate : completionRate // ignore: cast_nullable_to_non_nullable
as double,financialSummary: null == financialSummary ? _self.financialSummary : financialSummary // ignore: cast_nullable_to_non_nullable
as FinancialSummary,performanceScore: null == performanceScore ? _self.performanceScore : performanceScore // ignore: cast_nullable_to_non_nullable
as PerformanceScore,pendingPayout: null == pendingPayout ? _self.pendingPayout : pendingPayout // ignore: cast_nullable_to_non_nullable
as double,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as AnalyticsDateRange,profileImage: freezed == profileImage ? _self.profileImage : profileImage // ignore: cast_nullable_to_non_nullable
as String?,averageResponseTime: freezed == averageResponseTime ? _self.averageResponseTime : averageResponseTime // ignore: cast_nullable_to_non_nullable
as double?,patientRetentionRate: freezed == patientRetentionRate ? _self.patientRetentionRate : patientRetentionRate // ignore: cast_nullable_to_non_nullable
as double?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,payoutStatus: null == payoutStatus ? _self.payoutStatus : payoutStatus // ignore: cast_nullable_to_non_nullable
as PayoutStatus,
  ));
}

/// Create a copy of DoctorAnalytics
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FinancialSummaryCopyWith<$Res> get financialSummary {
  
  return $FinancialSummaryCopyWith<$Res>(_self.financialSummary, (value) {
    return _then(_self.copyWith(financialSummary: value));
  });
}/// Create a copy of DoctorAnalytics
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PerformanceScoreCopyWith<$Res> get performanceScore {
  
  return $PerformanceScoreCopyWith<$Res>(_self.performanceScore, (value) {
    return _then(_self.copyWith(performanceScore: value));
  });
}/// Create a copy of DoctorAnalytics
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
