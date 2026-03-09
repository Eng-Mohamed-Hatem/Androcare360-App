import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Scheduled function to expire packages that have reached their expiry date.
 * Runs daily at midnight Cairo time (UTC+2).
 *
 * **English**: Scans all 'packages' subcollections using a collectionGroup query.
 * Updates ACTIVE packages where expiryDate < now to EXPIRED.
 * Uses batched writes for efficiency (limit 500).
 *
 * **Arabic**: دالة مجدولة لإنهاء صلاحية الباقات التي تجاوزت تاريخ الانتهاء.
 * تعمل يوميًا في منتصف الليل بتوقيت القاهرة.
 *
 * **Spec**: tasks.md T082, important-rules.md (databaseId: 'elajtech')
 */
export const expirePackages = functions
    .region("europe-west1")
    .pubsub.schedule("0 0 * * *")
    .timeZone("Africa/Cairo")
    .onRun(async (context) => {
        const db = admin.firestore();
        const now = admin.firestore.Timestamp.now();

        console.log(`[expirePackages] Starting expiry scan at ${now.toDate().toISOString()}`);

        try {
            const expiredQuery = db
                .collectionGroup("packages")
                .where("status", "==", "ACTIVE")
                .where("expiryDate", "<", now);

            const snapshot = await expiredQuery.get();

            if (snapshot.empty) {
                console.log("[expirePackages] No expired packages found.");
                return null;
            }

            console.log(`[expirePackages] Found ${snapshot.size} expired packages.`);

            // Batch updates (max 500 per batch)
            let batch = db.batch();
            let count = 0;
            let totalProcessed = 0;

            for (const doc of snapshot.docs) {
                batch.update(doc.ref, {
                    status: "EXPIRED",
                    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                });

                count++;
                totalProcessed++;

                if (count === 500) {
                    await batch.commit();
                    console.log(`[expirePackages] Committed batch of 500. Total: ${totalProcessed}`);
                    batch = db.batch();
                    count = 0;
                }
            }

            if (count > 0) {
                await batch.commit();
                console.log(`[expirePackages] Committed final batch of ${count}. Total: ${totalProcessed}`);
            }

            return null;
        } catch (error) {
            console.error("[expirePackages] Error during expiry scan:", error);
            throw error;
        }
    });
