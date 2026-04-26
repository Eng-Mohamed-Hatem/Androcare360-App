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

describe('getDoctorAnalyticsDetail', () => {
  const wrapped = functionsTest.wrap(analytics.getDoctorAnalyticsDetail);
  const adminContext = createMockContext('admin-1', { userType: 'admin' });

  test('aggregates booking, response, financial, and performance detail', async () => {
    await db.collection('users').doc('admin-1').set({ userType: 'admin' });
    await db.doc('platform_settings/commission').set({ rate: 0.2 });
    await db.collection('users').doc('doctor-1').set({
      userType: 'doctor',
      isActive: true,
      fullName: 'Doctor Detail',
      clinicType: 'chronic_diseases',
      rating: 4,
      reviewsCount: 5,
    });

    const appointments = [
      {
        id: 'a0',
        patientId: 'p0',
        status: 'completed',
        fee: 50,
        type: 'video',
        createdAt: ts('2026-03-30T10:00:00Z'),
        confirmedAt: ts('2026-03-30T10:05:00Z'),
        scheduledDateTime: ts('2026-04-01T11:00:00Z'),
        completedAt: ts('2026-04-01T12:00:00Z'),
      },
      {
        id: 'a1',
        patientId: 'p1',
        status: 'completed',
        fee: 100,
        type: 'video',
        createdAt: ts('2026-04-02T10:00:00Z'),
        confirmedAt: ts('2026-04-02T10:10:00Z'),
        scheduledDateTime: ts('2026-04-02T11:00:00Z'),
        completedAt: ts('2026-04-02T12:00:00Z'),
      },
      {
        id: 'a2',
        patientId: 'p2',
        status: 'completed',
        fee: 200,
        type: 'video',
        createdAt: ts('2026-04-03T10:00:00Z'),
        confirmedAt: ts('2026-04-03T10:20:00Z'),
        scheduledDateTime: ts('2026-04-03T11:00:00Z'),
        completedAt: ts('2026-04-03T12:00:00Z'),
      },
      {
        id: 'a3',
        patientId: 'p3',
        status: 'completed',
        fee: 0,
        type: 'clinic',
        createdAt: ts('2026-04-04T10:00:00Z'),
        confirmedAt: ts('2026-04-04T10:30:00Z'),
        scheduledDateTime: ts('2026-04-04T11:00:00Z'),
        completedAt: ts('2026-04-04T12:00:00Z'),
      },
      {
        id: 'a4',
        patientId: 'p4',
        status: 'cancelled',
        fee: 150,
        type: 'clinic',
        createdAt: ts('2026-04-05T10:00:00Z'),
      },
      {
        id: 'a5',
        patientId: 'p5',
        status: 'missed',
        fee: 150,
        type: 'video',
        createdAt: ts('2026-04-06T10:00:00Z'),
      },
      {
        id: 'a6',
        patientId: 'p6',
        status: 'not_completed',
        fee: 150,
        type: 'clinic',
        createdAt: ts('2026-04-07T10:00:00Z'),
      },
      {
        id: 'a7',
        patientId: 'p7',
        status: 'completed',
        fee: 100,
        type: 'video',
        createdAt: ts('2026-04-08T10:00:00Z'),
        confirmedAt: ts('2026-04-08T10:05:00Z'),
        scheduledDateTime: ts('2026-04-08T11:00:00Z'),
        completedAt: ts('2026-04-08T12:00:00Z'),
        clinicType: 'dermatology',
      },
    ];

    for (const appointment of appointments) {
      const { id, ...data } = appointment;
      await db.collection('appointments').doc(id).set({
        ...data,
        doctorId: 'doctor-1',
        clinicType: data.clinicType || 'chronic_diseases',
      });
    }

    await db.collection('emr_records').add({
      appointmentId: 'a1',
      createdAt: ts('2026-04-02T13:00:00Z'),
    });
    await db.collection('emr_records').add({
      appointmentId: 'a2',
      createdAt: ts('2026-04-03T13:00:00Z'),
    });
    await db.collection('doctor_payouts').doc('doctor-1')
      .collection('transactions').add({ amount: 50 });

    await expect(
      wrapped({ doctorId: 'doctor-1', periodStart: '2026-04-01T00:00:00Z', periodEnd: '2026-04-30T23:59:59Z' }, {})
    ).rejects.toMatchObject({ code: 'unauthenticated' });

    await expect(
      wrapped({ doctorId: 'doctor-1', periodStart: 'invalid', periodEnd: '2026-04-30T23:59:59Z' }, adminContext)
    ).rejects.toMatchObject({ code: 'invalid-argument' });

    const result = await wrapped({
      doctorId: 'doctor-1',
      periodStart: '2026-04-01T00:00:00Z',
      periodEnd: '2026-04-30T23:59:59Z',
      clinicType: 'chronic_diseases',
    }, adminContext);

    expect(result.appointmentStats.completed).toBe(3);
    expect(result.appointmentStats.cancelled).toBe(1);
    expect(result.appointmentStats.noShow).toBe(1);
    expect(result.appointmentStats.averageResponseTimeMinutes).toBe(20);
    expect(result.financialSummary.totalRevenue).toBe(350);
    expect(result.financialSummary.platformCommission).toBe(70);
    expect(result.financialSummary.netPayout).toBe(280);
    expect(result.financialSummary.pendingAmount).toBe(230);
    expect(result.performanceScore.hasIncompleteData).toBe(true);
    expect(result.performanceScore.missingDimensions).toContain('emrSpeed');
    expect(Number.isFinite(result.performanceScore.totalScore)).toBe(true);
    expect(result.specialtyBreakdown).toEqual([
      { type: 'clinic', serviceType: 'clinic', clinicType: 'chronic_diseases', count: 3, percentage: 50 },
      { type: 'video', serviceType: 'video', clinicType: 'chronic_diseases', count: 3, percentage: 50 },
    ]);
  });
});
