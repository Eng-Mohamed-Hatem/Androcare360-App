class EMRModel {
  EMRModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.appointmentId,
    required this.createdAt,
    required this.libidoLevel,
    required this.onsetOfErectileDifficulty,
    required this.frequencyOfIntercourseAttempts,
    required this.penetrationSuccess,
    required this.erectionRigidity,
    required this.nocturnalMorningErections,
    required this.ejaculatoryFunction,
    required this.orgasmicSatisfaction,
    required this.partnerSatisfaction,
    required this.concernAboutPenileSize,
    required this.opinionAboutPartnerSatisfaction,
    required this.pastHomosexualExperience,
    required this.interestedInHomosexuality,
    required this.historyOfSexualTraumaInChildhood,
    required this.historyOfPornoAddiction,
    required this.historyOfMasturbationAddiction,
    required this.historyOfIllegalSex,
    required this.historyOfHavingSTDs,
    required this.historyOfPenileTrauma,
    required this.historyMedication,
    required this.historyOfPenileCurvature,
    required this.pde5I,
    required this.supplements,
    required this.hormones,
    required this.previousHormones,
    required this.previousGeneralLab,
    required this.duplexPenileArteries,
    required this.testicularUS,
    required this.penileUS,
    required this.trus,
    required this.abdominopelvicUS,
    required this.durationOfMarriage,
    required this.ageOfWife,
    required this.multipleWives,
    required this.durationOfInfertility,
    required this.infertilityType,
    required this.previousConceptions,
    required this.historyOfVaricoceleGenitalSurgery,
    required this.semenAnalysisSummary,
    required this.hormonalProfile,
    required this.geneticOtherTests,
    required this.urinaryFrequency,
    required this.stream,
    required this.nocturia,
    required this.strainingOrIncompleteEmptying,
    required this.psaLevelDate,
    required this.trusProstatic,
    required this.uroflowmetry,
    required this.generalAppearanceBMI,
    required this.genitalExamination,
    required this.testicularSizeConsistency,
    required this.epididymisVas,
    required this.digitalRectalExamination,
    required this.impressionDiagnosis,
    required this.recommendedInvestigations,
    required this.initialTreatmentPlan,
    required this.followUpInterval,
  });

  factory EMRModel.fromJson(Map<String, dynamic> json) => EMRModel(
    id: json['id'] as String,
    patientId: json['patientId'] as String,
    doctorId: json['doctorId'] as String,
    doctorName: json['doctorName'] as String,
    appointmentId: json['appointmentId'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt'] as String),
    libidoLevel: json['libidoLevel'] as String? ?? '',
    onsetOfErectileDifficulty:
        json['onsetOfErectileDifficulty'] as String? ?? '',
    frequencyOfIntercourseAttempts:
        json['frequencyOfIntercourseAttempts'] as String? ?? '',
    penetrationSuccess: json['penetrationSuccess'] as String? ?? '',
    erectionRigidity: json['erectionRigidity'] as String? ?? '',
    nocturnalMorningErections:
        json['nocturnalMorningErections'] as String? ?? '',
    ejaculatoryFunction: json['ejaculatoryFunction'] as String? ?? '',
    orgasmicSatisfaction: json['orgasmicSatisfaction'] as String? ?? '',
    partnerSatisfaction: json['partnerSatisfaction'] as String? ?? '',
    concernAboutPenileSize: json['concernAboutPenileSize'] as String? ?? '',
    opinionAboutPartnerSatisfaction:
        json['opinionAboutPartnerSatisfaction'] as String? ?? '',
    pastHomosexualExperience:
        json['pastHomosexualExperience'] as bool? ?? false,
    interestedInHomosexuality:
        json['interestedInHomosexuality'] as bool? ?? false,
    historyOfSexualTraumaInChildhood:
        json['historyOfSexualTraumaInChildhood'] as bool? ?? false,
    historyOfPornoAddiction: json['historyOfPornoAddiction'] as bool? ?? false,
    historyOfMasturbationAddiction:
        json['historyOfMasturbationAddiction'] as bool? ?? false,
    historyOfIllegalSex: json['historyOfIllegalSex'] as bool? ?? false,
    historyOfHavingSTDs: json['historyOfHavingSTDs'] as bool? ?? false,
    historyOfPenileTrauma: json['historyOfPenileTrauma'] as bool? ?? false,
    historyMedication: json['historyMedication'] as bool? ?? false,
    historyOfPenileCurvature:
        json['historyOfPenileCurvature'] as bool? ?? false,
    pde5I: json['pde5I'] as String? ?? '',
    supplements: json['supplements'] as String? ?? '',
    hormones: json['hormones'] as String? ?? '',
    previousHormones: json['previousHormones'] as String? ?? '',
    previousGeneralLab: json['previousGeneralLab'] as String? ?? '',
    duplexPenileArteries: json['duplexPenileArteries'] as String? ?? '',
    testicularUS: json['testicularUS'] as String? ?? '',
    penileUS: json['penileUS'] as String? ?? '',
    trus: json['trus'] as String? ?? '',
    abdominopelvicUS: json['abdominopelvicUS'] as String? ?? '',
    durationOfMarriage: json['durationOfMarriage'] as String? ?? '',
    ageOfWife: json['ageOfWife'] as String? ?? '',
    multipleWives: json['multipleWives'] as bool? ?? false,
    durationOfInfertility: json['durationOfInfertility'] as String? ?? '',
    infertilityType: json['infertilityType'] as String? ?? '',
    previousConceptions: json['previousConceptions'] as bool? ?? false,
    historyOfVaricoceleGenitalSurgery:
        json['historyOfVaricoceleGenitalSurgery'] as String? ?? '',
    semenAnalysisSummary: json['semenAnalysisSummary'] as String? ?? '',
    hormonalProfile: json['hormonalProfile'] as String? ?? '',
    geneticOtherTests: json['geneticOtherTests'] as String? ?? '',
    urinaryFrequency: json['urinaryFrequency'] as String? ?? '',
    stream: json['stream'] as String? ?? '',
    nocturia: json['nocturia'] as String? ?? '',
    strainingOrIncompleteEmptying:
        json['strainingOrIncompleteEmptying'] as bool? ?? false,
    psaLevelDate: json['psaLevelDate'] as String? ?? '',
    trusProstatic: json['trusProstatic'] as String? ?? '',
    uroflowmetry: json['uroflowmetry'] as String? ?? '',
    generalAppearanceBMI: json['generalAppearanceBMI'] as String? ?? '',
    genitalExamination: json['genitalExamination'] as String? ?? '',
    testicularSizeConsistency:
        json['testicularSizeConsistency'] as String? ?? '',
    epididymisVas: json['epididymisVas'] as String? ?? '',
    digitalRectalExamination: json['digitalRectalExamination'] as String? ?? '',
    impressionDiagnosis: json['impressionDiagnosis'] as String? ?? '',
    recommendedInvestigations:
        json['recommendedInvestigations'] as String? ?? '',
    initialTreatmentPlan: json['initialTreatmentPlan'] as String? ?? '',
    followUpInterval: json['followUpInterval'] as String? ?? '',
  );
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String appointmentId;
  final DateTime createdAt;

  // I. Sexual Function Assessment
  final String libidoLevel; // normal / reduced / absent
  final String onsetOfErectileDifficulty; // sudden / gradual
  final String frequencyOfIntercourseAttempts;
  final String penetrationSuccess; // %
  final String erectionRigidity; // scale 1–5
  final String nocturnalMorningErections; // present / absent
  final String ejaculatoryFunction; // normal / premature / delayed / absent
  final String orgasmicSatisfaction; // normal / reduced / absent
  final String partnerSatisfaction; // normal / reduced / absent
  final String concernAboutPenileSize; // normal / reduced / absent
  final String opinionAboutPartnerSatisfaction; // normal / reduced / absent

  // Past Sexual History
  final bool pastHomosexualExperience;
  final bool interestedInHomosexuality;
  final bool historyOfSexualTraumaInChildhood;
  final bool historyOfPornoAddiction;
  final bool historyOfMasturbationAddiction;
  final bool historyOfIllegalSex;
  final bool historyOfHavingSTDs;
  final bool historyOfPenileTrauma;
  final bool historyMedication;
  final bool historyOfPenileCurvature;

  // Medications & Investigations (New Schema)
  final String pde5I;
  final String supplements;
  final String hormones;

  // History of Previous Investigations (Split)
  final String previousHormones;
  final String previousGeneralLab;

  // Radiology + and/or ICI (Split)
  final String duplexPenileArteries;
  final String testicularUS;
  final String penileUS;
  final String trus;
  final String abdominopelvicUS;

  // II. Infertility Evaluation
  final String durationOfMarriage; // years
  final String ageOfWife; // years
  final bool multipleWives;
  final String durationOfInfertility; // years
  final String infertilityType; // primary / secondary
  final bool previousConceptions;
  final String historyOfVaricoceleGenitalSurgery;
  final String semenAnalysisSummary;
  final String hormonalProfile; // FSH, LH, Testosterone, Prolactin
  final String geneticOtherTests;

  // III. Prostatic Symptoms
  final String urinaryFrequency; // day/night e.g., "5/2"
  final String stream; // normal / weak / intermittent
  final String nocturia; // times/night
  final bool strainingOrIncompleteEmptying;
  final String psaLevelDate;
  final String trusProstatic;
  final String uroflowmetry;

  // IV. Physical Examination
  final String generalAppearanceBMI;
  final String genitalExamination;
  final String testicularSizeConsistency;
  final String epididymisVas;
  final String digitalRectalExamination;

  // V. Impression & Management Plan
  final String impressionDiagnosis;
  final String recommendedInvestigations;
  final String initialTreatmentPlan;
  final String followUpInterval;

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'doctorId': doctorId,
    'doctorName': doctorName,
    'appointmentId': appointmentId,
    'createdAt': createdAt.toIso8601String(),
    'libidoLevel': libidoLevel,
    'onsetOfErectileDifficulty': onsetOfErectileDifficulty,
    'frequencyOfIntercourseAttempts': frequencyOfIntercourseAttempts,
    'penetrationSuccess': penetrationSuccess,
    'erectionRigidity': erectionRigidity,
    'nocturnalMorningErections': nocturnalMorningErections,
    'ejaculatoryFunction': ejaculatoryFunction,
    'orgasmicSatisfaction': orgasmicSatisfaction,
    'partnerSatisfaction': partnerSatisfaction,
    'concernAboutPenileSize': concernAboutPenileSize,
    'opinionAboutPartnerSatisfaction': opinionAboutPartnerSatisfaction,
    'pastHomosexualExperience': pastHomosexualExperience,
    'interestedInHomosexuality': interestedInHomosexuality,
    'historyOfSexualTraumaInChildhood': historyOfSexualTraumaInChildhood,
    'historyOfPornoAddiction': historyOfPornoAddiction,
    'historyOfMasturbationAddiction': historyOfMasturbationAddiction,
    'historyOfIllegalSex': historyOfIllegalSex,
    'historyOfHavingSTDs': historyOfHavingSTDs,
    'historyOfPenileTrauma': historyOfPenileTrauma,
    'historyMedication': historyMedication,
    'historyOfPenileCurvature': historyOfPenileCurvature,
    'pde5I': pde5I,
    'supplements': supplements,
    'hormones': hormones,
    'previousHormones': previousHormones,
    'previousGeneralLab': previousGeneralLab,
    'duplexPenileArteries': duplexPenileArteries,
    'testicularUS': testicularUS,
    'penileUS': penileUS,
    'trus': trus,
    'abdominopelvicUS': abdominopelvicUS,
    'durationOfMarriage': durationOfMarriage,
    'ageOfWife': ageOfWife,
    'multipleWives': multipleWives,
    'durationOfInfertility': durationOfInfertility,
    'infertilityType': infertilityType,
    'previousConceptions': previousConceptions,
    'historyOfVaricoceleGenitalSurgery': historyOfVaricoceleGenitalSurgery,
    'semenAnalysisSummary': semenAnalysisSummary,
    'hormonalProfile': hormonalProfile,
    'geneticOtherTests': geneticOtherTests,
    'urinaryFrequency': urinaryFrequency,
    'stream': stream,
    'nocturia': nocturia,
    'strainingOrIncompleteEmptying': strainingOrIncompleteEmptying,
    'psaLevelDate': psaLevelDate,
    'trusProstatic': trusProstatic,
    'uroflowmetry': uroflowmetry,
    'generalAppearanceBMI': generalAppearanceBMI,
    'genitalExamination': genitalExamination,
    'testicularSizeConsistency': testicularSizeConsistency,
    'epididymisVas': epididymisVas,
    'digitalRectalExamination': digitalRectalExamination,
    'impressionDiagnosis': impressionDiagnosis,
    'recommendedInvestigations': recommendedInvestigations,
    'initialTreatmentPlan': initialTreatmentPlan,
    'followUpInterval': followUpInterval,
  };
}
