import 'dart:async';

import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// شاشة التحقق برمز OTP لتأكيد ربط رقم الهاتف — الخطوة 2
///
/// تستقبل رمز الـ OTP المؤلَّف من 6 أرقام وتستدعي [AuthNotifier.confirmPhoneLinking].
/// عند النجاح تعود إلى الشاشة السابقة وتعرض رسالة نجاح.
/// عند الفشل تعرض رسالة الخطأ وتسمح بإعادة المحاولة.
class LinkPhoneOtpScreen extends ConsumerStatefulWidget {
  const LinkPhoneOtpScreen({super.key});

  @override
  ConsumerState<LinkPhoneOtpScreen> createState() => _LinkPhoneOtpScreenState();
}

class _LinkPhoneOtpScreenState extends ConsumerState<LinkPhoneOtpScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _confirmLinking() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final smsCode = _otpController.text.trim();
    await ref.read(authProvider.notifier).confirmPhoneLinking(smsCode: smsCode);

    if (!mounted) return;

    final authState = ref.read(authProvider);

    if (authState.linkingSuccess) {
      // نجاح — أعد المستخدم إلى قائمة الإعدادات مع رسالة توضيحية
      Navigator.of(context)
        ..pop() // إغلاق LinkPhoneOtpScreen
        ..pop(); // إغلاق LinkPhoneScreen

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '✅ تم ربط رقم الهاتف بنجاح. يمكنك الآن تسجيل الدخول باستخدام رقم الموبايل والـ OTP.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (authState.linkingError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.linkingError!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLinking = ref.watch(authProvider.select((s) => s.isLinking));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تأكيد رمز التحقق')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // أيقونة توضيحية
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sms_outlined,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'أدخل رمز التحقق',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'أرسلنا رمز مكوّن من 6 أرقام إلى هاتفك. أدخله أدناه لتأكيد الربط.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // حقل رمز OTP
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  decoration: InputDecoration(
                    labelText: 'رمز التحقق (OTP)',
                    hintText: '------',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length != 6) {
                      return 'يرجى إدخال الرمز المكوّن من 6 أرقام';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // زر التأكيد
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLinking ? null : _confirmLinking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLinking
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'تأكيد الربط',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
