import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/core/services/call_monitoring_service.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:elajtech/shared/providers/appointments_provider.dart';

/// Bottom sheet for rescheduling a pending or confirmed appointment.
///
/// Shows a date picker (today → today + 90 days) and then a grid of available
/// time slots for the same doctor on the selected date. On confirm:
/// 1. Validates no conflict via appointmentsProvider.checkAppointmentConflict.
/// 2. Calls appointmentsProvider.rescheduleAppointment.
/// 3. Invokes [onRescheduled] with the new [DateTime] and closes.
///
/// Logs [CallMonitoringService.logRescheduleSubmitted] with outcome
/// `"confirmed"` / `"conflict"` / `"failed"` before returning.
class RescheduleAppointmentSheet extends ConsumerStatefulWidget {
  const RescheduleAppointmentSheet({
    required this.appointment,
    required this.onRescheduled,
    super.key,
  });

  final AppointmentModel appointment;
  final void Function(DateTime newDateTime) onRescheduled;

  @override
  ConsumerState<RescheduleAppointmentSheet> createState() =>
      _RescheduleAppointmentSheetState();
}

class _RescheduleAppointmentSheetState
    extends ConsumerState<RescheduleAppointmentSheet> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedSlot;
  bool _isConfirming = false;
  bool _isLoadingSlots = true;
  String? _conflictError;
  String? _loadError;
  List<TimeSlot> _availableSlots = const [];

  static const _maxDaysAhead = 90;

  @override
  void initState() {
    super.initState();
    unawaited(_loadSlots());
  }

  Future<void> _loadSlots() async {
    setState(() {
      _isLoadingSlots = true;
      _loadError = null;
      _selectedSlot = null;
      _conflictError = null;
    });

    try {
      final slots = await ref
          .read(appointmentsProvider.notifier)
          .getAvailableSlotsForDoctor(
            appointment: widget.appointment,
            date: _selectedDate,
          );

      if (!mounted) return;
      setState(() {
        _availableSlots = slots;
        _isLoadingSlots = false;
      });
    } on Exception catch (_) {
      if (!mounted) return;
      setState(() {
        _availableSlots = const [];
        _isLoadingSlots = false;
        _loadError = 'تعذر تحميل المواعيد المتاحة، حاول مرة أخرى';
      });
    }
  }

  Future<void> _confirm() async {
    final slot = _selectedSlot;
    if (slot == null) return;

    final user = ref.read(authProvider).user;
    final originalDt = widget.appointment.fullDateTime;
    final newDt = widget.appointment
        .copyWith(
          appointmentDate: _selectedDate,
          timeSlot: slot,
        )
        .fullDateTime;

    setState(() {
      _isConfirming = true;
      _conflictError = null;
    });

    try {
      final rescheduled = widget.appointment.copyWith(
        appointmentDate: _selectedDate,
        timeSlot: slot,
      );

      var hasConflict = false;
      if (user != null) {
        hasConflict = await ref
            .read(appointmentsProvider.notifier)
            .checkAppointmentConflict(user.id, rescheduled);
      }

      if (hasConflict) {
        if (!mounted) return;
        await _loadSlots();
        if (!mounted) return;
        setState(() => _conflictError = 'هذا الموعد محجوز، اختر وقتاً آخر');
        unawaited(
          getIt<CallMonitoringService>().logRescheduleSubmitted(
            appointmentId: widget.appointment.id,
            userId: user?.id ?? '',
            originalDateTime: originalDt,
            newDateTime: newDt,
            outcome: 'conflict',
          ),
        );
        return;
      }

      await ref
          .read(appointmentsProvider.notifier)
          .rescheduleAppointment(rescheduled);

      unawaited(
        getIt<CallMonitoringService>().logRescheduleSubmitted(
          appointmentId: widget.appointment.id,
          userId: user?.id ?? '',
          originalDateTime: originalDt,
          newDateTime: newDt,
          outcome: 'confirmed',
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onRescheduled(newDt);
    } on Exception catch (_) {
      if (!mounted) return;
      final user2 = ref.read(authProvider).user;
      unawaited(
        getIt<CallMonitoringService>().logRescheduleSubmitted(
          appointmentId: widget.appointment.id,
          userId: user2?.id ?? '',
          originalDateTime: originalDt,
          newDateTime: newDt,
          outcome: 'failed',
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر إعادة الجدولة، يرجى المحاولة لاحقاً'),
          backgroundColor: AppColors.error,
        ),
      );
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final lastSelectableDate = today.add(const Duration(days: _maxDaysAhead));
    final slots = _availableSlots;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            // ── Drag handle ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Title ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'إعادة جدولة الموعد',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'الطبيب: ${widget.appointment.doctorName}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

            const Divider(height: 24),

            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // ── Calendar ───────────────────────────────────────────────
                  CalendarDatePicker(
                    initialDate: _selectedDate,
                    firstDate: today,
                    lastDate: lastSelectableDate,
                    onDateChanged: (date) {
                      setState(() => _selectedDate = date);
                      unawaited(_loadSlots());
                    },
                  ),

                  const SizedBox(height: 16),
                  Text(
                    'اختر وقتاً',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),

                  // ── Slot grid ──────────────────────────────────────────────
                  if (_isLoadingSlots)
                    const Center(child: CircularProgressIndicator())
                  else if (_loadError != null)
                    Center(
                      child: Column(
                        children: [
                          Text(_loadError!),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () => unawaited(_loadSlots()),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    )
                  else if (slots.where((slot) => slot.isAvailable).isEmpty)
                    const Center(
                      child: Text('لا توجد مواعيد متاحة لهذا الطبيب حالياً'),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: slots.length,
                      itemBuilder: (_, index) {
                        final slot = slots[index];
                        final isSelected = _selectedSlot == slot.time;
                        return GestureDetector(
                          onTap: slot.isAvailable
                              ? () => setState(() {
                                  _selectedSlot = slot.time;
                                  _conflictError = null;
                                })
                              : null,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: !slot.isAvailable
                                  ? Colors.grey.shade100
                                  : isSelected
                                  ? AppColors.primary
                                  : AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              slot.time,
                              style: TextStyle(
                                fontSize: 12,
                                color: !slot.isAvailable
                                    ? Colors.grey.shade400
                                    : isSelected
                                    ? Colors.white
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  // ── Conflict error ─────────────────────────────────────────
                  if (_conflictError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _conflictError!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ── Confirm button ─────────────────────────────────────────
                  Semantics(
                    button: true,
                    label: 'تأكيد إعادة الجدولة',
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: (_selectedSlot == null || _isConfirming)
                            ? null
                            : _confirm,
                        child: _isConfirming
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('تأكيد إعادة الجدولة'),
                      ),
                    ),
                  ),

                  // Bottom safe-area spacing so the button is never hidden
                  // behind the system navigation bar or keyboard.
                  SizedBox(
                    height: 24 +
                        MediaQuery.of(context).padding.bottom,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
