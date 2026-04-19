import 'package:elajtech/features/patient/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import 'package:elajtech/features/patient/appointments/presentation/screens/patient_appointments_screen.dart';
import 'package:elajtech/features/patient/home/presentation/screens/doctors_list_screen.dart';
import 'package:elajtech/features/patient/home/presentation/screens/patient_home_screen.dart';
import 'package:elajtech/features/patient/medical_records/presentation/screens/medical_records_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// مزود التبويب المحدد في شاشة المريض الرئيسية
/// Shared tab-index provider for PatientMainScreen.
/// Write to this from any descendant widget to switch tabs programmatically.
final patientMainTabProvider = StateProvider<int>((ref) => 0);

/// Patient Main Screen - الشاشة الرئيسية للمريض مع شريط التنقل السفلي
class PatientMainScreen extends ConsumerStatefulWidget {
  /// إنشاء الشاشة الرئيسية للمريض
  const PatientMainScreen({super.key});

  @override
  ConsumerState<PatientMainScreen> createState() => _PatientMainScreenState();
}

class _PatientMainScreenState extends ConsumerState<PatientMainScreen> {
  /// الحصول على قائمة الشاشات المتاحة
  List<Widget> _getScreens() {
    return const [
      PatientHomeScreen(), // 0: الرئيسية
      DoctorsListScreen(), // 1: الأطباء
      AIAssistantScreen(), // 2: مساعد الذكاء الاصطناعي
      PatientAppointmentsScreen(), // 3: المواعيد
      MedicalRecordsScreen(), // 4: السجل الطبي
    ];
  }

  @override
  Widget build(BuildContext context) {
    // قراءة الفهرس من المزود المشترك حتى تستطيع أي شاشة فرعية التبديل برمجياً
    final selectedIndex = ref.watch(patientMainTabProvider);

    return Scaffold(
      // منع تغيير حجم الواجهة عند ظهور لوحة المفاتيح
      resizeToAvoidBottomInset: false,

      // الشاشة الحالية
      body: IndexedStack(
        index: selectedIndex,
        children: _getScreens(),
      ),

      // شريط التنقل السفلي بشكل أكثر إحكاماً لتقليل الفراغ العلوي
      bottomNavigationBar: Directionality(
        textDirection: TextDirection.rtl, // RTL للغة العربية
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) =>
              ref.read(patientMainTabProvider.notifier).state = index,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services_outlined),
              activeIcon: Icon(Icons.medical_services),
              label: 'الأطباء',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology, color: Colors.purple),
              activeIcon: Icon(Icons.psychology, color: Colors.purple),
              label: 'Ai Assistant',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'المواعيد',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              activeIcon: Icon(Icons.folder),
              label: 'السجل الطبي',
            ),
          ],
        ),
      ),
    );
  }
}
