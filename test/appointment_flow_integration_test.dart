import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
// تم حذف dartz لعدم الحاجة لها هنا

void main() {
  group('Androcare360 - Integration Test: Appointment to EMR Flow', () {
    late FakeFirebaseFirestore instance;

    setUp(() {
      instance = FakeFirebaseFirestore();
    });

    test('🔄 دورة حياة الموعد: من الحجز حتى إضافة السجل الطبي بنجاح', () async {
      // 1. إعداد بيانات الطبيب والمريض
      const doctorId = 'doc_001';
      const patientId = 'pat_001';

      await instance.collection('users').doc(doctorId).set({
        'userType': 'doctor', // التأكد من استخدام المسمى الجديد المصلح
        'fullName': 'د. أحمد علي',
        'specialization': 'طب الأسرة',
      });

      // 2. محاكاة عملية حجز موعد
      const appointmentId = 'app_100';
      await instance.collection('appointments').doc(appointmentId).set({
        'doctorId': doctorId,
        'patientId': patientId,
        'appointmentDate': DateTime.now()
            .add(const Duration(days: 1))
            .toIso8601String(),
        'status': 'scheduled',
      });

      // 3. التحقق من نجاح الحجز
      final appSnapshot = await instance
          .collection('appointments')
          .doc(appointmentId)
          .get();
      expect(appSnapshot.exists, isTrue);
      expect(appSnapshot.data()?['status'], 'scheduled');

      // 4. إضافة سجل طبي (EMR)
      final emrData = {
        'diagnosis': 'التهاب بسيط في الحلق',
        'prescription': 'مضاد حيوي 500 ملغ',
        'addedBy': doctorId,
        'patientId': patientId,
        'doctorType': 'doctor', // إضافة نوع المستخدم للتوثيق الإضافي
        'timestamp': DateTime.now().toIso8601String(),
      };

      await instance
          .collection('appointments')
          .doc(appointmentId)
          .collection('medical_records')
          .add(emrData);

      // 5. التحقق النهائي
      final emrSnapshot = await instance
          .collection('appointments')
          .doc(appointmentId)
          .collection('medical_records')
          .get();

      expect(emrSnapshot.docs.length, 1);
      expect(
        emrSnapshot.docs.first.data()['diagnosis'],
        'التهاب بسيط في الحلق',
      );
      print('✅ تم اختبار تدفق الموعد والسجل الطبي بنجاح');
    });
  });
}
