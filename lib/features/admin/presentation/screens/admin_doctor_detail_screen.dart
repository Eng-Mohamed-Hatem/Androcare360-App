import 'dart:io';

import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/constants/app_constants.dart';
import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/core/services/storage_service.dart';
import 'package:elajtech/features/admin/presentation/providers/admin_provider.dart';
import 'package:elajtech/features/admin/presentation/widgets/admin_account_status_chip.dart';
import 'package:elajtech/features/doctor/profile/presentation/widgets/working_hours_selector.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Admin screen to view and manage an individual doctor's profile.
///
/// Supports both **create** mode (when [doctor] is null) and **edit** mode.
///
/// Admin-managed fields (read-only for doctors):
/// - Profile photo, License number, Specializations, Biography,
///   Years of experience, Working hours, Consultation fee,
///   Consultation types, Clinic name, Clinic address,
///   Education, Certificates.
class AdminDoctorDetailScreen extends ConsumerStatefulWidget {
  const AdminDoctorDetailScreen({required this.doctor, super.key});

  /// Pass null to create a new doctor; pass a [UserModel] to edit one.
  final UserModel? doctor;

  @override
  ConsumerState<AdminDoctorDetailScreen> createState() =>
      _AdminDoctorDetailScreenState();
}

class _AdminDoctorDetailScreenState
    extends ConsumerState<AdminDoctorDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── Basic info controllers
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _phoneController;

  // ── Admin-only field controllers
  late final TextEditingController _licenseController;
  late final TextEditingController _biographyController;
  late final TextEditingController _consultationFeeController;
  late final TextEditingController _clinicAddressController;
  late final TextEditingController _experienceController;

  // ── Dropdown selections (replaces free-text for these two fields)
  String? _selectedSpecialization;
  String? _selectedClinicName;

  // ── Photo state
  File? _selectedPhoto;
  String? _currentPhotoUrl;
  bool _isUploadingPhoto = false;
  final StorageService _storageService = getIt<StorageService>();

  // ── Complex fields
  List<String> _selectedConsultationTypes = [];
  List<Map<String, String>> _educationList = [];
  List<Map<String, String>> _certificatesList = [];
  Map<String, List<String>> _workingHours = {};

  bool get _isCreateMode => widget.doctor == null;

  @override
  void initState() {
    super.initState();
    final d = widget.doctor;
    _nameController = TextEditingController(text: d?.fullName ?? '');
    _emailController = TextEditingController(text: d?.email ?? '');
    _passwordController = TextEditingController();
    _phoneController = TextEditingController(text: d?.phoneNumber ?? '');
    _licenseController = TextEditingController(text: d?.licenseNumber ?? '');
    _biographyController = TextEditingController(text: d?.biography ?? '');
    _consultationFeeController = TextEditingController(
      text: d?.consultationFee?.toString() ?? '',
    );
    _clinicAddressController = TextEditingController(
      text: d?.clinicAddress ?? '',
    );
    _experienceController = TextEditingController(
      text: d?.yearsOfExperience?.toString() ?? '',
    );

    // Initialize dropdowns — only keep the value if it's in the allowed list
    // so existing documents with legacy free-text values degrade gracefully
    // (the field will be left blank and the admin must re-select).
    final existingSpec = d?.specializations?.isNotEmpty ?? false
        ? d!.specializations!.first
        : null;
    _selectedSpecialization =
        (existingSpec != null &&
            MedicalSpecializations.values.contains(existingSpec))
        ? existingSpec
        : null;

    final existingClinic = d?.clinicName;
    _selectedClinicName =
        (existingClinic != null &&
            MedicalSpecializations.values.contains(existingClinic))
        ? existingClinic
        : null;

    _currentPhotoUrl = d?.profileImage;
    _selectedConsultationTypes = d?.consultationTypes ?? [];
    _workingHours = d?.workingHours != null
        ? Map<String, List<String>>.from(d!.workingHours!)
        : {};
    _educationList = d?.education != null
        ? List<Map<String, String>>.from(d!.education!)
        : [];
    _certificatesList = d?.certificates != null
        ? List<Map<String, String>>.from(d!.certificates!)
        : [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _biographyController.dispose();
    _consultationFeeController.dispose();
    _clinicAddressController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  // ─────────────────────────── Photo picker ──────────────────────────────

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    final file = File(picked.path);
    final sizeMb = await file.length() / (1024 * 1024);
    if (sizeMb > 5) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حجم الصورة يجب أن لا يتجاوز 5 ميجابايت'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    setState(() => _selectedPhoto = file);
  }

  // ─────────────────────────── Dialogs ───────────────────────────────────

  Future<void> _showWorkingHoursDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 600, maxWidth: 420),
          child: WorkingHoursSelector(
            initialWorkingHours: _workingHours,
            onSave: (hours) {
              setState(() => _workingHours = hours);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showAddEducationDialog() async {
    final degreeC = TextEditingController();
    final universityC = TextEditingController();
    final yearC = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة مؤهل علمي'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DialogField(label: 'الدرجة العلمية', controller: degreeC),
                const SizedBox(height: 12),
                _DialogField(
                  label: 'الجامعة / المعهد',
                  controller: universityC,
                ),
                const SizedBox(height: 12),
                _DialogField(
                  label: 'سنة التخرج',
                  controller: yearC,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
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
          TextButton(
            onPressed: () {
              if (degreeC.text.isNotEmpty && universityC.text.isNotEmpty) {
                setState(() {
                  _educationList.add({
                    'degree': degreeC.text.trim(),
                    'university': universityC.text.trim(),
                    'year': yearC.text.trim(),
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddCertificateDialog() async {
    final nameC = TextEditingController();
    final orgC = TextEditingController();
    final dateC = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة شهادة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogField(label: 'اسم الشهادة', controller: nameC),
              const SizedBox(height: 12),
              _DialogField(label: 'الجهة المانحة', controller: orgC),
              const SizedBox(height: 12),
              _DialogField(
                label: 'تاريخ الإصدار',
                controller: dateC,
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              if (nameC.text.isNotEmpty && orgC.text.isNotEmpty) {
                setState(() {
                  _certificatesList.add({
                    'name': nameC.text.trim(),
                    'organization': orgC.text.trim(),
                    'date': dateC.text.trim(),
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── Account toggle ────────────────────────────

  Future<void> _toggleStatus(bool currentStatus) async {
    final action = currentStatus ? 'تعطيل' : 'تفعيل';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$action الحساب'),
        content: Text(
          'هل تريد $action حساب الطبيب "${widget.doctor!.fullName}"؟\n'
          'سيؤدي التعطيل إلى منع الطبيب من تسجيل الدخول.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: currentStatus ? Colors.red : AppColors.primary,
            ),
            child: Text(action),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref
        .read(adminProvider.notifier)
        .setAccountStatus(
          targetUserId: widget.doctor!.id,
          isActive: !currentStatus,
        );
    if (mounted) Navigator.pop(context);
  }

  // ─────────────────────────── Submit ────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    // Upload photo if a new one was picked
    var photoUrl = _currentPhotoUrl;
    if (_selectedPhoto != null) {
      setState(() => _isUploadingPhoto = true);
      try {
        // Use a provisional ID for create mode (will be replaced by CF)
        final uploadId =
            widget.doctor?.id ??
            'temp_${DateTime.now().millisecondsSinceEpoch}';
        photoUrl = await _storageService.uploadProfileImage(
          _selectedPhoto!,
          uploadId,
        );
      } on Exception catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل رفع الصورة: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isUploadingPhoto = false);
        return;
      } finally {
        if (mounted) setState(() => _isUploadingPhoto = false);
      }
    }

    final updatedDoctor = UserModel(
      id: widget.doctor?.id ?? '',
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      userType: UserType.doctor,
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      licenseNumber: _licenseController.text.trim().isEmpty
          ? null
          : _licenseController.text.trim(),
      // Specialization is now always a single value from the dropdown
      specializations: _selectedSpecialization != null
          ? [_selectedSpecialization!]
          : null,
      biography: _biographyController.text.trim().isEmpty
          ? null
          : _biographyController.text.trim(),
      consultationFee: double.tryParse(_consultationFeeController.text),
      consultationTypes: _selectedConsultationTypes.isEmpty
          ? null
          : _selectedConsultationTypes,
      clinicName: _selectedClinicName,
      clinicAddress: _clinicAddressController.text.trim().isEmpty
          ? null
          : _clinicAddressController.text.trim(),
      yearsOfExperience: int.tryParse(_experienceController.text),
      workingHours: _workingHours.isEmpty ? null : _workingHours,
      education: _educationList.isEmpty ? null : _educationList,
      certificates: _certificatesList.isEmpty ? null : _certificatesList,
      profileImage: photoUrl,
      isActive: widget.doctor?.isActive ?? true,
      createdAt: widget.doctor?.createdAt ?? DateTime.now(),
    );

    if (_isCreateMode) {
      await ref
          .read(adminProvider.notifier)
          .createDoctor(
            doctor: updatedDoctor,
            password: _passwordController.text,
          );
    } else {
      await ref
          .read(adminProvider.notifier)
          .updateDoctorProfile(
            updatedDoctor: updatedDoctor,
            previousDoctor: widget.doctor!,
          );
    }

    final state = ref.read(adminProvider);
    if (mounted && state.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isCreateMode
                ? 'تم إنشاء حساب الطبيب بنجاح'
                : 'تم تحديث الملف الشخصي',
          ),
          backgroundColor: Colors.green,
        ),
      );
      if (mounted) Navigator.pop(context);
    }
  }

  // ─────────────────────────── Build ─────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);
    final isLoading = state.isActionLoading || _isUploadingPhoto;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: Text(_isCreateMode ? 'إضافة طبيب جديد' : 'ملف الطبيب'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Account status toggle (edit mode)
              if (!_isCreateMode) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AdminAccountStatusChip(isActive: widget.doctor!.isActive),
                    TextButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => _toggleStatus(widget.doctor!.isActive),
                      icon: Icon(
                        widget.doctor!.isActive
                            ? Icons.block_outlined
                            : Icons.check_circle_outline,
                        color: widget.doctor!.isActive
                            ? Colors.red
                            : Colors.green,
                      ),
                      label: Text(
                        widget.doctor!.isActive
                            ? 'تعطيل الحساب'
                            : 'تفعيل الحساب',
                        style: TextStyle(
                          color: widget.doctor!.isActive
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
              ],

              // ── Profile photo
              const _SectionHeader(label: 'الصورة الشخصية'),
              const SizedBox(height: 12),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _selectedPhoto != null
                          ? FileImage(_selectedPhoto!) as ImageProvider
                          : _currentPhotoUrl != null
                          ? NetworkImage(_currentPhotoUrl!)
                          : null,
                      child:
                          (_selectedPhoto == null && _currentPhotoUrl == null)
                          ? const Icon(
                              Icons.person,
                              size: 56,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: isLoading ? null : _pickPhoto,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isUploadingPhoto) ...[
                const SizedBox(height: 8),
                const Center(child: LinearProgressIndicator()),
              ],
              const SizedBox(height: 24),

              // ── Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Basic info
                    const _SectionHeader(label: 'المعلومات الأساسية'),
                    const SizedBox(height: 12),
                    _FormField(
                      controller: _nameController,
                      label: 'الاسم الكامل',
                      icon: Icons.person_outline,
                      required: true,
                      fieldKey: const ValueKey('fullNameField'),
                    ),
                    const SizedBox(height: 12),
                    _FormField(
                      controller: _emailController,
                      label: 'البريد الإلكتروني',
                      icon: Icons.email_outlined,
                      required: true,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      fieldKey: const ValueKey('emailField'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'هذا الحقل مطلوب';
                        }
                        final emailRegex = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        );
                        if (!emailRegex.hasMatch(value)) {
                          return 'يرجى إدخال بريد إلكتروني صحيح';
                        }
                        return null;
                      },
                    ),
                    if (_isCreateMode) ...[
                      const SizedBox(height: 12),
                      _FormField(
                        controller: _passwordController,
                        label: 'كلمة المرور الأولية',
                        icon: Icons.lock_outlined,
                        obscureText: true,
                        textDirection: TextDirection.ltr,
                        required: _isCreateMode,
                        fieldKey: const ValueKey('passwordField'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'هذا الحقل مطلوب';
                          }
                          if (value.length < 6) {
                            return 'يجب أن تكون 6 أحرف على الأقل';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 12),
                    _FormField(
                      controller: _phoneController,
                      label: 'رقم الهاتف',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(height: 24),

                    // ── Medical credentials
                    const _SectionHeader(
                      label: 'البيانات المهنية (للأدمن فقط)',
                    ),
                    const SizedBox(height: 12),
                    _FormField(
                      controller: _licenseController,
                      label: 'رقم الرخصة الطبية',
                      icon: Icons.badge_outlined,
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(height: 12),
                    // ── Specialization dropdown ────────────────────────────
                    _DropdownField(
                      label: 'التخصص',
                      icon: Icons.medical_services_outlined,
                      items: MedicalSpecializations.values,
                      value: _selectedSpecialization,
                      required: true,
                      onChanged: (v) =>
                          setState(() => _selectedSpecialization = v),
                    ),
                    const SizedBox(height: 12),
                    _FormField(
                      controller: _experienceController,
                      label: 'سنوات الخبرة',
                      icon: Icons.timeline,
                      keyboardType: TextInputType.number,
                      textDirection: TextDirection.ltr,
                      validator: (v) {
                        if (v == null || v.isEmpty) return null;
                        if (int.tryParse(v) == null) return 'أدخل رقماً صحيحاً';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _FormField(
                      controller: _consultationFeeController,
                      label: 'سعر الكشف (ريال)',
                      icon: Icons.attach_money_outlined,
                      keyboardType: TextInputType.number,
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(height: 12),
                    // ── Clinic name dropdown ───────────────────────────────
                    _DropdownField(
                      label: 'اسم العيادة',
                      icon: Icons.local_hospital_outlined,
                      items: MedicalSpecializations.values,
                      value: _selectedClinicName,
                      required: true,
                      onChanged: (v) => setState(() => _selectedClinicName = v),
                    ),
                    const SizedBox(height: 12),
                    _FormField(
                      controller: _clinicAddressController,
                      label: 'عنوان العيادة',
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _biographyController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'نبذة عن الطبيب',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.description_outlined),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Consultation types
                    const _SectionHeader(label: 'أنواع الاستشارات'),
                    const SizedBox(height: 8),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Column(
                        children: [
                          CheckboxListTile(
                            title: const Text('استشارة في العيادة'),
                            value: _selectedConsultationTypes.contains(
                              'clinic',
                            ),
                            onChanged: (v) {
                              setState(() {
                                if (v ?? false) {
                                  _selectedConsultationTypes.add('clinic');
                                } else {
                                  _selectedConsultationTypes.remove('clinic');
                                }
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                          CheckboxListTile(
                            title: const Text('استشارة فيديو (أونلاين)'),
                            value: _selectedConsultationTypes.contains('video'),
                            onChanged: (v) {
                              setState(() {
                                if (v ?? false) {
                                  _selectedConsultationTypes.add('video');
                                } else {
                                  _selectedConsultationTypes.remove('video');
                                }
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Working hours
                    const _SectionHeader(label: 'أوقات العمل'),
                    const SizedBox(height: 8),
                    if (_workingHours.isEmpty)
                      const Text(
                        'لم يتم تحديد أوقات عمل بعد',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _workingHours.entries
                            .map(
                              (e) => Chip(
                                label: Text(
                                  '${e.key}: ${e.value.isNotEmpty ? "${e.value.first} – ${e.value.last}" : ""}',
                                ),
                                backgroundColor: AppColors.primary.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _showWorkingHoursDialog,
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        _workingHours.isEmpty
                            ? 'تحديد أوقات العمل'
                            : 'تعديل أوقات العمل',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Education
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _SectionHeader(label: 'المؤهلات العلمية'),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: AppColors.primary,
                          ),
                          onPressed: _showAddEducationDialog,
                        ),
                      ],
                    ),
                    if (_educationList.isEmpty)
                      const Text(
                        'لا يوجد مؤهلات مضافة',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ..._educationList.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final edu = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(
                            Icons.school,
                            color: AppColors.primary,
                          ),
                          title: Text(edu['degree'] ?? ''),
                          subtitle: Text(
                            '${edu['university'] ?? ''} – ${edu['year'] ?? ''}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                setState(() => _educationList.removeAt(idx)),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),

                    // ── Certificates
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _SectionHeader(label: 'الشهادات المهنية'),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: AppColors.primary,
                          ),
                          onPressed: _showAddCertificateDialog,
                        ),
                      ],
                    ),
                    if (_certificatesList.isEmpty)
                      const Text(
                        'لا يوجد شهادات مضافة',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ..._certificatesList.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final cert = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(
                            Icons.card_membership,
                            color: AppColors.primary,
                          ),
                          title: Text(cert['name'] ?? ''),
                          subtitle: Text(
                            '${cert['organization'] ?? ''} – ${cert['date'] ?? ''}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                setState(() => _certificatesList.removeAt(idx)),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 32),

                    // ── Error message
                    if (state.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          state.error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // ── Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : Text(
                                _isCreateMode
                                    ? 'إنشاء الحساب'
                                    : 'حفظ التغييرات',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── Helper Widgets ───────────────────────────────

/// Section header with a primary-colored title bar style.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: Theme.of(context).textTheme.titleSmall?.copyWith(
      color: AppColors.primary,
      fontWeight: FontWeight.bold,
    ),
  );
}

/// Reusable dialog text field widget.
class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.textDirection,
  });
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    textDirection: textDirection,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}

/// Reusable form field widget for the admin detail screens.
class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.required = false,
    this.obscureText = false,
    this.keyboardType,
    this.textDirection,
    this.validator,
    this.fieldKey,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool required;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;
  final FormFieldValidator<String>? validator;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) => TextFormField(
    key: fieldKey,
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    textDirection: textDirection,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    validator:
        validator ??
        (required
            ? (v) => (v == null || v.isEmpty) ? 'هذا الحقل مطلوب' : null
            : null),
  );
}

/// Styled dropdown form field that matches the look of [_FormField].
///
/// Used for fields that must be constrained to a predefined list of options
/// (e.g. specialization and clinic name in the admin doctor form).
class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.icon,
    required this.items,
    required this.value,
    required this.onChanged,
    this.required = false,
  });

  final String label;
  final IconData icon;

  /// The fixed list of options to show in the dropdown.
  final List<String> items;

  /// Currently selected value (null means nothing is selected yet).
  final String? value;

  /// Called when the user picks a different option.
  final ValueChanged<String?> onChanged;

  /// If true, shows a validation error when no value is selected.
  final bool required;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items
          .map(
            (option) => DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: required
          ? (v) => (v == null || v.isEmpty) ? 'هذا الحقل مطلوب' : null
          : null,
    );
  }
}
