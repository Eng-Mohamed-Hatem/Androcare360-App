const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
const { RtcTokenBuilder, RtcRole } = require('agora-access-token');

// Load environment variables from .env file (Modern 2026 approach)
require('dotenv').config();

// ✅ Initialize Firebase Admin at module level
// هذا يضمن أن Firebase جاهز قبل أي استخدام لـ FieldValue.serverTimestamp()
if (admin.apps.length === 0) {
  admin.initializeApp();
}

// Lazy Initialization for database with custom databaseId
// يتم إنشاء النسخة فقط عند أول استخدام فعلي
let dbInstance;
function getDB() {
  if (!dbInstance) {
    const { getFirestore } = require("firebase-admin/firestore");
    // ✅ استخدام databaseId: 'elajtech' لضمان استقرار البيانات
    dbInstance = getFirestore(admin.app(), 'elajtech');
  }
  return dbInstance;
}

// Lazy load Messaging
function getMessaging() {
  const { getMessaging } = require("firebase-admin/messaging");
  return getMessaging();
}

// Lazy load Transporter
function getTransporter() {
  const nodemailer = require("nodemailer");
  return nodemailer.createTransport({
    service: "gmail", // OR use generic SMTP
    auth: {
      user: "mohamed.g2211@gmail.com", // REPLACE THIS
      pass: "gfrl yypz qtvu jyay",    // REPLACE THIS
    },
  });
}

// Google Calendar Auth Config
const SCOPES = ["https://www.googleapis.com/auth/calendar"];
const SERVICE_ACCOUNT_FILE = "./service-account.json"; // PATH TO YOUR KEY

// ============================================
// إعدادات Zoom Server-to-Server OAuth (Modern 2026)
// ============================================
// تستخدم process.env لقراءة المتغيرات من .env
function getZoomConfig() {
  return {
    clientId: process.env.ZOOM_CLIENT_ID || '',
    clientSecret: process.env.ZOOM_CLIENT_SECRET || '',
    accountId: process.env.ZOOM_ACCOUNT_ID || '',
  };
}

// Cache for access token to avoid unnecessary API calls
let zoomAccessTokenCache = {
  token: null,
  expiresAt: 0
};

/**
 * مسح التوكن المخزن لإجبار النظام على طلب توكن جديد
 * يُستدعى عند حدوث خطأ 400/401 من Zoom API (مشكلة صلاحيات)
 */
function clearZoomTokenCache() {
  console.log('🗑️ Clearing Zoom access token cache...');
  zoomAccessTokenCache = {
    token: null,
    expiresAt: 0
  };
  console.log('✅ Zoom token cache cleared - next request will fetch fresh token');
}

/**
 * الحصول على Access Token من Zoom عبر Server-to-Server OAuth
 * @returns {Promise<string>} Access Token
 */
async function getZoomAccessToken() {
  const now = Date.now();

  // التحقق من الكاش أولاً
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

    // 📋 Log scopes for debugging - تسجيل الصلاحيات للتحقق
    console.log('📋 Token Scopes received:', data.scope || 'No scopes in response');
    if (data.scope) {
      if (data.scope.includes('meeting:write')) {
        console.log('✅ Required scope meeting:write is present');
      } else {
        console.warn('⚠️ WARNING: Token missing required scope: meeting:write');
        console.warn('   Available scopes:', data.scope);
      }
    }

    // تخزين الـ token في الكاش (ينتهي قبل 5 دقائق للأمان)
    zoomAccessTokenCache = {
      token: data.access_token,
      expiresAt: now + ((data.expires_in - 300) * 1000)
    };

    console.log('✅ Zoom access token obtained successfully');
    console.log('   Token expires in:', data.expires_in, 'seconds');
    return data.access_token;

  } catch (error) {
    console.error('❌ Error getting Zoom access token:', error);
    throw error;
  }
}

/**
 * إنشاء اجتماع Zoom جديد
 * @param {string} topic - عنوان الاجتماع
 * @param {string} doctorName - اسم الطبيب
 * @param {number} duration - مدة الاجتماع بالدقائق
 * @returns {Promise<{meetingId: string, password: string, joinUrl: string, startUrl: string}>}
 */
async function createZoomMeeting(topic, doctorName, duration = 30, isRetry = false) {
  console.log('🎥 Creating Zoom meeting:', topic);
  if (isRetry) {
    console.log('🔄 This is a RETRY attempt with fresh token');
  }

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
        approval_type: 2, // No registration required
        audio: 'both',
        auto_recording: 'none',
        waiting_room: false,
        meeting_authentication: false,
      }
    };

    // استخدام 'me' لإنشاء الاجتماع باسم الحساب الرئيسي
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

      // 🔄 If 400/401 error (scope/auth issue), clear cache and retry once
      // خطأ 400/401 يعني مشكلة في الصلاحيات - نمسح الكاش ونعيد المحاولة
      if ((response.status === 400 || response.status === 401) && !isRetry) {
        console.log('🔄 Detected scope/auth error - clearing cached token and retrying...');
        clearZoomTokenCache();
        return createZoomMeeting(topic, doctorName, duration, true); // Retry once
      }

      throw new Error(`Zoom meeting creation failed: ${response.status} - ${errorText}`);
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

// ============================================
// إعدادات إعادة المحاولة - Retry Configuration
// ============================================
const RETRY_CONFIG = {
  maxAttempts: 3,
  backoffDelay: 1000, // 1 second
  maxBackoffDelay: 10000, // 10 seconds
};

/**
 * دالة مساعدة لإعادة المحاولة مع تأخير تدريجي
 */
async function retryWithBackoff(fn, attempt = 1) {
  try {
    return await fn();
  } catch (error) {
    if (attempt >= RETRY_CONFIG.maxAttempts) {
      throw error;
    }

    const delay = Math.min(
      RETRY_CONFIG.backoffDelay * Math.pow(2, attempt - 1),
      RETRY_CONFIG.maxBackoffDelay
    );

    console.log(`⏳ Retry attempt ${attempt + 1} after ${delay}ms`);
    await new Promise(resolve => setTimeout(resolve, delay));

    return retryWithBackoff(fn, attempt + 1);
  }
}

/**
 * دالة مساعدة لتسجيل الأخطاء بشكل مفصل
 */
function logError(context, error, details = {}) {
  console.error({
    timestamp: new Date().toISOString(),
    function: 'sendChatNotification',
    chatId: context?.params?.chatId,
    messageId: context?.params?.messageId,
    error: {
      name: error.name,
      message: error.message,
      code: error.code,
      stack: error.stack,
    },
    details,
  });
}

// ============================================
// Trigger: When an Appointment is Created/Updated
// Goal: Generate Zoom Session for Video Consultations
// ============================================
exports.generateMeetLink = functions.region("europe-west1").firestore
  .document("appointments/{appointmentId}")
  .onWrite(async (change, context) => {
    console.log("🔥 TRIGGER FIRED: appointments/.onWrite");
    console.log("Appointment ID:", context.params.appointmentId);

    const appointment = change.after.data();
    console.log("Data received:", JSON.stringify(appointment));

    // conditions: exists, is video, no session name yet
    if (!appointment) {
      console.log("❌ No appointment data (Deleted?)");
      return null;
    }

    console.log("Checking conditions: Type=", appointment.type, " Session=", appointment.zoomSessionName);

    if (
      appointment.type !== "video" ||
      appointment.zoomSessionName // Already has Zoom session
    ) {
      console.log("⚠️ Skipped: Not video or session exists");
      return null;
    }

    try {
      console.log(`✅ Creating REAL Zoom Meeting for ${context.params.appointmentId}`);

      // --- ZOOM API INTEGRATION ---
      // Create actual Zoom meeting for this appointment
      const meetingTopic = `استشارة طبية - ElajTech #${context.params.appointmentId}`;

      const zoomMeeting = await createZoomMeeting(meetingTopic, 'ElajTech', 30);

      console.log(`✅ Zoom Meeting Created: ID=${zoomMeeting.meetingId}, URL=${zoomMeeting.joinUrl}`);

      // Update Firestore with real Zoom meeting data
      await change.after.ref.update({
        zoomMeetingId: zoomMeeting.meetingId,
        zoomPassword: zoomMeeting.password,
        meetingLink: zoomMeeting.joinUrl, // ✅ Real Zoom URL!
        doctorMeetingUrl: zoomMeeting.startUrl,
        meetingProvider: "zoom",
        zoomSessionName: `ElajTech-${context.params.appointmentId}`, // Keep for backwards compatibility
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log("✅ Appointment updated with real Zoom Meeting URL");

    } catch (error) {
      console.error("❌ Error creating Zoom meeting:", error);

      // Fallback: If Zoom API fails, use session placeholder
      console.log("⚠️ Falling back to session placeholder...");
      const sessionName = `ElajTech-${context.params.appointmentId}`;
      await change.after.ref.update({
        zoomSessionName: sessionName,
        meetingLink: `zoom://session/${sessionName}`,
        meetingProvider: "zoom",
        zoomError: error.message,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  });

// ============================================
// Callable Function: Start Video Call (Doctor initiates)
// Goal: Create Zoom meeting, send VoIP push to patient
// ============================================
exports.startVideoCall = functions.region("europe-west1")
  .runWith({ enforceAppCheck: false }) // ✅ تفعيل حماية App Check
  .https.onCall(async (data, context) => {
    console.log("📞 startVideoCall called");

    // ⚠️ مُعطَّل مؤقتاً للسماح بتوليد Debug Token - يجب إعادة تفعيله بعد التسجيل!
    // ✅ التحقق من App Check (في الإنتاج)
    // if (!context.app && process.env.NODE_ENV === 'production') {
    //   console.error('❌ App Check token missing - unauthorized request');
    //   throw new functions.https.HttpsError(
    //     'failed-precondition',
    //     'طلب غير مصرح به - يجب استخدام التطبيق الرسمي'
    //   );
    // }

    // Validate input
    const { appointmentId, doctorId } = data;

    if (!appointmentId || !doctorId) {
      console.error('❌ Missing required fields: appointmentId or doctorId');
      throw new functions.https.HttpsError(
        'invalid-argument',
        'معرف الموعد ومعرف الطبيب مطلوبان'
      );
    }

    try {
      const db = getDB();

      // 1. Get appointment data
      const appointmentDoc = await db.collection('appointments').doc(appointmentId).get();

      if (!appointmentDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'الموعد غير موجود');
      }

      const appointment = appointmentDoc.data();

      // 2. Validate doctor owns this appointment
      if (appointment.doctorId !== doctorId) {
        throw new functions.https.HttpsError('permission-denied', 'ليس لديك صلاحية بدء هذه المكالمة');
      }

      // 3. Get doctor data
      const doctorDoc = await db.collection('users').doc(doctorId).get();
      const doctor = doctorDoc.data();
      const doctorName = doctor?.fullName || 'الطبيب';

      // 4. Get patient data
      const patientDoc = await db.collection('users').doc(appointment.patientId).get();
      const patient = patientDoc.data();

      if (!patient || !patient.fcmToken) {
        console.warn('⚠️ Patient has no FCM token');
        throw new functions.https.HttpsError('failed-precondition', 'المريض غير متصل بالتطبيق');
      }

      // 5. Create Zoom meeting via API
      console.log('🎥 Creating Zoom meeting for appointment:', appointmentId);

      const meetingTopic = `استشارة طبية - ${doctorName} مع ${appointment.patientName}`;
      const zoomMeeting = await createZoomMeeting(meetingTopic, doctorName, 30);

      console.log(`✅ Zoom meeting created: ID=${zoomMeeting.meetingId}`);

      // 6. Update appointment with meeting data
      await appointmentDoc.ref.update({
        zoomMeetingId: zoomMeeting.meetingId,
        zoomPassword: zoomMeeting.password,
        meetingLink: zoomMeeting.joinUrl,
        doctorMeetingUrl: zoomMeeting.startUrl,
        meetingProvider: 'zoom',
        callStatus: 'ringing',
        callStartedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 7. Send VoIP push notification to patient
      // ✅ مهم: استخدام data-only message للسماح لـ flutter_callkit_incoming
      // بالتحكم الكامل في الرنين وواجهة المكالمة
      const payload = {
        // ⚠️ لا نستخدم notification object هنا لأنه يتعارض مع CallKit
        // بيانات للتطبيق لعرض شاشة المكالمة مع الرنين
        data: {
          type: 'incoming_call',
          appointmentId: appointmentId,
          meetingId: zoomMeeting.meetingId,
          meetingPassword: zoomMeeting.password,
          meetingLink: zoomMeeting.joinUrl,
          callerName: doctorName,
          callerAvatar: doctor?.profileImage || '',
          // ⚠️ جميع القيم يجب أن تكون String
          timestamp: Date.now().toString(),
        },
        // ✅ إعدادات Android عالية الأولوية - بدون notification
        android: {
          priority: 'high',
          ttl: 60000,
          // ⚠️ إزالة notification من هنا ليعمل flutter_callkit_incoming
        },
        // إعدادات iOS VoIP - للمكالمات
        apns: {
          headers: {
            'apns-priority': '10',
            'apns-push-type': 'alert', // ✅ تغيير من voip لضمان الوصول
            'apns-expiration': '0',
          },
          payload: {
            aps: {
              'content-available': 1,
              'mutable-content': 1,
              alert: {
                title: '📞 مكالمة واردة',
                body: `مكالمة فيديو من ${doctorName}`,
              },
              sound: 'default',
            },
          },
        },
      };

      await getMessaging().send({
        token: patient.fcmToken,
        ...payload,
      });

      console.log(`✅ VoIP push sent to patient: ${appointment.patientId}`);

      // 8. Return meeting data for doctor to join
      return {
        success: true,
        meetingId: zoomMeeting.meetingId,
        password: zoomMeeting.password,
        startUrl: zoomMeeting.startUrl,
        joinUrl: zoomMeeting.joinUrl,
        message: 'تم بدء الاتصال بنجاح'
      };

    } catch (error) {
      console.error('❌ Error in startVideoCall:', error);

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      throw new functions.https.HttpsError(
        'internal',
        'حدث خطأ أثناء بدء المكالمة: ' + error.message
      );
    }
  });

// ============================================
// Callable Function: Handle Missed Call
// Goal: Update appointment status when call times out
// ============================================
exports.handleMissedCall = functions.region("europe-west1")
  .runWith({ enforceAppCheck: false }) // ✅ مُعطَّل للسماح بالاختبار
  .https.onCall(async (data, context) => {
    console.log("📞 handleMissedCall called");

    // ⚠️ App Check مُعطَّل مؤقتاً للاختبار
    // TODO: إعادة تفعيله في الإنتاج
    // if (!context.app && process.env.NODE_ENV === 'production') {
    //   console.warn('⚠️ App Check token missing');
    //   throw new functions.https.HttpsError(
    //     'failed-precondition',
    //     'طلب غير مصرح به'
    //   );
    // }

    const { appointmentId } = data;
    if (!appointmentId) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'معرف الموعد مطلوب'
      );
    }

    try {
      const db = getDB();

      // تحديث حالة الموعد
      await db.collection('appointments').doc(appointmentId).update({
        callStatus: 'missed',
        missedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`✅ Appointment ${appointmentId} marked as missed call`);

      return { success: true, message: 'تم تسجيل المكالمة الفائتة' };
    } catch (error) {
      console.error('❌ Error in handleMissedCall:', error);
      throw new functions.https.HttpsError(
        'internal',
        'حدث خطأ أثناء تسجيل المكالمة الفائتة'
      );
    }
  });

// ============================================
// Callable Function: Handle Call Declined
// Goal: Update appointment status and notify doctor when patient declines
// ============================================
exports.handleCallDeclined = functions.region("europe-west1")
  .runWith({ enforceAppCheck: false }) // ✅ مُعطَّل للسماح بالاختبار
  .https.onCall(async (data, context) => {
    console.log("📞 handleCallDeclined called");

    // ⚠️ App Check مُعطَّل مؤقتاً للاختبار
    // TODO: إعادة تفعيله في الإنتاج
    // if (!context.app && process.env.NODE_ENV === 'production') {
    //   console.warn('⚠️ App Check token missing');
    //   throw new functions.https.HttpsError(
    //     'failed-precondition',
    //     'طلب غير مصرح به'
    //   );
    // }

    const { appointmentId } = data;
    if (!appointmentId) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'معرف الموعد مطلوب'
      );
    }

    try {
      const db = getDB();

      // 1. الحصول على بيانات الموعد
      const appointmentDoc = await db.collection('appointments').doc(appointmentId).get();
      if (!appointmentDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'الموعد غير موجود');
      }

      const appointment = appointmentDoc.data();

      // 2. تحديث حالة الموعد
      await db.collection('appointments').doc(appointmentId).update({
        callStatus: 'declined',
        declinedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`✅ Appointment ${appointmentId} marked as declined`);

      // 3. إرسال إشعار للطبيب لإغلاق واجهة الاتصال
      const doctorDoc = await db.collection('users').doc(appointment.doctorId).get();
      if (doctorDoc.exists) {
        const doctorData = doctorDoc.data();
        const doctorToken = doctorData.fcmToken;

        if (doctorToken) {
          console.log(`📤 Sending decline notification to doctor: ${appointment.doctorId}`);

          await getMessaging().send({
            token: doctorToken,
            data: {
              type: 'call_declined',
              appointmentId: appointmentId,
              patientName: appointment.patientName || 'المريض',
            },
            notification: {
              title: '❌ تم رفض المكالمة',
              body: `${appointment.patientName || 'المريض'} رفض المكالمة`,
            },
            android: {
              priority: 'high',
              notification: {
                channelId: 'call_status',
                priority: 'high',
              },
            },
          });

          console.log('✅ Decline notification sent to doctor');
        }
      }

      return { success: true, message: 'تم إخطار الطبيب برفض المكالمة' };
    } catch (error) {
      console.error('❌ Error in handleCallDeclined:', error);
      if (error instanceof functions.https.HttpsError) {
        throw error;
      }
      throw new functions.https.HttpsError(
        'internal',
        'حدث خطأ أثناء معالجة رفض المكالمة'
      );
    }
  });

// ============================================
// Scheduled Task: Check for upcoming appointments
// Frequency: Every 15 minutes
// Goal: Send Email & Push Notification 30 mins before
// ============================================
exports.sendAppointmentReminders = functions.region("europe-west1").pubsub
  .schedule("every 15 minutes")
  .timeZone("Asia/Riyadh")
  .onRun(async (context) => {
    // Lazy load moment
    const moment = require("moment-timezone");

    const now = moment().tz("Asia/Riyadh");
    const thirtyMinutesLater = now.clone().add(30, "minutes");
    const fortyFiveMinutesLater = now.clone().add(45, "minutes");

    // Query appointments happening between 30 and 45 mins from now
    // NOTE: This requires storing a proper Timestamp field for easy querying

    // Simplification: Fetch confirmed appointments for 'today' and filter in memory if volume is low,
    // or better, use proper range queries on 'appointmentDate'.
    // Here assuming 'appointmentDate' is a Timestamp or ISO string that can be queried.

    const snapshot = await getDB().collection("appointments")
      .where("status", "==", "confirmed")
      .where("type", "==", "video")
      .get();

    const promises = [];

    snapshot.docs.forEach((doc) => {
      const appt = doc.data();

      // Parse Date (YYYY-MM-DDT00:00:00.000)
      let dateTime = moment.tz(appt.appointmentDate, "Asia/Riyadh");

      // Parse Time Slot (e.g., "10:30 PM", "10:30 م", "22:30")
      if (appt.timeSlot) {
        const timeParts = appt.timeSlot.split(/[:\s]/); // Split by colon or space
        let hours = parseInt(timeParts[0]);
        let minutes = parseInt(timeParts[1]);

        const isPM = appt.timeSlot.includes('PM') || appt.timeSlot.includes('م') || appt.timeSlot.includes('مساء');
        const isAM = appt.timeSlot.includes('AM') || appt.timeSlot.includes('ص') || appt.timeSlot.includes('صباح');

        if (isPM && hours !== 12) hours += 12;
        if (isAM && hours === 12) hours = 0;

        dateTime.hour(hours).minute(minutes).second(0);
      }

      const diffMinutes = dateTime.diff(now, 'minutes');

      // Check strictly 30 mins (with 1-2 min buffer for execution time)
      if (diffMinutes >= 28 && diffMinutes <= 32) {
        promises.push(sendNotifications(appt));
      }
    });

    await Promise.all(promises);
    return null;
  });

async function sendNotifications(appt) {
  const patientDoc = await getDB().collection("users").doc(appt.patientId).get();
  const doctorDoc = await getDB().collection("users").doc(appt.doctorId).get();

  const patient = patientDoc.data();
  const doctor = doctorDoc.data();

  // Define Meeting Link
  const meetingLink = appt.meetingLink || "الرابط موجود في التطبيق";
  const timeSlot = appt.timeSlot || "الموعد المحدد";

  // 2. Send Emails
  const mailOptionsPatient = {
    from: "noreply@elajtech.com",
    to: patient.email,
    subject: "تذكير بموعد الاستشارة - علاج تك",
    text: `مرحباً ${patient.fullName}،\n\nنود تذكيركم بأن موعد الاستشارة الفيديو مع د. ${doctor.fullName} سيكون في تمام الساعة ${timeSlot} (بعد 30 دقيقة).\n\nرابط الاجتماع: ${meetingLink}\n\nشكراً لاستخدامكم تطبيق علاج تك.`,
  };

  const mailOptionsDoctor = {
    from: "noreply@elajtech.com",
    to: doctor.email,
    subject: "تذكير بموعد استشارة قادم",
    text: `د. ${doctor.fullName}،\n\nلديك موعد استشارة فيديو مع المريض ${patient.fullName} في تمام الساعة ${timeSlot}.\n\nرابط الاجتماع: ${meetingLink}\n\nيرجى الاستعداد.`,
  };

  const transporter = getTransporter();

  if (patient.email) await transporter.sendMail(mailOptionsPatient).catch(err => console.error(err));
  if (doctor.email) await transporter.sendMail(mailOptionsDoctor).catch(err => console.error(err));

  // 3. Send Push Notifications
  // Patient
  if (patient.fcmToken) {
    const payloadPatient = {
      notification: {
        title: "تذكير: موعد الاستشارة",
        body: `الموعد: ${timeSlot} (بعد 30 دقيقة).\nرابط: ${meetingLink}`,
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        appointmentId: appt.id,
        type: "appointment_reminder"
      }
    };
    await getMessaging().sendToDevice(patient.fcmToken, payloadPatient).catch(err => console.error(err));
  }

  // Doctor
  if (doctor.fcmToken) {
    const payloadDoctor = {
      notification: {
        title: "موعد قادم",
        body: `موعد مع ${patient.fullName} الساعة ${timeSlot}.\nرابط: ${meetingLink}`,
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        appointmentId: appt.id,
        type: "appointment_reminder"
      }
    };
    await getMessaging().sendToDevice(doctor.fcmToken, payloadDoctor).catch(err => console.error(err));
  }
}

// ============================================
// TEST FUNCTION (HTTP)
// Trigger this in browser to check if Calendar API works
// ============================================
exports.testCalendar = functions.region("europe-west1").https.onRequest(async (req, res) => {
  try {
    const { google } = require("googleapis");
    const SERVICE_ACCOUNT_FILE = "./service-account.json";
    const SCOPES = ["https://www.googleapis.com/auth/calendar"];

    const auth = new google.auth.GoogleAuth({
      keyFile: SERVICE_ACCOUNT_FILE,
      scopes: SCOPES,
    });
    const calendar = google.calendar({ version: "v3", auth });

    const event = {
      summary: "Test Link Generation",
      description: "Debug Event",
      start: { dateTime: new Date().toISOString() },
      end: { dateTime: new Date(Date.now() + 1800000).toISOString() }, // +30 mins
      conferenceData: {
        createRequest: {
          requestId: "test-" + Date.now(),
          conferenceSolutionKey: { type: "hangoutsMeet" },
        },
      },
    };

    const response = await calendar.events.insert({
      calendarId: "mohamed.g2211@gmail.com", // Try distinct email
      resource: event,
      conferenceDataVersion: 1,
    });

    res.status(200).send({
      status: "SUCCESS",
      link: response.data.hangoutLink,
      message: "Calendar API is working!"
    });
  } catch (error) {
    res.status(500).send({
      status: "FAILED",
      error: error.message,
      stack: error.stack
    });
  }
});

// ============================================
// Trigger: When a new Chat Message is sent
// Goal: Send Push Notification to the receiver
// ============================================
exports.sendChatNotification = functions.region("europe-west1").firestore
  .document("chats/{chatId}/messages/{messageId}")
  .onCreate(async (snapshot, context) => {
    const startTime = Date.now();
    console.log("🔥 TRIGGER FIRED: sendChatNotification");
    const message = snapshot.data();
    const chatId = context.params.chatId;
    const messageId = context.params.messageId;

    // التحقق من وجود الرسالة
    if (!message) {
      console.log("⚠️ No message data");
      return null;
    }

    try {
      // 1. Get Chat Metadata to find participants
      let chatDoc, chatData;
      try {
        chatDoc = await retryWithBackoff(async () => {
          return await getDB().collection("chats").doc(chatId).get();
        });
        chatData = chatDoc.data();

        if (!chatData) {
          console.log(`⚠️ Chat document not found: ${chatId}`);
          return null;
        }
      } catch (error) {
        logError(context, error, { step: 'getChatDoc' });
        return null;
      }

      // 2. Identify Receiver
      const receiverId = message.receiverId;
      // Fallback if receiverId not in message: find participant who is NOT sender
      // const receiverId = chatData.participants.find(id => id !== message.senderId);

      if (!receiverId) {
        console.log("⚠️ No receiver found");
        return null;
      }

      // التحقق من أن المستلم مشارك في المحادثة
      if (!chatData.participants || !chatData.participants.includes(receiverId)) {
        console.log(`⚠️ Receiver ${receiverId} is not a participant in chat ${chatId}`);
        return null;
      }

      // 3. Get Receiver's FCM Token
      let userDoc, userData;
      try {
        userDoc = await retryWithBackoff(async () => {
          return await getDB().collection("users").doc(receiverId).get();
        });
        userData = userDoc.data();

        if (!userData) {
          console.log(`⚠️ User ${receiverId} document not found`);
          return null;
        }
      } catch (error) {
        logError(context, error, { step: 'getUserDoc', receiverId });
        return null;
      }

      if (!userData.fcmToken) {
        console.log(`⚠️ User ${receiverId} has no FCM Token`);

        // إنشاء مستند لتتبع المستخدمين بدون FCM Token
        try {
          await getDB().collection('notification_errors').add({
            type: 'no_fcm_token',
            userId: receiverId,
            chatId: chatId,
            messageId: messageId,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
          });
        } catch (logError) {
          // تجاهل الأخطاء في التسجيل
        }

        return null;
      }

      // 4. Send Notification
      const payload = {
        notification: {
          title: message.senderName || "رسالة جديدة",
          body: message.type === 'image' ? '📷 صورة' :
            message.isEncrypted ? '🔒 رسالة مشفرة' : message.message,
          sound: "default",
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          chatId: chatId,
          type: "chat_message",
          senderId: message.senderId,
          messageId: messageId,
        }
      };

      let response;
      try {
        response = await retryWithBackoff(async () => {
          return await getMessaging().sendToDevice(userData.fcmToken, payload);
        });

        console.log(`✅ Notification sent to ${receiverId}`);
        console.log(`📊 Response:`, {
          successCount: response.successCount,
          failureCount: response.failureCount,
          results: response.results,
        });

        // تسجيل الإشعارات الناجحة
        if (response.successCount > 0) {
          try {
            await getDB().collection('notification_logs').add({
              type: 'chat_notification',
              receiverId: receiverId,
              senderId: message.senderId,
              chatId: chatId,
              messageId: messageId,
              success: true,
              timestamp: admin.firestore.FieldValue.serverTimestamp(),
            });
          } catch (logError) {
            // تجاهل الأخطاء في التسجيل
          }
        }

        // تسجيل الإشعارات الفاشلة
        if (response.failureCount > 0) {
          for (let i = 0; i < response.results.length; i++) {
            if (response.results[i].error) {
              try {
                await getDB().collection('notification_errors').add({
                  type: 'send_failed',
                  userId: receiverId,
                  chatId: chatId,
                  messageId: messageId,
                  error: response.results[i].error.message,
                  errorCode: response.results[i].error.code,
                  timestamp: admin.firestore.FieldValue.serverTimestamp(),
                });
              } catch (logError) {
                // تجاهل الأخطاء في التسجيل
              }
            }
          }
        }

      } catch (error) {
        logError(context, error, {
          step: 'sendNotification',
          receiverId,
          fcmToken: userData.fcmToken.substring(0, 20) + '...'
        });

        // تسجيل فشل الإرسال
        try {
          await getDB().collection('notification_errors').add({
            type: 'send_exception',
            userId: receiverId,
            chatId: chatId,
            messageId: messageId,
            error: error.message,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
          });
        } catch (logError) {
          // تجاهل الأخطاء في التسجيل
        }

        return null;
      }

      const duration = Date.now() - startTime;
      console.log(`⏱️ Notification sent in ${duration}ms`);

    } catch (error) {
      logError(context, error, { step: 'general' });
    }
  });

// ============================================
// Cloud Function: Validate Doctor Update
// ============================================
/**
 * دالة للتحقق من صحة تحديثات الطبيب
 * التحقق من:
 * 1. دور المستخدم (doctor vs patient)
 * 2. الحقول المُحدّثة المسموح بها
 * 3. عدم وجود حقول فارغة
 *
 * يتبع نمط Either<Failure, Success> من طبقة Domain
 */
exports.validateDoctorUpdate = functions.https.onCall(async (data, context) => {
  // التحقق من صحة البيانات
  const db = getDB();

  // التحقق من صحة المعاملات
  if (!data.userId || !data.updateData) {
    console.error('❌ Invalid parameters: userId or updateData missing');
    return {
      success: false,
      message: "بيانات غير صالحة",
      errorCode: "INVALID_PARAMETERS"
    };
  }

  const userDoc = await db.collection("users").doc(data.userId).get();

  if (!userDoc.exists) {
    console.error(`❌ User document not found: ${data.userId}`);
    return {
      success: false,
      message: "المستخدم غير موجود",
      errorCode: "USER_NOT_FOUND"
    };
  }

  const userData = userDoc.data();

  // التحقق من الدور
  const userRole = userData.userType || 'patient';

  // الحقول المسموح بها للجميع
  const commonAllowedFields = [
    'fullName',
    'profileImage',
    'fcmToken',
    'isOnline',
    'phoneNumber',
    'username'
  ];

  // الحقول الإضافية المسموح بها للأطباء
  const doctorAllowedFields = [
    ...commonAllowedFields,
    'licenseNumber',
    'specialization',
    'workingHours',
    'biography',
    'yearsOfExperience',
    'consultationFee',
    'consultationTypes',
    'clinicName',
    'clinicAddress',
    'education',
    'certificates'
  ];

  const requestedFields = Object.keys(data.updateData || {});

  // التحقق من أن الحقول المطلوبة مسموحة
  const invalidFields = requestedFields.filter(field =>
    userRole === 'doctor'
      ? !doctorAllowedFields.includes(field)
      : !commonAllowedFields.includes(field)
  );

  // إذا كانت هناك حقول غير مسموحة
  if (invalidFields.length > 0) {
    console.warn(`⚠️ Invalid fields requested: ${invalidFields.join(', ')}`);
    return {
      success: false,
      message: `الحقول التالية غير مسموحة للتحديث: ${invalidFields.join(', ')}`,
      errorCode: "INVALID_FIELDS",
      invalidFields: invalidFields
    };
  }

  // التحقق من عدم وجود حقول فارغة (للحقول المطلوبة فقط)
  const requiredFields = ['fullName', 'email'];
  const emptyFields = requiredFields.filter(field =>
    data.updateData[field] === null || data.updateData[field] === ''
  );

  if (emptyFields.length > 0) {
    console.warn(`⚠️ Empty required fields: ${emptyFields.join(', ')}`);
    return {
      success: false,
      message: `يجب توفير قيم للحقول المطلوبة: ${emptyFields.join(', ')}`,
      errorCode: "EMPTY_FIELDS",
      emptyFields: emptyFields
    };
  }

  // السماح بالتحديث
  console.log(`✅ Validation passed for user: ${data.userId}, role: ${userRole}`);

  return {
    success: true,
    message: "تم التحقق من صحة البيانات",
    errorCode: null,
    allowedUpdates: Object.keys(data.updateData || {}),
    userRole: userRole
  };
});

// ============================================
// 🎥 AGORA VIDEO CALL FUNCTIONS
// ============================================

/**
 * دالة توليد Agora Token
 * 
 * @param {string} channelName - اسم القناة (Channel Name)
 * @param {number} uid - معرّف المستخدم الفريد (User ID)
 * @param {string} role - دور المستخدم ('publisher' أو 'subscriber')
 * @param {number} expirationTime - وقت انتهاء الصلاحية بالثواني (افتراضي: 3600)
 * @returns {string} - Agora Token
 */
function generateAgoraToken(channelName, uid, role = 'publisher', expirationTime = 3600) {
  // استخدام المتغيرات البيئية من .env file
  const appId = process.env.AGORA_APP_ID;
  const appCertificate = process.env.AGORA_APP_CERTIFICATE;

  if (!appId || !appCertificate) {
    console.error('❌ Agora credentials not configured!');
    console.error('Make sure .env file exists with AGORA_APP_ID and AGORA_APP_CERTIFICATE');
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Agora App ID or Certificate not configured'
    );
  }

  const currentTimestamp = Math.floor(Date.now() / 1000);
  const privilegeExpiredTs = currentTimestamp + expirationTime;

  // تحديد الدور (Publisher = 1, Subscriber = 2)
  const agoraRole = role === 'publisher' ? RtcRole.PUBLISHER : RtcRole.SUBSCRIBER;

  // توليد الـ Token
  const token = RtcTokenBuilder.buildTokenWithUid(
    appId,
    appCertificate,
    channelName,
    uid,
    agoraRole,
    privilegeExpiredTs
  );

  console.log(`✅ Agora token generated for channel: ${channelName}, uid: ${uid}`);
  return token;
}

/**
 * Cloud Function: بدء مكالمة Agora
 * 
 * يتم استدعاؤها من الطبيب لبدء المكالمة
 * تقوم بـ:
 * 1. توليد Agora Token للطبيب والمريض
 * 2. تحديث بيانات الموعد في Firestore
 * 3. إرسال VoIP notification للمريض
 */
exports.startAgoraCall = functions.region("europe-west1")
  .runWith({ enforceAppCheck: false })
  .https.onCall(async (data, context) => {
    console.log('📞 startAgoraCall called');

    try {
      // التحقق من المصادقة
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'يجب تسجيل الدخول لبدء المكالمة'
        );
      }

      const { appointmentId, doctorId } = data;

      // التحقق من المدخلات
      if (!appointmentId || !doctorId) {
        throw new functions.https.HttpsError(
          'invalid-argument',
          'appointmentId and doctorId are required'
        );
      }

      const db = getDB();

      // جلب بيانات الموعد
      const appointmentRef = db.collection('appointments').doc(appointmentId);
      const appointmentDoc = await appointmentRef.get();

      if (!appointmentDoc.exists) {
        throw new functions.https.HttpsError(
          'not-found',
          'الموعد غير موجود'
        );
      }

      const appointment = appointmentDoc.data();

      // التحقق من أن المستخدم هو الطبيب المسؤول
      if (appointment.doctorId !== doctorId) {
        throw new functions.https.HttpsError(
          'permission-denied',
          'غير مصرح لك ببدء هذه المكالمة'
        );
      }

      // ============================================
      // 🕒 Session Time Validation
      // التحقق من وقت الموعد
      // ============================================

      // تحويل وقت الموعد إلى timestamp
      const appointmentTime = appointment.appointmentTime?.toDate?.() || appointment.appointmentTime;

      if (appointmentTime) {
        const now = new Date();
        const timeDiff = appointmentTime.getTime() - now.getTime();
        const minutesDiff = Math.floor(timeDiff / (1000 * 60));

        console.log(`⏰ Appointment time check: ${minutesDiff} minutes from now`);

        // لا تسمح بالمكالمة قبل 15 دقيقة من الموعد
        if (minutesDiff > 15) {
          throw new functions.https.HttpsError(
            'failed-precondition',
            `لا يمكن بدء المكالمة قبل ${minutesDiff} دقيقة من الموعد. يُسمح بالبدء قبل 15 دقيقة فقط.`
          );
        }

        // لا تسمح بالمكالمة بعد 30 دقيقة من الموعد
        if (minutesDiff < -30) {
          throw new functions.https.HttpsError(
            'failed-precondition',
            'انتهى وقت هذا الموعد. لا يمكن بدء المكالمة بعد 30 دقيقة من الوقت المحدد.'
          );
        }

        console.log(`✅ Time validation passed: within allowed window`);
      } else {
        console.warn('⚠️ No appointmentTime found in appointment data');
      }

      // إنشاء Channel Name فريد
      const channelName = `appointment_${appointmentId}_${Date.now()}`;

      // توليد UIDs فريدة (Agora يتطلب UIDs رقمية موجبة)
      const doctorUid = Math.floor(Math.random() * 1000000) + 1;
      const patientUid = Math.floor(Math.random() * 1000000) + 1000001;

      // توليد Tokens (صلاحية ساعة واحدة)
      const doctorToken = generateAgoraToken(channelName, doctorUid, 'publisher', 3600);
      const patientToken = generateAgoraToken(channelName, patientUid, 'publisher', 3600);

      // تحديث بيانات الموعد في Firestore
      await appointmentRef.update({
        agoraChannelName: channelName,
        agoraToken: patientToken, // Token for patient
        agoraUid: patientUid,
        doctorAgoraToken: doctorToken, // Token for doctor
        doctorAgoraUid: doctorUid,
        meetingProvider: 'agora',
        callStartedAt: admin.firestore.FieldValue.serverTimestamp(),
        callStatus: 'ringing', // ✅ رنين - وليس completed
      });

      console.log(`✅ Agora call data saved for appointment ${appointmentId}`);

      // ✅ تسجيل في call_logs collection للتتبع
      try {
        await db.collection('call_logs').add({
          appointmentId: appointmentId,
          callType: 'agora',
          action: 'call_initiated',
          doctorId: doctorId,
          patientId: appointment.patientId,
          channelName: channelName,
          doctorUid: doctorUid,
          patientUid: patientUid,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          success: true,
        });
        console.log(`✅ Call log created for appointment ${appointmentId}`);
      } catch (logError) {
        // لا نفشل العملية بسبب خطأ في التسجيل
        console.warn('⚠️ Failed to create call log:', logError);
      }

      // الحصول على بيانات الطبيب
      const doctorDoc = await db.collection('users').doc(doctorId).get();
      const doctorData = doctorDoc.data();

      // إرسال VoIP notification للمريض
      await sendAgoraVoIPNotification({
        patientId: appointment.patientId,
        doctorName: appointment.doctorName || doctorData?.fullName || 'الطبيب',
        appointmentId: appointmentId,
        agoraChannelName: channelName,
        agoraToken: patientToken,
        agoraUid: patientUid,
      });

      console.log(`✅ Agora call started successfully for appointment ${appointmentId}`);

      return {
        success: true,
        message: 'تم بدء المكالمة بنجاح',
        agoraChannelName: channelName,
        agoraToken: doctorToken, // Return doctor's token
        agoraUid: doctorUid,
      };

    } catch (error) {
      console.error('❌ Error starting Agora call:', error);

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      throw new functions.https.HttpsError(
        'internal',
        'حدث خطأ أثناء بدء المكالمة',
        error.message
      );
    }
  });

/**
 * دالة إرسال VoIP Notification للمريض عبر Agora
 * 
 * ترسل إشعار VoIP عبر FCM لتنبيه المريض بمكالمة واردة
 */
async function sendAgoraVoIPNotification(data) {
  const { patientId, doctorName, appointmentId, agoraChannelName, agoraToken, agoraUid } = data;

  try {
    const db = getDB();

    // جلب FCM token للمريض
    const patientDoc = await db.collection('users').doc(patientId).get();

    if (!patientDoc.exists) {
      console.error('❌ Patient not found:', patientId);
      return;
    }

    const patient = patientDoc.data();
    const fcmToken = patient.fcmToken;

    if (!fcmToken) {
      console.error('❌ No FCM token for patient:', patientId);
      return;
    }

    // إعداد رسالة FCM بصيغة VoIP لـ Agora
    const message = {
      token: fcmToken,
      data: {
        type: 'incoming_call',
        appointmentId: appointmentId,
        doctorName: doctorName,
        patientId: patientId,
        agoraChannelName: agoraChannelName,
        agoraToken: agoraToken,
        agoraUid: String(agoraUid),
        callType: 'agora',
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'incoming_calls',
          priority: 'max',
          sound: 'default',
          tag: appointmentId,
        },
      },
      apns: {
        headers: {
          'apns-priority': '10',
          'apns-push-type': 'alert',
          'apns-expiration': '0',
        },
        payload: {
          aps: {
            'content-available': 1,
            'mutable-content': 1,
            alert: {
              title: '📞 مكالمة فيديو واردة',
              body: `مكالمة من ${doctorName}`,
            },
            sound: 'default',
          },
        },
      },
    };

    // إرسال الإشعار
    await getMessaging().send(message);
    console.log(`✅ Agora VoIP notification sent to patient ${patientId}`);

  } catch (error) {
    console.error('❌ Error sending Agora VoIP notification:', error);
    // لا نرمي خطأ هنا لأن المكالمة نفسها نجحت
  }
}

/**
 * Cloud Function: إنهاء مكالمة Agora
 * 
 * تُستدعى عند إنهاء أي طرف للمكالمة
 */
exports.endAgoraCall = functions.region("europe-west1")
  .runWith({ enforceAppCheck: false })
  .https.onCall(async (data, context) => {
    console.log('📞 endAgoraCall called');

    try {
      if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'يجب تسجيل الدخول');
      }

      const { appointmentId } = data;

      if (!appointmentId) {
        throw new functions.https.HttpsError('invalid-argument', 'appointmentId is required');
      }

      const db = getDB();

      // تحديث حالة الموعد
      await db.collection('appointments').doc(appointmentId).update({
        callEndedAt: admin.firestore.FieldValue.serverTimestamp(),
        callStatus: 'completed',
        status: 'completed', // ✅ فقط هنا نحول status إلى completed
      });

      console.log(`✅ Agora call ended for appointment ${appointmentId}`);

      // ✅ تسجيل في call_logs
      try {
        await db.collection('call_logs').add({
          appointmentId: appointmentId,
          callType: 'agora',
          action: 'call_ended',
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          success: true,
        });
        console.log(`✅ Call end logged for appointment ${appointmentId}`);
      } catch (logError) {
        console.warn('⚠️ Failed to log call end:', logError);
      }

      return {
        success: true,
        message: 'تم إنهاء المكالمة',
      };

    } catch (error) {
      console.error('❌ Error ending Agora call:', error);

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      throw new functions.https.HttpsError('internal', 'حدث خطأ أثناء إنهاء المكالمة');
    }
  });

/**
 * ✅ مساعد للتحقق مما إذا كان المستدعي مسؤولاً (Admin)
 */
async function checkIsAdmin(context) {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'يجب تسجيل الدخول');
  }
  const db = getDB();
  const userDoc = await db.collection('users').doc(context.auth.uid).get();
  if (!userDoc.exists || userDoc.data().userType !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'ليس لديك صلاحية مسؤول (Admin)');
  }
}

// ============================================
// 🩺 Cloud Function: Create Doctor Account
// يتم استدعاؤها من لوحة الإدارة لإنشاء حساب طبيب جديد
// ============================================
exports.createDoctorAccount = functions.region("europe-west1").https.onCall(async (data, context) => {
  console.log('🩺 createDoctorAccount called');
  await checkIsAdmin(context);

  const {
    email,
    password,
    fullName,
    phoneNumber,
    licenseNumber,
    specializations,
    workingHours,
    biography,
    yearsOfExperience,
    consultationFee,
    consultationTypes,
    clinicName,
    clinicAddress
  } = data;

  if (!email || !password || !fullName) {
    throw new functions.https.HttpsError('invalid-argument', 'البريد وكلمة المرور والاسم مطلوبة');
  }

  try {
    // 1. إنشاء حساب في Firebase Auth
    const userRecord = await admin.auth().createUser({
      email,
      password,
      displayName: fullName,
      phoneNumber: phoneNumber || undefined,
    });

    // 2. إنشاء مستند المستخدم في Firestore (قاعدة بيانات elajtech)
    const db = getDB();
    await db.collection('users').doc(userRecord.uid).set({
      id: userRecord.uid,
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber || '',
      userType: 'doctor',
      isActive: true,
      licenseNumber: licenseNumber || '',
      specializations: specializations || [],
      workingHours: workingHours || {},
      biography: biography || '',
      yearsOfExperience: yearsOfExperience || 0,
      consultationFee: consultationFee || 0,
      consultationTypes: consultationTypes || [],
      clinicName: clinicName || '',
      clinicAddress: clinicAddress || '',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      profileImage: '', // يتم تحديثها لاحقاً عند رفع الصورة
    });

    console.log(`✅ Doctor account created: ${userRecord.uid}`);
    return { uid: userRecord.uid };

  } catch (error) {
    console.error('❌ Error creating doctor account:', error);
    if (error.code === 'auth/email-already-exists') {
      throw new functions.https.HttpsError('already-exists', 'هذا البريد الإلكتروني مسجل مسبقاً');
    }
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// ============================================
// 🔐 Cloud Function: Set Account Status
// تفعيل أو تعطيل حساب مستخدم (طبيب أو مريض)
// ============================================
exports.setAccountStatus = functions.region("europe-west1").https.onCall(async (data, context) => {
  console.log('🔐 setAccountStatus called');
  await checkIsAdmin(context);

  const { targetUserId, isActive } = data;

  if (!targetUserId || isActive === undefined) {
    throw new functions.https.HttpsError('invalid-argument', 'targetUserId and isActive are required');
  }

  try {
    const db = getDB();

    // 1. تحديث Firestore
    await db.collection('users').doc(targetUserId).update({
      isActive: isActive,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 2. تحديث Firebase Auth (تعطيل/تفعيل الحساب)
    await admin.auth().updateUser(targetUserId, {
      disabled: !isActive,
    });

    console.log(`✅ Account status updated for user ${targetUserId}: isActive=${isActive}`);
    return { success: true };

  } catch (error) {
    console.error('❌ Error setting account status:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});
