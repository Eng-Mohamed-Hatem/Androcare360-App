/**
 * One-time seed script: creates required Firestore documents for the
 * Doctor Analytics Dashboard feature (PR-003, PR-006).
 *
 * Run from repo root:
 *   cd functions
 *   node scripts/seed-analytics-settings.js
 *
 * Prerequisites: Firebase Admin SDK initialised against the elajtech project.
 * The script is idempotent — re-running it overwrites documents with the same values.
 */

'use strict';

const admin = require('firebase-admin');

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();
db.settings({ databaseId: 'elajtech' });

async function seed() {
  // PR-003: commission rate used by all analytics Cloud Functions
  await db.collection('platform_settings').doc('commission').set(
    { rate: 0.15 },
    { merge: true },
  );
  console.log('[SEED] platform_settings/commission → { rate: 0.15 }');

  // PR-006: alert thresholds consumed by checkAdminAlerts scheduled CF
  await db.collection('admin_settings').doc('alert_thresholds').set(
    {
      payoutThreshold: 5000.0,
      completionRateThreshold: 0.70,
      inactivityDaysThreshold: 7,
    },
    { merge: true },
  );
  console.log(
    '[SEED] admin_settings/alert_thresholds → { payoutThreshold: 5000, completionRateThreshold: 0.70, inactivityDaysThreshold: 7 }',
  );

  console.log('[SEED] Done.');
  process.exit(0);
}

seed().catch((err) => {
  console.error('[SEED] Error:', err);
  process.exit(1);
});
