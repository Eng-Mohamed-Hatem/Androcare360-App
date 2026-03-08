# ElajTech Backend setup (Google Meet & Notifications)

This directory contains the Firebase Cloud Functions code required to:
1. Automatically generate Google Meet links when a video appointment is booked.
2. Send Email and Push Notifications to patients/doctors 30 minutes before the appointment.

## Prerequisites

1.  **Google Cloud Project**: Your Firebase project must be on the **Blaze (Pay-as-you-go)** plan.
2.  **Google Calendar API**: 
    *   Go to Google Cloud Console > APIs & Services > Enable APIs.
    *   Search for "Google Calendar API" and enable it.
3.  **Service Account**:
    *   Go to Google Cloud Console > IAM & Admin > Service Accounts.
    *   Create a new Service Account.
    *   Give it the role "Owner" or Specific permissions for Calendar.
    *   Create a JSON Key for this account and download it.
    *   **Rename** the file to `service-account.json` and place it in the `functions/` folder.
4.  **Email Configuration**:
    *   Open `functions/index.js`.
    *   Find the `nodemailer.createTransport` section.
    *   Update user/pass with your email credentials (or use SendGrid/Mailgun).

## Installation & Deployment

1.  **Install Dependencies**:
    Open a terminal in the `firebase_backend/functions` folder:
    ```bash
    npm install
    ```

2.  **Deploy to Firebase**:
    Make sure you have firebase-tools installed (`npm install -g firebase-tools`) and hold login.
    ```bash
    firebase login
    firebase init functions 
    # Select 'Use existing project' -> Your ElajTech project
    # Overwrite? NO (Keep the index.js I created)
    
    firebase deploy --only functions
    ```

## Testing

1.  Book a Video Appointment in the Flutter App.
2.  Check the Firebase Console > Functions > Logs.
3.  You should see "Generating Meet Link..." and subsequently the link appearing in your Firestore `appointments` document.
