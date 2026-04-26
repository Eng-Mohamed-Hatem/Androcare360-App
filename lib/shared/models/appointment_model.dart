/// Represents a medical appointment between a doctor and patient in the AndroCare360 system.
///
/// This model stores all appointment details including scheduling information,
/// participant IDs, status tracking, and video call integration with Agora SDK.
/// It supports both video consultations and in-clinic appointments.
///
/// **Firestore Collection:** `appointments`
///
/// **Status Values:**
/// - `pending`: Appointment requested, awaiting doctor confirmation
/// - `confirmed`: Doctor confirmed, appointment scheduled
/// - `scheduled`: Appointment has been scheduled with specific date/time
/// - `completed`: Appointment finished successfully
/// - `cancelled`: Appointment cancelled by doctor or patient
/// - `missed`: Patient did not attend the scheduled appointment
///
/// **Appointment Types:**
/// - `video`: Video consultation using Agora RTC
/// - `clinic`: In-person clinic visit
///
/// **Usage Example:**
/// ```dart
/// final appointment = AppointmentModel(
///   id: 'apt_123',
///   patientId: 'patient_456',
///   patientName: 'Ahmed Ali',
///   patientPhone: '+966500000001',
///   doctorId: 'doctor_789',
///   doctorName: 'Dr. Sarah Ahmed',
///   specialization: 'Nutrition',
///   appointmentDate: DateTime(2024, 3, 15),
///   timeSlot: '10:00 ص',
///   type: AppointmentType.video,
///   status: AppointmentStatus.confirmed,
///   fee: 150.0,
///   createdAt: DateTime.now(),
///   agoraChannelName: 'appointment_123',
///   meetingProvider: 'agora',
/// );
/// ```
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/shared/utils/json_helpers.dart';

class AppointmentModel {
  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
    required this.doctorId,
    required this.doctorName,
    required this.specialization,
    required this.appointmentDate,
    required this.timeSlot,
    required this.type,
    required this.status,
    required this.fee,
    required this.createdAt,
    this.notes,
    this.meetingLink,
    // حقول جدولة المواعيد
    this.scheduledDateTime,
    this.reminderSent = false,
    // ✅ جديد: Timestamp للتوقيت الصحيح (للتحقق من 24 ساعة)
    this.appointmentTimestamp,
    // 🎥 حقول Agora SDK
    this.agoraChannelName,
    this.agoraToken,
    this.agoraUid,
    this.meetingProvider = 'agora',
    this.callSessionId,
    this.callStartedAt,
    this.confirmationDeadlineAt,
    this.callSessionActive = false,
    this.bookingSource,
    this.assessmentId,
    this.assessmentResultBand,
    this.referralTargetKey,
    this.completedAt,
    this.confirmedAt,
  });

  /// Creates an AppointmentModel from JSON data.
  ///
  /// This factory constructor parses JSON data from Firestore or API responses
  /// and creates an AppointmentModel instance. It handles type conversions and
  /// provides default values for optional fields.
  ///
  /// Parameters:
  /// - [json]: Map containing appointment data with all required fields
  ///
  /// Returns a fully initialized AppointmentModel instance.
  ///
  /// Throws [FormatException] if date strings are malformed.
  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final status = _statusFromString(json['status'] as String?);

    return AppointmentModel(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      patientPhone: json['patientPhone'] as String,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      specialization: json['specialization'] as String,
      appointmentDate: JsonHelpers.parseDateTime(json['appointmentDate']),
      timeSlot: json['timeSlot'] as String,
      type: AppointmentType.values.firstWhere(
        (e) => e.toString() == 'AppointmentType.${json['type']}',
      ),
      status: status,
      fee: (json['fee'] as num).toDouble(),
      notes: json['notes'] as String?,
      meetingLink: json['meetingLink'] as String?,
      createdAt: JsonHelpers.parseDateTime(json['createdAt']),
      // حقول جدولة المواعيد
      scheduledDateTime: JsonHelpers.parseDateTimeOrNull(
        json['scheduledDateTime'],
      ),
      reminderSent: json['reminderSent'] as bool? ?? false,
      // ✅ جديد: قراءة appointmentTimestamp
      appointmentTimestamp: _parseAppointmentTimestamp(
        json['appointmentTimestamp'],
      ),
      // 🎥 حقول Agora SDK
      agoraChannelName:
          (json['channelName'] ?? json['agoraChannelName']) as String?,
      agoraToken: json['agoraToken'] as String?,
      agoraUid: _parseAgoraUid(json['agoraUid']),
      meetingProvider: json['meetingProvider'] as String? ?? 'agora',
      callSessionId: json['callSessionId'] as String?,
      callStartedAt: JsonHelpers.parseDateTimeOrNull(json['callStartedAt']),
      confirmationDeadlineAt: JsonHelpers.parseDateTimeOrNull(
        json['confirmationDeadlineAt'],
      ),
      callSessionActive: json['callSessionActive'] as bool? ?? false,
      bookingSource: json['bookingSource'] as String?,
      assessmentId: json['assessmentId'] as String?,
      assessmentResultBand: json['assessmentResultBand'] as String?,
      referralTargetKey: json['referralTargetKey'] as String?,
      completedAt: JsonHelpers.parseDateTimeOrNull(json['completedAt']),
      confirmedAt: JsonHelpers.parseDateTimeOrNull(json['confirmedAt']),
    );
  }

  factory AppointmentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    if (!snapshot.exists) {
      throw StateError('Appointment document ${snapshot.id} does not exist');
    }

    final data = snapshot.data();
    if (data == null) {
      throw StateError('Appointment document ${snapshot.id} has no data');
    }

    return AppointmentModel.fromJson({
      ...data,
      'id': data['id'] ?? snapshot.id,
    });
  }

  /// Unique identifier for the appointment
  final String id;

  /// ID of the patient for this appointment
  final String patientId;

  /// Full name of the patient
  final String patientName;

  /// Patient's phone number for contact
  final String patientPhone;

  /// ID of the doctor assigned to this appointment
  final String doctorId;

  /// Full name of the doctor
  final String doctorName;

  /// Medical specialization for this appointment (e.g., 'Nutrition', 'Physiotherapy')
  final String specialization;

  /// Date of the appointment (without time component)
  final DateTime appointmentDate;

  /// Time slot for the appointment (e.g., '10:00 ص', '02:00 م')
  final String timeSlot;

  /// Type of appointment: video consultation or clinic visit
  final AppointmentType type;

  /// Current status of the appointment
  final AppointmentStatus status;

  /// Consultation fee in SAR
  final double fee;

  /// Optional notes or special instructions for the appointment
  final String? notes;

  /// Timestamp when the appointment was created
  final DateTime createdAt;

  /// Optional meeting link (for backward compatibility with non-Agora systems)
  final String? meetingLink;

  // حقول جدولة المواعيد الجديدة
  /// The actual scheduled date and time (may differ from appointmentDate/timeSlot)
  ///
  /// This field stores the precise DateTime when the appointment is scheduled,
  /// useful for reminder notifications and calendar integration.
  final DateTime? scheduledDateTime;

  /// Indicates whether a reminder notification has been sent to the patient
  final bool reminderSent;

  /// Precise timestamp for the appointment (used for 24-hour validation checks)
  ///
  /// This Firestore Timestamp ensures accurate time tracking across time zones
  /// and is used to validate appointment timing rules.
  final DateTime? appointmentTimestamp;

  /// Agora channel name for video calls (e.g., 'appointment_123')
  ///
  /// This unique channel identifier is used to establish video connections
  /// between doctor and patient using Agora RTC SDK.
  final String? agoraChannelName;

  /// Agora authentication token (generated server-side, short-lived)
  ///
  /// This token is generated by Cloud Functions in the europe-west1 region
  /// and provides secure access to the Agora video channel.
  final String? agoraToken;

  /// Agora user ID (unique identifier for the user in the channel)
  ///
  /// This numeric ID identifies the participant within the Agora video session.
  final int? agoraUid;

  /// Meeting provider identifier ('agora' or 'zoom' for backward compatibility)
  final String meetingProvider;

  /// Active call session identifier for the appointment lifecycle.
  final String? callSessionId;

  /// Timestamp when the live call session started.
  final DateTime? callStartedAt;

  /// Deadline for the doctor confirmation step after a call ends.
  final DateTime? confirmationDeadlineAt;

  /// Whether the existing call session is still active for patient rejoin.
  final bool callSessionActive;

  /// Booking entry point, such as direct booking or assessment referral.
  final String? bookingSource;

  /// Optional source assessment identifier when booked from a self-assessment.
  final String? assessmentId;

  /// Optional result band captured from the assessment flow.
  final String? assessmentResultBand;

  /// Optional referral group key used to pre-filter specialists.
  final String? referralTargetKey;

  /// Timestamp when this appointment's status transitioned to `completed` (PR-002).
  /// Set server-side by the confirmAppointmentCompletion Cloud Function.
  /// Used as the primary time axis for analytics time-series queries.
  final DateTime? completedAt;

  /// Timestamp when this appointment first moved from `pending` to
  /// `confirmed` or `scheduled` (PR-005).
  /// Used by analytics to calculate average doctor response time.
  final DateTime? confirmedAt;

  /// Converts this AppointmentModel to JSON format for Firestore storage.
  ///
  /// This method serializes all appointment data into a Map suitable for
  /// storing in Firestore or sending via API. It handles DateTime conversions
  /// and Firestore Timestamp formatting.
  ///
  /// Returns a `Map<String, dynamic>` containing all appointment data.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'patientPhone': patientPhone,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'specialization': specialization,
      'appointmentDate': appointmentDate.toIso8601String(),
      'timeSlot': timeSlot,
      'type': type.name,
      'status': _statusToString(status),
      'fee': fee,
      'notes': notes,
      'meetingLink': meetingLink,
      'createdAt': createdAt.toIso8601String(),
      // حقول جدولة المواعيد
      'scheduledDateTime': scheduledDateTime?.toIso8601String(),
      'reminderSent': reminderSent,
      // ✅ جديد: إرسال appointmentTimestamp
      'appointmentTimestamp': _formatAppointmentTimestamp(),
      // 🎥 حقول Agora SDK
      'agoraChannelName': agoraChannelName,
      'agoraToken': agoraToken,
      'agoraUid': agoraUid,
      'meetingProvider': meetingProvider,
      'callSessionId': callSessionId,
      'callStartedAt': callStartedAt?.toIso8601String(),
      'confirmationDeadlineAt': confirmationDeadlineAt?.toIso8601String(),
      'callSessionActive': callSessionActive,
      'bookingSource': bookingSource,
      'assessmentId': assessmentId,
      'assessmentResultBand': assessmentResultBand,
      'referralTargetKey': referralTargetKey,
      'completedAt': completedAt?.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
    };
  }

  /// Helper method to parse appointmentTimestamp from Firestore data.
  ///
  /// This method handles both Firestore Timestamp objects and ISO8601 string
  /// formats, ensuring compatibility with different data sources.
  ///
  /// Parameters:
  /// - [value]: The timestamp value from Firestore (can be Timestamp or String)
  ///
  /// Returns a DateTime object or null if parsing fails.
  static DateTime? _parseAppointmentTimestamp(dynamic value) {
    if (value == null) return null;

    // إذا كان Timestamp من Firestore
    if (value is Timestamp) {
      return value.toDate();
    }

    // إذا كان String، حاول تحويله
    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  static int? _parseAgoraUid(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is String) {
      return int.tryParse(value);
    }

    return null;
  }

  /// Helper method to format appointmentTimestamp for Firestore storage.
  ///
  /// Converts the DateTime to a Firestore Timestamp object for proper
  /// storage and querying in Firestore.
  ///
  /// Returns a Firestore Timestamp or null if appointmentTimestamp is null.
  dynamic _formatAppointmentTimestamp() {
    if (appointmentTimestamp == null) return null;

    // ✅ إرسال كـ Timestamp من Firestore
    return Timestamp.fromDate(appointmentTimestamp!);
  }

  /// Combines appointmentDate and timeSlot into a single DateTime object.
  ///
  /// This getter parses the timeSlot string (which can be in 12-hour format
  /// with Arabic or English AM/PM indicators, or 24-hour format) and combines
  /// it with the appointmentDate to create a complete DateTime.
  ///
  /// Supported formats:
  /// - "11:00 ص" or "11:00 AM" (12-hour with Arabic/English AM)
  /// - "02:00 م" or "02:00 PM" (12-hour with Arabic/English PM)
  /// - "14:00" (24-hour format)
  ///
  /// Returns the combined DateTime, or appointmentDate if parsing fails.
  DateTime get fullDateTime {
    try {
      final parts = timeSlot.split(' ');
      if (parts.length == 2) {
        // Handle "11:00 AM" or "11:00 ص"
        final timeParts = parts[0].split(':');
        if (timeParts.length == 2) {
          var hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          final period = parts[1].trim();

          if ((period == 'م' || period == 'PM' || period == 'pm') &&
              hour != 12) {
            hour += 12;
          }
          if ((period == 'ص' || period == 'AM' || period == 'am') &&
              hour == 12) {
            hour = 0;
          }

          return DateTime(
            appointmentDate.year,
            appointmentDate.month,
            appointmentDate.day,
            hour,
            minute,
          );
        }
      } else {
        // Fallback for "HH:mm" (24-hour format)
        final timeParts = timeSlot.split(':');
        if (timeParts.length == 2) {
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          return DateTime(
            appointmentDate.year,
            appointmentDate.month,
            appointmentDate.day,
            hour,
            minute,
          );
        }
      }

      return appointmentDate;
    } on Exception catch (_) {
      return appointmentDate;
    }
  }

  /// Creates a copy of this AppointmentModel with the specified fields replaced.
  ///
  /// This method allows creating a modified copy of the appointment while
  /// preserving all other fields. Useful for updating appointment status,
  /// adding Agora credentials, or modifying scheduling information.
  ///
  /// All parameters are optional. If a parameter is not provided, the
  /// corresponding field from the original model is used.
  ///
  /// Returns a new AppointmentModel instance with the updated fields.
  AppointmentModel copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? patientPhone,
    String? doctorId,
    String? doctorName,
    String? specialization,
    DateTime? appointmentDate,
    String? timeSlot,
    AppointmentType? type,
    AppointmentStatus? status,
    double? fee,
    String? notes,
    String? meetingLink,
    DateTime? createdAt,
    // حقول جدولة المواعيد
    DateTime? scheduledDateTime,
    bool? reminderSent,
    // ✅ جديد: appointmentTimestamp
    DateTime? appointmentTimestamp,
    // 🎥 حقول Agora SDK
    String? agoraChannelName,
    String? agoraToken,
    int? agoraUid,
    String? meetingProvider,
    String? callSessionId,
    DateTime? callStartedAt,
    DateTime? confirmationDeadlineAt,
    bool? callSessionActive,
    String? bookingSource,
    String? assessmentId,
    String? assessmentResultBand,
    String? referralTargetKey,
    DateTime? completedAt,
    DateTime? confirmedAt,
  }) {
    final nextStatus = status ?? this.status;
    final now = DateTime.now().toUtc();
    final shouldStampCompleted =
        nextStatus == AppointmentStatus.completed &&
        this.status != AppointmentStatus.completed;
    final shouldStampConfirmed =
        this.status == AppointmentStatus.pending &&
        confirmedAt == null &&
        this.confirmedAt == null &&
        (nextStatus == AppointmentStatus.confirmed ||
            nextStatus == AppointmentStatus.scheduled);

    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      specialization: specialization ?? this.specialization,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      timeSlot: timeSlot ?? this.timeSlot,
      type: type ?? this.type,
      status: nextStatus,
      fee: fee ?? this.fee,
      notes: notes ?? this.notes,
      meetingLink: meetingLink ?? this.meetingLink,
      createdAt: createdAt ?? this.createdAt,
      // حقول جدولة المواعيد
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      reminderSent: reminderSent ?? this.reminderSent,
      // ✅ جديد: appointmentTimestamp
      appointmentTimestamp: appointmentTimestamp ?? this.appointmentTimestamp,
      // 🎥 حقول Agora SDK
      agoraChannelName: agoraChannelName ?? this.agoraChannelName,
      agoraToken: agoraToken ?? this.agoraToken,
      agoraUid: agoraUid ?? this.agoraUid,
      meetingProvider: meetingProvider ?? this.meetingProvider,
      callSessionId: callSessionId ?? this.callSessionId,
      callStartedAt: callStartedAt ?? this.callStartedAt,
      confirmationDeadlineAt:
          confirmationDeadlineAt ?? this.confirmationDeadlineAt,
      callSessionActive: callSessionActive ?? this.callSessionActive,
      bookingSource: bookingSource ?? this.bookingSource,
      assessmentId: assessmentId ?? this.assessmentId,
      assessmentResultBand: assessmentResultBand ?? this.assessmentResultBand,
      referralTargetKey: referralTargetKey ?? this.referralTargetKey,
      completedAt:
          completedAt ?? (shouldStampCompleted ? now : this.completedAt),
      confirmedAt:
          confirmedAt ?? (shouldStampConfirmed ? now : this.confirmedAt),
    );
  }
}

/// Defines the type of medical appointment.
///
/// **Values:**
/// - `video`: Video consultation using Agora RTC SDK
/// - `clinic`: In-person clinic visit
enum AppointmentType {
  /// Video consultation appointment
  video, // استشارة فيديو
  /// In-clinic appointment
  clinic, // زيارة عيادة
}

/// Defines the current status of an appointment.
///
/// **Status Flow:**
/// 1. `pending` → Patient requests appointment
/// 2. `confirmed` → Doctor confirms the appointment
/// 3. `scheduled` → Appointment is scheduled with specific date/time
/// 4. `completed` → Appointment successfully finished
/// 5. `cancelled` → Appointment cancelled by either party
/// 6. `missed` → Patient did not attend
enum AppointmentStatus {
  /// Appointment requested, awaiting doctor confirmation
  pending, // قيد الانتظار
  /// Doctor confirmed the appointment
  confirmed, // مؤكد
  /// Appointment has been scheduled
  scheduled, // مجدول (تم الجدولة)
  /// Doctor started the call and the patient is still ringing
  calling,

  /// The patient joined and the call is live
  inProgress,

  /// Patient explicitly declined the incoming call
  declined,

  /// The call ended and awaits doctor confirmation
  endedPendingConfirmation,

  /// Appointment completed successfully
  completed, // مكتمل
  /// Session ended without successful completion
  notCompleted,

  /// Appointment cancelled
  cancelled, // ملغي
  /// Patient missed the appointment
  missed, // فائت
}

AppointmentStatus _statusFromString(String? value) {
  switch (value) {
    case 'pending':
      return AppointmentStatus.pending;
    case 'confirmed':
      return AppointmentStatus.confirmed;
    case 'scheduled':
      return AppointmentStatus.scheduled;
    case 'calling':
      return AppointmentStatus.calling;
    case 'in_progress':
      return AppointmentStatus.inProgress;
    case 'declined':
      return AppointmentStatus.declined;
    case 'ended_pending_confirmation':
      return AppointmentStatus.endedPendingConfirmation;
    case 'completed':
      return AppointmentStatus.completed;
    case 'not_completed':
      return AppointmentStatus.notCompleted;
    case 'cancelled':
      return AppointmentStatus.cancelled;
    case 'missed':
      return AppointmentStatus.missed;
    default:
      return AppointmentStatus.pending;
  }
}

String _statusToString(AppointmentStatus status) {
  switch (status) {
    case AppointmentStatus.pending:
      return 'pending';
    case AppointmentStatus.confirmed:
      return 'confirmed';
    case AppointmentStatus.scheduled:
      return 'scheduled';
    case AppointmentStatus.calling:
      return 'calling';
    case AppointmentStatus.inProgress:
      return 'in_progress';
    case AppointmentStatus.declined:
      return 'declined';
    case AppointmentStatus.endedPendingConfirmation:
      return 'ended_pending_confirmation';
    case AppointmentStatus.completed:
      return 'completed';
    case AppointmentStatus.notCompleted:
      return 'not_completed';
    case AppointmentStatus.cancelled:
      return 'cancelled';
    case AppointmentStatus.missed:
      return 'missed';
  }
}

/// Represents a time slot for appointment booking.
///
/// This model is used in the appointment booking UI to display
/// available and unavailable time slots to users.
class TimeSlot {
  TimeSlot({required this.time, required this.isAvailable, this.slotId});

  /// Time string in 12-hour format (e.g., '09:00 ص', '02:00 م')
  final String time;

  /// Indicates whether this time slot is available for booking
  final bool isAvailable;

  /// Optional stable slot identifier used by reschedule flows.
  final String? slotId;
}

/// Provides mock time slots for testing and development.
///
/// This class generates a list of sample time slots with availability
/// status for use in UI development and testing scenarios.
class MockTimeSlots {
  /// Returns a list of mock time slots for a typical working day.
  ///
  /// The time slots cover morning and afternoon hours with some
  /// slots marked as unavailable to simulate real booking scenarios.
  static List<TimeSlot> getTimeSlots() {
    return [
      TimeSlot(time: '09:00 ص', isAvailable: true),
      TimeSlot(time: '10:00 ص', isAvailable: true),
      TimeSlot(time: '11:00 ص', isAvailable: false),
      TimeSlot(time: '12:00 م', isAvailable: true),
      TimeSlot(time: '02:00 م', isAvailable: true),
      TimeSlot(time: '03:00 م', isAvailable: false),
      TimeSlot(time: '04:00 م', isAvailable: true),
      TimeSlot(time: '05:00 م', isAvailable: true),
    ];
  }
}
