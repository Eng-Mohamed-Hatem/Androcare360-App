// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patient_package.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PatientPackage implements DiagnosticableTreeMixin {

 String get id; String get patientId; String get packageType; List<PackageService> get services; List<PackageServiceUsage> get servicesUsage; int get usedServicesCount; List<PackageDocument> get documents; DateTime get createdAt; DateTime get updatedAt; bool get isActive; String? get notes;
/// Create a copy of PatientPackage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PatientPackageCopyWith<PatientPackage> get copyWith => _$PatientPackageCopyWithImpl<PatientPackage>(this as PatientPackage, _$identity);

  /// Serializes this PatientPackage to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'PatientPackage'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('patientId', patientId))..add(DiagnosticsProperty('packageType', packageType))..add(DiagnosticsProperty('services', services))..add(DiagnosticsProperty('servicesUsage', servicesUsage))..add(DiagnosticsProperty('usedServicesCount', usedServicesCount))..add(DiagnosticsProperty('documents', documents))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('updatedAt', updatedAt))..add(DiagnosticsProperty('isActive', isActive))..add(DiagnosticsProperty('notes', notes));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PatientPackage&&(identical(other.id, id) || other.id == id)&&(identical(other.patientId, patientId) || other.patientId == patientId)&&(identical(other.packageType, packageType) || other.packageType == packageType)&&const DeepCollectionEquality().equals(other.services, services)&&const DeepCollectionEquality().equals(other.servicesUsage, servicesUsage)&&(identical(other.usedServicesCount, usedServicesCount) || other.usedServicesCount == usedServicesCount)&&const DeepCollectionEquality().equals(other.documents, documents)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,patientId,packageType,const DeepCollectionEquality().hash(services),const DeepCollectionEquality().hash(servicesUsage),usedServicesCount,const DeepCollectionEquality().hash(documents),createdAt,updatedAt,isActive,notes);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'PatientPackage(id: $id, patientId: $patientId, packageType: $packageType, services: $services, servicesUsage: $servicesUsage, usedServicesCount: $usedServicesCount, documents: $documents, createdAt: $createdAt, updatedAt: $updatedAt, isActive: $isActive, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $PatientPackageCopyWith<$Res>  {
  factory $PatientPackageCopyWith(PatientPackage value, $Res Function(PatientPackage) _then) = _$PatientPackageCopyWithImpl;
@useResult
$Res call({
 String id, String patientId, String packageType, List<PackageService> services, List<PackageServiceUsage> servicesUsage, int usedServicesCount, List<PackageDocument> documents, DateTime createdAt, DateTime updatedAt, bool isActive, String? notes
});




}
/// @nodoc
class _$PatientPackageCopyWithImpl<$Res>
    implements $PatientPackageCopyWith<$Res> {
  _$PatientPackageCopyWithImpl(this._self, this._then);

  final PatientPackage _self;
  final $Res Function(PatientPackage) _then;

/// Create a copy of PatientPackage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? patientId = null,Object? packageType = null,Object? services = null,Object? servicesUsage = null,Object? usedServicesCount = null,Object? documents = null,Object? createdAt = null,Object? updatedAt = null,Object? isActive = null,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,packageType: null == packageType ? _self.packageType : packageType // ignore: cast_nullable_to_non_nullable
as String,services: null == services ? _self.services : services // ignore: cast_nullable_to_non_nullable
as List<PackageService>,servicesUsage: null == servicesUsage ? _self.servicesUsage : servicesUsage // ignore: cast_nullable_to_non_nullable
as List<PackageServiceUsage>,usedServicesCount: null == usedServicesCount ? _self.usedServicesCount : usedServicesCount // ignore: cast_nullable_to_non_nullable
as int,documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<PackageDocument>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PatientPackage].
extension PatientPackagePatterns on PatientPackage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PatientPackage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PatientPackage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PatientPackage value)  $default,){
final _that = this;
switch (_that) {
case _PatientPackage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PatientPackage value)?  $default,){
final _that = this;
switch (_that) {
case _PatientPackage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String patientId,  String packageType,  List<PackageService> services,  List<PackageServiceUsage> servicesUsage,  int usedServicesCount,  List<PackageDocument> documents,  DateTime createdAt,  DateTime updatedAt,  bool isActive,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PatientPackage() when $default != null:
return $default(_that.id,_that.patientId,_that.packageType,_that.services,_that.servicesUsage,_that.usedServicesCount,_that.documents,_that.createdAt,_that.updatedAt,_that.isActive,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String patientId,  String packageType,  List<PackageService> services,  List<PackageServiceUsage> servicesUsage,  int usedServicesCount,  List<PackageDocument> documents,  DateTime createdAt,  DateTime updatedAt,  bool isActive,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _PatientPackage():
return $default(_that.id,_that.patientId,_that.packageType,_that.services,_that.servicesUsage,_that.usedServicesCount,_that.documents,_that.createdAt,_that.updatedAt,_that.isActive,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String patientId,  String packageType,  List<PackageService> services,  List<PackageServiceUsage> servicesUsage,  int usedServicesCount,  List<PackageDocument> documents,  DateTime createdAt,  DateTime updatedAt,  bool isActive,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _PatientPackage() when $default != null:
return $default(_that.id,_that.patientId,_that.packageType,_that.services,_that.servicesUsage,_that.usedServicesCount,_that.documents,_that.createdAt,_that.updatedAt,_that.isActive,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PatientPackage extends PatientPackage with DiagnosticableTreeMixin {
  const _PatientPackage({required this.id, required this.patientId, required this.packageType, required final  List<PackageService> services, required final  List<PackageServiceUsage> servicesUsage, required this.usedServicesCount, required final  List<PackageDocument> documents, required this.createdAt, required this.updatedAt, required this.isActive, this.notes}): _services = services,_servicesUsage = servicesUsage,_documents = documents,super._();
  factory _PatientPackage.fromJson(Map<String, dynamic> json) => _$PatientPackageFromJson(json);

@override final  String id;
@override final  String patientId;
@override final  String packageType;
 final  List<PackageService> _services;
@override List<PackageService> get services {
  if (_services is EqualUnmodifiableListView) return _services;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_services);
}

 final  List<PackageServiceUsage> _servicesUsage;
@override List<PackageServiceUsage> get servicesUsage {
  if (_servicesUsage is EqualUnmodifiableListView) return _servicesUsage;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_servicesUsage);
}

@override final  int usedServicesCount;
 final  List<PackageDocument> _documents;
@override List<PackageDocument> get documents {
  if (_documents is EqualUnmodifiableListView) return _documents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_documents);
}

@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  bool isActive;
@override final  String? notes;

/// Create a copy of PatientPackage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PatientPackageCopyWith<_PatientPackage> get copyWith => __$PatientPackageCopyWithImpl<_PatientPackage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PatientPackageToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'PatientPackage'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('patientId', patientId))..add(DiagnosticsProperty('packageType', packageType))..add(DiagnosticsProperty('services', services))..add(DiagnosticsProperty('servicesUsage', servicesUsage))..add(DiagnosticsProperty('usedServicesCount', usedServicesCount))..add(DiagnosticsProperty('documents', documents))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('updatedAt', updatedAt))..add(DiagnosticsProperty('isActive', isActive))..add(DiagnosticsProperty('notes', notes));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PatientPackage&&(identical(other.id, id) || other.id == id)&&(identical(other.patientId, patientId) || other.patientId == patientId)&&(identical(other.packageType, packageType) || other.packageType == packageType)&&const DeepCollectionEquality().equals(other._services, _services)&&const DeepCollectionEquality().equals(other._servicesUsage, _servicesUsage)&&(identical(other.usedServicesCount, usedServicesCount) || other.usedServicesCount == usedServicesCount)&&const DeepCollectionEquality().equals(other._documents, _documents)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,patientId,packageType,const DeepCollectionEquality().hash(_services),const DeepCollectionEquality().hash(_servicesUsage),usedServicesCount,const DeepCollectionEquality().hash(_documents),createdAt,updatedAt,isActive,notes);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'PatientPackage(id: $id, patientId: $patientId, packageType: $packageType, services: $services, servicesUsage: $servicesUsage, usedServicesCount: $usedServicesCount, documents: $documents, createdAt: $createdAt, updatedAt: $updatedAt, isActive: $isActive, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$PatientPackageCopyWith<$Res> implements $PatientPackageCopyWith<$Res> {
  factory _$PatientPackageCopyWith(_PatientPackage value, $Res Function(_PatientPackage) _then) = __$PatientPackageCopyWithImpl;
@override @useResult
$Res call({
 String id, String patientId, String packageType, List<PackageService> services, List<PackageServiceUsage> servicesUsage, int usedServicesCount, List<PackageDocument> documents, DateTime createdAt, DateTime updatedAt, bool isActive, String? notes
});




}
/// @nodoc
class __$PatientPackageCopyWithImpl<$Res>
    implements _$PatientPackageCopyWith<$Res> {
  __$PatientPackageCopyWithImpl(this._self, this._then);

  final _PatientPackage _self;
  final $Res Function(_PatientPackage) _then;

/// Create a copy of PatientPackage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? patientId = null,Object? packageType = null,Object? services = null,Object? servicesUsage = null,Object? usedServicesCount = null,Object? documents = null,Object? createdAt = null,Object? updatedAt = null,Object? isActive = null,Object? notes = freezed,}) {
  return _then(_PatientPackage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,packageType: null == packageType ? _self.packageType : packageType // ignore: cast_nullable_to_non_nullable
as String,services: null == services ? _self._services : services // ignore: cast_nullable_to_non_nullable
as List<PackageService>,servicesUsage: null == servicesUsage ? _self._servicesUsage : servicesUsage // ignore: cast_nullable_to_non_nullable
as List<PackageServiceUsage>,usedServicesCount: null == usedServicesCount ? _self.usedServicesCount : usedServicesCount // ignore: cast_nullable_to_non_nullable
as int,documents: null == documents ? _self._documents : documents // ignore: cast_nullable_to_non_nullable
as List<PackageDocument>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
