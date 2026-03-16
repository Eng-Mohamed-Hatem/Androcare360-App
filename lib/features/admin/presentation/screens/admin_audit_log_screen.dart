import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/admin/domain/entities/audit_log.dart';
import 'package:elajtech/features/admin/presentation/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

/// Displays a real-time stream of all admin audit log entries.
///
/// Uses [auditLogsStreamProvider] to listen for Firestore updates.
/// Each entry shows the admin name, action, target, and timestamp.
class AdminAuditLogScreen extends ConsumerWidget {
  const AdminAuditLogScreen({super.key});

  String _actionLabel(String action) {
    const labels = {
      'create_doctor': 'إنشاء حساب طبيب',
      'update_doctor_profile': 'تحديث ملف الطبيب',
      'deactivate_account': 'تعطيل حساب',
      'reactivate_account': 'تفعيل حساب',
      'set_account_status': 'تغيير حالة الحساب',
      'view_emr': 'عرض السجل الطبي',
    };
    return labels[action] ?? action;
  }

  Color _actionColor(String action) {
    if (action.contains('deactivate')) return Colors.red;
    if (action.contains('reactivate') || action.contains('activate')) {
      return Colors.green;
    }
    if (action.contains('create')) return AppColors.primary;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(auditLogsStreamProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text('سجل المراجعة'),
        ),
        body: logsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('خطأ: $err')),
          data: (logs) {
            if (logs.isEmpty) {
              return const Center(child: Text('لا توجد سجلات بعد'));
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
              itemCount: logs.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final log = logs[i];
                return _AuditLogTile(
                  log: log,
                  actionLabel: _actionLabel(log.action),
                  actionColor: _actionColor(log.action),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AuditLogTile extends StatelessWidget {
  const _AuditLogTile({
    required this.log,
    required this.actionLabel,
    required this.actionColor,
  });

  final AuditLog log;
  final String actionLabel;
  final Color actionColor;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: CircleAvatar(
      backgroundColor: actionColor.withValues(alpha: 0.15),
      child: Icon(
        _iconFor(log.action),
        color: actionColor,
        size: 20,
      ),
    ),
    title: Text(
      actionLabel,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    ),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('المسؤول: ${log.adminName}'),
        Text(
          'المستخدم: ${log.targetType} — ${log.targetId}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        if (log.changes != null && log.changes!.isNotEmpty)
          Text(
            'حقول مُعدّلة: ${log.changes!.keys.join(', ')}',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
      ],
    ),
    trailing: Text(
      DateFormat('yy/MM/dd\nHH:mm').format(log.timestamp.toLocal()),
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 11, color: Colors.grey),
    ),
    isThreeLine: true,
  );

  IconData _iconFor(String action) {
    if (action.contains('create')) return Icons.person_add_outlined;
    if (action.contains('deactivate') || action.contains('status')) {
      return Icons.block_outlined;
    }
    if (action.contains('reactivate') || action.contains('activate')) {
      return Icons.check_circle_outline;
    }
    if (action.contains('update')) return Icons.edit_outlined;
    if (action.contains('emr')) return Icons.folder_shared_outlined;
    return Icons.history;
  }
}
