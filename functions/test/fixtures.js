/**
 * Test Fixtures for AndroCare360 Cloud Functions
 * 
 * This file provides reusable test data for appointments, users, and call logs.
 * All fixtures support customization via the overrides parameter.
 * 
 * Usage:
 *   const appointment = createAppointmentFixture({ doctorId: 'custom_doctor' });
 *   const appointments = createAppointments(10);
 */

// ============================================================================
// APPOINTMENT FIXTURES
// ============================================================================

/**
 * Create a test appointment fixture
 * 
 * @param {object} overrides - Custom values to override defaults
 * @returns {object} Appointment data
 */
function createAppointmentFixture(overrides = {}) {
  return {
    id: overrides.id || 'test_apt_001',
    doctorId: overrides.doctorId || 'doctor_001',
    patientId: overrides.patientId || 'patient_001',
    doctorName: overrides.doctorName || 'Dr. Test Doctor',
    patientName: overrides.patientName || 'Test Patient',
    status: overrides.status || 'scheduled',
    scheduledAt: overrides.scheduledAt || new Date('2026-02-15T10:00:00Z'),
    createdAt: overrides.createdAt || new Date('2026-02-13T08:00:00Z'),
    specialization: overrides.specialization || 'General Medicine',
    duration: overrides.duration || 30, // minutes
    ...overrides,
  };
}

/**
 * Create an appointment with call data (for testing ongoing/completed calls)
 * 
 * @param {object} overrides - Custom values to override defaults
 * @returns {object} Appointment data with Agora call information
 */
function createAppointmentWithCallDataFixture(overrides = {}) {
  return {
    ...createAppointmentFixture(overrides),
    agoraChannelName: overrides.agoraChannelName || `test_channel_${Date.now()}`,
    agoraToken: overrides.agoraToken || 'test_patient_token_abc123',
    agoraUid: overrides.agoraUid || 12345,
    doctorAgoraToken: overrides.doctorAgoraToken || 'test_doctor_token_xyz789',
    doctorAgoraUid: overrides.doctorAgoraUid || 67890,
    meetingProvider: 'agora',
    callStartedAt: overrides.callStartedAt || new Date(),
    status: overrides.status || 'on_call',
  };
}

/**
 * Create a completed appointment fixture
 * 
 * @param {object} overrides - Custom values to override defaults
 * @returns {object} Completed appointment data
 */
function createCompletedAppointmentFixture(overrides = {}) {
  const now = new Date();
  const oneHourAgo = new Date(now.getTime() - 60 * 60 * 1000);
  
  return {
    ...createAppointmentWithCallDataFixture(overrides),
    status: 'completed',
    callStartedAt: overrides.callStartedAt || oneHourAgo,
    callEndedAt: overrides.callEndedAt || now,
    completedAt: overrides.completedAt || now,
  };
}

// ============================================================================
// USER FIXTURES
// ============================================================================

/**
 * Create a test doctor fixture
 * 
 * @param {object} overrides - Custom values to override defaults
 * @returns {object} Doctor user data
 */
function createDoctorFixture(overrides = {}) {
  return {
    id: overrides.id || 'doctor_001',
    fullName: overrides.fullName || 'Dr. Test Doctor',
    email: overrides.email || 'doctor@test.com',
    userType: 'doctor',
    specialization: overrides.specialization || 'General Medicine',
    fcmToken: overrides.fcmToken || 'doctor_fcm_token_123456',
    phoneNumber: overrides.phoneNumber || '+966501234567',
    licenseNumber: overrides.licenseNumber || 'DOC-12345',
    yearsOfExperience: overrides.yearsOfExperience || 10,
    rating: overrides.rating || 4.8,
    consultationFee: overrides.consultationFee || 200,
    isAvailable: overrides.isAvailable !== undefined ? overrides.isAvailable : true,
    createdAt: overrides.createdAt || new Date('2025-01-01T00:00:00Z'),
    ...overrides,
  };
}

/**
 * Create a test patient fixture
 * 
 * @param {object} overrides - Custom values to override defaults
 * @returns {object} Patient user data
 */
function createPatientFixture(overrides = {}) {
  return {
    id: overrides.id || 'patient_001',
    fullName: overrides.fullName || 'Test Patient',
    email: overrides.email || 'patient@test.com',
    userType: 'patient',
    fcmToken: overrides.fcmToken || 'patient_fcm_token_789012',
    phoneNumber: overrides.phoneNumber || '+966507654321',
    dateOfBirth: overrides.dateOfBirth || new Date('1990-01-01'),
    gender: overrides.gender || 'male',
    bloodType: overrides.bloodType || 'O+',
    allergies: overrides.allergies || [],
    chronicDiseases: overrides.chronicDiseases || [],
    createdAt: overrides.createdAt || new Date('2025-06-01T00:00:00Z'),
    ...overrides,
  };
}

// ============================================================================
// CALL LOG FIXTURES
// ============================================================================

/**
 * Create a test call log fixture
 * 
 * @param {object} overrides - Custom values to override defaults
 * @returns {object} Call log data
 */
function createCallLogFixture(overrides = {}) {
  return {
    eventType: overrides.eventType || 'call_attempt',
    appointmentId: overrides.appointmentId || 'test_apt_001',
    userId: overrides.userId || 'doctor_001',
    timestamp: overrides.timestamp || new Date(),
    errorCode: overrides.errorCode || null,
    errorMessage: overrides.errorMessage || null,
    stackTrace: overrides.stackTrace || null,
    deviceInfo: overrides.deviceInfo || {
      platform: 'android',
      deviceModel: 'Samsung Galaxy S21',
      manufacturer: 'Samsung',
      osVersion: 'Android 13',
      appVersion: '1.0.0',
      connectionType: 'wifi',
    },
    metadata: overrides.metadata || {},
    ...overrides,
  };
}

/**
 * Create a call attempt log fixture
 * 
 * @param {object} overrides - Custom values to override defaults
 * @returns {object} Call attempt log data
 */
function createCallAttemptLogFixture(overrides = {}) {
  return createCallLogFixture({
    eventType: 'call_attempt',
    ...overrides,
  });
}

/**
 * Create a call started log fixture
 * 
 * @param {object} overrides - Custom values to override defaults
 * @returns {object} Call started log data
 */
function createCallStartedLogFixture(overrides = {}) {
  return createCallLogFixture({
    eventType: 'call_started',
    metadata: {
      channelName: overrides.channelName || 'test_channel_001',
      doctorUid: overrides.doctorUid || 67890,
      ...overrides.metadata,
    },
    ...overrides,
  });
}

/**
 * Create a call error log fixture
 * 
 * @param {object} overrides - Custom values to override defaults
 * @returns {object} Call error log data
 */
function createCallErrorLogFixture(overrides = {}) {
  return createCallLogFixture({
    eventType: 'call_error',
    errorCode: overrides.errorCode || 'appointment_not_found',
    errorMessage: overrides.errorMessage || 'الموعد غير موجود',
    stackTrace: overrides.stackTrace || 'Error: Appointment not found\n    at ...',
    ...overrides,
  });
}

/**
 * Create a call ended log fixture
 * 
 * @param {object} overrides - Custom values to override defaults
 * @returns {object} Call ended log data
 */
function createCallEndedLogFixture(overrides = {}) {
  return createCallLogFixture({
    eventType: 'call_ended',
    metadata: {
      duration: overrides.duration || 1800, // 30 minutes in seconds
      ...overrides.metadata,
    },
    ...overrides,
  });
}

// ============================================================================
// FACTORY FUNCTIONS (Generate Multiple Records)
// ============================================================================

/**
 * Generate multiple appointment fixtures
 * 
 * @param {number} count - Number of appointments to generate
 * @param {function} overridesFn - Function that returns overrides for each appointment
 * @returns {Array<object>} Array of appointment fixtures
 * 
 * @example
 * const appointments = createAppointments(5, (i) => ({
 *   doctorId: `doctor_${i + 1}`,
 *   status: i % 2 === 0 ? 'scheduled' : 'completed'
 * }));
 */
function createAppointments(count, overridesFn = () => ({})) {
  return Array.from({ length: count }, (_, i) => 
    createAppointmentFixture({
      id: `test_apt_${String(i + 1).padStart(3, '0')}`,
      ...overridesFn(i),
    })
  );
}

/**
 * Generate multiple doctor fixtures
 * 
 * @param {number} count - Number of doctors to generate
 * @param {function} overridesFn - Function that returns overrides for each doctor
 * @returns {Array<object>} Array of doctor fixtures
 */
function createDoctors(count, overridesFn = () => ({})) {
  return Array.from({ length: count }, (_, i) => 
    createDoctorFixture({
      id: `doctor_${String(i + 1).padStart(3, '0')}`,
      email: `doctor${i + 1}@test.com`,
      fullName: `Dr. Test Doctor ${i + 1}`,
      fcmToken: `doctor_fcm_token_${i + 1}`,
      ...overridesFn(i),
    })
  );
}

/**
 * Generate multiple patient fixtures
 * 
 * @param {number} count - Number of patients to generate
 * @param {function} overridesFn - Function that returns overrides for each patient
 * @returns {Array<object>} Array of patient fixtures
 */
function createPatients(count, overridesFn = () => ({})) {
  return Array.from({ length: count }, (_, i) => 
    createPatientFixture({
      id: `patient_${String(i + 1).padStart(3, '0')}`,
      email: `patient${i + 1}@test.com`,
      fullName: `Test Patient ${i + 1}`,
      fcmToken: `patient_fcm_token_${i + 1}`,
      ...overridesFn(i),
    })
  );
}

/**
 * Generate multiple call log fixtures
 * 
 * @param {number} count - Number of call logs to generate
 * @param {function} overridesFn - Function that returns overrides for each log
 * @returns {Array<object>} Array of call log fixtures
 */
function createCallLogs(count, overridesFn = () => ({})) {
  const eventTypes = ['call_attempt', 'call_started', 'call_error', 'call_ended'];
  
  return Array.from({ length: count }, (_, i) => 
    createCallLogFixture({
      eventType: eventTypes[i % eventTypes.length],
      appointmentId: `test_apt_${String((i % 10) + 1).padStart(3, '0')}`,
      timestamp: new Date(Date.now() - i * 60000), // Each log 1 minute apart
      ...overridesFn(i),
    })
  );
}

// ============================================================================
// EXPORTS
// ============================================================================

module.exports = {
  // Single Appointment Fixtures
  createAppointmentFixture,
  createAppointmentWithCallDataFixture,
  createCompletedAppointmentFixture,
  
  // Single User Fixtures
  createDoctorFixture,
  createPatientFixture,
  
  // Single Call Log Fixtures
  createCallLogFixture,
  createCallAttemptLogFixture,
  createCallStartedLogFixture,
  createCallErrorLogFixture,
  createCallEndedLogFixture,
  
  // Factory Functions (Multiple Records)
  createAppointments,
  createDoctors,
  createPatients,
  createCallLogs,
};
