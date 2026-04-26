import 'package:elajtech/features/admin/analytics/domain/entities/admin_alert.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/date_range.dart';

/// Data model for admin alert Cloud Function responses.
class AdminAlertModel {
  const AdminAlertModel({
    required this.id,
    required this.type,
    required this.doctorId,
    required this.doctorName,
    required this.title,
    required this.message,
    required this.triggerValue,
    required this.threshold,
    required this.isRead,
    required this.createdAt,
    this.resolvedAt,
  });

  factory AdminAlertModel.fromJson(Map<String, dynamic> json) {
    return AdminAlertModel(
      id: json['id'] as String? ?? '',
      type: _parseType(json['type'] as String?),
      doctorId: json['doctorId'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      triggerValue: json['triggerValue'] as String? ?? '',
      threshold: json['threshold'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      resolvedAt: DateTime.tryParse(json['resolvedAt']?.toString() ?? ''),
    );
  }

  final String id;
  final AlertType type;
  final String doctorId;
  final String doctorName;
  final String title;
  final String message;
  final String triggerValue;
  final String threshold;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  AdminAlert toDomain() => AdminAlert(
    id: id,
    type: type,
    doctorId: doctorId,
    doctorName: doctorName,
    title: title,
    message: message,
    triggerValue: triggerValue,
    threshold: threshold,
    isRead: isRead,
    createdAt: createdAt,
    resolvedAt: resolvedAt,
  );

  static AlertType _parseType(String? value) {
    switch (value) {
      case 'performance':
        return AlertType.performance;
      case 'activity':
        return AlertType.activity;
      default:
        return AlertType.financial;
    }
  }
}
