// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnalyticsFilters {

 DateTime get periodStart; DateTime get periodEnd; String get sortBy; String get sortOrder; String get statusFilter; String? get specialtyFilter; String? get searchQuery;
/// Create a copy of AnalyticsFilters
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsFiltersCopyWith<AnalyticsFilters> get copyWith => _$AnalyticsFiltersCopyWithImpl<AnalyticsFilters>(this as AnalyticsFilters, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsFilters&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.statusFilter, statusFilter) || other.statusFilter == statusFilter)&&(identical(other.specialtyFilter, specialtyFilter) || other.specialtyFilter == specialtyFilter)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery));
}


@override
int get hashCode => Object.hash(runtimeType,periodStart,periodEnd,sortBy,sortOrder,statusFilter,specialtyFilter,searchQuery);

@override
String toString() {
  return 'AnalyticsFilters(periodStart: $periodStart, periodEnd: $periodEnd, sortBy: $sortBy, sortOrder: $sortOrder, statusFilter: $statusFilter, specialtyFilter: $specialtyFilter, searchQuery: $searchQuery)';
}


}

/// @nodoc
abstract mixin class $AnalyticsFiltersCopyWith<$Res>  {
  factory $AnalyticsFiltersCopyWith(AnalyticsFilters value, $Res Function(AnalyticsFilters) _then) = _$AnalyticsFiltersCopyWithImpl;
@useResult
$Res call({
 DateTime periodStart, DateTime periodEnd, String sortBy, String sortOrder, String statusFilter, String? specialtyFilter, String? searchQuery
});




}
/// @nodoc
class _$AnalyticsFiltersCopyWithImpl<$Res>
    implements $AnalyticsFiltersCopyWith<$Res> {
  _$AnalyticsFiltersCopyWithImpl(this._self, this._then);

  final AnalyticsFilters _self;
  final $Res Function(AnalyticsFilters) _then;

/// Create a copy of AnalyticsFilters
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? periodStart = null,Object? periodEnd = null,Object? sortBy = null,Object? sortOrder = null,Object? statusFilter = null,Object? specialtyFilter = freezed,Object? searchQuery = freezed,}) {
  return _then(_self.copyWith(
periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as String,statusFilter: null == statusFilter ? _self.statusFilter : statusFilter // ignore: cast_nullable_to_non_nullable
as String,specialtyFilter: freezed == specialtyFilter ? _self.specialtyFilter : specialtyFilter // ignore: cast_nullable_to_non_nullable
as String?,searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalyticsFilters].
extension AnalyticsFiltersPatterns on AnalyticsFilters {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsFilters value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsFilters() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsFilters value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsFilters():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsFilters value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsFilters() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime periodStart,  DateTime periodEnd,  String sortBy,  String sortOrder,  String statusFilter,  String? specialtyFilter,  String? searchQuery)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsFilters() when $default != null:
return $default(_that.periodStart,_that.periodEnd,_that.sortBy,_that.sortOrder,_that.statusFilter,_that.specialtyFilter,_that.searchQuery);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime periodStart,  DateTime periodEnd,  String sortBy,  String sortOrder,  String statusFilter,  String? specialtyFilter,  String? searchQuery)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsFilters():
return $default(_that.periodStart,_that.periodEnd,_that.sortBy,_that.sortOrder,_that.statusFilter,_that.specialtyFilter,_that.searchQuery);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime periodStart,  DateTime periodEnd,  String sortBy,  String sortOrder,  String statusFilter,  String? specialtyFilter,  String? searchQuery)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsFilters() when $default != null:
return $default(_that.periodStart,_that.periodEnd,_that.sortBy,_that.sortOrder,_that.statusFilter,_that.specialtyFilter,_that.searchQuery);case _:
  return null;

}
}

}

/// @nodoc


class _AnalyticsFilters implements AnalyticsFilters {
  const _AnalyticsFilters({required this.periodStart, required this.periodEnd, required this.sortBy, required this.sortOrder, this.statusFilter = 'all', this.specialtyFilter, this.searchQuery});
  

@override final  DateTime periodStart;
@override final  DateTime periodEnd;
@override final  String sortBy;
@override final  String sortOrder;
@override@JsonKey() final  String statusFilter;
@override final  String? specialtyFilter;
@override final  String? searchQuery;

/// Create a copy of AnalyticsFilters
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsFiltersCopyWith<_AnalyticsFilters> get copyWith => __$AnalyticsFiltersCopyWithImpl<_AnalyticsFilters>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsFilters&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.statusFilter, statusFilter) || other.statusFilter == statusFilter)&&(identical(other.specialtyFilter, specialtyFilter) || other.specialtyFilter == specialtyFilter)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery));
}


@override
int get hashCode => Object.hash(runtimeType,periodStart,periodEnd,sortBy,sortOrder,statusFilter,specialtyFilter,searchQuery);

@override
String toString() {
  return 'AnalyticsFilters(periodStart: $periodStart, periodEnd: $periodEnd, sortBy: $sortBy, sortOrder: $sortOrder, statusFilter: $statusFilter, specialtyFilter: $specialtyFilter, searchQuery: $searchQuery)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsFiltersCopyWith<$Res> implements $AnalyticsFiltersCopyWith<$Res> {
  factory _$AnalyticsFiltersCopyWith(_AnalyticsFilters value, $Res Function(_AnalyticsFilters) _then) = __$AnalyticsFiltersCopyWithImpl;
@override @useResult
$Res call({
 DateTime periodStart, DateTime periodEnd, String sortBy, String sortOrder, String statusFilter, String? specialtyFilter, String? searchQuery
});




}
/// @nodoc
class __$AnalyticsFiltersCopyWithImpl<$Res>
    implements _$AnalyticsFiltersCopyWith<$Res> {
  __$AnalyticsFiltersCopyWithImpl(this._self, this._then);

  final _AnalyticsFilters _self;
  final $Res Function(_AnalyticsFilters) _then;

/// Create a copy of AnalyticsFilters
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? periodStart = null,Object? periodEnd = null,Object? sortBy = null,Object? sortOrder = null,Object? statusFilter = null,Object? specialtyFilter = freezed,Object? searchQuery = freezed,}) {
  return _then(_AnalyticsFilters(
periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as String,statusFilter: null == statusFilter ? _self.statusFilter : statusFilter // ignore: cast_nullable_to_non_nullable
as String,specialtyFilter: freezed == specialtyFilter ? _self.specialtyFilter : specialtyFilter // ignore: cast_nullable_to_non_nullable
as String?,searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$AnalyticsState {

 AnalyticsFilters get filters; List<DoctorAnalytics> get doctors; bool get isLoading; bool get hasMore; bool get hasStaleData; PlatformSummary? get platformSummary; String? get error; String? get nextCursor;
/// Create a copy of AnalyticsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsStateCopyWith<AnalyticsState> get copyWith => _$AnalyticsStateCopyWithImpl<AnalyticsState>(this as AnalyticsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsState&&(identical(other.filters, filters) || other.filters == filters)&&const DeepCollectionEquality().equals(other.doctors, doctors)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.hasStaleData, hasStaleData) || other.hasStaleData == hasStaleData)&&(identical(other.platformSummary, platformSummary) || other.platformSummary == platformSummary)&&(identical(other.error, error) || other.error == error)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}


@override
int get hashCode => Object.hash(runtimeType,filters,const DeepCollectionEquality().hash(doctors),isLoading,hasMore,hasStaleData,platformSummary,error,nextCursor);

@override
String toString() {
  return 'AnalyticsState(filters: $filters, doctors: $doctors, isLoading: $isLoading, hasMore: $hasMore, hasStaleData: $hasStaleData, platformSummary: $platformSummary, error: $error, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class $AnalyticsStateCopyWith<$Res>  {
  factory $AnalyticsStateCopyWith(AnalyticsState value, $Res Function(AnalyticsState) _then) = _$AnalyticsStateCopyWithImpl;
@useResult
$Res call({
 AnalyticsFilters filters, List<DoctorAnalytics> doctors, bool isLoading, bool hasMore, bool hasStaleData, PlatformSummary? platformSummary, String? error, String? nextCursor
});


$AnalyticsFiltersCopyWith<$Res> get filters;$PlatformSummaryCopyWith<$Res>? get platformSummary;

}
/// @nodoc
class _$AnalyticsStateCopyWithImpl<$Res>
    implements $AnalyticsStateCopyWith<$Res> {
  _$AnalyticsStateCopyWithImpl(this._self, this._then);

  final AnalyticsState _self;
  final $Res Function(AnalyticsState) _then;

/// Create a copy of AnalyticsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? filters = null,Object? doctors = null,Object? isLoading = null,Object? hasMore = null,Object? hasStaleData = null,Object? platformSummary = freezed,Object? error = freezed,Object? nextCursor = freezed,}) {
  return _then(_self.copyWith(
filters: null == filters ? _self.filters : filters // ignore: cast_nullable_to_non_nullable
as AnalyticsFilters,doctors: null == doctors ? _self.doctors : doctors // ignore: cast_nullable_to_non_nullable
as List<DoctorAnalytics>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,hasStaleData: null == hasStaleData ? _self.hasStaleData : hasStaleData // ignore: cast_nullable_to_non_nullable
as bool,platformSummary: freezed == platformSummary ? _self.platformSummary : platformSummary // ignore: cast_nullable_to_non_nullable
as PlatformSummary?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of AnalyticsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsFiltersCopyWith<$Res> get filters {
  
  return $AnalyticsFiltersCopyWith<$Res>(_self.filters, (value) {
    return _then(_self.copyWith(filters: value));
  });
}/// Create a copy of AnalyticsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlatformSummaryCopyWith<$Res>? get platformSummary {
    if (_self.platformSummary == null) {
    return null;
  }

  return $PlatformSummaryCopyWith<$Res>(_self.platformSummary!, (value) {
    return _then(_self.copyWith(platformSummary: value));
  });
}
}


/// Adds pattern-matching-related methods to [AnalyticsState].
extension AnalyticsStatePatterns on AnalyticsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsState value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsState value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AnalyticsFilters filters,  List<DoctorAnalytics> doctors,  bool isLoading,  bool hasMore,  bool hasStaleData,  PlatformSummary? platformSummary,  String? error,  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsState() when $default != null:
return $default(_that.filters,_that.doctors,_that.isLoading,_that.hasMore,_that.hasStaleData,_that.platformSummary,_that.error,_that.nextCursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AnalyticsFilters filters,  List<DoctorAnalytics> doctors,  bool isLoading,  bool hasMore,  bool hasStaleData,  PlatformSummary? platformSummary,  String? error,  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsState():
return $default(_that.filters,_that.doctors,_that.isLoading,_that.hasMore,_that.hasStaleData,_that.platformSummary,_that.error,_that.nextCursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AnalyticsFilters filters,  List<DoctorAnalytics> doctors,  bool isLoading,  bool hasMore,  bool hasStaleData,  PlatformSummary? platformSummary,  String? error,  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsState() when $default != null:
return $default(_that.filters,_that.doctors,_that.isLoading,_that.hasMore,_that.hasStaleData,_that.platformSummary,_that.error,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc


class _AnalyticsState implements AnalyticsState {
  const _AnalyticsState({required this.filters, final  List<DoctorAnalytics> doctors = const [], this.isLoading = false, this.hasMore = false, this.hasStaleData = false, this.platformSummary, this.error, this.nextCursor}): _doctors = doctors;
  

@override final  AnalyticsFilters filters;
 final  List<DoctorAnalytics> _doctors;
@override@JsonKey() List<DoctorAnalytics> get doctors {
  if (_doctors is EqualUnmodifiableListView) return _doctors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_doctors);
}

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool hasMore;
@override@JsonKey() final  bool hasStaleData;
@override final  PlatformSummary? platformSummary;
@override final  String? error;
@override final  String? nextCursor;

/// Create a copy of AnalyticsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsStateCopyWith<_AnalyticsState> get copyWith => __$AnalyticsStateCopyWithImpl<_AnalyticsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsState&&(identical(other.filters, filters) || other.filters == filters)&&const DeepCollectionEquality().equals(other._doctors, _doctors)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.hasStaleData, hasStaleData) || other.hasStaleData == hasStaleData)&&(identical(other.platformSummary, platformSummary) || other.platformSummary == platformSummary)&&(identical(other.error, error) || other.error == error)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}


@override
int get hashCode => Object.hash(runtimeType,filters,const DeepCollectionEquality().hash(_doctors),isLoading,hasMore,hasStaleData,platformSummary,error,nextCursor);

@override
String toString() {
  return 'AnalyticsState(filters: $filters, doctors: $doctors, isLoading: $isLoading, hasMore: $hasMore, hasStaleData: $hasStaleData, platformSummary: $platformSummary, error: $error, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsStateCopyWith<$Res> implements $AnalyticsStateCopyWith<$Res> {
  factory _$AnalyticsStateCopyWith(_AnalyticsState value, $Res Function(_AnalyticsState) _then) = __$AnalyticsStateCopyWithImpl;
@override @useResult
$Res call({
 AnalyticsFilters filters, List<DoctorAnalytics> doctors, bool isLoading, bool hasMore, bool hasStaleData, PlatformSummary? platformSummary, String? error, String? nextCursor
});


@override $AnalyticsFiltersCopyWith<$Res> get filters;@override $PlatformSummaryCopyWith<$Res>? get platformSummary;

}
/// @nodoc
class __$AnalyticsStateCopyWithImpl<$Res>
    implements _$AnalyticsStateCopyWith<$Res> {
  __$AnalyticsStateCopyWithImpl(this._self, this._then);

  final _AnalyticsState _self;
  final $Res Function(_AnalyticsState) _then;

/// Create a copy of AnalyticsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? filters = null,Object? doctors = null,Object? isLoading = null,Object? hasMore = null,Object? hasStaleData = null,Object? platformSummary = freezed,Object? error = freezed,Object? nextCursor = freezed,}) {
  return _then(_AnalyticsState(
filters: null == filters ? _self.filters : filters // ignore: cast_nullable_to_non_nullable
as AnalyticsFilters,doctors: null == doctors ? _self._doctors : doctors // ignore: cast_nullable_to_non_nullable
as List<DoctorAnalytics>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,hasStaleData: null == hasStaleData ? _self.hasStaleData : hasStaleData // ignore: cast_nullable_to_non_nullable
as bool,platformSummary: freezed == platformSummary ? _self.platformSummary : platformSummary // ignore: cast_nullable_to_non_nullable
as PlatformSummary?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of AnalyticsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsFiltersCopyWith<$Res> get filters {
  
  return $AnalyticsFiltersCopyWith<$Res>(_self.filters, (value) {
    return _then(_self.copyWith(filters: value));
  });
}/// Create a copy of AnalyticsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlatformSummaryCopyWith<$Res>? get platformSummary {
    if (_self.platformSummary == null) {
    return null;
  }

  return $PlatformSummaryCopyWith<$Res>(_self.platformSummary!, (value) {
    return _then(_self.copyWith(platformSummary: value));
  });
}
}

/// @nodoc
mixin _$FiltersState {

 AnalyticsPeriod get period; String get statusFilter; DateTime? get customStart; DateTime? get customEnd; String? get specialtyFilter; String? get searchQuery;
/// Create a copy of FiltersState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FiltersStateCopyWith<FiltersState> get copyWith => _$FiltersStateCopyWithImpl<FiltersState>(this as FiltersState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FiltersState&&(identical(other.period, period) || other.period == period)&&(identical(other.statusFilter, statusFilter) || other.statusFilter == statusFilter)&&(identical(other.customStart, customStart) || other.customStart == customStart)&&(identical(other.customEnd, customEnd) || other.customEnd == customEnd)&&(identical(other.specialtyFilter, specialtyFilter) || other.specialtyFilter == specialtyFilter)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery));
}


@override
int get hashCode => Object.hash(runtimeType,period,statusFilter,customStart,customEnd,specialtyFilter,searchQuery);

@override
String toString() {
  return 'FiltersState(period: $period, statusFilter: $statusFilter, customStart: $customStart, customEnd: $customEnd, specialtyFilter: $specialtyFilter, searchQuery: $searchQuery)';
}


}

/// @nodoc
abstract mixin class $FiltersStateCopyWith<$Res>  {
  factory $FiltersStateCopyWith(FiltersState value, $Res Function(FiltersState) _then) = _$FiltersStateCopyWithImpl;
@useResult
$Res call({
 AnalyticsPeriod period, String statusFilter, DateTime? customStart, DateTime? customEnd, String? specialtyFilter, String? searchQuery
});




}
/// @nodoc
class _$FiltersStateCopyWithImpl<$Res>
    implements $FiltersStateCopyWith<$Res> {
  _$FiltersStateCopyWithImpl(this._self, this._then);

  final FiltersState _self;
  final $Res Function(FiltersState) _then;

/// Create a copy of FiltersState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? period = null,Object? statusFilter = null,Object? customStart = freezed,Object? customEnd = freezed,Object? specialtyFilter = freezed,Object? searchQuery = freezed,}) {
  return _then(_self.copyWith(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as AnalyticsPeriod,statusFilter: null == statusFilter ? _self.statusFilter : statusFilter // ignore: cast_nullable_to_non_nullable
as String,customStart: freezed == customStart ? _self.customStart : customStart // ignore: cast_nullable_to_non_nullable
as DateTime?,customEnd: freezed == customEnd ? _self.customEnd : customEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,specialtyFilter: freezed == specialtyFilter ? _self.specialtyFilter : specialtyFilter // ignore: cast_nullable_to_non_nullable
as String?,searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FiltersState].
extension FiltersStatePatterns on FiltersState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FiltersState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FiltersState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FiltersState value)  $default,){
final _that = this;
switch (_that) {
case _FiltersState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FiltersState value)?  $default,){
final _that = this;
switch (_that) {
case _FiltersState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AnalyticsPeriod period,  String statusFilter,  DateTime? customStart,  DateTime? customEnd,  String? specialtyFilter,  String? searchQuery)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FiltersState() when $default != null:
return $default(_that.period,_that.statusFilter,_that.customStart,_that.customEnd,_that.specialtyFilter,_that.searchQuery);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AnalyticsPeriod period,  String statusFilter,  DateTime? customStart,  DateTime? customEnd,  String? specialtyFilter,  String? searchQuery)  $default,) {final _that = this;
switch (_that) {
case _FiltersState():
return $default(_that.period,_that.statusFilter,_that.customStart,_that.customEnd,_that.specialtyFilter,_that.searchQuery);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AnalyticsPeriod period,  String statusFilter,  DateTime? customStart,  DateTime? customEnd,  String? specialtyFilter,  String? searchQuery)?  $default,) {final _that = this;
switch (_that) {
case _FiltersState() when $default != null:
return $default(_that.period,_that.statusFilter,_that.customStart,_that.customEnd,_that.specialtyFilter,_that.searchQuery);case _:
  return null;

}
}

}

/// @nodoc


class _FiltersState implements FiltersState {
  const _FiltersState({this.period = AnalyticsPeriod.month, this.statusFilter = 'all', this.customStart, this.customEnd, this.specialtyFilter, this.searchQuery});
  

@override@JsonKey() final  AnalyticsPeriod period;
@override@JsonKey() final  String statusFilter;
@override final  DateTime? customStart;
@override final  DateTime? customEnd;
@override final  String? specialtyFilter;
@override final  String? searchQuery;

/// Create a copy of FiltersState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FiltersStateCopyWith<_FiltersState> get copyWith => __$FiltersStateCopyWithImpl<_FiltersState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FiltersState&&(identical(other.period, period) || other.period == period)&&(identical(other.statusFilter, statusFilter) || other.statusFilter == statusFilter)&&(identical(other.customStart, customStart) || other.customStart == customStart)&&(identical(other.customEnd, customEnd) || other.customEnd == customEnd)&&(identical(other.specialtyFilter, specialtyFilter) || other.specialtyFilter == specialtyFilter)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery));
}


@override
int get hashCode => Object.hash(runtimeType,period,statusFilter,customStart,customEnd,specialtyFilter,searchQuery);

@override
String toString() {
  return 'FiltersState(period: $period, statusFilter: $statusFilter, customStart: $customStart, customEnd: $customEnd, specialtyFilter: $specialtyFilter, searchQuery: $searchQuery)';
}


}

/// @nodoc
abstract mixin class _$FiltersStateCopyWith<$Res> implements $FiltersStateCopyWith<$Res> {
  factory _$FiltersStateCopyWith(_FiltersState value, $Res Function(_FiltersState) _then) = __$FiltersStateCopyWithImpl;
@override @useResult
$Res call({
 AnalyticsPeriod period, String statusFilter, DateTime? customStart, DateTime? customEnd, String? specialtyFilter, String? searchQuery
});




}
/// @nodoc
class __$FiltersStateCopyWithImpl<$Res>
    implements _$FiltersStateCopyWith<$Res> {
  __$FiltersStateCopyWithImpl(this._self, this._then);

  final _FiltersState _self;
  final $Res Function(_FiltersState) _then;

/// Create a copy of FiltersState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? period = null,Object? statusFilter = null,Object? customStart = freezed,Object? customEnd = freezed,Object? specialtyFilter = freezed,Object? searchQuery = freezed,}) {
  return _then(_FiltersState(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as AnalyticsPeriod,statusFilter: null == statusFilter ? _self.statusFilter : statusFilter // ignore: cast_nullable_to_non_nullable
as String,customStart: freezed == customStart ? _self.customStart : customStart // ignore: cast_nullable_to_non_nullable
as DateTime?,customEnd: freezed == customEnd ? _self.customEnd : customEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,specialtyFilter: freezed == specialtyFilter ? _self.specialtyFilter : specialtyFilter // ignore: cast_nullable_to_non_nullable
as String?,searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$AlertsState {

 List<AdminAlert> get alerts; int get unreadCount; bool get isLoading; bool get hasStaleData; String? get error;
/// Create a copy of AlertsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlertsStateCopyWith<AlertsState> get copyWith => _$AlertsStateCopyWithImpl<AlertsState>(this as AlertsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlertsState&&const DeepCollectionEquality().equals(other.alerts, alerts)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.hasStaleData, hasStaleData) || other.hasStaleData == hasStaleData)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(alerts),unreadCount,isLoading,hasStaleData,error);

@override
String toString() {
  return 'AlertsState(alerts: $alerts, unreadCount: $unreadCount, isLoading: $isLoading, hasStaleData: $hasStaleData, error: $error)';
}


}

/// @nodoc
abstract mixin class $AlertsStateCopyWith<$Res>  {
  factory $AlertsStateCopyWith(AlertsState value, $Res Function(AlertsState) _then) = _$AlertsStateCopyWithImpl;
@useResult
$Res call({
 List<AdminAlert> alerts, int unreadCount, bool isLoading, bool hasStaleData, String? error
});




}
/// @nodoc
class _$AlertsStateCopyWithImpl<$Res>
    implements $AlertsStateCopyWith<$Res> {
  _$AlertsStateCopyWithImpl(this._self, this._then);

  final AlertsState _self;
  final $Res Function(AlertsState) _then;

/// Create a copy of AlertsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? alerts = null,Object? unreadCount = null,Object? isLoading = null,Object? hasStaleData = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
alerts: null == alerts ? _self.alerts : alerts // ignore: cast_nullable_to_non_nullable
as List<AdminAlert>,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,hasStaleData: null == hasStaleData ? _self.hasStaleData : hasStaleData // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AlertsState].
extension AlertsStatePatterns on AlertsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AlertsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AlertsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AlertsState value)  $default,){
final _that = this;
switch (_that) {
case _AlertsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AlertsState value)?  $default,){
final _that = this;
switch (_that) {
case _AlertsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AdminAlert> alerts,  int unreadCount,  bool isLoading,  bool hasStaleData,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AlertsState() when $default != null:
return $default(_that.alerts,_that.unreadCount,_that.isLoading,_that.hasStaleData,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AdminAlert> alerts,  int unreadCount,  bool isLoading,  bool hasStaleData,  String? error)  $default,) {final _that = this;
switch (_that) {
case _AlertsState():
return $default(_that.alerts,_that.unreadCount,_that.isLoading,_that.hasStaleData,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AdminAlert> alerts,  int unreadCount,  bool isLoading,  bool hasStaleData,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _AlertsState() when $default != null:
return $default(_that.alerts,_that.unreadCount,_that.isLoading,_that.hasStaleData,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _AlertsState implements AlertsState {
  const _AlertsState({final  List<AdminAlert> alerts = const [], this.unreadCount = 0, this.isLoading = false, this.hasStaleData = false, this.error}): _alerts = alerts;
  

 final  List<AdminAlert> _alerts;
@override@JsonKey() List<AdminAlert> get alerts {
  if (_alerts is EqualUnmodifiableListView) return _alerts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_alerts);
}

@override@JsonKey() final  int unreadCount;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool hasStaleData;
@override final  String? error;

/// Create a copy of AlertsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlertsStateCopyWith<_AlertsState> get copyWith => __$AlertsStateCopyWithImpl<_AlertsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlertsState&&const DeepCollectionEquality().equals(other._alerts, _alerts)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.hasStaleData, hasStaleData) || other.hasStaleData == hasStaleData)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_alerts),unreadCount,isLoading,hasStaleData,error);

@override
String toString() {
  return 'AlertsState(alerts: $alerts, unreadCount: $unreadCount, isLoading: $isLoading, hasStaleData: $hasStaleData, error: $error)';
}


}

/// @nodoc
abstract mixin class _$AlertsStateCopyWith<$Res> implements $AlertsStateCopyWith<$Res> {
  factory _$AlertsStateCopyWith(_AlertsState value, $Res Function(_AlertsState) _then) = __$AlertsStateCopyWithImpl;
@override @useResult
$Res call({
 List<AdminAlert> alerts, int unreadCount, bool isLoading, bool hasStaleData, String? error
});




}
/// @nodoc
class __$AlertsStateCopyWithImpl<$Res>
    implements _$AlertsStateCopyWith<$Res> {
  __$AlertsStateCopyWithImpl(this._self, this._then);

  final _AlertsState _self;
  final $Res Function(_AlertsState) _then;

/// Create a copy of AlertsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? alerts = null,Object? unreadCount = null,Object? isLoading = null,Object? hasStaleData = null,Object? error = freezed,}) {
  return _then(_AlertsState(
alerts: null == alerts ? _self._alerts : alerts // ignore: cast_nullable_to_non_nullable
as List<AdminAlert>,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,hasStaleData: null == hasStaleData ? _self.hasStaleData : hasStaleData // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
