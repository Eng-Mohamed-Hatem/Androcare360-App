import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/constants/app_strings.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:elajtech/shared/widgets/custom_button.dart';
import 'package:elajtech/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// OTP Verification Screen - شاشة التحقق من كود SMS
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({
    required this.phoneNumber,
    super.key,
    this.requestedUserType = UserType.patient,
  });
  final String phoneNumber;
  final UserType requestedUserType;

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  /// Handles OTP verification
  Future<void> _handleVerifyOtp() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      await ref
          .read(authProvider.notifier)
          .verifyOtp(
            _otpController.text.trim(),
            widget.requestedUserType,
          );

      if (mounted) {
        final authState = ref.read(authProvider);

        if (authState.phoneAuthErrorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.phoneAuthErrorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (authState.isAuthenticated) {
          // Success! Navigation is handled by AuthWrapper.
          // We can pop back to root if needed, but usually AuthWrapper handles it.
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    }
  }

  /// Re-sends the verification code
  Future<void> _handleResendCode() async {
    await ref
        .read(authProvider.notifier)
        .startPhoneVerification(widget.phoneNumber);

    if (mounted) {
      final authState = ref.read(authProvider);
      if (authState.phoneAuthErrorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إعادة إرسال الرمز بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
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
        title: const Text(AppStrings.auth_otp_title),
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

                // Icon
                const Center(
                  child: Icon(
                    Icons.mark_email_read_outlined,
                    size: 80,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  AppStrings.auth_otp_title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                Text(
                  'أدخل الرمز المكون من 6 أرقام المرسل إلى\n${widget.phoneNumber}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(height: 40),

                // OTP Field
                CustomTextField(
                  label: 'رمز التحقق',
                  hint: '000000',
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.lock_clock_outlined,
                  textAlign: TextAlign.center,
                  letterSpacing: 8,
                  maxLength: 6,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال الرمز';
                    }
                    if (value.length < 6) {
                      return 'الرمز يجب أن يكون 6 أرقام';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Verify Button
                CustomButton(
                  text: 'تحقق وتسجيل الدخول',
                  onPressed: isPhoneLoading ? null : _handleVerifyOtp,
                  isLoading: isPhoneLoading,
                  height: 52,
                ),

                const SizedBox(height: 24),

                // Resend Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('لم يصلك الرمز؟'),
                    TextButton(
                      onPressed: isPhoneLoading ? null : _handleResendCode,
                      child: const Text(
                        AppStrings.auth_otp_resend,
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
}
