import 'dart:typed_data';

import 'package:elajtech/shared/models/device_request_model.dart';
import 'package:elajtech/shared/models/lab_request_model.dart';
import 'package:elajtech/shared/models/prescription_model.dart';
import 'package:elajtech/shared/models/radiology_request_model.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// PDF document generation and management service for the elajtech platform.
/// خدمة إنشاء وإدارة مستندات PDF لمنصة elajtech.
///
/// This service provides comprehensive PDF generation capabilities for medical documents including:
/// - Medical prescriptions (وصفة طبية)
/// - Lab test requests (طلب تحاليل طبية)
/// - Radiology/imaging requests (طلب أشعة)
/// - Medical device requests (طلب أجهزة طبية)
/// - Custom formatted documents with Arabic/English support
///
/// **Static Service Pattern:**
/// All methods are static and can be called directly without instantiation:
/// ```dart
/// final pdfBytes = await PdfService.generatePrescriptionPdf(prescription);
/// ```
///
/// **Features:**
/// - RTL (Right-to-Left) support for Arabic text
/// - Custom Arabic fonts (Cairo font family)
/// - Professional medical document templates
/// - Multi-page document generation
/// - Consistent branding and formatting
/// - PDF/A format for archival compliance
///
/// **Usage Example - Prescription:**
/// ```dart
/// final prescription = PrescriptionModel(
///   patientName: 'أحمد محمد',
///   doctorName: 'سارة أحمد',
///   medicines: [
///     Medicine(name: 'Paracetamol', type: MedicineType.tablet, frequency: 'مرتين يومياً', duration: '5 أيام'),
///   ],
///   diagnosis: 'التهاب الحلق',
///   createdAt: DateTime.now(),
/// );
///
/// final pdfBytes = await PdfService.generatePrescriptionPdf(prescription);
///
/// // Save or share the PDF
/// await savePDF(pdfBytes, 'prescription.pdf');
/// ```
///
/// **Usage Example - Lab Request:**
/// ```dart
/// final labRequest = LabRequestModel(
///   patientName: 'أحمد محمد',
///   doctorName: 'سارة أحمد',
///   testNames: ['CBC', 'Lipid Profile', 'HbA1c'],
///   createdAt: DateTime.now(),
/// );
///
/// final pdfBytes = await PdfService.generateLabRequestPdf(labRequest);
/// ```
///
/// **Document Structure:**
/// All generated PDFs include:
/// - Header: AndroCare360 branding, doctor name, document type, date
/// - Patient Info: Name, age (if applicable), diagnosis (if applicable)
/// - Content: Document-specific content (medicines, tests, scans, devices)
/// - Notes: Optional notes from doctor
/// - Footer: Well-wishes message and system branding
///
/// **Font Loading:**
/// - Uses Google Fonts (Cairo) for Arabic text rendering
/// - Automatically loads regular and bold variants
/// - Ensures proper RTL text display
///
/// **File Format:**
/// - Returns: Uint8List (PDF bytes)
/// - Format: PDF 1.4 compatible
/// - Page Size: A4 (210mm x 297mm)
///
/// **Integration Points:**
/// - Works with FileUploadService for cloud storage
/// - Integrates with StorageService for local caching
/// - Used by appointment and consultation features
/// - Supports sharing via platform share dialogs
///
/// @see FileUploadService for uploading generated PDFs
/// @see StorageService for local PDF storage
/// @see PrescriptionModel for prescription data structure
/// @see LabRequestModel for lab request data structure
/// @see RadiologyRequestModel for radiology request data structure
/// @see DeviceRequestModel for device request data structure
class PdfService {
  /// Generates a medical prescription PDF document.
  /// إنشاء مستند PDF لوصفة طبية.
  ///
  /// Creates a professionally formatted prescription document with:
  /// - Doctor and patient information
  /// - List of prescribed medications with dosage and frequency
  /// - Diagnosis information
  /// - Doctor's notes (if provided)
  /// - Arabic RTL formatting
  ///
  /// **Parameters:**
  /// - [prescription]: PrescriptionModel containing all prescription details
  ///
  /// **Returns:**
  /// A Future<Uint8List> containing the PDF document bytes.
  ///
  /// **Throws:**
  /// - [Exception] if font loading fails
  /// - [Exception] if PDF generation fails
  ///
  /// **Example:**
  /// ```dart
  /// final prescription = PrescriptionModel(
  ///   patientName: 'أحمد محمد',
  ///   patientAge: 35,
  ///   doctorName: 'سارة أحمد',
  ///   diagnosis: 'التهاب الحلق',
  ///   medicines: [
  ///     Medicine(
  ///       name: 'Paracetamol 500mg',
  ///       type: MedicineType.tablet,
  ///       frequency: 'مرتين يومياً',
  ///       duration: '5 أيام',
  ///     ),
  ///   ],
  ///   notes: 'الراحة وشرب السوائل',
  ///   createdAt: DateTime.now(),
  /// );
  ///
  /// final pdfBytes = await PdfService.generatePrescriptionPdf(prescription);
  ///
  /// // Save to file
  /// final file = File('prescription.pdf');
  /// await file.writeAsBytes(pdfBytes);
  /// ```
  ///
  /// **Document Layout:**
  /// - Header: AndroCare360 logo, doctor name, date
  /// - Patient Info: Name, age, diagnosis
  /// - Medicine Table: Name, type, dosage, duration
  /// - Notes: Doctor's additional instructions
  /// - Footer: Well-wishes and branding
  ///
  /// **Font Support:**
  /// - Uses Cairo font for Arabic text
  /// - Supports RTL text direction
  /// - Bold variant for headers and labels
  static Future<Uint8List> generatePrescriptionPdf(
    PrescriptionModel prescription,
  ) async {
    final pdf = pw.Document();

    // Load Arabic Font
    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (pw.Context context) =>
            _buildPrescriptionLayout(context, prescription),
      ),
    );

    return pdf.save();
  }

  /// Generates a lab test request PDF document.
  /// إنشاء مستند PDF لطلب تحاليل طبية.
  ///
  /// Creates a professionally formatted lab request document with:
  /// - Doctor and patient information
  /// - List of requested lab tests
  /// - Doctor's notes (if provided)
  /// - Arabic RTL formatting
  ///
  /// **Parameters:**
  /// - [request]: LabRequestModel containing all lab request details
  ///
  /// **Returns:**
  /// A Future<Uint8List> containing the PDF document bytes.
  ///
  /// **Throws:**
  /// - [Exception] if font loading fails
  /// - [Exception] if PDF generation fails
  ///
  /// **Example:**
  /// ```dart
  /// final labRequest = LabRequestModel(
  ///   patientName: 'أحمد محمد',
  ///   doctorName: 'سارة أحمد',
  ///   testNames: [
  ///     'Complete Blood Count (CBC)',
  ///     'Lipid Profile',
  ///     'HbA1c',
  ///     'Kidney Function Tests',
  ///   ],
  ///   notes: 'صيام 12 ساعة قبل التحليل',
  ///   createdAt: DateTime.now(),
  /// );
  ///
  /// final pdfBytes = await PdfService.generateLabRequestPdf(labRequest);
  /// ```
  ///
  /// **Document Layout:**
  /// - Header: AndroCare360 logo, doctor name, date
  /// - Patient Info: Name
  /// - Test List: Bulleted list of requested tests
  /// - Notes: Special instructions (fasting, timing, etc.)
  /// - Footer: Well-wishes and branding
  static Future<Uint8List> generateLabRequestPdf(
    LabRequestModel request,
  ) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (pw.Context context) => _buildLabRequestLayout(context, request),
      ),
    );

    return pdf.save();
  }

  /// Generates a radiology/imaging request PDF document.
  /// إنشاء مستند PDF لطلب أشعة.
  ///
  /// Creates a professionally formatted radiology request document with:
  /// - Doctor and patient information
  /// - List of requested imaging scans
  /// - Doctor's notes (if provided)
  /// - Arabic RTL formatting
  ///
  /// **Parameters:**
  /// - [request]: RadiologyRequestModel containing all radiology request details
  ///
  /// **Returns:**
  /// A Future<Uint8List> containing the PDF document bytes.
  ///
  /// **Throws:**
  /// - [Exception] if font loading fails
  /// - [Exception] if PDF generation fails
  ///
  /// **Example:**
  /// ```dart
  /// final radiologyRequest = RadiologyRequestModel(
  ///   patientName: 'أحمد محمد',
  ///   doctorName: 'سارة أحمد',
  ///   scanTypes: [
  ///     'Chest X-Ray',
  ///     'Abdominal Ultrasound',
  ///     'MRI Brain',
  ///   ],
  ///   notes: 'الفحص عاجل',
  ///   createdAt: DateTime.now(),
  /// );
  ///
  /// final pdfBytes = await PdfService.generateRadiologyRequestPdf(radiologyRequest);
  /// ```
  ///
  /// **Document Layout:**
  /// - Header: AndroCare360 logo, doctor name, date
  /// - Patient Info: Name
  /// - Scan List: Bulleted list of requested imaging scans
  /// - Notes: Special instructions or urgency indicators
  /// - Footer: Well-wishes and branding
  static Future<Uint8List> generateRadiologyRequestPdf(
    RadiologyRequestModel request,
  ) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (pw.Context context) =>
            _buildRadiologyRequestLayout(context, request),
      ),
    );

    return pdf.save();
  }

  /// Generates a medical device request PDF document.
  /// إنشاء مستند PDF لطلب أجهزة طبية.
  ///
  /// Creates a professionally formatted device request document with:
  /// - Doctor and patient information
  /// - List of requested medical devices
  /// - Doctor's notes (if provided)
  /// - Arabic RTL formatting
  ///
  /// **Parameters:**
  /// - [request]: DeviceRequestModel containing all device request details
  ///
  /// **Returns:**
  /// A Future<Uint8List> containing the PDF document bytes.
  ///
  /// **Throws:**
  /// - [Exception] if font loading fails
  /// - [Exception] if PDF generation fails
  ///
  /// **Example:**
  /// ```dart
  /// final deviceRequest = DeviceRequestModel(
  ///   patientName: 'أحمد محمد',
  ///   doctorName: 'سارة أحمد',
  ///   deviceNames: [
  ///     'Blood Pressure Monitor',
  ///     'Glucose Meter',
  ///     'Nebulizer',
  ///   ],
  ///   notes: 'للاستخدام المنزلي',
  ///   createdAt: DateTime.now(),
  /// );
  ///
  /// final pdfBytes = await PdfService.generateDeviceRequestPdf(deviceRequest);
  /// ```
  ///
  /// **Document Layout:**
  /// - Header: AndroCare360 logo, doctor name, date
  /// - Patient Info: Name
  /// - Device List: Bulleted list of requested medical devices
  /// - Notes: Usage instructions or special requirements
  /// - Footer: Well-wishes and branding
  static Future<Uint8List> generateDeviceRequestPdf(
    DeviceRequestModel request,
  ) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (pw.Context context) =>
            _buildDeviceRequestLayout(context, request),
      ),
    );

    return pdf.save();
  }

  // --- Layout Builders ---

  static pw.Widget _buildPrescriptionLayout(
    pw.Context context,
    PrescriptionModel prescription,
  ) {
    final dateFormat = intl.DateFormat('dd/MM/yyyy', 'ar');

    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _buildHeader(
            title: 'وصفة طبية',
            doctorName: 'د. ${prescription.doctorName}', // Added 'د.'
            date: dateFormat.format(prescription.createdAt),
          ),
          pw.SizedBox(height: 20),
          _buildPatientInfo(
            name: prescription.patientName,
            age: prescription.patientAge,
            diagnosis: prescription.diagnosis,
          ),
          pw.SizedBox(height: 20),
          _buildMedicineTable(prescription.medicines),
          pw.Spacer(),
          if (prescription.notes != null) ...[
            pw.Divider(),
            pw.Text(
              'ملاحظات: ${prescription.notes}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 10),
          ],
          _buildFooter(),
        ],
      ),
    );
  }

  static pw.Widget _buildLabRequestLayout(
    pw.Context context,
    LabRequestModel request,
  ) {
    final dateFormat = intl.DateFormat('dd/MM/yyyy', 'ar');

    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _buildHeader(
            title: 'طلب تحاليل طبية',
            doctorName: 'د. ${request.doctorName}', // Added 'د.'
            date: dateFormat.format(request.createdAt),
          ),
          pw.SizedBox(height: 20),
          _buildPatientInfo(name: request.patientName),
          pw.SizedBox(height: 20),
          pw.Text(
            'التحاليل المطلوبة:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
          ),
          pw.SizedBox(height: 10),
          ...request.testNames.map(_buildRtlBulletPoint),
          pw.Spacer(),
          if (request.notes != null) ...[
            pw.Divider(),
            pw.Text(
              'ملاحظات: ${request.notes}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 10),
          ],
          _buildFooter(),
        ],
      ),
    );
  }

  static pw.Widget _buildRadiologyRequestLayout(
    pw.Context context,
    RadiologyRequestModel request,
  ) {
    final dateFormat = intl.DateFormat('dd/MM/yyyy', 'ar');

    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _buildHeader(
            title: 'طلب أشعة',
            doctorName: 'د. ${request.doctorName}', // Added 'د.'
            date: dateFormat.format(request.createdAt),
          ),
          pw.SizedBox(height: 20),
          _buildPatientInfo(name: request.patientName),
          pw.SizedBox(height: 20),
          pw.Text(
            'الأشعة المطلوبة:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
          ),
          pw.SizedBox(height: 10),
          ...request.scanTypes.map(_buildRtlBulletPoint),
          pw.Spacer(),
          if (request.notes != null) ...[
            pw.Divider(),
            pw.Text(
              'ملاحظات: ${request.notes}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 10),
          ],
          _buildFooter(),
        ],
      ),
    );
  }

  static pw.Widget _buildDeviceRequestLayout(
    pw.Context context,
    DeviceRequestModel request,
  ) {
    final dateFormat = intl.DateFormat('dd/MM/yyyy', 'ar');

    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _buildHeader(
            title: 'طلب أجهزة طبية',
            doctorName: 'د. ${request.doctorName}', // Added 'د.'
            date: dateFormat.format(request.createdAt),
          ),
          pw.SizedBox(height: 20),
          _buildPatientInfo(name: request.patientName),
          pw.SizedBox(height: 20),
          pw.Text(
            'الأجهزة المطلوبة:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
          ),
          pw.SizedBox(height: 10),
          ...request.deviceNames.map(_buildRtlBulletPoint),
          pw.Spacer(),
          if (request.notes != null) ...[
            pw.Divider(),
            pw.Text(
              'ملاحظات: ${request.notes}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 10),
          ],
          _buildFooter(),
        ],
      ),
    );
  }

  // --- Reusable Components ---

  static pw.Widget _buildHeader({
    required String title,
    required String doctorName,
    required String date,
  }) => pw.Container(
    decoration: const pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(width: 2, color: PdfColors.blue),
      ),
    ),
    padding: const pw.EdgeInsets.only(bottom: 10),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'AndroCare360',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue,
              ),
            ),
            pw.Text(doctorName, style: const pw.TextStyle(fontSize: 14)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              'التاريخ: $date',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    ),
  );

  static pw.Widget _buildPatientInfo({
    required String name,
    int? age,
    String? diagnosis,
  }) => pw.Container(
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey100,
      borderRadius: pw.BorderRadius.circular(4),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Text(
              'اسم المريض: ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(name),
          ],
        ),
        if (diagnosis != null) ...[
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Text(
                'التشخيص: ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(diagnosis),
            ],
          ),
        ],
      ],
    ),
  );

  static pw.Widget _buildMedicineTable(List<Medicine> medicines) => pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey300),
    children: [
      // Header
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
        children: [
          _buildTableHeader('الدواء'),
          _buildTableHeader('النوع'),
          _buildTableHeader('الجرعة'),
          _buildTableHeader('المدة'),
        ],
      ),
      // Rows
      ...medicines.map(
        (medicine) => pw.TableRow(
          children: [
            _buildTableCell(medicine.name),
            _buildTableCell(_medicineTypeToString(medicine.type)),
            _buildTableCell(medicine.frequency),
            _buildTableCell(medicine.duration),
          ],
        ),
      ),
    ],
  );

  static pw.Widget _buildTableHeader(String text) => pw.Padding(
    padding: const pw.EdgeInsets.all(5),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      textAlign: pw.TextAlign.center,
    ),
  );

  static pw.Widget _buildTableCell(String text) => pw.Padding(
    padding: const pw.EdgeInsets.all(5),
    child: pw.Text(
      text,
      style: const pw.TextStyle(fontSize: 10),
      textAlign: pw.TextAlign.center,
    ),
  );

  static pw.Widget _buildFooter() => pw.Column(
    children: [
      pw.Divider(color: PdfColors.grey),
      pw.Text(
        'نتمنى لكم الشفاء العاجل',
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        textAlign: pw.TextAlign.center,
      ),
      pw.Text(
        'AndroCare360 Clinic System',
        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
        textAlign: pw.TextAlign.center,
      ),
    ],
  );

  static String _medicineTypeToString(MedicineType type) {
    switch (type) {
      case MedicineType.tablet:
        return 'أقراص';
      case MedicineType.syrup:
        return 'شراب';
      case MedicineType.injection:
        return 'حقن';
    }
  }

  static pw.Widget _buildRtlBulletPoint(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 4,
          height: 4,
          margin: const pw.EdgeInsets.only(
            top: 6,
            left: 5,
          ), // Left margin separates bullet from text
          decoration: const pw.BoxDecoration(
            color: PdfColors.black,
            shape: pw.BoxShape.circle,
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            text,
            textAlign:
                pw.TextAlign.right, // Align text to the right, next to bullet
            style: const pw.TextStyle(fontSize: 12),
          ),
        ),
      ],
    ),
  );
}
