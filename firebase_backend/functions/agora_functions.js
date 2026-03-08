// ============================================
// 🎥 AGORA VIDEO CALL FUNCTIONS
// ============================================

const { RtcTokenBuilder, RtcRole } = require('agora-access-token');

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
    // استخدام المتغيرات البيئية من Firebase Config
    const appId = functions.config().agora?.app_id;
    const appCertificate = functions.config().agora?.app_certificate;

    if (!appId || !appCertificate) {
        console.error('❌ Agora credentials not configured!');
        console.error('Run: firebase functions:config:set agora.app_id="YOUR_APP_ID" agora.app_certificate="YOUR_CERTIFICATE"');
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
                callStatus: 'ringing',
            });

            console.log(`✅ Agora call data saved for appointment ${appointmentId}`);

            // إرسال VoIP notification للمريض
            await sendAgoraVoIPNotification({
                patientId: appointment.patientId,
                doctorName: appointment.doctorName,
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
                status: 'completed',
            });

            console.log(`✅ Agora call ended for appointment ${appointmentId}`);

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
