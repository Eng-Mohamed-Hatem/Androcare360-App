import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/device_requests/domain/repositories/device_request_repository.dart';
import 'package:elajtech/features/lab_requests/domain/repositories/lab_request_repository.dart';
import 'package:elajtech/features/radiology_requests/domain/repositories/radiology_request_repository.dart';
import 'package:elajtech/shared/models/device_request_model.dart';
import 'package:elajtech/shared/models/lab_request_model.dart';
import 'package:elajtech/shared/models/radiology_request_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

enum MedicalRequestType { lab, radiology, device }

class AddMedicalRequestScreen extends ConsumerStatefulWidget {
  const AddMedicalRequestScreen({
    required this.requestType,
    required this.patientId,
    required this.patientName,
    required this.appointmentId,
    super.key,
  });
  final MedicalRequestType requestType;
  final String patientId;
  final String patientName;
  final String appointmentId;

  @override
  ConsumerState<AddMedicalRequestScreen> createState() =>
      _AddMedicalRequestScreenState();
}

class _AddMedicalRequestScreenState
    extends ConsumerState<AddMedicalRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemController = TextEditingController();
  final _notesController = TextEditingController();
  final List<String> _items = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _itemController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addItem() {
    if (_itemController.text.trim().isNotEmpty) {
      setState(() {
        _items.add(_itemController.text.trim());
        _itemController.clear();
      });
    }
  }

  String _getTitle() {
    switch (widget.requestType) {
      case MedicalRequestType.lab:
        return 'طلب تحليل طبي';
      case MedicalRequestType.radiology:
        return 'طلب أشعة';
      case MedicalRequestType.device:
        return 'طلب جهاز طبي';
    }
  }

  String _getItemLabel() {
    switch (widget.requestType) {
      case MedicalRequestType.lab:
        return 'اسم التحليل';
      case MedicalRequestType.radiology:
        return 'نوع الأشعة';
      case MedicalRequestType.device:
        return 'اسم الجهاز';
    }
  }

  Future<void> _saveRequest() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب إضافة عنصر واحد على الأقل')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final doctor = ref.read(authProvider).user!;

      // Fetch patient just like in prescription screen if needed,
      // but for these models we only store basics.

      final id = const Uuid().v4();
      final now = DateTime.now();
      final notes = _notesController.text.isEmpty
          ? null
          : _notesController.text;

      switch (widget.requestType) {
        case MedicalRequestType.lab:
          final request = LabRequestModel(
            id: id,
            appointmentId: widget.appointmentId,
            doctorId: doctor.id,
            doctorName: doctor.fullName,
            patientId: widget.patientId,
            patientName: widget.patientName,
            testNames: _items,
            notes: notes,
            createdAt: now,
          );
          final result = await GetIt.I<LabRequestRepository>().saveLabRequest(
            request,
          );
          result.fold(
            (l) => throw Exception(l.message),
            (r) => null, // Success
          );

        case MedicalRequestType.radiology:
          final request = RadiologyRequestModel(
            id: id,
            appointmentId: widget.appointmentId,
            doctorId: doctor.id,
            doctorName: doctor.fullName,
            patientId: widget.patientId,
            patientName: widget.patientName,
            scanTypes: _items,
            notes: notes,
            createdAt: now,
          );
          final result = await GetIt.I<RadiologyRequestRepository>()
              .saveRadiologyRequest(request);
          result.fold(
            (l) => throw Exception(l.message),
            (r) => null, // Success
          );

        case MedicalRequestType.device:
          final request = DeviceRequestModel(
            id: id,
            appointmentId: widget.appointmentId,
            doctorId: doctor.id,
            doctorName: doctor.fullName,
            patientId: widget.patientId,
            patientName: widget.patientName,
            deviceNames: _items,
            notes: notes,
            createdAt: now,
          );
          final result = await GetIt.I<DeviceRequestRepository>()
              .saveDeviceRequest(request);
          result.fold(
            (l) => throw Exception(l.message),
            (r) => null, // Success
          );
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم حفظ الطلب بنجاح')));
        Navigator.pop(context);
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
      }
      debugPrint('Error saving medical request: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_getTitle())),
    body: Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Patient Info Summary
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(widget.patientName),
                      subtitle: const Text('مريض'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Add Item Section
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _itemController,
                          decoration: InputDecoration(
                            labelText: _getItemLabel(),
                            border: const OutlineInputBorder(),
                          ),
                          onFieldSubmitted: (_) => _addItem(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'اضغط على + أو Enter للإضافة',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),

                  // Items List
                  if (_items.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('لم يتم إضافة ${_getItemLabel()} بعد'),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _items.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            title: Text(item),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  _items.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 24),

                  // Notes
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'ملاحظات',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveRequest,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('حفظ ${_getTitle()}'),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
