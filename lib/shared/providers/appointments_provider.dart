import 'package:elajtech/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:elajtech/features/notifications/domain/repositories/notification_repository.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:elajtech/shared/models/notification_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

/// Appointments State Notifier - إدارة حالة المواعيد
class AppointmentsNotifier extends StateNotifier<List<AppointmentModel>> {
  AppointmentsNotifier(this._repository, this._notificationRepository)
    : super([]);
  final AppointmentRepository _repository;
  final NotificationRepository _notificationRepository; // Start with empty list

  /// Load appointments for patient
  ///
  /// Returns `true` on success, `false` on failure.
  /// Callers that use `unawaited(...)` are unaffected by the new return type.
  Future<bool> loadForPatient(String patientId) async {
    final result = await _repository.getAppointmentsForPatient(patientId);
    return result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint(
            '❌ [AppointmentsProvider] loadForPatient failed: ${failure.message}',
          );
        }
        return false;
      },
      (appointments) {
        state = appointments;
        return true;
      },
    );
  }

  /// Load appointments for doctor
  Future<void> loadForDoctor(String doctorId) async {
    final result = await _repository.getAppointmentsForDoctor(doctorId);
    state = result.fold(
      (failure) => [],
      (appointments) => appointments,
    );
  }

  /// Check Appointment Conflict
  Future<bool> checkAppointmentConflict(
    String patientId,
    AppointmentModel newAppointment,
  ) async {
    final result = await _repository.checkAppointmentConflict(
      patientId: patientId,
      newAppointment: newAppointment,
    );

    return result.fold(
      (failure) {
        // In case of error, we might want to be conservative and assume conflict,
        // or throw exception. For now, let's log and return true (block booking)
        // or rethrow to let UI handle it.
        // Given the UI expects a boolean, let's throw so UI can show error.
        throw Exception(failure.message);
      },
      (hasConflict) => hasConflict,
    );
  }

  /// Add new appointment - إضافة موعد جديد
  @Deprecated('Use createAppointment instead')
  void addAppointment(AppointmentModel appointment) {
    state = [...state, appointment];
  }

  /// Create new appointment
  Future<void> createAppointment(AppointmentModel appointment) async {
    final result = await _repository.bookAppointment(appointment);
    result.fold(
      (failure) {
        // Handle failure - maybe throw or expose error state
        throw Exception(failure.message);
      },
      (_) {
        state = [...state, appointment];
      },
    );
  }

  /// Update appointment - تحديث موعد
  void updateAppointment(AppointmentModel updatedAppointment) {
    state = [
      for (final appointment in state)
        if (appointment.id == updatedAppointment.id)
          updatedAppointment
        else
          appointment,
    ];
  }

  /// Reschedule appointment - تأجيل موعد
  Future<void> rescheduleAppointment(
    AppointmentModel updatedAppointment,
  ) async {
    final appointmentIndex = state.indexWhere(
      (apt) => apt.id == updatedAppointment.id,
    );
    if (appointmentIndex == -1) return;

    try {
      // Update Firestore
      final result = await _repository.saveAppointment(updatedAppointment);

      result.fold(
        (failure) => throw Exception(failure.message),
        (_) {
          // Update Local State
          state = [
            for (final apt in state)
              if (apt.id == updatedAppointment.id) updatedAppointment else apt,
          ];
        },
      );
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<List<TimeSlot>> getAvailableSlotsForDoctor({
    required AppointmentModel appointment,
    required DateTime date,
  }) async {
    final result = await _repository.getDoctorAppointmentsViaCloudFunction(
      doctorId: appointment.doctorId,
      date: date,
    );
    final rawAppointments = result.fold(
      (failure) => throw Exception(failure.message),
      (data) => data,
    );

    final normalizedDate = DateTime(date.year, date.month, date.day);
    final now = DateTime.now();
    final unavailableTimes = rawAppointments
        .where((item) => item['id'] != appointment.id)
        .where((item) {
          final status = item['status'] as String? ?? '';
          return status != 'cancelled' &&
              status != 'completed' &&
              status != 'notCompleted' &&
              status != 'declined';
        })
        .map((item) => item['timeSlot'] as String? ?? '')
        .where((time) => time.isNotEmpty)
        .toSet();

    final slots = <TimeSlot>[];
    var current = DateTime(date.year, date.month, date.day, 8);
    final end = DateTime(date.year, date.month, date.day, 20);

    while (current.isBefore(end)) {
      final hour = current.hour;
      final minute = current.minute;
      final label = hour < 12
          ? '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} ص'
          : hour == 12
          ? '12:${minute.toString().padLeft(2, '0')} م'
          : '${(hour - 12).toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} م';

      slots.add(
        TimeSlot(
          time: label,
          isAvailable:
              current.isAfter(now) &&
              current != appointment.fullDateTime &&
              !unavailableTimes.contains(label),
          slotId:
              '${appointment.doctorId}_${DateTime(date.year, date.month, date.day, current.hour, current.minute).millisecondsSinceEpoch}',
        ),
      );

      current = current.add(const Duration(minutes: 30));
    }

    if (kDebugMode) {
      debugPrint(
        '📅 [AppointmentsProvider] Loaded slots for doctor=${appointment.doctorId} date=$normalizedDate available=${slots.where((slot) => slot.isAvailable).length}',
      );
    }

    return slots;
  }

  /// Cancel appointment - إلغاء موعد
  Future<void> cancelAppointment(
    String appointmentId, {
    bool isDoctor = false,
  }) async {
    // Find the appointment
    final appointmentIndex = state.indexWhere((apt) => apt.id == appointmentId);
    if (appointmentIndex == -1) return;

    final appointment = state[appointmentIndex];
    final updatedAppointment = appointment.copyWith(
      status: AppointmentStatus.cancelled,
    );

    try {
      // Update Firestore
      final result = await _repository.saveAppointment(updatedAppointment);

      await result.fold((failure) => throw Exception(failure.message), (
        _,
      ) async {
        // Create Notification
        // If doctor cancelled -> notify patient
        // If patient cancelled -> notify doctor
        final targetUserId = isDoctor
            ? appointment.patientId
            : appointment.doctorId;
        final body = isDoctor
            ? 'قام د. ${appointment.doctorName} بإلغاء الموعد المقرر في ${appointment.timeSlot}'
            : 'قام المريض ${appointment.patientName} بإلغاء الموعد المقرر في ${appointment.timeSlot}';

        final notification = NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: targetUserId,
          title: 'إلغاء موعد',
          body: body,
          type: NotificationType.appointment,
          createdAt: DateTime.now(),
          data: {'appointmentId': appointment.id},
        );

        await _notificationRepository.saveNotification(notification);

        // Update Local State
        state = [
          for (final apt in state)
            if (apt.id == appointmentId) updatedAppointment else apt,
        ];
      });
    } on Exception catch (_) {
      // Revert local state if needed or handle error
      // Ideally show error to user
      rethrow;
    }
  }

  /// Complete appointment - إكمال موعد
  Future<void> completeAppointment(String appointmentId) async {
    // Find the appointment
    final appointmentIndex = state.indexWhere((apt) => apt.id == appointmentId);
    if (appointmentIndex == -1) return;

    final appointment = state[appointmentIndex];
    final updatedAppointment = appointment.copyWith(
      status: AppointmentStatus.completed,
    );

    try {
      // Update Firestore
      final result = await _repository.saveAppointment(updatedAppointment);

      result.fold((failure) => throw Exception(failure.message), (_) {
        // Update Local State
        state = [
          for (final apt in state)
            if (apt.id == appointmentId) updatedAppointment else apt,
        ];
      });
    } on Exception catch (_) {
      rethrow;
    }
  }

  /// Get upcoming appointments - الحصول على المواعيد القادمة
  List<AppointmentModel> getUpcomingAppointments() => state.where((apt) {
    // Use fullDateTime to handle specific time slots correctly
    final isFuture = apt.fullDateTime.isAfter(
      DateTime.now().subtract(
        const Duration(minutes: 15),
      ), // Show until 15 mins after start
    );
    return apt.status != AppointmentStatus.cancelled &&
        apt.status != AppointmentStatus.completed &&
        isFuture;
  }).toList()..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

  /// Get past appointments - الحصول على المواعيد السابقة
  List<AppointmentModel> getPastAppointments() =>
      state
          .where(
            (apt) =>
                apt.status == AppointmentStatus.completed &&
                apt.appointmentDate.isBefore(DateTime.now()),
          )
          .toList()
        ..sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));

  /// Check if doctor has appointment with patient today
  bool hasAppointmentToday(String patientId) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return state.any((apt) {
      if (apt.patientId != patientId) return false;
      if (apt.status == AppointmentStatus.cancelled) return false;

      return apt.appointmentDate.isAfter(todayStart) &&
              apt.appointmentDate.isBefore(todayEnd) ||
          apt.appointmentDate.isAtSameMomentAs(todayStart);
    });
  }
}

/// Appointments Provider - مزود المواعيد
final appointmentsProvider =
    StateNotifierProvider<AppointmentsNotifier, List<AppointmentModel>>(
      (ref) => AppointmentsNotifier(
        GetIt.I<AppointmentRepository>(),
        GetIt.I<NotificationRepository>(),
      ),
    );

/// Upcoming Appointments Provider - مزود المواعيد القادمة
final upcomingAppointmentsProvider = Provider<List<AppointmentModel>>((ref) {
  final notifier = ref.watch(appointmentsProvider.notifier);
  ref.watch(appointmentsProvider); // Watch for changes
  return notifier.getUpcomingAppointments();
});

/// Past Appointments Provider - مزود المواعيد السابقة
final pastAppointmentsProvider = Provider<List<AppointmentModel>>((ref) {
  final notifier = ref.watch(appointmentsProvider.notifier);
  ref.watch(appointmentsProvider); // Watch for changes
  return notifier.getPastAppointments();
});

/// مزود مراقبة مواعيد المريض في الوقت الفعلي
/// Real-time stream provider for patient appointments.
///
/// Listens to Firestore snapshots so the patient's appointments tab
/// automatically reflects changes made by the doctor (e.g. starting a call
/// updates status to 'calling', sets agoraToken / callStartedAt).
///
/// Usage:
/// ```dart
/// final appointmentsAsync = ref.watch(patientAppointmentsStreamProvider(patientId));
/// appointmentsAsync.when(data: ..., loading: ..., error: ...);
/// ```
final AutoDisposeStreamProviderFamily<List<AppointmentModel>, String>
    patientAppointmentsStreamProvider = StreamProvider.autoDispose
        .family<List<AppointmentModel>, String>(
  (ref, patientId) =>
      GetIt.I<AppointmentRepository>().watchAppointmentsForPatient(patientId),
);
