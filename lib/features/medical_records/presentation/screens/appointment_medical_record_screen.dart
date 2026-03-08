import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/services/permission_service.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/device_requests/domain/repositories/device_request_repository.dart';
import 'package:elajtech/features/doctor/medical_records/data/repositories/physiotherapy_emr_repository.dart';
import 'package:elajtech/features/doctor/medical_records/domain/entities/physiotherapy_emr.dart';
import 'package:elajtech/features/nutrition/domain/entities/nutrition_emr_entity.dart';
import 'package:elajtech/features/nutrition/domain/repositories/nutrition_emr_repository.dart';
import 'package:elajtech/features/doctor/medical_records/presentation/screens/add_emr_screen.dart';
import 'package:elajtech/features/doctor/medical_records/presentation/screens/add_internal_medicine_emr_screen.dart';
import 'package:elajtech/features/doctor/medical_requests/presentation/screens/add_medical_request_screen.dart';
import 'package:elajtech/features/doctor/prescriptions/presentation/screens/add_prescription_screen.dart';
import 'package:elajtech/features/emr/domain/repositories/emr_repository.dart';
import 'package:elajtech/features/emr/domain/repositories/internal_medicine_emr_repository.dart';
import 'package:elajtech/features/lab_requests/domain/repositories/lab_request_repository.dart';
import 'package:elajtech/features/medical_records/presentation/screens/emr_details_screen.dart';
import 'package:elajtech/features/medical_records/presentation/screens/internal_medicine_emr_details_screen.dart';
import 'package:elajtech/features/medical_records/presentation/widgets/medical_record_cards.dart';
import 'package:elajtech/features/nutrition/presentation/screens/nutrition_clinic_screen.dart';
import 'package:elajtech/features/prescriptions/domain/repositories/prescription_repository.dart';
import 'package:elajtech/features/radiology_requests/domain/repositories/radiology_request_repository.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:elajtech/shared/models/device_request_model.dart';
import 'package:elajtech/shared/models/emr_model.dart';
import 'package:elajtech/shared/models/internal_medicine_emr_model.dart';
import 'package:elajtech/shared/models/lab_request_model.dart';
import 'package:elajtech/shared/models/prescription_model.dart';
import 'package:elajtech/shared/models/radiology_request_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

class AppointmentMedicalRecordScreen extends ConsumerStatefulWidget {
  const AppointmentMedicalRecordScreen({
    required this.appointment,
    required this.patientName,
    super.key,
  });
  final AppointmentModel appointment;
  final String patientName;

  @override
  ConsumerState<AppointmentMedicalRecordScreen> createState() =>
      _AppointmentMedicalRecordScreenState();
}

class _AppointmentMedicalRecordScreenState
    extends ConsumerState<AppointmentMedicalRecordScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _canViewAndrologyEMR = false;
  bool _canViewInternalMedicineEMR = false;
  bool _canViewNutritionEMR = false;
  bool _canViewPhysiotherapyEMR = false;
  bool _canEdit = false;
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();

    if (kDebugMode) {
      debugPrint('');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint(
        '🚀 [EMR Screen] initState - Initializing Medical Record Screen',
      );
      debugPrint('═══════════════════════════════════════════════════════════');
    }

    final user = ref.read(authProvider).user;

    if (kDebugMode) {
      if (user != null) {
        debugPrint('👤 [EMR Screen] Current User:');
        debugPrint('   - ID: ${user.id}');
        debugPrint('   - Name: ${user.fullName}');
        debugPrint('   - Type: ${user.userType}');
        debugPrint('   - Specializations: ${user.specializations ?? "None"}');
      } else {
        debugPrint('⚠️ [EMR Screen] User is NULL');
      }
    }

    // Check all permissions using SpecialtyConstants
    _canViewAndrologyEMR = PermissionsService.canViewEMR(user);
    _canViewInternalMedicineEMR = PermissionsService.canViewInternalMedicineEMR(
      user,
    );
    _canViewNutritionEMR = PermissionsService.canViewNutritionEMR(user);
    _canViewPhysiotherapyEMR = PermissionsService.canViewPhysiotherapyEMR(user);
    _canEdit =
        user != null &&
        PermissionsService.canEditRecord(widget.appointment, user.id);

    if (kDebugMode) {
      debugPrint('');
      debugPrint('📋 [EMR Screen] Permission Results:');
      debugPrint('   - Can View Andrology EMR? $_canViewAndrologyEMR');
      debugPrint(
        '   - Can View Internal Medicine EMR? $_canViewInternalMedicineEMR',
      );
      debugPrint('   - Can View Nutrition EMR? $_canViewNutritionEMR');
      debugPrint('   - Can View Physiotherapy EMR? $_canViewPhysiotherapyEMR');
      debugPrint('   - Can Edit Records? $_canEdit');
      debugPrint('');
      debugPrint(
        '✅ [EMR Screen] Unified UI - Always showing 5 tabs for all doctors',
      );
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('');
    }

    // Fixed tab count: Always 5 tabs for all doctors
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _navigateToAddScreen(int index) async {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('📝 [EMR Screen] User tapped Add button on tab index: $index');
    }

    // Fixed tab indices:
    // 0: Prescription
    // 1: Lab
    // 2: Radiology
    // 3: Device
    // 4: EMR

    if (index == 0) {
      // Prescription tab
      if (kDebugMode) {
        debugPrint('   ➡️ Navigating to Add Prescription Screen');
      }
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (context) => AddPrescriptionScreen(
            patientId: widget.appointment.patientId,
            patientName: widget.patientName,
            appointmentId: widget.appointment.id,
          ),
        ),
      );
    } else if (index >= 1 && index <= 3) {
      // Investigation tabs (Lab=1, Radiology=2, Device=3)
      final type = index == 1
          ? MedicalRequestType.lab
          : index == 2
          ? MedicalRequestType.radiology
          : MedicalRequestType.device;

      if (kDebugMode) {
        debugPrint('   ➡️ Navigating to Add Medical Request Screen: $type');
      }

      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (context) => AddMedicalRequestScreen(
            requestType: type,
            patientId: widget.appointment.patientId,
            patientName: widget.patientName,
            appointmentId: widget.appointment.id,
          ),
        ),
      );
    } else if (index == 4) {
      // EMR tab
      // Determine which EMR screen to show based on specialty
      if (_canViewNutritionEMR) {
        if (kDebugMode) {
          debugPrint('   ➡️ Navigating to Add Nutrition EMR Screen');
        }
        await Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (context) => NutritionClinicScreen(
              patientId: widget.appointment.patientId,
              appointmentId: widget.appointment.id,
            ),
          ),
        );

        // 🔄 IMMEDIATE REFRESH: Invalidate Nutrition EMR Provider on return
        if (mounted) {
          if (kDebugMode) {
            debugPrint(
              '   🔄 [EMR Screen] Returned from Nutrition Clinic - Refreshing EMR list',
            );
          }
          // Force re-fetch from Firestore to show newly created/updated records
          setState(() {
            _refreshKey++;
          });
        }
      } else if (_canViewPhysiotherapyEMR) {
        if (kDebugMode) {
          debugPrint('   ➡️ Navigating to Add Physiotherapy EMR Screen');
        }
        await Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (context) => AddEMRScreen(
              patientId: widget.appointment.patientId,
              patientName: widget.patientName,
              appointmentId: widget.appointment.id,
            ),
          ),
        );

        // 🔄 IMMEDIATE REFRESH after Physiotherapy EMR screen
        if (mounted) {
          setState(() {
            _refreshKey++;
          });
        }
      } else if (_canViewAndrologyEMR) {
        if (kDebugMode) {
          debugPrint('   ➡️ Navigating to Add Andrology EMR Screen');
        }
        await Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (context) => AddEMRScreen(
              patientId: widget.appointment.patientId,
              patientName: widget.patientName,
              appointmentId: widget.appointment.id,
            ),
          ),
        );

        // 🔄 IMMEDIATE REFRESH after Andrology EMR screen
        if (mounted) {
          setState(() {
            _refreshKey++;
          });
        }
      } else if (_canViewInternalMedicineEMR) {
        if (kDebugMode) {
          debugPrint('   ➡️ Navigating to Add Internal Medicine EMR Screen');
        }
        await Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (context) => AddInternalMedicineEMRScreen(
              patientId: widget.appointment.patientId,
              patientName: widget.patientName,
              appointmentId: widget.appointment.id,
            ),
          ),
        );

        // 🔄 IMMEDIATE REFRESH after Internal Medicine EMR screen
        if (mounted) {
          setState(() {
            _refreshKey++;
          });
        }
      }
    }

    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Null safety check - prevent crashes on logout
    final user = ref.watch(authProvider).user;
    if (user == null) {
      if (kDebugMode) {
        debugPrint('⚠️ [EMR Screen] User is null, returning empty widget');
      }
      return const SizedBox();
    }

    // Fixed 5 tabs - always shown for all doctors
    final tabs = <Tab>[
      const Tab(text: 'الوصفات الطبية'),
      const Tab(text: 'التحاليل'),
      const Tab(text: 'الأشعة'),
      const Tab(text: 'الأجهزة'),
      const Tab(text: 'EMR'),
    ];

    // Fixed 5 tab views - always shown for all doctors
    final tabViews = <Widget>[
      _AppointmentRecordList(
        key: ValueKey('$_refreshKey-prescription'),
        type: 'prescription',
        appointmentId: widget.appointment.id,
        patientId: widget.appointment.patientId,
        patientName: widget.patientName,
      ),
      _AppointmentRecordList(
        key: ValueKey('$_refreshKey-lab'),
        type: 'lab',
        appointmentId: widget.appointment.id,
        patientId: widget.appointment.patientId,
        patientName: widget.patientName,
      ),
      _AppointmentRecordList(
        key: ValueKey('$_refreshKey-radiology'),
        type: 'radiology',
        appointmentId: widget.appointment.id,
        patientId: widget.appointment.patientId,
        patientName: widget.patientName,
      ),
      _AppointmentRecordList(
        key: ValueKey('$_refreshKey-device'),
        type: 'device',
        appointmentId: widget.appointment.id,
        patientId: widget.appointment.patientId,
        patientName: widget.patientName,
      ),
      // EMR tab with LTR (left-to-right) text direction
      Directionality(
        textDirection: TextDirection.ltr,
        child: _AppointmentRecordList(
          key: ValueKey('$_refreshKey-emr'),
          type: _determineEMRType(),
          appointmentId: widget.appointment.id,
          patientId: widget.appointment.patientId,
          patientName: widget.patientName,
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('السجل الطبي للموعد', style: TextStyle(fontSize: 16)),
            Text(
              '${widget.patientName} - ${widget.appointment.appointmentDate.toString().split(' ')[0]}',
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
          tabs: tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabViews,
      ),
      floatingActionButton: _canEdit
          ? FloatingActionButton.extended(
              onPressed: () => _navigateToAddScreen(_tabController.index),
              label: const Text('إضافة جديد'),
              icon: const Icon(Icons.add),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }

  /// Determine which EMR type to display based on doctor's specialty
  String _determineEMRType() {
    if (_canViewNutritionEMR) {
      return 'nutrition_emr';
    } else if (_canViewPhysiotherapyEMR) {
      return 'physiotherapy_emr';
    } else if (_canViewAndrologyEMR) {
      return 'emr';
    } else if (_canViewInternalMedicineEMR) {
      return 'internal_medicine_emr';
    }
    // Default fallback
    return 'emr';
  }
}

class _AppointmentRecordList extends StatefulWidget {
  const _AppointmentRecordList({
    required this.type,
    required this.appointmentId,
    required this.patientId,
    required this.patientName,
    super.key,
  });
  final String type;
  final String appointmentId;
  final String patientId;
  final String patientName;

  @override
  State<_AppointmentRecordList> createState() => _AppointmentRecordListState();
}

class _AppointmentRecordListState extends State<_AppointmentRecordList> {
  late Future<List<dynamic>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      debugPrint('');
      debugPrint('📄 [Record List] Loading records for type: ${widget.type}');
    }
    // FIX: Initialize Future only once in initState to prevent rebuilds
    _recordsFuture = _fetchRecords();
  }

  void _loadRecords() {
    setState(() {
      _recordsFuture = _fetchRecords();
    });
  }

  Future<List<dynamic>> _fetchRecords() async {
    if (kDebugMode) {
      debugPrint('   ⏳ [Record List] Fetching records from Firestore...');
    }

    try {
      switch (widget.type) {
        case 'prescription':
          final result = await GetIt.I<PrescriptionRepository>()
              .getPrescriptionsByAppointmentId(widget.appointmentId);
          final records = result.fold((l) => <dynamic>[], (r) => r);
          if (kDebugMode) {
            debugPrint(
              '   ✅ [Record List] Loaded ${records.length} prescription(s)',
            );
          }
          return records;
        case 'lab':
          final result = await GetIt.I<LabRequestRepository>()
              .getLabRequestsByAppointmentId(widget.appointmentId);
          final records = result.fold((l) => <dynamic>[], (r) => r);
          if (kDebugMode) {
            debugPrint(
              '   ✅ [Record List] Loaded ${records.length} lab request(s)',
            );
          }
          return records;
        case 'radiology':
          final repository = GetIt.I<RadiologyRequestRepository>();
          final result = await repository.getRadiologyRequestsByAppointmentId(
            widget.appointmentId,
          );
          final records = result.fold((l) => <dynamic>[], (r) => r);
          if (kDebugMode) {
            debugPrint(
              '   ✅ [Record List] Loaded ${records.length} radiology request(s)',
            );
          }
          return records;
        case 'device':
          final repository = GetIt.I<DeviceRequestRepository>();
          final result = await repository.getDeviceRequestsByAppointmentId(
            widget.appointmentId,
          );
          final records = result.fold((l) => <dynamic>[], (r) => r);
          if (kDebugMode) {
            debugPrint(
              '   ✅ [Record List] Loaded ${records.length} device request(s)',
            );
          }
          return records;
        case 'emr':
          final result = await GetIt.I<EMRRepository>().getEMRByAppointmentId(
            widget.appointmentId,
          );
          final records = result.fold(
            (l) => <dynamic>[],
            (r) => r != null ? <dynamic>[r] : <dynamic>[],
          );
          if (kDebugMode) {
            debugPrint(
              '   ✅ [Record List] Loaded ${records.length} andrology EMR record(s)',
            );
          }
          return records;
        case 'internal_medicine_emr':
          final result = await GetIt.I<InternalMedicineEMRRepository>()
              .getEMRByAppointmentId(
                widget.appointmentId,
              );
          final records = result.fold(
            (l) => <dynamic>[],
            (r) => r != null ? <dynamic>[r] : <dynamic>[],
          );
          if (kDebugMode) {
            debugPrint(
              '   ✅ [Record List] Loaded ${records.length} internal medicine EMR record(s)',
            );
          }
          return records;
        case 'nutrition_emr':
          final result = await GetIt.I<NutritionEMRRepository>()
              .getEMRByAppointmentId(widget.appointmentId);
          final records = result.fold(
            (l) => <dynamic>[],
            (r) => r != null ? <dynamic>[r] : <dynamic>[],
          );
          if (kDebugMode) {
            debugPrint(
              '   ✅ [Record List] Loaded ${records.length} nutrition EMR record(s)',
            );
          }
          return records;
        case 'physiotherapy_emr':
          final result = await GetIt.I<PhysiotherapyEMRRepository>()
              .getPhysiotherapyEMRByVisit(widget.appointmentId);
          final records = result.fold(
            (l) => <dynamic>[],
            (r) => r != null ? <dynamic>[r] : <dynamic>[],
          );
          if (kDebugMode) {
            debugPrint(
              '   ✅ [Record List] Loaded ${records.length} physiotherapy EMR record(s)',
            );
          }
          return records;
        default:
          if (kDebugMode) {
            debugPrint('   ❌ [Record List] Unknown type: ${widget.type}');
          }
          return [];
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('   ❌ [Record List] Error loading records: $e');
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<dynamic>>(
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
        return const Center(child: Text('لا توجد سجلات'));
      }

      /// FIX: Add RepaintBoundary + unique keys to prevent rendering loops
      return ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          // Generate unique key based on item type and ID
          final itemKey = _generateItemKey(item, index);

          /// FIX: Wrap each card with RepaintBoundary to isolate rebuilds
          return RepaintBoundary(
            key: itemKey,
            child: _buildRecordCard(item),
          );
        },
      );
    },
  );

  /// Generate unique key for list items to prevent rebuild loops
  Key _generateItemKey(dynamic item, int index) {
    if (item is EMRModel) {
      return ValueKey('emr_${item.id}');
    } else if (item is InternalMedicineEMRModel) {
      return ValueKey('internal_emr_${item.id}');
    } else if (item is PhysiotherapyEMR) {
      return ValueKey('physio_emr_${item.id}');
    } else if (item is NutritionEMREntity) {
      return ValueKey('nutrition_emr_${item.id}');
    } else if (item is PrescriptionModel) {
      return ValueKey('prescription_${item.id}');
    } else if (item is LabRequestModel) {
      return ValueKey('lab_${item.id}');
    } else if (item is RadiologyRequestModel) {
      return ValueKey('radiology_${item.id}');
    } else if (item is DeviceRequestModel) {
      return ValueKey('device_${item.id}');
    }
    return ValueKey('item_$index');
  }

  /// Build individual record card based on type
  /// FIX: Extracted to separate method to improve clarity and prevent inline rebuilds
  Widget _buildRecordCard(dynamic item) {
    // Render item based on type
    if (item is EMRModel) {
      return Card(
        child: ListTile(
          title: const Text('Andrology EMR Record'),
          subtitle: Text('Diagnosis: ${item.impressionDiagnosis}'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () async {
            await Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (context) => EMRDetailsScreen(emr: item),
              ),
            );
          },
        ),
      );
    }
    if (item is InternalMedicineEMRModel) {
      return Card(
        child: ListTile(
          title: const Text('Internal Medicine EMR Record'),
          subtitle: Text(
            'ICD-10: ${item.icd10Codes.isNotEmpty ? item.icd10Codes.join(", ") : "None"}',
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () async {
            await Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (context) =>
                    InternalMedicineEMRDetailsScreen(emr: item),
              ),
            );
          },
        ),
      );
    }
    if (item is PhysiotherapyEMR) {
      return Card(
        child: ListTile(
          title: const Text('Physiotherapy EMR Record'),
          subtitle: Text(
            'Primary Diagnosis: ${item.primaryDiagnosis ?? "None"}',
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () async {
            await Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (context) => AddEMRScreen(
                  patientId: widget.patientId,
                  patientName: widget.patientName,
                  appointmentId: widget.appointmentId,
                ),
              ),
            );
          },
        ),
      );
    }

    /// Enhanced Nutrition EMR Card with improved visual design
    if (item is NutritionEMREntity) {
      // Calculate values ONCE before building the widget to prevent rebuild loops
      final completionPercentage = item.completionPercentage.toStringAsFixed(0);
      final lastUpdatedDate = item.updatedAt.toString().split(' ')[0];
      final completionValue = item.completionPercentage / 100.0;

      return RepaintBoundary(
        child: Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () async {
              await Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => NutritionClinicScreen(
                    patientId: widget.patientId,
                    appointmentId: widget.appointmentId,
                  ),
                ),
              );

              // Refresh list after returning from nutrition screen
              if (mounted) {
                _loadRecords();
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Title & Badge
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Nutrition EMR Record',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Last Updated: $lastUpdatedDate',
                              style: const TextStyle(
                                fontSize: 12,
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
                  const SizedBox(height: 14),
                  // Completion Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Completion Status',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          Text(
                            '$completionPercentage%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: completionValue,
                          minHeight: 6,
                          backgroundColor: AppColors.borderLight,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            completionValue == 1.0
                                ? Colors.green
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Fallback for other items
    if (item is PrescriptionModel) {
      return PrescriptionCard(prescription: item);
    }
    if (item is LabRequestModel) {
      return MedicalRequestCard(
        title: 'طلب تحليل',
        icon: Icons.biotech_outlined,
        color: AppColors.primary,
        items: item.testNames,
        notes: item.notes,
        doctorName: item.doctorName,
        date: item.createdAt,
      );
    }
    if (item is RadiologyRequestModel) {
      return MedicalRequestCard(
        title: 'طلب أشعة',
        icon: Icons.rate_review_outlined,
        color: AppColors.secondary,
        items: item.scanTypes,
        notes: item.notes,
        doctorName: item.doctorName,
        date: item.createdAt,
      );
    }
    if (item is DeviceRequestModel) {
      return MedicalRequestCard(
        title: 'طلب جهاز',
        icon: Icons.devices_other,
        color: Colors.indigo,
        items: item.deviceNames,
        notes: item.notes,
        doctorName: item.doctorName,
        date: item.createdAt,
      );
    }

    return const SizedBox.shrink();
  }
}
