import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/services/pdf_service.dart';
import 'package:elajtech/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/device_requests/domain/repositories/device_request_repository.dart';
import 'package:elajtech/features/lab_requests/domain/repositories/lab_request_repository.dart';
import 'package:elajtech/features/medical_records/presentation/widgets/medical_record_cards.dart';
import 'package:elajtech/features/prescriptions/domain/repositories/prescription_repository.dart';
import 'package:elajtech/features/radiology_requests/domain/repositories/radiology_request_repository.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:elajtech/shared/models/device_request_model.dart';
import 'package:elajtech/shared/models/lab_request_model.dart';
import 'package:elajtech/shared/models/prescription_model.dart';
import 'package:elajtech/shared/models/radiology_request_model.dart';
import 'package:elajtech/shared/widgets/appointments/appointment_history_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:printing/printing.dart';

// Providers
final AutoDisposeFutureProvider<List<PrescriptionModel>>
patientPrescriptionsProvider =
    FutureProvider.autoDispose<List<PrescriptionModel>>((ref) async {
      final user = ref.watch(authProvider).user;
      if (user == null) return [];
      final repository = GetIt.I<PrescriptionRepository>();
      final result = await repository.getPrescriptionsForPatient(user.id);
      return result.fold(
        (failure) => [],
        (list) => list,
      );
    });

final AutoDisposeFutureProvider<List<LabRequestModel>>
patientLabRequestsProvider = FutureProvider.autoDispose<List<LabRequestModel>>((
  ref,
) async {
  final user = ref.watch(authProvider).user;
  if (user == null) return [];
  final repository = GetIt.I<LabRequestRepository>();
  final result = await repository.getLabRequestsForPatient(user.id);
  return result.fold(
    (failure) => [],
    (list) => list,
  );
});

final AutoDisposeFutureProvider<List<RadiologyRequestModel>>
patientRadiologyRequestsProvider =
    FutureProvider.autoDispose<List<RadiologyRequestModel>>((ref) async {
      final user = ref.watch(authProvider).user;
      if (user == null) return [];
      final repository = GetIt.I<RadiologyRequestRepository>();
      final result = await repository.getRadiologyRequestsForPatient(user.id);
      return result.fold(
        (failure) => [],
        (list) => list,
      );
    });

final AutoDisposeFutureProvider<List<DeviceRequestModel>>
patientDeviceRequestsProvider =
    FutureProvider.autoDispose<List<DeviceRequestModel>>((ref) async {
      final user = ref.watch(authProvider).user;
      if (user == null) return [];
      final repository = GetIt.I<DeviceRequestRepository>();
      final result = await repository.getDeviceRequestsForPatient(user.id);
      return result.fold(
        (failure) => [],
        (list) => list,
      );
    });

final AutoDisposeFutureProvider<List<AppointmentModel>> appointmentsProvider =
    FutureProvider.autoDispose<List<AppointmentModel>>(
      (ref) async {
        final user = ref.watch(authProvider).user;
        if (user == null) return [];
        final repository = GetIt.I<AppointmentRepository>();
        final result = await repository.getAppointmentsForPatient(user.id);
        return result.fold(
          (failure) => [], // Return empty on error or handle differently
          (list) => list,
        );
      },
    );

class MedicalRecordsScreen extends ConsumerStatefulWidget {
  const MedicalRecordsScreen({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  ConsumerState<MedicalRecordsScreen> createState() =>
      _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends ConsumerState<MedicalRecordsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('السجل الطبي'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'المواعيد'),
            Tab(text: 'الوصفات الطبية'),
            Tab(text: 'التحاليل'),
            Tab(text: 'الأشعة'),
            Tab(text: 'الأجهزة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AppointmentsTab(),
          _PrescriptionsTab(),
          _LabTestsTab(),
          _ImagingTab(),
          _MedicalDevicesTab(),
        ],
      ),
    );
  }
}

class _AppointmentsTab extends ConsumerWidget {
  const _AppointmentsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsProvider);

    return appointmentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
      data: (appointments) {
        if (appointments.isEmpty) {
          return const Center(child: Text('لا يوجد مواعيد سابقة'));
        }
        return ListView.separated(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 100,
          ),
          itemCount: appointments.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            return AppointmentHistoryCard(appointment: appointment);
          },
        );
      },
    );
  }
}

class _PrescriptionsTab extends ConsumerWidget {
  const _PrescriptionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prescriptionsAsync = ref.watch(patientPrescriptionsProvider);

    return prescriptionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
      data: (prescriptions) {
        if (prescriptions.isEmpty) {
          return const Center(child: Text('لا يوجد وصفات طبية'));
        }
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 100,
          ),
          itemCount: prescriptions.length,
          itemBuilder: (context, index) {
            final prescription = prescriptions[index];
            return PrescriptionCard(
              prescription: prescription,
              onDownloadPdf: () async {
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('جاري إنشاء ملف PDF...')),
                  );
                  final pdfBytes = await PdfService.generatePrescriptionPdf(
                    prescription,
                  );
                  await Printing.layoutPdf(
                    onLayout: (format) => pdfBytes,
                    name: 'prescription_${prescription.id}.pdf',
                  );
                } on Exception catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
                  }
                }
              },
            );
          },
        );
      },
    );
  }
}

class _LabTestsTab extends ConsumerWidget {
  const _LabTestsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labsAsync = ref.watch(patientLabRequestsProvider);

    return labsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
      data: (requests) {
        if (requests.isEmpty) {
          return const Center(child: Text('لا يوجد طلبات تحليل'));
        }
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 100,
          ),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            return MedicalRequestCard(
              title: 'طلب تحليل',
              icon: Icons.biotech_outlined,
              color: AppColors.primary,
              items: req.testNames,
              notes: req.notes,
              doctorName: req.doctorName,
              date: req.createdAt,
              onDownloadPdf: () async {
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('جاري إنشاء ملف PDF...')),
                  );
                  final pdfBytes = await PdfService.generateLabRequestPdf(req);
                  await Printing.layoutPdf(
                    onLayout: (format) => pdfBytes,
                    name: 'lab_request_${req.id}.pdf',
                  );
                } on Exception catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
                  }
                }
              },
            );
          },
        );
      },
    );
  }
}

class _ImagingTab extends ConsumerWidget {
  const _ImagingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radiologyAsync = ref.watch(patientRadiologyRequestsProvider);

    return radiologyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
      data: (requests) {
        if (requests.isEmpty) {
          return const Center(child: Text('لا يوجد طلبات أشعة'));
        }
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 100,
          ),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            return MedicalRequestCard(
              title: 'طلب أشعة',
              icon: Icons.rate_review_outlined,
              color: AppColors
                  .secondary, // Or AppColors.warning based on preference, using Secondary (Teal) as per Doctor View
              items: req.scanTypes,
              notes: req.notes,
              doctorName: req.doctorName,
              date: req.createdAt,
              onDownloadPdf: () async {
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('جاري إنشاء ملف PDF...')),
                  );
                  final pdfBytes = await PdfService.generateRadiologyRequestPdf(
                    req,
                  );
                  await Printing.layoutPdf(
                    onLayout: (format) => pdfBytes,
                    name: 'radiology_request_${req.id}.pdf',
                  );
                } on Exception catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
                  }
                }
              },
            );
          },
        );
      },
    );
  }
}

class _MedicalDevicesTab extends ConsumerWidget {
  const _MedicalDevicesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(patientDeviceRequestsProvider);

    return devicesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
      data: (requests) {
        if (requests.isEmpty) {
          return const Center(child: Text('لا يوجد طلبات أجهزة'));
        }
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 100,
          ),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            return MedicalRequestCard(
              title: 'طلب جهاز',
              icon: Icons.devices_other,
              color: Colors.indigo, // Changed from Orange to Indigo
              items: req.deviceNames,
              notes: req.notes,
              doctorName: req.doctorName,
              date: req.createdAt,
              onDownloadPdf: () async {
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('جاري إنشاء ملف PDF...')),
                  );
                  final pdfBytes = await PdfService.generateDeviceRequestPdf(
                    req,
                  );
                  await Printing.layoutPdf(
                    onLayout: (format) => pdfBytes,
                    name: 'device_request_${req.id}.pdf',
                  );
                } on Exception catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
                  }
                }
              },
            );
          },
        );
      },
    );
  }
}
