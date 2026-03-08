import 'package:flutter/material.dart';

/// Department Model - نموذج القسم الطبي
class DepartmentModel {
  DepartmentModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.icon,
    required this.color,
    required this.description,
  });

  /// From JSON
  factory DepartmentModel.fromJson(Map<String, dynamic> json) =>
      DepartmentModel(
        id: json['id'] as String,
        nameAr: json['nameAr'] as String,
        nameEn: json['nameEn'] as String,
        icon: Icons.local_hospital, // Default fallback
        color: json['color'] as String,
        description: json['description'] as String,
      );
  final String id;
  final String nameAr;
  final String nameEn;
  final IconData icon;
  final String color;
  final String description;

  /// To JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'nameAr': nameAr,
    'nameEn': nameEn,
    'icon': icon.codePoint.toString(),
    'color': color,
    'description': description,
  };
}

/// Static list of medical departments
class MedicalDepartments {
  static List<DepartmentModel> getAllDepartments() => [
    DepartmentModel(
      id: '1',
      nameAr: 'أمراض الضعف الجنسي',
      nameEn: 'Sexual Dysfunction',
      icon: Icons.male,
      color: '#E3F2FD',
      description: 'علاج أمراض الضعف الجنسي',
    ),
    DepartmentModel(
      id: '2',
      nameAr: 'تأخر الإنجاب',
      nameEn: 'Infertility',
      icon: Icons.child_care,
      color: '#F3E5F5',
      description: 'علاج مشاكل تأخر الإنجاب',
    ),
    DepartmentModel(
      id: '3',
      nameAr: 'جراحات الذكورة',
      nameEn: 'Male Surgery',
      icon: Icons.medical_services,
      color: '#E8F5E9',
      description: 'جراحات الذكورة المتخصصة',
    ),
    DepartmentModel(
      id: '4',
      nameAr: 'زرع الدعامة الذكرية',
      nameEn: 'Penile Implant',
      icon: Icons.healing,
      color: '#FFF3E0',
      description: 'زرع الدعامة الذكرية (دعامة القضيب)',
    ),
    DepartmentModel(
      id: '5',
      nameAr: 'أمراض البروستات',
      nameEn: 'Prostate Diseases',
      icon: Icons.water_drop,
      color: '#FCE4EC',
      description: 'علاج أمراض البروستات',
    ),
    DepartmentModel(
      id: '6',
      nameAr: 'الموجات التصادمية',
      nameEn: 'Shockwave Therapy',
      icon: Icons.flash_on,
      color: '#E0F2F1',
      description: 'العلاج بالموجات التصادمية',
    ),
    DepartmentModel(
      id: '7',
      nameAr: 'الخدمات التشخيصية والعلاجية',
      nameEn: 'Diagnostic Services',
      icon: Icons.analytics,
      color: '#F1F8E9',
      description: 'الخدمات التشخيصية والعلاجية المتكاملة',
    ),
    DepartmentModel(
      id: '8',
      nameAr: 'الجلسات',
      nameEn: 'Sessions',
      icon: Icons.calendar_today,
      color: '#FFF9C4',
      description: 'جلسات العلاج المتخصصة',
    ),
    DepartmentModel(
      id: '9',
      nameAr: 'الأجهزة',
      nameEn: 'Devices',
      icon: Icons.monitor_heart,
      color: '#E1BEE7',
      description: 'الأجهزة الطبية المتخصصة',
    ),
    DepartmentModel(
      id: '10',
      nameAr: 'عيادة الباطنة',
      nameEn: 'Internal Medicine',
      icon: Icons.medical_information,
      color: '#E8EAF6',
      description: 'تشخيص وعلاج أمراض الباطنة',
    ),
    DepartmentModel(
      id: '11',
      nameAr: 'طب الأسرة',
      nameEn: 'Family Medicine',
      icon: Icons.family_restroom,
      color: '#FFF8E1',
      description: 'الرعاية الصحية الشاملة للعائلة',
    ),
  ];
}
