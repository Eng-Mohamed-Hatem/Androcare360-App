const {
  admin,
  db,
  functionsTest,
  createMockContext,
} = require('./setup');
const analytics = require('../src/doctor_analytics');

function ts(date) {
  return admin.firestore.Timestamp.fromDate(new Date(date));
}

describe('getPlatformSummary', () => {
  const wrapped = functionsTest.wrap(analytics.getPlatformSummary);
  const adminContext = createMockContext('admin-1', { userType: 'admin' });

  test('aggregates active doctors and rejects missing auth', async () => {
    await db.collection('users').doc('admin-1').set({ userType: 'admin' });
    await db.doc('platform_settings/commission').set({ rate: 0.1 });
    await db.collection('users').doc('doctor-active').set({
      userType: 'doctor',
      isActive: true,
      name: 'Active Doctor',
      clinicType: 'chronic_diseases',
      rating: 5,
    });
    await db.collection('users').doc('doctor-inactive').set({
      userType: 'doctor',
      isActive: false,
      name: 'Inactive Doctor',
      clinicType: 'chronic_diseases',
      rating: 5,
    });
    await db
      .collection('doctor_payouts')
      .doc('doctor-active')
      .collection('transactions')
      .add({ amount: 30 });

    await db.collection('appointments').add({
      doctorId: 'doctor-active',
      patientId: 'p1',
      status: 'completed',
      fee: 200,
      clinicType: 'chronic_diseases',
      createdAt: ts('2026-04-02T10:00:00Z'),
      completedAt: ts('2026-04-02T11:00:00Z'),
    });
    await db.collection('appointments').add({
      doctorId: 'doctor-inactive',
      patientId: 'p2',
      status: 'completed',
      fee: 999,
      clinicType: 'chronic_diseases',
      createdAt: ts('2026-04-02T10:00:00Z'),
      completedAt: ts('2026-04-02T11:00:00Z'),
    });

    await expect(
      wrapped({ periodStart: '2026-04-01T00:00:00Z', periodEnd: '2026-04-30T23:59:59Z' }, {})
    ).rejects.toMatchObject({ code: 'unauthenticated' });

    const result = await wrapped({
      periodStart: '2026-04-01T00:00:00Z',
      periodEnd: '2026-04-30T23:59:59Z',
    }, adminContext);

    expect(result.activeDoctorsCount).toBe(1);
    expect(result.totalCompletedAppointments).toBe(1);
    expect(result.totalRevenue).toBe(200);
    expect(result.totalPendingPayouts).toBe(150);
    expect(result.averagePerformanceScore).toBeGreaterThan(0);
  });
});
