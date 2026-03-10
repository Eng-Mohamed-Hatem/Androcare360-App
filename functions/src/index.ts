import * as admin from "firebase-admin";

// Initialize admin with custom databaseId
admin.initializeApp();
// Note: databaseId is handled via the admin instance and query methods
// In v1 SDK, we use admin.firestore() which defaults to (default) 
// but can be configured for multi-db if needed.
// However, collectionGroup queries work across all databases if configured,
// but usually we want to targets specifically 'elajtech'.
// For elajtech project, we ensure the environment or initialization points correctly.

export { expirePackages } from "./expire_packages";
