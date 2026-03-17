import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/presentation/providers/doctor_registration_provider.dart';
import 'package:elajtech/shared/constants/clinic_types.dart';
import 'package:elajtech/shared/utils/phone_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Doctor registration screen with specialty and phone validation.
class DoctorRegistrationScreen extends ConsumerStatefulWidget {
  const DoctorRegistrationScreen({super.key});

  @override
  ConsumerState<DoctorRegistrationScreen> createState() =>
      _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState
    extends ConsumerState<DoctorRegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final ValueNotifier<String?> _phoneError = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _specialtyError = ValueNotifier<String?>(null);
  String _selectedClinicType = '';

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _phoneError.dispose();
    _specialtyError.dispose();
    super.dispose();
  }

  Future<void> _registerDoctor() async {
    if (_formKey.currentState?.validate() != true) return;

    if (_selectedClinicType.isEmpty) {
      _specialtyError.value = 'Specialty is required';
      return;
    }
    _specialtyError.value = null;

    final phoneValidation = PhoneValidator.validate(
      _phoneController.text.trim(),
    );
    _phoneError.value = phoneValidation;
    if (phoneValidation != null) return;

    await ref
        .read(doctorRegistrationProvider.notifier)
        .registerDoctor(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          specialty: ClinicTypes.arabicLabel(_selectedClinicType),
        );
  }

  @override
  Widget build(BuildContext context) {
    final registrationState = ref.watch(doctorRegistrationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Registration'),
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
                TextFormField(
                  key: const Key('doctor_registration_full_name_field'),
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Full name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  key: const Key('doctor_registration_email_field'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@')) {
                      return 'Invalid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ValueListenableBuilder<String?>(
                  valueListenable: _phoneError,
                  builder: (context, phoneError, _) {
                    return TextFormField(
                      key: const Key('doctor_registration_phone_field'),
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone number',
                        prefixIcon: const Icon(Icons.phone),
                        border: const OutlineInputBorder(),
                        errorText: phoneError,
                        helperText:
                            'Format: +countrycode number (e.g. +201234567890)',
                      ),
                      validator: PhoneValidator.validate,
                    );
                  },
                ),
                const SizedBox(height: 24),
                ValueListenableBuilder<String?>(
                  valueListenable: _specialtyError,
                  builder: (context, specialtyError, _) {
                    return DropdownButtonFormField<String>(
                      key: const Key('doctor_registration_specialty_dropdown'),
                      isExpanded: true,
                      initialValue: _selectedClinicType.isEmpty
                          ? null
                          : _selectedClinicType,
                      decoration: InputDecoration(
                        labelText: 'نوع العيادة',
                        prefixIcon: const Icon(Icons.medical_services),
                        border: const OutlineInputBorder(),
                        errorText: specialtyError,
                      ),
                      items: ClinicTypes.values.map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(ClinicTypes.arabicLabel(value)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedClinicType = newValue ?? '';
                        });
                        if (newValue != null) {
                          _specialtyError.value = null;
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى اختيار نوع العيادة';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  key: const Key('doctor_registration_submit_button'),
                  onPressed: registrationState.isLoading
                      ? null
                      : _registerDoctor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: registrationState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                if (registrationState.isSuccess)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 48,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Registration successful',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your account is pending admin approval',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (registrationState.error != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      registrationState.error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
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
