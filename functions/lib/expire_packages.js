"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.expirePackages = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
exports.expirePackages = functions
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
    }
    catch (error) {
        console.error("[expirePackages] Error during expiry scan:", error);
        throw error;
    }
});
//# sourceMappingURL=expire_packages.js.map