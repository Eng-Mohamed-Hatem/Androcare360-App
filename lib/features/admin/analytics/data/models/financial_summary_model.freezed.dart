// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'financial_summary_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FinancialSummaryModel {

 double get totalRevenue; double get platformCommission; double get netPayout; double get paidAmount; double get pendingAmount; double get commissionRate;
/// Create a copy of FinancialSummaryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FinancialSummaryModelCopyWith<FinancialSummaryModel> get copyWith => _$FinancialSummaryModelCopyWithImpl<FinancialSummaryModel>(this as FinancialSummaryModel, _$identity);

  /// Serializes this FinancialSummaryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FinancialSummaryModel&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.platformCommission, platformCommission) || other.platformCommission == platformCommission)&&(identical(other.netPayout, netPayout) || other.netPayout == netPayout)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.pendingAmount, pendingAmount) || other.pendingAmount == pendingAmount)&&(identical(other.commissionRate, commissionRate) || other.commissionRate == commissionRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalRevenue,platformCommission,netPayout,paidAmount,pendingAmount,commissionRate);

@override
String toString() {
  return 'FinancialSummaryModel(totalRevenue: $totalRevenue, platformCommission: $platformCommission, netPayout: $netPayout, paidAmount: $paidAmount, pendingAmount: $pendingAmount, commissionRate: $commissionRate)';
}


}

/// @nodoc
abstract mixin class $FinancialSummaryModelCopyWith<$Res>  {
  factory $FinancialSummaryModelCopyWith(FinancialSummaryModel value, $Res Function(FinancialSummaryModel) _then) = _$FinancialSummaryModelCopyWithImpl;
@useResult
$Res call({
 double totalRevenue, double platformCommission, double netPayout, double paidAmount, double pendingAmount, double commissionRate
});




}
/// @nodoc
class _$FinancialSummaryModelCopyWithImpl<$Res>
    implements $FinancialSummaryModelCopyWith<$Res> {
  _$FinancialSummaryModelCopyWithImpl(this._self, this._then);

  final FinancialSummaryModel _self;
  final $Res Function(FinancialSummaryModel) _then;

/// Create a copy of FinancialSummaryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalRevenue = null,Object? platformCommission = null,Object? netPayout = null,Object? paidAmount = null,Object? pendingAmount = null,Object? commissionRate = null,}) {
  return _then(_self.copyWith(
totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,platformCommission: null == platformCommission ? _self.platformCommission : platformCommission // ignore: cast_nullable_to_non_nullable
as double,netPayout: null == netPayout ? _self.netPayout : netPayout // ignore: cast_nullable_to_non_nullable
as double,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double,pendingAmount: null == pendingAmount ? _self.pendingAmount : pendingAmount // ignore: cast_nullable_to_non_nullable
as double,commissionRate: null == commissionRate ? _self.commissionRate : commissionRate // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [FinancialSummaryModel].
extension FinancialSummaryModelPatterns on FinancialSummaryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FinancialSummaryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FinancialSummaryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FinancialSummaryModel value)  $default,){
final _that = this;
switch (_that) {
case _FinancialSummaryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FinancialSummaryModel value)?  $default,){
final _that = this;
switch (_that) {
case _FinancialSummaryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double totalRevenue,  double platformCommission,  double netPayout,  double paidAmount,  double pendingAmount,  double commissionRate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FinancialSummaryModel() when $default != null:
return $default(_that.totalRevenue,_that.platformCommission,_that.netPayout,_that.paidAmount,_that.pendingAmount,_that.commissionRate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double totalRevenue,  double platformCommission,  double netPayout,  double paidAmount,  double pendingAmount,  double commissionRate)  $default,) {final _that = this;
switch (_that) {
case _FinancialSummaryModel():
return $default(_that.totalRevenue,_that.platformCommission,_that.netPayout,_that.paidAmount,_that.pendingAmount,_that.commissionRate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double totalRevenue,  double platformCommission,  double netPayout,  double paidAmount,  double pendingAmount,  double commissionRate)?  $default,) {final _that = this;
switch (_that) {
case _FinancialSummaryModel() when $default != null:
return $default(_that.totalRevenue,_that.platformCommission,_that.netPayout,_that.paidAmount,_that.pendingAmount,_that.commissionRate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FinancialSummaryModel extends FinancialSummaryModel {
  const _FinancialSummaryModel({required this.totalRevenue, required this.platformCommission, required this.netPayout, required this.paidAmount, required this.pendingAmount, required this.commissionRate}): super._();
  factory _FinancialSummaryModel.fromJson(Map<String, dynamic> json) => _$FinancialSummaryModelFromJson(json);

@override final  double totalRevenue;
@override final  double platformCommission;
@override final  double netPayout;
@override final  double paidAmount;
@override final  double pendingAmount;
@override final  double commissionRate;

/// Create a copy of FinancialSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FinancialSummaryModelCopyWith<_FinancialSummaryModel> get copyWith => __$FinancialSummaryModelCopyWithImpl<_FinancialSummaryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FinancialSummaryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FinancialSummaryModel&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.platformCommission, platformCommission) || other.platformCommission == platformCommission)&&(identical(other.netPayout, netPayout) || other.netPayout == netPayout)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.pendingAmount, pendingAmount) || other.pendingAmount == pendingAmount)&&(identical(other.commissionRate, commissionRate) || other.commissionRate == commissionRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalRevenue,platformCommission,netPayout,paidAmount,pendingAmount,commissionRate);

@override
String toString() {
  return 'FinancialSummaryModel(totalRevenue: $totalRevenue, platformCommission: $platformCommission, netPayout: $netPayout, paidAmount: $paidAmount, pendingAmount: $pendingAmount, commissionRate: $commissionRate)';
}


}

/// @nodoc
abstract mixin class _$FinancialSummaryModelCopyWith<$Res> implements $FinancialSummaryModelCopyWith<$Res> {
  factory _$FinancialSummaryModelCopyWith(_FinancialSummaryModel value, $Res Function(_FinancialSummaryModel) _then) = __$FinancialSummaryModelCopyWithImpl;
@override @useResult
$Res call({
 double totalRevenue, double platformCommission, double netPayout, double paidAmount, double pendingAmount, double commissionRate
});




}
/// @nodoc
class __$FinancialSummaryModelCopyWithImpl<$Res>
    implements _$FinancialSummaryModelCopyWith<$Res> {
  __$FinancialSummaryModelCopyWithImpl(this._self, this._then);

  final _FinancialSummaryModel _self;
  final $Res Function(_FinancialSummaryModel) _then;

/// Create a copy of FinancialSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalRevenue = null,Object? platformCommission = null,Object? netPayout = null,Object? paidAmount = null,Object? pendingAmount = null,Object? commissionRate = null,}) {
  return _then(_FinancialSummaryModel(
totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,platformCommission: null == platformCommission ? _self.platformCommission : platformCommission // ignore: cast_nullable_to_non_nullable
as double,netPayout: null == netPayout ? _self.netPayout : netPayout // ignore: cast_nullable_to_non_nullable
as double,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double,pendingAmount: null == pendingAmount ? _self.pendingAmount : pendingAmount // ignore: cast_nullable_to_non_nullable
as double,commissionRate: null == commissionRate ? _self.commissionRate : commissionRate // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
