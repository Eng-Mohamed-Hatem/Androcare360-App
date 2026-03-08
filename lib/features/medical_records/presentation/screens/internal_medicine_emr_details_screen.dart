import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/shared/models/internal_medicine_emr_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

/// Internal Medicine EMR Details Screen
class InternalMedicineEMRDetailsScreen extends StatelessWidget {
  const InternalMedicineEMRDetailsScreen({
    required this.emr,
    super.key,
  });

  final InternalMedicineEMRModel emr;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Internal Medicine EMR Details'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header Card
            Card(
              color: AppColors.primary.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. ${emr.doctorName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Date: ${intl.DateFormat('yyyy-MM-dd HH:mm').format(emr.createdAt)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // System Review Section
            if (emr.systemReview.isNotEmpty) ...[
              _buildSectionHeader('A. System Review'),
              ...emr.systemReview.entries.map((entry) {
                final systemLabel =
                    SystemReviewOptions.systemLabels[entry.key] ?? entry.key;
                return _buildSubSection(systemLabel, entry.value);
              }),
              const SizedBox(height: 24),
            ],

            // Chronic Diseases Section
            if (emr.chronicDiseases.isNotEmpty) ...[
              _buildSectionHeader('B. Chronic Disease Groups'),
              ...emr.chronicDiseases.entries.map((entry) {
                final diseaseLabel =
                    ChronicDiseaseOptions.diseaseLabels[entry.key] ?? entry.key;
                return _buildSubSection(diseaseLabel, entry.value);
              }),
              const SizedBox(height: 24),
            ],

            // ICD-10 Codes Section
            if (emr.icd10Codes.isNotEmpty) ...[
              _buildSectionHeader('C. ICD-10 Diagnosis Codes'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: emr.icd10Codes.map((code) {
                      // Find the description
                      final codeData = ICD10Codes.codes.firstWhere(
                        (c) => c['code'] == code,
                        orElse: () => {'code': code, 'description': ''},
                      );
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${codeData['code']} - ${codeData['description']}',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Notes Section
            if (emr.notes != null && emr.notes!.isNotEmpty) ...[
              _buildSectionHeader('Additional Notes'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    emr.notes!,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const Divider(thickness: 2, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildSubSection(String title, List<String> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, size: 20, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
