const {
  db,
  createMockContext,
  functionsTest,
} = require('./setup');
const {
  createAppointmentWithCallDataFixture,
  createDoctorFixture,
  createPatientFixture,
} = require('./fixtures');
const {
  handleCallDeclined,
  cancelCall,
} = require('../index');

describe('Phase 6 declined and cancel workflow', () => {
  test('handleCallDeclined writes declined state and is idempotent', async () => {
    const appointment = createAppointmentWithCallDataFixture({
      id: 'phase6_declined_001',
      doctorId: 'phase6_doctor_001',
      patientId: 'phase6_patient_001',
      status: 'calling',
      callStatus: 'ringing',
      callSessionActive: true,
    });
    const patient = createPatientFixture({ id: appointment.patientId });
    const doctor = createDoctorFixture({ id: appointment.doctorId });

    await db.collection('appointments').doc(appointment.id).set(appointment);
    await db.collection('users').doc(patient.id).set(patient);
    await db.collection('users').doc(doctor.id).set(doctor);

    const result = await functionsTest.wrap(handleCallDeclined)({
      appointmentId: appointment.id,
    }, createMockContext(patient.id));

    expect(result.success).toBe(true);

    let updated = (await db.collection('appointments').doc(appointment.id).get()).data();
    expect(updated.status).toBe('declined');
    expect(updated.callStatus).toBe('declined');
    expect(updated.callSessionActive).toBe(false);
    expect(updated.declinedAt).toBeDefined();

    const idempotent = await functionsTest.wrap(handleCallDeclined)({
      appointmentId: appointment.id,
    }, createMockContext(patient.id));
    expect(idempotent.success).toBe(true);

    updated = (await db.collection('appointments').doc(appointment.id).get()).data();
    expect(updated.status).toBe('declined');
  });

  test('cancelCall resets calling appointment to scheduled and guards invalid state', async () => {
    const appointment = createAppointmentWithCallDataFixture({
      id: 'phase6_cancel_001',
      doctorId: 'phase6_doctor_002',
      patientId: 'phase6_patient_002',
      status: 'calling',
      callStatus: 'ringing',
      callSessionId: 'phase6_channel_002',
      callSessionActive: true,
      callStartedAt: new Date(),
    });
    const doctor = createDoctorFixture({ id: appointment.doctorId });

    await db.collection('appointments').doc(appointment.id).set(appointment);
    await db.collection('users').doc(doctor.id).set(doctor);

    const result = await functionsTest.wrap(cancelCall)({
      appointmentId: appointment.id,
      doctorId: doctor.id,
    }, createMockContext(doctor.id));

    expect(result.success).toBe(true);
    expect(result.status).toBe('scheduled');

    let updated = (await db.collection('appointments').doc(appointment.id).get()).data();
    expect(updated.status).toBe('scheduled');
    expect(updated.callSessionActive).toBe(false);
    expect(updated.callStatus).toBeUndefined();
    expect(updated.callSessionId).toBeUndefined();
    expect(updated.callStartedAt).toBeUndefined();

    const wrongStateAppointment = {
      ...appointment,
      id: 'phase6_cancel_002',
      status: 'declined',
      callStatus: 'declined',
    };
    await db.collection('appointments').doc(wrongStateAppointment.id).set(wrongStateAppointment);

    await expect(
      functionsTest.wrap(cancelCall)({
        appointmentId: wrongStateAppointment.id,
        doctorId: doctor.id,
      }, createMockContext(doctor.id))
    ).rejects.toMatchObject({ code: 'failed-precondition' });
  });
});
