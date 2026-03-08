import 'package:elajtech/features/patient/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import 'package:elajtech/features/patient/home/presentation/screens/doctors_list_screen.dart';
import 'package:elajtech/features/patient/home/presentation/screens/patient_home_screen.dart';
import 'package:elajtech/features/patient/medical_records/presentation/screens/medical_records_screen.dart';
import 'package:elajtech/features/patient_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Patient Main Screen - الشاشة الرئيسية للمريض مع شريط التنقل السفلي
class PatientMainScreen extends ConsumerStatefulWidget {
  /// إنشاء الشاشة الرئيسية للمريض
  const PatientMainScreen({super.key});

  @override
  ConsumerState<PatientMainScreen> createState() => _PatientMainScreenState();
}

class _PatientMainScreenState extends ConsumerState<PatientMainScreen> {
  /// الفهرس الحالي للشاشة المعروضة
  int _selectedIndex = 0;

  /// الحصول على قائمة الشاشات المتاحة
  List<Widget> _getScreens() {
    return [
      const PatientHomeScreen(), // 0: الرئيسية
      const DoctorsListScreen(), // 1: الأطباء
      const AIAssistantScreen(), // 2: مساعد الذكاء الاصطناعي
      const AppointmentsManagementScreen(), // 3: المواعيد
      const MedicalRecordsScreen(), // 4: السجل الطبي
    ];
  }

  /// تغيير الشاشة المعروضة
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // منع تغيير حجم الواجهة عند ظهور لوحة المفاتيح
      resizeToAvoidBottomInset: false,

      // السماح للمحتوى بالامتداد خلف شريط التنقل السفلي
      extendBody: true,

      // الشاشة الحالية
      body: IndexedStack(
        index: _selectedIndex,
        children: _getScreens(),
      ),

      // شريط التنقل السفلي (شكل قياسي)
      bottomNavigationBar: Directionality(
        textDirection: TextDirection.rtl, // RTL للغة العربية
        child: NavigationBar(
          height: 75,
          selectedIndex: _selectedIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: _onItemTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: Icon(Icons.medical_services_outlined),
              label: 'الأطباء',
            ),
            NavigationDestination(
              icon: Icon(Icons.psychology, color: Colors.purple),
              label: 'Ai Assistant',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              label: 'المواعيد',
            ),
            NavigationDestination(
              icon: Icon(Icons.folder_outlined),
              label: 'السجل الطبي',
            ),
          ],
        ),
      ),
    );
  }
}
