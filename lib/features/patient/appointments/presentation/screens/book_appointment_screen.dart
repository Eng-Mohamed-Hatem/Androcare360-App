import 'dart:async';

import 'package:elajtech/core/constants/app_colors.dart';
// import 'package:elajtech/core/services/firestore_service.dart'; // Unused
import 'package:elajtech/core/services/assessment_referral_tracking_service.dart';
import 'package:elajtech/core/services/notification_service.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/patient/self_assessment/data/models/quiz_models.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:elajtech/shared/providers/appointments_provider.dart';
import 'package:elajtech/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

/// Book Appointment Screen - شاشة حجز الموعد
class BookAppointmentScreen extends ConsumerStatefulWidget {
  const BookAppointmentScreen({
    required this.doctor,
    required this.isVideoConsultation,
    super.key,
    this.referralContext,
  });
  final UserModel doctor;
  final bool isVideoConsultation;
  final AssessmentReferralContext? referralContext;

  @override
  ConsumerState<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String? _selectedTimeSlot;
  final _notesController = TextEditingController();
  bool _isLoading = false;
  late final AssessmentReferralTrackingService _trackingService;
  bool _bookingCompleted = false;

  @override
  void initState() {
    super.initState();
    _trackingService = AssessmentReferralTrackingService.maybeCreate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final referralContext = widget.referralContext;
      if (referralContext == null) {
        return;
      }

      unawaited(
        _trackingService.logEvent(
          context: referralContext,
          eventName: 'booking_viewed',
          stage: 'booking',
        ),
      );
    });
  }

  @override
  void dispose() {
    final referralContext = widget.referralContext;
    if (referralContext != null && !_bookingCompleted) {
      unawaited(
        _trackingService.logEvent(
          context: referralContext,
          eventName: 'referral_abandoned',
          stage: 'booking',
          status: 'abandoned',
        ),
      );
    }
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _confirmBooking() async {
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار وقت الموعد'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Get current user
    final authState = ref.read(authProvider);
    final currentUser = authState.user;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تسجيل الدخول أولاً'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create new appointment object for validation and saving
      final appointmentId = DateTime.now().millisecondsSinceEpoch.toString();
      final meetingLink = widget.isVideoConsultation
          ? 'pending' // ✅ سيُحدّث بواسطة generateMeetLink Cloud Function
          : null;

      final newAppointment = AppointmentModel(
        id: appointmentId,
        patientId: currentUser.id,
        patientName: currentUser.fullName,
        patientPhone: currentUser.phoneNumber ?? 'غير متوفر',
        doctorId: widget.doctor.id,
        doctorName: widget.doctor.fullName,
        specialization: widget.doctor.specializations?.first ?? 'عام',
        appointmentDate: _selectedDate,
        timeSlot: _selectedTimeSlot!,
        type: widget.isVideoConsultation
            ? AppointmentType.video
            : AppointmentType.clinic,
        status: AppointmentStatus.pending,
        fee: widget.doctor.consultationFee ?? 200.0,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        meetingLink:
            meetingLink, // Server-side generation via Cloud Function (Agora)
        createdAt: DateTime.now(),
        bookingSource: widget.referralContext != null
            ? 'assessment_referral'
            : 'direct_booking',
        assessmentId: widget.referralContext?.assessmentId,
        assessmentResultBand: widget.referralContext?.resultBand,
        referralTargetKey: widget.referralContext?.referralTargetKey,
      );

      // Check for conflicts with existing appointments (Server-side check)
      final hasConflict = await ref
          .read(appointmentsProvider.notifier)
          .checkAppointmentConflict(currentUser.id, newAppointment);

      if (hasConflict) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'عذراً، لا يمكن إتمام الحجز لوجود تعارض مع موعد آخر في نفس التوقيت. يرجى اختيار وقت مختلف.',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Create and Save Appointment via Provider
      await ref
          .read(appointmentsProvider.notifier)
          .createAppointment(newAppointment);

      if (widget.referralContext != null) {
        _bookingCompleted = true;
        await _trackingService.logEvent(
          context: widget.referralContext!,
          eventName: 'booking_completed',
          stage: 'booking',
          status: 'completed',
          metadata: {'appointmentId': newAppointment.id},
        );
      }

      // Schedule Notification (2 hours before)
      try {
        final timeParts = _selectedTimeSlot!.split(' ');
        final clockParts = timeParts[0].split(':');
        var hour = int.parse(clockParts[0]);
        final minute = int.parse(clockParts[1]);
        final period = timeParts[1];

        if (period == 'م' && hour != 12) hour += 12;
        if (period == 'ص' && hour == 12) hour = 0;

        final appointmentDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          hour,
          minute,
        );

        final reminderTime = appointmentDateTime.subtract(
          const Duration(minutes: 30),
        );

        await NotificationService().scheduleNotification(
          id: newAppointment.id.hashCode,
          title: 'تذكير بموعد',
          body:
              'لديك موعد مع د. ${widget.doctor.fullName} بعد 30 دقيقة في الساعة $_selectedTimeSlot',
          scheduledDate: reminderTime,
        );
      } on Exception catch (e) {
        debugPrint('Error scheduling notification: $e');
        // Non-critical error, continue
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حجز الموعد بنجاح!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate back to home
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ غير متوقع: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'إغلاق',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<TimeSlot> _generateTimeSlots(DateTime date) {
    // Weekday map
    final weekDays = {
      DateTime.sunday: 'الأحد',
      DateTime.monday: 'الاثنين',
      DateTime.tuesday: 'الثلاثاء',
      DateTime.wednesday: 'الأربعاء',
      DateTime.thursday: 'الخميس',
      DateTime.friday: 'الجمعة',
      DateTime.saturday: 'السبت',
    };

    final dayName = weekDays[date.weekday];
    final hours = widget.doctor.workingHours?[dayName];

    if (hours == null || hours.isEmpty) {
      return [];
    }

    final startParts = hours[0].split(':');
    final endParts = hours[1].split(':');

    final startHour = int.parse(startParts[0]);
    final startMinute = int.parse(startParts[1]);
    final endHour = int.parse(endParts[0]);
    final endMinute = int.parse(endParts[1]);

    final slots = <TimeSlot>[];
    var current = DateTime(
      date.year,
      date.month,
      date.day,
      startHour,
      startMinute,
    );
    final end = DateTime(date.year, date.month, date.day, endHour, endMinute);

    while (current.isBefore(end)) {
      final hourVal = current.hour;
      final minuteVal = current.minute.toString().padLeft(2, '0');
      final period = hourVal >= 12 ? 'م' : 'ص';
      final hour12 = hourVal > 12
          ? hourVal - 12
          : (hourVal == 0 ? 12 : hourVal);
      final hourStr = hour12.toString().padLeft(2, '0');
      final timeStr = '$hourStr:$minuteVal $period';

      // Check if slot is passed (if today)
      final now = DateTime.now();
      final isToday =
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
      final isPassed = isToday && current.isBefore(now);

      slots.add(TimeSlot(time: timeStr, isAvailable: !isPassed));
      current = current.add(const Duration(minutes: 30));
    }

    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final timeSlots = _generateTimeSlots(_selectedDate);

    return Scaffold(
      appBar: AppBar(title: const Text('حجز موعد')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Doctor Image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: widget.doctor.profileImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.doctor.profileImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 30,
                            color: AppColors.primary,
                          ),
                  ),
                  const SizedBox(width: 16),

                  // Doctor Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.doctor.fullName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.doctor.specializations?.join('، ') ?? 'عام',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondaryLight),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: widget.isVideoConsultation
                                ? AppColors.info.withValues(alpha: 0.2)
                                : AppColors.success.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.isVideoConsultation
                                    ? Icons.videocam
                                    : Icons.local_hospital,
                                size: 16,
                                color: widget.isVideoConsultation
                                    ? AppColors.info
                                    : AppColors.success,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.isVideoConsultation
                                    ? 'استشارة فيديو'
                                    : 'زيارة عيادة',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: widget.isVideoConsultation
                                          ? AppColors.info
                                          : AppColors.success,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Select Date Section
            Text(
              'اختر التاريخ',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Calendar
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: TableCalendar<dynamic>(
                firstDay: DateTime.now(), // Start from today
                lastDay: DateTime.now().add(const Duration(days: 90)),
                focusedDay: _focusedDay,
                enabledDayPredicate: (day) {
                  final weekDays = {
                    DateTime.sunday: 'الأحد',
                    DateTime.monday: 'الاثنين',
                    DateTime.tuesday: 'الثلاثاء',
                    DateTime.wednesday: 'الأربعاء',
                    DateTime.thursday: 'الخميس',
                    DateTime.friday: 'الجمعة',
                    DateTime.saturday: 'السبت',
                  };
                  final dayName = weekDays[day.weekday];
                  if (widget.doctor.workingHours != null) {
                    return widget.doctor.workingHours!.containsKey(dayName);
                  }
                  return false;
                },
                selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay;
                    _focusedDay = focusedDay;
                    _selectedTimeSlot = null; // Reset time slot
                  });
                },
                availableGestures: AvailableGestures.horizontalSwipe,
                startingDayOfWeek: StartingDayOfWeek.saturday,
                locale: 'ar',
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: Theme.of(context).textTheme.titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: const TextStyle(color: AppColors.error),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Select Time Section
            Text(
              'اختر الوقت',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Time Slots Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: timeSlots.length,
              itemBuilder: (context, index) {
                final slot = timeSlots[index];
                final isSelected = _selectedTimeSlot == slot.time;

                return InkWell(
                  onTap: slot.isAvailable
                      ? () {
                          setState(() {
                            _selectedTimeSlot = slot.time;
                          });
                        }
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: !slot.isAvailable
                          ? AppColors.surfaceLight
                          : isSelected
                          ? AppColors.primary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: !slot.isAvailable
                            ? AppColors.borderLight
                            : isSelected
                            ? AppColors.primary
                            : AppColors.borderLight,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        slot.time,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: !slot.isAvailable
                              ? AppColors.textSecondaryLight
                              : isSelected
                              ? Colors.white
                              : AppColors.textPrimaryLight,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Notes Section
            Text(
              'ملاحظات (اختياري)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'أضف أي ملاحظات أو أعراض تريد إخبار الطبيب بها',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Fee Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'إجمالي الرسوم',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${widget.doctor.consultationFee ?? 200.0} ريال',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Confirm Button
            CustomButton(
              text: 'تأكيد الحجز',
              onPressed: _confirmBooking,
              width: double.infinity,
              height: 52,
              isLoading: _isLoading,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class TimeSlot {
  TimeSlot({required this.time, required this.isAvailable});
  final String time;
  final bool isAvailable;
}
