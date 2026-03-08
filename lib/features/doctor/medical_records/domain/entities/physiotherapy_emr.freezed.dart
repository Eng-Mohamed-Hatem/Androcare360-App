// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'physiotherapy_emr.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PhysiotherapyEMR {

/// Unique identifier for this EMR record (UUID v4)
 String get id;/// Patient identifier from patients collection
 String get patientId;/// Physical therapist/Doctor identifier from users collection
 String get doctorId;/// Physical therapist's full name for display and audit
 String get doctorName;/// Appointment ID linking to appointments collection
 String get appointmentId;/// Visit date and time (from appointment)
 DateTime get visitDate;/// Record creation timestamp
 DateTime get createdAt;// ═══════════════════════════════════════════════════════════════════════
// 📋 PHASE ONE: CHECKLIST SECTIONS (8 sections)
// ═══════════════════════════════════════════════════════════════════════
/// Section 1: Patient and Visit Basics
///
/// Contains fundamental visit information:
/// - Identity verification status
/// - Informed consent documentation
/// - Reason for visit
/// - Medical history review
///
/// Example: {'Identity': ['Verified'], 'Consent': ['Obtained']}
 Map<String, List<String>> get basics;/// Section 2: Pain Assessment
///
/// Comprehensive pain evaluation:
/// - Pain location (body regions)
/// - Pain intensity (0-10 scale)
/// - Pain characteristics (sharp, dull, burning, etc.)
/// - Aggravating and relieving factors
///
/// Example: {'Location': ['Lower back'], 'Intensity': ['Moderate (4-6/10)']}
 Map<String, List<String>> get painAssessment;/// Section 3: Functional Assessment
///
/// Activities of Daily Living (ADL) evaluation:
/// - Mobility limitations
/// - Balance and coordination
/// - Gait analysis
/// - Transfer abilities
///
/// Example: {'ADL': ['Difficulty with stairs'], 'Mobility': ['Limited walking']}
 Map<String, List<String>> get functionalAssessment;/// Section 4: Systems Review
///
/// Body systems screening:
/// - Cardiovascular system
/// - Respiratory system
/// - Neurological system
/// - Musculoskeletal system
///
/// Example: {'Cardiovascular': ['Normal'], 'Respiratory': ['No issues']}
 Map<String, List<String>> get systemsReview;/// Section 5: Range of Motion (ROM)
///
/// Joint mobility measurements:
/// - Active ROM
/// - Passive ROM
/// - Joint-specific limitations
/// - Flexibility assessment
///
/// Example: {'Shoulder': ['Limited flexion'], 'Knee': ['Full ROM']}
 Map<String, List<String>> get rangeOfMotion;/// Section 6: Strength Assessment
///
/// Muscle strength testing (0-5 scale):
/// - Manual muscle testing
/// - Functional strength
/// - Muscle group evaluation
/// - Weakness patterns
///
/// Example: {'Quadriceps': ['4/5'], 'Hamstrings': ['3/5']}
 Map<String, List<String>> get strengthAssessment;/// Section 7: Devices and Equipment
///
/// Assistive devices and orthotics:
/// - Current devices in use
/// - Recommended equipment
/// - Orthotic prescriptions
/// - Adaptive equipment needs
///
/// Example: {'Current': ['Walking cane'], 'Recommended': ['Knee brace']}
 Map<String, List<String>> get devicesEquipment;/// Section 8: Treatment Plan
///
/// Therapeutic interventions:
/// - Manual therapy techniques
/// - Therapeutic exercises
/// - Modalities (heat, ice, electrical stimulation)
/// - Treatment frequency and duration
///
/// Example: {'Interventions': ['Manual therapy', 'Exercises'], 'Frequency': ['3x/week']}
 Map<String, List<String>> get treatmentPlan;// ═══════════════════════════════════════════════════════════════════════
// 📝 PHASE TWO: TEXT INPUT SECTIONS (2 sections)
// ═══════════════════════════════════════════════════════════════════════
/// Primary Diagnosis
///
/// Clinical diagnosis with ICD codes:
/// - Primary condition
/// - Secondary diagnoses
/// - ICD-10 codes
/// - Prognosis
///
/// Example: 'Chronic lower back pain with L5-S1 radiculopathy (M54.16)'
 String? get primaryDiagnosis;/// Management Plan
///
/// Detailed treatment strategy:
/// - Short-term goals (1-2 weeks)
/// - Long-term goals (4-12 weeks)
/// - Treatment timeline
/// - Expected outcomes
/// - Home exercise program
/// - Follow-up schedule
///
/// Example: 'Progressive strengthening program over 6 weeks with focus on core stability...'
 String? get managementPlan;// ═══════════════════════════════════════════════════════════════════════
// 📊 METADATA
// ═══════════════════════════════════════════════════════════════════════
/// Clinic specialization identifier
///
/// Default: 'عيادة العلاج الطبيعي والتأهيل' (Physical Therapy & Rehabilitation Clinic)
 String get specialization;
/// Create a copy of PhysiotherapyEMR
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhysiotherapyEMRCopyWith<PhysiotherapyEMR> get copyWith => _$PhysiotherapyEMRCopyWithImpl<PhysiotherapyEMR>(this as PhysiotherapyEMR, _$identity);

  /// Serializes this PhysiotherapyEMR to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhysiotherapyEMR&&(identical(other.id, id) || other.id == id)&&(identical(other.patientId, patientId) || other.patientId == patientId)&&(identical(other.doctorId, doctorId) || other.doctorId == doctorId)&&(identical(other.doctorName, doctorName) || other.doctorName == doctorName)&&(identical(other.appointmentId, appointmentId) || other.appointmentId == appointmentId)&&(identical(other.visitDate, visitDate) || other.visitDate == visitDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.basics, basics)&&const DeepCollectionEquality().equals(other.painAssessment, painAssessment)&&const DeepCollectionEquality().equals(other.functionalAssessment, functionalAssessment)&&const DeepCollectionEquality().equals(other.systemsReview, systemsReview)&&const DeepCollectionEquality().equals(other.rangeOfMotion, rangeOfMotion)&&const DeepCollectionEquality().equals(other.strengthAssessment, strengthAssessment)&&const DeepCollectionEquality().equals(other.devicesEquipment, devicesEquipment)&&const DeepCollectionEquality().equals(other.treatmentPlan, treatmentPlan)&&(identical(other.primaryDiagnosis, primaryDiagnosis) || other.primaryDiagnosis == primaryDiagnosis)&&(identical(other.managementPlan, managementPlan) || other.managementPlan == managementPlan)&&(identical(other.specialization, specialization) || other.specialization == specialization));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,patientId,doctorId,doctorName,appointmentId,visitDate,createdAt,const DeepCollectionEquality().hash(basics),const DeepCollectionEquality().hash(painAssessment),const DeepCollectionEquality().hash(functionalAssessment),const DeepCollectionEquality().hash(systemsReview),const DeepCollectionEquality().hash(rangeOfMotion),const DeepCollectionEquality().hash(strengthAssessment),const DeepCollectionEquality().hash(devicesEquipment),const DeepCollectionEquality().hash(treatmentPlan),primaryDiagnosis,managementPlan,specialization);

@override
String toString() {
  return 'PhysiotherapyEMR(id: $id, patientId: $patientId, doctorId: $doctorId, doctorName: $doctorName, appointmentId: $appointmentId, visitDate: $visitDate, createdAt: $createdAt, basics: $basics, painAssessment: $painAssessment, functionalAssessment: $functionalAssessment, systemsReview: $systemsReview, rangeOfMotion: $rangeOfMotion, strengthAssessment: $strengthAssessment, devicesEquipment: $devicesEquipment, treatmentPlan: $treatmentPlan, primaryDiagnosis: $primaryDiagnosis, managementPlan: $managementPlan, specialization: $specialization)';
}


}

/// @nodoc
abstract mixin class $PhysiotherapyEMRCopyWith<$Res>  {
  factory $PhysiotherapyEMRCopyWith(PhysiotherapyEMR value, $Res Function(PhysiotherapyEMR) _then) = _$PhysiotherapyEMRCopyWithImpl;
@useResult
$Res call({
 String id, String patientId, String doctorId, String doctorName, String appointmentId, DateTime visitDate, DateTime createdAt, Map<String, List<String>> basics, Map<String, List<String>> painAssessment, Map<String, List<String>> functionalAssessment, Map<String, List<String>> systemsReview, Map<String, List<String>> rangeOfMotion, Map<String, List<String>> strengthAssessment, Map<String, List<String>> devicesEquipment, Map<String, List<String>> treatmentPlan, String? primaryDiagnosis, String? managementPlan, String specialization
});




}
/// @nodoc
class _$PhysiotherapyEMRCopyWithImpl<$Res>
    implements $PhysiotherapyEMRCopyWith<$Res> {
  _$PhysiotherapyEMRCopyWithImpl(this._self, this._then);

  final PhysiotherapyEMR _self;
  final $Res Function(PhysiotherapyEMR) _then;

/// Create a copy of PhysiotherapyEMR
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? patientId = null,Object? doctorId = null,Object? doctorName = null,Object? appointmentId = null,Object? visitDate = null,Object? createdAt = null,Object? basics = null,Object? painAssessment = null,Object? functionalAssessment = null,Object? systemsReview = null,Object? rangeOfMotion = null,Object? strengthAssessment = null,Object? devicesEquipment = null,Object? treatmentPlan = null,Object? primaryDiagnosis = freezed,Object? managementPlan = freezed,Object? specialization = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,doctorId: null == doctorId ? _self.doctorId : doctorId // ignore: cast_nullable_to_non_nullable
as String,doctorName: null == doctorName ? _self.doctorName : doctorName // ignore: cast_nullable_to_non_nullable
as String,appointmentId: null == appointmentId ? _self.appointmentId : appointmentId // ignore: cast_nullable_to_non_nullable
as String,visitDate: null == visitDate ? _self.visitDate : visitDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,basics: null == basics ? _self.basics : basics // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,painAssessment: null == painAssessment ? _self.painAssessment : painAssessment // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,functionalAssessment: null == functionalAssessment ? _self.functionalAssessment : functionalAssessment // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,systemsReview: null == systemsReview ? _self.systemsReview : systemsReview // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,rangeOfMotion: null == rangeOfMotion ? _self.rangeOfMotion : rangeOfMotion // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,strengthAssessment: null == strengthAssessment ? _self.strengthAssessment : strengthAssessment // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,devicesEquipment: null == devicesEquipment ? _self.devicesEquipment : devicesEquipment // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,treatmentPlan: null == treatmentPlan ? _self.treatmentPlan : treatmentPlan // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,primaryDiagnosis: freezed == primaryDiagnosis ? _self.primaryDiagnosis : primaryDiagnosis // ignore: cast_nullable_to_non_nullable
as String?,managementPlan: freezed == managementPlan ? _self.managementPlan : managementPlan // ignore: cast_nullable_to_non_nullable
as String?,specialization: null == specialization ? _self.specialization : specialization // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PhysiotherapyEMR].
extension PhysiotherapyEMRPatterns on PhysiotherapyEMR {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhysiotherapyEMR value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhysiotherapyEMR() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhysiotherapyEMR value)  $default,){
final _that = this;
switch (_that) {
case _PhysiotherapyEMR():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhysiotherapyEMR value)?  $default,){
final _that = this;
switch (_that) {
case _PhysiotherapyEMR() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String patientId,  String doctorId,  String doctorName,  String appointmentId,  DateTime visitDate,  DateTime createdAt,  Map<String, List<String>> basics,  Map<String, List<String>> painAssessment,  Map<String, List<String>> functionalAssessment,  Map<String, List<String>> systemsReview,  Map<String, List<String>> rangeOfMotion,  Map<String, List<String>> strengthAssessment,  Map<String, List<String>> devicesEquipment,  Map<String, List<String>> treatmentPlan,  String? primaryDiagnosis,  String? managementPlan,  String specialization)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhysiotherapyEMR() when $default != null:
return $default(_that.id,_that.patientId,_that.doctorId,_that.doctorName,_that.appointmentId,_that.visitDate,_that.createdAt,_that.basics,_that.painAssessment,_that.functionalAssessment,_that.systemsReview,_that.rangeOfMotion,_that.strengthAssessment,_that.devicesEquipment,_that.treatmentPlan,_that.primaryDiagnosis,_that.managementPlan,_that.specialization);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String patientId,  String doctorId,  String doctorName,  String appointmentId,  DateTime visitDate,  DateTime createdAt,  Map<String, List<String>> basics,  Map<String, List<String>> painAssessment,  Map<String, List<String>> functionalAssessment,  Map<String, List<String>> systemsReview,  Map<String, List<String>> rangeOfMotion,  Map<String, List<String>> strengthAssessment,  Map<String, List<String>> devicesEquipment,  Map<String, List<String>> treatmentPlan,  String? primaryDiagnosis,  String? managementPlan,  String specialization)  $default,) {final _that = this;
switch (_that) {
case _PhysiotherapyEMR():
return $default(_that.id,_that.patientId,_that.doctorId,_that.doctorName,_that.appointmentId,_that.visitDate,_that.createdAt,_that.basics,_that.painAssessment,_that.functionalAssessment,_that.systemsReview,_that.rangeOfMotion,_that.strengthAssessment,_that.devicesEquipment,_that.treatmentPlan,_that.primaryDiagnosis,_that.managementPlan,_that.specialization);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String patientId,  String doctorId,  String doctorName,  String appointmentId,  DateTime visitDate,  DateTime createdAt,  Map<String, List<String>> basics,  Map<String, List<String>> painAssessment,  Map<String, List<String>> functionalAssessment,  Map<String, List<String>> systemsReview,  Map<String, List<String>> rangeOfMotion,  Map<String, List<String>> strengthAssessment,  Map<String, List<String>> devicesEquipment,  Map<String, List<String>> treatmentPlan,  String? primaryDiagnosis,  String? managementPlan,  String specialization)?  $default,) {final _that = this;
switch (_that) {
case _PhysiotherapyEMR() when $default != null:
return $default(_that.id,_that.patientId,_that.doctorId,_that.doctorName,_that.appointmentId,_that.visitDate,_that.createdAt,_that.basics,_that.painAssessment,_that.functionalAssessment,_that.systemsReview,_that.rangeOfMotion,_that.strengthAssessment,_that.devicesEquipment,_that.treatmentPlan,_that.primaryDiagnosis,_that.managementPlan,_that.specialization);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PhysiotherapyEMR extends PhysiotherapyEMR {
  const _PhysiotherapyEMR({required this.id, required this.patientId, required this.doctorId, required this.doctorName, required this.appointmentId, required this.visitDate, required this.createdAt, required final  Map<String, List<String>> basics, required final  Map<String, List<String>> painAssessment, required final  Map<String, List<String>> functionalAssessment, required final  Map<String, List<String>> systemsReview, required final  Map<String, List<String>> rangeOfMotion, required final  Map<String, List<String>> strengthAssessment, required final  Map<String, List<String>> devicesEquipment, required final  Map<String, List<String>> treatmentPlan, this.primaryDiagnosis, this.managementPlan, this.specialization = 'عيادة العلاج الطبيعي والتأهيل'}): _basics = basics,_painAssessment = painAssessment,_functionalAssessment = functionalAssessment,_systemsReview = systemsReview,_rangeOfMotion = rangeOfMotion,_strengthAssessment = strengthAssessment,_devicesEquipment = devicesEquipment,_treatmentPlan = treatmentPlan,super._();
  factory _PhysiotherapyEMR.fromJson(Map<String, dynamic> json) => _$PhysiotherapyEMRFromJson(json);

/// Unique identifier for this EMR record (UUID v4)
@override final  String id;
/// Patient identifier from patients collection
@override final  String patientId;
/// Physical therapist/Doctor identifier from users collection
@override final  String doctorId;
/// Physical therapist's full name for display and audit
@override final  String doctorName;
/// Appointment ID linking to appointments collection
@override final  String appointmentId;
/// Visit date and time (from appointment)
@override final  DateTime visitDate;
/// Record creation timestamp
@override final  DateTime createdAt;
// ═══════════════════════════════════════════════════════════════════════
// 📋 PHASE ONE: CHECKLIST SECTIONS (8 sections)
// ═══════════════════════════════════════════════════════════════════════
/// Section 1: Patient and Visit Basics
///
/// Contains fundamental visit information:
/// - Identity verification status
/// - Informed consent documentation
/// - Reason for visit
/// - Medical history review
///
/// Example: {'Identity': ['Verified'], 'Consent': ['Obtained']}
 final  Map<String, List<String>> _basics;
// ═══════════════════════════════════════════════════════════════════════
// 📋 PHASE ONE: CHECKLIST SECTIONS (8 sections)
// ═══════════════════════════════════════════════════════════════════════
/// Section 1: Patient and Visit Basics
///
/// Contains fundamental visit information:
/// - Identity verification status
/// - Informed consent documentation
/// - Reason for visit
/// - Medical history review
///
/// Example: {'Identity': ['Verified'], 'Consent': ['Obtained']}
@override Map<String, List<String>> get basics {
  if (_basics is EqualUnmodifiableMapView) return _basics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_basics);
}

/// Section 2: Pain Assessment
///
/// Comprehensive pain evaluation:
/// - Pain location (body regions)
/// - Pain intensity (0-10 scale)
/// - Pain characteristics (sharp, dull, burning, etc.)
/// - Aggravating and relieving factors
///
/// Example: {'Location': ['Lower back'], 'Intensity': ['Moderate (4-6/10)']}
 final  Map<String, List<String>> _painAssessment;
/// Section 2: Pain Assessment
///
/// Comprehensive pain evaluation:
/// - Pain location (body regions)
/// - Pain intensity (0-10 scale)
/// - Pain characteristics (sharp, dull, burning, etc.)
/// - Aggravating and relieving factors
///
/// Example: {'Location': ['Lower back'], 'Intensity': ['Moderate (4-6/10)']}
@override Map<String, List<String>> get painAssessment {
  if (_painAssessment is EqualUnmodifiableMapView) return _painAssessment;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_painAssessment);
}

/// Section 3: Functional Assessment
///
/// Activities of Daily Living (ADL) evaluation:
/// - Mobility limitations
/// - Balance and coordination
/// - Gait analysis
/// - Transfer abilities
///
/// Example: {'ADL': ['Difficulty with stairs'], 'Mobility': ['Limited walking']}
 final  Map<String, List<String>> _functionalAssessment;
/// Section 3: Functional Assessment
///
/// Activities of Daily Living (ADL) evaluation:
/// - Mobility limitations
/// - Balance and coordination
/// - Gait analysis
/// - Transfer abilities
///
/// Example: {'ADL': ['Difficulty with stairs'], 'Mobility': ['Limited walking']}
@override Map<String, List<String>> get functionalAssessment {
  if (_functionalAssessment is EqualUnmodifiableMapView) return _functionalAssessment;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_functionalAssessment);
}

/// Section 4: Systems Review
///
/// Body systems screening:
/// - Cardiovascular system
/// - Respiratory system
/// - Neurological system
/// - Musculoskeletal system
///
/// Example: {'Cardiovascular': ['Normal'], 'Respiratory': ['No issues']}
 final  Map<String, List<String>> _systemsReview;
/// Section 4: Systems Review
///
/// Body systems screening:
/// - Cardiovascular system
/// - Respiratory system
/// - Neurological system
/// - Musculoskeletal system
///
/// Example: {'Cardiovascular': ['Normal'], 'Respiratory': ['No issues']}
@override Map<String, List<String>> get systemsReview {
  if (_systemsReview is EqualUnmodifiableMapView) return _systemsReview;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_systemsReview);
}

/// Section 5: Range of Motion (ROM)
///
/// Joint mobility measurements:
/// - Active ROM
/// - Passive ROM
/// - Joint-specific limitations
/// - Flexibility assessment
///
/// Example: {'Shoulder': ['Limited flexion'], 'Knee': ['Full ROM']}
 final  Map<String, List<String>> _rangeOfMotion;
/// Section 5: Range of Motion (ROM)
///
/// Joint mobility measurements:
/// - Active ROM
/// - Passive ROM
/// - Joint-specific limitations
/// - Flexibility assessment
///
/// Example: {'Shoulder': ['Limited flexion'], 'Knee': ['Full ROM']}
@override Map<String, List<String>> get rangeOfMotion {
  if (_rangeOfMotion is EqualUnmodifiableMapView) return _rangeOfMotion;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rangeOfMotion);
}

/// Section 6: Strength Assessment
///
/// Muscle strength testing (0-5 scale):
/// - Manual muscle testing
/// - Functional strength
/// - Muscle group evaluation
/// - Weakness patterns
///
/// Example: {'Quadriceps': ['4/5'], 'Hamstrings': ['3/5']}
 final  Map<String, List<String>> _strengthAssessment;
/// Section 6: Strength Assessment
///
/// Muscle strength testing (0-5 scale):
/// - Manual muscle testing
/// - Functional strength
/// - Muscle group evaluation
/// - Weakness patterns
///
/// Example: {'Quadriceps': ['4/5'], 'Hamstrings': ['3/5']}
@override Map<String, List<String>> get strengthAssessment {
  if (_strengthAssessment is EqualUnmodifiableMapView) return _strengthAssessment;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_strengthAssessment);
}

/// Section 7: Devices and Equipment
///
/// Assistive devices and orthotics:
/// - Current devices in use
/// - Recommended equipment
/// - Orthotic prescriptions
/// - Adaptive equipment needs
///
/// Example: {'Current': ['Walking cane'], 'Recommended': ['Knee brace']}
 final  Map<String, List<String>> _devicesEquipment;
/// Section 7: Devices and Equipment
///
/// Assistive devices and orthotics:
/// - Current devices in use
/// - Recommended equipment
/// - Orthotic prescriptions
/// - Adaptive equipment needs
///
/// Example: {'Current': ['Walking cane'], 'Recommended': ['Knee brace']}
@override Map<String, List<String>> get devicesEquipment {
  if (_devicesEquipment is EqualUnmodifiableMapView) return _devicesEquipment;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_devicesEquipment);
}

/// Section 8: Treatment Plan
///
/// Therapeutic interventions:
/// - Manual therapy techniques
/// - Therapeutic exercises
/// - Modalities (heat, ice, electrical stimulation)
/// - Treatment frequency and duration
///
/// Example: {'Interventions': ['Manual therapy', 'Exercises'], 'Frequency': ['3x/week']}
 final  Map<String, List<String>> _treatmentPlan;
/// Section 8: Treatment Plan
///
/// Therapeutic interventions:
/// - Manual therapy techniques
/// - Therapeutic exercises
/// - Modalities (heat, ice, electrical stimulation)
/// - Treatment frequency and duration
///
/// Example: {'Interventions': ['Manual therapy', 'Exercises'], 'Frequency': ['3x/week']}
@override Map<String, List<String>> get treatmentPlan {
  if (_treatmentPlan is EqualUnmodifiableMapView) return _treatmentPlan;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_treatmentPlan);
}

// ═══════════════════════════════════════════════════════════════════════
// 📝 PHASE TWO: TEXT INPUT SECTIONS (2 sections)
// ═══════════════════════════════════════════════════════════════════════
/// Primary Diagnosis
///
/// Clinical diagnosis with ICD codes:
/// - Primary condition
/// - Secondary diagnoses
/// - ICD-10 codes
/// - Prognosis
///
/// Example: 'Chronic lower back pain with L5-S1 radiculopathy (M54.16)'
@override final  String? primaryDiagnosis;
/// Management Plan
///
/// Detailed treatment strategy:
/// - Short-term goals (1-2 weeks)
/// - Long-term goals (4-12 weeks)
/// - Treatment timeline
/// - Expected outcomes
/// - Home exercise program
/// - Follow-up schedule
///
/// Example: 'Progressive strengthening program over 6 weeks with focus on core stability...'
@override final  String? managementPlan;
// ═══════════════════════════════════════════════════════════════════════
// 📊 METADATA
// ═══════════════════════════════════════════════════════════════════════
/// Clinic specialization identifier
///
/// Default: 'عيادة العلاج الطبيعي والتأهيل' (Physical Therapy & Rehabilitation Clinic)
@override@JsonKey() final  String specialization;

/// Create a copy of PhysiotherapyEMR
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhysiotherapyEMRCopyWith<_PhysiotherapyEMR> get copyWith => __$PhysiotherapyEMRCopyWithImpl<_PhysiotherapyEMR>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhysiotherapyEMRToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhysiotherapyEMR&&(identical(other.id, id) || other.id == id)&&(identical(other.patientId, patientId) || other.patientId == patientId)&&(identical(other.doctorId, doctorId) || other.doctorId == doctorId)&&(identical(other.doctorName, doctorName) || other.doctorName == doctorName)&&(identical(other.appointmentId, appointmentId) || other.appointmentId == appointmentId)&&(identical(other.visitDate, visitDate) || other.visitDate == visitDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._basics, _basics)&&const DeepCollectionEquality().equals(other._painAssessment, _painAssessment)&&const DeepCollectionEquality().equals(other._functionalAssessment, _functionalAssessment)&&const DeepCollectionEquality().equals(other._systemsReview, _systemsReview)&&const DeepCollectionEquality().equals(other._rangeOfMotion, _rangeOfMotion)&&const DeepCollectionEquality().equals(other._strengthAssessment, _strengthAssessment)&&const DeepCollectionEquality().equals(other._devicesEquipment, _devicesEquipment)&&const DeepCollectionEquality().equals(other._treatmentPlan, _treatmentPlan)&&(identical(other.primaryDiagnosis, primaryDiagnosis) || other.primaryDiagnosis == primaryDiagnosis)&&(identical(other.managementPlan, managementPlan) || other.managementPlan == managementPlan)&&(identical(other.specialization, specialization) || other.specialization == specialization));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,patientId,doctorId,doctorName,appointmentId,visitDate,createdAt,const DeepCollectionEquality().hash(_basics),const DeepCollectionEquality().hash(_painAssessment),const DeepCollectionEquality().hash(_functionalAssessment),const DeepCollectionEquality().hash(_systemsReview),const DeepCollectionEquality().hash(_rangeOfMotion),const DeepCollectionEquality().hash(_strengthAssessment),const DeepCollectionEquality().hash(_devicesEquipment),const DeepCollectionEquality().hash(_treatmentPlan),primaryDiagnosis,managementPlan,specialization);

@override
String toString() {
  return 'PhysiotherapyEMR(id: $id, patientId: $patientId, doctorId: $doctorId, doctorName: $doctorName, appointmentId: $appointmentId, visitDate: $visitDate, createdAt: $createdAt, basics: $basics, painAssessment: $painAssessment, functionalAssessment: $functionalAssessment, systemsReview: $systemsReview, rangeOfMotion: $rangeOfMotion, strengthAssessment: $strengthAssessment, devicesEquipment: $devicesEquipment, treatmentPlan: $treatmentPlan, primaryDiagnosis: $primaryDiagnosis, managementPlan: $managementPlan, specialization: $specialization)';
}


}

/// @nodoc
abstract mixin class _$PhysiotherapyEMRCopyWith<$Res> implements $PhysiotherapyEMRCopyWith<$Res> {
  factory _$PhysiotherapyEMRCopyWith(_PhysiotherapyEMR value, $Res Function(_PhysiotherapyEMR) _then) = __$PhysiotherapyEMRCopyWithImpl;
@override @useResult
$Res call({
 String id, String patientId, String doctorId, String doctorName, String appointmentId, DateTime visitDate, DateTime createdAt, Map<String, List<String>> basics, Map<String, List<String>> painAssessment, Map<String, List<String>> functionalAssessment, Map<String, List<String>> systemsReview, Map<String, List<String>> rangeOfMotion, Map<String, List<String>> strengthAssessment, Map<String, List<String>> devicesEquipment, Map<String, List<String>> treatmentPlan, String? primaryDiagnosis, String? managementPlan, String specialization
});




}
/// @nodoc
class __$PhysiotherapyEMRCopyWithImpl<$Res>
    implements _$PhysiotherapyEMRCopyWith<$Res> {
  __$PhysiotherapyEMRCopyWithImpl(this._self, this._then);

  final _PhysiotherapyEMR _self;
  final $Res Function(_PhysiotherapyEMR) _then;

/// Create a copy of PhysiotherapyEMR
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? patientId = null,Object? doctorId = null,Object? doctorName = null,Object? appointmentId = null,Object? visitDate = null,Object? createdAt = null,Object? basics = null,Object? painAssessment = null,Object? functionalAssessment = null,Object? systemsReview = null,Object? rangeOfMotion = null,Object? strengthAssessment = null,Object? devicesEquipment = null,Object? treatmentPlan = null,Object? primaryDiagnosis = freezed,Object? managementPlan = freezed,Object? specialization = null,}) {
  return _then(_PhysiotherapyEMR(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,doctorId: null == doctorId ? _self.doctorId : doctorId // ignore: cast_nullable_to_non_nullable
as String,doctorName: null == doctorName ? _self.doctorName : doctorName // ignore: cast_nullable_to_non_nullable
as String,appointmentId: null == appointmentId ? _self.appointmentId : appointmentId // ignore: cast_nullable_to_non_nullable
as String,visitDate: null == visitDate ? _self.visitDate : visitDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,basics: null == basics ? _self._basics : basics // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,painAssessment: null == painAssessment ? _self._painAssessment : painAssessment // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,functionalAssessment: null == functionalAssessment ? _self._functionalAssessment : functionalAssessment // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,systemsReview: null == systemsReview ? _self._systemsReview : systemsReview // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,rangeOfMotion: null == rangeOfMotion ? _self._rangeOfMotion : rangeOfMotion // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,strengthAssessment: null == strengthAssessment ? _self._strengthAssessment : strengthAssessment // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,devicesEquipment: null == devicesEquipment ? _self._devicesEquipment : devicesEquipment // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,treatmentPlan: null == treatmentPlan ? _self._treatmentPlan : treatmentPlan // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,primaryDiagnosis: freezed == primaryDiagnosis ? _self.primaryDiagnosis : primaryDiagnosis // ignore: cast_nullable_to_non_nullable
as String?,managementPlan: freezed == managementPlan ? _self.managementPlan : managementPlan // ignore: cast_nullable_to_non_nullable
as String?,specialization: null == specialization ? _self.specialization : specialization // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
