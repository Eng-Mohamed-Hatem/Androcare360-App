const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json'); // I need to check if this exists or use default

if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.applicationDefault()
    });
}

const db = admin.firestore().getFirestoreWithDatabaseId('elajtech');

async function verifyAdmin() {
    const uid = 'R4UWWD59hmYxOiaEuVlapUSZZSA2';
    console.log(`🔍 Checking user ${uid} in 'elajtech' database...`);

    try {
        const userDoc = await db.collection('users').doc(uid).get();

        if (!userDoc.exists) {
            console.log('❌ User document NOT FOUND in elajtech database.');
            return;
        }

        const data = userDoc.data();
        console.log('✅ User document FOUND.');
        console.log('Data:', JSON.stringify(data, null, 2));

        if (data.userType === 'admin') {
            console.log('🛡️ User is correctly marked as admin.');
        } else {
            console.log(`⚠️ User is NOT marked as admin. Current userType: '${data.userType}'`);
        }
    } catch (error) {
        console.error('❌ Error reading document:', error.message);
    }
}

verifyAdmin();
