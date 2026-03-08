const functions = require("firebase-functions/v1");
// ... existing code ...

// --- TEST FUNCTION ---
exports.testMeetLink = functions.https.onRequest(async (req, res) => {
    const { google } = require("googleapis");
    const SERVICE_ACCOUNT_FILE = "./service-account.json";
    const SCOPES = ["https://www.googleapis.com/auth/calendar"];

    try {
        const auth = new google.auth.GoogleAuth({
            keyFile: SERVICE_ACCOUNT_FILE,
            scopes: SCOPES,
        });
        const calendar = google.calendar({ version: "v3", auth });

        // Create a dummy event
        const event = {
            summary: "Test Meeting",
            start: { dateTime: new Date().toISOString() },
            end: { dateTime: new Date(Date.now() + 3600000).toISOString() },
            conferenceData: {
                createRequest: {
                    requestId: "test-" + Date.now(),
                    conferenceSolutionKey: { type: "hangoutsMeet" },
                },
            },
        };

        const response = await calendar.events.insert({
            calendarId: "primary",
            resource: event,
            conferenceDataVersion: 1,
        });

        res.send({ status: "success", link: response.data.hangoutLink });
    } catch (error) {
        res.status(500).send({ error: error.message });
    }
});
