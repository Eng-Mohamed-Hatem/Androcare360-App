// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FinancialSummaryModel _$FinancialSummaryModelFromJson(
  Map<String, dynamic> json,
) => _FinancialSummaryModel(
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
  platformCommission: (json['platformCommission'] as num).toDouble(),
  netPayout: (json['netPayout'] as num).toDouble(),
  paidAmount: (json['paidAmount'] as num).toDouble(),
  pendingAmount: (json['pendingAmount'] as num).toDouble(),
  commissionRate: (json['commissionRate'] as num).toDouble(),
);

Map<String, dynamic> _$FinancialSummaryModelToJson(
  _FinancialSummaryModel instance,
) => <String, dynamic>{
  'totalRevenue': instance.totalRevenue,
  'platformCommission': instance.platformCommission,
  'netPayout': instance.netPayout,
  'paidAmount': instance.paidAmount,
  'pendingAmount': instance.pendingAmount,
  'commissionRate': instance.commissionRate,
};
