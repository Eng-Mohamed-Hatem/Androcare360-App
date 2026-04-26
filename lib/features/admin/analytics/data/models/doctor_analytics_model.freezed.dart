// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'doctor_analytics_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DoctorAnalyticsModel {

 String get doctorId; String get doctorName; String get specialty; bool get isActive; int get totalAppointments; int get completedAppointments; int get cancelledAppointments; int get noShowAppointments; double get completionRate; FinancialSummaryModel get financialSummary; double get pendingPayout; String get payoutStatus; double get performanceTotalScore; double get completionRateScore; double get patientRatingScore; double get punctualityScore; double get emrSpeedScore; bool get hasIncompleteData; List<String> get missingDimensions; bool get isOverviewScore; String? get profileImage; double? get averageResponseTime; double? get patientRetentionRate; DateTime? get lastLoginAt;
/// Create a copy of DoctorAnalyticsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoctorAnalyticsModelCopyWith<DoctorAnalyticsModel> get copyWith => _$DoctorAnalyticsModelCopyWithImpl<DoctorAnalyticsModel>(this as DoctorAnalyticsModel, _$identity);

  /// Serializes this DoctorAnalyticsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoctorAnalyticsModel&&(identical(other.doctorId, doctorId) || other.doctorId == doctorId)&&(identical(other.doctorName, doctorName) || other.doctorName == doctorName)&&(identical(other.specialty, specialty) || other.specialty == specialty)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.totalAppointments, totalAppointments) || other.totalAppointments == totalAppointments)&&(identical(other.completedAppointments, completedAppointments) || other.completedAppointments == completedAppointments)&&(identical(other.cancelledAppointments, cancelledAppointments) || other.cancelledAppointments == cancelledAppointments)&&(identical(other.noShowAppointments, noShowAppointments) || other.noShowAppointments == noShowAppointments)&&(identical(other.completionRate, completionRate) || other.completionRate == completionRate)&&(identical(other.financialSummary, financialSummary) || other.financialSummary == financialSummary)&&(identical(other.pendingPayout, pendingPayout) || other.pendingPayout == pendingPayout)&&(identical(other.payoutStatus, payoutStatus) || other.payoutStatus == payoutStatus)&&(identical(other.performanceTotalScore, performanceTotalScore) || other.performanceTotalScore == performanceTotalScore)&&(identical(other.completionRateScore, completionRateScore) || other.completionRateScore == completionRateScore)&&(identical(other.patientRatingScore, patientRatingScore) || other.patientRatingScore == patientRatingScore)&&(identical(other.punctualityScore, punctualityScore) || other.punctualityScore == punctualityScore)&&(identical(other.emrSpeedScore, emrSpeedScore) || other.emrSpeedScore == emrSpeedScore)&&(identical(other.hasIncompleteData, hasIncompleteData) || other.hasIncompleteData == hasIncompleteData)&&const DeepCollectionEquality().equals(other.missingDimensions, missingDimensions)&&(identical(other.isOverviewScore, isOverviewScore) || other.isOverviewScore == isOverviewScore)&&(identical(other.profileImage, profileImage) || other.profileImage == profileImage)&&(identical(other.averageResponseTime, averageResponseTime) || other.averageResponseTime == averageResponseTime)&&(identical(other.patientRetentionRate, patientRetentionRate) || other.patientRetentionRate == patientRetentionRate)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,doctorId,doctorName,specialty,isActive,totalAppointments,completedAppointments,cancelledAppointments,noShowAppointments,completionRate,financialSummary,pendingPayout,payoutStatus,performanceTotalScore,completionRateScore,patientRatingScore,punctualityScore,emrSpeedScore,hasIncompleteData,const DeepCollectionEquality().hash(missingDimensions),isOverviewScore,profileImage,averageResponseTime,patientRetentionRate,lastLoginAt]);

@override
String toString() {
  return 'DoctorAnalyticsModel(doctorId: $doctorId, doctorName: $doctorName, specialty: $specialty, isActive: $isActive, totalAppointments: $totalAppointments, completedAppointments: $completedAppointments, cancelledAppointments: $cancelledAppointments, noShowAppointments: $noShowAppointments, completionRate: $completionRate, financialSummary: $financialSummary, pendingPayout: $pendingPayout, payoutStatus: $payoutStatus, performanceTotalScore: $performanceTotalScore, completionRateScore: $completionRateScore, patientRatingScore: $patientRatingScore, punctualityScore: $punctualityScore, emrSpeedScore: $emrSpeedScore, hasIncompleteData: $hasIncompleteData, missingDimensions: $missingDimensions, isOverviewScore: $isOverviewScore, profileImage: $profileImage, averageResponseTime: $averageResponseTime, patientRetentionRate: $patientRetentionRate, lastLoginAt: $lastLoginAt)';
}


}

/// @nodoc
abstract mixin class $DoctorAnalyticsModelCopyWith<$Res>  {
  factory $DoctorAnalyticsModelCopyWith(DoctorAnalyticsModel value, $Res Function(DoctorAnalyticsModel) _then) = _$DoctorAnalyticsModelCopyWithImpl;
@useResult
$Res call({
 String doctorId, String doctorName, String specialty, bool isActive, int totalAppointments, int completedAppointments, int cancelledAppointments, int noShowAppointments, double completionRate, FinancialSummaryModel financialSummary, double pendingPayout, String payoutStatus, double performanceTotalScore, double completionRateScore, double patientRatingScore, double punctualityScore, double emrSpeedScore, bool hasIncompleteData, List<String> missingDimensions, bool isOverviewScore, String? profileImage, double? averageResponseTime, double? patientRetentionRate, DateTime? lastLoginAt
});


$FinancialSummaryModelCopyWith<$Res> get financialSummary;

}
/// @nodoc
class _$DoctorAnalyticsModelCopyWithImpl<$Res>
    implements $DoctorAnalyticsModelCopyWith<$Res> {
  _$DoctorAnalyticsModelCopyWithImpl(this._self, this._then);

  final DoctorAnalyticsModel _self;
  final $Res Function(DoctorAnalyticsModel) _then;

/// Create a copy of DoctorAnalyticsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? doctorId = null,Object? doctorName = null,Object? specialty = null,Object? isActive = null,Object? totalAppointments = null,Object? completedAppointments = null,Object? cancelledAppointments = null,Object? noShowAppointments = null,Object? completionRate = null,Object? financialSummary = null,Object? pendingPayout = null,Object? payoutStatus = null,Object? performanceTotalScore = null,Object? completionRateScore = null,Object? patientRatingScore = null,Object? punctualityScore = null,Object? emrSpeedScore = null,Object? hasIncompleteData = null,Object? missingDimensions = null,Object? isOverviewScore = null,Object? profileImage = freezed,Object? averageResponseTime = freezed,Object? patientRetentionRate = freezed,Object? lastLoginAt = freezed,}) {
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
as FinancialSummaryModel,pendingPayout: null == pendingPayout ? _self.pendingPayout : pendingPayout // ignore: cast_nullable_to_non_nullable
as double,payoutStatus: null == payoutStatus ? _self.payoutStatus : payoutStatus // ignore: cast_nullable_to_non_nullable
as String,performanceTotalScore: null == performanceTotalScore ? _self.performanceTotalScore : performanceTotalScore // ignore: cast_nullable_to_non_nullable
as double,completionRateScore: null == completionRateScore ? _self.completionRateScore : completionRateScore // ignore: cast_nullable_to_non_nullable
as double,patientRatingScore: null == patientRatingScore ? _self.patientRatingScore : patientRatingScore // ignore: cast_nullable_to_non_nullable
as double,punctualityScore: null == punctualityScore ? _self.punctualityScore : punctualityScore // ignore: cast_nullable_to_non_nullable
as double,emrSpeedScore: null == emrSpeedScore ? _self.emrSpeedScore : emrSpeedScore // ignore: cast_nullable_to_non_nullable
as double,hasIncompleteData: null == hasIncompleteData ? _self.hasIncompleteData : hasIncompleteData // ignore: cast_nullable_to_non_nullable
as bool,missingDimensions: null == missingDimensions ? _self.missingDimensions : missingDimensions // ignore: cast_nullable_to_non_nullable
as List<String>,isOverviewScore: null == isOverviewScore ? _self.isOverviewScore : isOverviewScore // ignore: cast_nullable_to_non_nullable
as bool,profileImage: freezed == profileImage ? _self.profileImage : profileImage // ignore: cast_nullable_to_non_nullable
as String?,averageResponseTime: freezed == averageResponseTime ? _self.averageResponseTime : averageResponseTime // ignore: cast_nullable_to_non_nullable
as double?,patientRetentionRate: freezed == patientRetentionRate ? _self.patientRetentionRate : patientRetentionRate // ignore: cast_nullable_to_non_nullable
as double?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of DoctorAnalyticsModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FinancialSummaryModelCopyWith<$Res> get financialSummary {
  
  return $FinancialSummaryModelCopyWith<$Res>(_self.financialSummary, (value) {
    return _then(_self.copyWith(financialSummary: value));
  });
}
}


/// Adds pattern-matching-related methods to [DoctorAnalyticsModel].
extension DoctorAnalyticsModelPatterns on DoctorAnalyticsModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DoctorAnalyticsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DoctorAnalyticsModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DoctorAnalyticsModel value)  $default,){
final _that = this;
switch (_that) {
case _DoctorAnalyticsModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DoctorAnalyticsModel value)?  $default,){
final _that = this;
switch (_that) {
case _DoctorAnalyticsModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String doctorId,  String doctorName,  String specialty,  bool isActive,  int totalAppointments,  int completedAppointments,  int cancelledAppointments,  int noShowAppointments,  double completionRate,  FinancialSummaryModel financialSummary,  double pendingPayout,  String payoutStatus,  double performanceTotalScore,  double completionRateScore,  double patientRatingScore,  double punctualityScore,  double emrSpeedScore,  bool hasIncompleteData,  List<String> missingDimensions,  bool isOverviewScore,  String? profileImage,  double? averageResponseTime,  double? patientRetentionRate,  DateTime? lastLoginAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DoctorAnalyticsModel() when $default != null:
return $default(_that.doctorId,_that.doctorName,_that.specialty,_that.isActive,_that.totalAppointments,_that.completedAppointments,_that.cancelledAppointments,_that.noShowAppointments,_that.completionRate,_that.financialSummary,_that.pendingPayout,_that.payoutStatus,_that.performanceTotalScore,_that.completionRateScore,_that.patientRatingScore,_that.punctualityScore,_that.emrSpeedScore,_that.hasIncompleteData,_that.missingDimensions,_that.isOverviewScore,_that.profileImage,_that.averageResponseTime,_that.patientRetentionRate,_that.lastLoginAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String doctorId,  String doctorName,  String specialty,  bool isActive,  int totalAppointments,  int completedAppointments,  int cancelledAppointments,  int noShowAppointments,  double completionRate,  FinancialSummaryModel financialSummary,  double pendingPayout,  String payoutStatus,  double performanceTotalScore,  double completionRateScore,  double patientRatingScore,  double punctualityScore,  double emrSpeedScore,  bool hasIncompleteData,  List<String> missingDimensions,  bool isOverviewScore,  String? profileImage,  double? averageResponseTime,  double? patientRetentionRate,  DateTime? lastLoginAt)  $default,) {final _that = this;
switch (_that) {
case _DoctorAnalyticsModel():
return $default(_that.doctorId,_that.doctorName,_that.specialty,_that.isActive,_that.totalAppointments,_that.completedAppointments,_that.cancelledAppointments,_that.noShowAppointments,_that.completionRate,_that.financialSummary,_that.pendingPayout,_that.payoutStatus,_that.performanceTotalScore,_that.completionRateScore,_that.patientRatingScore,_that.punctualityScore,_that.emrSpeedScore,_that.hasIncompleteData,_that.missingDimensions,_that.isOverviewScore,_that.profileImage,_that.averageResponseTime,_that.patientRetentionRate,_that.lastLoginAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String doctorId,  String doctorName,  String specialty,  bool isActive,  int totalAppointments,  int completedAppointments,  int cancelledAppointments,  int noShowAppointments,  double completionRate,  FinancialSummaryModel financialSummary,  double pendingPayout,  String payoutStatus,  double performanceTotalScore,  double completionRateScore,  double patientRatingScore,  double punctualityScore,  double emrSpeedScore,  bool hasIncompleteData,  List<String> missingDimensions,  bool isOverviewScore,  String? profileImage,  double? averageResponseTime,  double? patientRetentionRate,  DateTime? lastLoginAt)?  $default,) {final _that = this;
switch (_that) {
case _DoctorAnalyticsModel() when $default != null:
return $default(_that.doctorId,_that.doctorName,_that.specialty,_that.isActive,_that.totalAppointments,_that.completedAppointments,_that.cancelledAppointments,_that.noShowAppointments,_that.completionRate,_that.financialSummary,_that.pendingPayout,_that.payoutStatus,_that.performanceTotalScore,_that.completionRateScore,_that.patientRatingScore,_that.punctualityScore,_that.emrSpeedScore,_that.hasIncompleteData,_that.missingDimensions,_that.isOverviewScore,_that.profileImage,_that.averageResponseTime,_that.patientRetentionRate,_that.lastLoginAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DoctorAnalyticsModel extends DoctorAnalyticsModel {
  const _DoctorAnalyticsModel({required this.doctorId, required this.doctorName, required this.specialty, required this.isActive, required this.totalAppointments, required this.completedAppointments, required this.cancelledAppointments, required this.noShowAppointments, required this.completionRate, required this.financialSummary, required this.pendingPayout, required this.payoutStatus, required this.performanceTotalScore, this.completionRateScore = 0, this.patientRatingScore = 0, this.punctualityScore = 0, this.emrSpeedScore = 0, this.hasIncompleteData = true, final  List<String> missingDimensions = const ['emrSpeed'], this.isOverviewScore = true, this.profileImage, this.averageResponseTime, this.patientRetentionRate, this.lastLoginAt}): _missingDimensions = missingDimensions,super._();
  factory _DoctorAnalyticsModel.fromJson(Map<String, dynamic> json) => _$DoctorAnalyticsModelFromJson(json);

@override final  String doctorId;
@override final  String doctorName;
@override final  String specialty;
@override final  bool isActive;
@override final  int totalAppointments;
@override final  int completedAppointments;
@override final  int cancelledAppointments;
@override final  int noShowAppointments;
@override final  double completionRate;
@override final  FinancialSummaryModel financialSummary;
@override final  double pendingPayout;
@override final  String payoutStatus;
@override final  double performanceTotalScore;
@override@JsonKey() final  double completionRateScore;
@override@JsonKey() final  double patientRatingScore;
@override@JsonKey() final  double punctualityScore;
@override@JsonKey() final  double emrSpeedScore;
@override@JsonKey() final  bool hasIncompleteData;
 final  List<String> _missingDimensions;
@override@JsonKey() List<String> get missingDimensions {
  if (_missingDimensions is EqualUnmodifiableListView) return _missingDimensions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_missingDimensions);
}

@override@JsonKey() final  bool isOverviewScore;
@override final  String? profileImage;
@override final  double? averageResponseTime;
@override final  double? patientRetentionRate;
@override final  DateTime? lastLoginAt;

/// Create a copy of DoctorAnalyticsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoctorAnalyticsModelCopyWith<_DoctorAnalyticsModel> get copyWith => __$DoctorAnalyticsModelCopyWithImpl<_DoctorAnalyticsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DoctorAnalyticsModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DoctorAnalyticsModel&&(identical(other.doctorId, doctorId) || other.doctorId == doctorId)&&(identical(other.doctorName, doctorName) || other.doctorName == doctorName)&&(identical(other.specialty, specialty) || other.specialty == specialty)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.totalAppointments, totalAppointments) || other.totalAppointments == totalAppointments)&&(identical(other.completedAppointments, completedAppointments) || other.completedAppointments == completedAppointments)&&(identical(other.cancelledAppointments, cancelledAppointments) || other.cancelledAppointments == cancelledAppointments)&&(identical(other.noShowAppointments, noShowAppointments) || other.noShowAppointments == noShowAppointments)&&(identical(other.completionRate, completionRate) || other.completionRate == completionRate)&&(identical(other.financialSummary, financialSummary) || other.financialSummary == financialSummary)&&(identical(other.pendingPayout, pendingPayout) || other.pendingPayout == pendingPayout)&&(identical(other.payoutStatus, payoutStatus) || other.payoutStatus == payoutStatus)&&(identical(other.performanceTotalScore, performanceTotalScore) || other.performanceTotalScore == performanceTotalScore)&&(identical(other.completionRateScore, completionRateScore) || other.completionRateScore == completionRateScore)&&(identical(other.patientRatingScore, patientRatingScore) || other.patientRatingScore == patientRatingScore)&&(identical(other.punctualityScore, punctualityScore) || other.punctualityScore == punctualityScore)&&(identical(other.emrSpeedScore, emrSpeedScore) || other.emrSpeedScore == emrSpeedScore)&&(identical(other.hasIncompleteData, hasIncompleteData) || other.hasIncompleteData == hasIncompleteData)&&const DeepCollectionEquality().equals(other._missingDimensions, _missingDimensions)&&(identical(other.isOverviewScore, isOverviewScore) || other.isOverviewScore == isOverviewScore)&&(identical(other.profileImage, profileImage) || other.profileImage == profileImage)&&(identical(other.averageResponseTime, averageResponseTime) || other.averageResponseTime == averageResponseTime)&&(identical(other.patientRetentionRate, patientRetentionRate) || other.patientRetentionRate == patientRetentionRate)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,doctorId,doctorName,specialty,isActive,totalAppointments,completedAppointments,cancelledAppointments,noShowAppointments,completionRate,financialSummary,pendingPayout,payoutStatus,performanceTotalScore,completionRateScore,patientRatingScore,punctualityScore,emrSpeedScore,hasIncompleteData,const DeepCollectionEquality().hash(_missingDimensions),isOverviewScore,profileImage,averageResponseTime,patientRetentionRate,lastLoginAt]);

@override
String toString() {
  return 'DoctorAnalyticsModel(doctorId: $doctorId, doctorName: $doctorName, specialty: $specialty, isActive: $isActive, totalAppointments: $totalAppointments, completedAppointments: $completedAppointments, cancelledAppointments: $cancelledAppointments, noShowAppointments: $noShowAppointments, completionRate: $completionRate, financialSummary: $financialSummary, pendingPayout: $pendingPayout, payoutStatus: $payoutStatus, performanceTotalScore: $performanceTotalScore, completionRateScore: $completionRateScore, patientRatingScore: $patientRatingScore, punctualityScore: $punctualityScore, emrSpeedScore: $emrSpeedScore, hasIncompleteData: $hasIncompleteData, missingDimensions: $missingDimensions, isOverviewScore: $isOverviewScore, profileImage: $profileImage, averageResponseTime: $averageResponseTime, patientRetentionRate: $patientRetentionRate, lastLoginAt: $lastLoginAt)';
}


}

/// @nodoc
abstract mixin class _$DoctorAnalyticsModelCopyWith<$Res> implements $DoctorAnalyticsModelCopyWith<$Res> {
  factory _$DoctorAnalyticsModelCopyWith(_DoctorAnalyticsModel value, $Res Function(_DoctorAnalyticsModel) _then) = __$DoctorAnalyticsModelCopyWithImpl;
@override @useResult
$Res call({
 String doctorId, String doctorName, String specialty, bool isActive, int totalAppointments, int completedAppointments, int cancelledAppointments, int noShowAppointments, double completionRate, FinancialSummaryModel financialSummary, double pendingPayout, String payoutStatus, double performanceTotalScore, double completionRateScore, double patientRatingScore, double punctualityScore, double emrSpeedScore, bool hasIncompleteData, List<String> missingDimensions, bool isOverviewScore, String? profileImage, double? averageResponseTime, double? patientRetentionRate, DateTime? lastLoginAt
});


@override $FinancialSummaryModelCopyWith<$Res> get financialSummary;

}
/// @nodoc
class __$DoctorAnalyticsModelCopyWithImpl<$Res>
    implements _$DoctorAnalyticsModelCopyWith<$Res> {
  __$DoctorAnalyticsModelCopyWithImpl(this._self, this._then);

  final _DoctorAnalyticsModel _self;
  final $Res Function(_DoctorAnalyticsModel) _then;

/// Create a copy of DoctorAnalyticsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? doctorId = null,Object? doctorName = null,Object? specialty = null,Object? isActive = null,Object? totalAppointments = null,Object? completedAppointments = null,Object? cancelledAppointments = null,Object? noShowAppointments = null,Object? completionRate = null,Object? financialSummary = null,Object? pendingPayout = null,Object? payoutStatus = null,Object? performanceTotalScore = null,Object? completionRateScore = null,Object? patientRatingScore = null,Object? punctualityScore = null,Object? emrSpeedScore = null,Object? hasIncompleteData = null,Object? missingDimensions = null,Object? isOverviewScore = null,Object? profileImage = freezed,Object? averageResponseTime = freezed,Object? patientRetentionRate = freezed,Object? lastLoginAt = freezed,}) {
  return _then(_DoctorAnalyticsModel(
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
as FinancialSummaryModel,pendingPayout: null == pendingPayout ? _self.pendingPayout : pendingPayout // ignore: cast_nullable_to_non_nullable
as double,payoutStatus: null == payoutStatus ? _self.payoutStatus : payoutStatus // ignore: cast_nullable_to_non_nullable
as String,performanceTotalScore: null == performanceTotalScore ? _self.performanceTotalScore : performanceTotalScore // ignore: cast_nullable_to_non_nullable
as double,completionRateScore: null == completionRateScore ? _self.completionRateScore : completionRateScore // ignore: cast_nullable_to_non_nullable
as double,patientRatingScore: null == patientRatingScore ? _self.patientRatingScore : patientRatingScore // ignore: cast_nullable_to_non_nullable
as double,punctualityScore: null == punctualityScore ? _self.punctualityScore : punctualityScore // ignore: cast_nullable_to_non_nullable
as double,emrSpeedScore: null == emrSpeedScore ? _self.emrSpeedScore : emrSpeedScore // ignore: cast_nullable_to_non_nullable
as double,hasIncompleteData: null == hasIncompleteData ? _self.hasIncompleteData : hasIncompleteData // ignore: cast_nullable_to_non_nullable
as bool,missingDimensions: null == missingDimensions ? _self._missingDimensions : missingDimensions // ignore: cast_nullable_to_non_nullable
as List<String>,isOverviewScore: null == isOverviewScore ? _self.isOverviewScore : isOverviewScore // ignore: cast_nullable_to_non_nullable
as bool,profileImage: freezed == profileImage ? _self.profileImage : profileImage // ignore: cast_nullable_to_non_nullable
as String?,averageResponseTime: freezed == averageResponseTime ? _self.averageResponseTime : averageResponseTime // ignore: cast_nullable_to_non_nullable
as double?,patientRetentionRate: freezed == patientRetentionRate ? _self.patientRetentionRate : patientRetentionRate // ignore: cast_nullable_to_non_nullable
as double?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of DoctorAnalyticsModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FinancialSummaryModelCopyWith<$Res> get financialSummary {
  
  return $FinancialSummaryModelCopyWith<$Res>(_self.financialSummary, (value) {
    return _then(_self.copyWith(financialSummary: value));
  });
}
}

// dart format on
