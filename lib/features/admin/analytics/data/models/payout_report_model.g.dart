// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payout_report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PayoutEntryModel _$PayoutEntryModelFromJson(Map<String, dynamic> json) =>
    _PayoutEntryModel(
      appointmentId: json['appointmentId'] as String,
      patientName: json['patientName'] as String,
      appointmentDate: json['appointmentDate'] as String,
      status: json['status'] as String,
      fee: (json['fee'] as num).toDouble(),
      commission: (json['commission'] as num).toDouble(),
      netAmount: (json['netAmount'] as num).toDouble(),
    );

Map<String, dynamic> _$PayoutEntryModelToJson(_PayoutEntryModel instance) =>
    <String, dynamic>{
      'appointmentId': instance.appointmentId,
      'patientName': instance.patientName,
      'appointmentDate': instance.appointmentDate,
      'status': instance.status,
      'fee': instance.fee,
      'commission': instance.commission,
      'netAmount': instance.netAmount,
    };

_PayoutReportModel _$PayoutReportModelFromJson(Map<String, dynamic> json) =>
    _PayoutReportModel(
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      specialty: json['specialty'] as String,
      period: Map<String, String>.from(json['period'] as Map),
      entries: (json['entries'] as List<dynamic>)
          .map((e) => PayoutEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalCommission: (json['totalCommission'] as num).toDouble(),
      totalNetPayout: (json['totalNetPayout'] as num).toDouble(),
      generatedAt: json['generatedAt'] as String,
    );

Map<String, dynamic> _$PayoutReportModelToJson(_PayoutReportModel instance) =>
    <String, dynamic>{
      'doctorId': instance.doctorId,
      'doctorName': instance.doctorName,
      'specialty': instance.specialty,
      'period': instance.period,
      'entries': instance.entries,
      'totalRevenue': instance.totalRevenue,
      'totalCommission': instance.totalCommission,
      'totalNetPayout': instance.totalNetPayout,
      'generatedAt': instance.generatedAt,
    };
