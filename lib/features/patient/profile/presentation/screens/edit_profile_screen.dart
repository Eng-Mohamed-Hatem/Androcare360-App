import 'dart:async';

import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/constants/app_strings.dart';
import 'package:elajtech/shared/widgets/custom_button.dart';
import 'package:elajtech/shared/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Edit Profile Screen - شاشة تعديل الملف الشخصي
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showPasswordFields = false;

  @override
  void initState() {
    super.initState();
    // Load current email safely
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _emailController.text = user.email ?? '';
      }
    } on Exception {
      // Firebase not initialized, leave email empty
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updateEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('المستخدم غير مسجل الدخول');

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );
      await user.reauthenticateWithCredential(credential);

      // Update email
      await user.verifyBeforeUpdateEmail(_emailController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال رابط التحقق إلى البريد الإلكتروني الجديد'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      var message = 'حدث خطأ أثناء تحديث البريد الإلكتروني';
      if (e.code == 'wrong-password') {
        message = 'كلمة المرور الحالية غير صحيحة';
      } else if (e.code == 'email-already-in-use') {
        message = 'البريد الإلكتروني مستخدم بالفعل';
      } else if (e.code == 'invalid-email') {
        message = 'البريد الإلكتروني غير صالح';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
      }
    } on Exception catch (e) {
      // Handle non-Firebase errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('المستخدم غير مسجل الدخول');

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(_newPasswordController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث كلمة المرور بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      var message = 'حدث خطأ أثناء تحديث كلمة المرور';
      if (e.code == 'wrong-password') {
        message = 'كلمة المرور الحالية غير صحيحة';
      } else if (e.code == 'weak-password') {
        message = 'كلمة المرور الجديدة ضعيفة جداً';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
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
    appBar: AppBar(title: const Text('تعديل الملف الشخصي')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email Section
            Text(
              'البريد الإلكتروني',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _emailController,
              label: AppStrings.email,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال البريد الإلكتروني';
                }
                if (!value.contains('@')) {
                  return 'البريد الإلكتروني غير صالح';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Password Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'كلمة المرور',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showPasswordFields = !_showPasswordFields;
                    });
                  },
                  child: Text(_showPasswordFields ? 'إخفاء' : 'تغيير'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_showPasswordFields) ...[
              CustomTextField(
                controller: _newPasswordController,
                label: 'كلمة المرور الجديدة',
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال كلمة المرور الجديدة';
                  }
                  if (value.length < 6) {
                    return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _confirmPasswordController,
                label: 'تأكيد كلمة المرور',
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'كلمة المرور غير متطابقة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
            ],

            // Current Password (required for both operations)
            Text(
              'للتأكيد، أدخل كلمة المرور الحالية',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 12),

            CustomTextField(
              controller: _currentPasswordController,
              label: 'كلمة المرور الحالية',
              obscureText: true,
              prefixIcon: Icons.lock,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال كلمة المرور الحالية';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'حفظ التغييرات',
                onPressed: _isLoading
                    ? () {}
                    : () {
                        if (_showPasswordFields) {
                          // Intentionally not awaited - update happens in background
                          unawaited(_updatePassword());
                        } else {
                          // Intentionally not awaited - update happens in background
                          unawaited(_updateEmail());
                        }
                      },
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
