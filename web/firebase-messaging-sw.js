// Give the service worker access to Firebase Messaging.
// Note that you can only use Firebase Messaging here. Other Firebase libraries
// are not available in the service worker.
importScripts('https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js');

// Initialize the Firebase app in the service worker by passing in
// your app's Firebase config object.
// https://firebase.google.com/docs/web/setup#config-object
firebase.initializeApp({
    apiKey: "AIzaSyCCAvjopqHF0_1e3_NuoH6wNJCof8ReptU",
    authDomain: "elajtech-fc804.firebaseapp.com",
    projectId: "elajtech-fc804",
    storageBucket: "elajtech-fc804.firebasestorage.app",
    messagingSenderId: "375824242048",
    appId: "1:375824242048:web:8bbdea84f709a608ea5d65",
    measurementId: "G-M32DG8WG25"
});

// Retrieve an instance of Firebase Messaging so that it can handle background
// messages.
const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);

    const notificationTitle = payload.notification.title || 'إشعار جديد';
    const notificationOptions = {
        body: payload.notification.body || '',
        icon: '/icons/Icon-192.png',
        badge: '/icons/Icon-192.png',
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
});
