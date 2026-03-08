/// Represents a single admin audit log entry stored in the `audit_logs`
/// Firestore collection.
///
/// Every write/update/deactivation performed by an admin is recorded here
/// to provide a complete audit trail for compliance and debugging.
class AuditLog {
  /// Creates an [AuditLog] entity.
  const AuditLog({
    required this.id,
    required this.adminId,
    required this.adminName,
    required this.action,
    required this.targetId,
    required this.targetType,
    required this.timestamp,
    this.changes,
    this.metadata,
  });

  /// Firestore document ID (auto-generated)
  final String id;

  /// UID of the admin who performed the action
  final String adminId;

  /// Display name of the admin at the time of the action
  final String adminName;

  /// Human-readable action identifier, e.g.:
  /// - `create_doctor`
  /// - `update_doctor_profile`
  /// - `deactivate_account`
  /// - `reactivate_account`
  /// - `view_emr`
  final String action;

  /// UID of the user who was affected by this action
  final String targetId;

  /// Role of the affected user: `doctor` or `patient`
  final String targetType;

  /// UTC timestamp when the action was performed
  final DateTime timestamp;

  /// Field-level diff map.
  /// Key = field name, value = `{'before': oldValue, 'after': newValue}`
  final Map<String, dynamic>? changes;

  /// Optional extra context (e.g., appointment count warning)
  final Map<String, dynamic>? metadata;
}
