/**
 * Test Setup Verification
 * 
 * This test file verifies that the test environment is configured correctly
 * and that fixtures are working as expected.
 */

const { admin, db, createMockContext } = require('./setup');
const {
  createAppointmentFixture,
  createDoctorFixture,
  createPatientFixture,
  createCallLogFixture,
  createAppointments,
  createDoctors,
} = require('./fixtures');

describe('Test Setup Verification', () => {
  describe('Firebase Emulator Connection', () => {
    test('should connect to Firestore emulator', async () => {
      const testDoc = await db.collection('test').add({ test: true });
      expect(testDoc.id).toBeDefined();
      
      // Cleanup
      await testDoc.delete();
    });

    test('should use elajtech database', () => {
      const settings = db._settings;
      expect(settings.databaseId).toBe('elajtech');
    });

    test('should connect to the Firestore emulator host', () => {
      const settings = db._settings;
      const emulatorHost = settings.host || `${settings.servicePath}:${settings.port}`;
      expect(['localhost:8080', '127.0.0.1:8080']).toContain(emulatorHost);
      expect(settings.ssl).toBe(false);
    });
  });

  describe('Appointment Fixtures', () => {
    test('should create appointment fixture with default values', () => {
      const appointment = createAppointmentFixture();
      
      expect(appointment.id).toBe('test_apt_001');
      expect(appointment.doctorId).toBe('doctor_001');
      expect(appointment.patientId).toBe('patient_001');
      expect(appointment.status).toBe('scheduled');
      expect(appointment.doctorName).toBeDefined();
      expect(appointment.patientName).toBeDefined();
    });

    test('should create appointment fixture with custom values', () => {
      const appointment = createAppointmentFixture({
        id: 'custom_apt_123',
        doctorId: 'custom_doctor',
        status: 'completed',
      });
      
      expect(appointment.id).toBe('custom_apt_123');
      expect(appointment.doctorId).toBe('custom_doctor');
      expect(appointment.status).toBe('completed');
    });

    test('should create multiple appointments', () => {
      const appointments = createAppointments(5);
      
      expect(appointments).toHaveLength(5);
      expect(appointments[0].id).toBe('test_apt_001');
      expect(appointments[4].id).toBe('test_apt_005');
    });

    test('should create multiple appointments with custom overrides', () => {
      const appointments = createAppointments(3, (i) => ({
        doctorId: `doctor_${i + 1}`,
        status: i % 2 === 0 ? 'scheduled' : 'completed',
      }));
      
      expect(appointments).toHaveLength(3);
      expect(appointments[0].doctorId).toBe('doctor_1');
      expect(appointments[0].status).toBe('scheduled');
      expect(appointments[1].status).toBe('completed');
    });
  });

  describe('User Fixtures', () => {
    test('should create doctor fixture', () => {
      const doctor = createDoctorFixture();
      
      expect(doctor.id).toBe('doctor_001');
      expect(doctor.userType).toBe('doctor');
      expect(doctor.fcmToken).toBeDefined();
      expect(doctor.email).toBeDefined();
      expect(doctor.specialization).toBeDefined();
    });

    test('should create patient fixture', () => {
      const patient = createPatientFixture();
      
      expect(patient.id).toBe('patient_001');
      expect(patient.userType).toBe('patient');
      expect(patient.fcmToken).toBeDefined();
      expect(patient.email).toBeDefined();
    });

    test('should create multiple doctors', () => {
      const doctors = createDoctors(3);
      
      expect(doctors).toHaveLength(3);
      expect(doctors[0].id).toBe('doctor_001');
      expect(doctors[0].email).toBe('doctor1@test.com');
      expect(doctors[2].id).toBe('doctor_003');
      expect(doctors[2].email).toBe('doctor3@test.com');
    });
  });

  describe('Call Log Fixtures', () => {
    test('should create call log fixture', () => {
      const callLog = createCallLogFixture();
      
      expect(callLog.eventType).toBe('call_attempt');
      expect(callLog.appointmentId).toBe('test_apt_001');
      expect(callLog.userId).toBe('doctor_001');
      expect(callLog.timestamp).toBeInstanceOf(Date);
      expect(callLog.deviceInfo).toBeDefined();
      expect(callLog.deviceInfo.platform).toBe('android');
    });

    test('should create call log with custom event type', () => {
      const callLog = createCallLogFixture({
        eventType: 'call_error',
        errorCode: 'appointment_not_found',
        errorMessage: 'الموعد غير موجود',
      });
      
      expect(callLog.eventType).toBe('call_error');
      expect(callLog.errorCode).toBe('appointment_not_found');
      expect(callLog.errorMessage).toBe('الموعد غير موجود');
    });
  });

  describe('Mock Context', () => {
    test('should create mock authentication context', () => {
      const context = createMockContext('doctor_001');
      
      expect(context.auth).toBeDefined();
      expect(context.auth.uid).toBe('doctor_001');
      expect(context.auth.token).toBeDefined();
    });

    test('should create mock context with custom claims', () => {
      const context = createMockContext('doctor_001', {
        userType: 'doctor',
        email: 'doctor@test.com',
      });
      
      expect(context.auth.uid).toBe('doctor_001');
      expect(context.auth.token.userType).toBe('doctor');
      expect(context.auth.token.email).toBe('doctor@test.com');
    });
  });

  describe('Firestore Operations', () => {
    test('should write and read appointment from elajtech database', async () => {
      const appointment = createAppointmentFixture();
      
      // Write to Firestore
      await db.collection('appointments').doc(appointment.id).set(appointment);
      
      // Read from Firestore
      const doc = await db.collection('appointments').doc(appointment.id).get();
      
      expect(doc.exists).toBe(true);
      expect(doc.data().doctorId).toBe(appointment.doctorId);
      expect(doc.data().patientId).toBe(appointment.patientId);
    });

    test('should write and read user from elajtech database', async () => {
      const doctor = createDoctorFixture();
      
      // Write to Firestore
      await db.collection('users').doc(doctor.id).set(doctor);
      
      // Read from Firestore
      const doc = await db.collection('users').doc(doctor.id).get();
      
      expect(doc.exists).toBe(true);
      expect(doc.data().userType).toBe('doctor');
      expect(doc.data().fcmToken).toBe(doctor.fcmToken);
    });

    test('should write and read call log from elajtech database', async () => {
      const callLog = createCallLogFixture();
      
      // Write to Firestore
      const docRef = await db.collection('call_logs').add(callLog);
      
      // Read from Firestore
      const doc = await docRef.get();
      
      expect(doc.exists).toBe(true);
      expect(doc.data().eventType).toBe(callLog.eventType);
      expect(doc.data().appointmentId).toBe(callLog.appointmentId);
    });
  });
});
