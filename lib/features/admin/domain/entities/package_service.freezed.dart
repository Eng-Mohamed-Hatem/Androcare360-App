// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'package_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PackageService {

 String get id; String get serviceName; String get description; double get price; int get durationMinutes;
/// Create a copy of PackageService
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackageServiceCopyWith<PackageService> get copyWith => _$PackageServiceCopyWithImpl<PackageService>(this as PackageService, _$identity);

  /// Serializes this PackageService to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackageService&&(identical(other.id, id) || other.id == id)&&(identical(other.serviceName, serviceName) || other.serviceName == serviceName)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,serviceName,description,price,durationMinutes);

@override
String toString() {
  return 'PackageService(id: $id, serviceName: $serviceName, description: $description, price: $price, durationMinutes: $durationMinutes)';
}


}

/// @nodoc
abstract mixin class $PackageServiceCopyWith<$Res>  {
  factory $PackageServiceCopyWith(PackageService value, $Res Function(PackageService) _then) = _$PackageServiceCopyWithImpl;
@useResult
$Res call({
 String id, String serviceName, String description, double price, int durationMinutes
});




}
/// @nodoc
class _$PackageServiceCopyWithImpl<$Res>
    implements $PackageServiceCopyWith<$Res> {
  _$PackageServiceCopyWithImpl(this._self, this._then);

  final PackageService _self;
  final $Res Function(PackageService) _then;

/// Create a copy of PackageService
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? serviceName = null,Object? description = null,Object? price = null,Object? durationMinutes = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,serviceName: null == serviceName ? _self.serviceName : serviceName // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PackageService].
extension PackageServicePatterns on PackageService {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackageService value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackageService() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackageService value)  $default,){
final _that = this;
switch (_that) {
case _PackageService():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackageService value)?  $default,){
final _that = this;
switch (_that) {
case _PackageService() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String serviceName,  String description,  double price,  int durationMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackageService() when $default != null:
return $default(_that.id,_that.serviceName,_that.description,_that.price,_that.durationMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String serviceName,  String description,  double price,  int durationMinutes)  $default,) {final _that = this;
switch (_that) {
case _PackageService():
return $default(_that.id,_that.serviceName,_that.description,_that.price,_that.durationMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String serviceName,  String description,  double price,  int durationMinutes)?  $default,) {final _that = this;
switch (_that) {
case _PackageService() when $default != null:
return $default(_that.id,_that.serviceName,_that.description,_that.price,_that.durationMinutes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PackageService extends PackageService {
  const _PackageService({required this.id, required this.serviceName, required this.description, required this.price, required this.durationMinutes}): super._();
  factory _PackageService.fromJson(Map<String, dynamic> json) => _$PackageServiceFromJson(json);

@override final  String id;
@override final  String serviceName;
@override final  String description;
@override final  double price;
@override final  int durationMinutes;

/// Create a copy of PackageService
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackageServiceCopyWith<_PackageService> get copyWith => __$PackageServiceCopyWithImpl<_PackageService>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackageServiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackageService&&(identical(other.id, id) || other.id == id)&&(identical(other.serviceName, serviceName) || other.serviceName == serviceName)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,serviceName,description,price,durationMinutes);

@override
String toString() {
  return 'PackageService(id: $id, serviceName: $serviceName, description: $description, price: $price, durationMinutes: $durationMinutes)';
}


}

/// @nodoc
abstract mixin class _$PackageServiceCopyWith<$Res> implements $PackageServiceCopyWith<$Res> {
  factory _$PackageServiceCopyWith(_PackageService value, $Res Function(_PackageService) _then) = __$PackageServiceCopyWithImpl;
@override @useResult
$Res call({
 String id, String serviceName, String description, double price, int durationMinutes
});




}
/// @nodoc
class __$PackageServiceCopyWithImpl<$Res>
    implements _$PackageServiceCopyWith<$Res> {
  __$PackageServiceCopyWithImpl(this._self, this._then);

  final _PackageService _self;
  final $Res Function(_PackageService) _then;

/// Create a copy of PackageService
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? serviceName = null,Object? description = null,Object? price = null,Object? durationMinutes = null,}) {
  return _then(_PackageService(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,serviceName: null == serviceName ? _self.serviceName : serviceName // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
