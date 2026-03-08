// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'package_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PackageDocument {

 String get id; String get documentUrl; String get fileName; String get mimeType; int get fileSize; String get uploadedBy; DateTime get uploadedAt; String? get note;
/// Create a copy of PackageDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackageDocumentCopyWith<PackageDocument> get copyWith => _$PackageDocumentCopyWithImpl<PackageDocument>(this as PackageDocument, _$identity);

  /// Serializes this PackageDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackageDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.documentUrl, documentUrl) || other.documentUrl == documentUrl)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.uploadedBy, uploadedBy) || other.uploadedBy == uploadedBy)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,documentUrl,fileName,mimeType,fileSize,uploadedBy,uploadedAt,note);

@override
String toString() {
  return 'PackageDocument(id: $id, documentUrl: $documentUrl, fileName: $fileName, mimeType: $mimeType, fileSize: $fileSize, uploadedBy: $uploadedBy, uploadedAt: $uploadedAt, note: $note)';
}


}

/// @nodoc
abstract mixin class $PackageDocumentCopyWith<$Res>  {
  factory $PackageDocumentCopyWith(PackageDocument value, $Res Function(PackageDocument) _then) = _$PackageDocumentCopyWithImpl;
@useResult
$Res call({
 String id, String documentUrl, String fileName, String mimeType, int fileSize, String uploadedBy, DateTime uploadedAt, String? note
});




}
/// @nodoc
class _$PackageDocumentCopyWithImpl<$Res>
    implements $PackageDocumentCopyWith<$Res> {
  _$PackageDocumentCopyWithImpl(this._self, this._then);

  final PackageDocument _self;
  final $Res Function(PackageDocument) _then;

/// Create a copy of PackageDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? documentUrl = null,Object? fileName = null,Object? mimeType = null,Object? fileSize = null,Object? uploadedBy = null,Object? uploadedAt = null,Object? note = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,documentUrl: null == documentUrl ? _self.documentUrl : documentUrl // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,uploadedBy: null == uploadedBy ? _self.uploadedBy : uploadedBy // ignore: cast_nullable_to_non_nullable
as String,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PackageDocument].
extension PackageDocumentPatterns on PackageDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackageDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackageDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackageDocument value)  $default,){
final _that = this;
switch (_that) {
case _PackageDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackageDocument value)?  $default,){
final _that = this;
switch (_that) {
case _PackageDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String documentUrl,  String fileName,  String mimeType,  int fileSize,  String uploadedBy,  DateTime uploadedAt,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackageDocument() when $default != null:
return $default(_that.id,_that.documentUrl,_that.fileName,_that.mimeType,_that.fileSize,_that.uploadedBy,_that.uploadedAt,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String documentUrl,  String fileName,  String mimeType,  int fileSize,  String uploadedBy,  DateTime uploadedAt,  String? note)  $default,) {final _that = this;
switch (_that) {
case _PackageDocument():
return $default(_that.id,_that.documentUrl,_that.fileName,_that.mimeType,_that.fileSize,_that.uploadedBy,_that.uploadedAt,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String documentUrl,  String fileName,  String mimeType,  int fileSize,  String uploadedBy,  DateTime uploadedAt,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _PackageDocument() when $default != null:
return $default(_that.id,_that.documentUrl,_that.fileName,_that.mimeType,_that.fileSize,_that.uploadedBy,_that.uploadedAt,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PackageDocument extends PackageDocument {
  const _PackageDocument({required this.id, required this.documentUrl, required this.fileName, required this.mimeType, required this.fileSize, required this.uploadedBy, required this.uploadedAt, this.note}): super._();
  factory _PackageDocument.fromJson(Map<String, dynamic> json) => _$PackageDocumentFromJson(json);

@override final  String id;
@override final  String documentUrl;
@override final  String fileName;
@override final  String mimeType;
@override final  int fileSize;
@override final  String uploadedBy;
@override final  DateTime uploadedAt;
@override final  String? note;

/// Create a copy of PackageDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackageDocumentCopyWith<_PackageDocument> get copyWith => __$PackageDocumentCopyWithImpl<_PackageDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackageDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackageDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.documentUrl, documentUrl) || other.documentUrl == documentUrl)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.uploadedBy, uploadedBy) || other.uploadedBy == uploadedBy)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,documentUrl,fileName,mimeType,fileSize,uploadedBy,uploadedAt,note);

@override
String toString() {
  return 'PackageDocument(id: $id, documentUrl: $documentUrl, fileName: $fileName, mimeType: $mimeType, fileSize: $fileSize, uploadedBy: $uploadedBy, uploadedAt: $uploadedAt, note: $note)';
}


}

/// @nodoc
abstract mixin class _$PackageDocumentCopyWith<$Res> implements $PackageDocumentCopyWith<$Res> {
  factory _$PackageDocumentCopyWith(_PackageDocument value, $Res Function(_PackageDocument) _then) = __$PackageDocumentCopyWithImpl;
@override @useResult
$Res call({
 String id, String documentUrl, String fileName, String mimeType, int fileSize, String uploadedBy, DateTime uploadedAt, String? note
});




}
/// @nodoc
class __$PackageDocumentCopyWithImpl<$Res>
    implements _$PackageDocumentCopyWith<$Res> {
  __$PackageDocumentCopyWithImpl(this._self, this._then);

  final _PackageDocument _self;
  final $Res Function(_PackageDocument) _then;

/// Create a copy of PackageDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? documentUrl = null,Object? fileName = null,Object? mimeType = null,Object? fileSize = null,Object? uploadedBy = null,Object? uploadedAt = null,Object? note = freezed,}) {
  return _then(_PackageDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,documentUrl: null == documentUrl ? _self.documentUrl : documentUrl // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,uploadedBy: null == uploadedBy ? _self.uploadedBy : uploadedBy // ignore: cast_nullable_to_non_nullable
as String,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
