import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/admin/presentation/providers/admin_provider.dart';
import 'package:elajtech/features/medical_records/presentation/widgets/medical_record_cards.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:elajtech/shared/models/device_request_model.dart';
import 'package:elajtech/shared/models/lab_request_model.dart';
import 'package:elajtech/shared/models/prescription_model.dart';
import 'package:elajtech/shared/models/radiology_request_model.dart';
import 'package:elajtech/shared/widgets/appointments/appointment_history_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Read-only view of all EMR records belonging to a specific patient.
///
/// The admin can browse all medical collection types. Records are grouped
/// by their source collection name for clarity.
class AdminPatientEmrScreen extends ConsumerStatefulWidget {
  const AdminPatientEmrScreen({required this.patientId, super.key});

  final String patientId;

  @override
  ConsumerState<AdminPatientEmrScreen> createState() =>
      _AdminPatientEmrScreenState();
}

class _AdminPatientEmrScreenState extends ConsumerState<AdminPatientEmrScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(adminProvider.notifier)
          .loadPatientEmrHistory(widget.patientId)
          .ignore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);
    final records = state.emrHistory;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            title: const Text('السجل الطبي'),
            bottom: const TabBar(
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: 'الوصفات الطبية'),
                Tab(text: 'التحاليل'),
                Tab(text: 'الأشعة'),
                Tab(text: 'الأجهزة'),
                Tab(text: 'المواعيد'),
              ],
            ),
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  children: [
                    _AdminEmrCategoryTab(
                      records: records,
                      collection: 'prescriptions',
                    ),
                    _AdminEmrCategoryTab(
                      records: records,
                      collection: 'lab_requests',
                    ),
                    _AdminEmrCategoryTab(
                      records: records,
                      collection: 'radiology_requests',
                    ),
                    _AdminEmrCategoryTab(
                      records: records,
                      collection: 'device_requests',
                    ),
                    _AdminEmrCategoryTab(
                      records: records,
                      collection: 'appointments',
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _AdminEmrCategoryTab extends StatelessWidget {
  const _AdminEmrCategoryTab({
    required this.records,
    required this.collection,
  });

  final List<Map<String, dynamic>> records;
  final String collection;

  @override
  Widget build(BuildContext context) {
    final filtered = records
        .where((r) => r['collection'] == collection)
        .toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('لا توجد بيانات'));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final record = filtered[index];
        final data = record['data'] as Map<String, dynamic>? ?? {};

        switch (collection) {
          case 'prescriptions':
            return PrescriptionCard(
              prescription: PrescriptionModel.fromJson(data),
            );
          case 'lab_requests':
            final req = LabRequestModel.fromJson(data);
            return MedicalRequestCard(
              title: 'طلب تحليل',
              icon: Icons.biotech_outlined,
              color: AppColors.primary,
              items: req.testNames,
              notes: req.notes,
              doctorName: req.doctorName,
              date: req.createdAt,
            );
          case 'radiology_requests':
            final req = RadiologyRequestModel.fromJson(data);
            return MedicalRequestCard(
              title: 'طلب أشعة',
              icon: Icons.rate_review_outlined,
              color: AppColors.secondary,
              items: req.scanTypes,
              notes: req.notes,
              doctorName: req.doctorName,
              date: req.createdAt,
            );
          case 'device_requests':
            final req = DeviceRequestModel.fromJson(data);
            return MedicalRequestCard(
              title: 'طلب جهاز',
              icon: Icons.devices_other,
              color: Colors.indigo,
              items: req.deviceNames,
              notes: req.notes,
              doctorName: req.doctorName,
              date: req.createdAt,
            );
          case 'appointments':
            return AppointmentHistoryCard(
              appointment: AppointmentModel.fromJson(data),
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
