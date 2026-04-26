// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payout_report_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PayoutEntryModel {

 String get appointmentId; String get patientName; String get appointmentDate; String get status; double get fee; double get commission; double get netAmount;
/// Create a copy of PayoutEntryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayoutEntryModelCopyWith<PayoutEntryModel> get copyWith => _$PayoutEntryModelCopyWithImpl<PayoutEntryModel>(this as PayoutEntryModel, _$identity);

  /// Serializes this PayoutEntryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayoutEntryModel&&(identical(other.appointmentId, appointmentId) || other.appointmentId == appointmentId)&&(identical(other.patientName, patientName) || other.patientName == patientName)&&(identical(other.appointmentDate, appointmentDate) || other.appointmentDate == appointmentDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.fee, fee) || other.fee == fee)&&(identical(other.commission, commission) || other.commission == commission)&&(identical(other.netAmount, netAmount) || other.netAmount == netAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appointmentId,patientName,appointmentDate,status,fee,commission,netAmount);

@override
String toString() {
  return 'PayoutEntryModel(appointmentId: $appointmentId, patientName: $patientName, appointmentDate: $appointmentDate, status: $status, fee: $fee, commission: $commission, netAmount: $netAmount)';
}


}

/// @nodoc
abstract mixin class $PayoutEntryModelCopyWith<$Res>  {
  factory $PayoutEntryModelCopyWith(PayoutEntryModel value, $Res Function(PayoutEntryModel) _then) = _$PayoutEntryModelCopyWithImpl;
@useResult
$Res call({
 String appointmentId, String patientName, String appointmentDate, String status, double fee, double commission, double netAmount
});




}
/// @nodoc
class _$PayoutEntryModelCopyWithImpl<$Res>
    implements $PayoutEntryModelCopyWith<$Res> {
  _$PayoutEntryModelCopyWithImpl(this._self, this._then);

  final PayoutEntryModel _self;
  final $Res Function(PayoutEntryModel) _then;

/// Create a copy of PayoutEntryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? appointmentId = null,Object? patientName = null,Object? appointmentDate = null,Object? status = null,Object? fee = null,Object? commission = null,Object? netAmount = null,}) {
  return _then(_self.copyWith(
appointmentId: null == appointmentId ? _self.appointmentId : appointmentId // ignore: cast_nullable_to_non_nullable
as String,patientName: null == patientName ? _self.patientName : patientName // ignore: cast_nullable_to_non_nullable
as String,appointmentDate: null == appointmentDate ? _self.appointmentDate : appointmentDate // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,fee: null == fee ? _self.fee : fee // ignore: cast_nullable_to_non_nullable
as double,commission: null == commission ? _self.commission : commission // ignore: cast_nullable_to_non_nullable
as double,netAmount: null == netAmount ? _self.netAmount : netAmount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PayoutEntryModel].
extension PayoutEntryModelPatterns on PayoutEntryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayoutEntryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayoutEntryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayoutEntryModel value)  $default,){
final _that = this;
switch (_that) {
case _PayoutEntryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayoutEntryModel value)?  $default,){
final _that = this;
switch (_that) {
case _PayoutEntryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String appointmentId,  String patientName,  String appointmentDate,  String status,  double fee,  double commission,  double netAmount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayoutEntryModel() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String appointmentId,  String patientName,  String appointmentDate,  String status,  double fee,  double commission,  double netAmount)  $default,) {final _that = this;
switch (_that) {
case _PayoutEntryModel():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String appointmentId,  String patientName,  String appointmentDate,  String status,  double fee,  double commission,  double netAmount)?  $default,) {final _that = this;
switch (_that) {
case _PayoutEntryModel() when $default != null:
return $default(_that.appointmentId,_that.patientName,_that.appointmentDate,_that.status,_that.fee,_that.commission,_that.netAmount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PayoutEntryModel extends PayoutEntryModel {
  const _PayoutEntryModel({required this.appointmentId, required this.patientName, required this.appointmentDate, required this.status, required this.fee, required this.commission, required this.netAmount}): super._();
  factory _PayoutEntryModel.fromJson(Map<String, dynamic> json) => _$PayoutEntryModelFromJson(json);

@override final  String appointmentId;
@override final  String patientName;
@override final  String appointmentDate;
@override final  String status;
@override final  double fee;
@override final  double commission;
@override final  double netAmount;

/// Create a copy of PayoutEntryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayoutEntryModelCopyWith<_PayoutEntryModel> get copyWith => __$PayoutEntryModelCopyWithImpl<_PayoutEntryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PayoutEntryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayoutEntryModel&&(identical(other.appointmentId, appointmentId) || other.appointmentId == appointmentId)&&(identical(other.patientName, patientName) || other.patientName == patientName)&&(identical(other.appointmentDate, appointmentDate) || other.appointmentDate == appointmentDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.fee, fee) || other.fee == fee)&&(identical(other.commission, commission) || other.commission == commission)&&(identical(other.netAmount, netAmount) || other.netAmount == netAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appointmentId,patientName,appointmentDate,status,fee,commission,netAmount);

@override
String toString() {
  return 'PayoutEntryModel(appointmentId: $appointmentId, patientName: $patientName, appointmentDate: $appointmentDate, status: $status, fee: $fee, commission: $commission, netAmount: $netAmount)';
}


}

/// @nodoc
abstract mixin class _$PayoutEntryModelCopyWith<$Res> implements $PayoutEntryModelCopyWith<$Res> {
  factory _$PayoutEntryModelCopyWith(_PayoutEntryModel value, $Res Function(_PayoutEntryModel) _then) = __$PayoutEntryModelCopyWithImpl;
@override @useResult
$Res call({
 String appointmentId, String patientName, String appointmentDate, String status, double fee, double commission, double netAmount
});




}
/// @nodoc
class __$PayoutEntryModelCopyWithImpl<$Res>
    implements _$PayoutEntryModelCopyWith<$Res> {
  __$PayoutEntryModelCopyWithImpl(this._self, this._then);

  final _PayoutEntryModel _self;
  final $Res Function(_PayoutEntryModel) _then;

/// Create a copy of PayoutEntryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? appointmentId = null,Object? patientName = null,Object? appointmentDate = null,Object? status = null,Object? fee = null,Object? commission = null,Object? netAmount = null,}) {
  return _then(_PayoutEntryModel(
appointmentId: null == appointmentId ? _self.appointmentId : appointmentId // ignore: cast_nullable_to_non_nullable
as String,patientName: null == patientName ? _self.patientName : patientName // ignore: cast_nullable_to_non_nullable
as String,appointmentDate: null == appointmentDate ? _self.appointmentDate : appointmentDate // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,fee: null == fee ? _self.fee : fee // ignore: cast_nullable_to_non_nullable
as double,commission: null == commission ? _self.commission : commission // ignore: cast_nullable_to_non_nullable
as double,netAmount: null == netAmount ? _self.netAmount : netAmount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$PayoutReportModel {

 String get doctorId; String get doctorName; String get specialty; Map<String, String> get period; List<PayoutEntryModel> get entries; double get totalRevenue; double get totalCommission; double get totalNetPayout; String get generatedAt;
/// Create a copy of PayoutReportModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayoutReportModelCopyWith<PayoutReportModel> get copyWith => _$PayoutReportModelCopyWithImpl<PayoutReportModel>(this as PayoutReportModel, _$identity);

  /// Serializes this PayoutReportModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayoutReportModel&&(identical(other.doctorId, doctorId) || other.doctorId == doctorId)&&(identical(other.doctorName, doctorName) || other.doctorName == doctorName)&&(identical(other.specialty, specialty) || other.specialty == specialty)&&const DeepCollectionEquality().equals(other.period, period)&&const DeepCollectionEquality().equals(other.entries, entries)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.totalCommission, totalCommission) || other.totalCommission == totalCommission)&&(identical(other.totalNetPayout, totalNetPayout) || other.totalNetPayout == totalNetPayout)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,doctorId,doctorName,specialty,const DeepCollectionEquality().hash(period),const DeepCollectionEquality().hash(entries),totalRevenue,totalCommission,totalNetPayout,generatedAt);

@override
String toString() {
  return 'PayoutReportModel(doctorId: $doctorId, doctorName: $doctorName, specialty: $specialty, period: $period, entries: $entries, totalRevenue: $totalRevenue, totalCommission: $totalCommission, totalNetPayout: $totalNetPayout, generatedAt: $generatedAt)';
}


}

/// @nodoc
abstract mixin class $PayoutReportModelCopyWith<$Res>  {
  factory $PayoutReportModelCopyWith(PayoutReportModel value, $Res Function(PayoutReportModel) _then) = _$PayoutReportModelCopyWithImpl;
@useResult
$Res call({
 String doctorId, String doctorName, String specialty, Map<String, String> period, List<PayoutEntryModel> entries, double totalRevenue, double totalCommission, double totalNetPayout, String generatedAt
});




}
/// @nodoc
class _$PayoutReportModelCopyWithImpl<$Res>
    implements $PayoutReportModelCopyWith<$Res> {
  _$PayoutReportModelCopyWithImpl(this._self, this._then);

  final PayoutReportModel _self;
  final $Res Function(PayoutReportModel) _then;

/// Create a copy of PayoutReportModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? doctorId = null,Object? doctorName = null,Object? specialty = null,Object? period = null,Object? entries = null,Object? totalRevenue = null,Object? totalCommission = null,Object? totalNetPayout = null,Object? generatedAt = null,}) {
  return _then(_self.copyWith(
doctorId: null == doctorId ? _self.doctorId : doctorId // ignore: cast_nullable_to_non_nullable
as String,doctorName: null == doctorName ? _self.doctorName : doctorName // ignore: cast_nullable_to_non_nullable
as String,specialty: null == specialty ? _self.specialty : specialty // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as Map<String, String>,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<PayoutEntryModel>,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,totalCommission: null == totalCommission ? _self.totalCommission : totalCommission // ignore: cast_nullable_to_non_nullable
as double,totalNetPayout: null == totalNetPayout ? _self.totalNetPayout : totalNetPayout // ignore: cast_nullable_to_non_nullable
as double,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PayoutReportModel].
extension PayoutReportModelPatterns on PayoutReportModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayoutReportModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayoutReportModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayoutReportModel value)  $default,){
final _that = this;
switch (_that) {
case _PayoutReportModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayoutReportModel value)?  $default,){
final _that = this;
switch (_that) {
case _PayoutReportModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String doctorId,  String doctorName,  String specialty,  Map<String, String> period,  List<PayoutEntryModel> entries,  double totalRevenue,  double totalCommission,  double totalNetPayout,  String generatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayoutReportModel() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String doctorId,  String doctorName,  String specialty,  Map<String, String> period,  List<PayoutEntryModel> entries,  double totalRevenue,  double totalCommission,  double totalNetPayout,  String generatedAt)  $default,) {final _that = this;
switch (_that) {
case _PayoutReportModel():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String doctorId,  String doctorName,  String specialty,  Map<String, String> period,  List<PayoutEntryModel> entries,  double totalRevenue,  double totalCommission,  double totalNetPayout,  String generatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PayoutReportModel() when $default != null:
return $default(_that.doctorId,_that.doctorName,_that.specialty,_that.period,_that.entries,_that.totalRevenue,_that.totalCommission,_that.totalNetPayout,_that.generatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PayoutReportModel extends PayoutReportModel {
  const _PayoutReportModel({required this.doctorId, required this.doctorName, required this.specialty, required final  Map<String, String> period, required final  List<PayoutEntryModel> entries, required this.totalRevenue, required this.totalCommission, required this.totalNetPayout, required this.generatedAt}): _period = period,_entries = entries,super._();
  factory _PayoutReportModel.fromJson(Map<String, dynamic> json) => _$PayoutReportModelFromJson(json);

@override final  String doctorId;
@override final  String doctorName;
@override final  String specialty;
 final  Map<String, String> _period;
@override Map<String, String> get period {
  if (_period is EqualUnmodifiableMapView) return _period;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_period);
}

 final  List<PayoutEntryModel> _entries;
@override List<PayoutEntryModel> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

@override final  double totalRevenue;
@override final  double totalCommission;
@override final  double totalNetPayout;
@override final  String generatedAt;

/// Create a copy of PayoutReportModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayoutReportModelCopyWith<_PayoutReportModel> get copyWith => __$PayoutReportModelCopyWithImpl<_PayoutReportModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PayoutReportModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayoutReportModel&&(identical(other.doctorId, doctorId) || other.doctorId == doctorId)&&(identical(other.doctorName, doctorName) || other.doctorName == doctorName)&&(identical(other.specialty, specialty) || other.specialty == specialty)&&const DeepCollectionEquality().equals(other._period, _period)&&const DeepCollectionEquality().equals(other._entries, _entries)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.totalCommission, totalCommission) || other.totalCommission == totalCommission)&&(identical(other.totalNetPayout, totalNetPayout) || other.totalNetPayout == totalNetPayout)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,doctorId,doctorName,specialty,const DeepCollectionEquality().hash(_period),const DeepCollectionEquality().hash(_entries),totalRevenue,totalCommission,totalNetPayout,generatedAt);

@override
String toString() {
  return 'PayoutReportModel(doctorId: $doctorId, doctorName: $doctorName, specialty: $specialty, period: $period, entries: $entries, totalRevenue: $totalRevenue, totalCommission: $totalCommission, totalNetPayout: $totalNetPayout, generatedAt: $generatedAt)';
}


}

/// @nodoc
abstract mixin class _$PayoutReportModelCopyWith<$Res> implements $PayoutReportModelCopyWith<$Res> {
  factory _$PayoutReportModelCopyWith(_PayoutReportModel value, $Res Function(_PayoutReportModel) _then) = __$PayoutReportModelCopyWithImpl;
@override @useResult
$Res call({
 String doctorId, String doctorName, String specialty, Map<String, String> period, List<PayoutEntryModel> entries, double totalRevenue, double totalCommission, double totalNetPayout, String generatedAt
});




}
/// @nodoc
class __$PayoutReportModelCopyWithImpl<$Res>
    implements _$PayoutReportModelCopyWith<$Res> {
  __$PayoutReportModelCopyWithImpl(this._self, this._then);

  final _PayoutReportModel _self;
  final $Res Function(_PayoutReportModel) _then;

/// Create a copy of PayoutReportModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? doctorId = null,Object? doctorName = null,Object? specialty = null,Object? period = null,Object? entries = null,Object? totalRevenue = null,Object? totalCommission = null,Object? totalNetPayout = null,Object? generatedAt = null,}) {
  return _then(_PayoutReportModel(
doctorId: null == doctorId ? _self.doctorId : doctorId // ignore: cast_nullable_to_non_nullable
as String,doctorName: null == doctorName ? _self.doctorName : doctorName // ignore: cast_nullable_to_non_nullable
as String,specialty: null == specialty ? _self.specialty : specialty // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self._period : period // ignore: cast_nullable_to_non_nullable
as Map<String, String>,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<PayoutEntryModel>,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,totalCommission: null == totalCommission ? _self.totalCommission : totalCommission // ignore: cast_nullable_to_non_nullable
as double,totalNetPayout: null == totalNetPayout ? _self.totalNetPayout : totalNetPayout // ignore: cast_nullable_to_non_nullable
as double,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
