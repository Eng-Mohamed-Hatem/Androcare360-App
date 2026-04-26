// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payout_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PayoutEntry {

 String get appointmentId; String get patientName; DateTime get appointmentDate; String get status; double get fee; double get commission; double get netAmount;
/// Create a copy of PayoutEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayoutEntryCopyWith<PayoutEntry> get copyWith => _$PayoutEntryCopyWithImpl<PayoutEntry>(this as PayoutEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayoutEntry&&(identical(other.appointmentId, appointmentId) || other.appointmentId == appointmentId)&&(identical(other.patientName, patientName) || other.patientName == patientName)&&(identical(other.appointmentDate, appointmentDate) || other.appointmentDate == appointmentDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.fee, fee) || other.fee == fee)&&(identical(other.commission, commission) || other.commission == commission)&&(identical(other.netAmount, netAmount) || other.netAmount == netAmount));
}


@override
int get hashCode => Object.hash(runtimeType,appointmentId,patientName,appointmentDate,status,fee,commission,netAmount);

@override
String toString() {
  return 'PayoutEntry(appointmentId: $appointmentId, patientName: $patientName, appointmentDate: $appointmentDate, status: $status, fee: $fee, commission: $commission, netAmount: $netAmount)';
}


}

/// @nodoc
abstract mixin class $PayoutEntryCopyWith<$Res>  {
  factory $PayoutEntryCopyWith(PayoutEntry value, $Res Function(PayoutEntry) _then) = _$PayoutEntryCopyWithImpl;
@useResult
$Res call({
 String appointmentId, String patientName, DateTime appointmentDate, String status, double fee, double commission, double netAmount
});




}
/// @nodoc
class _$PayoutEntryCopyWithImpl<$Res>
    implements $PayoutEntryCopyWith<$Res> {
  _$PayoutEntryCopyWithImpl(this._self, this._then);

  final PayoutEntry _self;
  final $Res Function(PayoutEntry) _then;

/// Create a copy of PayoutEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? appointmentId = null,Object? patientName = null,Object? appointmentDate = null,Object? status = null,Object? fee = null,Object? commission = null,Object? netAmount = null,}) {
  return _then(_self.copyWith(
appointmentId: null == appointmentId ? _self.appointmentId : appointmentId // ignore: cast_nullable_to_non_nullable
as String,patientName: null == patientName ? _self.patientName : patientName // ignore: cast_nullable_to_non_nullable
as String,appointmentDate: null == appointmentDate ? _self.appointmentDate : appointmentDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,fee: null == fee ? _self.fee : fee // ignore: cast_nullable_to_non_nullable
as double,commission: null == commission ? _self.commission : commission // ignore: cast_nullable_to_non_nullable
as double,netAmount: null == netAmount ? _self.netAmount : netAmount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PayoutEntry].
extension PayoutEntryPatterns on PayoutEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayoutEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayoutEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayoutEntry value)  $default,){
final _that = this;
switch (_that) {
case _PayoutEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayoutEntry value)?  $default,){
final _that = this;
switch (_that) {
case _PayoutEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String appointmentId,  String patientName,  DateTime appointmentDate,  String status,  double fee,  double commission,  double netAmount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayoutEntry() when $default != null:
return $default(_that.appointmentId,_that.patientName,_that.appointmentDate,_that.status,_that.fee,_that.commission,_that.netAmount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String appointmentId,  String patientName,  DateTime appointmentDate,  String status,  double fee,  double commission,  double netAmount)  $default,) {final _that = this;
switch (_that) {
case _PayoutEntry():
return $default(_that.appointmentId,_that.patientName,_that.appointmentDate,_that.status,_that.fee,_that.commission,_that.netAmount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String appointmentId,  String patientName,  DateTime appointmentDate,  String status,  double fee,  double commission,  double netAmount)?  $default,) {final _that = this;
switch (_that) {
case _PayoutEntry() when $default != null:
return $default(_that.appointmentId,_that.patientName,_that.appointmentDate,_that.status,_that.fee,_that.commission,_that.netAmount);case _:
  return null;

}
}

}

/// @nodoc


class _PayoutEntry implements PayoutEntry {
  const _PayoutEntry({required this.appointmentId, required this.patientName, required this.appointmentDate, required this.status, required this.fee, required this.commission, required this.netAmount});
  

@override final  String appointmentId;
@override final  String patientName;
@override final  DateTime appointmentDate;
@override final  String status;
@override final  double fee;
@override final  double commission;
@override final  double netAmount;

/// Create a copy of PayoutEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayoutEntryCopyWith<_PayoutEntry> get copyWith => __$PayoutEntryCopyWithImpl<_PayoutEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayoutEntry&&(identical(other.appointmentId, appointmentId) || other.appointmentId == appointmentId)&&(identical(other.patientName, patientName) || other.patientName == patientName)&&(identical(other.appointmentDate, appointmentDate) || other.appointmentDate == appointmentDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.fee, fee) || other.fee == fee)&&(identical(other.commission, commission) || other.commission == commission)&&(identical(other.netAmount, netAmount) || other.netAmount == netAmount));
}


@override
int get hashCode => Object.hash(runtimeType,appointmentId,patientName,appointmentDate,status,fee,commission,netAmount);

@override
String toString() {
  return 'PayoutEntry(appointmentId: $appointmentId, patientName: $patientName, appointmentDate: $appointmentDate, status: $status, fee: $fee, commission: $commission, netAmount: $netAmount)';
}


}

/// @nodoc
abstract mixin class _$PayoutEntryCopyWith<$Res> implements $PayoutEntryCopyWith<$Res> {
  factory _$PayoutEntryCopyWith(_PayoutEntry value, $Res Function(_PayoutEntry) _then) = __$PayoutEntryCopyWithImpl;
@override @useResult
$Res call({
 String appointmentId, String patientName, DateTime appointmentDate, String status, double fee, double commission, double netAmount
});




}
/// @nodoc
class __$PayoutEntryCopyWithImpl<$Res>
    implements _$PayoutEntryCopyWith<$Res> {
  __$PayoutEntryCopyWithImpl(this._self, this._then);

  final _PayoutEntry _self;
  final $Res Function(_PayoutEntry) _then;

/// Create a copy of PayoutEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? appointmentId = null,Object? patientName = null,Object? appointmentDate = null,Object? status = null,Object? fee = null,Object? commission = null,Object? netAmount = null,}) {
  return _then(_PayoutEntry(
appointmentId: null == appointmentId ? _self.appointmentId : appointmentId // ignore: cast_nullable_to_non_nullable
as String,patientName: null == patientName ? _self.patientName : patientName // ignore: cast_nullable_to_non_nullable
as String,appointmentDate: null == appointmentDate ? _self.appointmentDate : appointmentDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,fee: null == fee ? _self.fee : fee // ignore: cast_nullable_to_non_nullable
as double,commission: null == commission ? _self.commission : commission // ignore: cast_nullable_to_non_nullable
as double,netAmount: null == netAmount ? _self.netAmount : netAmount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$PayoutReport {

// ── required ───────────────────────────────────────────────────────────
 String get doctorId; String get doctorName; String get specialty; AnalyticsDateRange get period; List<PayoutEntry> get entries; double get totalRevenue; double get totalCommission; double get totalNetPayout; DateTime get generatedAt;
/// Create a copy of PayoutReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayoutReportCopyWith<PayoutReport> get copyWith => _$PayoutReportCopyWithImpl<PayoutReport>(this as PayoutReport, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayoutReport&&(identical(other.doctorId, doctorId) || other.doctorId == doctorId)&&(identical(other.doctorName, doctorName) || other.doctorName == doctorName)&&(identical(other.specialty, specialty) || other.specialty == specialty)&&(identical(other.period, period) || other.period == period)&&const DeepCollectionEquality().equals(other.entries, entries)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.totalCommission, totalCommission) || other.totalCommission == totalCommission)&&(identical(other.totalNetPayout, totalNetPayout) || other.totalNetPayout == totalNetPayout)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,doctorId,doctorName,specialty,period,const DeepCollectionEquality().hash(entries),totalRevenue,totalCommission,totalNetPayout,generatedAt);

@override
String toString() {
  return 'PayoutReport(doctorId: $doctorId, doctorName: $doctorName, specialty: $specialty, period: $period, entries: $entries, totalRevenue: $totalRevenue, totalCommission: $totalCommission, totalNetPayout: $totalNetPayout, generatedAt: $generatedAt)';
}


}

/// @nodoc
abstract mixin class $PayoutReportCopyWith<$Res>  {
  factory $PayoutReportCopyWith(PayoutReport value, $Res Function(PayoutReport) _then) = _$PayoutReportCopyWithImpl;
@useResult
$Res call({
 String doctorId, String doctorName, String specialty, AnalyticsDateRange period, List<PayoutEntry> entries, double totalRevenue, double totalCommission, double totalNetPayout, DateTime generatedAt
});


$AnalyticsDateRangeCopyWith<$Res> get period;

}
/// @nodoc
class _$PayoutReportCopyWithImpl<$Res>
    implements $PayoutReportCopyWith<$Res> {
  _$PayoutReportCopyWithImpl(this._self, this._then);

  final PayoutReport _self;
  final $Res Function(PayoutReport) _then;

/// Create a copy of PayoutReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? doctorId = null,Object? doctorName = null,Object? specialty = null,Object? period = null,Object? entries = null,Object? totalRevenue = null,Object? totalCommission = null,Object? totalNetPayout = null,Object? generatedAt = null,}) {
  return _then(_self.copyWith(
doctorId: null == doctorId ? _self.doctorId : doctorId // ignore: cast_nullable_to_non_nullable
as String,doctorName: null == doctorName ? _self.doctorName : doctorName // ignore: cast_nullable_to_non_nullable
as String,specialty: null == specialty ? _self.specialty : specialty // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as AnalyticsDateRange,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<PayoutEntry>,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,totalCommission: null == totalCommission ? _self.totalCommission : totalCommission // ignore: cast_nullable_to_non_nullable
as double,totalNetPayout: null == totalNetPayout ? _self.totalNetPayout : totalNetPayout // ignore: cast_nullable_to_non_nullable
as double,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of PayoutReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsDateRangeCopyWith<$Res> get period {
  
  return $AnalyticsDateRangeCopyWith<$Res>(_self.period, (value) {
    return _then(_self.copyWith(period: value));
  });
}
}


/// Adds pattern-matching-related methods to [PayoutReport].
extension PayoutReportPatterns on PayoutReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayoutReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayoutReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayoutReport value)  $default,){
final _that = this;
switch (_that) {
case _PayoutReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayoutReport value)?  $default,){
final _that = this;
switch (_that) {
case _PayoutReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String doctorId,  String doctorName,  String specialty,  AnalyticsDateRange period,  List<PayoutEntry> entries,  double totalRevenue,  double totalCommission,  double totalNetPayout,  DateTime generatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayoutReport() when $default != null:
return $default(_that.doctorId,_that.doctorName,_that.specialty,_that.period,_that.entries,_that.totalRevenue,_that.totalCommission,_that.totalNetPayout,_that.generatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String doctorId,  String doctorName,  String specialty,  AnalyticsDateRange period,  List<PayoutEntry> entries,  double totalRevenue,  double totalCommission,  double totalNetPayout,  DateTime generatedAt)  $default,) {final _that = this;
switch (_that) {
case _PayoutReport():
return $default(_that.doctorId,_that.doctorName,_that.specialty,_that.period,_that.entries,_that.totalRevenue,_that.totalCommission,_that.totalNetPayout,_that.generatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String doctorId,  String doctorName,  String specialty,  AnalyticsDateRange period,  List<PayoutEntry> entries,  double totalRevenue,  double totalCommission,  double totalNetPayout,  DateTime generatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PayoutReport() when $default != null:
return $default(_that.doctorId,_that.doctorName,_that.specialty,_that.period,_that.entries,_that.totalRevenue,_that.totalCommission,_that.totalNetPayout,_that.generatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _PayoutReport implements PayoutReport {
  const _PayoutReport({required this.doctorId, required this.doctorName, required this.specialty, required this.period, required final  List<PayoutEntry> entries, required this.totalRevenue, required this.totalCommission, required this.totalNetPayout, required this.generatedAt}): _entries = entries;
  

// ── required ───────────────────────────────────────────────────────────
@override final  String doctorId;
@override final  String doctorName;
@override final  String specialty;
@override final  AnalyticsDateRange period;
 final  List<PayoutEntry> _entries;
@override List<PayoutEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

@override final  double totalRevenue;
@override final  double totalCommission;
@override final  double totalNetPayout;
@override final  DateTime generatedAt;

/// Create a copy of PayoutReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayoutReportCopyWith<_PayoutReport> get copyWith => __$PayoutReportCopyWithImpl<_PayoutReport>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayoutReport&&(identical(other.doctorId, doctorId) || other.doctorId == doctorId)&&(identical(other.doctorName, doctorName) || other.doctorName == doctorName)&&(identical(other.specialty, specialty) || other.specialty == specialty)&&(identical(other.period, period) || other.period == period)&&const DeepCollectionEquality().equals(other._entries, _entries)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.totalCommission, totalCommission) || other.totalCommission == totalCommission)&&(identical(other.totalNetPayout, totalNetPayout) || other.totalNetPayout == totalNetPayout)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,doctorId,doctorName,specialty,period,const DeepCollectionEquality().hash(_entries),totalRevenue,totalCommission,totalNetPayout,generatedAt);

@override
String toString() {
  return 'PayoutReport(doctorId: $doctorId, doctorName: $doctorName, specialty: $specialty, period: $period, entries: $entries, totalRevenue: $totalRevenue, totalCommission: $totalCommission, totalNetPayout: $totalNetPayout, generatedAt: $generatedAt)';
}


}

/// @nodoc
abstract mixin class _$PayoutReportCopyWith<$Res> implements $PayoutReportCopyWith<$Res> {
  factory _$PayoutReportCopyWith(_PayoutReport value, $Res Function(_PayoutReport) _then) = __$PayoutReportCopyWithImpl;
@override @useResult
$Res call({
 String doctorId, String doctorName, String specialty, AnalyticsDateRange period, List<PayoutEntry> entries, double totalRevenue, double totalCommission, double totalNetPayout, DateTime generatedAt
});


@override $AnalyticsDateRangeCopyWith<$Res> get period;

}
/// @nodoc
class __$PayoutReportCopyWithImpl<$Res>
    implements _$PayoutReportCopyWith<$Res> {
  __$PayoutReportCopyWithImpl(this._self, this._then);

  final _PayoutReport _self;
  final $Res Function(_PayoutReport) _then;

/// Create a copy of PayoutReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? doctorId = null,Object? doctorName = null,Object? specialty = null,Object? period = null,Object? entries = null,Object? totalRevenue = null,Object? totalCommission = null,Object? totalNetPayout = null,Object? generatedAt = null,}) {
  return _then(_PayoutReport(
doctorId: null == doctorId ? _self.doctorId : doctorId // ignore: cast_nullable_to_non_nullable
as String,doctorName: null == doctorName ? _self.doctorName : doctorName // ignore: cast_nullable_to_non_nullable
as String,specialty: null == specialty ? _self.specialty : specialty // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as AnalyticsDateRange,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<PayoutEntry>,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,totalCommission: null == totalCommission ? _self.totalCommission : totalCommission // ignore: cast_nullable_to_non_nullable
as double,totalNetPayout: null == totalNetPayout ? _self.totalNetPayout : totalNetPayout // ignore: cast_nullable_to_non_nullable
as double,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of PayoutReport
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
