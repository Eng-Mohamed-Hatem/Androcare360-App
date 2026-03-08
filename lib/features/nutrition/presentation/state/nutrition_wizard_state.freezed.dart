// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nutrition_wizard_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NutritionWizardState {

/// Current active step (1-8)
 int get currentStep;/// Set of steps that have been visited
 Set<int> get visitedSteps;/// Last step that was successfully saved
 int get lastSavedStep;/// Whether user can proceed to next step
/// (based on validation of current step)
 bool get canProceed;/// Validation error message for current step
 String? get validationError;/// Completion status for each step (1-8)
 Map<int, StepCompletionStatus> get stepStatuses;
/// Create a copy of NutritionWizardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NutritionWizardStateCopyWith<NutritionWizardState> get copyWith => _$NutritionWizardStateCopyWithImpl<NutritionWizardState>(this as NutritionWizardState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NutritionWizardState&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&const DeepCollectionEquality().equals(other.visitedSteps, visitedSteps)&&(identical(other.lastSavedStep, lastSavedStep) || other.lastSavedStep == lastSavedStep)&&(identical(other.canProceed, canProceed) || other.canProceed == canProceed)&&(identical(other.validationError, validationError) || other.validationError == validationError)&&const DeepCollectionEquality().equals(other.stepStatuses, stepStatuses));
}


@override
int get hashCode => Object.hash(runtimeType,currentStep,const DeepCollectionEquality().hash(visitedSteps),lastSavedStep,canProceed,validationError,const DeepCollectionEquality().hash(stepStatuses));

@override
String toString() {
  return 'NutritionWizardState(currentStep: $currentStep, visitedSteps: $visitedSteps, lastSavedStep: $lastSavedStep, canProceed: $canProceed, validationError: $validationError, stepStatuses: $stepStatuses)';
}


}

/// @nodoc
abstract mixin class $NutritionWizardStateCopyWith<$Res>  {
  factory $NutritionWizardStateCopyWith(NutritionWizardState value, $Res Function(NutritionWizardState) _then) = _$NutritionWizardStateCopyWithImpl;
@useResult
$Res call({
 int currentStep, Set<int> visitedSteps, int lastSavedStep, bool canProceed, String? validationError, Map<int, StepCompletionStatus> stepStatuses
});




}
/// @nodoc
class _$NutritionWizardStateCopyWithImpl<$Res>
    implements $NutritionWizardStateCopyWith<$Res> {
  _$NutritionWizardStateCopyWithImpl(this._self, this._then);

  final NutritionWizardState _self;
  final $Res Function(NutritionWizardState) _then;

/// Create a copy of NutritionWizardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentStep = null,Object? visitedSteps = null,Object? lastSavedStep = null,Object? canProceed = null,Object? validationError = freezed,Object? stepStatuses = null,}) {
  return _then(_self.copyWith(
currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,visitedSteps: null == visitedSteps ? _self.visitedSteps : visitedSteps // ignore: cast_nullable_to_non_nullable
as Set<int>,lastSavedStep: null == lastSavedStep ? _self.lastSavedStep : lastSavedStep // ignore: cast_nullable_to_non_nullable
as int,canProceed: null == canProceed ? _self.canProceed : canProceed // ignore: cast_nullable_to_non_nullable
as bool,validationError: freezed == validationError ? _self.validationError : validationError // ignore: cast_nullable_to_non_nullable
as String?,stepStatuses: null == stepStatuses ? _self.stepStatuses : stepStatuses // ignore: cast_nullable_to_non_nullable
as Map<int, StepCompletionStatus>,
  ));
}

}


/// Adds pattern-matching-related methods to [NutritionWizardState].
extension NutritionWizardStatePatterns on NutritionWizardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NutritionWizardState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NutritionWizardState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NutritionWizardState value)  $default,){
final _that = this;
switch (_that) {
case _NutritionWizardState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NutritionWizardState value)?  $default,){
final _that = this;
switch (_that) {
case _NutritionWizardState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentStep,  Set<int> visitedSteps,  int lastSavedStep,  bool canProceed,  String? validationError,  Map<int, StepCompletionStatus> stepStatuses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NutritionWizardState() when $default != null:
return $default(_that.currentStep,_that.visitedSteps,_that.lastSavedStep,_that.canProceed,_that.validationError,_that.stepStatuses);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentStep,  Set<int> visitedSteps,  int lastSavedStep,  bool canProceed,  String? validationError,  Map<int, StepCompletionStatus> stepStatuses)  $default,) {final _that = this;
switch (_that) {
case _NutritionWizardState():
return $default(_that.currentStep,_that.visitedSteps,_that.lastSavedStep,_that.canProceed,_that.validationError,_that.stepStatuses);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentStep,  Set<int> visitedSteps,  int lastSavedStep,  bool canProceed,  String? validationError,  Map<int, StepCompletionStatus> stepStatuses)?  $default,) {final _that = this;
switch (_that) {
case _NutritionWizardState() when $default != null:
return $default(_that.currentStep,_that.visitedSteps,_that.lastSavedStep,_that.canProceed,_that.validationError,_that.stepStatuses);case _:
  return null;

}
}

}

/// @nodoc


class _NutritionWizardState extends NutritionWizardState {
  const _NutritionWizardState({this.currentStep = 1, final  Set<int> visitedSteps = const {1}, this.lastSavedStep = 0, this.canProceed = true, this.validationError, final  Map<int, StepCompletionStatus> stepStatuses = const {1 : StepCompletionStatus.notStarted, 2 : StepCompletionStatus.notStarted, 3 : StepCompletionStatus.notStarted, 4 : StepCompletionStatus.notStarted, 5 : StepCompletionStatus.notStarted, 6 : StepCompletionStatus.notStarted, 7 : StepCompletionStatus.notStarted, 8 : StepCompletionStatus.notStarted}}): _visitedSteps = visitedSteps,_stepStatuses = stepStatuses,super._();
  

/// Current active step (1-8)
@override@JsonKey() final  int currentStep;
/// Set of steps that have been visited
 final  Set<int> _visitedSteps;
/// Set of steps that have been visited
@override@JsonKey() Set<int> get visitedSteps {
  if (_visitedSteps is EqualUnmodifiableSetView) return _visitedSteps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_visitedSteps);
}

/// Last step that was successfully saved
@override@JsonKey() final  int lastSavedStep;
/// Whether user can proceed to next step
/// (based on validation of current step)
@override@JsonKey() final  bool canProceed;
/// Validation error message for current step
@override final  String? validationError;
/// Completion status for each step (1-8)
 final  Map<int, StepCompletionStatus> _stepStatuses;
/// Completion status for each step (1-8)
@override@JsonKey() Map<int, StepCompletionStatus> get stepStatuses {
  if (_stepStatuses is EqualUnmodifiableMapView) return _stepStatuses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_stepStatuses);
}


/// Create a copy of NutritionWizardState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NutritionWizardStateCopyWith<_NutritionWizardState> get copyWith => __$NutritionWizardStateCopyWithImpl<_NutritionWizardState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NutritionWizardState&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&const DeepCollectionEquality().equals(other._visitedSteps, _visitedSteps)&&(identical(other.lastSavedStep, lastSavedStep) || other.lastSavedStep == lastSavedStep)&&(identical(other.canProceed, canProceed) || other.canProceed == canProceed)&&(identical(other.validationError, validationError) || other.validationError == validationError)&&const DeepCollectionEquality().equals(other._stepStatuses, _stepStatuses));
}


@override
int get hashCode => Object.hash(runtimeType,currentStep,const DeepCollectionEquality().hash(_visitedSteps),lastSavedStep,canProceed,validationError,const DeepCollectionEquality().hash(_stepStatuses));

@override
String toString() {
  return 'NutritionWizardState(currentStep: $currentStep, visitedSteps: $visitedSteps, lastSavedStep: $lastSavedStep, canProceed: $canProceed, validationError: $validationError, stepStatuses: $stepStatuses)';
}


}

/// @nodoc
abstract mixin class _$NutritionWizardStateCopyWith<$Res> implements $NutritionWizardStateCopyWith<$Res> {
  factory _$NutritionWizardStateCopyWith(_NutritionWizardState value, $Res Function(_NutritionWizardState) _then) = __$NutritionWizardStateCopyWithImpl;
@override @useResult
$Res call({
 int currentStep, Set<int> visitedSteps, int lastSavedStep, bool canProceed, String? validationError, Map<int, StepCompletionStatus> stepStatuses
});




}
/// @nodoc
class __$NutritionWizardStateCopyWithImpl<$Res>
    implements _$NutritionWizardStateCopyWith<$Res> {
  __$NutritionWizardStateCopyWithImpl(this._self, this._then);

  final _NutritionWizardState _self;
  final $Res Function(_NutritionWizardState) _then;

/// Create a copy of NutritionWizardState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentStep = null,Object? visitedSteps = null,Object? lastSavedStep = null,Object? canProceed = null,Object? validationError = freezed,Object? stepStatuses = null,}) {
  return _then(_NutritionWizardState(
currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,visitedSteps: null == visitedSteps ? _self._visitedSteps : visitedSteps // ignore: cast_nullable_to_non_nullable
as Set<int>,lastSavedStep: null == lastSavedStep ? _self.lastSavedStep : lastSavedStep // ignore: cast_nullable_to_non_nullable
as int,canProceed: null == canProceed ? _self.canProceed : canProceed // ignore: cast_nullable_to_non_nullable
as bool,validationError: freezed == validationError ? _self.validationError : validationError // ignore: cast_nullable_to_non_nullable
as String?,stepStatuses: null == stepStatuses ? _self._stepStatuses : stepStatuses // ignore: cast_nullable_to_non_nullable
as Map<int, StepCompletionStatus>,
  ));
}


}

// dart format on
