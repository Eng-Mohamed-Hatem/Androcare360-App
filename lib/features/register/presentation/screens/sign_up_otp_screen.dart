import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/patient/home/presentation/screens/patient_home_screen.dart';
import 'package:elajtech/features/register/presentation/screens/patient_register_screen.dart'
    show PatientRegisterScreen;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// شاشة إدخال رمز OTP لإتمام تسجيل المريض الجديد.
///
/// ⚠️ Patient sign-up only.
///
/// تُعرَض هذه الشاشة بعد [PatientRegisterScreen] فور إرسال رمز OTP.
/// عند نجاح التحقق، يتم ربط الهاتف بالحساب وإنشاء وثيقة Firestore،
/// ثم الانتقال إلى [PatientHomeScreen].
class SignUpOtpScreen extends ConsumerStatefulWidget {
  const SignUpOtpScreen({super.key});

  @override
  ConsumerState<SignUpOtpScreen> createState() => _SignUpOtpScreenState();
}

class _SignUpOtpScreenState extends ConsumerState<SignUpOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  /// تأكيد رمز OTP وإتمام تسجيل المريض.
  Future<void> _confirmOtp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref
        .read(authProvider.notifier)
        .confirmSignUpOtp(smsCode: _otpController.text.trim());

    if (!mounted) return;
    final authState = ref.read(authProvider);

    if (authState.isAuthenticated) {
      // تسجيل ناجح — انتقل لشاشة المريض الرئيسية وامسح سجل التنقل
      await Navigator.pushAndRemoveUntil<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => const PatientHomeScreen(),
        ),
        (_) => false,
      );
    } else if (authState.signUpError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.signUpError!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.signUpLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تأكيد رقم الهاتف'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),

                // Icon
                const Icon(
                  Icons.phone_android,
                  size: 72,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'أدخل رمز التحقق',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'تم إرسال رمز مكوّن من 6 أرقام إلى رقم هاتفك.\n'
                  'يرجى إدخاله في الحقل أدناه لإتمام التسجيل.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // OTP Input
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 12,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '------',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        letterSpacing: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال رمز التحقق';
                      }
                      if (value.trim().length != 6) {
                        return 'رمز التحقق يجب أن يكون 6 أرقام';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // Confirm Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _confirmOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'تأكيد وإتمام التسجيل',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Info note
                Text(
                  'إذا لم يصلك الرمز خلال دقيقة، يرجى الرجوع والمحاولة مرة أخرى.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
