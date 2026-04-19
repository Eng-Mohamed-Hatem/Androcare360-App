import 'package:elajtech/features/patient/consultation/presentation/screens/incoming_call_screen.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shouldRestoreIncomingCall', () {
    test('keeps missed blocked by default', () {
      expect(shouldRestoreIncomingCall(AppointmentStatus.missed), isFalse);
    });

    test('allows missed when fresh join authorization exists', () {
      expect(
        shouldRestoreIncomingCall(
          AppointmentStatus.missed,
          hasFreshJoinAuthorization: true,
        ),
        isTrue,
      );
    });

    test('allows missed when accepted from CallKit', () {
      expect(
        shouldRestoreIncomingCall(
          AppointmentStatus.missed,
          hasAcceptedFromCallKit: true,
        ),
        isTrue,
      );
    });

    test('allows missed when native active call still exists', () {
      expect(
        shouldRestoreIncomingCall(
          AppointmentStatus.missed,
          hasActiveNativeCall: true,
        ),
        isTrue,
      );
    });
  });
}
