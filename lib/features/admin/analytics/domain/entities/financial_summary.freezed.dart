// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'financial_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FinancialSummary {

/// إجمالي الإيرادات (المواعيد المكتملة فقط ذات الرسوم > 0)
 double get totalRevenue;/// عمولة المنصة = totalRevenue × commissionRate
 double get platformCommission;/// صافي المستحق = totalRevenue − platformCommission
 double get netPayout;/// المبلغ المدفوع فعلياً للطبيب
 double get paidAmount;/// المبلغ في انتظار الصرف
 double get pendingAmount;/// نسبة عمولة المنصة (من platform_settings/commission.rate)
 double get commissionRate;
/// Create a copy of FinancialSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FinancialSummaryCopyWith<FinancialSummary> get copyWith => _$FinancialSummaryCopyWithImpl<FinancialSummary>(this as FinancialSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FinancialSummary&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.platformCommission, platformCommission) || other.platformCommission == platformCommission)&&(identical(other.netPayout, netPayout) || other.netPayout == netPayout)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.pendingAmount, pendingAmount) || other.pendingAmount == pendingAmount)&&(identical(other.commissionRate, commissionRate) || other.commissionRate == commissionRate));
}


@override
int get hashCode => Object.hash(runtimeType,totalRevenue,platformCommission,netPayout,paidAmount,pendingAmount,commissionRate);

@override
String toString() {
  return 'FinancialSummary(totalRevenue: $totalRevenue, platformCommission: $platformCommission, netPayout: $netPayout, paidAmount: $paidAmount, pendingAmount: $pendingAmount, commissionRate: $commissionRate)';
}


}

/// @nodoc
abstract mixin class $FinancialSummaryCopyWith<$Res>  {
  factory $FinancialSummaryCopyWith(FinancialSummary value, $Res Function(FinancialSummary) _then) = _$FinancialSummaryCopyWithImpl;
@useResult
$Res call({
 double totalRevenue, double platformCommission, double netPayout, double paidAmount, double pendingAmount, double commissionRate
});




}
/// @nodoc
class _$FinancialSummaryCopyWithImpl<$Res>
    implements $FinancialSummaryCopyWith<$Res> {
  _$FinancialSummaryCopyWithImpl(this._self, this._then);

  final FinancialSummary _self;
  final $Res Function(FinancialSummary) _then;

/// Create a copy of FinancialSummary
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


/// Adds pattern-matching-related methods to [FinancialSummary].
extension FinancialSummaryPatterns on FinancialSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FinancialSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FinancialSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FinancialSummary value)  $default,){
final _that = this;
switch (_that) {
case _FinancialSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FinancialSummary value)?  $default,){
final _that = this;
switch (_that) {
case _FinancialSummary() when $default != null:
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
case _FinancialSummary() when $default != null:
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
case _FinancialSummary():
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
case _FinancialSummary() when $default != null:
return $default(_that.totalRevenue,_that.platformCommission,_that.netPayout,_that.paidAmount,_that.pendingAmount,_that.commissionRate);case _:
  return null;

}
}

}

/// @nodoc


class _FinancialSummary implements FinancialSummary {
  const _FinancialSummary({required this.totalRevenue, required this.platformCommission, required this.netPayout, required this.paidAmount, required this.pendingAmount, required this.commissionRate});
  

/// إجمالي الإيرادات (المواعيد المكتملة فقط ذات الرسوم > 0)
@override final  double totalRevenue;
/// عمولة المنصة = totalRevenue × commissionRate
@override final  double platformCommission;
/// صافي المستحق = totalRevenue − platformCommission
@override final  double netPayout;
/// المبلغ المدفوع فعلياً للطبيب
@override final  double paidAmount;
/// المبلغ في انتظار الصرف
@override final  double pendingAmount;
/// نسبة عمولة المنصة (من platform_settings/commission.rate)
@override final  double commissionRate;

/// Create a copy of FinancialSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FinancialSummaryCopyWith<_FinancialSummary> get copyWith => __$FinancialSummaryCopyWithImpl<_FinancialSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FinancialSummary&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.platformCommission, platformCommission) || other.platformCommission == platformCommission)&&(identical(other.netPayout, netPayout) || other.netPayout == netPayout)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.pendingAmount, pendingAmount) || other.pendingAmount == pendingAmount)&&(identical(other.commissionRate, commissionRate) || other.commissionRate == commissionRate));
}


@override
int get hashCode => Object.hash(runtimeType,totalRevenue,platformCommission,netPayout,paidAmount,pendingAmount,commissionRate);

@override
String toString() {
  return 'FinancialSummary(totalRevenue: $totalRevenue, platformCommission: $platformCommission, netPayout: $netPayout, paidAmount: $paidAmount, pendingAmount: $pendingAmount, commissionRate: $commissionRate)';
}


}

/// @nodoc
abstract mixin class _$FinancialSummaryCopyWith<$Res> implements $FinancialSummaryCopyWith<$Res> {
  factory _$FinancialSummaryCopyWith(_FinancialSummary value, $Res Function(_FinancialSummary) _then) = __$FinancialSummaryCopyWithImpl;
@override @useResult
$Res call({
 double totalRevenue, double platformCommission, double netPayout, double paidAmount, double pendingAmount, double commissionRate
});




}
/// @nodoc
class __$FinancialSummaryCopyWithImpl<$Res>
    implements _$FinancialSummaryCopyWith<$Res> {
  __$FinancialSummaryCopyWithImpl(this._self, this._then);

  final _FinancialSummary _self;
  final $Res Function(_FinancialSummary) _then;

/// Create a copy of FinancialSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalRevenue = null,Object? platformCommission = null,Object? netPayout = null,Object? paidAmount = null,Object? pendingAmount = null,Object? commissionRate = null,}) {
  return _then(_FinancialSummary(
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
