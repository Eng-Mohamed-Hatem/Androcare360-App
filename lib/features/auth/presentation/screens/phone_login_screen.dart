import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/constants/app_strings.dart';
import 'package:elajtech/core/utils/validators.dart';
import 'package:elajtech/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:elajtech/shared/widgets/custom_button.dart';
import 'package:elajtech/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Phone Login Screen - شاشة تسجيل الدخول برقم الهاتف
class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({
    super.key,
    this.requestedUserType = UserType.patient,
  });
  final UserType requestedUserType;

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// Handles phone verification request
  Future<void> _handleVerifyPhone() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final phoneNumber = _phoneController.text.trim();

      // Ensure it starts with + if needed, or follow E.164
      // Simple validation: if doesn't start with +, assume international code added by user
      // but typical pattern is +[country][number]

      await ref.read(authProvider.notifier).startPhoneVerification(phoneNumber);

      if (mounted) {
        final authState = ref.read(authProvider);

        if (authState.phoneAuthErrorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.phoneAuthErrorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (authState.verificationId != null) {
          // Navigate to OTP screen
          await Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (context) => OtpVerificationScreen(
                phoneNumber: phoneNumber,
                requestedUserType: widget.requestedUserType,
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPhoneLoading = ref.watch(
      authProvider.select((s) => s.isPhoneLoading),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.authPhoneLoginTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Icon/Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.phone_android,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  AppStrings.authPhoneLoginTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                Text(
                  'أدخل رقم الهاتف مسبوقاً بكود الدولة (مثال: +20)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Phone Field
                CustomTextField(
                  label: AppStrings.phoneNumber,
                  hint: '+9665XXXXXXXX',
                  helperText: 'اكتب رقم الموبايل بصيغة دولية مثل +9665XXXXXXXX',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone,
                  textDirection: TextDirection.ltr,
                  validator: Validators.phoneNumber,
                ),
                const SizedBox(height: 32),

                // Verify Button
                CustomButton(
                  text: 'إرسال رمز التحقق',
                  onPressed: isPhoneLoading ? null : _handleVerifyPhone,
                  isLoading: isPhoneLoading,
                  height: 52,
                ),

                const SizedBox(height: 24),

                // Info Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.amber),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'سيتم إرسال رمز تحقق (OTP) مكون من 6 أرقام لهاتفك.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
