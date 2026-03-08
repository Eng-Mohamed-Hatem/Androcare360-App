/**
 * Zoom Helper Functions
 * Used by both Cloud Functions and migration scripts
 */

require('dotenv').config({ path: '../functions/.env' });

// Cache for access token
let zoomAccessTokenCache = {
    token: null,
    expiresAt: 0
};

/**
 * Get Zoom configuration from environment
 */
function getZoomConfig() {
    return {
        clientId: process.env.ZOOM_CLIENT_ID || '',
        clientSecret: process.env.ZOOM_CLIENT_SECRET || '',
        accountId: process.env.ZOOM_ACCOUNT_ID || '',
    };
}

/**
 * Get Zoom Access Token via Server-to-Server OAuth
 */
async function getZoomAccessToken() {
    const now = Date.now();

    // Check cache first
    if (zoomAccessTokenCache.token && now < zoomAccessTokenCache.expiresAt) {
        console.log('✅ Using cached Zoom access token');
        return zoomAccessTokenCache.token;
    }

    console.log('🔑 Requesting new Zoom access token...');

    const { clientId, clientSecret, accountId } = getZoomConfig();

    if (!clientId || !clientSecret || !accountId) {
        console.error('❌ Zoom credentials not configured!');
        console.error('ZOOM_CLIENT_ID:', clientId ? 'SET' : 'MISSING');
        console.error('ZOOM_CLIENT_SECRET:', clientSecret ? 'SET' : 'MISSING');
        console.error('ZOOM_ACCOUNT_ID:', accountId ? 'SET' : 'MISSING');
        throw new Error('Zoom credentials not configured. Check .env file.');
    }

    try {
        const fetch = (await import('node-fetch')).default;

        // Base64 encode credentials
        const credentials = Buffer.from(`${clientId}:${clientSecret}`).toString('base64');

        const response = await fetch('https://zoom.us/oauth/token', {
            method: 'POST',
            headers: {
                'Authorization': `Basic ${credentials}`,
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: `grant_type=account_credentials&account_id=${accountId}`
        });

        if (!response.ok) {
            const errorText = await response.text();
            console.error('❌ Zoom OAuth error:', response.status, errorText);
            throw new Error(`Zoom OAuth failed: ${response.status}`);
        }

        const data = await response.json();

        // Cache token (expires 5 minutes early for safety)
        zoomAccessTokenCache = {
            token: data.access_token,
            expiresAt: now + ((data.expires_in - 300) * 1000)
        };

        console.log('✅ Zoom access token obtained successfully');
        return data.access_token;

    } catch (error) {
        console.error('❌ Error getting Zoom access token:', error);
        throw error;
    }
}

module.exports = {
    getZoomConfig,
    getZoomAccessToken,
};
