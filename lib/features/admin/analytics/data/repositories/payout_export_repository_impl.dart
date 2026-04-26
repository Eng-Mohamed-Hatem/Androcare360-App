import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/admin/analytics/data/models/payout_report_model.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/payout_report.dart';
import 'package:elajtech/features/admin/analytics/domain/repositories/payout_export_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

/// تنفيذ مستودع تصدير المستحقات — calls exportPayoutReport CF, generates PDF/Excel.
@LazySingleton(as: PayoutExportRepository)
class PayoutExportRepositoryImpl implements PayoutExportRepository {
  const PayoutExportRepositoryImpl(this._functions);

  final FirebaseFunctions _functions;

  static final _currencyFmt = NumberFormat.currency(
    locale: 'ar',
    symbol: 'ر.س ',
    decimalDigits: 2,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // getPayoutReportData
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PayoutReport>> getPayoutReportData({
    required String doctorId,
    required int year,
    required int month,
  }) async {
    try {
      final result = await _functions
          .httpsCallable('exportPayoutReport')
          .call<Map<String, dynamic>>({
            'doctorId': doctorId,
            'year': year,
            'month': month,
          });

      final data = Map<String, dynamic>.from(result.data as Map);
      if (kDebugMode) {
        debugPrint(
          '[PayoutExport] getPayoutReportData doctorId=$doctorId year=$year month=$month entries=${(data['entries'] as List?)?.length ?? 0}',
        );
      }
      return Right(PayoutReportModel.fromCfResponse(data).toDomain());
    } on FirebaseFunctionsException catch (e, st) {
      debugPrint(
        '[PayoutExport] getPayoutReportData error: ${e.code} ${e.message}',
      );
      debugPrint(st.toString());
      if (e.code == 'not-found') {
        return const Left(Failure.app('لا توجد بيانات لهذه الفترة'));
      }
      return Left(
        Failure.firestore(e.message ?? 'Failed to load payout report'),
      );
    } on Object catch (e, st) {
      debugPrint('[PayoutExport] getPayoutReportData unexpected: $e');
      debugPrint(st.toString());
      return Left(Failure.unexpected(e.toString()));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // generatePdf
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, String>> generatePdf(PayoutReport report) async {
    try {
      final arabicFont = pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf'),
      );
      final arabicBoldFont = pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoNaskhArabic-Bold.ttf'),
      );
      final pdf = pw.Document()
        ..addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            textDirection: pw.TextDirection.rtl,
            theme: pw.ThemeData.withFont(
              base: arabicFont,
              bold: arabicBoldFont,
            ),
            build: (context) => [
              _buildPdfHeader(report),
              pw.SizedBox(height: 16),
              _buildPdfDoctorInfo(report),
              pw.SizedBox(height: 16),
              _buildPdfTable(report),
              pw.SizedBox(height: 16),
              _buildPdfFooter(report),
            ],
          ),
        );

      final bytes = await pdf.save();
      final fileName =
          'payout_${report.doctorId}_${report.period.start.year}_${report.period.start.month}.pdf';
      try {
        await Printing.sharePdf(bytes: bytes, filename: fileName);
      } on Object catch (e) {
        if (kDebugMode) {
          debugPrint('[PayoutExport] PDF share skipped: $e');
        }
      }
      final path = await _resolveFilePath(fileName);
      final file = File(path);
      await file.writeAsBytes(bytes);

      if (kDebugMode) {
        debugPrint('[PayoutExport] PDF saved: $path');
      }
      return Right(path);
    } on Object catch (e, st) {
      debugPrint('[PayoutExport] generatePdf error: $e');
      debugPrint(st.toString());
      return Left(Failure.unexpected(e.toString()));
    }
  }

  pw.Widget _buildPdfHeader(PayoutReport report) => pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(
        'تقرير المستحقات الشهري',
        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        textDirection: pw.TextDirection.rtl,
      ),
      pw.Text(
        'AndroCare360',
        style: const pw.TextStyle(fontSize: 14),
      ),
    ],
  );

  pw.Widget _buildPdfDoctorInfo(PayoutReport report) => pw.Container(
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey400),
      borderRadius: pw.BorderRadius.circular(4),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(
          'الطبيب: ${report.doctorName}',
          textDirection: pw.TextDirection.rtl,
        ),
        pw.Text(
          'التخصص: ${report.specialty}',
          textDirection: pw.TextDirection.rtl,
        ),
        pw.Text(
          'الفترة: ${DateFormat('yyyy-MM-dd').format(report.period.start)} – ${DateFormat('yyyy-MM-dd').format(report.period.end)}',
          textDirection: pw.TextDirection.rtl,
        ),
      ],
    ),
  );

  pw.Widget _buildPdfTable(PayoutReport report) {
    const headers = [
      'المبلغ الصافي',
      'العمولة',
      'الرسوم',
      'الحالة',
      'المريض',
      'التاريخ',
    ];
    final rows = report.entries
        .map(
          (e) => [
            _currencyFmt.format(e.netAmount),
            _currencyFmt.format(e.commission),
            _currencyFmt.format(e.fee),
            e.status,
            e.patientName,
            DateFormat('yyyy-MM-dd').format(e.appointmentDate),
          ],
        )
        .toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
      ),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.center,
    );
  }

  pw.Widget _buildPdfFooter(PayoutReport report) => pw.Container(
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey100,
      borderRadius: pw.BorderRadius.circular(4),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(
          'إجمالي الإيرادات: ${_currencyFmt.format(report.totalRevenue)}',
          textDirection: pw.TextDirection.rtl,
        ),
        pw.Text(
          'إجمالي العمولات: ${_currencyFmt.format(report.totalCommission)}',
          textDirection: pw.TextDirection.rtl,
        ),
        pw.Text(
          'إجمالي المستحق الصافي: ${_currencyFmt.format(report.totalNetPayout)}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          textDirection: pw.TextDirection.rtl,
        ),
      ],
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // generateExcel
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, String>> generateExcel(PayoutReport report) async {
    try {
      final workbook = xlsio.Workbook();
      final sheet = workbook.worksheets[0]..name = 'تقرير المستحقات';

      // Headers
      const headers = [
        'التاريخ',
        'المريض',
        'الحالة',
        'الرسوم',
        'العمولة',
        'المبلغ الصافي',
      ];
      for (var i = 0; i < headers.length; i++) {
        sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
        sheet.getRangeByIndex(1, i + 1).cellStyle.bold = true;
      }

      // Data rows
      for (var i = 0; i < report.entries.length; i++) {
        final entry = report.entries[i];
        final row = i + 2;
        sheet
            .getRangeByIndex(row, 1)
            .setText(
              DateFormat('yyyy-MM-dd').format(entry.appointmentDate),
            );
        sheet.getRangeByIndex(row, 2).setText(entry.patientName);
        sheet.getRangeByIndex(row, 3).setText(entry.status);
        sheet.getRangeByIndex(row, 4).setNumber(entry.fee);
        sheet.getRangeByIndex(row, 5).setNumber(entry.commission);
        sheet.getRangeByIndex(row, 6).setNumber(entry.netAmount);
      }

      // Summary row
      final summaryRow = report.entries.length + 3;
      sheet.getRangeByIndex(summaryRow, 1).setText('الإجمالي');
      sheet.getRangeByIndex(summaryRow, 1).cellStyle.bold = true;
      sheet.getRangeByIndex(summaryRow, 4).setNumber(report.totalRevenue);
      sheet.getRangeByIndex(summaryRow, 5).setNumber(report.totalCommission);
      sheet.getRangeByIndex(summaryRow, 6).setNumber(report.totalNetPayout);

      final bytes = workbook.saveAsStream();
      workbook.dispose();

      final path = await _resolveFilePath(
        'payout_${report.doctorId}_${report.period.start.year}_${report.period.start.month}.xlsx',
      );
      final file = File(path);
      await file.writeAsBytes(bytes);

      if (kDebugMode) {
        debugPrint('[PayoutExport] Excel saved: $path');
      }
      return Right(path);
    } on Object catch (e, st) {
      debugPrint('[PayoutExport] generateExcel error: $e');
      debugPrint(st.toString());
      return Left(Failure.unexpected(e.toString()));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // recordPayout
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Unit>> recordPayout({
    required String doctorId,
    required double amount,
    String? note,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[PayoutExport] recordPayout doctorId=$doctorId amount=$amount',
        );
      }
      await _functions.httpsCallable('recordPayout').call<Map<String, dynamic>>(
        {
          'doctorId': doctorId,
          'amount': amount,
          'currency': 'SAR',
          'note': note,
        },
      );
      return const Right(unit);
    } on FirebaseFunctionsException catch (e, st) {
      debugPrint('[PayoutExport] recordPayout error: ${e.code} ${e.message}');
      debugPrint(st.toString());
      return Left(Failure.firestore(e.message ?? 'Failed to record payout'));
    } on Object catch (e, st) {
      debugPrint('[PayoutExport] recordPayout unexpected: $e');
      debugPrint(st.toString());
      return Left(Failure.unexpected(e.toString()));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  Future<String> _resolveFilePath(String fileName) async {
    return '${Directory.systemTemp.path}/$fileName';
  }
}
