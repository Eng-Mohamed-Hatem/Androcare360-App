import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/constants/medical_specializations.dart';
import 'package:elajtech/features/patient/home/presentation/screens/doctors_list_screen.dart';
import 'package:flutter/material.dart';

class SubSpecialtiesScreen extends StatelessWidget {
  const SubSpecialtiesScreen({required this.mainCategory, super.key});
  final String mainCategory;

  @override
  Widget build(BuildContext context) {
    final subSpecialties = MedicalSpecializations.getSubSpecialties(
      mainCategory,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // Light gray background
      appBar: AppBar(
        title: Text(mainCategory),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: subSpecialties.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد تخصصات متاحة حالياً',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 Columns
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85, // Taller cards
              ),
              itemCount: subSpecialties.length,
              itemBuilder: (context, index) {
                final specialty = subSpecialties[index];
                final icon = MedicalSpecializations.getIcon(specialty);

                return _SpecialtyCard(
                  title: specialty,
                  icon: icon,
                  onTap: () async {
                    await Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) =>
                            DoctorsListScreen(category: specialty),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _SpecialtyCard extends StatelessWidget {
  const _SpecialtyCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}
