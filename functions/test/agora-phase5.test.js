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
  autoCompleteExpiredConfirmationsInternal,
  confirmAppointmentCompletion,
} = require('../index');

describe('Phase 5 confirmation expiry workflow', () => {
  test('autoCompleteExpiredConfirmations marks expired pending confirmations as not_completed', async () => {
    const appointment = createAppointmentWithCallDataFixture({
      id: 'phase5_auto_001',
      doctorId: 'phase5_doctor_001',
      patientId: 'phase5_patient_001',
      status: 'ended_pending_confirmation',
      confirmationDeadlineAt: new Date(Date.now() - 26 * 3600 * 1000),
      callEndedAt: new Date(Date.now() - 25 * 3600 * 1000),
      callSessionActive: false,
    });
    const doctor = createDoctorFixture({ id: appointment.doctorId });
    const patient = createPatientFixture({ id: appointment.patientId });

    await db.collection('appointments').doc(appointment.id).set(appointment);
    await db.collection('users').doc(doctor.id).set(doctor);
    await db.collection('users').doc(patient.id).set(patient);

    const result = await autoCompleteExpiredConfirmationsInternal(new Date());

    expect(result.processed).toBe(1);

    const updated = (await db.collection('appointments').doc(appointment.id).get()).data();
    expect(updated.status).toBe('not_completed');
    expect(updated.notCompletedAt).toBeDefined();
  });

  test('autoCompleteExpiredConfirmations skips already-resolved appointments', async () => {
    const appointment = createAppointmentWithCallDataFixture({
      id: 'phase5_auto_002',
      doctorId: 'phase5_doctor_002',
      patientId: 'phase5_patient_002',
      status: 'completed',
      confirmationDeadlineAt: new Date(Date.now() - 26 * 3600 * 1000),
      completedAt: new Date(Date.now() - 25 * 3600 * 1000),
    });

    await db.collection('appointments').doc(appointment.id).set(appointment);

    const result = await autoCompleteExpiredConfirmationsInternal(new Date());

    expect(result.processed).toBe(0);

    const updated = (await db.collection('appointments').doc(appointment.id).get()).data();
    expect(updated.status).toBe('completed');
  });

  test('doctor confirmation beats auto-complete race condition', async () => {
    const appointment = createAppointmentWithCallDataFixture({
      id: 'phase5_auto_003',
      doctorId: 'phase5_doctor_003',
      patientId: 'phase5_patient_003',
      status: 'ended_pending_confirmation',
      confirmationDeadlineAt: new Date(Date.now() - 26 * 3600 * 1000),
    });
    const doctor = createDoctorFixture({ id: appointment.doctorId });
    const patient = createPatientFixture({ id: appointment.patientId });

    await db.collection('appointments').doc(appointment.id).set(appointment);
    await db.collection('users').doc(doctor.id).set(doctor);
    await db.collection('users').doc(patient.id).set(patient);

    const confirmResult = await functionsTest.wrap(confirmAppointmentCompletion)({
      appointmentId: appointment.id,
      doctorId: doctor.id,
      completed: true,
    }, createMockContext(doctor.id));
    expect(confirmResult.success).toBe(true);

    const result = await autoCompleteExpiredConfirmationsInternal(new Date());
    expect(result.processed).toBe(0);

    const updated = (await db.collection('appointments').doc(appointment.id).get()).data();
    expect(updated.status).toBe('completed');
    expect(updated.notCompletedAt).toBeUndefined();
  });
});
