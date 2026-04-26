import 'package:dartz/dartz.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/admin_alert.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/date_range.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/doctor_analytics.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/financial_summary.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/payout_report.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/performance_score.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/platform_summary.dart';
import 'package:elajtech/features/admin/analytics/domain/repositories/analytics_repository.dart';
import 'package:elajtech/features/admin/analytics/domain/repositories/payout_export_repository.dart';

AnalyticsDateRange testPeriod() => AnalyticsDateRange(
  start: DateTime.utc(2026, 4),
  end: DateTime.utc(2026, 4, 30, 23, 59, 59),
);

PlatformSummary testSummary() => PlatformSummary(
  totalCompletedAppointments: 8,
  totalRevenue: 1200,
  totalPendingPayouts: 340,
  averagePerformanceScore: 77.5,
  activeDoctorsCount: 2,
  period: testPeriod(),
);

DoctorAnalytics testDoctor({
  String id = 'doctor-1',
  String name = 'د. أحمد',
  bool isActive = true,
  double revenue = 600,
  double pending = 120,
  double score = 81,
}) => DoctorAnalytics(
  doctorId: id,
  doctorName: name,
  specialty: 'chronic_diseases',
  isActive: isActive,
  totalAppointments: 10,
  completedAppointments: 8,
  cancelledAppointments: 1,
  noShowAppointments: 1,
  completionRate: 0.8,
  financialSummary: FinancialSummary(
    totalRevenue: revenue,
    platformCommission: revenue * 0.15,
    netPayout: revenue * 0.85,
    paidAmount: revenue * 0.85 - pending,
    pendingAmount: pending,
    commissionRate: 0.15,
  ),
  performanceScore: PerformanceScore(
    totalScore: score,
    completionRateScore: 26.67,
    patientRatingScore: 27,
    punctualityScore: 27.33,
    emrSpeedScore: 0,
    hasIncompleteData: true,
    missingDimensions: const ['emrSpeed'],
    isOverviewScore: true,
  ),
  pendingPayout: pending,
  period: testPeriod(),
);

class FakeAnalyticsRepository implements AnalyticsRepository {
  FakeAnalyticsRepository({
    PlatformSummary? summary,
    List<DoctorAnalytics>? doctors,
    DoctorAnalytics? detail,
    List<SpecialtyBreakdown>? specialtyBreakdown,
    List<AdminAlert>? alerts,
    PatientRetention? retention,
    this.failure,
  }) : summary = summary ?? testSummary(),
       doctors = doctors ?? [testDoctor()],
       detail = detail ?? testDoctor(),
       specialtyBreakdown = specialtyBreakdown ?? testSpecialtyBreakdown(),
       alerts = alerts ?? testAdminAlerts(),
       retention = retention ?? testPatientRetention();

  final PlatformSummary summary;
  final List<DoctorAnalytics> doctors;
  final DoctorAnalytics detail;
  final List<SpecialtyBreakdown> specialtyBreakdown;
  final List<AdminAlert> alerts;
  final PatientRetention retention;
  final Failure? failure;
  int overviewCalls = 0;
  int summaryCalls = 0;
  int detailCalls = 0;
  int specialtyBreakdownCalls = 0;
  int alertsCalls = 0;
  int acknowledgeCalls = 0;
  int retentionCalls = 0;
  String? acknowledgedAlertId;
  String? lastSpecialtyClinicType;

  @override
  Future<Either<Failure, PlatformSummary>> getPlatformSummary({
    required DateTime periodStart,
    required DateTime periodEnd,
    String? specialtyFilter,
  }) async {
    summaryCalls++;
    if (failure != null) {
      return Left(failure!);
    }
    return Right(summary);
  }

  @override
  Future<Either<Failure, DoctorsOverviewResult>> getDoctorsOverview({
    required DateTime periodStart,
    required DateTime periodEnd,
    required String sortBy,
    required String sortOrder,
    required int pageSize,
    String? specialtyFilter,
    String? statusFilter,
    String? searchQuery,
    String? cursor,
  }) async {
    overviewCalls++;
    if (failure != null) {
      return Left(failure!);
    }

    final sorted = [...doctors]
      ..sort((a, b) {
        final comparison = switch (sortBy) {
          'revenue' => a.financialSummary.totalRevenue.compareTo(
            b.financialSummary.totalRevenue,
          ),
          'performanceScore' => a.performanceScore.totalScore.compareTo(
            b.performanceScore.totalScore,
          ),
          _ => a.doctorName.compareTo(b.doctorName),
        };
        return sortOrder == 'asc' ? comparison : -comparison;
      });

    return Right(
      DoctorsOverviewResult(
        doctors: sorted,
        hasMore: false,
      ),
    );
  }

  @override
  Future<Either<Failure, DoctorAnalytics>> getDoctorDetail({
    required String doctorId,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    detailCalls++;
    if (failure != null) {
      return Left(failure!);
    }
    return Right(detail);
  }

  @override
  Future<Either<Failure, TimeSeriesResult>> getDoctorTimeSeries({
    required String doctorId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required String granularity,
  }) async => Right(
    TimeSeriesResult(
      granularity: granularity,
      hasComparison: true,
      appointmentsChangePercent: 12.5,
      dataPoints: [
        TimeSeriesPoint(
          date: periodStart,
          appointments: 2,
          revenue: 200,
          performanceScore: 75,
          completionRate: 0.8,
          isMarker: true,
        ),
        TimeSeriesPoint(
          date: periodEnd,
          appointments: 3,
          revenue: 300,
          performanceScore: 80,
          completionRate: 1,
          isMarker: true,
        ),
      ],
    ),
  );

  @override
  Future<Either<Failure, List<AdminAlert>>> getAdminAlerts({
    bool includeRead = false,
    int limit = 50,
  }) async {
    alertsCalls++;
    if (failure != null) {
      return Left(failure!);
    }
    return Right(
      includeRead ? alerts : alerts.where((a) => !a.isRead).toList(),
    );
  }

  @override
  Future<Either<Failure, Unit>> acknowledgeAlert(String alertId) async {
    acknowledgeCalls++;
    acknowledgedAlertId = alertId;
    if (failure != null) {
      return Left(failure!);
    }
    return const Right(unit);
  }

  @override
  Future<Either<Failure, List<SpecialtyBreakdown>>> getSpecialtyBreakdown({
    required String doctorId,
    required DateTime periodStart,
    required DateTime periodEnd,
    String? clinicType,
  }) async {
    specialtyBreakdownCalls++;
    lastSpecialtyClinicType = clinicType;
    if (failure != null) {
      return Left(failure!);
    }
    return Right(specialtyBreakdown);
  }

  @override
  Future<Either<Failure, PatientRetention>> getPatientRetention({
    required String doctorId,
  }) async {
    retentionCalls++;
    if (failure != null) {
      return Left(failure!);
    }
    return Right(retention);
  }
}

List<AdminAlert> testAdminAlerts() => [
  AdminAlert(
    id: 'alert-1',
    type: AlertType.financial,
    doctorId: 'doctor-1',
    doctorName: 'د. أحمد',
    title: 'مستحقات مرتفعة',
    message: 'تجاوزت المستحقات الحد المحدد',
    triggerValue: '5200 SAR',
    threshold: '5000 SAR',
    createdAt: DateTime.utc(2026, 4, 25),
  ),
  AdminAlert(
    id: 'alert-2',
    type: AlertType.performance,
    doctorId: 'doctor-2',
    doctorName: 'د. سارة',
    title: 'انخفاض معدل الإتمام',
    message: 'معدل الإتمام منخفض',
    triggerValue: '65%',
    threshold: '70%',
    createdAt: DateTime.utc(2026, 4, 24),
    isRead: true,
  ),
];

PatientRetention testPatientRetention({
  double rate = 0.4,
  int totalUniquePatients = 5,
  int returningPatients = 2,
  bool hasSufficientData = true,
}) => PatientRetention(
  retentionRate: rate,
  totalUniquePatients: totalUniquePatients,
  returningPatients: returningPatients,
  hasSufficientData: hasSufficientData,
);

List<SpecialtyBreakdown> testSpecialtyBreakdown() => const [
  SpecialtyBreakdown(
    type: 'video',
    clinicType: 'chronic_diseases',
    count: 6,
    percentage: 60,
  ),
  SpecialtyBreakdown(
    type: 'clinic',
    clinicType: 'chronic_diseases',
    count: 4,
    percentage: 40,
  ),
];

PayoutReport testPayoutReport({List<PayoutEntry>? entries}) => PayoutReport(
  doctorId: 'doctor-1',
  doctorName: 'د. أحمد',
  specialty: 'chronic_diseases',
  period: AnalyticsDateRange(
    start: DateTime.utc(2026, 4),
    end: DateTime.utc(2026, 4, 30, 23, 59, 59),
  ),
  entries:
      entries ??
      [
        PayoutEntry(
          appointmentId: 'appointment-1',
          patientName: 'مريض 1',
          appointmentDate: DateTime.utc(2026, 4, 15, 10),
          status: 'completed',
          fee: 200,
          commission: 30,
          netAmount: 170,
        ),
      ],
  totalRevenue: entries == null || entries.isNotEmpty ? 200 : 0,
  totalCommission: entries == null || entries.isNotEmpty ? 30 : 0,
  totalNetPayout: entries == null || entries.isNotEmpty ? 170 : 0,
  generatedAt: DateTime.utc(2026, 4, 25, 16),
);

class FakePayoutExportRepository implements PayoutExportRepository {
  FakePayoutExportRepository({PayoutReport? report, this.failure, this.delay})
    : report = report ?? testPayoutReport();

  final PayoutReport report;
  final Failure? failure;
  final Duration? delay;
  int fetchCalls = 0;
  int pdfCalls = 0;
  int excelCalls = 0;
  int recordCalls = 0;
  double? lastRecordedAmount;
  String? lastRecordedNote;

  @override
  Future<Either<Failure, PayoutReport>> getPayoutReportData({
    required String doctorId,
    required int year,
    required int month,
  }) async {
    fetchCalls++;
    if (delay != null) await Future<void>.delayed(delay!);
    if (failure != null) return Left(failure!);
    return Right(report);
  }

  @override
  Future<Either<Failure, String>> generatePdf(PayoutReport report) async {
    pdfCalls++;
    return const Right('/tmp/payout.pdf');
  }

  @override
  Future<Either<Failure, String>> generateExcel(PayoutReport report) async {
    excelCalls++;
    return const Right('/tmp/payout.xlsx');
  }

  @override
  Future<Either<Failure, Unit>> recordPayout({
    required String doctorId,
    required double amount,
    String? note,
  }) async {
    recordCalls++;
    lastRecordedAmount = amount;
    lastRecordedNote = note;
    if (failure != null) return Left(failure!);
    return const Right(unit);
  }
}
