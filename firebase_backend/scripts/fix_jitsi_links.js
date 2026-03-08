/**
 * Migration Script: Fix Jitsi Links -> Zoom Links
 * سكريبت ترحيل: تحويل روابط Jitsi إلى Zoom
 * 
 * Run: node fix_jitsi_links.js
 * 
 * This script updates future video appointments that have Jitsi links
 * to use real Zoom meeting URLs instead.
 */

const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
admin.initializeApp();

// Connect to elajtech database
const db = admin.firestore();
db.settings({ databaseId: 'elajtech' });

// Import createZoomMeeting from index.js (reuse the function)
const { getZoomAccessToken } = require('./zoom_helper');

/**
 * Create Zoom meeting via API
 */
async function createZoomMeeting(topic, doctorName, duration = 30) {
    console.log('🎥 Creating Zoom meeting:', topic);

    try {
        const accessToken = await getZoomAccessToken();
        const fetch = (await import('node-fetch')).default;

        const meetingData = {
            topic: topic,
            type: 1, // Instant meeting
            duration: duration,
            timezone: 'Asia/Riyadh',
            settings: {
                host_video: true,
                participant_video: true,
                join_before_host: false,
                mute_upon_entry: false,
                watermark: false,
                use_pmi: false,
                approval_type: 2,
                audio: 'both',
                auto_recording: 'none',
                waiting_room: false,
                meeting_authentication: false,
            }
        };

        const response = await fetch('https://api.zoom.us/v2/users/me/meetings', {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${accessToken}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(meetingData)
        });

        if (!response.ok) {
            const errorText = await response.text();
            console.error('❌ Zoom meeting creation failed:', response.status, errorText);
            throw new Error(`Zoom meeting creation failed: ${response.status}`);
        }

        const meeting = await response.json();

        console.log('✅ Zoom meeting created:', meeting.id);

        return {
            meetingId: String(meeting.id),
            password: meeting.password || '',
            joinUrl: meeting.join_url,
            startUrl: meeting.start_url,
        };

    } catch (error) {
        console.error('❌ Error creating Zoom meeting:', error);
        throw error;
    }
}

/**
 * Main migration function
 */
async function fixJitsiLinks() {
    console.log('🔄 Starting Jitsi to Zoom migration...\n');

    const now = new Date();

    try {
        // Find future appointments with Jitsi links or pending status
        const snapshot = await db.collection('appointments')
            .where('type', '==', 'video')
            .get();

        console.log(`📋 Found ${snapshot.size} video appointments total\n`);

        let updated = 0;
        let skipped = 0;
        let errors = 0;

        for (const doc of snapshot.docs) {
            const data = doc.data();

            // Parse appointment date
            let appointmentDate;
            if (data.appointmentDate?.toDate) {
                appointmentDate = data.appointmentDate.toDate();
            } else if (data.appointmentDate) {
                appointmentDate = new Date(data.appointmentDate);
            } else {
                console.log(`⚠️ Skipping ${doc.id}: No appointment date`);
                skipped++;
                continue;
            }

            // Skip past appointments
            if (appointmentDate <= now) {
                console.log(`⏭️ Skipping ${doc.id}: Past appointment (${appointmentDate.toISOString()})`);
                skipped++;
                continue;
            }

            // Skip cancelled/completed appointments
            if (data.status === 'cancelled' || data.status === 'completed') {
                console.log(`⏭️ Skipping ${doc.id}: Status is ${data.status}`);
                skipped++;
                continue;
            }

            // Check if needs migration (has Jitsi link or 'pending' placeholder)
            const needsMigration =
                data.meetingLink?.includes('meet.jit.si') ||
                data.meetingLink === 'pending' ||
                !data.meetingLink ||
                !data.zoomMeetingId;

            if (!needsMigration) {
                console.log(`⏭️ Skipping ${doc.id}: Already has Zoom link`);
                skipped++;
                continue;
            }

            // Create new Zoom meeting
            console.log(`\n🔄 Migrating appointment ${doc.id}...`);
            console.log(`   Doctor: ${data.doctorName}`);
            console.log(`   Patient: ${data.patientName}`);
            console.log(`   Date: ${appointmentDate.toISOString()}`);
            console.log(`   Current Link: ${data.meetingLink}`);

            try {
                const zoomMeeting = await createZoomMeeting(
                    `استشارة طبية - ${data.doctorName || 'ElajTech'}`,
                    data.doctorName || 'ElajTech',
                    30
                );

                await doc.ref.update({
                    meetingLink: zoomMeeting.joinUrl,
                    doctorMeetingUrl: zoomMeeting.startUrl,
                    zoomMeetingId: zoomMeeting.meetingId,
                    zoomPassword: zoomMeeting.password,
                    meetingProvider: 'zoom',
                    migratedFromJitsi: true,
                    migratedAt: admin.firestore.FieldValue.serverTimestamp(),
                });

                console.log(`   ✅ Updated with Zoom URL: ${zoomMeeting.joinUrl}`);
                updated++;

                // Rate limiting: wait 1 second between Zoom API calls
                await new Promise(resolve => setTimeout(resolve, 1000));

            } catch (error) {
                console.error(`   ❌ Error: ${error.message}`);
                errors++;
            }
        }

        console.log('\n' + '='.repeat(50));
        console.log('🎉 Migration Complete!');
        console.log(`   ✅ Updated: ${updated}`);
        console.log(`   ⏭️ Skipped: ${skipped}`);
        console.log(`   ❌ Errors: ${errors}`);
        console.log('='.repeat(50));

    } catch (error) {
        console.error('❌ Migration failed:', error);
        process.exit(1);
    }
}

// Run the migration
fixJitsiLinks()
    .then(() => process.exit(0))
    .catch(err => {
        console.error(err);
        process.exit(1);
    });
