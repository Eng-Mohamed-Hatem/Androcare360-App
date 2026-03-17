import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/constants/app_strings.dart';
import 'package:elajtech/core/utils/validators.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/shared/constants/clinic_types.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:elajtech/shared/widgets/custom_button.dart';
import 'package:elajtech/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Doctor Register Screen - شاشة تسجيل الطبيب الجديد
class DoctorRegisterScreen extends ConsumerStatefulWidget {
  const DoctorRegisterScreen({super.key});

  @override
  ConsumerState<DoctorRegisterScreen> createState() =>
      _DoctorRegisterScreenState();
}

class _DoctorRegisterScreenState extends ConsumerState<DoctorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _usernameController = TextEditingController();
  final _clinicAddressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Selections
  String? _selectedClinicType;
  final List<String> _selectedConsultationTypes = [];

  bool _agreedToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _licenseNumberController.dispose();
    _clinicAddressController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.mustAgreeToTerms),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedClinicType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار نوع العيادة'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedConsultationTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار نوع استشارة واحد على الأقل'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Register and login with the provided data as doctor
        await ref
            .read(authProvider.notifier)
            .loginWithEmail(
              _emailController.text.trim(),
              _passwordController.text,
              fullName: _fullNameController.text.trim(),
              phoneNumber: _phoneController.text.trim(),
              username: _usernameController.text.trim(),
              userType: UserType.doctor,
              licenseNumber: _licenseNumberController.text.trim(),
              specializations: <String>[
                ClinicTypes.arabicLabel(_selectedClinicType!),
              ],
              clinicType: _selectedClinicType,
              clinicAddress: _clinicAddressController.text.trim(),
              consultationTypes: _selectedConsultationTypes,
              isRegistration: true,
            );

        if (mounted) {
          final authState = ref.read(authProvider);

          // Check if registration failed due to duplicate data
          if (authState.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authState.error!),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }

          if (authState.user?.userType == UserType.doctor) {
            await ref.read(authProvider.notifier).logout();
            if (!mounted) {
              return;
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تم إرسال طلب التسجيل بنجاح. سيتم تفعيل الحساب بعد مراجعة الإدارة.',
              ),
              backgroundColor: AppColors.success,
            ),
          );

          Navigator.pop(context);
        }
      } on Exception {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل التسجيل. يرجى المحاولة مرة أخرى.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _showTermsDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.termsAndConditions),
        content: const SingleChildScrollView(
          child: Text(
            'هنا يتم عرض الشروط والأحكام الخاصة بالأطباء...\n\n'
            '1. يجب على الطبيب تقديم معلومات صحيحة\n'
            '2. يجب أن يكون لديه ترخيص طبي ساري\n'
            '3. يلتزم الطبيب بالمعايير الطبية والأخلاقية\n'
            '4. يحق للتطبيق تعديل الشروط في أي وقت\n\n'
            'وغيرها من الشروط والأحكام...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text(AppStrings.doctorRegister)),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'إنشاء حساب طبيب جديد',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                'املأ البيانات التالية للتسجيل كطبيب',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Full Name
              CustomTextField(
                label: AppStrings.fullName,
                hint: 'أدخل اسمك الكامل',
                controller: _fullNameController,
                prefixIcon: Icons.person_outline,
                validator: (value) =>
                    Validators.required(value, fieldName: 'الاسم الكامل'),
              ),
              const SizedBox(height: 16),

              // Phone Number
              CustomTextField(
                label: AppStrings.phoneNumber,
                hint: '+9665XXXXXXXX',
                helperText: 'اكتب رقم الموبايل بصيغة دولية مثل +9665XXXXXXXX',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: Validators.phoneNumber,
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: 16),

              // Email
              CustomTextField(
                label: AppStrings.email,
                hint: 'doctor@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: Validators.email,
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: 16),

              // License Number
              CustomTextField(
                label: AppStrings.licenseNumber,
                hint: 'أدخل رقم الترخيص الطبي',
                controller: _licenseNumberController,
                prefixIcon: Icons.badge_outlined,
                validator: (value) =>
                    Validators.required(value, fieldName: 'رقم الترخيص'),
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: 24),

              // --- Medical Information ---
              const Text(
                'المعلومات المهنية',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // 1. Clinic Type
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'نوع العيادة',
                  prefixIcon: Icon(Icons.local_hospital_outlined),
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedClinicType,
                items: ClinicTypes.values
                    .map(
                      (clinicType) => DropdownMenuItem(
                        value: clinicType,
                        child: Text(ClinicTypes.arabicLabel(clinicType)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClinicType = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'يرجى اختيار نوع العيادة' : null,
              ),
              const SizedBox(height: 16),

              // 2. Consultation Types
              const Text(
                'أنواع الاستشارات المتاحة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('استشارة في العيادة'),
                value: _selectedConsultationTypes.contains('clinic'),
                onChanged: (val) {
                  setState(() {
                    if (val ?? false) {
                      _selectedConsultationTypes.add('clinic');
                    } else {
                      _selectedConsultationTypes.remove('clinic');
                    }
                  });
                },
                secondary: const Icon(
                  Icons.apartment,
                  color: AppColors.primary,
                ),
              ),
              CheckboxListTile(
                title: const Text('استشارة فيديو (أونلاين)'),
                value: _selectedConsultationTypes.contains('video'),
                onChanged: (val) {
                  setState(() {
                    if (val ?? false) {
                      _selectedConsultationTypes.add('video');
                    } else {
                      _selectedConsultationTypes.remove('video');
                    }
                  });
                },
                secondary: const Icon(
                  Icons.videocam,
                  color: AppColors.secondary,
                ),
              ),

              // 3. Clinic Address (Only if clinic consultation is selected, or always)
              // User said "Write clinic address", let's show it always or if clinic type is selected.
              // Best to show it if 'clinic' is selected or just always for profile completeness.
              if (_selectedConsultationTypes.contains('clinic')) ...[
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'عنوان العيادة',
                  hint: 'المدينة، الحي، اسم المبنى...',
                  controller: _clinicAddressController,
                  prefixIcon: Icons.location_on_outlined,
                  validator: (value) =>
                      Validators.required(value, fieldName: 'عنوان العيادة'),
                ),
              ],

              const SizedBox(height: 32),

              // Username
              CustomTextField(
                label: AppStrings.username,
                hint: 'اختر اسم مستخدم',
                controller: _usernameController,
                prefixIcon: Icons.alternate_email,
                validator: Validators.username,
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: 16),

              // Password
              CustomTextField(
                label: AppStrings.password,
                controller: _passwordController,
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                validator: Validators.password,
              ),
              const SizedBox(height: 16),

              // Confirm Password
              CustomTextField(
                label: AppStrings.confirmPassword,
                controller: _confirmPasswordController,
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                validator: (value) => Validators.confirmPassword(
                  value,
                  _passwordController.text,
                ),
              ),
              const SizedBox(height: 24),

              // Terms and Conditions Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreedToTerms = value ?? false;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _agreedToTerms = !_agreedToTerms;
                        });
                      },
                      child: Text(
                        AppStrings.agreeToTerms,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // View Terms Link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async => _showTermsDialog(),
                  child: const Text(AppStrings.viewTerms),
                ),
              ),
              const SizedBox(height: 24),

              // Register Button
              CustomButton(
                text: AppStrings.doctorRegister,
                onPressed: _handleRegister,
                isLoading: _isLoading,
                height: 52,
              ),
              const SizedBox(height: 24),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.alreadyHaveAccount,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      AppStrings.login,
                      style: TextStyle(fontWeight: FontWeight.bold),
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
