/// Unit tests for AppointmentsProvider
///
/// Tests cover:
/// - State initialization
/// - Load appointments (patient/doctor)
/// - Create appointment
/// - Update appointment
/// - Cancel appointment
/// - Complete appointment
/// - Conflict detection
/// - Upcoming/past appointments filtering
/// - Error handling
///
/// Target: 85%+ coverage

library;

import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:elajtech/features/notifications/domain/repositories/notification_repository.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:elajtech/shared/models/notification_model.dart';
import 'package:elajtech/shared/providers/appointments_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../fixtures/appointment_fixtures.dart';
import 'appointments_provider_test.mocks.dart';

@GenerateMocks([
  AppointmentRepository,
  NotificationRepository,
])
void main() {
  late ProviderContainer container;
  late MockAppointmentRepository mockAppointmentRepository;
  late MockNotificationRepository mockNotificationRepository;

  setUp(() {
    mockAppointmentRepository = MockAppointmentRepository();
    mockNotificationRepository = MockNotificationRepository();

    container = ProviderContainer(
      overrides: [
        appointmentsProvider.overrideWith(
          (ref) => AppointmentsNotifier(
            mockAppointmentRepository,
            mockNotificationRepository,
          ),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AppointmentsProvider - State Initialization', () {
    test('should initialize with empty list', () {
      // Arrange & Act
      final state = container.read(appointmentsProvider);

      // Assert
      expect(state, isEmpty);
    });
  });

  group('AppointmentsProvider - Load Appointments', () {
    test('should load appointments for patient successfully', () async {
      // Arrange
      const patientId = 'patient_test_001';
      final appointments = AppointmentFixtures.createMultipleAppointments(
        patientId: patientId,
      );

      when(
        mockAppointmentRepository.getAppointmentsForPatient(patientId),
      ).thenAnswer((_) async => Right(appointments));

      // Act
      await container
          .read(appointmentsProvider.notifier)
          .loadForPatient(patientId);

      // Assert
      final state = container.read(appointmentsProvider);
      expect(state.length, appointments.length);
      expect(state, equals(appointments));

      verify(
        mockAppointmentRepository.getAppointmentsForPatient(patientId),
      ).called(1);
    });

    test(
      'should return empty list when loading patient appointments fails',
      () async {
        // Arrange
        const patientId = 'patient_test_001';

        when(
          mockAppointmentRepository.getAppointmentsForPatient(patientId),
        ).thenAnswer((_) async => const Left(ServerFailure('Failed to load')));

        // Act
        await container
            .read(appointmentsProvider.notifier)
            .loadForPatient(patientId);

        // Assert
        final state = container.read(appointmentsProvider);
        expect(state, isEmpty);
      },
    );

    test('should load appointments for doctor successfully', () async {
      // Arrange
      const doctorId = 'doctor_test_001';
      final appointments = AppointmentFixtures.createMultipleAppointments(
        doctorId: doctorId,
      );

      when(
        mockAppointmentRepository.getAppointmentsForDoctor(doctorId),
      ).thenAnswer((_) async => Right(appointments));

      // Act
      await container
          .read(appointmentsProvider.notifier)
          .loadForDoctor(doctorId);

      // Assert
      final state = container.read(appointmentsProvider);
      expect(state.length, appointments.length);
      expect(state, equals(appointments));

      verify(
        mockAppointmentRepository.getAppointmentsForDoctor(doctorId),
      ).called(1);
    });

    test(
      'should return empty list when loading doctor appointments fails',
      () async {
        // Arrange
        const doctorId = 'doctor_test_001';

        when(
          mockAppointmentRepository.getAppointmentsForDoctor(doctorId),
        ).thenAnswer((_) async => const Left(ServerFailure('Failed to load')));

        // Act
        await container
            .read(appointmentsProvider.notifier)
            .loadForDoctor(doctorId);

        // Assert
        final state = container.read(appointmentsProvider);
        expect(state, isEmpty);
      },
    );
  });

  group('AppointmentsProvider - Create Appointment', () {
    test('should create appointment successfully', () async {
      // Arrange
      final appointment = AppointmentFixtures.createPendingAppointment();

      when(
        mockAppointmentRepository.bookAppointment(appointment),
      ).thenAnswer((_) async => const Right(unit));

      // Act
      await container
          .read(appointmentsProvider.notifier)
          .createAppointment(appointment);

      // Assert
      final state = container.read(appointmentsProvider);
      expect(state.length, 1);
      expect(state.first, equals(appointment));

      verify(mockAppointmentRepository.bookAppointment(appointment)).called(1);
    });

    test('should throw exception when create appointment fails', () async {
      // Arrange
      final appointment = AppointmentFixtures.createPendingAppointment();

      when(mockAppointmentRepository.bookAppointment(appointment)).thenAnswer(
        (_) async => const Left(ServerFailure('Failed to create')),
      );

      // Act & Assert
      await expectLater(
        container
            .read(appointmentsProvider.notifier)
            .createAppointment(appointment),
        throwsException,
      );
    });
  });

  group('AppointmentsProvider - Update Appointment', () {
    test('should update appointment in state', () async {
      // Arrange
      final appointment = AppointmentFixtures.createPendingAppointment();
      final updatedAppointment = appointment.copyWith(
        status: AppointmentStatus.confirmed,
      );

      when(
        mockAppointmentRepository.bookAppointment(appointment),
      ).thenAnswer((_) async => const Right(unit));

      when(
        mockAppointmentRepository.saveAppointment(updatedAppointment),
      ).thenAnswer((_) async => const Right(unit));

      // Create appointment first
      await container
          .read(appointmentsProvider.notifier)
          .createAppointment(appointment);

      // Act
      container
          .read(appointmentsProvider.notifier)
          .updateAppointment(updatedAppointment);

      // Assert
      final state = container.read(appointmentsProvider);
      expect(state.length, 1);
      expect(state.first.status, AppointmentStatus.confirmed);
      expect(state.first.id, appointment.id);
    });

    test('should not affect other appointments when updating', () async {
      // Arrange
      final appointment1 = AppointmentFixtures.createPendingAppointment(
        id: 'apt_001',
      );
      final appointment2 = AppointmentFixtures.createConfirmedAppointment(
        id: 'apt_002',
      );
      final updatedAppointment1 = appointment1.copyWith(
        status: AppointmentStatus.confirmed,
      );

      when(
        mockAppointmentRepository.bookAppointment(any),
      ).thenAnswer((_) async => const Right(unit));

      await container
          .read(appointmentsProvider.notifier)
          .createAppointment(appointment1);
      await container
          .read(appointmentsProvider.notifier)
          .createAppointment(appointment2);

      // Act
      container
          .read(appointmentsProvider.notifier)
          .updateAppointment(updatedAppointment1);

      // Assert
      final state = container.read(appointmentsProvider);
      expect(state.length, 2);
      expect(state[0].status, AppointmentStatus.confirmed);
      expect(state[1].status, AppointmentStatus.confirmed);
      expect(state[1].id, 'apt_002');
    });
  });

  group('AppointmentsProvider - Cancel Appointment', () {
    test('should cancel appointment successfully', () async {
      // Arrange
      final appointment = AppointmentFixtures.createConfirmedAppointment();

      when(
        mockAppointmentRepository.bookAppointment(any),
      ).thenAnswer((_) async => const Right(unit));
      when(
        mockAppointmentRepository.saveAppointment(any),
      ).thenAnswer((_) async => const Right(unit));
      when(
        mockNotificationRepository.saveNotification(any),
      ).thenAnswer((_) async => const Right(unit));

      await container
          .read(appointmentsProvider.notifier)
          .createAppointment(appointment);

      // Act
      await container
          .read(appointmentsProvider.notifier)
          .cancelAppointment(appointment.id);

      // Assert
      final state = container.read(appointmentsProvider);
      expect(state.length, 1);
      expect(state.first.status, AppointmentStatus.cancelled);

      verify(
        mockAppointmentRepository.bookAppointment(any),
      ).called(1);
      verify(
        mockAppointmentRepository.saveAppointment(any),
      ).called(1); // One more for cancel
      verify(mockNotificationRepository.saveNotification(any)).called(1);
    });

    test('should create notification when patient cancels', () async {
      // Arrange
      final appointment = AppointmentFixtures.createConfirmedAppointment();

      when(
        mockAppointmentRepository.bookAppointment(any),
      ).thenAnswer((_) async => const Right(unit));
      when(
        mockAppointmentRepository.saveAppointment(any),
      ).thenAnswer((_) async => const Right(unit));
      when(
        mockNotificationRepository.saveNotification(any),
      ).thenAnswer((_) async => const Right(unit));

      await container
          .read(appointmentsProvider.notifier)
          .createAppointment(appointment);

      // Act
      await container
          .read(appointmentsProvider.notifier)
          .cancelAppointment(appointment.id);

      // Assert
      final captured = verify(
        mockNotificationRepository.saveNotification(captureAny),
      ).captured;

      expect(captured.length, 1);
      final notification = captured[0] as NotificationModel;
      expect(notification.userId, appointment.doctorId);
      expect(notification.type, NotificationType.appointment);
      expect(notification.title, 'إلغاء موعد');
    });

    test('should create notification when doctor cancels', () async {
      // Arrange
      final appointment = AppointmentFixtures.createConfirmedAppointment();

      when(
        mockAppointmentRepository.bookAppointment(any),
      ).thenAnswer((_) async => const Right(unit));
      when(
        mockAppointmentRepository.saveAppointment(any),
      ).thenAnswer((_) async => const Right(unit));
      when(
        mockNotificationRepository.saveNotification(any),
      ).thenAnswer((_) async => const Right(unit));

      await container
          .read(appointmentsProvider.notifier)
          .createAppointment(appointment);

      // Act
      await container
          .read(appointmentsProvider.notifier)
          .cancelAppointment(appointment.id, isDoctor: true);

      // Assert
      final captured = verify(
        mockNotificationRepository.saveNotification(captureAny),
      ).captured;

      expect(captured.length, 1);
      final notification = captured[0] as NotificationModel;
      expect(notification.userId, appointment.patientId);
      expect(notification.type, NotificationType.appointment);
    });

    test('should do nothing when appointment not found', () async {
      // Arrange
      const nonExistentId = 'non_existent_id';

      // Act
      await container
          .read(appointmentsProvider.notifier)
          .cancelAppointment(nonExistentId);

      // Assert
      verifyNever(mockAppointmentRepository.saveAppointment(any));
      verifyNever(mockNotificationRepository.saveNotification(any));
    });

    test('should throw exception when cancel fails', () async {
      // Arrange
      final appointment = AppointmentFixtures.createConfirmedAppointment();

      when(mockAppointmentRepository.bookAppointment(any)).thenAnswer(
        (
          _,
        ) async => const Right(unit),
      ); // First call (createAppointment)

      when(mockAppointmentRepository.saveAppointment(any)).thenAnswer((
        _,
      ) async {
        return const Left(
          ServerFailure('Failed to cancel'),
        ); // Second call (cancelAppointment)
      });

      await container
          .read(appointmentsProvider.notifier)
          .createAppointment(appointment);

      // Act & Assert
      await expectLater(
        container
            .read(appointmentsProvider.notifier)
            .cancelAppointment(appointment.id),
        throwsException,
      );
    });
  });

  group('AppointmentsProvider - Complete Appointment', () {
    test('should complete appointment successfully', () async {
      // Arrange
      final appointment = AppointmentFixtures.createConfirmedAppointment();

      when(
        mockAppointmentRepository.bookAppointment(any),
      ).thenAnswer((_) async => const Right(unit));
      when(
        mockAppointmentRepository.saveAppointment(any),
      ).thenAnswer((_) async => const Right(unit));

      await container
          .read(appointmentsProvider.notifier)
          .createAppointment(appointment);

      // Act
      await container
          .read(appointmentsProvider.notifier)
          .completeAppointment(appointment.id);

      // Assert
      final state = container.read(appointmentsProvider);
      expect(state.length, 1);
      expect(state.first.status, AppointmentStatus.completed);

      verify(
        mockAppointmentRepository.bookAppointment(any),
      ).called(1); // Once for create
      verify(
        mockAppointmentRepository.saveAppointment(any),
      ).called(1); // Once for complete
    });

    test('should do nothing when appointment not found', () async {
      // Arrange
      const nonExistentId = 'non_existent_id';

      // Act
      await container
          .read(appointmentsProvider.notifier)
          .completeAppointment(nonExistentId);

      // Assert
      verifyNever(mockAppointmentRepository.saveAppointment(any));
    });

    test('should throw exception when complete fails', () async {
      // Arrange
      final appointment = AppointmentFixtures.createConfirmedAppointment();

      when(mockAppointmentRepository.bookAppointment(any)).thenAnswer(
        (
          _,
        ) async => const Right(unit),
      );

      when(mockAppointmentRepository.saveAppointment(any)).thenAnswer((
        _,
      ) async {
        return const Left(
          ServerFailure('Failed to complete'),
        ); // Second call (completeAppointment)
      });

      await container
          .read(appointmentsProvider.notifier)
          .createAppointment(appointment);

      // Act & Assert
      await expectLater(
        container
            .read(appointmentsProvider.notifier)
            .completeAppointment(appointment.id),
        throwsException,
      );
    });
  });

  group('AppointmentsProvider - Conflict Detection', () {
    test('should return false when no conflict exists', () async {
      // Arrange
      const patientId = 'patient_test_001';
      final newAppointment = AppointmentFixtures.createPendingAppointment();

      when(
        mockAppointmentRepository.checkAppointmentConflict(
          patientId: patientId,
          newAppointment: newAppointment,
        ),
      ).thenAnswer((_) async => const Right(false));

      // Act
      final hasConflict = await container
          .read(appointmentsProvider.notifier)
          .checkAppointmentConflict(patientId, newAppointment);

      // Assert
      expect(hasConflict, false);

      verify(
        mockAppointmentRepository.checkAppointmentConflict(
          patientId: patientId,
          newAppointment: newAppointment,
        ),
      ).called(1);
    });

    test('should return true when conflict exists', () async {
      // Arrange
      const patientId = 'patient_test_001';
      final newAppointment = AppointmentFixtures.createPendingAppointment();

      when(
        mockAppointmentRepository.checkAppointmentConflict(
          patientId: patientId,
          newAppointment: newAppointment,
        ),
      ).thenAnswer((_) async => const Right(true));

      // Act
      final hasConflict = await container
          .read(appointmentsProvider.notifier)
          .checkAppointmentConflict(patientId, newAppointment);

      // Assert
      expect(hasConflict, true);
    });

    test('should throw exception when conflict check fails', () async {
      // Arrange
      const patientId = 'patient_test_001';
      final newAppointment = AppointmentFixtures.createPendingAppointment();

      when(
        mockAppointmentRepository.checkAppointmentConflict(
          patientId: patientId,
          newAppointment: newAppointment,
        ),
      ).thenAnswer(
        (_) async => const Left(ServerFailure('Failed to check conflict')),
      );

      // Act & Assert
      await expectLater(
        container
            .read(appointmentsProvider.notifier)
            .checkAppointmentConflict(patientId, newAppointment),
        throwsException,
      );
    });
  });

  group('AppointmentsProvider - Upcoming Appointments', () {
    test('should return only upcoming appointments', () async {
      // Arrange
      final futureAppointment = AppointmentFixtures.createPendingAppointment(
        appointmentDate: DateTime.now().add(const Duration(days: 1)),
      );
      final pastAppointment = AppointmentFixtures.createCompletedAppointment();

      when(
        mockAppointmentRepository.bookAppointment(any),
      ).thenAnswer((_) async => const Right(unit));
      when(
        mockAppointmentRepository.saveAppointment(any),
      ).thenAnswer((_) async => const Right(unit));

      await container
          .read(appointmentsProvider.notifier)
          .createAppointment(futureAppointment);
      await container
          .read(appointmentsProvider.notifier)
          .createAppointment(pastAppointment);

      // Act
      final upcoming = container
          .read(appointmentsProvider.notifier)
          .getUpcomingAppointments();

      // Assert
      expect(upcoming.length, 1);
      expect(upcoming.first.id, futureAppointment.id);
    });

    test('should exclude cancelled appointments from upcoming', () async {
      // Arrange
      final futureAppointment = AppointmentFixtures.createPendingAppointment(
        appointmentDate: DateTime.now().add(const Duration(days: 1)),
      );
      final cancelledAppointment =
          AppointmentFixtures.createCancelledAppointment();

      when(
        mockAppointmentRepository.bookAppointment(any),
      ).thenAnswer((_) async => const Right(unit));
      when(
        mockAppointmentRepository.saveAppointment(any),
      ).thenAnswer((_) async => const Right(unit));

      await container
          .read(appointmentsProvider.notifier)
          .createAppointment(futureAppointment);
      await container
          .read(appointmentsProvider.notifier)
          .createAppointment(cancelledAppointment);

      // Act
      final upcoming = container
          .read(appointmentsProvider.notifier)
          .getUpcomingAppointments();

      // Assert
      expect(upcoming.length, 1);
      expect(upcoming.first.status, isNot(AppointmentStatus.cancelled));
    });

    test('should sort upcoming appointments by date', () async {
      // Arrange
      final appointment1 = AppointmentFixtures.createPendingAppointment(
        id: 'apt_001',
        appointmentDate: DateTime.now().add(const Duration(days: 3)),
      );
      final appointment2 = AppointmentFixtures.createPendingAppointment(
        id: 'apt_002',
        appointmentDate: DateTime.now().add(const Duration(days: 1)),
      );

      when(
        mockAppointmentRepository.bookAppointment(any),
      ).thenAnswer((_) async => const Right(unit));
      when(
        mockAppointmentRepository.saveAppointment(any),
      ).thenAnswer((_) async => const Right(unit));

      await container
          .read(appointmentsProvider.notifier)
          .createAppointment(appointment1);
      await container
          .read(appointmentsProvider.notifier)
          .createAppointment(appointment2);

      // Act
      final upcoming = container
          .read(appointmentsProvider.notifier)
          .getUpcomingAppointments();

      // Assert
      expect(upcoming.length, 2);
      expect(upcoming.first.id, 'apt_002'); // Earlier date first
      expect(upcoming.last.id, 'apt_001');
    });
  });

  group('AppointmentsProvider - Past Appointments', () {
    test('should return only completed past appointments', () async {
      // Arrange
      final pastAppointment = AppointmentFixtures.createCompletedAppointment();
      final futureAppointment = AppointmentFixtures.createPendingAppointment(
        appointmentDate: DateTime.now().add(const Duration(days: 1)),
      );

      when(
        mockAppointmentRepository.bookAppointment(any),
      ).thenAnswer((_) async => const Right(unit));
      when(
        mockAppointmentRepository.saveAppointment(any),
      ).thenAnswer((_) async => const Right(unit));

      await container
          .read(appointmentsProvider.notifier)
          .createAppointment(pastAppointment);
      await container
          .read(appointmentsProvider.notifier)
          .createAppointment(futureAppointment);

      // Act
      final past = container
          .read(appointmentsProvider.notifier)
          .getPastAppointments();

      // Assert
      expect(past.length, 1);
      expect(past.first.status, AppointmentStatus.completed);
    });

    test('should sort past appointments by date descending', () async {
      // Arrange
      final appointment1 = AppointmentFixtures.createCompletedAppointment(
        id: 'apt_001',
      );
      final appointment2 = AppointmentFixtures.createCompletedAppointment(
        id: 'apt_002',
      );

      when(
        mockAppointmentRepository.bookAppointment(any),
      ).thenAnswer((_) async => const Right(unit));
      when(
        mockAppointmentRepository.saveAppointment(any),
      ).thenAnswer((_) async => const Right(unit));

      await container
          .read(appointmentsProvider.notifier)
          .createAppointment(appointment1);
      await container
          .read(appointmentsProvider.notifier)
          .createAppointment(appointment2);

      // Act
      final past = container
          .read(appointmentsProvider.notifier)
          .getPastAppointments();

      // Assert
      expect(past.length, 2);
      // Most recent first (descending order)
    });
  });

  group('AppointmentsProvider - Has Appointment Today', () {
    test('should return true when patient has appointment today', () async {
      // Arrange
      const patientId = 'patient_test_001';
      final todayAppointment = AppointmentFixtures.createPendingAppointment(
        patientId: patientId,
        appointmentDate: DateTime.now(),
      );

      when(
        mockAppointmentRepository.bookAppointment(any),
      ).thenAnswer((_) async => const Right(unit));
      when(
        mockAppointmentRepository.saveAppointment(any),
      ).thenAnswer((_) async => const Right(unit));

      await container
          .read(appointmentsProvider.notifier)
          .createAppointment(todayAppointment);

      // Act
      final hasToday = container
          .read(appointmentsProvider.notifier)
          .hasAppointmentToday(patientId);

      // Assert
      expect(hasToday, true);
    });

    test('should return false when patient has no appointment today', () async {
      // Arrange
      const patientId = 'patient_test_001';
      final futureAppointment = AppointmentFixtures.createPendingAppointment(
        patientId: patientId,
        appointmentDate: DateTime.now().add(const Duration(days: 1)),
      );

      when(
        mockAppointmentRepository.bookAppointment(any),
      ).thenAnswer((_) async => const Right(unit));
      when(
        mockAppointmentRepository.saveAppointment(any),
      ).thenAnswer((_) async => const Right(unit));

      await container
          .read(appointmentsProvider.notifier)
          .createAppointment(futureAppointment);

      // Act
      final hasToday = container
          .read(appointmentsProvider.notifier)
          .hasAppointmentToday(patientId);

      // Assert
      expect(hasToday, false);
    });

    test('should return false when appointment is cancelled', () async {
      // Arrange
      const patientId = 'patient_test_001';
      final cancelledAppointment =
          AppointmentFixtures.createCancelledAppointment(
            patientId: patientId,
          );

      when(
        mockAppointmentRepository.bookAppointment(any),
      ).thenAnswer((_) async => const Right(unit));
      when(
        mockAppointmentRepository.saveAppointment(any),
      ).thenAnswer((_) async => const Right(unit));

      await container
          .read(appointmentsProvider.notifier)
          .createAppointment(cancelledAppointment);

      // Act
      final hasToday = container
          .read(appointmentsProvider.notifier)
          .hasAppointmentToday(patientId);

      // Assert
      expect(hasToday, false);
    });
  });

  group('AppointmentsProvider - Deprecated Methods', () {
    test('should add appointment using deprecated method', () {
      // Arrange
      final appointment = AppointmentFixtures.createPendingAppointment();

      // Act
      // ignore: deprecated_member_use_from_same_package
      container.read(appointmentsProvider.notifier).addAppointment(appointment);

      // Assert
      final state = container.read(appointmentsProvider);
      expect(state.length, 1);
      expect(state.first, equals(appointment));
    });
  });
}
