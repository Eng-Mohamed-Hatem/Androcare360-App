// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'package_service_usage.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PackageServiceUsage {

 String get serviceId; DateTime get usedAt; String? get note;
/// Create a copy of PackageServiceUsage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackageServiceUsageCopyWith<PackageServiceUsage> get copyWith => _$PackageServiceUsageCopyWithImpl<PackageServiceUsage>(this as PackageServiceUsage, _$identity);

  /// Serializes this PackageServiceUsage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackageServiceUsage&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.usedAt, usedAt) || other.usedAt == usedAt)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,serviceId,usedAt,note);

@override
String toString() {
  return 'PackageServiceUsage(serviceId: $serviceId, usedAt: $usedAt, note: $note)';
}


}

/// @nodoc
abstract mixin class $PackageServiceUsageCopyWith<$Res>  {
  factory $PackageServiceUsageCopyWith(PackageServiceUsage value, $Res Function(PackageServiceUsage) _then) = _$PackageServiceUsageCopyWithImpl;
@useResult
$Res call({
 String serviceId, DateTime usedAt, String? note
});




}
/// @nodoc
class _$PackageServiceUsageCopyWithImpl<$Res>
    implements $PackageServiceUsageCopyWith<$Res> {
  _$PackageServiceUsageCopyWithImpl(this._self, this._then);

  final PackageServiceUsage _self;
  final $Res Function(PackageServiceUsage) _then;

/// Create a copy of PackageServiceUsage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? serviceId = null,Object? usedAt = null,Object? note = freezed,}) {
  return _then(_self.copyWith(
serviceId: null == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String,usedAt: null == usedAt ? _self.usedAt : usedAt // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PackageServiceUsage].
extension PackageServiceUsagePatterns on PackageServiceUsage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackageServiceUsage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackageServiceUsage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackageServiceUsage value)  $default,){
final _that = this;
switch (_that) {
case _PackageServiceUsage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackageServiceUsage value)?  $default,){
final _that = this;
switch (_that) {
case _PackageServiceUsage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String serviceId,  DateTime usedAt,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackageServiceUsage() when $default != null:
return $default(_that.serviceId,_that.usedAt,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String serviceId,  DateTime usedAt,  String? note)  $default,) {final _that = this;
switch (_that) {
case _PackageServiceUsage():
return $default(_that.serviceId,_that.usedAt,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String serviceId,  DateTime usedAt,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _PackageServiceUsage() when $default != null:
return $default(_that.serviceId,_that.usedAt,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PackageServiceUsage extends PackageServiceUsage {
  const _PackageServiceUsage({required this.serviceId, required this.usedAt, this.note}): super._();
  factory _PackageServiceUsage.fromJson(Map<String, dynamic> json) => _$PackageServiceUsageFromJson(json);

@override final  String serviceId;
@override final  DateTime usedAt;
@override final  String? note;

/// Create a copy of PackageServiceUsage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackageServiceUsageCopyWith<_PackageServiceUsage> get copyWith => __$PackageServiceUsageCopyWithImpl<_PackageServiceUsage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackageServiceUsageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackageServiceUsage&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.usedAt, usedAt) || other.usedAt == usedAt)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,serviceId,usedAt,note);

@override
String toString() {
  return 'PackageServiceUsage(serviceId: $serviceId, usedAt: $usedAt, note: $note)';
}


}

/// @nodoc
abstract mixin class _$PackageServiceUsageCopyWith<$Res> implements $PackageServiceUsageCopyWith<$Res> {
  factory _$PackageServiceUsageCopyWith(_PackageServiceUsage value, $Res Function(_PackageServiceUsage) _then) = __$PackageServiceUsageCopyWithImpl;
@override @useResult
$Res call({
 String serviceId, DateTime usedAt, String? note
});




}
/// @nodoc
class __$PackageServiceUsageCopyWithImpl<$Res>
    implements _$PackageServiceUsageCopyWith<$Res> {
  __$PackageServiceUsageCopyWithImpl(this._self, this._then);

  final _PackageServiceUsage _self;
  final $Res Function(_PackageServiceUsage) _then;

/// Create a copy of PackageServiceUsage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? serviceId = null,Object? usedAt = null,Object? note = freezed,}) {
  return _then(_PackageServiceUsage(
serviceId: null == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String,usedAt: null == usedAt ? _self.usedAt : usedAt // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
