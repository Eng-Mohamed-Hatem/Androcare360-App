import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/device_requests/domain/repositories/device_request_repository.dart';
import 'package:elajtech/features/doctor/medical_requests/presentation/screens/add_medical_request_screen.dart';
import 'package:elajtech/features/doctor/prescriptions/presentation/screens/add_prescription_screen.dart';
import 'package:elajtech/features/lab_requests/domain/repositories/lab_request_repository.dart';
import 'package:elajtech/features/prescriptions/domain/repositories/prescription_repository.dart';
import 'package:elajtech/features/radiology_requests/domain/repositories/radiology_request_repository.dart';
import 'package:elajtech/shared/models/device_request_model.dart';
import 'package:elajtech/shared/models/lab_request_model.dart';
import 'package:elajtech/shared/models/prescription_model.dart';
import 'package:elajtech/shared/models/radiology_request_model.dart';
import 'package:elajtech/shared/providers/appointments_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class PatientMedicalRecordScreen extends ConsumerStatefulWidget {
  const PatientMedicalRecordScreen({
    required this.patientId,
    required this.patientName,
    super.key,
  });
  final String patientId;
  final String patientName;

  @override
  ConsumerState<PatientMedicalRecordScreen> createState() =>
      _PatientMedicalRecordScreenState();
}

class _PatientMedicalRecordScreenState
    extends ConsumerState<PatientMedicalRecordScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _navigateToAddScreen(int index) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) {
          if (index == 0) {
            return AddPrescriptionScreen(
              patientId: widget.patientId,
              patientName: widget.patientName,
              appointmentId: '',
            );
          } else {
            final type = index == 1
                ? MedicalRequestType.lab
                : index == 2
                ? MedicalRequestType.radiology
                : MedicalRequestType.device;

            return AddMedicalRequestScreen(
              requestType: type,
              patientId: widget.patientId,
              patientName: widget.patientName,
              appointmentId: '',
            );
          }
        },
      ),
    );

    // Refresh the list after returning
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check Permissions
    final canEdit = ref
        .watch(appointmentsProvider.notifier)
        .hasAppointmentToday(widget.patientId);

    // We can also double check current user is a Doctor
    final isDoctor = ref.read(authProvider).user?.userType.name == 'doctor';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('السجل الطبي', style: TextStyle(fontSize: 16)),
            Text(
              widget.patientName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'الوصفات الطبية'),
            Tab(text: 'التحاليل'),
            Tab(text: 'الأشعة'),
            Tab(text: 'الأجهزة الطبية'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RecordList(
            key: ValueKey('$_refreshKey-prescription'),
            type: 'prescription',
            patientId: widget.patientId,
          ),
          _RecordList(
            key: ValueKey('$_refreshKey-lab'),
            type: 'lab',
            patientId: widget.patientId,
          ),
          _RecordList(
            key: ValueKey('$_refreshKey-radiology'),
            type: 'radiology',
            patientId: widget.patientId,
          ),
          _RecordList(
            key: ValueKey('$_refreshKey-device'),
            type: 'device',
            patientId: widget.patientId,
          ),
        ],
      ),
      floatingActionButton: (canEdit && isDoctor)
          ? FloatingActionButton.extended(
              onPressed: () => _navigateToAddScreen(_tabController.index),
              label: const Text('إضافة جديد'),
              icon: const Icon(Icons.add),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }
}

class _RecordList extends StatefulWidget {
  const _RecordList({required this.type, required this.patientId, super.key});
  final String type;
  final String patientId;

  @override
  State<_RecordList> createState() => _RecordListState();
}

class _RecordListState extends State<_RecordList> {
  late Future<List<dynamic>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _recordsFuture = _fetchRecords();
    });
  }

  Future<List<dynamic>> _fetchRecords() async {
    switch (widget.type) {
      case 'prescription':
        final result = await GetIt.I<PrescriptionRepository>()
            .getPrescriptionsForPatient(widget.patientId);
        return result.fold((l) => [], (r) => r);
      case 'lab':
        final result = await GetIt.I<LabRequestRepository>()
            .getLabRequestsForPatient(widget.patientId);
        return result.fold((l) => [], (r) => r);
      case 'radiology':
        final repository = GetIt.I<RadiologyRequestRepository>();
        final result = await repository.getRadiologyRequestsForPatient(
          widget.patientId,
        );
        return result.fold((l) => [], (r) => r);
      case 'device':
        final repository = GetIt.I<DeviceRequestRepository>();
        final result = await repository.getDeviceRequestsForPatient(
          widget.patientId,
        );
        return result.fold((l) => [], (r) => r);
      default:
        return [];
    }
  }

  @override
  void didUpdateWidget(covariant _RecordList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type ||
        oldWidget.patientId != widget.patientId) {
      _loadRecords();
    }
  }

  Widget _buildChip(String label, Color color, {IconData? icon}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            color: color.withValues(
              alpha: 0.9,
            ), // Slightly darker for readability
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );

  Widget _buildRecordItem(dynamic item) {
    if (item is PrescriptionModel) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderLight),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ExpansionTile(
          shape: Border.all(
            color: Colors.transparent,
          ), // Remove border when expanded
          collapsedShape: Border.all(color: Colors.transparent),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.medication, color: AppColors.primary),
          ),
          title: const Text(
            'وصفة طبية',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${DateFormat('yyyy/MM/dd').format(item.createdAt)} • د. ${item.doctorName}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: item.medicines
                        .map(
                          (med) => _buildChip(
                            '${med.name} (${med.frequency})',
                            AppColors.primary,
                            icon: Icons
                                .medication_liquid_outlined, // Generic med icon
                          ),
                        )
                        .toList(),
                  ),
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ملاحظات: ${item.notes}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    } else if (item is LabRequestModel) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderLight),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ExpansionTile(
          shape: Border.all(color: Colors.transparent),
          collapsedShape: Border.all(color: Colors.transparent),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.science, color: AppColors.secondary),
          ),
          title: const Text(
            'طلب تحليل',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${DateFormat('yyyy/MM/dd').format(item.createdAt)} • د. ${item.doctorName}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: item.testNames
                        .map((test) => _buildChip(test, AppColors.secondary))
                        .toList(),
                  ),
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ملاحظات: ${item.notes}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    } else if (item is RadiologyRequestModel) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderLight),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ExpansionTile(
          shape: Border.all(color: Colors.transparent),
          collapsedShape: Border.all(color: Colors.transparent),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.medical_services, color: AppColors.warning),
          ),
          title: const Text(
            'طلب أشعة',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${DateFormat('yyyy/MM/dd').format(item.createdAt)} • د. ${item.doctorName}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: item.scanTypes
                        .map((scan) => _buildChip(scan, AppColors.warning))
                        .toList(),
                  ),
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ملاحظات: ${item.notes}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    } else if (item is DeviceRequestModel) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderLight),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ExpansionTile(
          shape: Border.all(color: Colors.transparent),
          collapsedShape: Border.all(color: Colors.transparent),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.monitor_heart, color: AppColors.error),
          ),
          title: const Text(
            'طلب جهاز',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${DateFormat('yyyy/MM/dd').format(item.createdAt)} • د. ${item.doctorName}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: item.deviceNames
                        .map(
                          (device) => _buildChip(
                            device,
                            AppColors.error,
                            icon: Icons.medical_services_outlined,
                          ),
                        )
                        .toList(),
                  ),
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ملاحظات: ${item.notes}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<dynamic>>(
    key: ValueKey(widget.type), // Force rebuild if type changes
    future: _recordsFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Center(child: Text('حدث خطأ: ${snapshot.error}'));
      }

      final items = snapshot.data ?? [];

      if (items.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'لا توجد سجلات لعرضها حالياً',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => _buildRecordItem(items[index]),
      );
    },
  );
}
