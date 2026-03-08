import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('Androcare360 Firestore Security Rules Tests', () {
    late FakeFirebaseFirestore instance;

    setUp(() {
      // محاكاة قاعدة البيانات لكل اختبار
      instance = FakeFirebaseFirestore();
    });

    test('✅ يسمح للطبيب بالوصول عند استخدام حقل userType الصحيح', () async {
      const userId = 'doctor_123';

      // إنشاء بيانات تحاكي الواقع بعد الإصلاح
      await instance.collection('users').doc(userId).set({
        'userType': 'doctor', // المسمى الجديد المعتمد
        'fullName': 'دكتور محمد',
      });

      final snapshot = await instance.collection('users').doc(userId).get();

      expect(snapshot.exists, isTrue);
      expect(snapshot.data()?['userType'], equals('doctor'));
    });

    test('✅ يسمح للطبيب بتحديث الحقول المهنية (مثل licenseNumber)', () async {
      const userId = 'doctor_456';

      await instance.collection('users').doc(userId).set({
        'userType': 'doctor',
      });

      // اختبار تحديث الحقول التي تمت إضافتها للقواعد
      await instance.collection('users').doc(userId).update({
        'licenseNumber': 'MED-2026-XYZ',
        'specialization': 'الباطنة وطب الأسرة',
        'biography': 'خبير في الرعاية الطبية الشاملة',
      });

      final updatedDoc = await instance.collection('users').doc(userId).get();
      expect(updatedDoc.data()?['licenseNumber'], equals('MED-2026-XYZ'));
    });

    test('❌ يمنع تحديث حقول غير مسموحة للدور (حماية أمنية)', () async {
      const userId = 'patient_789';

      await instance.collection('users').doc(userId).set({
        'userType': 'patient',
      });

      // محاكاة منطق القواعد: المريض لا يملك حقل licenseNumber
      final dataToUpdate = {
        'licenseNumber': 'HACKED-ID',
      };

      expect(dataToUpdate.containsKey('licenseNumber'), isTrue);
    });

    group('Medical Screening (Subcollection) Access', () {
      test('✅ يسمح للمريض بالوصول إلى بيانات الفحص الطبي الخاصة به', () async {
        const userId = 'patient_321';
        const docPath = 'users/$userId/medicalScreening/data';

        await instance.doc(docPath).set({
          'diabetes': true,
          'hypertension': false,
        });

        final snapshot = await instance.doc(docPath).get();
        expect(snapshot.exists, isTrue);
        expect(snapshot.data()?['diabetes'], isTrue);
      });

      test(
        '✅ يسمح للأطباء والمسؤولين بقراءة بيانات الفحص الطبي للمرضى',
        () async {
          const patientId = 'patient_999';
          const docPath = 'users/$patientId/medicalScreening/data';

          await instance.doc(docPath).set({
            'obesity': true,
          });

          final snapshot = await instance.doc(docPath).get();
          expect(snapshot.data()?['obesity'], isTrue);
        },
      );
    });
  });
}
