import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/models/paginated_result.dart';
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

const _medicalRecordsCacheDuration = Duration(minutes: 2);
const _medicalRecordsPageSize = 10;

void _cacheProviderFor(Ref<Object?> ref, Duration duration) {
  final link = ref.keepAlive();
  final timer = Timer(duration, link.close);
  ref.onDispose(timer.cancel);
}

PaginatedResult<T> _unwrapOrThrow<T>(
  Either<Failure, PaginatedResult<T>> result,
) {
  return result.fold(
    (failure) => throw Exception(
      failure.message.isNotEmpty
          ? failure.message
          : 'تعذر تحميل السجل الطبي حالياً',
    ),
    (list) => list,
  );
}

final AutoDisposeStateProvider<int> appointmentsPageLimitProvider =
    StateProvider.autoDispose<int>((ref) {
      _cacheProviderFor(ref, _medicalRecordsCacheDuration);
      return _medicalRecordsPageSize;
    });

final AutoDisposeStateProvider<int> prescriptionsPageLimitProvider =
    StateProvider.autoDispose<int>((ref) {
      _cacheProviderFor(ref, _medicalRecordsCacheDuration);
      return _medicalRecordsPageSize;
    });

final AutoDisposeStateProvider<int> labRequestsPageLimitProvider =
    StateProvider.autoDispose<int>((ref) {
      _cacheProviderFor(ref, _medicalRecordsCacheDuration);
      return _medicalRecordsPageSize;
    });

final AutoDisposeStateProvider<int> radiologyRequestsPageLimitProvider =
    StateProvider.autoDispose<int>((ref) {
      _cacheProviderFor(ref, _medicalRecordsCacheDuration);
      return _medicalRecordsPageSize;
    });

final AutoDisposeStateProvider<int> deviceRequestsPageLimitProvider =
    StateProvider.autoDispose<int>((ref) {
      _cacheProviderFor(ref, _medicalRecordsCacheDuration);
      return _medicalRecordsPageSize;
    });

// Providers
final AutoDisposeFutureProvider<PaginatedResult<PrescriptionModel>>
patientPrescriptionsProvider =
    FutureProvider.autoDispose<PaginatedResult<PrescriptionModel>>((ref) async {
      _cacheProviderFor(ref, _medicalRecordsCacheDuration);
      final limit = ref.watch(prescriptionsPageLimitProvider);
      final user = ref.watch(authProvider).user;
      if (user == null) {
        return const PaginatedResult(items: [], hasMore: false);
      }
      final repository = GetIt.I<PrescriptionRepository>();
      final result = await repository.getPrescriptionsForPatientPage(
        user.id,
        limit: limit,
      );
      return _unwrapOrThrow(result);
    });

final AutoDisposeFutureProvider<PaginatedResult<LabRequestModel>>
patientLabRequestsProvider =
    FutureProvider.autoDispose<PaginatedResult<LabRequestModel>>((ref) async {
      _cacheProviderFor(ref, _medicalRecordsCacheDuration);
      final limit = ref.watch(labRequestsPageLimitProvider);
      final user = ref.watch(authProvider).user;
      if (user == null) {
        return const PaginatedResult(items: [], hasMore: false);
      }
      final repository = GetIt.I<LabRequestRepository>();
      final result = await repository.getLabRequestsForPatientPage(
        user.id,
        limit: limit,
      );
      return _unwrapOrThrow(result);
    });

final AutoDisposeFutureProvider<PaginatedResult<RadiologyRequestModel>>
patientRadiologyRequestsProvider =
    FutureProvider.autoDispose<PaginatedResult<RadiologyRequestModel>>((
      ref,
    ) async {
      _cacheProviderFor(ref, _medicalRecordsCacheDuration);
      final limit = ref.watch(radiologyRequestsPageLimitProvider);
      final user = ref.watch(authProvider).user;
      if (user == null) {
        return const PaginatedResult(items: [], hasMore: false);
      }
      final repository = GetIt.I<RadiologyRequestRepository>();
      final result = await repository.getRadiologyRequestsForPatientPage(
        user.id,
        limit: limit,
      );
      return _unwrapOrThrow(result);
    });

final AutoDisposeFutureProvider<PaginatedResult<DeviceRequestModel>>
patientDeviceRequestsProvider =
    FutureProvider.autoDispose<PaginatedResult<DeviceRequestModel>>((
      ref,
    ) async {
      _cacheProviderFor(ref, _medicalRecordsCacheDuration);
      final limit = ref.watch(deviceRequestsPageLimitProvider);
      final user = ref.watch(authProvider).user;
      if (user == null) {
        return const PaginatedResult(items: [], hasMore: false);
      }
      final repository = GetIt.I<DeviceRequestRepository>();
      final result = await repository.getDeviceRequestsForPatientPage(
        user.id,
        limit: limit,
      );
      return _unwrapOrThrow(result);
    });

final AutoDisposeFutureProvider<PaginatedResult<AppointmentModel>>
appointmentsProvider =
    FutureProvider.autoDispose<PaginatedResult<AppointmentModel>>(
      (ref) async {
        _cacheProviderFor(ref, _medicalRecordsCacheDuration);
        final limit = ref.watch(appointmentsPageLimitProvider);
        final user = ref.watch(authProvider).user;
        if (user == null) {
          return const PaginatedResult(items: [], hasMore: false);
        }
        final repository = GetIt.I<AppointmentRepository>();
        final result = await repository.getAppointmentsForPatientPage(
          user.id,
          limit: limit,
        );
        return _unwrapOrThrow(result);
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
  late final Set<int> _activatedTabs;

  @override
  void initState() {
    super.initState();
    final initialTabIndex = widget.initialIndex.clamp(0, 4);
    _activatedTabs = <int>{initialTabIndex};
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: initialTabIndex,
    )..addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_activatedTabs.contains(_tabController.index)) {
      return;
    }
    setState(() {
      _activatedTabs.add(_tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_handleTabChange)
      ..dispose();
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
        children: [
          _AppointmentsTab(isActive: _activatedTabs.contains(0)),
          _PrescriptionsTab(isActive: _activatedTabs.contains(1)),
          _LabTestsTab(isActive: _activatedTabs.contains(2)),
          _ImagingTab(isActive: _activatedTabs.contains(3)),
          _MedicalDevicesTab(isActive: _activatedTabs.contains(4)),
        ],
      ),
    );
  }
}

class _AppointmentsTab extends ConsumerWidget {
  const _AppointmentsTab({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isActive) {
      return const _DeferredTabPlaceholder(
        message: 'اختر هذا التبويب لتحميل سجل المواعيد',
      );
    }

    final appointmentsAsync = ref.watch(appointmentsProvider);

    return appointmentsAsync.when(
      loading: () => const _MedicalRecordsLoadingState(
        message: 'جاري تحميل المواعيد...',
      ),
      error: (err, stack) => _MedicalRecordsErrorState(
        message: 'تعذر تحميل المواعيد',
        onRetry: () => ref.invalidate(appointmentsProvider),
      ),
      data: (appointments) {
        if (appointments.items.isEmpty) {
          return _MedicalRecordsEmptyState(
            message: 'لا يوجد مواعيد سابقة',
            onRefresh: () async {
              ref.read(appointmentsPageLimitProvider.notifier).state =
                  _medicalRecordsPageSize;
              final _ = await ref.refresh(appointmentsProvider.future);
            },
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.read(appointmentsPageLimitProvider.notifier).state =
                _medicalRecordsPageSize;
            final _ = await ref.refresh(appointmentsProvider.future);
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 100,
            ),
            itemCount:
                appointments.items.length + (appointments.hasMore ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == appointments.items.length) {
                return _LoadMoreButton(
                  onPressed: () {
                    ref.read(appointmentsPageLimitProvider.notifier).state +=
                        _medicalRecordsPageSize;
                  },
                );
              }
              final appointment = appointments.items[index];
              return AppointmentHistoryCard(appointment: appointment);
            },
          ),
        );
      },
    );
  }
}

class _PrescriptionsTab extends ConsumerWidget {
  const _PrescriptionsTab({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isActive) {
      return const _DeferredTabPlaceholder(
        message: 'افتح الوصفات الطبية عند الحاجة لتسريع التحميل',
      );
    }

    final prescriptionsAsync = ref.watch(patientPrescriptionsProvider);

    return prescriptionsAsync.when(
      loading: () => const _MedicalRecordsLoadingState(
        message: 'جاري تحميل الوصفات الطبية...',
      ),
      error: (err, stack) => _MedicalRecordsErrorState(
        message: 'تعذر تحميل الوصفات الطبية',
        onRetry: () => ref.invalidate(patientPrescriptionsProvider),
      ),
      data: (prescriptions) {
        if (prescriptions.items.isEmpty) {
          return _MedicalRecordsEmptyState(
            message: 'لا يوجد وصفات طبية',
            onRefresh: () async {
              ref.read(prescriptionsPageLimitProvider.notifier).state =
                  _medicalRecordsPageSize;
              final _ = await ref.refresh(patientPrescriptionsProvider.future);
            },
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.read(prescriptionsPageLimitProvider.notifier).state =
                _medicalRecordsPageSize;
            final _ = await ref.refresh(patientPrescriptionsProvider.future);
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 100,
            ),
            itemCount:
                prescriptions.items.length + (prescriptions.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == prescriptions.items.length) {
                return _LoadMoreButton(
                  onPressed: () {
                    ref.read(prescriptionsPageLimitProvider.notifier).state +=
                        _medicalRecordsPageSize;
                  },
                );
              }
              final prescription = prescriptions.items[index];
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
          ),
        );
      },
    );
  }
}

class _LabTestsTab extends ConsumerWidget {
  const _LabTestsTab({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isActive) {
      return const _DeferredTabPlaceholder(
        message: 'افتح التحاليل عند الحاجة لتحميلها بشكل مستقل',
      );
    }

    final labsAsync = ref.watch(patientLabRequestsProvider);

    return labsAsync.when(
      loading: () => const _MedicalRecordsLoadingState(
        message: 'جاري تحميل التحاليل...',
      ),
      error: (err, stack) => _MedicalRecordsErrorState(
        message: 'تعذر تحميل طلبات التحاليل',
        onRetry: () => ref.invalidate(patientLabRequestsProvider),
      ),
      data: (requests) {
        if (requests.items.isEmpty) {
          return _MedicalRecordsEmptyState(
            message: 'لا يوجد طلبات تحليل',
            onRefresh: () async {
              ref.read(labRequestsPageLimitProvider.notifier).state =
                  _medicalRecordsPageSize;
              final _ = await ref.refresh(patientLabRequestsProvider.future);
            },
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.read(labRequestsPageLimitProvider.notifier).state =
                _medicalRecordsPageSize;
            final _ = await ref.refresh(patientLabRequestsProvider.future);
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 100,
            ),
            itemCount: requests.items.length + (requests.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == requests.items.length) {
                return _LoadMoreButton(
                  onPressed: () {
                    ref.read(labRequestsPageLimitProvider.notifier).state +=
                        _medicalRecordsPageSize;
                  },
                );
              }
              final req = requests.items[index];
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
                    final pdfBytes = await PdfService.generateLabRequestPdf(
                      req,
                    );
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
          ),
        );
      },
    );
  }
}

class _ImagingTab extends ConsumerWidget {
  const _ImagingTab({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isActive) {
      return const _DeferredTabPlaceholder(
        message: 'سيتم تحميل الأشعة فقط عند فتح هذا التبويب',
      );
    }

    final radiologyAsync = ref.watch(patientRadiologyRequestsProvider);

    return radiologyAsync.when(
      loading: () => const _MedicalRecordsLoadingState(
        message: 'جاري تحميل طلبات الأشعة...',
      ),
      error: (err, stack) => _MedicalRecordsErrorState(
        message: 'تعذر تحميل طلبات الأشعة',
        onRetry: () => ref.invalidate(patientRadiologyRequestsProvider),
      ),
      data: (requests) {
        if (requests.items.isEmpty) {
          return _MedicalRecordsEmptyState(
            message: 'لا يوجد طلبات أشعة',
            onRefresh: () async {
              ref.read(radiologyRequestsPageLimitProvider.notifier).state =
                  _medicalRecordsPageSize;
              final _ = await ref.refresh(
                patientRadiologyRequestsProvider.future,
              );
            },
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.read(radiologyRequestsPageLimitProvider.notifier).state =
                _medicalRecordsPageSize;
            final _ = await ref.refresh(
              patientRadiologyRequestsProvider.future,
            );
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 100,
            ),
            itemCount: requests.items.length + (requests.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == requests.items.length) {
                return _LoadMoreButton(
                  onPressed: () {
                    ref
                            .read(radiologyRequestsPageLimitProvider.notifier)
                            .state +=
                        _medicalRecordsPageSize;
                  },
                );
              }
              final req = requests.items[index];
              return MedicalRequestCard(
                title: 'طلب أشعة',
                icon: Icons.rate_review_outlined,
                color: AppColors.secondary,
                items: req.scanTypes,
                notes: req.notes,
                doctorName: req.doctorName,
                date: req.createdAt,
                onDownloadPdf: () async {
                  try {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('جاري إنشاء ملف PDF...')),
                    );
                    final pdfBytes =
                        await PdfService.generateRadiologyRequestPdf(req);
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
          ),
        );
      },
    );
  }
}

class _MedicalDevicesTab extends ConsumerWidget {
  const _MedicalDevicesTab({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isActive) {
      return const _DeferredTabPlaceholder(
        message: 'سيتم تحميل الأجهزة الطبية عند فتح التبويب فقط',
      );
    }

    final devicesAsync = ref.watch(patientDeviceRequestsProvider);

    return devicesAsync.when(
      loading: () => const _MedicalRecordsLoadingState(
        message: 'جاري تحميل الأجهزة الطبية...',
      ),
      error: (err, stack) => _MedicalRecordsErrorState(
        message: 'تعذر تحميل طلبات الأجهزة',
        onRetry: () => ref.invalidate(patientDeviceRequestsProvider),
      ),
      data: (requests) {
        if (requests.items.isEmpty) {
          return _MedicalRecordsEmptyState(
            message: 'لا يوجد طلبات أجهزة',
            onRefresh: () async {
              ref.read(deviceRequestsPageLimitProvider.notifier).state =
                  _medicalRecordsPageSize;
              final _ = await ref.refresh(patientDeviceRequestsProvider.future);
            },
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.read(deviceRequestsPageLimitProvider.notifier).state =
                _medicalRecordsPageSize;
            final _ = await ref.refresh(patientDeviceRequestsProvider.future);
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 100,
            ),
            itemCount: requests.items.length + (requests.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == requests.items.length) {
                return _LoadMoreButton(
                  onPressed: () {
                    ref.read(deviceRequestsPageLimitProvider.notifier).state +=
                        _medicalRecordsPageSize;
                  },
                );
              }
              final req = requests.items[index];
              return MedicalRequestCard(
                title: 'طلب جهاز',
                icon: Icons.devices_other,
                color: Colors.indigo,
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
          ),
        );
      },
    );
  }
}

class _DeferredTabPlaceholder extends StatelessWidget {
  const _DeferredTabPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bolt_outlined,
              size: 42,
              color: AppColors.primary.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicalRecordsLoadingState extends StatelessWidget {
  const _MedicalRecordsLoadingState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (_, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          );
        }

        return Container(
          height: 110,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MedicalRecordsErrorState extends StatelessWidget {
  const _MedicalRecordsErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'يمكنك المحاولة مرة أخرى دون إعادة تحميل بقية السجل الطبي.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicalRecordsEmptyState extends StatelessWidget {
  const _MedicalRecordsEmptyState({
    required this.message,
    required this.onRefresh,
  });

  final String message;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        children: [
          const SizedBox(height: 60),
          const Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: AppColors.textSecondaryLight,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'اسحب لأسفل للتحديث أو عد لاحقاً إذا تمت إضافة بيانات جديدة.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.expand_more),
        label: const Text('تحميل المزيد'),
      ),
    );
  }
}
