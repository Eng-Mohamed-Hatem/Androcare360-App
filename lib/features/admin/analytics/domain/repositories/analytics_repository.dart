import 'package:dartz/dartz.dart';

import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/admin_alert.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/doctor_analytics.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/platform_summary.dart';

/// نتيجة قائمة الأطباء مع مؤشر الصفحة التالية
class DoctorsOverviewResult {
  const DoctorsOverviewResult({
    required this.doctors,
    required this.hasMore,
    this.nextCursor,
  });

  final List<DoctorAnalytics> doctors;
  final bool hasMore;
  final String? nextCursor;
}

/// نتيجة توزيع التخصصات لطبيب
class SpecialtyBreakdown {
  const SpecialtyBreakdown({
    required this.type,
    required this.clinicType,
    required this.count,
    required this.percentage,
  });

  /// نوع الموعد: video | clinic
  final String type;
  final String clinicType;
  final int count;
  final double percentage;
}

/// نقطة واحدة في مخطط السلاسل الزمنية.
class TimeSeriesPoint {
  const TimeSeriesPoint({
    required this.date,
    required this.appointments,
    required this.revenue,
    required this.performanceScore,
    required this.completionRate,
    required this.isMarker,
  });

  final DateTime date;
  final int appointments;
  final double revenue;
  final double performanceScore;
  final double completionRate;
  final bool isMarker;
}

/// نتيجة بيانات المخطط مع مقارنة الفترة السابقة عند توفرها.
class TimeSeriesResult {
  const TimeSeriesResult({
    required this.granularity,
    required this.dataPoints,
    required this.hasComparison,
    this.appointmentsChangePercent,
    this.revenueChangePercent,
  });

  final String granularity;
  final List<TimeSeriesPoint> dataPoints;
  final bool hasComparison;
  final double? appointmentsChangePercent;
  final double? revenueChangePercent;
}

/// نتيجة معدل الاحتفاظ بالمرضى
class PatientRetention {
  const PatientRetention({
    required this.retentionRate,
    required this.totalUniquePatients,
    required this.returningPatients,
    required this.hasSufficientData,
  });

  final double retentionRate;
  final int totalUniquePatients;
  final int returningPatients;

  /// false عندما يكون عدد المرضى الفريدين أقل من 5
  final bool hasSufficientData;
}

/// واجهة مستودع التحليلات — Analytics repository interface.
/// Implemented by AnalyticsRepositoryImpl using Cloud Functions.
abstract class AnalyticsRepository {
  /// يعرض ملخص المنصة الإجمالي للفترة المحددة
  Future<Either<Failure, PlatformSummary>> getPlatformSummary({
    required DateTime periodStart,
    required DateTime periodEnd,
    String? specialtyFilter,
  });

  /// يعرض قائمة الأطباء مرقّمة مع تصفية وفرز
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
  });

  /// يعرض تفاصيل إحصائيات طبيب واحد
  Future<Either<Failure, DoctorAnalytics>> getDoctorDetail({
    required String doctorId,
    required DateTime periodStart,
    required DateTime periodEnd,
  });

  /// يعرض بيانات السلاسل الزمنية لأداء طبيب
  Future<Either<Failure, TimeSeriesResult>> getDoctorTimeSeries({
    required String doctorId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required String granularity,
  });

  /// يعرض التنبيهات الإدارية النشطة
  Future<Either<Failure, List<AdminAlert>>> getAdminAlerts({
    bool includeRead = false,
    int limit = 50,
  });

  /// يؤكد تنبيهاً كمقروء
  Future<Either<Failure, Unit>> acknowledgeAlert(String alertId);

  /// يعرض توزيع الحجوزات حسب نوع الخدمة والتخصص
  Future<Either<Failure, List<SpecialtyBreakdown>>> getSpecialtyBreakdown({
    required String doctorId,
    required DateTime periodStart,
    required DateTime periodEnd,
    String? clinicType,
  });

  /// يحسب معدل الاحتفاظ بالمرضى لطبيب
  Future<Either<Failure, PatientRetention>> getPatientRetention({
    required String doctorId,
  });
}
