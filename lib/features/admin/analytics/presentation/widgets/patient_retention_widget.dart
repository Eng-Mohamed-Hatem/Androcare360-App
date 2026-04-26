import 'package:elajtech/features/admin/analytics/domain/repositories/analytics_repository.dart';
import 'package:flutter/material.dart';

class PatientRetentionWidget extends StatelessWidget {
  const PatientRetentionWidget({required this.retention, super.key});

  final PatientRetention retention;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              height: 72,
              width: 72,
              child: retention.hasSufficientData
                  ? CircularProgressIndicator(
                      value: retention.retentionRate.clamp(0, 1).toDouble(),
                      strokeWidth: 8,
                    )
                  : const Icon(Icons.groups_outlined, size: 44),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'معدل الاحتفاظ بالمرضى',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  if (retention.hasSufficientData)
                    Text(
                      '${(retention.retentionRate * 100).toStringAsFixed(1)}% من ${retention.totalUniquePatients} مرضى',
                    )
                  else
                    const Text('غير متوفر — بيانات غير كافية'),
                  Text('مرضى عائدون: ${retention.returningPatients}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
