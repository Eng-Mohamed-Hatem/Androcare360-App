/**
 * Doctor Analytics Cloud Functions — AndroCare360
 *
 * Callable functions for the Doctor Analytics Dashboard (Feature 010).
 * All functions require admin authentication (userType === 'admin').
 * Region: europe-west1 | Database: elajtech
 */

'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { onSchedule } = require('firebase-functions/v2/scheduler');

// Firestore instance re-uses the one configured in index.js (databaseId: 'elajtech')
const db = admin.firestore();

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Verifies the caller is a signed-in admin using the canonical users document.
 * @param {object} context - Cloud Function context
 */
async function requireAdmin(context) {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Authentication required.'
    );
  }
  const userDoc = await db.collection('users').doc(context.auth.uid).get();
  if (!userDoc.exists || userDoc.data().userType !== 'admin') {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Admin access required.'
    );
  }
}

/**
 * Fetches the platform commission rate from Firestore.
 * Falls back to 0.15 if the document is missing.
 * @returns {Promise<number>}
 */
async function getCommissionRate() {
  try {
    const doc = await db.doc('platform_settings/commission').get();
    if (doc.exists) {
      const rate = doc.data().rate;
      if (typeof rate === 'number' && rate >= 0 && rate <= 1) {
        return rate;
      }
    }
  } catch (e) {
    console.log('[ANALYTICS] getCommissionRate fallback to 0.15:', e.message);
  }
  return 0.15;
}

/**
 * Computes appointment statistics for a single doctor within a period.
 * Applies financial eligibility rule BR-001: status === 'completed' AND fee > 0.
 *
 * @param {string} doctorId
 * @param {Date} periodStart
 * @param {Date} periodEnd
 * @param {number} commissionRate
 * @param {string|null} specialtyFilter - optional clinicType filter
 * @returns {Promise<object>}
 */
async function computeDoctorStats(doctorId, periodStart, periodEnd, commissionRate, specialtyFilter) {
  let query = db.collection('appointments')
    .where('doctorId', '==', doctorId)
    .where('completedAt', '>=', periodStart)
    .where('completedAt', '<=', periodEnd);

  let allQuery = db.collection('appointments')
    .where('doctorId', '==', doctorId)
    .where('createdAt', '>=', periodStart)
    .where('createdAt', '<=', periodEnd);

  if (specialtyFilter) {
    query = query.where('clinicType', '==', specialtyFilter);
    allQuery = allQuery.where('clinicType', '==', specialtyFilter);
  }

  const [periodSnap, allSnap] = await Promise.all([
    query.get(),
    allQuery.get(),
  ]);

  let totalRevenue = 0;
  let completedCount = 0;
  let cancelledCount = 0;
  let noShowCount = 0;
  let notCompletedCount = 0;

  allSnap.forEach((doc) => {
    const d = doc.data();
    const status = d.status || '';
    if (status === 'completed') completedCount++;
    else if (status === 'cancelled') cancelledCount++;
    else if (status === 'missed' || status === 'no_show') noShowCount++;
    else if (status === 'not_completed') notCompletedCount++;
  });

  periodSnap.forEach((doc) => {
    const d = doc.data();
    // BR-001: financial eligibility
    if (d.status === 'completed' && typeof d.fee === 'number' && d.fee > 0) {
      totalRevenue += d.fee;
    } else if (d.status === 'completed' && (!d.fee || d.fee <= 0)) {
      console.log(`[ANALYTICS] zero-fee anomaly excluded appointmentId=${doc.id}`);
    }
  });

  const totalCount = allSnap.size;
  const completionRate = totalCount > 0 ? completedCount / totalCount : 0;
  const platformCommission = Math.round(totalRevenue * commissionRate * 100) / 100;
  const netPayout = Math.round((totalRevenue - platformCommission) * 100) / 100;

  return {
    totalAppointments: totalCount,
    completedAppointments: completedCount,
    cancelledAppointments: cancelledCount,
    noShowAppointments: noShowCount,
    completionRate,
    totalRevenue: Math.round(totalRevenue * 100) / 100,
    platformCommission,
    netPayout,
    notCompletedCount,
  };
}

/**
 * Fetches the total paid-out amount for a doctor from doctor_payouts subcollection.
 * @param {string} doctorId
 * @returns {Promise<number>}
 */
async function getPaidAmount(doctorId) {
  try {
    const txSnap = await db
      .collection('doctor_payouts')
      .doc(doctorId)
      .collection('transactions')
      .get();
    let paid = 0;
    txSnap.forEach((doc) => {
      const d = doc.data();
      if (typeof d.amount === 'number') paid += d.amount;
    });
    return Math.round(paid * 100) / 100;
  } catch (_) {
    return 0;
  }
}

/**
 * Computes the 3-dimension overview performance score (EMR omitted for batch efficiency).
 * Redistributes weights proportionally: each dimension gets 33.33 pts.
 *
 * @param {number} completionRate  0-1
 * @param {number} doctorRating    0-5
 * @param {number} completedCount
 * @param {number} notCompletedCount
 * @returns {number} totalScore 0-100
 */
function computeOverviewScore(completionRate, doctorRating, completedCount, notCompletedCount) {
  const W = 100 / 3; // ~33.33 each dimension

  const completionScore = completionRate * W;
  const ratingScore = (doctorRating / 5.0) * W;

  const punctualityDenominator = completedCount + notCompletedCount;
  const punctualityScore = punctualityDenominator > 0
    ? (completedCount / punctualityDenominator) * W
    : 0;

  const total = completionScore + ratingScore + punctualityScore;
  return {
    totalScore: Math.round(total * 100) / 100,
    completionRateScore: Math.round(completionScore * 100) / 100,
    patientRatingScore: Math.round(ratingScore * 100) / 100,
    punctualityScore: Math.round(punctualityScore * 100) / 100,
    emrSpeedScore: 0,
    hasIncompleteData: true,
    missingDimensions: ['emrSpeed'],
    isOverviewScore: true,
  };
}

function timestampToIso(value) {
  if (!value) return null;
  if (typeof value.toDate === 'function') return value.toDate().toISOString();
  if (value instanceof Date) return value.toISOString();
  if (typeof value === 'string') return value;
  return null;
}

function toDate(value) {
  if (!value) return null;
  if (typeof value.toDate === 'function') return value.toDate();
  if (value instanceof Date) return value;
  if (typeof value === 'string') {
    const parsed = new Date(value);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }
  return null;
}

function parseRequiredPeriod(data) {
  const periodStart = new Date(data.periodStart);
  const periodEnd = new Date(data.periodEnd);
  if (
    Number.isNaN(periodStart.getTime()) ||
    Number.isNaN(periodEnd.getTime()) ||
    periodStart > periodEnd
  ) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Valid periodStart and periodEnd are required.'
    );
  }
  return { periodStart, periodEnd };
}

function isInPeriod(value, start, end) {
  const date = toDate(value);
  return date !== null && date >= start && date <= end;
}

function round2(value) {
  return Math.round(value * 100) / 100;
}

function round1(value) {
  return Math.round(value * 10) / 10;
}

function matchesClinicType(appointment, clinicType) {
  if (!clinicType) return true;
  return appointment.clinicType === clinicType || appointment.specialization === clinicType;
}

function normalizeAppointmentType(appointment) {
  const raw = String(
    appointment.type ||
    appointment.appointmentType ||
    appointment.consultationType ||
    ''
  ).toLowerCase();

  if (raw.includes('video') || raw.includes('online') || raw.includes('remote')) {
    return 'video';
  }
  if (raw.includes('clinic') || raw.includes('visit') || raw.includes('in_person')) {
    return 'clinic';
  }
  return raw || 'unknown';
}

function computeSpecialtyBreakdown(appointments) {
  if (appointments.length === 0) return [];

  const buckets = new Map();
  appointments.forEach((item) => {
    const appointment = item.data;
    const type = normalizeAppointmentType(appointment);
    const clinicType = appointment.clinicType || appointment.specialization || 'General';
    const key = `${type}::${clinicType}`;
    const current = buckets.get(key) || { type, serviceType: type, clinicType, count: 0 };
    current.count += 1;
    buckets.set(key, current);
  });

  return Array.from(buckets.values())
    .map((bucket) => ({
      ...bucket,
      percentage: round2((bucket.count / appointments.length) * 100),
    }))
    .sort((a, b) => {
      if (a.type !== b.type) return a.type.localeCompare(b.type);
      return a.clinicType.localeCompare(b.clinicType);
    });
}

function addDays(date, days) {
  return new Date(date.getTime() + days * 86400000);
}

function periodLengthDays(start, end) {
  return Math.max(1, Math.ceil((end.getTime() - start.getTime()) / 86400000));
}

function bucketKeyFor(date, granularity) {
  const y = date.getUTCFullYear();
  const m = String(date.getUTCMonth() + 1).padStart(2, '0');
  const d = String(date.getUTCDate()).padStart(2, '0');

  if (granularity === 'monthly') {
    return `${y}-${m}-01`;
  }
  if (granularity === 'weekly') {
    const day = date.getUTCDay();
    const diffToMonday = day === 0 ? -6 : 1 - day;
    const monday = addDays(new Date(Date.UTC(y, date.getUTCMonth(), date.getUTCDate())), diffToMonday);
    return `${monday.getUTCFullYear()}-${String(monday.getUTCMonth() + 1).padStart(2, '0')}-${String(monday.getUTCDate()).padStart(2, '0')}`;
  }
  return `${y}-${m}-${d}`;
}

function summarizeAppointmentsForTimeSeries(appointments, granularity, commissionRate) {
  const buckets = new Map();

  appointments.forEach((item) => {
    const appointment = item.data;
    const completedAt = toDate(appointment.completedAt || appointment.scheduledDateTime || appointment.createdAt);
    if (!completedAt) return;

    const key = bucketKeyFor(completedAt, granularity);
    const bucket = buckets.get(key) || {
      date: key,
      appointments: 0,
      completed: 0,
      revenue: 0,
    };

    bucket.appointments += 1;
    if (appointment.status === 'completed') {
      bucket.completed += 1;
      if (typeof appointment.fee === 'number' && appointment.fee > 0) {
        bucket.revenue += appointment.fee;
      }
    }

    buckets.set(key, bucket);
  });

  return Array.from(buckets.values())
    .sort((a, b) => a.date.localeCompare(b.date))
    .map((bucket) => {
      const completionRate = bucket.appointments > 0 ? bucket.completed / bucket.appointments : 0;
      const performanceScore = completionRate * 50 + Math.min(50, round2(bucket.revenue * commissionRate) > 0 ? 50 : 0);
      return {
        date: bucket.date,
        appointments: bucket.appointments,
        revenue: round2(bucket.revenue),
        performanceScore: round2(performanceScore),
        completionRate: round2(completionRate),
        isMarker: buckets.size < 3,
      };
    });
}

function computeChangePercent(current, previous) {
  if (previous <= 0) return null;
  return round1(((current - previous) / previous) * 100);
}

function computeTimeSeriesData({ allAppointments, periodStart, periodEnd, granularity, clinicType, commissionRate }) {
  const normalizedGranularity = ['daily', 'weekly', 'monthly'].includes(granularity)
    ? granularity
    : 'monthly';
  const lengthDays = periodLengthDays(periodStart, periodEnd);
  const previousEnd = addDays(periodStart, -1);
  const previousStart = addDays(previousEnd, -lengthDays + 1);

  const currentAppointments = allAppointments.filter((item) =>
    isInPeriod(item.data.completedAt || item.data.createdAt, periodStart, periodEnd) &&
    matchesClinicType(item.data, clinicType)
  );
  const previousAppointments = allAppointments.filter((item) =>
    isInPeriod(item.data.completedAt || item.data.createdAt, previousStart, previousEnd) &&
    matchesClinicType(item.data, clinicType)
  );

  const dataPoints = summarizeAppointmentsForTimeSeries(
    currentAppointments,
    normalizedGranularity,
    commissionRate,
  );
  const previousPoints = summarizeAppointmentsForTimeSeries(
    previousAppointments,
    normalizedGranularity,
    commissionRate,
  );

  const currentAppointmentsTotal = dataPoints.reduce((sum, item) => sum + item.appointments, 0);
  const previousAppointmentsTotal = previousPoints.reduce((sum, item) => sum + item.appointments, 0);
  const currentRevenueTotal = dataPoints.reduce((sum, item) => sum + item.revenue, 0);
  const previousRevenueTotal = previousPoints.reduce((sum, item) => sum + item.revenue, 0);
  const hasComparison = dataPoints.length >= 2 &&
    previousPoints.length >= 2 &&
    previousAppointmentsTotal > 0 &&
    previousRevenueTotal > 0;

  return {
    granularity: normalizedGranularity,
    dataPoints,
    hasComparison,
    comparison: hasComparison
      ? {
        previousPeriod: {
          appointments: previousAppointmentsTotal,
          revenue: round2(previousRevenueTotal),
        },
        changePercent: {
          appointments: computeChangePercent(currentAppointmentsTotal, previousAppointmentsTotal),
          revenue: computeChangePercent(currentRevenueTotal, previousRevenueTotal),
        },
      }
      : null,
  };
}

function computePatientRetention(appointments) {
  const byPatient = new Map();
  appointments.forEach((item) => {
    const patientId = item.data.patientId;
    if (!patientId) return;
    byPatient.set(patientId, (byPatient.get(patientId) || 0) + 1);
  });

  const totalUniquePatients = byPatient.size;
  const returningPatients = Array.from(byPatient.values())
    .filter((count) => count >= 2)
    .length;
  const hasSufficientData = totalUniquePatients >= 5;

  return {
    totalUniquePatients,
    returningPatients,
    retentionRate: hasSufficientData && totalUniquePatients > 0
      ? round2(returningPatients / totalUniquePatients)
      : null,
    hasSufficientData,
  };
}

async function getAlertThresholds() {
  try {
    const doc = await db.doc('admin_settings/alert_thresholds').get();
    if (doc.exists) {
      const data = doc.data();
      return {
        payoutThreshold: typeof data.payoutThreshold === 'number' ? data.payoutThreshold : 5000,
        completionRateThreshold: typeof data.completionRateThreshold === 'number' ? data.completionRateThreshold : 0.70,
        inactivityDaysThreshold: typeof data.inactivityDaysThreshold === 'number' ? data.inactivityDaysThreshold : 7,
      };
    }
  } catch (e) {
    console.log('[ANALYTICS] getAlertThresholds fallback:', e.message);
  }
  return {
    payoutThreshold: 5000,
    completionRateThreshold: 0.70,
    inactivityDaysThreshold: 7,
  };
}

async function upsertAdminAlert({ doctorId, doctorName, type, title, message, triggerValue, threshold }) {
  const existing = await db.collection('admin_alerts')
    .where('doctorId', '==', doctorId)
    .get();
  const existingActive = existing.docs.find((doc) => {
    const alert = doc.data();
    return alert.type === type && alert.isRead !== true;
  });

  const payload = {
    doctorId,
    doctorName,
    type,
    title,
    message,
    triggerValue,
    threshold,
    isRead: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    resolvedAt: null,
  };

  if (!existingActive) {
    await db.collection('admin_alerts').add(payload);
    return;
  }

  await existingActive.ref.update(payload);
}

function emptyDetailScore() {
  return {
    totalScore: 0,
    completionRateScore: 0,
    patientRatingScore: 0,
    punctualityScore: 0,
    emrSpeedScore: 0,
    hasIncompleteData: true,
    missingDimensions: ['completionRate', 'patientRating', 'punctuality', 'emrSpeed'],
    isOverviewScore: false,
  };
}

async function computeDetailPerformanceScore({
  appointments,
  doctorData,
  periodStart,
  periodEnd,
}) {
  const minimumDataPoints = 3;
  const minimumPeriodDays = 30;
  const periodDays = Math.ceil((periodEnd.getTime() - periodStart.getTime()) / 86400000);
  const hasEnoughHistory = periodDays >= minimumPeriodDays;

  if (!hasEnoughHistory) {
    return emptyDetailScore();
  }

  const totalCount = appointments.length;
  const completedAppointments = appointments.filter((item) => item.data.status === 'completed');
  const notCompletedCount = appointments.filter((item) => item.data.status === 'not_completed').length;
  const punctualityDenominator = completedAppointments.length + notCompletedCount;
  const rating = typeof doctorData.rating === 'number' ? doctorData.rating : 0;
  const reviewsCount = typeof doctorData.reviewsCount === 'number'
    ? doctorData.reviewsCount
    : rating > 0
      ? minimumDataPoints
      : 0;

  const emrScores = [];
  await Promise.all(completedAppointments.map(async (item) => {
    const scheduledAt = toDate(item.data.scheduledDateTime || item.data.appointmentTimestamp || item.data.appointmentDate);
    if (!scheduledAt) return;

    const emrSnap = await db.collection('emr_records')
      .where('appointmentId', '==', item.id)
      .limit(1)
      .get();
    if (emrSnap.empty) return;

    const emrCreatedAt = toDate(emrSnap.docs[0].data().createdAt);
    if (!emrCreatedAt) return;

    const hoursToReport = (emrCreatedAt.getTime() - scheduledAt.getTime()) / 3600000;
    emrScores.push(hoursToReport >= 0 && hoursToReport <= 24 ? 1 : 0);
  }));

  const rawScores = {
    completionRate: totalCount > 0 ? (completedAppointments.length / totalCount) * 25 : 0,
    patientRating: (rating / 5.0) * 25,
    punctuality: punctualityDenominator > 0
      ? (completedAppointments.length / punctualityDenominator) * 25
      : 0,
    emrSpeed: emrScores.length > 0
      ? (emrScores.reduce((sum, value) => sum + value, 0) / emrScores.length) * 25
      : 0,
  };

  const availability = {
    completionRate: totalCount >= minimumDataPoints,
    patientRating: reviewsCount >= minimumDataPoints,
    punctuality: punctualityDenominator >= minimumDataPoints,
    emrSpeed: emrScores.length >= minimumDataPoints,
  };

  const availableDimensions = Object.entries(availability)
    .filter(([, available]) => available)
    .map(([dimension]) => dimension);
  const missingDimensions = Object.entries(availability)
    .filter(([, available]) => !available)
    .map(([dimension]) => dimension);

  const totalScore = availableDimensions.length === 0
    ? 0
    : round2(
      availableDimensions.reduce((sum, dimension) => sum + rawScores[dimension], 0) /
      (25 * availableDimensions.length) * 100
    );

  return {
    totalScore,
    completionRateScore: round2(rawScores.completionRate),
    patientRatingScore: round2(rawScores.patientRating),
    punctualityScore: round2(rawScores.punctuality),
    emrSpeedScore: round2(rawScores.emrSpeed),
    hasIncompleteData: missingDimensions.length > 0,
    missingDimensions,
    isOverviewScore: false,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// getPlatformSummary
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Returns platform-wide aggregated summary for the 4 summary cards (US1).
 *
 * Request: { periodStart, periodEnd, specialtyFilter? }
 * Response: { totalCompletedAppointments, totalRevenue, totalPendingPayouts,
 *              averagePerformanceScore, activeDoctorsCount }
 */
const getPlatformSummary = functions
  .region('europe-west1')
  .https.onCall(async (data, context) => {
    await requireAdmin(context);

    const { periodStart, periodEnd } = parseRequiredPeriod(data);
    const specialtyFilter = data.specialtyFilter || null;

    console.log(`[ANALYTICS] getPlatformSummary period=${data.periodStart} to ${data.periodEnd}`);

    const commissionRate = await getCommissionRate();

    // Get all active doctors
    let doctorQuery = db.collection('users')
      .where('userType', '==', 'doctor')
      .where('isActive', '==', true);
    if (specialtyFilter) {
      doctorQuery = doctorQuery.where('clinicType', '==', specialtyFilter);
    }
    const doctorSnap = await doctorQuery.get();
    const activeDoctorsCount = doctorSnap.size;

    if (activeDoctorsCount === 0) {
      return {
        totalCompletedAppointments: 0,
        totalRevenue: 0.0,
        totalPendingPayouts: 0.0,
        averagePerformanceScore: 0.0,
        activeDoctorsCount: 0,
      };
    }

    // Aggregate stats for all active doctors
    const doctors = doctorSnap.docs;
    const statsPromises = doctors.map((doc) =>
      computeDoctorStats(doc.id, periodStart, periodEnd, commissionRate, specialtyFilter)
    );
    const paidPromises = doctors.map((doc) => getPaidAmount(doc.id));

    const [allStats, allPaid] = await Promise.all([
      Promise.all(statsPromises),
      Promise.all(paidPromises),
    ]);

    let totalCompletedAppointments = 0;
    let totalRevenue = 0;
    let totalPendingPayouts = 0;
    let totalPerformanceScore = 0;

    for (let i = 0; i < doctors.length; i++) {
      const stats = allStats[i];
      const doctorData = doctors[i].data();
      const paid = allPaid[i];

      totalCompletedAppointments += stats.completedAppointments;
      totalRevenue += stats.totalRevenue;

      const pendingPayout = Math.max(0, stats.netPayout - paid);
      totalPendingPayouts += pendingPayout;

      const score = computeOverviewScore(
        stats.completionRate,
        doctorData.rating || 0,
        stats.completedAppointments,
        stats.notCompletedCount,
      );
      totalPerformanceScore += score.totalScore;
    }

    const averagePerformanceScore = activeDoctorsCount > 0
      ? Math.round((totalPerformanceScore / activeDoctorsCount) * 100) / 100
      : 0;

    return {
      totalCompletedAppointments,
      totalRevenue: Math.round(totalRevenue * 100) / 100,
      totalPendingPayouts: Math.round(totalPendingPayouts * 100) / 100,
      averagePerformanceScore,
      activeDoctorsCount,
    };
  });

// ─────────────────────────────────────────────────────────────────────────────
// getDoctorsOverview
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Returns paginated, filtered, sorted doctor analytics for the overview table (US1).
 *
 * Request: { periodStart, periodEnd, specialtyFilter?, statusFilter,
 *             searchQuery?, sortBy, sortOrder, pageSize, cursor? }
 * Response: { doctors: [...], hasMore, nextCursor }
 */
const getDoctorsOverview = functions
  .region('europe-west1')
  .https.onCall(async (data, context) => {
    await requireAdmin(context);

    const { periodStart, periodEnd } = parseRequiredPeriod(data);
    const specialtyFilter = data.specialtyFilter || null;
    const statusFilter = data.statusFilter || 'all';
    const searchQuery = (data.searchQuery || '').trim().toLowerCase();
    const sortBy = data.sortBy || 'name';
    const sortOrder = data.sortOrder || 'asc';
    const pageSize = Math.min(data.pageSize || 20, 50);
    const cursor = data.cursor || null;

    console.log(`[ANALYTICS] getDoctorsOverview sortBy=${sortBy} page cursor=${cursor}`);

    const commissionRate = await getCommissionRate();

    // Build doctor query
    let doctorQuery = db.collection('users').where('userType', '==', 'doctor');
    if (statusFilter === 'active') {
      doctorQuery = doctorQuery.where('isActive', '==', true);
    } else if (statusFilter === 'inactive') {
      doctorQuery = doctorQuery.where('isActive', '==', false);
    }
    if (specialtyFilter) {
      doctorQuery = doctorQuery.where('clinicType', '==', specialtyFilter);
    }

    const doctorSnap = await doctorQuery.get();
    let doctors = doctorSnap.docs;

    // Client-side search filter (Firestore lacks full-text search)
    if (searchQuery) {
      doctors = doctors.filter((doc) => {
        const data = doc.data();
        const name = String(data.name || data.fullName || '').toLowerCase();
        return name.includes(searchQuery);
      });
    }

    // Compute stats for all matching doctors
    const statsPromises = doctors.map((doc) =>
      computeDoctorStats(doc.id, periodStart, periodEnd, commissionRate, specialtyFilter)
    );
    const paidPromises = doctors.map((doc) => getPaidAmount(doc.id));

    const [allStats, allPaid] = await Promise.all([
      Promise.all(statsPromises),
      Promise.all(paidPromises),
    ]);

    // Build result rows
    const rows = doctors.map((doc, i) => {
      const d = doc.data();
      const stats = allStats[i];
      const paid = allPaid[i];
      const pendingPayout = Math.max(0, stats.netPayout - paid);
      const payoutStatus = paid >= stats.netPayout && stats.netPayout > 0
        ? 'paid'
        : paid > 0
          ? 'partial'
          : 'pending';

      const score = computeOverviewScore(
        stats.completionRate,
        d.rating || 0,
        stats.completedAppointments,
        stats.notCompletedCount,
      );

      return {
        doctorId: doc.id,
        doctorName: d.name || d.fullName || '',
        profileImage: d.profileImage || d.photoURL || null,
        specialty: d.clinicType || 'General',
        isActive: d.isActive !== false,
        totalAppointments: stats.totalAppointments,
        completedAppointments: stats.completedAppointments,
        cancelledAppointments: stats.cancelledAppointments,
        noShowAppointments: stats.noShowAppointments,
        completionRate: stats.completionRate,
        averageResponseTime: null, // expensive to compute in batch — available in detail
        totalRevenue: stats.totalRevenue,
        platformCommission: stats.platformCommission,
        netPayout: stats.netPayout,
        pendingPayout,
        payoutStatus,
        performanceTotalScore: score.totalScore,
        performanceScore: score,
        patientRetentionRate: null, // available in detail only
        lastLoginAt: timestampToIso(d.lastLoginAt),
      };
    });

    // Sort
    rows.sort((a, b) => {
      let av, bv;
      switch (sortBy) {
        case 'appointments': av = a.totalAppointments; bv = b.totalAppointments; break;
        case 'revenue': av = a.totalRevenue; bv = b.totalRevenue; break;
        case 'performanceScore': av = a.performanceTotalScore; bv = b.performanceTotalScore; break;
        case 'pendingPayout': av = a.pendingPayout; bv = b.pendingPayout; break;
        default: av = a.doctorName.toLowerCase(); bv = b.doctorName.toLowerCase(); break;
      }
      if (av < bv) return sortOrder === 'asc' ? -1 : 1;
      if (av > bv) return sortOrder === 'asc' ? 1 : -1;
      return 0;
    });

    // Cursor-based pagination
    let startIndex = 0;
    if (cursor) {
      const cursorIndex = rows.findIndex((r) => r.doctorId === cursor);
      if (cursorIndex >= 0) startIndex = cursorIndex + 1;
    }

    const pageRows = rows.slice(startIndex, startIndex + pageSize);
    const hasMore = startIndex + pageSize < rows.length;
    const nextCursor = hasMore ? pageRows[pageRows.length - 1].doctorId : null;

    return {
      doctors: pageRows,
      hasMore,
      nextCursor,
    };
  });

// ─────────────────────────────────────────────────────────────────────────────
// getDoctorAnalyticsDetail
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Returns full analytics detail for a single doctor (US2 core detail data).
 * Request: { doctorId, periodStart, periodEnd }
 */
const getDoctorAnalyticsDetail = functions
  .region('europe-west1')
  .https.onCall(async (data, context) => {
    await requireAdmin(context);

    const doctorId = data.doctorId;
    if (!doctorId) {
      throw new functions.https.HttpsError('invalid-argument', 'doctorId is required.');
    }

    const { periodStart, periodEnd } = parseRequiredPeriod(data);
    const clinicType = data.clinicType || data.specialtyFilter || null;
    const granularity = data.granularity || 'monthly';

    console.log(`[ANALYTICS] getDoctorAnalyticsDetail doctorId=${doctorId} period=${data.periodStart} to ${data.periodEnd} clinicType=${clinicType || 'all'}`);

    const doctorDoc = await db.collection('users').doc(doctorId).get();
    if (!doctorDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Doctor not found.');
    }
    const doctorData = doctorDoc.data();

    const commissionRate = await getCommissionRate();
    const appointmentSnap = await db.collection('appointments')
      .where('doctorId', '==', doctorId)
      .get();

    const allAppointments = appointmentSnap.docs
      .map((doc) => ({ id: doc.id, data: doc.data() }));
    const appointments = allAppointments.filter((item) =>
      isInPeriod(item.data.createdAt, periodStart, periodEnd) &&
      matchesClinicType(item.data, clinicType)
    );
    const financialAppointments = allAppointments.filter((item) =>
      isInPeriod(item.data.completedAt, periodStart, periodEnd) &&
      matchesClinicType(item.data, clinicType)
    );
    const specialtyBreakdown = computeSpecialtyBreakdown(appointments);
    const timeSeriesData = computeTimeSeriesData({
      allAppointments,
      periodStart,
      periodEnd,
      granularity,
      clinicType,
      commissionRate,
    });
    const patientRetention = computePatientRetention(appointments);

    let completed = 0;
    let cancelled = 0;
    let noShow = 0;
    let totalRevenue = 0;
    const responseTimes = [];

    appointments.forEach((item) => {
      const appointment = item.data;
      const status = appointment.status || '';
      if (status === 'completed') completed++;
      if (status === 'cancelled') cancelled++;
      if (status === 'missed' || status === 'no_show') noShow++;

      const createdAt = toDate(appointment.createdAt);
      const confirmedAt = toDate(appointment.confirmedAt);
      if (createdAt && confirmedAt && confirmedAt >= createdAt) {
        responseTimes.push((confirmedAt.getTime() - createdAt.getTime()) / 60000);
      }
    });

    financialAppointments.forEach((item) => {
      const appointment = item.data;
      if (appointment.status === 'completed' && typeof appointment.fee === 'number' && appointment.fee > 0) {
        totalRevenue += round2(appointment.fee);
      } else if (appointment.status === 'completed' && (!appointment.fee || appointment.fee <= 0)) {
        console.log(`[ANALYTICS] zero-fee anomaly excluded appointmentId=${item.id}`);
      }
    });

    const total = appointments.length;
    const completionRate = total > 0 ? completed / total : 0;
    const averageResponseTimeMinutes = responseTimes.length === 0
      ? null
      : round2(responseTimes.reduce((sum, value) => sum + value, 0) / responseTimes.length);

    const platformCommission = round2(totalRevenue * commissionRate);
    const netPayout = round2(totalRevenue - platformCommission);
    const paidAmount = await getPaidAmount(doctorId);
    const pendingAmount = Math.max(0, round2(netPayout - paidAmount));
    const performanceScore = await computeDetailPerformanceScore({
      appointments,
      doctorData,
      periodStart,
      periodEnd,
    });

    return {
      doctor: {
        doctorId,
        doctorName: doctorData.name || doctorData.fullName || '',
        profileImage: doctorData.profileImage || doctorData.photoURL || null,
        specialty: doctorData.clinicType || doctorData.specialty || 'General',
        isActive: doctorData.isActive !== false,
        lastLoginAt: timestampToIso(doctorData.lastLoginAt),
      },
      appointmentStats: {
        total,
        completed,
        cancelled,
        noShow,
        completionRate,
        averageResponseTimeMinutes,
      },
      financialSummary: {
        totalRevenue: round2(totalRevenue),
        platformCommission,
        netPayout,
        paidAmount,
        pendingAmount,
        commissionRate,
      },
      performanceScore,
      specialtyBreakdown,
      timeSeriesData,
      patientRetention,
    };
  });

// ─────────────────────────────────────────────────────────────────────────────
// exportPayoutReport (US5)
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Returns structured payout data for a doctor in a given month.
 * Applies BR-001: status === 'completed' AND fee > 0.
 * Request: { doctorId, year, month }
 */
const exportPayoutReport = functions
  .region('europe-west1')
  .https.onCall(async (data, context) => {
    await requireAdmin(context);

    const doctorId = data.doctorId;
    if (!doctorId) {
      throw new functions.https.HttpsError('invalid-argument', 'doctorId is required.');
    }
    const year = data.year;
    const month = data.month; // 1-indexed
    if (
      typeof year !== 'number' || typeof month !== 'number' ||
      month < 1 || month > 12 || year < 2000 || year > 2100
    ) {
      throw new functions.https.HttpsError('invalid-argument', 'Valid year and month (1-12) are required.');
    }

    console.log(`[ANALYTICS] exportPayoutReport doctorId=${doctorId} year=${year} month=${month}`);

    const doctorDoc = await db.collection('users').doc(doctorId).get();
    if (!doctorDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Doctor not found.');
    }
    const doctorData = doctorDoc.data();
    const commissionRate = await getCommissionRate();

    // Build inclusive date range for the requested month
    const periodStart = new Date(Date.UTC(year, month - 1, 1, 0, 0, 0, 0));
    const periodEnd = new Date(Date.UTC(year, month, 0, 23, 59, 59, 999)); // last day of month

    const snap = await db.collection('appointments')
      .where('doctorId', '==', doctorId)
      .where('completedAt', '>=', admin.firestore.Timestamp.fromDate(periodStart))
      .where('completedAt', '<=', admin.firestore.Timestamp.fromDate(periodEnd))
      .orderBy('completedAt', 'asc')
      .get();

    const entries = [];
    let totalRevenue = 0;
    let totalCommission = 0;
    let totalNetPayout = 0;

    snap.forEach((doc) => {
      const d = doc.data();
      // BR-001: financial eligibility
      if (d.status !== 'completed' || typeof d.fee !== 'number' || d.fee <= 0) {
        if (d.status === 'completed') {
          console.log(`[ANALYTICS] zero-fee anomaly excluded appointmentId=${doc.id}`);
        }
        return;
      }

      const fee = round2(d.fee);
      const commission = round2(fee * commissionRate);
      const netAmount = round2(fee - commission);

      totalRevenue += fee;
      totalCommission += commission;
      totalNetPayout += netAmount;

      entries.push({
        appointmentId: doc.id,
        patientName: d.patientName || d.patientFullName || '',
        appointmentDate: timestampToIso(d.completedAt) || timestampToIso(d.createdAt) || '',
        status: d.status,
        fee,
        commission,
        netAmount,
      });
    });

    const padMonth = String(month).padStart(2, '0');
    const lastDay = new Date(Date.UTC(year, month, 0)).getUTCDate();

    return {
      doctorId,
      doctorName: doctorData.name || doctorData.fullName || '',
      specialty: doctorData.clinicType || doctorData.specialty || 'General',
      period: {
        start: `${year}-${padMonth}-01`,
        end: `${year}-${padMonth}-${String(lastDay).padStart(2, '0')}`,
      },
      entries,
      totalRevenue: round2(totalRevenue),
      totalCommission: round2(totalCommission),
      totalNetPayout: round2(totalNetPayout),
      generatedAt: new Date().toISOString(),
    };
  });

// ─────────────────────────────────────────────────────────────────────────────
// recordPayout (US5, FR-007)
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Records a payout disbursement for a doctor (admin-only).
 * Appends to doctor_payouts/{doctorId}/transactions/{auto-id}.
 * Request: { doctorId, amount, currency?, note? }
 */
const recordPayout = functions
  .region('europe-west1')
  .https.onCall(async (data, context) => {
    await requireAdmin(context);

    const doctorId = data.doctorId;
    const amount = data.amount;
    const note = data.note || null;

    if (!doctorId) {
      throw new functions.https.HttpsError('invalid-argument', 'doctorId is required.');
    }
    if (typeof amount !== 'number' || amount <= 0) {
      throw new functions.https.HttpsError('invalid-argument', 'amount must be a positive number.');
    }

    const doctorDoc = await db.collection('users').doc(doctorId).get();
    if (!doctorDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Doctor not found.');
    }

    // Compute current pending amount to determine status
    const commissionRate = await getCommissionRate();

    const completedSnap = await db.collection('appointments')
      .where('doctorId', '==', doctorId)
      .where('status', '==', 'completed')
      .get();

    let totalRevenue = 0;
    completedSnap.forEach((doc) => {
      const d = doc.data();
      if (typeof d.fee === 'number' && d.fee > 0) {
        totalRevenue += d.fee;
      }
    });

    const netPayout = round2(totalRevenue - round2(totalRevenue * commissionRate));
    const paidAmount = await getPaidAmount(doctorId);
    const currentPendingAmount = Math.max(0, round2(netPayout - paidAmount));

    const status = amount >= currentPendingAmount ? 'paid' : 'partial';

    const txRef = db
      .collection('doctor_payouts')
      .doc(doctorId)
      .collection('transactions')
      .doc();

    await txRef.set({
      amount: round2(amount),
      currency: data.currency || 'SAR',
      status,
      recordedAt: admin.firestore.FieldValue.serverTimestamp(),
      recordedByUid: context.auth.uid,
      note,
    });

    console.log(`[PAYOUT] doctorId:${doctorId} | amount:${amount} | status:${status} | by:${context.auth.uid}`);

    return { success: true, status };
  });

// ─────────────────────────────────────────────────────────────────────────────
// Admin alerts (US4)
// ─────────────────────────────────────────────────────────────────────────────

async function evaluateAdminAlerts() {
  const thresholds = await getAlertThresholds();
  const commissionRate = await getCommissionRate();
  const now = new Date();
  const trailingStart = addDays(now, -30);

  const doctorSnap = await db.collection('users')
    .where('userType', '==', 'doctor')
    .where('isActive', '==', true)
    .get();

  for (const doctorDoc of doctorSnap.docs) {
    const doctor = doctorDoc.data();
    const doctorId = doctorDoc.id;
    const doctorName = doctor.name || doctor.fullName || '';

    const stats = await computeDoctorStats(
      doctorId,
      trailingStart,
      now,
      commissionRate,
      null,
    );
    const paidAmount = await getPaidAmount(doctorId);
    const pendingAmount = Math.max(0, round2(stats.netPayout - paidAmount));

    console.log(`[ANALYTICS] checkAdminAlerts doctorId=${doctorId} pending=${pendingAmount} completion=${stats.completionRate}`);

    if (pendingAmount > thresholds.payoutThreshold) {
      await upsertAdminAlert({
        doctorId,
        doctorName,
        type: 'financial',
        title: 'مستحقات مرتفعة',
        message: `تجاوزت مستحقات ${doctorName} الحد المالي المحدد`,
        triggerValue: `${round2(pendingAmount)} SAR`,
        threshold: `${thresholds.payoutThreshold} SAR`,
      });
    }

    if (stats.totalAppointments > 0 && stats.completionRate < thresholds.completionRateThreshold) {
      await upsertAdminAlert({
        doctorId,
        doctorName,
        type: 'performance',
        title: 'انخفاض معدل الإتمام',
        message: `معدل إتمام الحجوزات لدى ${doctorName} أقل من الحد المطلوب خلال آخر 30 يوماً`,
        triggerValue: `${round2(stats.completionRate * 100)}%`,
        threshold: `${round2(thresholds.completionRateThreshold * 100)}%`,
      });
    }

    const lastLoginAt = toDate(doctor.lastLoginAt);
    if (lastLoginAt) {
      const inactiveDays = Math.floor((now.getTime() - lastLoginAt.getTime()) / 86400000);
      if (inactiveDays >= thresholds.inactivityDaysThreshold) {
        await upsertAdminAlert({
          doctorId,
          doctorName,
          type: 'activity',
          title: 'خمول الطبيب',
          message: `لم يسجل ${doctorName} الدخول منذ ${inactiveDays} يوماً`,
          triggerValue: `${inactiveDays} days`,
          threshold: `${thresholds.inactivityDaysThreshold} days`,
        });
      }
    }
  }
}

const checkAdminAlerts = onSchedule(
  { schedule: 'every 60 minutes', region: 'europe-west1', timeZone: 'UTC' },
  async () => {
    await evaluateAdminAlerts();
  },
);

const getAdminAlerts = functions
  .region('europe-west1')
  .https.onCall(async (data, context) => {
    await requireAdmin(context);

    const includeRead = data.includeRead === true;
    const limit = Math.min(data.limit || 50, 100);
    console.log(`[ANALYTICS] getAdminAlerts includeRead=${includeRead} limit=${limit}`);

    let query = db.collection('admin_alerts').orderBy('createdAt', 'desc').limit(limit);
    if (!includeRead) {
      query = db.collection('admin_alerts')
        .where('isRead', '==', false)
        .orderBy('createdAt', 'desc')
        .limit(limit);
    }

    const snap = await query.get();
    const alerts = snap.docs.map((doc) => {
      const alert = doc.data();
      return {
        id: doc.id,
        type: alert.type || 'financial',
        doctorId: alert.doctorId || '',
        doctorName: alert.doctorName || '',
        title: alert.title || '',
        message: alert.message || '',
        triggerValue: alert.triggerValue || '',
        threshold: alert.threshold || '',
        isRead: alert.isRead === true,
        createdAt: timestampToIso(alert.createdAt) || new Date().toISOString(),
        resolvedAt: timestampToIso(alert.resolvedAt),
      };
    });

    const unreadCount = alerts.filter((alert) => !alert.isRead).length;
    return { alerts, unreadCount };
  });

const acknowledgeAlert = functions
  .region('europe-west1')
  .https.onCall(async (data, context) => {
    await requireAdmin(context);

    const alertId = data.alertId;
    if (!alertId) {
      throw new functions.https.HttpsError('invalid-argument', 'alertId is required.');
    }
    console.log(`[ANALYTICS] acknowledgeAlert alertId=${alertId}`);

    const ref = db.collection('admin_alerts').doc(alertId);
    const doc = await ref.get();
    if (!doc.exists) {
      throw new functions.https.HttpsError('not-found', 'Alert not found.');
    }

    await ref.update({
      isRead: true,
      resolvedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true };
  });

module.exports = {
  getDoctorsOverview,
  getPlatformSummary,
  getDoctorAnalyticsDetail,
  exportPayoutReport,
  recordPayout,
  checkAdminAlerts,
  getAdminAlerts,
  acknowledgeAlert,
  evaluateAdminAlerts,
};
