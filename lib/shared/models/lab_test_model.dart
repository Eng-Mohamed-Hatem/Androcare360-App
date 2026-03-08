/// Lab Test Model - نموذج التحليل المعملي
class LabTestModel {
  LabTestModel({
    required this.id,
    required this.appointmentId,
    required this.patientId,
    required this.doctorId,
    required this.testName,
    required this.testType,
    required this.status,
    required this.requestedDate,
    this.completedDate,
    this.resultUrl,
    this.notes,
  });

  factory LabTestModel.fromJson(Map<String, dynamic> json) => LabTestModel(
    id: json['id'] as String,
    appointmentId: json['appointmentId'] as String,
    patientId: json['patientId'] as String,
    doctorId: json['doctorId'] as String,
    testName: json['testName'] as String,
    testType: json['testType'] as String,
    status: LabTestStatus.values.firstWhere(
      (e) => e.toString() == 'LabTestStatus.${json['status']}',
    ),
    requestedDate: DateTime.parse(json['requestedDate'] as String),
    completedDate: json['completedDate'] != null
        ? DateTime.parse(json['completedDate'] as String)
        : null,
    resultUrl: json['resultUrl'] as String?,
    notes: json['notes'] as String?,
  );
  final String id;
  final String appointmentId;
  final String patientId;
  final String doctorId;
  final String testName;
  final String testType;
  final LabTestStatus status;
  final DateTime requestedDate;
  final DateTime? completedDate;
  final String? resultUrl;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'id': id,
    'appointmentId': appointmentId,
    'patientId': patientId,
    'doctorId': doctorId,
    'testName': testName,
    'testType': testType,
    'status': status.name,
    'requestedDate': requestedDate.toIso8601String(),
    'completedDate': completedDate?.toIso8601String(),
    'resultUrl': resultUrl,
    'notes': notes,
  };
}

/// Lab Test Status - حالة التحليل
enum LabTestStatus {
  pending, // قيد الانتظار
  inProgress, // قيد التنفيذ
  completed, // مكتمل
  cancelled, // ملغي
}

/// Mock Lab Tests
class MockLabTests {
  static List<LabTestModel> getLabTests() => [
    LabTestModel(
      id: '1',
      appointmentId: '1',
      patientId: '1',
      doctorId: '1',
      testName: 'تحليل دم شامل (CBC)',
      testType: 'Blood Test',
      status: LabTestStatus.completed,
      requestedDate: DateTime.now().subtract(const Duration(days: 10)),
      completedDate: DateTime.now().subtract(const Duration(days: 8)),
      resultUrl: 'cbc_result.pdf',
      notes: 'النتائج طبيعية',
    ),
    LabTestModel(
      id: '2',
      appointmentId: '2',
      patientId: '1',
      doctorId: '2',
      testName: 'تحليل فيتامين د',
      testType: 'Blood Test',
      status: LabTestStatus.pending,
      requestedDate: DateTime.now().subtract(const Duration(days: 5)),
      notes: 'يرجى الصيام 8 ساعات قبل التحليل',
    ),
    LabTestModel(
      id: '3',
      appointmentId: '3',
      patientId: '1',
      doctorId: '1',
      testName: 'تحليل وظائف الكلى',
      testType: 'Blood Test',
      status: LabTestStatus.inProgress,
      requestedDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
}
