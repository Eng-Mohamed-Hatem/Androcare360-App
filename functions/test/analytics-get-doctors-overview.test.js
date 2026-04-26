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

describe('getDoctorsOverview', () => {
  const wrapped = functionsTest.wrap(analytics.getDoctorsOverview);
  const adminContext = createMockContext('admin-1', { userType: 'admin' });

  test('applies financial rule, commission, score, pagination, and admin auth', async () => {
    await db.collection('users').doc('admin-1').set({ userType: 'admin' });
    await db.doc('platform_settings/commission').set({ rate: 0.2 });
    await db.collection('users').doc('doctor-1').set({
      userType: 'doctor',
      isActive: true,
      name: 'Doctor One',
      clinicType: 'chronic_diseases',
      rating: 4.5,
    });
    await db.collection('users').doc('doctor-2').set({
      userType: 'doctor',
      isActive: true,
      name: 'Doctor Two',
      clinicType: 'chronic_diseases',
      rating: 3,
    });

    await db.collection('appointments').add({
      doctorId: 'doctor-1',
      patientId: 'p1',
      status: 'completed',
      fee: 100,
      clinicType: 'chronic_diseases',
      createdAt: ts('2026-04-02T10:00:00Z'),
      completedAt: ts('2026-04-02T11:00:00Z'),
    });
    await db.collection('appointments').add({
      doctorId: 'doctor-1',
      patientId: 'p2',
      status: 'completed',
      fee: 0,
      clinicType: 'chronic_diseases',
      createdAt: ts('2026-04-03T10:00:00Z'),
      completedAt: ts('2026-04-03T11:00:00Z'),
    });
    await db.collection('appointments').add({
      doctorId: 'doctor-1',
      patientId: 'p3',
      status: 'not_completed',
      fee: 150,
      clinicType: 'chronic_diseases',
      createdAt: ts('2026-04-04T10:00:00Z'),
      completedAt: ts('2026-04-04T11:00:00Z'),
    });

    await expect(
      wrapped({ periodStart: '2026-04-01T00:00:00Z', periodEnd: '2026-04-30T23:59:59Z' }, {})
    ).rejects.toMatchObject({ code: 'unauthenticated' });

    const result = await wrapped({
      periodStart: '2026-04-01T00:00:00Z',
      periodEnd: '2026-04-30T23:59:59Z',
      sortBy: 'name',
      sortOrder: 'asc',
      pageSize: 1,
    }, adminContext);

    expect(result.doctors).toHaveLength(1);
    expect(result.hasMore).toBe(true);
    expect(result.nextCursor).toBe('doctor-1');

    const row = result.doctors[0];
    expect(row.totalRevenue).toBe(100);
    expect(row.platformCommission).toBe(20);
    expect(row.netPayout).toBe(80);
    expect(row.completionRate).toBeCloseTo(2 / 3, 4);
    expect(row.performanceScore.isOverviewScore).toBe(true);
    expect(row.performanceScore.missingDimensions).toEqual(['emrSpeed']);
  });
});
