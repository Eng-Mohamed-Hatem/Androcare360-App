import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/constants/app_strings.dart';
import 'package:elajtech/core/utils/validators.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/shared/widgets/custom_button.dart';
import 'package:elajtech/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Edit Doctor Profile Screen — Doctor Self-Edit
///
/// **Scope (Doctor):** Only allows editing `fullName` and `phoneNumber`.
/// All other profile fields (biography, experience, fee, photo, education,
/// certificates, working hours, consultation types, clinic) are admin-only
/// and can only be changed from the Admin panel.
///
/// **Note:** This screen is kept for forward compatibility but its scope
/// is intentionally minimal to enforce the admin-only rule.
class EditDoctorProfileScreen extends ConsumerStatefulWidget {
  const EditDoctorProfileScreen({super.key});

  @override
  ConsumerState<EditDoctorProfileScreen> createState() =>
      _EditDoctorProfileScreenState();
}

class _EditDoctorProfileScreenState
    extends ConsumerState<EditDoctorProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  /// Only editable by the doctor themselves.
  late TextEditingController _fullNameController;

  /// Only editable by the doctor themselves.
  late TextEditingController _phoneController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _fullNameController = TextEditingController(text: user?.fullName);
    _phoneController = TextEditingController(text: user?.phoneNumber);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Saves only the doctor-editable fields: fullName and phoneNumber.
  ///
  /// All other fields (biography, experience, fee, photo, education,
  /// certificates, consultationTypes, clinicAddress) are admin-managed
  /// and MUST NOT be written from this method.
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(authProvider).user;
      if (currentUser == null) return;

      // ✅ Only update doctor-editable fields — no admin-only fields touched.
      final updatedUser = currentUser.copyWith(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      await ref.read(authProvider.notifier).updateUserData(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث الملف الشخصي بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('تعديل المعلومات الشخصية')),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info banner — read-only fields.
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'بيانات الملف الشخصي الأخرى (الصورة، الخبرة، الشهادات...) يتم إدارتها من قِبَل الإدارة فقط.',
                      style: TextStyle(fontSize: 12, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Full Name
            CustomTextField(
              label: AppStrings.fullName,
              controller: _fullNameController,
              prefixIcon: Icons.person_outline,
              validator: (value) =>
                  Validators.required(value, fieldName: 'الاسم'),
            ),
            const SizedBox(height: 16),

            // Phone Number
            CustomTextField(
              label: AppStrings.phoneNumber,
              controller: _phoneController,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: Validators.phoneNumber,
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 32),

            // Save Button
            CustomButton(
              text: AppStrings.save,
              onPressed: _saveProfile,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    ),
  );
}
