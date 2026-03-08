import 'package:elajtech/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

/// Devices Screen - شاشة الأجهزة
class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.devices),
      ),
      body: const Center(
        child: Text(
          'قريباً سيتم إضافة الأجهزة',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
