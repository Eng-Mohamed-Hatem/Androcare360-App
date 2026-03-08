/// Imaging Request Model - نموذج طلب الأشعة
class ImagingRequestModel {
  ImagingRequestModel({
    required this.id,
    required this.appointmentId,
    required this.patientId,
    required this.doctorId,
    required this.imagingType,
    required this.bodyPart,
    required this.status,
    required this.requestedDate,
    this.completedDate,
    this.resultUrl,
    this.notes,
  });

  factory ImagingRequestModel.fromJson(Map<String, dynamic> json) =>
      ImagingRequestModel(
        id: json['id'] as String,
        appointmentId: json['appointmentId'] as String,
        patientId: json['patientId'] as String,
        doctorId: json['doctorId'] as String,
        imagingType: json['imagingType'] as String,
        bodyPart: json['bodyPart'] as String,
        status: ImagingStatus.values.firstWhere(
          (e) => e.toString() == 'ImagingStatus.${json['status']}',
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
  final String imagingType;
  final String bodyPart;
  final ImagingStatus status;
  final DateTime requestedDate;
  final DateTime? completedDate;
  final String? resultUrl;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'id': id,
    'appointmentId': appointmentId,
    'patientId': patientId,
    'doctorId': doctorId,
    'imagingType': imagingType,
    'bodyPart': bodyPart,
    'status': status.name,
    'requestedDate': requestedDate.toIso8601String(),
    'completedDate': completedDate?.toIso8601String(),
    'resultUrl': resultUrl,
    'notes': notes,
  };
}

/// Imaging Status - حالة الأشعة
enum ImagingStatus {
  pending, // قيد الانتظار
  scheduled, // مجدول
  completed, // مكتمل
  cancelled, // ملغي
}

/// Mock Imaging Requests
class MockImagingRequests {
  static List<ImagingRequestModel> getImagingRequests() => [
    ImagingRequestModel(
      id: '1',
      appointmentId: '1',
      patientId: '1',
      doctorId: '1',
      imagingType: 'أشعة سينية (X-Ray)',
      bodyPart: 'الصدر',
      status: ImagingStatus.completed,
      requestedDate: DateTime.now().subtract(const Duration(days: 15)),
      completedDate: DateTime.now().subtract(const Duration(days: 13)),
      resultUrl: 'chest_xray.pdf',
      notes: 'لا توجد مشاكل واضحة',
    ),
    ImagingRequestModel(
      id: '2',
      appointmentId: '2',
      patientId: '1',
      doctorId: '2',
      imagingType: 'أشعة مقطعية (CT Scan)',
      bodyPart: 'البطن',
      status: ImagingStatus.scheduled,
      requestedDate: DateTime.now().subtract(const Duration(days: 3)),
      notes: 'موعد الأشعة: غداً الساعة 2:00 مساءً',
    ),
    ImagingRequestModel(
      id: '3',
      appointmentId: '3',
      patientId: '1',
      doctorId: '1',
      imagingType: 'رنين مغناطيسي (MRI)',
      bodyPart: 'الركبة',
      status: ImagingStatus.pending,
      requestedDate: DateTime.now().subtract(const Duration(days: 1)),
      notes: 'في انتظار تحديد الموعد',
    ),
  ];
}
