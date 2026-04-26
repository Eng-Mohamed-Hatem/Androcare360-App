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

describe('recordPayout', () => {
  const wrapped = functionsTest.wrap(analytics.recordPayout);
  const adminContext = createMockContext('admin-1', { userType: 'admin' });

  async function seedBase() {
    await db.collection('users').doc('admin-1').set({ userType: 'admin' });
    await db.doc('platform_settings/commission').set({ rate: 0.15 });
    await db.collection('users').doc('doctor-1').set({
      userType: 'doctor',
      isActive: true,
      fullName: 'Doctor Payout',
    });
    await db.collection('appointments').doc('appointment-1').set({
      doctorId: 'doctor-1',
      status: 'completed',
      fee: 1000,
      createdAt: ts('2026-04-15T09:00:00Z'),
      completedAt: ts('2026-04-15T10:00:00Z'),
    });
  }

  test('creates partial and paid payout transactions with audit fields', async () => {
    await seedBase();
    const logSpy = jest.spyOn(console, 'log').mockImplementation(() => {});

    await expect(
      wrapped({ doctorId: 'doctor-1', amount: 100, currency: 'SAR' }, {})
    ).rejects.toMatchObject({ code: 'unauthenticated' });

    await expect(
      wrapped({ doctorId: 'missing', amount: 100, currency: 'SAR' }, adminContext)
    ).rejects.toMatchObject({ code: 'not-found' });

    await expect(
      wrapped({ doctorId: 'doctor-1', amount: 0, currency: 'SAR' }, adminContext)
    ).rejects.toMatchObject({ code: 'invalid-argument' });

    const partial = await wrapped({
      doctorId: 'doctor-1',
      amount: 100,
      currency: 'SAR',
      note: 'first transfer',
    }, adminContext);
    expect(partial.status).toBe('partial');

    const paid = await wrapped({
      doctorId: 'doctor-1',
      amount: 750,
      currency: 'SAR',
    }, adminContext);
    expect(paid.status).toBe('paid');

    const txSnap = await db.collection('doctor_payouts').doc('doctor-1')
      .collection('transactions')
      .orderBy('amount')
      .get();
    expect(txSnap.size).toBe(2);
    expect(txSnap.docs[0].data()).toMatchObject({
      amount: 100,
      currency: 'SAR',
      status: 'partial',
      recordedByUid: 'admin-1',
      note: 'first transfer',
    });
    expect(txSnap.docs[0].data().recordedAt).toBeDefined();
    expect(txSnap.docs[1].data().status).toBe('paid');
    expect(logSpy).toHaveBeenCalledWith(expect.stringContaining('[PAYOUT]'));

    logSpy.mockRestore();
  });
});
