import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/prescriptions/domain/repositories/prescription_repository.dart';
import 'package:elajtech/features/user/domain/repositories/user_repository.dart';
import 'package:elajtech/shared/models/prescription_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

class AddPrescriptionScreen extends ConsumerStatefulWidget {
  const AddPrescriptionScreen({
    required this.patientId,
    required this.patientName,
    required this.appointmentId,
    super.key,
  });
  final String patientId;
  final String patientName;
  final String appointmentId;

  @override
  ConsumerState<AddPrescriptionScreen> createState() =>
      _AddPrescriptionScreenState();
}

class _AddPrescriptionScreenState extends ConsumerState<AddPrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();
  final List<Medicine> _medicines = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _diagnosisController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addMedicine() async {
    await showDialog<void>(
      context: context,
      builder: (context) => _AddMedicineDialog(
        onAdd: (medicine) {
          setState(() {
            _medicines.add(medicine);
          });
        },
      ),
    );
  }

  Future<void> _savePrescription() async {
    if (!_formKey.currentState!.validate()) return;
    if (_medicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب إضافة دواء واحد على الأقل')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final doctor = ref.read(authProvider).user!;

      // Need to fetch patient details to make it complete as per model
      // For now we trust passed params, but ideally we should fetch patient object if model requires more.
      // The updated PrescriptionModel requires patientAge, maritalStatus, phone.
      // We will perform a fetch of the Appointment or Patient to get these details,
      // OR we can make them nullable in model temporarily if we can't reliably get them here.
      // But we have appointmentId. We can fetch Appointment first?

      // Actually, let's fetch the full Patient object from UserRepository to be safe/accurate.
      // Actually, let's fetch the full Patient object from UserRepository to be safe/accurate.
      final userResult = await GetIt.I<UserRepository>().getUser(
        widget.patientId,
      );
      final patient = userResult.fold((l) => null, (r) => r);

      if (patient == null) throw Exception('Patient not found');

      final prescription = PrescriptionModel(
        id: const Uuid().v4(),
        appointmentId: widget.appointmentId,
        doctorId: doctor.id,
        doctorName: doctor.fullName,
        patientId: widget.patientId,
        patientName: patient.fullName,
        patientAge:
            30, // Placeholder: Age not in UserModel yet, maybe default or calc from DOB if exists
        patientMaritalStatus: 'Unspecified', // Placeholder
        patientPhone: patient.phoneNumber ?? '',
        diagnosis: _diagnosisController.text,
        medicines: _medicines,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        createdAt: DateTime.now(),
      );

      final result = await GetIt.I<PrescriptionRepository>().savePrescription(
        prescription,
      );

      result.fold(
        (failure) => throw Exception(failure.message),
        (_) => null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ الوصفة الطبية بنجاح')),
        );
        Navigator.pop(context);
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
      }
      debugPrint('Error saving prescription: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('إضافة وصفة طبية')),
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
                  const SizedBox(height: 16),

                  // Diagnosis
                  TextFormField(
                    controller: _diagnosisController,
                    decoration: const InputDecoration(
                      labelText: 'التشخيص الطبي',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.monitor_heart),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 24),

                  // Medicines Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الأدوية (${_medicines.length})',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async => _addMedicine(),
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة دواء'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Medicines List (Table-like)
                  if (_medicines.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('لم يتم إضافة أدوية بعد'),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _medicines.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final medicine = _medicines[index];
                        return Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      medicine.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _medicines.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    _buildBadge(
                                      _medicineTypeToString(medicine.type),
                                      Colors.blue,
                                    ),
                                    _buildBadge(
                                      medicine.frequency,
                                      Colors.green,
                                    ),
                                    _buildBadge(
                                      medicine.duration,
                                      Colors.orange,
                                    ),
                                  ],
                                ),
                                if (medicine.notes != null &&
                                    medicine.notes!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'ملاحظات: ${medicine.notes}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 24),

                  // General Notes
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'ملاحظات عامة',
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
                onPressed: _isLoading ? null : _savePrescription,
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
                    : const Text('حفظ الوصفة الطبية'),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildBadge(String text, MaterialColor color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Text(text, style: TextStyle(color: color, fontSize: 12)),
  );

  String _medicineTypeToString(MedicineType type) {
    switch (type) {
      case MedicineType.tablet:
        return 'أقراص';
      case MedicineType.syrup:
        return 'شراب';
      case MedicineType.injection:
        return 'حقن';
    }
  }
}

class _AddMedicineDialog extends StatefulWidget {
  const _AddMedicineDialog({required this.onAdd});
  final void Function(Medicine) onAdd;

  @override
  State<_AddMedicineDialog> createState() => _AddMedicineDialogState();
}

class _AddMedicineDialogState extends State<_AddMedicineDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController =
      TextEditingController(); // Specific notes for medicine
  MedicineType _type = MedicineType.tablet;
  String _duration = 'أسبوع';
  String _frequency = 'مرتين يومياً';

  final List<String> _durations = [
    'يوم واحد',
    '3 أيام',
    'أسبوع',
    'أسبوعين',
    'شهر',
    'شهرين',
  ];

  final List<String> _frequencies = [
    'مرة يومياً',
    'مرتين يومياً',
    '3 مرات يومياً',
    '4 مرات يومياً',
    'عند اللزوم',
  ];

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('إضافة دواء'),
    content: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'اسم الدواء'),
              validator: (val) => val?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MedicineType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'النوع'),
              items: MedicineType.values.map((t) {
                var label = '';
                switch (t) {
                  case MedicineType.tablet:
                    label = 'أقراص';
                  case MedicineType.syrup:
                    label = 'شراب';
                  case MedicineType.injection:
                    label = 'حقن';
                }
                return DropdownMenuItem(value: t, child: Text(label));
              }).toList(),
              onChanged: (val) => setState(() => _type = val!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _duration,
              decoration: const InputDecoration(labelText: 'المدة'),
              items: _durations
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (val) => setState(() => _duration = val!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _frequency,
              decoration: const InputDecoration(
                labelText: 'الجرعة / التكرار',
              ),
              items: _frequencies
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (val) => setState(() => _frequency = val!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات (اختياري)',
              ),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('إلغاء'),
      ),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            widget.onAdd(
              Medicine(
                name: _nameController.text,
                type: _type,
                duration: _duration,
                frequency: _frequency,
                notes: _notesController.text.isEmpty
                    ? null
                    : _notesController.text,
              ),
            );
            Navigator.pop(context);
          }
        },
        child: const Text('إضافة'),
      ),
    ],
  );
}
