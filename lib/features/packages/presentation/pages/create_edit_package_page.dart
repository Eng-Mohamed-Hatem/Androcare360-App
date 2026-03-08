import 'package:elajtech/core/constants/app_colors.dart';

import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/package_service_item.dart';
import 'package:elajtech/features/packages/domain/usecases/create_clinic_package_usecase.dart';
import 'package:elajtech/features/packages/domain/usecases/update_clinic_package_usecase.dart';
import 'package:elajtech/features/packages/presentation/providers/admin_packages_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateEditPackagePage extends ConsumerStatefulWidget {
  const CreateEditPackagePage({super.key, this.packageToEdit});

  final PackageEntity? packageToEdit;

  @override
  ConsumerState<CreateEditPackagePage> createState() =>
      _CreateEditPackagePageState();
}

class _CreateEditPackagePageState extends ConsumerState<CreateEditPackagePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _shortDescController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _discountController;
  late TextEditingController _validityController;
  late TextEditingController _termsController;
  late TextEditingController _displayOrderController;

  PackageCategory _selectedCategory =
      PackageCategory.andrologyInfertilityProstate;
  PackageType _selectedType = PackageType.physicalOnly;
  PackageStatus _selectedStatus = PackageStatus.active;
  bool _isFeatured = false;

  List<PackageServiceItem> _services = [];

  bool get isEditMode => widget.packageToEdit != null;

  @override
  void initState() {
    super.initState();
    final p = widget.packageToEdit;
    _nameController = TextEditingController(text: p?.name ?? '');
    _shortDescController = TextEditingController(
      text: p?.shortDescription ?? '',
    );
    _descController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(
      text: p != null ? p.price.toString() : '',
    );
    _discountController = TextEditingController(
      text: p?.discountPercentage?.toString() ?? '',
    );
    _validityController = TextEditingController(
      text: p?.validityDays.toString() ?? '30',
    );
    _termsController = TextEditingController(text: p?.termsAndConditions ?? '');
    _displayOrderController = TextEditingController(
      text: p?.displayOrder.toString() ?? '',
    );

    if (p != null) {
      _selectedCategory = p.category;
      _selectedType = p.packageType;
      _selectedStatus = p.status;
      _isFeatured = p.isFeatured;
      _services = List.from(p.services);
    } else {
      // Default empty service
      _services.add(
        const PackageServiceItem(
          serviceId: '',
          serviceType: ServiceType.visit,
          displayName: '',
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortDescController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _validityController.dispose();
    _termsController.dispose();
    _displayOrderController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إضافة خدمة واحدة على الأقل')),
      );
      return;
    }
    for (final s in _services) {
      if (s.displayName.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الرجاء إدخال أسماء جميع الخدمات بشكل صحيح'),
          ),
        );
        return;
      }
    }

    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final discount = double.tryParse(_discountController.text.trim());
    final validity = int.tryParse(_validityController.text.trim()) ?? 30;
    final displayOrder = int.tryParse(_displayOrderController.text.trim());

    if (isEditMode) {
      // Optimistic concurrency logic
      final params = UpdatePackageParams(
        clinicId: widget.packageToEdit!.clinicId,
        packageId: widget.packageToEdit!.id,
        loadedAt: widget.packageToEdit!.updatedAt,
        category: _selectedCategory,
        name: _nameController.text.trim(),
        shortDescription: _shortDescController.text.trim(),
        description: _descController.text.trim(),
        services: _services,
        validityDays: validity,
        termsAndConditions: _termsController.text.trim(),
        price: price,
        currency: 'EGP',
        discountPercentage: discount,
        type: _selectedType,
        status: _selectedStatus,
        displayOrder: displayOrder ?? widget.packageToEdit!.displayOrder,
        isFeatured: _isFeatured,
      );
      ref.read(adminPackageWriteProvider.notifier).updatePackage(params).then((
        _,
      ) {
        if (mounted && !ref.read(adminPackageWriteProvider).hasError) {
          Navigator.pop(context);
        }
      });
    } else {
      final clinicId = ref.read(adminSelectedClinicProvider);
      if (clinicId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء اختيار عيادة أولاً')),
        );
        return;
      }
      final params = CreatePackageParams(
        clinicId: clinicId,
        category: _selectedCategory,
        name: _nameController.text.trim(),
        shortDescription: _shortDescController.text.trim(),
        description: _descController.text.trim(),
        services: _services,
        validityDays: validity,
        termsAndConditions: _termsController.text.trim(),
        price: price,
        currency: 'EGP',
        discountPercentage: discount,
        type: _selectedType,
        status: _selectedStatus,
        displayOrder: displayOrder,
        isFeatured: _isFeatured,
      );
      ref.read(adminPackageWriteProvider.notifier).createPackage(params).then((
        _,
      ) {
        if (mounted && !ref.read(adminPackageWriteProvider).hasError) {
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final writeState = ref.watch(adminPackageWriteProvider);
    final isLoading = writeState.isLoading;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditMode ? 'تعديل الباقة' : 'إضافة باقة جديدة'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Info
                      _buildSectionTitle('المعلومات الأساسية'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        _nameController,
                        'اسم الباقة',
                        required: true,
                        maxLength: 200,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        _shortDescController,
                        'وصف مختصر',
                        required: true,
                        maxLength: 500,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        _descController,
                        'وصف تفصيلي',
                        maxLines: 4,
                        maxLength: 3000,
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle('التصنيف والنوع'),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<PackageCategory>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'القسم',
                          border: OutlineInputBorder(),
                        ),
                        items: PackageCategory.values.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(c.value),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedCategory = val!),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<PackageType>(
                        initialValue: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'نوع الباقة',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: PackageType.physicalOnly,
                            child: Text('حضوري فقط'),
                          ),
                          DropdownMenuItem(
                            value: PackageType.videoOnly,
                            child: Text('فيديو فقط'),
                          ),
                          DropdownMenuItem(
                            value: PackageType.both,
                            child: Text('شامل (حضوري وفيديو)'),
                          ),
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedType = val!),
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle('الخدمات المشمولة'),
                      const SizedBox(height: 12),
                      _buildServicesList(),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            // simple fallback ID, since actual ID isn't shown to user normally
                            _services.add(
                              PackageServiceItem(
                                serviceId: DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                                serviceType: ServiceType.visit,
                                displayName: '',
                              ),
                            );
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة خدمة أخرى'),
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle('التسعير والصلاحية'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              _priceController,
                              'السعر (EGP)',
                              required: true,
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              _discountController,
                              'نسبة الخصم (%)',
                              isNumber: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              _validityController,
                              'الصلاحية (بالأيام)',
                              required: true,
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              _displayOrderController,
                              'ترتيب العرض',
                              isNumber: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        _termsController,
                        'الشروط والأحكام',
                        maxLines: 3,
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle('الحالة'),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<PackageStatus>(
                        initialValue: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'حالة الباقة',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: PackageStatus.active,
                            child: Text('نشط'),
                          ),
                          DropdownMenuItem(
                            value: PackageStatus.inactive,
                            child: Text('غير نشط'),
                          ),
                          DropdownMenuItem(
                            value: PackageStatus.hidden,
                            child: Text('مخفي'),
                          ),
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedStatus = val!),
                      ),
                      CheckboxListTile(
                        title: const Text('باقة مميزة للمرضى'),
                        value: _isFeatured,
                        onChanged: (val) =>
                            setState(() => _isFeatured = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),

                      const SizedBox(height: 48),
                      ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.primary,
                        ),
                        child: Text(
                          isEditMode ? 'حفظ التغييرات' : 'إنشاء الباقة',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool required = false,
    bool isNumber = false,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label + (required ? ' *' : ''),
        border: const OutlineInputBorder(),
      ),
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: isNumber
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
          : null,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return 'هذا الحقل مطلوب';
        }
        return null;
      },
    );
  }

  Widget _buildServicesList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _services.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _services[index];
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<ServiceType>(
                  initialValue: item.serviceType,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: ServiceType.visit,
                      child: Text('زيارة'),
                    ),
                    DropdownMenuItem(
                      value: ServiceType.lab,
                      child: Text('تحليل'),
                    ),
                    DropdownMenuItem(
                      value: ServiceType.imaging,
                      child: Text('أشعة'),
                    ),
                    DropdownMenuItem(
                      value: ServiceType.session,
                      child: Text('جلسة'),
                    ),
                    DropdownMenuItem(
                      value: ServiceType.other,
                      child: Text('أخرى'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _services[index] = PackageServiceItem(
                          serviceId: item.serviceId,
                          serviceType: val,
                          displayName: item.displayName,
                          quantity: item.quantity,
                        );
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: TextFormField(
                  initialValue: item.displayName,
                  decoration: const InputDecoration(
                    labelText: 'الاسم (عربي)',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    _services[index] = PackageServiceItem(
                      serviceId: item.serviceId,
                      serviceType: item.serviceType,
                      displayName: val,
                      quantity: item.quantity,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: item.quantity.toString(),
                  decoration: const InputDecoration(
                    labelText: 'الكمية',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (val) {
                    final q = int.tryParse(val) ?? 1;
                    _services[index] = PackageServiceItem(
                      serviceId: item.serviceId,
                      serviceType: item.serviceType,
                      displayName: item.displayName,
                      quantity: q > 0 ? q : 1,
                    );
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _services.removeAt(index);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
