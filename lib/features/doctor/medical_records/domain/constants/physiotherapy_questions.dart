/// Physical Therapy EMR Questions and Options
/// Updated with the correct Telehealth Checklist as requested
class PhysiotherapyQuestions {
  PhysiotherapyQuestions._();

  static const Map<String, List<String>> physiotherapyQuestions = {
    'Patient & Visit Basics': [
      'Identity verified',
      'Consent obtained',
      'Pain present',
      'Red flags screened',
      'Other',
    ],
    'Pain Assessment': [
      'Location',
      'Intensity (0–10)',
      'Duration',
      'Aggravating factors',
      'Relieving factors',
      'Other',
    ],
    'Functional Status': [
      'Mobility',
      'Transfers',
      'Gait',
      'Balance',
      'ADLs',
      'Other',
    ],
    'Systems Screening': [
      'Neurological',
      'Musculoskeletal',
      'Cardiorespiratory',
      'Integumentary',
      'Other',
    ],
    'Range of Motion': [
      'Cervical',
      'Thoracic',
      'Lumbar',
      'Upper limbs',
      'Lower limbs',
      'Other',
    ],
    'Strength Testing': [
      'Upper limb strength',
      'Lower limb strength',
      'Core strength',
      'Other',
    ],
    'Assistive Devices': [
      'No device',
      'Cane',
      'Crutches',
      'Walker',
      'Wheelchair',
      'Other',
    ],
    'Plan': [
      'Home exercise program',
      'Manual therapy',
      'Electrotherapy',
      'Education',
      'Referral',
      'Other',
    ],
  };

  // مصفوفة العناوين لسهولة الوصول إليها في الواجهة
  static const List<String> sections = [
    'Patient & Visit Basics',
    'Pain Assessment',
    'Functional Status',
    'Systems Screening',
    'Range of Motion',
    'Strength Testing',
    'Assistive Devices',
    'Plan',
  ];
}
