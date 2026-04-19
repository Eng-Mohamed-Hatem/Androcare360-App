import 'dart:async';

import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/constants/app_strings.dart';
import 'package:elajtech/core/utils/validators.dart';
import 'package:elajtech/features/auth/presentation/screens/login_screen.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/common/privacy_policy_screen.dart';
import 'package:elajtech/shared/widgets/biometric_switch.dart';
import 'package:elajtech/shared/widgets/custom_text_field.dart';
import 'package:elajtech/features/auth/presentation/screens/link_phone_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Doctor Profile Screen - صفحة الملف الشخصي للطبيب
class DoctorProfileScreen extends ConsumerStatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  ConsumerState<DoctorProfileScreen> createState() =>
      _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends ConsumerState<DoctorProfileScreen> {
  Future<void> _showChangePasswordDialog() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.changePassword),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: AppStrings.currentPassword,
                  controller: currentPasswordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: AppStrings.newPassword,
                  controller: newPasswordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: AppStrings.confirmPassword,
                  controller: confirmPasswordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) => Validators.confirmPassword(
                    value,
                    newPasswordController.text,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final user = FirebaseAuth.instance.currentUser;
              if (user == null || user.email == null) return;
              try {
                final credential = EmailAuthProvider.credential(
                  email: user.email!,
                  password: currentPasswordController.text,
                );
                await user.reauthenticateWithCredential(credential);
                await user.updatePassword(newPasswordController.text);
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تغيير كلمة المرور بنجاح'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } on FirebaseAuthException catch (e) {
                if (!context.mounted) return;
                final msg =
                    e.code == 'wrong-password' || e.code == 'invalid-credential'
                        ? 'كلمة المرور الحالية غير صحيحة'
                        : e.message ?? 'حدث خطأ، يرجى المحاولة لاحقاً';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(msg),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutConfirmation() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.logout),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (!context.mounted) return;
              await Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
            child: const Text(
              AppStrings.logout,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.doctorProfile),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    backgroundImage:
                        user?.profileImage != null &&
                            user!.profileImage!.isNotEmpty
                        ? NetworkImage(user.profileImage!)
                        : null,
                    child:
                        user?.profileImage == null ||
                            user!.profileImage!.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'د. ${user?.fullName ?? "غير متوفر"}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.specializations != null &&
                            user!.specializations!.isNotEmpty
                        ? user.specializations!.join('، ')
                        : 'التخصص غير محدد',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Personal Information Section
            Text(
              AppStrings.personalInfo,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _InfoCard(
              icon: Icons.email_outlined,
              title: AppStrings.email,
              value: user?.email ?? 'غير متوفر',
            ),
            const SizedBox(height: 12),

            _InfoCard(
              icon: Icons.phone_outlined,
              title: AppStrings.phoneNumber,
              value: user?.phoneNumber ?? 'غير متوفر',
            ),

            // ── ربط رقم الهاتف (يظهر فقط إذا لم يكن هناك رقم مرتبط) ──
            if (user?.phoneNumber == null || user!.phoneNumber!.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _SettingsTile(
                  icon: Icons.link,
                  title: 'ربط رقم الهاتف',
                  onTap: () async {
                    await Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const LinkPhoneScreen(),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),

            _InfoCard(
              icon: Icons.badge_outlined,
              title: AppStrings.licenseNumber,
              value: user?.licenseNumber ?? 'غير متوفر',
            ),
            const SizedBox(height: 12),

            _InfoCard(
              icon: Icons.medical_services_outlined,
              title: AppStrings.specialization,
              value:
                  user?.specializations != null &&
                      user!.specializations!.isNotEmpty
                  ? user.specializations!.join('، ')
                  : 'غير محدد',
            ),
            const SizedBox(height: 12),

            _InfoCard(
              icon: Icons.info_outline,
              title: 'نبذة عني',
              value: user?.biography ?? 'لا يوجد نبذة',
            ),
            const SizedBox(height: 12),

            _InfoCard(
              icon: Icons.timeline,
              title: 'سنوات الخبرة',
              value: '${user?.yearsOfExperience ?? 0} سنوات',
            ),
            const SizedBox(height: 12),

            if (user?.clinicName != null) ...[
              _InfoCard(
                icon: Icons.local_hospital_outlined,
                title: 'العيادة',
                value: user!.clinicName!,
              ),
              const SizedBox(height: 12),
            ],

            if (user?.clinicAddress != null) ...[
              _InfoCard(
                icon: Icons.location_on_outlined,
                title: 'عنوان العيادة',
                value: user!.clinicAddress!,
              ),
              const SizedBox(height: 12),
            ],

            _InfoCard(
              icon: Icons.attach_money,
              title: 'سعر الكشف',
              value: '${user?.consultationFee ?? 0} ريال',
            ),
            const SizedBox(height: 12),

            _InfoCard(
              icon: Icons.videocam_outlined,
              title: 'أنواع الاستشارات',
              value:
                  user?.consultationTypes != null &&
                      user!.consultationTypes!.isNotEmpty
                  ? user.consultationTypes!
                        .map((t) => t == 'video' ? 'فيديو' : 'عيادة')
                        .join('، ')
                  : 'غير محدد',
            ),

            const SizedBox(height: 32),

            if (user?.education != null && user!.education!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                AppStrings.education,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              ...user.education!.map(
                (edu) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _EducationCard(
                    degree: edu['degree']!,
                    university: edu['university']!,
                    year: edu['year']!,
                  ),
                ),
              ),
            ],

            if (user?.certificates != null &&
                user!.certificates!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                AppStrings.certificates,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              ...user.certificates!.map(
                (cert) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _CertificateCard(
                    name: cert['name']!,
                    organization: cert['organization']!,
                    date: cert['date']!,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Settings Section
            Text(
              AppStrings.settings,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _SettingsTile(
              icon: Icons.lock_outline,
              title: AppStrings.changePassword,
              onTap: () async => _showChangePasswordDialog(),
            ),
            const SizedBox(height: 12),

            const _SettingsTile(
              icon: Icons.fingerprint,
              title: 'تفعيل الدخول بالبصمة',
              trailing: BiometricSwitch(),
            ),
            const SizedBox(height: 12),

            const SizedBox(height: 12),

            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'سياسة الخصوصية',
              onTap: () {
                // Intentionally not awaited - navigation happens in background
                unawaited(
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _SettingsTile(
              icon: Icons.logout,
              title: AppStrings.logout,
              onTap: () async => _showLogoutConfirmation(),
              isDestructive: true,
            ),

            const SizedBox(height: 12),
            const Divider(),

            _SettingsTile(
              icon: Icons.delete_forever,
              title: 'حذف الحساب',
              isDestructive: true,
              onTap: () async {
                await showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('حذف الحساب نهائياً'),
                    content: const Text(
                      'هل أنت متأكد من رغبتك في حذف الحساب؟ سيتم فقدان جميع بياناتك وسجلاتك الطبية بشكل نهائي ولا يمكن استرجاعها.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context); // Close dialog

                          // Show loading
                          await showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          await ref.read(authProvider.notifier).deleteAccount();

                          if (context.mounted) {
                            Navigator.pop(context); // Close loading

                            final error = ref.read(authProvider).error;
                            if (error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            } else {
                              // Success - Navigate to Login (State listener in main usually handles this, but we force it here)
                              await Navigator.of(
                                context,
                              ).pushNamedAndRemoveUntil('/', (route) => false);
                            }
                          }
                        },
                        child: const Text(
                          'حذف نهائي',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.borderLight),
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _EducationCard extends StatelessWidget {
  const _EducationCard({
    required this.degree,
    required this.university,
    required this.year,
  });
  final String degree;
  final String university;
  final String year;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.borderLight),
    ),
    child: Row(
      children: [
        const Icon(Icons.school, color: AppColors.primary, size: 32),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                degree,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(university, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(
                year,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({
    required this.name,
    required this.organization,
    required this.date,
  });
  final String name;
  final String organization;
  final String date;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.borderLight),
    ),
    child: Row(
      children: [
        const Icon(Icons.card_membership, color: AppColors.primary, size: 32),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                organization,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.onTap,
    this.isDestructive = false,
    this.trailing,
  });
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool isDestructive;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDestructive ? AppColors.error : AppColors.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDestructive ? AppColors.error : null,
              ),
            ),
          ),
          trailing ??
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondaryLight,
              ),
        ],
      ),
    ),
  );
}
