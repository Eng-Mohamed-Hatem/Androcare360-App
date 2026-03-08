# AndroCare360 Cloud Functions Test Suite

This directory contains the test infrastructure for AndroCare360 Cloud Functions, specifically designed to test the VoIP appointment bugfix with the 'elajtech' database configuration.

## 📁 File Structure

```
test/
├── README.md           # This file
├── setup.js            # Test environment configuration
├── fixtures.js         # Reusable test data
└── setup.test.js       # Setup verification tests
```

## 🚀 Quick Start

### Prerequisites

1. **Firebase CLI** installed:
   ```bash
   npm install -g firebase-tools
   ```

2. **Node.js 20** (or compatible version)

3. **Firebase Emulators** initialized:
   ```bash
   firebase init emulators
   ```

### Running Tests

#### 1. Start Firebase Emulators

In one terminal, start the emulators:

```bash
firebase emulators:start
```

This will start:
- Firestore Emulator on `localhost:8080`
- Auth Emulator on `localhost:9099`
- Functions Emulator on `localhost:5001`
- Emulator UI on `localhost:4000`

#### 2. Run Tests

In another terminal, run the tests:

```bash
cd functions
npm test
```

#### 3. Run Tests with Coverage

```bash
npm run test:coverage
```

#### 4. Run Tests in Watch Mode

```bash
npm run test:watch
```

## 📝 Test Files

### `setup.js`

Configures the test environment:

- ✅ Initializes Firebase Admin SDK with 'elajtech' database
- ✅ Connects to Firestore Emulator (localhost:8080)
- ✅ Connects to Auth Emulator (localhost:9099)
- ✅ Sets environment variables for emulator mode
- ✅ Provides test utilities (clearFirestoreData, createMockContext, wait)
- ✅ Implements Jest lifecycle hooks (beforeAll, afterEach, afterAll)

**Critical Configuration:**
```javascript
db.settings({
  host: 'localhost:8080',
  ssl: false,
  databaseId: 'elajtech', // ✅ CRITICAL: Explicit database ID
});
```

### `fixtures.js`

Provides reusable test data:

**Single Fixtures:**
- `createAppointmentFixture()` - Basic appointment
- `createAppointmentWithCallDataFixture()` - Appointment with Agora data
- `createCompletedAppointmentFixture()` - Completed appointment
- `createDoctorFixture()` - Doctor user
- `createPatientFixture()` - Patient user
- `createCallLogFixture()` - Call log entry
- `createCallAttemptLogFixture()` - Call attempt log
- `createCallStartedLogFixture()` - Call started log
- `createCallErrorLogFixture()` - Call error log
- `createCallEndedLogFixture()` - Call ended log

**Factory Functions:**
- `createAppointments(count, overridesFn)` - Multiple appointments
- `createDoctors(count, overridesFn)` - Multiple doctors
- `createPatients(count, overridesFn)` - Multiple patients
- `createCallLogs(count, overridesFn)` - Multiple call logs

**Usage Example:**
```javascript
const { createAppointmentFixture, createDoctorFixture } = require('./fixtures');

// Create single appointment
const appointment = createAppointmentFixture({
  doctorId: 'custom_doctor',
  status: 'completed',
});

// Create multiple appointments
const appointments = createAppointments(10, (i) => ({
  doctorId: `doctor_${i + 1}`,
  status: i % 2 === 0 ? 'scheduled' : 'completed',
}));
```

### `setup.test.js`

Verification tests to ensure the test environment is configured correctly:

- ✅ Firestore emulator connection
- ✅ Database ID configuration ('elajtech')
- ✅ Fixture creation and customization
- ✅ Factory functions
- ✅ Mock authentication context
- ✅ Firestore read/write operations

## 🧪 Writing Tests

### Basic Test Structure

```javascript
const { db, createMockContext } = require('./setup');
const { createAppointmentFixture, createDoctorFixture } = require('./fixtures');

describe('My Test Suite', () => {
  test('should do something', async () => {
    // Arrange: Create test data
    const appointment = createAppointmentFixture();
    await db.collection('appointments').doc(appointment.id).set(appointment);
    
    // Act: Perform operation
    const doc = await db.collection('appointments').doc(appointment.id).get();
    
    // Assert: Verify results
    expect(doc.exists).toBe(true);
    expect(doc.data().doctorId).toBe(appointment.doctorId);
  });
});
```

### Testing Cloud Functions

```javascript
const { startAgoraCall } = require('../index');
const { createMockContext } = require('./setup');
const { createAppointmentFixture, createDoctorFixture } = require('./fixtures');

describe('startAgoraCall', () => {
  test('should start call successfully', async () => {
    // Arrange
    const appointment = createAppointmentFixture();
    const doctor = createDoctorFixture({ id: appointment.doctorId });
    
    await db.collection('appointments').doc(appointment.id).set(appointment);
    await db.collection('users').doc(doctor.id).set(doctor);
    
    const context = createMockContext(doctor.id);
    
    // Act
    const result = await startAgoraCall({
      appointmentId: appointment.id,
      doctorId: doctor.id,
    }, context);
    
    // Assert
    expect(result.success).toBe(true);
    expect(result.agoraToken).toBeDefined();
    expect(result.agoraChannelName).toBeDefined();
  });
});
```

## 🔍 Debugging Tests

### View Emulator UI

Open http://localhost:4000 to view:
- Firestore data
- Auth users
- Function logs

### Enable Verbose Logging

```bash
npm test -- --verbose
```

### Run Specific Test File

```bash
npm test -- setup.test.js
```

### Run Specific Test

```bash
npm test -- -t "should connect to Firestore emulator"
```

## ✅ Verification Checklist

Before writing integration tests, verify:

- [ ] Firebase Emulators are running
- [ ] `npm test` runs successfully
- [ ] All setup verification tests pass
- [ ] Emulator UI is accessible at http://localhost:4000
- [ ] Firestore shows 'elajtech' database in UI
- [ ] Test data is created and cleaned up correctly

## 🐛 Troubleshooting

### Error: "Cannot find module './setup'"

Make sure you're running tests from the `functions` directory:
```bash
cd functions
npm test
```

### Error: "ECONNREFUSED localhost:8080"

Start the Firebase Emulators first:
```bash
firebase emulators:start
```

### Error: "Database not found"

Verify the database ID in `setup.js`:
```javascript
db.settings({
  databaseId: 'elajtech', // Must match production
});
```

### Tests Hang or Don't Exit

Use the `--detectOpenHandles` flag:
```bash
npm test -- --detectOpenHandles
```

Or add `--forceExit`:
```bash
npm test -- --forceExit
```

## 📚 Next Steps

After verifying the test setup:

1. **Task 3**: Implement unit tests for database configuration
2. **Task 4**: Implement integration tests for Cloud Functions
3. **Task 5**: Implement database isolation tests
4. **Task 6**: Run all tests and verify pass rate

## 🔗 Related Documentation

- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)
- [AndroCare360 VoIP Bugfix Spec](../.kiro/specs/voip-appointment-not-found-bugfix/)

---

**Last Updated:** 2026-02-13  
**Version:** 1.0.0  
**Maintained by:** AndroCare360 Development Team
