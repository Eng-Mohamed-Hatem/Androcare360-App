import 'dart:async';

import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/utils/validators.dart';
import 'package:elajtech/features/auth/presentation/screens/link_phone_otp_screen.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// شاشة ربط رقم الهاتف بالحساب الحالي — الخطوة 1: إدخال رقم الهاتف
///
/// تتاح لكل من المريض والطبيب المسجّلَين بالبريد الإلكتروني.
/// تُرسل رمز OTP عبر Firebase Phone Auth وتنتقل إلى [LinkPhoneOtpScreen].
class LinkPhoneScreen extends ConsumerStatefulWidget {
  const LinkPhoneScreen({super.key});

  @override
  ConsumerState<LinkPhoneScreen> createState() => _LinkPhoneScreenState();
}

class _LinkPhoneScreenState extends ConsumerState<LinkPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  /// المرجع المُستخدَم لمراقبة تغيّر حالة [linkingVerificationId].
  String? _previousVerificationId;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// يُرسل OTP ثم ينتظر حتى يصل [linkingVerificationId] الجديد.
  Future<void> _sendOtp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final phone = _phoneController.text.trim();

    // حفظ الـ verificationId الحالي قبل الإرسال للكشف عن التغيير
    _previousVerificationId = ref.read(authProvider).linkingVerificationId;

    await ref.read(authProvider.notifier).startPhoneLinking(phoneNumber: phone);

    if (!mounted) return;

    final authState = ref.read(authProvider);

    // إذا ظهر خطأ — اعرضه في Snackbar
    if (authState.linkingError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.linkingError!),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // إذا وصل verificationId جديد — انتقل إلى شاشة OTP
    if (authState.linkingVerificationId != null &&
        authState.linkingVerificationId != _previousVerificationId) {
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => const LinkPhoneOtpScreen(),
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
        appBar: AppBar(title: const Text('ربط رقم الهاتف')),
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
                    Icons.phone_android_outlined,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'أدخل رقم هاتفك',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'سيُرسَل إليك رمز تحقق (OTP) لتأكيد ربط الرقم بحسابك.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // حقل رقم الهاتف
                CustomTextField(
                  label: 'رقم الهاتف',
                  hint: '+9665XXXXXXXX',
                  helperText: 'اكتب رقم الموبايل بصيغة دولية مثل +9665XXXXXXXX',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_android_outlined,
                  textDirection: TextDirection.ltr,
                  validator: Validators.phoneNumber,
                ),

                const SizedBox(height: 32),

                // زر الإرسال
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLinking ? null : _sendOtp,
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
                            'إرسال رمز التحقق',
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
