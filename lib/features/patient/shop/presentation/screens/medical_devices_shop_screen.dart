import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/patient/shop/presentation/widgets/device_card.dart';
import 'package:elajtech/shared/models/medical_device_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Medical Devices Shop Screen - شاشة متجر الأجهزة الطبية
class MedicalDevicesShopScreen extends ConsumerWidget {
  const MedicalDevicesShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = MockMedicalDevices.getDevices();

    return Scaffold(
      appBar: AppBar(
        title: const Text('متجر الأجهزة الطبية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن جهاز طبي...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Categories (Horizontal Scroll)
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                _CategoryChip('الكل', isSelected: true),
                _CategoryChip('أجهزة القياس', isSelected: false),
                _CategoryChip('أجهزة العلاج', isSelected: false),
                _CategoryChip('مستلزمات طبية', isSelected: false),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Devices Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: devices.length,
              itemBuilder: (context, index) =>
                  DeviceCard(device: devices[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip(this.label, {required this.isSelected});
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 8),
    child: FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {},
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
    ),
  );
}
