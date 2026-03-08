import 'package:elajtech/features/appointments/data/repositories/appointment_repository_impl.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class FakeFirebaseFunctions extends Fake implements FirebaseFunctions {
  FakeFirebaseFunctions(this.mockCallable);
  final HttpsCallable mockCallable;

  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) {
    return mockCallable;
  }
}

class FakeHttpsCallable extends Fake implements HttpsCallable {
  FakeHttpsCallable(this.mockResult);
  final Object mockResult;

  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    return mockResult as HttpsCallableResult<T>;
  }
}

class FakeHttpsCallableResult<T> extends Fake
    implements HttpsCallableResult<T> {
  FakeHttpsCallableResult(this.mockData);
  final T mockData;

  @override
  T get data => mockData;
}

void main() {
  late AppointmentRepositoryImpl repository;
  late FakeFirebaseFirestore fakeFirestore;
  late FakeFirebaseFunctions mockFunctions;

  setUp(() {
    tz_data.initializeTimeZones();
    fakeFirestore = FakeFirebaseFirestore();

    final mockResult = FakeHttpsCallableResult<Map<String, dynamic>>({
      'appointments': <dynamic>[],
    });
    final mockCallable = FakeHttpsCallable(mockResult);
    mockFunctions = FakeFirebaseFunctions(mockCallable);
  });

  final tDate = DateTime(2027, 1, 22, 10); // Future date
  final tAppointment = AppointmentModel(
    id: 'new_app_1',
    patientId: 'patient1',
    patientName: 'Patient Test',
    patientPhone: '123456789',
    doctorId: 'doctor1',
    doctorName: 'Dr. Test',
    specialization: 'General',
    appointmentDate: tDate,
    timeSlot: '10:00 AM',
    type: AppointmentType.video,
    status: AppointmentStatus.pending,
    fee: 100,
    createdAt: DateTime.now(),
    notes: 'Test',
  );

  group('checkAppointmentConflict', () {
    test(
      'should return Right(false) when no conflicting appointments exist (Success Case)',
      () async {
        repository = AppointmentRepositoryImpl(
          fakeFirestore,
          mockFunctions,
        );
        final result = await repository.checkAppointmentConflict(
          patientId: 'patient1',
          newAppointment: tAppointment,
        );
        expect(result.isRight(), true);
        expect(result.getOrElse(() => true), false);
      },
    );

    test(
      'should return Right(true) when conflicting appointment exists (Exact same time)',
      () async {
        repository = AppointmentRepositoryImpl(
          fakeFirestore,
          mockFunctions,
        );
        await repository.saveAppointment(
          tAppointment.copyWith(id: 'existing_1'),
        );

        final result = await repository.checkAppointmentConflict(
          patientId: 'patient1',
          newAppointment: tAppointment,
        );
        expect(result.isRight(), true);
        expect(result.getOrElse(() => false), true);
      },
    );

    test(
      'should return Right(false) when appointment is 30 mins later (New 30m Duration Rule)',
      () async {
        repository = AppointmentRepositoryImpl(
          fakeFirestore,
          mockFunctions,
        );
        // Save at 10:00 AM
        await repository.saveAppointment(
          tAppointment.copyWith(id: 'existing_1'),
        );

        // Try booking at 10:30 AM
        final lateAppointment = tAppointment.copyWith(
          id: 'new_2',
          timeSlot: '10:30 AM',
        );

        final result = await repository.checkAppointmentConflict(
          patientId: 'patient1',
          newAppointment: lateAppointment,
        );

        // Should be false now because default duration is 30 mins
        expect(result.isRight(), true);
        expect(result.getOrElse(() => true), false);
      },
    );
  });

  group('saveAppointment & bookAppointment Extra Validation', () {
    test('saveAppointment should fail for past dates', () async {
      repository = AppointmentRepositoryImpl(
        fakeFirestore,
        mockFunctions,
      );

      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      final pastAppointment = tAppointment.copyWith(
        id: 'past_1',
        appointmentDate: pastDate,
        timeSlot: '09:00 AM', // assume some past slot
      );

      final result = await repository.saveAppointment(pastAppointment);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, 'لا يمكن حجز موعد في وقت سابق'),
        (_) => fail('Should have failed'),
      );
    });

    test('bookAppointment should succeed for new slot and lock it', () async {
      repository = AppointmentRepositoryImpl(
        fakeFirestore,
        mockFunctions,
      );

      final result = await repository.bookAppointment(tAppointment);

      expect(result.isRight(), true);

      // Verify slot lock exists in Firestore
      final riyadhTimezone = tz.getLocation('Asia/Riyadh');
      final ts = tz.TZDateTime.from(tAppointment.fullDateTime, riyadhTimezone);
      final slotId = 'doctor1_${ts.millisecondsSinceEpoch}';

      final slotDoc = await fakeFirestore
          .collection('appointment_slots')
          .doc(slotId)
          .get();
      expect(slotDoc.exists, true);
      expect(slotDoc.data()?['appointmentId'], tAppointment.id);
    });

    test(
      'bookAppointment should fail if slot is already locked (Race Condition Prevention)',
      () async {
        repository = AppointmentRepositoryImpl(
          fakeFirestore,
          mockFunctions,
        );

        // 1. Manually lock the slot
        final riyadhTimezone = tz.getLocation('Asia/Riyadh');
        final ts = tz.TZDateTime.from(
          tAppointment.fullDateTime,
          riyadhTimezone,
        );
        final slotId = 'doctor1_${ts.millisecondsSinceEpoch}';
        await fakeFirestore.collection('appointment_slots').doc(slotId).set({
          'occupied': true,
        });

        // 2. Try to book via transaction
        final result = await repository.bookAppointment(tAppointment);

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.message, contains('تم حجزه للتو')),
          (_) => fail('Should have failed'),
        );
      },
    );
  });
}
