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

async function seedBase() {
  await db.collection('users').doc('admin-1').set({ userType: 'admin' });
  await db.doc('platform_settings/commission').set({ rate: 0.15 });
  await db.collection('users').doc('doctor-1').set({
    userType: 'doctor',
    isActive: true,
    fullName: 'Time Doctor',
    clinicType: 'chronic_diseases',
    rating: 5,
    reviewsCount: 5,
  });
}

async function addAppointment(id, completedAt, fee = 100) {
  await db.collection('appointments').doc(id).set({
    doctorId: 'doctor-1',
    patientId: `patient-${id}`,
    status: 'completed',
    fee,
    type: 'video',
    clinicType: 'chronic_diseases',
    createdAt: ts(completedAt),
    completedAt: ts(completedAt),
    confirmedAt: ts(completedAt),
    scheduledDateTime: ts(completedAt),
  });
}

describe('time-series aggregation', () => {
  const wrapped = functionsTest.wrap(analytics.getDoctorAnalyticsDetail);
  const adminContext = createMockContext('admin-1', { userType: 'admin' });

  test('groups daily buckets and calculates period-over-period change', async () => {
    await seedBase();
    await addAppointment('prev-1', '2026-03-03T10:00:00Z');
    await addAppointment('prev-2', '2026-03-04T10:00:00Z');
    await addAppointment('cur-1', '2026-04-01T10:00:00Z');
    await addAppointment('cur-2', '2026-04-02T10:00:00Z');
    await addAppointment('cur-3', '2026-04-03T10:00:00Z');

    const result = await wrapped({
      doctorId: 'doctor-1',
      periodStart: '2026-04-01T00:00:00Z',
      periodEnd: '2026-04-30T23:59:59Z',
      granularity: 'daily',
    }, adminContext);

    expect(result.timeSeriesData.granularity).toBe('daily');
    expect(result.timeSeriesData.dataPoints.map((p) => p.date)).toEqual([
      '2026-04-01',
      '2026-04-02',
      '2026-04-03',
    ]);
    expect(result.timeSeriesData.hasComparison).toBe(true);
    expect(result.timeSeriesData.comparison.changePercent.appointments).toBe(50);
    expect(result.timeSeriesData.comparison.changePercent.revenue).toBe(50);
    expect(result.timeSeriesData.dataPoints.every((p) => p.isMarker === false)).toBe(true);
  });

  test('omits comparison when previous period total is zero and marks sparse data', async () => {
    await seedBase();
    await addAppointment('cur-1', '2026-04-01T10:00:00Z');

    const result = await wrapped({
      doctorId: 'doctor-1',
      periodStart: '2026-04-01T00:00:00Z',
      periodEnd: '2026-04-30T23:59:59Z',
      granularity: 'daily',
    }, adminContext);

    expect(result.timeSeriesData.hasComparison).toBe(false);
    expect(result.timeSeriesData.comparison).toBeNull();
    expect(result.timeSeriesData.dataPoints).toHaveLength(1);
    expect(result.timeSeriesData.dataPoints[0].isMarker).toBe(true);
  });

  test('rejects missing admin auth', async () => {
    await seedBase();

    await expect(
      wrapped({
        doctorId: 'doctor-1',
        periodStart: '2026-04-01T00:00:00Z',
        periodEnd: '2026-04-30T23:59:59Z',
      }, {})
    ).rejects.toMatchObject({ code: 'unauthenticated' });
  });
});
