/// Medical Record Model - نموذج السجل الطبي
class MedicalRecordModel {
  MedicalRecordModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.date,
    required this.diagnosis,
    required this.symptoms,
    required this.attachments,
    required this.type,
    this.prescription,
  });

  /// From JSON
  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) =>
      MedicalRecordModel(
        id: json['id'] as String,
        patientId: json['patientId'] as String,
        doctorId: json['doctorId'] as String,
        doctorName: json['doctorName'] as String,
        date: DateTime.parse(json['date'] as String),
        diagnosis: json['diagnosis'] as String,
        symptoms: json['symptoms'] as String,
        prescription: json['prescription'] as String?,
        attachments: List<String>.from(json['attachments'] as List),
        type: RecordType.values.firstWhere(
          (e) => e.toString() == 'RecordType.${json['type']}',
        ),
      );
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final DateTime date;
  final String diagnosis;
  final String symptoms;
  final String? prescription;
  final List<String> attachments;
  final RecordType type;

  /// To JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'doctorId': doctorId,
    'doctorName': doctorName,
    'date': date.toIso8601String(),
    'diagnosis': diagnosis,
    'symptoms': symptoms,
    'prescription': prescription,
    'attachments': attachments,
    'type': type.name,
  };
}

/// Record Type - نوع السجل
enum RecordType {
  consultation, // استشارة
  labTest, // تحليل
  imaging, // أشعة
  prescription, // وصفة طبية
}

/// Mock Medical Records
class MockMedicalRecords {
  static List<MedicalRecordModel> getRecords() => [
    MedicalRecordModel(
      id: '1',
      patientId: '1',
      doctorId: '1',
      doctorName: 'د. أحمد محمد',
      date: DateTime.now().subtract(const Duration(days: 7)),
      diagnosis: 'التهاب في الجهاز التنفسي',
      symptoms: 'سعال، حمى، صداع',
      prescription: 'مضاد حيوي، خافض للحرارة',
      attachments: [],
      type: RecordType.consultation,
    ),
    MedicalRecordModel(
      id: '2',
      patientId: '1',
      doctorId: '2',
      doctorName: 'د. سارة علي',
      date: DateTime.now().subtract(const Duration(days: 14)),
      diagnosis: 'فحص دوري',
      symptoms: 'لا يوجد',
      prescription: 'فيتامينات',
      attachments: [],
      type: RecordType.consultation,
    ),
    MedicalRecordModel(
      id: '3',
      patientId: '1',
      doctorId: '1',
      doctorName: 'د. أحمد محمد',
      date: DateTime.now().subtract(const Duration(days: 30)),
      diagnosis: 'تحليل دم شامل',
      symptoms: 'فحص دوري',
      attachments: ['lab_result.pdf'],
      type: RecordType.labTest,
    ),
  ];
}
