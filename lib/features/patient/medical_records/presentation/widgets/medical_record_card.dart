import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/shared/models/medical_record_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Medical Record Card Widget - بطاقة السجل الطبي
class MedicalRecordCard extends StatelessWidget {
  const MedicalRecordCard({required this.record, super.key});
  final MedicalRecordModel record;

  IconData _getIconForType(RecordType type) {
    switch (type) {
      case RecordType.consultation:
        return Icons.medical_services;
      case RecordType.labTest:
        return Icons.science;
      case RecordType.imaging:
        return Icons.camera_alt;
      case RecordType.prescription:
        return Icons.medication;
    }
  }

  Color _getColorForType(RecordType type) {
    switch (type) {
      case RecordType.consultation:
        return AppColors.primary;
      case RecordType.labTest:
        return AppColors.info;
      case RecordType.imaging:
        return AppColors.warning;
      case RecordType.prescription:
        return AppColors.success;
    }
  }

  String _getTypeLabel(RecordType type) {
    switch (type) {
      case RecordType.consultation:
        return 'استشارة';
      case RecordType.labTest:
        return 'تحليل';
      case RecordType.imaging:
        return 'أشعة';
      case RecordType.prescription:
        return 'وصفة طبية';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy', 'ar');
    final color = _getColorForType(record.type);

    return InkWell(
      onTap: () {
        // TODO(elajtech): Navigate to record details.
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getIconForType(record.type),
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Type & Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTypeLabel(record.type),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(record.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondaryLight,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Doctor Name
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 16,
                  color: AppColors.textSecondaryLight,
                ),
                const SizedBox(width: 8),
                Text(
                  record.doctorName,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Diagnosis
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'التشخيص',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    record.diagnosis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            // Prescription (if available)
            if (record.prescription != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.medication,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        record.prescription!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Attachments (if available)
            if (record.attachments.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.attach_file,
                    size: 16,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${record.attachments.length} مرفقات',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.info),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
