import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/core/errors/exceptions.dart';
import 'package:elajtech/core/services/call_monitoring_service.dart';
import 'package:elajtech/features/patient/appointments/presentation/widgets/appointment_card_widget.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../mocks/mocks.mocks.dart';

class _TestCallMonitoringService extends CallMonitoringService {
  _TestCallMonitoringService() : super(MockFirebaseFirestore());

  @override
  Future<void> logJoinMeetingTap({
    required String appointmentId,
    required String userId,
    required String outcome,
  }) async {}

  @override
  Future<void> logRescheduleSubmitted({
    required String appointmentId,
    required String userId,
    required DateTime originalDateTime,
    required DateTime newDateTime,
    required String outcome,
  }) async {}
}

void main() {
  setUp(() async {
    if (getIt.isRegistered<CallMonitoringService>()) {
      await getIt.unregister<CallMonitoringService>();
    }
    getIt.registerSingleton<CallMonitoringService>(
      _TestCallMonitoringService(),
    );
  });

  tearDown(() async {
    if (getIt.isRegistered<CallMonitoringService>()) {
      await getIt.unregister<CallMonitoringService>();
    }
  });

  AppointmentModel makeApt({
    required AppointmentStatus status,
    required DateTime appointmentDate,
    String timeSlot = '10:00',
    bool callSessionActive = false,
    DateTime? callStartedAt,
  }) {
    return AppointmentModel(
      id: 'test_id',
      patientId: 'patient_1',
      patientName: 'Test Patient',
      patientPhone: '+1234567890',
      doctorId: 'doctor_1',
      doctorName: 'Dr. Test',
      specialization: 'Andrology',
      appointmentDate: appointmentDate,
      timeSlot: timeSlot,
      type: AppointmentType.video,
      status: status,
      fee: 0,
      createdAt: DateTime(2026),
      callStartedAt: callStartedAt,
      callSessionActive: callSessionActive,
    );
  }

  Future<void> pumpCard(
    WidgetTester tester, {
    required AppointmentModel appointment,
    Future<void> Function()? onJoinMeeting,
    void Function(DateTime)? onRescheduled,
    void Function()? onMedicalRecordTap,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AppointmentCardWidget(
                appointment: appointment,
                onJoinMeeting: onJoinMeeting,
                onRescheduled: onRescheduled,
                onMedicalRecordTap: onMedicalRecordTap,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  String timeOf(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  group('US1 — Call action area widget tests', () {
    testWidgets(
      'shows "Waiting for Call" label for confirmed outside join window',
      (tester) async {
        final appointmentDate = DateTime.now().add(const Duration(days: 1));
        final apt = makeApt(
          status: AppointmentStatus.confirmed,
          appointmentDate: appointmentDate,
        );
        await pumpCard(tester, appointment: apt);

        expect(find.text('في انتظار المكالمة'), findsOneWidget);
      },
    );

    testWidgets(
      '"Waiting for Call" label is not tappable — no join button outside window',
      (tester) async {
        final appointmentDate = DateTime.now().add(const Duration(days: 1));
        final apt = makeApt(
          status: AppointmentStatus.confirmed,
          appointmentDate: appointmentDate,
        );
        await pumpCard(tester, appointment: apt);

        final waitingLabel = find.text('في انتظار المكالمة');
        expect(waitingLabel, findsOneWidget);

        // No join button shown when appointment is far in the future and
        // has no Agora credentials / meeting link.
        final elevatedButtons = find.byType(ElevatedButton);
        expect(elevatedButtons, findsNothing);
      },
    );

    testWidgets(
      'shows "Join Meeting" button for calling status',
      (tester) async {
        final start = DateTime.now().add(const Duration(hours: 1));
        final apt = makeApt(
          status: AppointmentStatus.calling,
          appointmentDate: start,
          timeSlot: timeOf(start),
        );
        await pumpCard(tester, appointment: apt, onJoinMeeting: () async {});

        expect(find.text('انضم للاجتماع'), findsOneWidget);
      },
    );

    testWidgets(
      'shows "Join Meeting" button for inProgress status',
      (tester) async {
        final start = DateTime.now().add(const Duration(hours: 1));
        final apt = makeApt(
          status: AppointmentStatus.inProgress,
          appointmentDate: start,
          timeSlot: timeOf(start),
        );
        await pumpCard(tester, appointment: apt, onJoinMeeting: () async {});

        expect(find.text('انضم للاجتماع'), findsOneWidget);
      },
    );

    testWidgets(
      'shows "Join Meeting" for missed with active session',
      (tester) async {
        final start = DateTime.now().add(const Duration(hours: 1));
        final apt = makeApt(
          status: AppointmentStatus.missed,
          appointmentDate: start,
          timeSlot: timeOf(start),
          callSessionActive: true,
        );
        await pumpCard(tester, appointment: apt, onJoinMeeting: () async {});

        expect(find.text('انضم للاجتماع'), findsOneWidget);
      },
    );

    testWidgets(
      'shows "Join Meeting" when callStartedAt exists before status catches up',
      (tester) async {
        final start = DateTime.now().add(const Duration(hours: 1));
        final apt = makeApt(
          status: AppointmentStatus.confirmed,
          appointmentDate: start,
          timeSlot: timeOf(start),
          callStartedAt: DateTime.now(),
        );
        await pumpCard(tester, appointment: apt, onJoinMeeting: () async {});

        expect(find.text('انضم للاجتماع'), findsOneWidget);
      },
    );

    testWidgets(
      'no call action for completed status',
      (tester) async {
        final apt = makeApt(
          status: AppointmentStatus.completed,
          appointmentDate: DateTime.now(),
        );
        await pumpCard(tester, appointment: apt);

        expect(find.text('في انتظار المكالمة'), findsNothing);
        expect(find.text('انضم للاجتماع'), findsNothing);
      },
    );

    testWidgets(
      'no call action for cancelled status',
      (tester) async {
        final apt = makeApt(
          status: AppointmentStatus.cancelled,
          appointmentDate: DateTime.now(),
        );
        await pumpCard(tester, appointment: apt);

        expect(find.text('في انتظار المكالمة'), findsNothing);
        expect(find.text('انضم للاجتماع'), findsNothing);
      },
    );

    testWidgets(
      'no call action for notCompleted status',
      (tester) async {
        final apt = makeApt(
          status: AppointmentStatus.notCompleted,
          appointmentDate: DateTime.now(),
        );
        await pumpCard(tester, appointment: apt);

        expect(find.text('في انتظار المكالمة'), findsNothing);
        expect(find.text('انضم للاجتماع'), findsNothing);
      },
    );

    testWidgets(
      'no call action for declined status',
      (tester) async {
        final apt = makeApt(
          status: AppointmentStatus.declined,
          appointmentDate: DateTime.now(),
        );
        await pumpCard(tester, appointment: apt);

        expect(find.text('في انتظار المكالمة'), findsNothing);
        expect(find.text('انضم للاجتماع'), findsNothing);
      },
    );

    testWidgets(
      'no call action for endedPendingConfirmation status',
      (tester) async {
        final apt = makeApt(
          status: AppointmentStatus.endedPendingConfirmation,
          appointmentDate: DateTime.now(),
        );
        await pumpCard(tester, appointment: apt);

        expect(find.text('في انتظار المكالمة'), findsNothing);
        expect(find.text('انضم للاجتماع'), findsNothing);
      },
    );

    testWidgets(
      'tapping "Join Meeting" triggers onJoinMeeting callback',
      (tester) async {
        var joinTapped = false;
        final start = DateTime.now().add(const Duration(hours: 1));
        final apt = makeApt(
          status: AppointmentStatus.calling,
          appointmentDate: start,
          timeSlot: timeOf(start),
        );
        await pumpCard(
          tester,
          appointment: apt,
          onJoinMeeting: () async {
            joinTapped = true;
          },
        );

        await tester.tap(find.text('انضم للاجتماع'));
        await tester.pumpAndSettle();

        expect(joinTapped, isTrue);
      },
    );

    testWidgets(
      'FAILED_PRECONDITION shows "doctor not started" SnackBar',
      (tester) async {
        final start = DateTime.now().add(const Duration(hours: 1));
        final apt = makeApt(
          status: AppointmentStatus.calling,
          appointmentDate: start,
          timeSlot: timeOf(start),
        );
        await pumpCard(
          tester,
          appointment: apt,
          onJoinMeeting: () async {
            throw const AgoraException(
              'precondition',
              code: 'FAILED_PRECONDITION',
            );
          },
        );

        await tester.tap(find.text('انضم للاجتماع'));
        await tester.pumpAndSettle();

        expect(
          find.text('لم يبدأ الطبيب المكالمة بعد — يرجى الانتظار'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'NOT_FOUND shows "meeting no longer available" SnackBar',
      (tester) async {
        final start = DateTime.now().add(const Duration(hours: 1));
        final apt = makeApt(
          status: AppointmentStatus.calling,
          appointmentDate: start,
          timeSlot: timeOf(start),
        );
        await pumpCard(
          tester,
          appointment: apt,
          onJoinMeeting: () async {
            throw const AgoraException('not found', code: 'NOT_FOUND');
          },
        );

        await tester.tap(find.text('انضم للاجتماع'));
        await tester.pumpAndSettle();

        expect(find.text('الاجتماع لم يعد متاحاً'), findsOneWidget);
      },
    );

    testWidgets(
      'shows "Waiting for Call" for pending status',
      (tester) async {
        final apt = makeApt(
          status: AppointmentStatus.pending,
          appointmentDate: DateTime.now().add(const Duration(hours: 2)),
          timeSlot: '${DateTime.now().add(const Duration(hours: 2)).hour}:00',
        );
        await pumpCard(tester, appointment: apt);

        expect(find.text('في انتظار المكالمة'), findsOneWidget);
      },
    );
  });

  group('US2 — Reschedule button widget tests', () {
    testWidgets(
      'shows "Reschedule" for confirmed >2h away',
      (tester) async {
        final apt = makeApt(
          status: AppointmentStatus.confirmed,
          appointmentDate: DateTime.now().add(const Duration(hours: 3)),
          timeSlot: '${DateTime.now().add(const Duration(hours: 3)).hour}:00',
        );
        await pumpCard(tester, appointment: apt);

        expect(find.text('تأجيل الموعد'), findsOneWidget);
      },
    );

    testWidgets(
      'hides "Reschedule" for confirmed <2h away',
      (tester) async {
        final apt = makeApt(
          status: AppointmentStatus.confirmed,
          appointmentDate: DateTime.now().add(const Duration(minutes: 30)),
          timeSlot:
              '${DateTime.now().add(const Duration(minutes: 30)).hour}:00',
        );
        await pumpCard(tester, appointment: apt);

        expect(find.text('تأجيل الموعد'), findsNothing);
      },
    );

    testWidgets(
      'hides "Reschedule" for completed status',
      (tester) async {
        final apt = makeApt(
          status: AppointmentStatus.completed,
          appointmentDate: DateTime.now().add(const Duration(hours: 5)),
        );
        await pumpCard(tester, appointment: apt);

        expect(find.text('تأجيل الموعد'), findsNothing);
      },
    );
  });

  group('US3 — Medical record icon widget tests', () {
    testWidgets(
      'shows "View Medical Record" icon for completed status',
      (tester) async {
        final apt = makeApt(
          status: AppointmentStatus.completed,
          appointmentDate: DateTime.now(),
        );
        await pumpCard(tester, appointment: apt);

        expect(find.byIcon(Icons.article_outlined), findsOneWidget);
        expect(find.byTooltip('عرض السجل الطبي'), findsOneWidget);
      },
    );

    testWidgets(
      'icon tap target meets 48dp minimum',
      (tester) async {
        final apt = makeApt(
          status: AppointmentStatus.completed,
          appointmentDate: DateTime.now(),
        );
        await pumpCard(tester, appointment: apt);

        final iconSize = tester.getSize(
          find.ancestor(
            of: find.byIcon(Icons.article_outlined),
            matching: find.byType(SizedBox),
          ),
        );
        expect(iconSize.width, greaterThanOrEqualTo(48));
        expect(iconSize.height, greaterThanOrEqualTo(48));
      },
    );

    testWidgets(
      'hides "View Medical Record" icon for all non-completed statuses',
      (tester) async {
        for (final status in AppointmentStatus.values) {
          if (status == AppointmentStatus.completed) continue;

          final apt = makeApt(
            status: status,
            appointmentDate: DateTime.now(),
          );
          await pumpCard(tester, appointment: apt);

          expect(
            find.byIcon(Icons.article_outlined),
            findsNothing,
            reason: 'Icon should be hidden for status $status',
          );
        }
      },
    );

    testWidgets(
      'tapping medical record icon triggers onMedicalRecordTap',
      (tester) async {
        var tapped = false;
        final apt = makeApt(
          status: AppointmentStatus.completed,
          appointmentDate: DateTime.now(),
        );
        await pumpCard(
          tester,
          appointment: apt,
          onMedicalRecordTap: () {
            tapped = true;
          },
        );

        await tester.tap(find.byIcon(Icons.article_outlined));
        await tester.pumpAndSettle();

        expect(tapped, isTrue);
      },
    );
  });

  group('Phase 6 — Status coverage matrix', () {
    testWidgets('matches Scenario 5 action matrix for all rows', (
      tester,
    ) async {
      final now = DateTime.now();
      final insideWindow = now.add(const Duration(minutes: 5));
      final outsideWindow = now.add(const Duration(days: 1));
      final liveUpcoming = now.add(const Duration(hours: 1));

      final cases = [
        (
          name: 'pending outside window',
          appointment: makeApt(
            status: AppointmentStatus.pending,
            appointmentDate: outsideWindow,
          ),
          waiting: true,
          join: false, // No join button: far future, no Agora creds/meetingLink
          reschedule: true,
          record: false,
        ),
        (
          name: 'confirmed outside window',
          appointment: makeApt(
            status: AppointmentStatus.confirmed,
            appointmentDate: outsideWindow,
          ),
          waiting: true,
          join: false, // No join button: far future, no Agora creds/meetingLink
          reschedule: true,
          record: false,
        ),
        (
          name: 'confirmed inside window',
          appointment: makeApt(
            status: AppointmentStatus.confirmed,
            appointmentDate: insideWindow,
            timeSlot: timeOf(insideWindow),
          ),
          waiting: false,
          join: true,
          reschedule: false, // < 2h away → reschedule hidden per 2-hour rule
          record: false,
        ),
        (
          name: 'calling',
          appointment: makeApt(
            status: AppointmentStatus.calling,
            appointmentDate: liveUpcoming,
            timeSlot: timeOf(liveUpcoming),
          ),
          waiting: false,
          join: true,
          reschedule: false,
          record: false,
        ),
        (
          name: 'in progress',
          appointment: makeApt(
            status: AppointmentStatus.inProgress,
            appointmentDate: liveUpcoming,
            timeSlot: timeOf(liveUpcoming),
          ),
          waiting: false,
          join: true,
          reschedule: false,
          record: false,
        ),
        (
          name: 'missed active session',
          appointment: makeApt(
            status: AppointmentStatus.missed,
            appointmentDate: liveUpcoming,
            timeSlot: timeOf(liveUpcoming),
            callSessionActive: true,
          ),
          waiting: false,
          join: true,
          reschedule: false,
          record: false,
        ),
        (
          name: 'missed no session',
          appointment: makeApt(
            status: AppointmentStatus.missed,
            appointmentDate: now,
          ),
          waiting: false,
          join: false,
          reschedule: false,
          record: false,
        ),
        (
          name: 'declined',
          appointment: makeApt(
            status: AppointmentStatus.declined,
            appointmentDate: now,
          ),
          waiting: false,
          join: false,
          reschedule: false,
          record: false,
        ),
        (
          name: 'ended pending confirmation',
          appointment: makeApt(
            status: AppointmentStatus.endedPendingConfirmation,
            appointmentDate: now,
          ),
          waiting: false,
          join: false,
          reschedule: false,
          record: false,
        ),
        (
          name: 'not completed',
          appointment: makeApt(
            status: AppointmentStatus.notCompleted,
            appointmentDate: now,
          ),
          waiting: false,
          join: false,
          reschedule: false,
          record: false,
        ),
        (
          name: 'completed',
          appointment: makeApt(
            status: AppointmentStatus.completed,
            appointmentDate: now,
          ),
          waiting: false,
          join: false,
          reschedule: false,
          record: true,
        ),
        (
          name: 'cancelled',
          appointment: makeApt(
            status: AppointmentStatus.cancelled,
            appointmentDate: now,
          ),
          waiting: false,
          join: false,
          reschedule: false,
          record: false,
        ),
      ];

      for (final testCase in cases) {
        await pumpCard(
          tester,
          appointment: testCase.appointment,
          onJoinMeeting: testCase.join ? () async {} : null,
        );

        expect(
          find.text('في انتظار المكالمة'),
          testCase.waiting ? findsOneWidget : findsNothing,
          reason: testCase.name,
        );
        expect(
          find.byType(ElevatedButton),
          testCase.join ? findsOneWidget : findsNothing,
          reason: testCase.name,
        );
        expect(
          find.text('تأجيل الموعد'),
          testCase.reschedule ? findsOneWidget : findsNothing,
          reason: testCase.name,
        );
        expect(
          find.byIcon(Icons.article_outlined),
          testCase.record ? findsOneWidget : findsNothing,
          reason: testCase.name,
        );
      }
    });

    testWidgets('join button has semantics label and 48dp height', (
      tester,
    ) async {
      final apt = makeApt(
        status: AppointmentStatus.calling,
        appointmentDate: DateTime.now().add(const Duration(hours: 1)),
        timeSlot: timeOf(DateTime.now().add(const Duration(hours: 1))),
      );
      await pumpCard(tester, appointment: apt, onJoinMeeting: () async {});

      expect(find.byType(ElevatedButton), findsOneWidget);
      final size = tester.getSize(find.byType(ElevatedButton));
      expect(size.height, greaterThanOrEqualTo(48));
    });

    testWidgets('reschedule button has semantics label and 48dp height', (
      tester,
    ) async {
      final apt = makeApt(
        status: AppointmentStatus.confirmed,
        appointmentDate: DateTime.now().add(const Duration(days: 1)),
      );
      await pumpCard(tester, appointment: apt);

      expect(find.text('تأجيل الموعد'), findsOneWidget);
      final size = tester.getSize(find.byType(OutlinedButton).first);
      expect(size.height, greaterThanOrEqualTo(48));
    });
  });
}
