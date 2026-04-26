# Repository Interfaces: Doctor Analytics Dashboard

**Branch**: `010-doctor-analytics-dashboard` | **Date**: 2026-04-25

## AnalyticsRepository

Abstract interface for all analytics data operations. Implemented by `AnalyticsRepositoryImpl` which uses Cloud Functions + Firestore.

```dart
abstract class AnalyticsRepository {
  /// يعرض ملخص المنصة الإجمالي للفترة المحددة
  /// Platform-wide summary for the given period
  Future<Either<Failure, PlatformSummary>> getPlatformSummary({
    required DateTime periodStart,
    required DateTime periodEnd,
    String? specialtyFilter,
  });

  /// يعرض قائمة الأطباء مع إحصائياتهم (جدول Overview)
  /// Paginated, filtered, sorted list of doctor analytics
  Future<Either<Failure, DoctorsOverviewResult>> getDoctorsOverview({
    required DateTime periodStart,
    required DateTime periodEnd,
    String? specialtyFilter,
    String? statusFilter,
    String? searchQuery,
    required String sortBy,
    required String sortOrder,
    required int pageSize,
    String? cursor,
  });

  /// يعرض تفاصيل إحصائيات طبيب واحد
  /// Full analytics detail for a single doctor
  Future<Either<Failure, DoctorAnalyticsDetail>> getDoctorDetail({
    required String doctorId,
    required DateTime periodStart,
    required DateTime periodEnd,
  });

  /// يعرض بيانات السلاسل الزمنية لأداء طبيب
  /// Time-series data for charts (daily/weekly/monthly)
  Future<Either<Failure, TimeSeriesData>> getDoctorTimeSeries({
    required String doctorId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required String granularity,
  });

  /// يعرض قائمة التنبيهات النشطة
  /// Active admin alerts
  Future<Either<Failure, List<AdminAlert>>> getAdminAlerts({
    bool includeRead = false,
    int limit = 50,
  });

  /// يؤكد تنبيه كمقروء
  /// Mark alert as acknowledged
  Future<Either<Failure, void>> acknowledgeAlert(String alertId);

  /// يعرض توزيع الحجوزات حسب نوع الخدمة
  /// Appointment distribution by service type
  Future<Either<Failure, List<SpecialtyBreakdown>>> getSpecialtyBreakdown({
    required String doctorId,
    required DateTime periodStart,
    required DateTime periodEnd,
  });

  /// يحسب معدل الاحتفاظ بالمرضى
  /// Patient retention rate for a doctor
  Future<Either<Failure, PatientRetention>> getPatientRetention({
    required String doctorId,
  });
}
```

## PayoutExportRepository

Abstract interface for payout report generation. Implemented by `PayoutExportRepositoryImpl`.

```dart
abstract class PayoutExportRepository {
  /// يجلب بيانات تقرير المستحقات من Cloud Function
  /// Fetch payout report data from Cloud Function
  Future<Either<Failure, PayoutReport>> getPayoutReportData({
    required String doctorId,
    required int year,
    required int month,
  });

  /// ينشئ ملف PDF من تقرير المستحقات
  /// Generate PDF file from payout report
  Future<Either<Failure, String>> generatePdf(PayoutReport report);

  /// ينشئ ملف Excel من تقرير المستحقات
  /// Generate Excel file from payout report
  Future<Either<Failure, String>> generateExcel(PayoutReport report);
}
```

## Error Types

Uses existing `Failure` classes from `lib/core/error/`:

- `ServerFailure` — Cloud Function errors, Firestore errors
- `NetworkFailure` — Connectivity issues
- `NotFoundFailure` — Doctor/alert not found
- `NoDataFailure` — Empty period, no appointments
- `PermissionFailure` — Non-admin access attempt

## Provider Contracts

### AnalyticsNotifier (StateNotifier)

```dart
class AnalyticsState {
  final PlatformSummary? platformSummary;
  final List<DoctorAnalytics> doctors;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final String? nextCursor;
  final AnalyticsFilters filters;
}

class AnalyticsFilters {
  final DateTime periodStart;
  final DateTime periodEnd;
  final String? specialtyFilter;
  final String statusFilter; // all | active | inactive
  final String? searchQuery;
  final String sortBy;
  final String sortOrder;
}
```

### AlertsNotifier (StateNotifier)

```dart
class AlertsState {
  final List<AdminAlert> alerts;
  final int unreadCount;
  final bool isLoading;
  final String? error;
}
```

### FiltersNotifier (StateNotifier)

```dart
class FiltersState {
  final AnalyticsPeriod period; // day | week | month | custom
  final DateTime? customStart;
  final DateTime? customEnd;
  final String? specialtyFilter;
  final String statusFilter;
  final String? searchQuery;
}
```
