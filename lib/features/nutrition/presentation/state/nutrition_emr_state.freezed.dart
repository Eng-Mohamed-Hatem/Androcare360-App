// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nutrition_emr_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NutritionEMRState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NutritionEMRState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NutritionEMRState()';
}


}

/// @nodoc
class $NutritionEMRStateCopyWith<$Res>  {
$NutritionEMRStateCopyWith(NutritionEMRState _, $Res Function(NutritionEMRState) __);
}


/// Adds pattern-matching-related methods to [NutritionEMRState].
extension NutritionEMRStatePatterns on NutritionEMRState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Loading value)?  loading,TResult Function( _Loaded value)?  loaded,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Loading value)  loading,required TResult Function( _Loaded value)  loaded,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Loading():
return loading(_that);case _Loaded():
return loaded(_that);case _Error():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Loading value)?  loading,TResult? Function( _Loaded value)?  loaded,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( NutritionEMREntity emr,  Set<String> dirtyFields,  DateTime? lastSavedAt,  bool isSaving,  String? saveError,  String? lastOperationType)?  loaded,TResult Function( String message,  bool canRetry)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.emr,_that.dirtyFields,_that.lastSavedAt,_that.isSaving,_that.saveError,_that.lastOperationType);case _Error() when error != null:
return error(_that.message,_that.canRetry);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( NutritionEMREntity emr,  Set<String> dirtyFields,  DateTime? lastSavedAt,  bool isSaving,  String? saveError,  String? lastOperationType)  loaded,required TResult Function( String message,  bool canRetry)  error,}) {final _that = this;
switch (_that) {
case _Loading():
return loading();case _Loaded():
return loaded(_that.emr,_that.dirtyFields,_that.lastSavedAt,_that.isSaving,_that.saveError,_that.lastOperationType);case _Error():
return error(_that.message,_that.canRetry);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( NutritionEMREntity emr,  Set<String> dirtyFields,  DateTime? lastSavedAt,  bool isSaving,  String? saveError,  String? lastOperationType)?  loaded,TResult? Function( String message,  bool canRetry)?  error,}) {final _that = this;
switch (_that) {
case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.emr,_that.dirtyFields,_that.lastSavedAt,_that.isSaving,_that.saveError,_that.lastOperationType);case _Error() when error != null:
return error(_that.message,_that.canRetry);case _:
  return null;

}
}

}

/// @nodoc


class _Loading extends NutritionEMRState {
  const _Loading(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NutritionEMRState.loading()';
}


}




/// @nodoc


class _Loaded extends NutritionEMRState {
  const _Loaded({required this.emr, final  Set<String> dirtyFields = const {}, this.lastSavedAt, this.isSaving = false, this.saveError, this.lastOperationType}): _dirtyFields = dirtyFields,super._();
  

 final  NutritionEMREntity emr;
 final  Set<String> _dirtyFields;
@JsonKey() Set<String> get dirtyFields {
  if (_dirtyFields is EqualUnmodifiableSetView) return _dirtyFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_dirtyFields);
}

 final  DateTime? lastSavedAt;
@JsonKey() final  bool isSaving;
 final  String? saveError;
/// ✅ FIX: Track last operation type for success messages
/// Values: 'created', 'updated', null
 final  String? lastOperationType;

/// Create a copy of NutritionEMRState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loaded&&(identical(other.emr, emr) || other.emr == emr)&&const DeepCollectionEquality().equals(other._dirtyFields, _dirtyFields)&&(identical(other.lastSavedAt, lastSavedAt) || other.lastSavedAt == lastSavedAt)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.saveError, saveError) || other.saveError == saveError)&&(identical(other.lastOperationType, lastOperationType) || other.lastOperationType == lastOperationType));
}


@override
int get hashCode => Object.hash(runtimeType,emr,const DeepCollectionEquality().hash(_dirtyFields),lastSavedAt,isSaving,saveError,lastOperationType);

@override
String toString() {
  return 'NutritionEMRState.loaded(emr: $emr, dirtyFields: $dirtyFields, lastSavedAt: $lastSavedAt, isSaving: $isSaving, saveError: $saveError, lastOperationType: $lastOperationType)';
}


}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $NutritionEMRStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 NutritionEMREntity emr, Set<String> dirtyFields, DateTime? lastSavedAt, bool isSaving, String? saveError, String? lastOperationType
});


$NutritionEMREntityCopyWith<$Res> get emr;

}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of NutritionEMRState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? emr = null,Object? dirtyFields = null,Object? lastSavedAt = freezed,Object? isSaving = null,Object? saveError = freezed,Object? lastOperationType = freezed,}) {
  return _then(_Loaded(
emr: null == emr ? _self.emr : emr // ignore: cast_nullable_to_non_nullable
as NutritionEMREntity,dirtyFields: null == dirtyFields ? _self._dirtyFields : dirtyFields // ignore: cast_nullable_to_non_nullable
as Set<String>,lastSavedAt: freezed == lastSavedAt ? _self.lastSavedAt : lastSavedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,saveError: freezed == saveError ? _self.saveError : saveError // ignore: cast_nullable_to_non_nullable
as String?,lastOperationType: freezed == lastOperationType ? _self.lastOperationType : lastOperationType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of NutritionEMRState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionEMREntityCopyWith<$Res> get emr {
  
  return $NutritionEMREntityCopyWith<$Res>(_self.emr, (value) {
    return _then(_self.copyWith(emr: value));
  });
}
}

/// @nodoc


class _Error extends NutritionEMRState {
  const _Error({required this.message, this.canRetry = true}): super._();
  

 final  String message;
@JsonKey() final  bool canRetry;

/// Create a copy of NutritionEMRState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message)&&(identical(other.canRetry, canRetry) || other.canRetry == canRetry));
}


@override
int get hashCode => Object.hash(runtimeType,message,canRetry);

@override
String toString() {
  return 'NutritionEMRState.error(message: $message, canRetry: $canRetry)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $NutritionEMRStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message, bool canRetry
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of NutritionEMRState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? canRetry = null,}) {
  return _then(_Error(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,canRetry: null == canRetry ? _self.canRetry : canRetry // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
