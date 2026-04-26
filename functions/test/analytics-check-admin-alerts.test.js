const {
  admin,
  db,
} = require('./setup');
const analytics = require('../src/doctor_analytics');

function ts(date) {
  return admin.firestore.Timestamp.fromDate(new Date(date));
}

function daysAgo(days) {
  return admin.firestore.Timestamp.fromDate(
    new Date(Date.now() - days * 24 * 60 * 60 * 1000)
  );
}

async function seedDoctor(id, extra = {}) {
  await db.collection('users').doc(id).set({
    userType: 'doctor',
    isActive: true,
    fullName: id,
    clinicType: 'chronic_diseases',
    ...extra,
  });
}

async function seedAppointment(id, doctorId, status, fee, date = new Date()) {
  await db.collection('appointments').doc(id).set({
    doctorId,
    patientId: `patient-${id}`,
    status,
    fee,
    createdAt: admin.firestore.Timestamp.fromDate(date),
    completedAt: status === 'completed' ? admin.firestore.Timestamp.fromDate(date) : null,
    clinicType: 'chronic_diseases',
    type: 'video',
  });
}

describe('checkAdminAlerts', () => {
  test('creates financial, performance, and activity alerts with deduplication', async () => {
    await db.doc('platform_settings/commission').set({ rate: 0.15 });
    await db.doc('admin_settings/alert_thresholds').set({
      payoutThreshold: 5000,
      completionRateThreshold: 0.7,
      inactivityDaysThreshold: 7,
    });

    await seedDoctor('financial-doctor');
    await seedAppointment('financial-1', 'financial-doctor', 'completed', 7000);

    await seedDoctor('performance-doctor');
    await seedAppointment('performance-1', 'performance-doctor', 'completed', 100);
    await seedAppointment('performance-2', 'performance-doctor', 'cancelled', 100);
    await seedAppointment('performance-3', 'performance-doctor', 'cancelled', 100);

    await seedDoctor('activity-doctor', { lastLoginAt: daysAgo(10) });
    await seedDoctor('inactive-doctor', { isActive: false, lastLoginAt: daysAgo(30) });

    await analytics.evaluateAdminAlerts();

    let snap = await db.collection('admin_alerts').get();
    const alerts = snap.docs.map((doc) => doc.data());
    expect(alerts).toEqual(
      expect.arrayContaining([
        expect.objectContaining({ doctorId: 'financial-doctor', type: 'financial' }),
        expect.objectContaining({ doctorId: 'performance-doctor', type: 'performance' }),
        expect.objectContaining({ doctorId: 'activity-doctor', type: 'activity' }),
      ])
    );
    expect(alerts.some((alert) => alert.doctorId === 'inactive-doctor')).toBe(false);

    const countAfterFirstRun = snap.size;
    await analytics.evaluateAdminAlerts();
    snap = await db.collection('admin_alerts').get();
    expect(snap.size).toBe(countAfterFirstRun);
  });

  test('reads threshold values from Firestore settings', async () => {
    await db.doc('platform_settings/commission').set({ rate: 0.15 });
    await db.doc('admin_settings/alert_thresholds').set({
      payoutThreshold: 100,
      completionRateThreshold: 0.9,
      inactivityDaysThreshold: 1,
    });
    await seedDoctor('threshold-doctor', { lastLoginAt: daysAgo(2) });
    await seedAppointment('threshold-1', 'threshold-doctor', 'completed', 200);

    await analytics.evaluateAdminAlerts();

    const snap = await db.collection('admin_alerts').get();
    const alerts = snap.docs.map((doc) => doc.data());
    expect(alerts).toEqual(
      expect.arrayContaining([
        expect.objectContaining({ type: 'financial', threshold: '100 SAR' }),
        expect.objectContaining({ type: 'activity', threshold: '1 days' }),
      ])
    );
  });
});
