import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/admin/analytics/data/models/admin_alert_model.dart';
import 'package:elajtech/features/admin/analytics/data/models/doctor_analytics_model.dart';
import 'package:elajtech/features/admin/analytics/data/models/platform_summary_model.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/admin_alert.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/date_range.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/doctor_analytics.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/platform_summary.dart';
import 'package:elajtech/features/admin/analytics/domain/repositories/analytics_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// تنفيذ مستودع التحليلات — calls Cloud Functions for all analytics data.
@LazySingleton(as: AnalyticsRepository)
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  const AnalyticsRepositoryImpl(this._functions);

  final FirebaseFunctions _functions;

  // ─────────────────────────────────────────────────────────────────────────
  // getPlatformSummary
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PlatformSummary>> getPlatformSummary({
    required DateTime periodStart,
    required DateTime periodEnd,
    String? specialtyFilter,
  }) async {
    try {
      final result = await _functions
          .httpsCallable('getPlatformSummary')
          .call<Map<String, dynamic>>({
            'periodStart': periodStart.toIso8601String(),
            'periodEnd': periodEnd.toIso8601String(),
            'specialtyFilter': specialtyFilter,
          });

      final data = Map<String, dynamic>.from(result.data as Map);
      final period = AnalyticsDateRange(start: periodStart, end: periodEnd);
      return Right(PlatformSummaryModel.fromJson(data).toDomain(period));
    } on FirebaseFunctionsException catch (e, st) {
      debugPrint(
        '[AnalyticsRepository] getPlatformSummary error: ${e.code} ${e.message}',
      );
      debugPrint(st.toString());
      return Left(
        Failure.firestore(e.message ?? 'Failed to load platform summary'),
      );
    } on Object catch (e, st) {
      debugPrint('[AnalyticsRepository] getPlatformSummary unexpected: $e');
      debugPrint(st.toString());
      return Left(Failure.unexpected(e.toString()));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // getDoctorsOverview
  // ─────────────────────────────────────────────────────────────────────────

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
    try {
      final result = await _functions
          .httpsCallable('getDoctorsOverview')
          .call<Map<String, dynamic>>({
            'periodStart': periodStart.toIso8601String(),
            'periodEnd': periodEnd.toIso8601String(),
            'sortBy': sortBy,
            'sortOrder': sortOrder,
            'pageSize': pageSize,
            'specialtyFilter': specialtyFilter,
            'statusFilter': statusFilter,
            'searchQuery': searchQuery,
            'cursor': cursor,
          });

      final data = Map<String, dynamic>.from(result.data as Map);
      final period = AnalyticsDateRange(start: periodStart, end: periodEnd);

      final doctorsRaw = data['doctors'] as List<dynamic>? ?? [];
      final doctors = doctorsRaw
          .map(
            (e) => DoctorAnalyticsModel.fromOverviewJson(
              Map<String, dynamic>.from(e as Map),
            ).toDomain(period),
          )
          .toList();

      return Right(
        DoctorsOverviewResult(
          doctors: doctors,
          hasMore: data['hasMore'] as bool? ?? false,
          nextCursor: data['nextCursor'] as String?,
        ),
      );
    } on FirebaseFunctionsException catch (e, st) {
      debugPrint(
        '[AnalyticsRepository] getDoctorsOverview error: ${e.code} ${e.message}',
      );
      debugPrint(st.toString());
      return Left(
        Failure.firestore(e.message ?? 'Failed to load doctors overview'),
      );
    } on Object catch (e, st) {
      debugPrint('[AnalyticsRepository] getDoctorsOverview unexpected: $e');
      debugPrint(st.toString());
      return Left(Failure.unexpected(e.toString()));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Stubs for phases 4-9
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, DoctorAnalytics>> getDoctorDetail({
    required String doctorId,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    try {
      final result = await _functions
          .httpsCallable('getDoctorAnalyticsDetail')
          .call<Map<String, dynamic>>({
            'doctorId': doctorId,
            'periodStart': periodStart.toIso8601String(),
            'periodEnd': periodEnd.toIso8601String(),
          });

      final data = Map<String, dynamic>.from(result.data as Map);
      final period = AnalyticsDateRange(start: periodStart, end: periodEnd);
      return Right(DoctorAnalyticsModel.fromDetailJson(data).toDomain(period));
    } on FirebaseFunctionsException catch (e, st) {
      debugPrint(
        '[AnalyticsRepository] getDoctorDetail error: ${e.code} ${e.message}',
      );
      debugPrint(st.toString());
      return Left(
        Failure.firestore(
          e.message ?? 'Failed to load doctor analytics detail',
        ),
      );
    } on Object catch (e, st) {
      debugPrint('[AnalyticsRepository] getDoctorDetail unexpected: $e');
      debugPrint(st.toString());
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TimeSeriesResult>> getDoctorTimeSeries({
    required String doctorId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required String granularity,
  }) async {
    try {
      final result = await _functions
          .httpsCallable('getDoctorAnalyticsDetail')
          .call<Map<String, dynamic>>({
            'doctorId': doctorId,
            'periodStart': periodStart.toIso8601String(),
            'periodEnd': periodEnd.toIso8601String(),
            'granularity': granularity,
          });

      final data = Map<String, dynamic>.from(result.data as Map);
      return Right(_parseTimeSeries(data['timeSeriesData']));
    } on FirebaseFunctionsException catch (e, st) {
      debugPrint(
        '[AnalyticsRepository] getDoctorTimeSeries error: ${e.code} ${e.message}',
      );
      debugPrint(st.toString());
      return Left(
        Failure.firestore(e.message ?? 'Failed to load time-series data'),
      );
    } on Object catch (e, st) {
      debugPrint('[AnalyticsRepository] getDoctorTimeSeries unexpected: $e');
      debugPrint(st.toString());
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AdminAlert>>> getAdminAlerts({
    bool includeRead = false,
    int limit = 50,
  }) async {
    try {
      final result = await _functions
          .httpsCallable('getAdminAlerts')
          .call<Map<String, dynamic>>({
            'includeRead': includeRead,
            'limit': limit,
          });

      final data = Map<String, dynamic>.from(result.data as Map);
      final rawAlerts = data['alerts'] as List<dynamic>? ?? const [];
      return Right(
        rawAlerts
            .map(
              (item) => AdminAlertModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ).toDomain(),
            )
            .toList(),
      );
    } on FirebaseFunctionsException catch (e, st) {
      debugPrint(
        '[AnalyticsRepository] getAdminAlerts error: ${e.code} ${e.message}',
      );
      debugPrint(st.toString());
      return Left(Failure.firestore(e.message ?? 'Failed to load alerts'));
    } on Object catch (e, st) {
      debugPrint('[AnalyticsRepository] getAdminAlerts unexpected: $e');
      debugPrint(st.toString());
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> acknowledgeAlert(String alertId) async =>
      _acknowledgeAlert(alertId);

  Future<Either<Failure, Unit>> _acknowledgeAlert(String alertId) async {
    try {
      await _functions.httpsCallable('acknowledgeAlert').call<void>({
        'alertId': alertId,
      });
      return const Right(unit);
    } on FirebaseFunctionsException catch (e, st) {
      debugPrint(
        '[AnalyticsRepository] acknowledgeAlert error: ${e.code} ${e.message}',
      );
      debugPrint(st.toString());
      return Left(
        Failure.firestore(e.message ?? 'Failed to acknowledge alert'),
      );
    } on Object catch (e, st) {
      debugPrint('[AnalyticsRepository] acknowledgeAlert unexpected: $e');
      debugPrint(st.toString());
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SpecialtyBreakdown>>> getSpecialtyBreakdown({
    required String doctorId,
    required DateTime periodStart,
    required DateTime periodEnd,
    String? clinicType,
  }) async {
    try {
      final result = await _functions
          .httpsCallable('getDoctorAnalyticsDetail')
          .call<Map<String, dynamic>>({
            'doctorId': doctorId,
            'periodStart': periodStart.toIso8601String(),
            'periodEnd': periodEnd.toIso8601String(),
            'clinicType': clinicType,
          });

      final data = Map<String, dynamic>.from(result.data as Map);
      return Right(_parseSpecialtyBreakdown(data['specialtyBreakdown']));
    } on FirebaseFunctionsException catch (e, st) {
      debugPrint(
        '[AnalyticsRepository] getSpecialtyBreakdown error: ${e.code} ${e.message}',
      );
      debugPrint(st.toString());
      return Left(
        Failure.firestore(e.message ?? 'Failed to load specialty breakdown'),
      );
    } on Object catch (e, st) {
      debugPrint('[AnalyticsRepository] getSpecialtyBreakdown unexpected: $e');
      debugPrint(st.toString());
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PatientRetention>> getPatientRetention({
    required String doctorId,
  }) async {
    try {
      final now = DateTime.now().toUtc();
      final start = DateTime.utc(now.year - 5, now.month, now.day);
      final result = await _functions
          .httpsCallable('getDoctorAnalyticsDetail')
          .call<Map<String, dynamic>>({
            'doctorId': doctorId,
            'periodStart': start.toIso8601String(),
            'periodEnd': now.toIso8601String(),
          });

      final data = Map<String, dynamic>.from(result.data as Map);
      return Right(_parsePatientRetention(data['patientRetention']));
    } on FirebaseFunctionsException catch (e, st) {
      debugPrint(
        '[AnalyticsRepository] getPatientRetention error: ${e.code} ${e.message}',
      );
      debugPrint(st.toString());
      return Left(
        Failure.firestore(e.message ?? 'Failed to load patient retention'),
      );
    } on Object catch (e, st) {
      debugPrint('[AnalyticsRepository] getPatientRetention unexpected: $e');
      debugPrint(st.toString());
      return Left(Failure.unexpected(e.toString()));
    }
  }

  static TimeSeriesResult _parseTimeSeries(Object? raw) {
    final json = Map<String, dynamic>.from((raw as Map?) ?? const {});
    final comparison = Map<String, dynamic>.from(
      (json['comparison'] as Map?) ?? const {},
    );
    final changePercent = Map<String, dynamic>.from(
      (comparison['changePercent'] as Map?) ?? const {},
    );
    final points = (json['dataPoints'] as List<dynamic>? ?? const []).map((
      item,
    ) {
      final point = Map<String, dynamic>.from(item as Map);
      return TimeSeriesPoint(
        date:
            DateTime.tryParse(point['date']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        appointments: (point['appointments'] as num?)?.toInt() ?? 0,
        revenue: (point['revenue'] as num?)?.toDouble() ?? 0,
        performanceScore: (point['performanceScore'] as num?)?.toDouble() ?? 0,
        completionRate: (point['completionRate'] as num?)?.toDouble() ?? 0,
        isMarker: point['isMarker'] as bool? ?? false,
      );
    }).toList();

    return TimeSeriesResult(
      granularity: json['granularity']?.toString() ?? 'monthly',
      dataPoints: points,
      hasComparison: json['hasComparison'] as bool? ?? false,
      appointmentsChangePercent: (changePercent['appointments'] as num?)
          ?.toDouble(),
      revenueChangePercent: (changePercent['revenue'] as num?)?.toDouble(),
    );
  }

  static PatientRetention _parsePatientRetention(Object? raw) {
    final json = Map<String, dynamic>.from((raw as Map?) ?? const {});
    return PatientRetention(
      retentionRate: (json['retentionRate'] as num?)?.toDouble() ?? 0,
      totalUniquePatients: (json['totalUniquePatients'] as num?)?.toInt() ?? 0,
      returningPatients: (json['returningPatients'] as num?)?.toInt() ?? 0,
      hasSufficientData: json['hasSufficientData'] as bool? ?? false,
    );
  }

  static List<SpecialtyBreakdown> _parseSpecialtyBreakdown(Object? raw) {
    final items = raw is List<dynamic> ? raw : const <dynamic>[];
    return items.map((item) {
      final json = Map<String, dynamic>.from(item as Map);
      return SpecialtyBreakdown(
        type: (json['type'] ?? json['serviceType'] ?? '').toString(),
        clinicType: (json['clinicType'] ?? '').toString(),
        count: (json['count'] as num?)?.toInt() ?? 0,
        percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      );
    }).toList();
  }
}
