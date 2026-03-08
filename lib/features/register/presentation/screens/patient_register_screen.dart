import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/constants/app_strings.dart';
import 'package:elajtech/core/utils/validators.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/register/presentation/screens/doctor_register_screen.dart';
import 'package:elajtech/features/register/presentation/screens/sign_up_otp_screen.dart';
import 'package:elajtech/shared/widgets/custom_button.dart';
import 'package:elajtech/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Patient Register Screen - شاشة تسجيل المريض الجديد
class PatientRegisterScreen extends ConsumerStatefulWidget {
  const PatientRegisterScreen({super.key});

  @override
  ConsumerState<PatientRegisterScreen> createState() =>
      _PatientRegisterScreenState();
}

class _PatientRegisterScreenState extends ConsumerState<PatientRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _agreedToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
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

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      // Step 1: Create email account + send OTP
      await ref
          .read(authProvider.notifier)
          .startSignUpWithEmailAndPhone(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _fullNameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            username: _usernameController.text.trim(),
          );

      if (!mounted) return;

      final authState = ref.read(authProvider);

      if (authState.signUpError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.signUpError!),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Step 2: Navigate to OTP screen (phone number already in provider state)
      if (authState.signUpVerificationId != null) {
        await Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const SignUpOtpScreen(),
          ),
        );
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

  Future<void> _showTermsDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.termsAndConditions),
        content: const SingleChildScrollView(
          child: Text(AppStrings.termsAndConditionsFullText),
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
    appBar: AppBar(title: const Text(AppStrings.register)),
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
                'إنشاء حساب جديد',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                'املأ البيانات التالية للتسجيل',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Doctor Registration Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.medical_services,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'هل أنت طبيب؟',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'سجل كطبيب للوصول إلى لوحة التحكم',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => const DoctorRegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        AppStrings.registerAsDoctor,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
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
                hint: 'example@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: Validators.email,
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: 16),

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
                text: AppStrings.register,
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
