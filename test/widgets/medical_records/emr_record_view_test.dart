import 'package:elajtech/shared/models/emr_model.dart';
import 'package:elajtech/shared/widgets/emr/emr_record_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final mockEmr = EMRModel(
    id: 'emr_123',
    patientId: 'patient_456',
    appointmentId: 'apt_789',
    doctorId: 'doc_101',
    doctorName: 'Dr. Test',
    libidoLevel: 'Normal',
    onsetOfErectileDifficulty: 'Gradual',
    frequencyOfIntercourseAttempts: '2 times/week',
    penetrationSuccess: '100%',
    erectionRigidity: '4',
    nocturnalMorningErections: 'Present',
    ejaculatoryFunction: 'Normal',
    orgasmicSatisfaction: 'Good',
    partnerSatisfaction: 'Good',
    concernAboutPenileSize: 'None',
    opinionAboutPartnerSatisfaction: 'Satisfied',
    pastHomosexualExperience: false,
    interestedInHomosexuality: false,
    historyOfSexualTraumaInChildhood: false,
    historyOfPornoAddiction: true, // Should show with checkmark
    historyOfMasturbationAddiction: false,
    historyOfIllegalSex: false,
    historyOfHavingSTDs: false,
    historyOfPenileTrauma: false,
    historyMedication: false,
    historyOfPenileCurvature: false,
    pde5I: 'None',
    supplements: 'None',
    hormones: 'None',
    previousHormones: 'None',
    previousGeneralLab: 'Normal',
    duplexPenileArteries: 'Normal',
    testicularUS: 'Normal',
    penileUS: 'Normal',
    trus: 'Normal',
    abdominopelvicUS: 'Normal',
    durationOfMarriage: '5 years',
    ageOfWife: '30',
    multipleWives: false,
    durationOfInfertility: 'None',
    infertilityType: 'Primary',
    previousConceptions: true,
    historyOfVaricoceleGenitalSurgery: 'None',
    semenAnalysisSummary: 'Normal',
    hormonalProfile: 'Normal',
    geneticOtherTests: 'None',
    urinaryFrequency: 'Normal',
    stream: 'Normal',
    nocturia: '0',
    strainingOrIncompleteEmptying: false,
    psaLevelDate: 'Normal',
    trusProstatic: 'Normal',
    uroflowmetry: 'Normal',
    generalAppearanceBMI: 'Normal',
    genitalExamination: 'Normal',
    testicularSizeConsistency: 'Normal',
    epididymisVas: 'Normal',
    digitalRectalExamination: 'Normal',
    impressionDiagnosis: 'Healthy',
    recommendedInvestigations: 'None',
    initialTreatmentPlan: 'None',
    followUpInterval: 'None',
    createdAt: DateTime(2024, 3, 10),
  );

  testWidgets('EmrRecordView displays record data correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EmrRecordView(record: mockEmr),
          ),
        ),
      ),
    );

    // Verify sections are present
    expect(find.text('I. Sexual Function Assessment'), findsOneWidget);
    expect(find.text('II. Past Sexual History'), findsOneWidget);
    expect(find.text('III. Infertility Evaluation'), findsOneWidget);

    // Verify item data
    expect(find.text('Libido Level:'), findsOneWidget);
    expect(find.text('Normal'), findsAtLeastNWidgets(1));

    // Verify boolean item (Porno Addiction is true)
    expect(find.text('Porno Addiction'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsAtLeastNWidgets(1));

    // Verify subsection headers
    expect(find.text('Medications'), findsOneWidget);
  });
}
