const {
  db,
  createMockContext,
  functionsTest,
} = require('./setup');
const {
  createAppointmentWithCallDataFixture,
  createPatientFixture,
} = require('./fixtures');
const {
  handleMissedCall,
  patientJoinCall,
} = require('../index');

describe('Phase 4 missed call rejoin workflow', () => {
  test('handleMissedCall writes missed state and keeps session active', async () => {
    const appointment = createAppointmentWithCallDataFixture({
      id: 'phase4_missed_001',
      doctorId: 'phase4_doctor_001',
      patientId: 'phase4_patient_001',
      status: 'calling',
      callStatus: 'ringing',
    });
    const patient = createPatientFixture({ id: appointment.patientId });

    await db.collection('appointments').doc(appointment.id).set(appointment);
    await db.collection('users').doc(patient.id).set(patient);

    const result = await functionsTest.wrap(handleMissedCall)({
      appointmentId: appointment.id,
    }, createMockContext(patient.id));

    expect(result.success).toBe(true);

    const updated = (await db.collection('appointments').doc(appointment.id).get()).data();
    expect(updated.status).toBe('missed');
    expect(updated.callStatus).toBe('missed');
    expect(updated.callSessionActive).toBe(true);
    expect(updated.missedAt).toBeDefined();
  });

  test('handleMissedCall is idempotent once appointment is already missed', async () => {
    const appointment = createAppointmentWithCallDataFixture({
      id: 'phase4_missed_002',
      doctorId: 'phase4_doctor_002',
      patientId: 'phase4_patient_002',
      status: 'missed',
      callStatus: 'missed',
      callSessionActive: true,
    });
    const patient = createPatientFixture({ id: appointment.patientId });

    await db.collection('appointments').doc(appointment.id).set(appointment);
    await db.collection('users').doc(patient.id).set(patient);

    const result = await functionsTest.wrap(handleMissedCall)({
      appointmentId: appointment.id,
    }, createMockContext(patient.id));

    expect(result.success).toBe(true);

    const updated = (await db.collection('appointments').doc(appointment.id).get()).data();
    expect(updated.status).toBe('missed');
    expect(updated.callSessionActive).toBe(true);
  });

  test('handleMissedCall ignores cancelled appointments', async () => {
    const appointment = createAppointmentWithCallDataFixture({
      id: 'phase4_missed_003',
      doctorId: 'phase4_doctor_002b',
      patientId: 'phase4_patient_002b',
      status: 'cancelled',
      callStatus: 'ringing',
    });
    const patient = createPatientFixture({ id: appointment.patientId });

    await db.collection('appointments').doc(appointment.id).set(appointment);
    await db.collection('users').doc(patient.id).set(patient);

    const result = await functionsTest.wrap(handleMissedCall)({
      appointmentId: appointment.id,
    }, createMockContext(patient.id));

    expect(result.success).toBe(true);

    const updated = (await db.collection('appointments').doc(appointment.id).get()).data();
    expect(updated.status).toBe('cancelled');
    expect(updated.callStatus).toBe('ringing');
  });

  test('patientJoinCall validates identity, session expiry, status, and idempotent in_progress', async () => {
    const appointment = createAppointmentWithCallDataFixture({
      id: 'phase4_join_001',
      doctorId: 'phase4_doctor_003',
      patientId: 'phase4_patient_003',
      status: 'missed',
      callStatus: 'missed',
      callSessionId: 'phase4_channel_003',
      callSessionActive: true,
      callStartedAt: new Date(),
    });
    const patient = createPatientFixture({ id: appointment.patientId });

    await db.collection('appointments').doc(appointment.id).set(appointment);
    await db.collection('users').doc(patient.id).set(patient);

    const result = await functionsTest.wrap(patientJoinCall)({
      appointmentId: appointment.id,
      patientId: patient.id,
    }, createMockContext(patient.id));

    expect(result.success).toBe(true);
    expect(result.agoraToken).toBeDefined();
    expect(result.channelName).toBe('phase4_channel_003');
    expect(result.uid).toBeDefined();

    let updated = (await db.collection('appointments').doc(appointment.id).get()).data();
    expect(updated.status).toBe('in_progress');

    const idempotent = await functionsTest.wrap(patientJoinCall)({
      appointmentId: appointment.id,
      patientId: patient.id,
    }, createMockContext(patient.id));

    expect(idempotent.success).toBe(true);
    expect(idempotent.channelName).toBe('phase4_channel_003');

    const wrongPatient = createPatientFixture({ id: 'phase4_patient_wrong' });
    await db.collection('users').doc(wrongPatient.id).set(wrongPatient);
    await expect(
      functionsTest.wrap(patientJoinCall)({
        appointmentId: appointment.id,
        patientId: wrongPatient.id,
      }, createMockContext(wrongPatient.id))
    ).rejects.toMatchObject({ code: 'permission-denied' });

    const expiredAppointment = {
      ...appointment,
      id: 'phase4_join_002',
      callStartedAt: new Date(Date.now() - 2 * 3600 * 1000),
    };
    await db.collection('appointments').doc(expiredAppointment.id).set(expiredAppointment);

    await expect(
      functionsTest.wrap(patientJoinCall)({
        appointmentId: expiredAppointment.id,
        patientId: patient.id,
      }, createMockContext(patient.id))
    ).rejects.toMatchObject({ code: 'deadline-exceeded' });

    const wrongStateAppointment = {
      ...appointment,
      id: 'phase4_join_003',
      status: 'completed',
    };
    await db.collection('appointments').doc(wrongStateAppointment.id).set(wrongStateAppointment);

    await expect(
      functionsTest.wrap(patientJoinCall)({
        appointmentId: wrongStateAppointment.id,
        patientId: patient.id,
      }, createMockContext(patient.id))
    ).rejects.toMatchObject({ code: 'failed-precondition' });

    const inactiveSessionAppointment = {
      ...appointment,
      id: 'phase4_join_004',
      callSessionActive: false,
    };
    await db.collection('appointments').doc(inactiveSessionAppointment.id).set(inactiveSessionAppointment);

    await expect(
      functionsTest.wrap(patientJoinCall)({
        appointmentId: inactiveSessionAppointment.id,
        patientId: patient.id,
      }, createMockContext(patient.id))
    ).rejects.toMatchObject({ code: 'failed-precondition' });
  });
});
