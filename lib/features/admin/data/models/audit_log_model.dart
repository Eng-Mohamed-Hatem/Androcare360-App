import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/features/admin/domain/entities/audit_log.dart';
import 'package:elajtech/shared/models/user_model.dart';

/// Firestore data model for audit log documents.
///
/// Maps to/from the `audit_logs` Firestore collection. Every admin action
/// should produce one document here via [toJson].
class AuditLogModel extends AuditLog {
  /// Creates an [AuditLogModel] with all required fields.
  const AuditLogModel({
    required super.id,
    required super.adminId,
    required super.adminName,
    required super.action,
    required super.targetId,
    required super.targetType,
    required super.timestamp,
    super.changes,
    super.metadata,
  });

  /// Parses a Firestore document into an [AuditLogModel].
  ///
  /// - [timestamp] stored as Firestore [Timestamp] is converted to [DateTime].
  /// - Missing optional fields default to `null`.
  factory AuditLogModel.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists) {
      throw StateError('AuditLog document ${doc.id} does not exist');
    }
    final data = doc.data()! as Map<String, dynamic>;
    return AuditLogModel(
      id: doc.id,
      adminId: data['adminId'] as String? ?? '',
      adminName: data['adminName'] as String? ?? '',
      action: data['action'] as String? ?? '',
      targetId: data['targetId'] as String? ?? '',
      targetType: data['targetType'] as String? ?? '',
      timestamp: data['timestamp'] is Timestamp
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      changes: data['changes'] as Map<String, dynamic>?,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Serializes this log entry to a Firestore-compatible map.
  ///
  /// [timestamp] is written as a [FieldValue.serverTimestamp] sentinel so
  /// Firestore sets the exact server time rather than relying on the device clock.
  /// Pass [useServerTimestamp] = true when creating new documents.
  Map<String, dynamic> toJson({bool useServerTimestamp = true}) => {
    'adminId': adminId,
    'adminName': adminName,
    'action': action,
    'targetId': targetId,
    'targetType': targetType,
    'timestamp': useServerTimestamp
        ? FieldValue.serverTimestamp()
        : Timestamp.fromDate(timestamp),
    if (changes != null) 'changes': changes,
    if (metadata != null) 'metadata': metadata,
  };

  /// Builds the field-level diff between [previous] and [updated] UserModels.
  ///
  /// Only top-level scalar fields that differ are included. Returns a map of:
  /// ```json
  /// { "fieldName": { "before": "oldValue", "after": "newValue" } }
  /// ```
  static Map<String, dynamic> diffUsers(
    UserModel previous,
    UserModel updated,
  ) {
    final prev = previous.toJson();
    final next = updated.toJson();
    final diff = <String, dynamic>{};
    for (final key in next.keys) {
      if (prev[key] != next[key]) {
        diff[key] = {'before': prev[key], 'after': next[key]};
      }
    }
    return diff;
  }
}
