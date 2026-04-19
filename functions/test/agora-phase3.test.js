const {
  db,
  createMockContext,
  functionsTest,
} = require('./setup');
const {
  createAppointmentFixture,
  createAppointmentWithCallDataFixture,
  createDoctorFixture,
  createPatientFixture,
} = require('./fixtures');
const {
  startAgoraCall,
  endAgoraCall,
  confirmAppointmentCompletion,
  markCallInProgress,
} = require('../index');

describe('Phase 3 Agora workflow', () => {
  test('startAgoraCall writes calling state and rejects duplicate initiation', async () => {
    const appointment = createAppointmentFixture({
      id: 'phase3_start_001',
      doctorId: 'phase3_doctor_001',
      patientId: 'phase3_patient_001',
      status: 'scheduled',
    });
    const doctor = createDoctorFixture({ id: appointment.doctorId });
    const patient = createPatientFixture({ id: appointment.patientId });

    await db.collection('appointments').doc(appointment.id).set(appointment);
    await db.collection('users').doc(doctor.id).set(doctor);
    await db.collection('users').doc(patient.id).set(patient);

    const context = createMockContext(doctor.id);
    const result = await functionsTest.wrap(startAgoraCall)({
      appointmentId: appointment.id,
      doctorId: doctor.id,
    }, context);

    expect(result.success).toBe(true);

    const updated = (await db.collection('appointments').doc(appointment.id).get()).data();
    expect(updated.status).toBe('calling');
    expect(updated.callSessionId).toBe(result.agoraChannelName);
    expect(updated.callStartedAt).toBeDefined();

    await expect(
      functionsTest.wrap(startAgoraCall)({
        appointmentId: appointment.id,
        doctorId: doctor.id,
      }, context)
    ).rejects.toMatchObject({ code: 'failed-precondition' });
  });

  test('endAgoraCall moves in-progress calls to ended_pending_confirmation', async () => {
    const appointment = createAppointmentWithCallDataFixture({
      id: 'phase3_end_001',
      doctorId: 'phase3_doctor_002',
      patientId: 'phase3_patient_002',
      status: 'in_progress',
      callStatus: 'ringing',
      callSessionId: 'phase3_channel_002',
    });
    const doctor = createDoctorFixture({ id: appointment.doctorId });

    await db.collection('appointments').doc(appointment.id).set(appointment);
    await db.collection('users').doc(doctor.id).set(doctor);

    const result = await functionsTest.wrap(endAgoraCall)({
      appointmentId: appointment.id,
    }, createMockContext(doctor.id));

    expect(result.success).toBe(true);

    const updated = (await db.collection('appointments').doc(appointment.id).get()).data();
    expect(updated.status).toBe('ended_pending_confirmation');
    expect(updated.callStatus).toBe('ended');
    expect(updated.callEndedAt).toBeDefined();
    expect(updated.confirmationDeadlineAt).toBeDefined();
  });

  test('endAgoraCall keeps unanswered calls in missed state', async () => {
    const appointment = createAppointmentWithCallDataFixture({
      id: 'phase3_end_missed_001',
      doctorId: 'phase3_doctor_003',
      patientId: 'phase3_patient_003',
      status: 'calling',
      callSessionId: 'phase3_channel_003',
    });
    const doctor = createDoctorFixture({ id: appointment.doctorId });

    await db.collection('appointments').doc(appointment.id).set(appointment);
    await db.collection('users').doc(doctor.id).set(doctor);

    await functionsTest.wrap(endAgoraCall)({
      appointmentId: appointment.id,
    }, createMockContext(doctor.id));

    const updated = (await db.collection('appointments').doc(appointment.id).get()).data();
    expect(updated.status).toBe('missed');
    expect(updated.callStatus).toBe('ended');
  });

  test('endAgoraCall ignores terminal appointments', async () => {
    const appointment = createAppointmentWithCallDataFixture({
      id: 'phase3_end_terminal_001',
      doctorId: 'phase3_doctor_003b',
      patientId: 'phase3_patient_003b',
      status: 'completed',
      callStatus: 'ended',
    });
    const doctor = createDoctorFixture({ id: appointment.doctorId });

    await db.collection('appointments').doc(appointment.id).set(appointment);
    await db.collection('users').doc(doctor.id).set(doctor);

    const result = await functionsTest.wrap(endAgoraCall)({
      appointmentId: appointment.id,
    }, createMockContext(doctor.id));

    expect(result.success).toBe(true);

    const updated = (await db.collection('appointments').doc(appointment.id).get()).data();
    expect(updated.status).toBe('completed');
    expect(updated.callStatus).toBe('ended');
    expect(updated.confirmationDeadlineAt).toBeUndefined();
  });

  test('confirmAppointmentCompletion handles completed, not_completed, wrong state, and idempotency', async () => {
    const baseAppointment = createAppointmentWithCallDataFixture({
      id: 'phase3_confirm_001',
      doctorId: 'phase3_doctor_004',
      patientId: 'phase3_patient_004',
      status: 'ended_pending_confirmation',
      callSessionId: 'phase3_channel_004',
    });
    const doctor = createDoctorFixture({ id: baseAppointment.doctorId });
    const patient = createPatientFixture({ id: baseAppointment.patientId });

    await db.collection('appointments').doc(baseAppointment.id).set(baseAppointment);
    await db.collection('users').doc(doctor.id).set(doctor);
    await db.collection('users').doc(patient.id).set(patient);

    const completeResult = await functionsTest.wrap(confirmAppointmentCompletion)({
      appointmentId: baseAppointment.id,
      doctorId: doctor.id,
      completed: true,
    }, createMockContext(doctor.id));

    expect(completeResult.success).toBe(true);

    let updated = (await db.collection('appointments').doc(baseAppointment.id).get()).data();
    expect(updated.status).toBe('completed');
    expect(updated.completedAt).toBeDefined();

    const idempotentResult = await functionsTest.wrap(confirmAppointmentCompletion)({
      appointmentId: baseAppointment.id,
      doctorId: doctor.id,
      completed: true,
    }, createMockContext(doctor.id));
    expect(idempotentResult.success).toBe(true);
    expect(idempotentResult.status).toBe('completed');

    const notCompletedAppointment = {
      ...baseAppointment,
      id: 'phase3_confirm_002',
      status: 'ended_pending_confirmation',
    };
    await db.collection('appointments').doc(notCompletedAppointment.id).set(notCompletedAppointment);

    const notCompletedResult = await functionsTest.wrap(confirmAppointmentCompletion)({
      appointmentId: notCompletedAppointment.id,
      doctorId: doctor.id,
      completed: false,
    }, createMockContext(doctor.id));

    expect(notCompletedResult.success).toBe(true);
    updated = (await db.collection('appointments').doc(notCompletedAppointment.id).get()).data();
    expect(updated.status).toBe('not_completed');
    expect(updated.notCompletedAt).toBeDefined();

    const wrongStateAppointment = {
      ...baseAppointment,
      id: 'phase3_confirm_003',
      status: 'in_progress',
    };
    await db.collection('appointments').doc(wrongStateAppointment.id).set(wrongStateAppointment);

    await expect(
      functionsTest.wrap(confirmAppointmentCompletion)({
        appointmentId: wrongStateAppointment.id,
        doctorId: doctor.id,
        completed: true,
      }, createMockContext(doctor.id))
    ).rejects.toMatchObject({ code: 'failed-precondition' });

    await expect(
      functionsTest.wrap(confirmAppointmentCompletion)({
        appointmentId: wrongStateAppointment.id,
        doctorId: 'wrong_doctor',
        completed: true,
      }, createMockContext('wrong_doctor'))
    ).rejects.toMatchObject({ code: 'permission-denied' });
  });

  test('markCallInProgress updates active appointments once patient joins', async () => {
    const appointment = createAppointmentWithCallDataFixture({
      id: 'phase3_progress_001',
      doctorId: 'phase3_doctor_005',
      patientId: 'phase3_patient_005',
      status: 'calling',
    });
    const patient = createPatientFixture({ id: appointment.patientId });

    await db.collection('appointments').doc(appointment.id).set(appointment);
    await db.collection('users').doc(patient.id).set(patient);

    const result = await functionsTest.wrap(markCallInProgress)({
      appointmentId: appointment.id,
    }, createMockContext(patient.id));

    expect(result.success).toBe(true);

    const updated = (await db.collection('appointments').doc(appointment.id).get()).data();
    expect(updated.status).toBe('in_progress');
  });
});
