import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/constants/app_strings.dart';
import 'package:elajtech/core/utils/validators.dart';
import 'package:elajtech/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:elajtech/features/auth/presentation/screens/phone_login_screen.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/register/presentation/screens/patient_register_screen.dart';
import 'package:elajtech/main.dart' show AuthWrapper;
import 'package:elajtech/shared/models/user_model.dart';
import 'package:elajtech/shared/widgets/custom_button.dart';
import 'package:elajtech/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Login Screen - شاشة تسجيل الدخول
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handles patient login — routing is managed by [AuthWrapper] which
  /// watches [authProvider] and switches between admin / doctor / patient
  /// screens automatically when [isAuthenticated] becomes true.
  Future<void> _handleLogin() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      await ref
          .read(authProvider.notifier)
          .loginWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
          );

      if (mounted) {
        final authState = ref.read(authProvider);

        if (authState.isAuthenticated) {
          // AuthWrapper handles routing — no explicit Navigator call needed.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تسجيل الدخول بنجاح!'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (authState.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.error!),
              backgroundColor: AppColors.error,
            ),
          );
        }

        setState(() => _isLoading = false);
      }
    }
  }

  /// Handles biometric login — routing is managed by [AuthWrapper].
  Future<void> _handleBiometricLogin() async {
    FocusScope.of(context).unfocus();

    await ref.read(authProvider.notifier).loginWithBiometric();

    if (mounted) {
      final authState = ref.read(authProvider);
      if (authState.isAuthenticated) {
        // AuthWrapper handles routing for admin / doctor / patient.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تسجيل الدخول بنجاح!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (authState.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Handles phone login navigation.
  Future<void> _handlePhoneLogin() async {
    FocusScope.of(context).unfocus();
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const PhoneLoginScreen(),
      ),
    );
  }

  /// Handles doctor login — routing is managed by [AuthWrapper].
  Future<void> _handleDoctorLogin() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      await ref
          .read(authProvider.notifier)
          .loginWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
            userType: UserType.doctor,
          );

      if (mounted) {
        final authState = ref.read(authProvider);

        if (authState.isAuthenticated) {
          // AuthWrapper handles routing — no explicit Navigator call needed.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تسجيل الدخول بنجاح!'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (authState.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.error!),
              backgroundColor: AppColors.error,
            ),
          );
        }

        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.medical_services,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                AppStrings.login,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                'مرحباً بك في ${AppStrings.appName}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Email Field
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

              // Password Field
              CustomTextField(
                label: AppStrings.password,
                controller: _passwordController,
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                validator: Validators.password,
              ),
              const SizedBox(height: 12),

              // Forgot Password
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () async {
                    await Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text(AppStrings.forgotPassword),
                ),
              ),
              const SizedBox(height: 24),

              // Login Button
              CustomButton(
                text: AppStrings.login,
                onPressed: _isLoading ? null : _handleLogin,
                isLoading: _isLoading,
                height: 52,
              ),
              const SizedBox(height: 16),

              // Biometric Login Button
              CustomButton(
                text: AppStrings.loginWithBiometric,
                onPressed: _handleBiometricLogin,
                isOutlined: true,
                icon: Icons.fingerprint,
                height: 52,
              ),
              const SizedBox(height: 16),

              // Phone Login Button
              CustomButton(
                text: 'تسجيل الدخول برقم الهاتف',
                onPressed: _handlePhoneLogin,
                isOutlined: true,
                icon: Icons.phone_android,
                height: 52,
              ),
              const SizedBox(height: 16),

              // Doctor Login Button
              CustomButton(
                text: AppStrings.loginAsDoctor,
                onPressed: _isLoading ? null : _handleDoctorLogin,
                isOutlined: true,
                isLoading: _isLoading,
                icon: Icons.medical_services,
                height: 52,
              ),
              const SizedBox(height: 32),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'أو',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 32),

              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.dontHaveAccount,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () async {
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const PatientRegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      AppStrings.register,
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
