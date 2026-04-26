// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_alert.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AdminAlert {

// ── required ───────────────────────────────────────────────────────────
 String get id; AlertType get type; String get doctorId; String get doctorName; String get title; String get message;/// القيمة التي أطلقت التنبيه (مثل: "5200 SAR"، "65%"، "12 يوماً")
 String get triggerValue;/// الحد المضبوط في admin_settings/alert_thresholds
 String get threshold; DateTime get createdAt;// ── optional / defaulted ───────────────────────────────────────────────
 bool get isRead; DateTime? get resolvedAt;
/// Create a copy of AdminAlert
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminAlertCopyWith<AdminAlert> get copyWith => _$AdminAlertCopyWithImpl<AdminAlert>(this as AdminAlert, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminAlert&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.doctorId, doctorId) || other.doctorId == doctorId)&&(identical(other.doctorName, doctorName) || other.doctorName == doctorName)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.triggerValue, triggerValue) || other.triggerValue == triggerValue)&&(identical(other.threshold, threshold) || other.threshold == threshold)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,doctorId,doctorName,title,message,triggerValue,threshold,createdAt,isRead,resolvedAt);

@override
String toString() {
  return 'AdminAlert(id: $id, type: $type, doctorId: $doctorId, doctorName: $doctorName, title: $title, message: $message, triggerValue: $triggerValue, threshold: $threshold, createdAt: $createdAt, isRead: $isRead, resolvedAt: $resolvedAt)';
}


}

/// @nodoc
abstract mixin class $AdminAlertCopyWith<$Res>  {
  factory $AdminAlertCopyWith(AdminAlert value, $Res Function(AdminAlert) _then) = _$AdminAlertCopyWithImpl;
@useResult
$Res call({
 String id, AlertType type, String doctorId, String doctorName, String title, String message, String triggerValue, String threshold, DateTime createdAt, bool isRead, DateTime? resolvedAt
});




}
/// @nodoc
class _$AdminAlertCopyWithImpl<$Res>
    implements $AdminAlertCopyWith<$Res> {
  _$AdminAlertCopyWithImpl(this._self, this._then);

  final AdminAlert _self;
  final $Res Function(AdminAlert) _then;

/// Create a copy of AdminAlert
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? doctorId = null,Object? doctorName = null,Object? title = null,Object? message = null,Object? triggerValue = null,Object? threshold = null,Object? createdAt = null,Object? isRead = null,Object? resolvedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AlertType,doctorId: null == doctorId ? _self.doctorId : doctorId // ignore: cast_nullable_to_non_nullable
as String,doctorName: null == doctorName ? _self.doctorName : doctorName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,triggerValue: null == triggerValue ? _self.triggerValue : triggerValue // ignore: cast_nullable_to_non_nullable
as String,threshold: null == threshold ? _self.threshold : threshold // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminAlert].
extension AdminAlertPatterns on AdminAlert {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminAlert value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminAlert() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminAlert value)  $default,){
final _that = this;
switch (_that) {
case _AdminAlert():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminAlert value)?  $default,){
final _that = this;
switch (_that) {
case _AdminAlert() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  AlertType type,  String doctorId,  String doctorName,  String title,  String message,  String triggerValue,  String threshold,  DateTime createdAt,  bool isRead,  DateTime? resolvedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminAlert() when $default != null:
return $default(_that.id,_that.type,_that.doctorId,_that.doctorName,_that.title,_that.message,_that.triggerValue,_that.threshold,_that.createdAt,_that.isRead,_that.resolvedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  AlertType type,  String doctorId,  String doctorName,  String title,  String message,  String triggerValue,  String threshold,  DateTime createdAt,  bool isRead,  DateTime? resolvedAt)  $default,) {final _that = this;
switch (_that) {
case _AdminAlert():
return $default(_that.id,_that.type,_that.doctorId,_that.doctorName,_that.title,_that.message,_that.triggerValue,_that.threshold,_that.createdAt,_that.isRead,_that.resolvedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  AlertType type,  String doctorId,  String doctorName,  String title,  String message,  String triggerValue,  String threshold,  DateTime createdAt,  bool isRead,  DateTime? resolvedAt)?  $default,) {final _that = this;
switch (_that) {
case _AdminAlert() when $default != null:
return $default(_that.id,_that.type,_that.doctorId,_that.doctorName,_that.title,_that.message,_that.triggerValue,_that.threshold,_that.createdAt,_that.isRead,_that.resolvedAt);case _:
  return null;

}
}

}

/// @nodoc


class _AdminAlert implements AdminAlert {
  const _AdminAlert({required this.id, required this.type, required this.doctorId, required this.doctorName, required this.title, required this.message, required this.triggerValue, required this.threshold, required this.createdAt, this.isRead = false, this.resolvedAt});
  

// ── required ───────────────────────────────────────────────────────────
@override final  String id;
@override final  AlertType type;
@override final  String doctorId;
@override final  String doctorName;
@override final  String title;
@override final  String message;
/// القيمة التي أطلقت التنبيه (مثل: "5200 SAR"، "65%"، "12 يوماً")
@override final  String triggerValue;
/// الحد المضبوط في admin_settings/alert_thresholds
@override final  String threshold;
@override final  DateTime createdAt;
// ── optional / defaulted ───────────────────────────────────────────────
@override@JsonKey() final  bool isRead;
@override final  DateTime? resolvedAt;

/// Create a copy of AdminAlert
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminAlertCopyWith<_AdminAlert> get copyWith => __$AdminAlertCopyWithImpl<_AdminAlert>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminAlert&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.doctorId, doctorId) || other.doctorId == doctorId)&&(identical(other.doctorName, doctorName) || other.doctorName == doctorName)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.triggerValue, triggerValue) || other.triggerValue == triggerValue)&&(identical(other.threshold, threshold) || other.threshold == threshold)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,doctorId,doctorName,title,message,triggerValue,threshold,createdAt,isRead,resolvedAt);

@override
String toString() {
  return 'AdminAlert(id: $id, type: $type, doctorId: $doctorId, doctorName: $doctorName, title: $title, message: $message, triggerValue: $triggerValue, threshold: $threshold, createdAt: $createdAt, isRead: $isRead, resolvedAt: $resolvedAt)';
}


}

/// @nodoc
abstract mixin class _$AdminAlertCopyWith<$Res> implements $AdminAlertCopyWith<$Res> {
  factory _$AdminAlertCopyWith(_AdminAlert value, $Res Function(_AdminAlert) _then) = __$AdminAlertCopyWithImpl;
@override @useResult
$Res call({
 String id, AlertType type, String doctorId, String doctorName, String title, String message, String triggerValue, String threshold, DateTime createdAt, bool isRead, DateTime? resolvedAt
});




}
/// @nodoc
class __$AdminAlertCopyWithImpl<$Res>
    implements _$AdminAlertCopyWith<$Res> {
  __$AdminAlertCopyWithImpl(this._self, this._then);

  final _AdminAlert _self;
  final $Res Function(_AdminAlert) _then;

/// Create a copy of AdminAlert
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? doctorId = null,Object? doctorName = null,Object? title = null,Object? message = null,Object? triggerValue = null,Object? threshold = null,Object? createdAt = null,Object? isRead = null,Object? resolvedAt = freezed,}) {
  return _then(_AdminAlert(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AlertType,doctorId: null == doctorId ? _self.doctorId : doctorId // ignore: cast_nullable_to_non_nullable
as String,doctorName: null == doctorName ? _self.doctorName : doctorName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,triggerValue: null == triggerValue ? _self.triggerValue : triggerValue // ignore: cast_nullable_to_non_nullable
as String,threshold: null == threshold ? _self.threshold : threshold // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
