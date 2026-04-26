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

describe('exportPayoutReport', () => {
  const wrapped = functionsTest.wrap(analytics.exportPayoutReport);
  const detailWrapped = functionsTest.wrap(analytics.getDoctorAnalyticsDetail);
  const adminContext = createMockContext('admin-1', { userType: 'admin' });

  async function seedBase() {
    await db.collection('users').doc('admin-1').set({ userType: 'admin' });
    await db.doc('platform_settings/commission').set({ rate: 0.15 });
    await db.collection('users').doc('doctor-1').set({
      userType: 'doctor',
      isActive: true,
      fullName: 'Doctor Export',
      clinicType: 'chronic_diseases',
      rating: 4.5,
      reviewsCount: 10,
    });
  }

  test('applies BR-001 and returns rounded itemized payout rows', async () => {
    await seedBase();
    await db.collection('appointments').doc('eligible-1').set({
      doctorId: 'doctor-1',
      patientName: 'Patient One',
      status: 'completed',
      fee: 200,
      createdAt: ts('2026-04-15T09:00:00Z'),
      completedAt: ts('2026-04-15T10:00:00Z'),
    });
    await db.collection('appointments').doc('eligible-2').set({
      doctorId: 'doctor-1',
      patientName: 'Patient Two',
      status: 'completed',
      fee: 100.335,
      createdAt: ts('2026-04-16T09:00:00Z'),
      completedAt: ts('2026-04-16T10:00:00Z'),
    });
    await db.collection('appointments').doc('zero-fee').set({
      doctorId: 'doctor-1',
      patientName: 'Zero Fee',
      status: 'completed',
      fee: 0,
      createdAt: ts('2026-04-17T09:00:00Z'),
      completedAt: ts('2026-04-17T10:00:00Z'),
    });
    await db.collection('appointments').doc('cancelled').set({
      doctorId: 'doctor-1',
      patientName: 'Cancelled',
      status: 'cancelled',
      fee: 150,
      createdAt: ts('2026-04-18T09:00:00Z'),
      completedAt: ts('2026-04-18T10:00:00Z'),
    });

    await expect(
      wrapped({ doctorId: 'doctor-1', year: 2026, month: 4 }, {})
    ).rejects.toMatchObject({ code: 'unauthenticated' });

    const report = await wrapped({ doctorId: 'doctor-1', year: 2026, month: 4 }, adminContext);

    expect(report.entries).toHaveLength(2);
    expect(report.entries[0]).toMatchObject({
      appointmentId: 'eligible-1',
      patientName: 'Patient One',
      fee: 200,
      commission: 30,
      netAmount: 170,
    });
    expect(report.entries[1]).toMatchObject({
      appointmentId: 'eligible-2',
      fee: 100.34,
      commission: 15.05,
      netAmount: 85.29,
    });
    expect(report.totalRevenue).toBe(300.34);
    expect(report.totalCommission).toBe(45.05);
    expect(report.totalNetPayout).toBe(255.29);

    const detail = await detailWrapped({
      doctorId: 'doctor-1',
      periodStart: '2026-04-01T00:00:00Z',
      periodEnd: '2026-04-30T23:59:59Z',
    }, adminContext);
    expect(report.totalRevenue).toBe(detail.financialSummary.totalRevenue);
    expect(report.totalCommission).toBe(detail.financialSummary.platformCommission);
    expect(report.totalNetPayout).toBe(detail.financialSummary.netPayout);
  });

  test('returns empty report with zero totals for months without eligible appointments', async () => {
    await seedBase();

    const report = await wrapped({ doctorId: 'doctor-1', year: 2026, month: 5 }, adminContext);

    expect(report.entries).toEqual([]);
    expect(report.totalRevenue).toBe(0);
    expect(report.totalCommission).toBe(0);
    expect(report.totalNetPayout).toBe(0);
  });
});
