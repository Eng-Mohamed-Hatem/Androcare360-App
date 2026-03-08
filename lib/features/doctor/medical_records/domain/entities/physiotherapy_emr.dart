import 'package:freezed_annotation/freezed_annotation.dart';

part 'physiotherapy_emr.freezed.dart';
part 'physiotherapy_emr.g.dart';

/// Physical Therapy EMR Entity - سجل العلاج الطبيعي الإلكتروني
///
/// Clean Architecture Domain Entity for Physical Therapy Clinical Records
///
/// يمثل هذا الكيان سجل العلاج الطبيعي الشامل في نظام AndroCare360، ويتضمن
/// تقييماً كاملاً للمريض عبر 8 أقسام من القوائم المرجعية بالإضافة إلى
/// قسمين نصيين للتشخيص وخطة العلاج.
///
/// This entity represents a comprehensive physical therapy assessment record
/// in the AndroCare360 system, including 8 checklist sections for systematic
/// evaluation and 2 unified text sections for diagnosis and management planning.
///
/// **Firestore Collection:** `physiotherapy_emrs`
/// **Database:** `elajtech`
/// **Specialization:** عيادة العلاج الطبيعي والتأهيل (Physical Therapy & Rehabilitation)
///
/// **Architecture:**
/// - Uses Freezed for complete immutability
/// - Follows Clean Architecture domain layer principles
/// - Implements comprehensive audit trail
/// - Supports 24-hour edit window with automatic locking
///
/// **Assessment Structure:**
///
/// **Phase One - Checklist Sections (8 sections):**
/// 1. **Basics** - Patient identity, consent, reason for visit
/// 2. **Pain Assessment** - Pain location, intensity, characteristics
/// 3. **Functional Assessment** - ADL, mobility, balance evaluation
/// 4. **Systems Review** - Cardiovascular, respiratory, neurological
/// 5. **Range of Motion** - Joint mobility measurements
/// 6. **Strength Assessment** - Muscle strength testing
/// 7. **Devices & Equipment** - Assistive devices, orthotics
/// 8. **Treatment Plan** - Therapeutic interventions, goals
///
/// **Phase Two - Text Input Sections (2 sections):**
/// 1. **Primary Diagnosis** - Clinical diagnosis and ICD codes
/// 2. **Management Plan** - Detailed treatment strategy and timeline
///
/// **Data Structure:**
/// Each checklist section is stored as `Map<String, List<String>>` where:
/// - Key: Category name (e.g., 'Pain Location', 'Muscle Strength')
/// - Value: List of selected checkbox items
///
/// **Security & Locking:**
/// - 24-hour edit window from creation
/// - Automatic locking after expiration
/// - Audit trail for all modifications
/// - Only assigned doctor can edit
///
/// **Usage Example:**
/// ```dart
/// // Creating a new physiotherapy EMR
/// final emr = PhysiotherapyEMR(
///   id: 'emr_123',
///   patientId: 'patient_456',
///   doctorId: 'doctor_789',
///   doctorName: 'Dr. Ahmed Ali',
///   appointmentId: 'apt_123',
///   visitDate: DateTime.now(),
///   createdAt: DateTime.now(),
///   basics: {
///     'Identity Verification': ['Patient identity verified'],
///     'Consent': ['Informed consent obtained'],
///   },
///   painAssessment: {
///     'Pain Location': ['Lower back', 'Right knee'],
///     'Pain Intensity': ['Moderate (4-6/10)'],
///   },
///   functionalAssessment: {
///     'ADL': ['Difficulty with stairs', 'Limited walking distance'],
///   },
///   systemsReview: {},
///   rangeOfMotion: {},
///   strengthAssessment: {},
///   devicesEquipment: {},
///   treatmentPlan: {
///     'Interventions': ['Manual therapy', 'Therapeutic exercises'],
///   },
///   primaryDiagnosis: 'Chronic lower back pain with radiculopathy',
///   managementPlan: 'Progressive strengthening program over 6 weeks...',
/// );
///
/// // Accessing checklist data
/// final painLocations = emr.painAssessment['Pain Location'] ?? [];
/// print('Pain locations: ${painLocations.join(", ")}');
///
/// // Checking if section has data
/// final hasPainData = emr.painAssessment.isNotEmpty;
/// ```
///
/// **Integration Points:**
/// - Created via PhysiotherapyEMRRepository
/// - Displayed in PhysiotherapyEMRFormScreen
/// - Linked to appointments collection
/// - Accessible only to assigned doctor and patient
///
/// **Validation Rules:**
/// - All required fields must be non-null
/// - visitDate must not be in the future
/// - doctorId must match authenticated user for edits
/// - Checklist maps can be empty but not null
///
/// **Critical Elajtech Rules:**
/// - Database ID: Always use `databaseId: 'elajtech'`
/// - Clinic Isolation: Independent repository for physiotherapy
/// - 24-Hour Lock: Enforced at repository level
/// - Audit Trail: All changes logged with user info
@freezed
abstract class PhysiotherapyEMR with _$PhysiotherapyEMR {
  const factory PhysiotherapyEMR({
    /// Unique identifier for this EMR record (UUID v4)
    required String id,

    /// Patient identifier from patients collection
    required String patientId,

    /// Physical therapist/Doctor identifier from users collection
    required String doctorId,

    /// Physical therapist's full name for display and audit
    required String doctorName,

    /// Appointment ID linking to appointments collection
    required String appointmentId,

    /// Visit date and time (from appointment)
    required DateTime visitDate,

    /// Record creation timestamp
    required DateTime createdAt,

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
    required Map<String, List<String>> basics,

    /// Section 2: Pain Assessment
    ///
    /// Comprehensive pain evaluation:
    /// - Pain location (body regions)
    /// - Pain intensity (0-10 scale)
    /// - Pain characteristics (sharp, dull, burning, etc.)
    /// - Aggravating and relieving factors
    ///
    /// Example: {'Location': ['Lower back'], 'Intensity': ['Moderate (4-6/10)']}
    required Map<String, List<String>> painAssessment,

    /// Section 3: Functional Assessment
    ///
    /// Activities of Daily Living (ADL) evaluation:
    /// - Mobility limitations
    /// - Balance and coordination
    /// - Gait analysis
    /// - Transfer abilities
    ///
    /// Example: {'ADL': ['Difficulty with stairs'], 'Mobility': ['Limited walking']}
    required Map<String, List<String>> functionalAssessment,

    /// Section 4: Systems Review
    ///
    /// Body systems screening:
    /// - Cardiovascular system
    /// - Respiratory system
    /// - Neurological system
    /// - Musculoskeletal system
    ///
    /// Example: {'Cardiovascular': ['Normal'], 'Respiratory': ['No issues']}
    required Map<String, List<String>> systemsReview,

    /// Section 5: Range of Motion (ROM)
    ///
    /// Joint mobility measurements:
    /// - Active ROM
    /// - Passive ROM
    /// - Joint-specific limitations
    /// - Flexibility assessment
    ///
    /// Example: {'Shoulder': ['Limited flexion'], 'Knee': ['Full ROM']}
    required Map<String, List<String>> rangeOfMotion,

    /// Section 6: Strength Assessment
    ///
    /// Muscle strength testing (0-5 scale):
    /// - Manual muscle testing
    /// - Functional strength
    /// - Muscle group evaluation
    /// - Weakness patterns
    ///
    /// Example: {'Quadriceps': ['4/5'], 'Hamstrings': ['3/5']}
    required Map<String, List<String>> strengthAssessment,

    /// Section 7: Devices and Equipment
    ///
    /// Assistive devices and orthotics:
    /// - Current devices in use
    /// - Recommended equipment
    /// - Orthotic prescriptions
    /// - Adaptive equipment needs
    ///
    /// Example: {'Current': ['Walking cane'], 'Recommended': ['Knee brace']}
    required Map<String, List<String>> devicesEquipment,

    /// Section 8: Treatment Plan
    ///
    /// Therapeutic interventions:
    /// - Manual therapy techniques
    /// - Therapeutic exercises
    /// - Modalities (heat, ice, electrical stimulation)
    /// - Treatment frequency and duration
    ///
    /// Example: {'Interventions': ['Manual therapy', 'Exercises'], 'Frequency': ['3x/week']}
    required Map<String, List<String>> treatmentPlan,

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
    String? primaryDiagnosis,

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
    String? managementPlan,

    // ═══════════════════════════════════════════════════════════════════════
    // 📊 METADATA
    // ═══════════════════════════════════════════════════════════════════════

    /// Clinic specialization identifier
    ///
    /// Default: 'عيادة العلاج الطبيعي والتأهيل' (Physical Therapy & Rehabilitation Clinic)
    @Default('عيادة العلاج الطبيعي والتأهيل') String specialization,
  }) = _PhysiotherapyEMR;

  const PhysiotherapyEMR._();

  factory PhysiotherapyEMR.fromJson(Map<String, dynamic> json) =>
      _$PhysiotherapyEMRFromJson(json);
}
