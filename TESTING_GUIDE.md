# 🧪 دليل الاختبار الشامل - Agora Video Calls

## 📋 قبل البدء

### المتطلبات
- ✅ Flutter app قيد التشغيل (`flutter run`)
- ✅ Cloud Functions منشورة على Firebase
- ✅ جهازين منفصلين (أو محاكيين)
- ✅ حسابين نشطين:
  - حساب طبيب
  - حساب مريض

### فتح Firebase Console
```
افتح: https://console.firebase.google.com
انتقل إلى: Functions > Logs
```

---

## 🎯 الاختبار 1: إنشاء موعد فيديو

### الخطوات:
1. **سجل دخول كطبيب**
2. **انتقل إلى إدارة المواعيد**
3. **أنشئ موعد جديد**:
   - نوع الموعد: استشارة فيديو
   - اختر مريض
   - حدد التاريخ والوقت

### النتيجة المتوقعة:
✅ تم إنشاء الموعد بنجاح  
✅ الموعد ظاهر في قائمة المواعيد  
✅ حالة الموعد: `scheduled` أو `confirmed`

---

## 🎯 الاختبار 2: بدء المكالمة (Doctor Side)

### الخطوات:
1. **انتقل إلى شاشة المواعيد** (DoctorAppointmentsScreen)
2. **ابحث عن الموعد المُنشأ**
3. **اضغط على "بدء الاتصال"**

### ما يجب أن يحدث:
```
1. يتم استدعاء startAgoraCall Cloud Function
2. Firebase Logs تظهر: "📞 startAgoraCall called"
3. Token generation: "✅ Agora token generated"
4. Firestore update: "✅ Agora call data saved"
5. VoIP notification sent: "✅ Agora VoIP notification sent"
6. الطبيب ينتقل إلى AgoraVideoCallScreen
```

### Firebase Logs المتوقعة:
```
📞 startAgoraCall called
✅ Agora token generated for channel: appointment_XXX_123456, uid: 789012
✅ Agora call data saved for appointment ABC123
✅ Agora VoIP notification sent to patient XYZ
✅ Agora call started successfully for appointment ABC123
```

### التحقق من Firestore:
افتح Firestore Console وتحقق من:
```javascript
appointments/{appointmentId}
- agoraChannelName: "appointment_XXX_123456" ✅
- agoraToken: "006..." (طويل) ✅
- agoraUid: 1234567 ✅
- doctorAgoraToken: "006..." ✅
- doctorAgoraUid: 7890123 ✅
- callStatus: "ringing" ✅
- meetingProvider: "agora" ✅
```

---

## 🎯 الاختبار 3: استقبال المكالمة (Patient Side)

### ما يجب أن يحدث تلقائياً:

#### على جهاز المريض:
1. **يظهر إشعار VoIP**:
   - العنوان: "📞 مكالمة فيديو واردة"
   - الرسالة: "مكالمة من Dr. [اسم الطبيب]"
   - زر Accept/Decline

2. **الضغط على Accept**:
   - التطبيق يفتح (إذا كان مغلق)
   - ينتقل إلى AgoraVideoCallScreen
   - يبدأ الانضمام للقناة

### إذا لم يظهر الإشعار:

**تحقق من:**
```
1. FCM Token موجود للمريض في Firestore
2. التطبيق لديه permission للإشعارات
3. Firebase Console > Logs:
   - "❌ No FCM token for patient" → مشكلة
   - "✅ VoIP notification sent" → صحيح
```

---

## 🎯 الاختبار 4: شاشة الفيديو

### على جهاز الطبيب:
```
✅ يجب أن ترى:
- شاشة AgoraVideoCallScreen
- Loading indicator (جاري الاتصال...)
- أزرار التحكم في الأسفل:
  - 🎤 Microphone toggle
  - 📹 Camera toggle
  - 🔄 Switch camera
  - 🔊 Speaker toggle
  - 📞 End call (أحمر)
```

### على جهاز المريض:
```
✅ يجب أن ترى:
- شاشة AgoraVideoCallScreen
- Loading indicator (جاري الاتصال...)
- نفس أزرار التحكم
```

---

## 🎯 الاختبار 5: الاتصال الفعلي

### اختبار الفيديو:
1. **على جهاز الطبيب**: يجب أن ترى فيديو المريض
2. **على جهاز المريض**: يجب أن ترى فيديو الطبيب

### إذا لم يظهر الفيديو:
```bash
# تحقق من:
1. Camera permission granted
2. Agora SDK initialized
3. Channel joined successfully
4. Firebase Logs: ابحث عن errors
```

### اختبار الصوت:
1. **الطبيب يتحدث** → المريض يسمع
2. **المريض يتحدث** → الطبيب يسمع

### إذا لم يعمل الصوت:
```bash
# تحقق من:
1. Microphone permission granted
2. Speaker enabled
3. Audio routing صحيح
```

---

## 🎯 الاختبار 6: الكنترولات

### اختبر كل زر:

#### 1. Microphone Toggle 🎤
- اضغط لإيقاف المايك → الطرف الآخر لا يسمع
- اضغط مرة أخرى لتشغيل → الطرف الآخر يسمع

#### 2. Camera Toggle 📹
- اضغط لإيقاف الكاميرا → الفيديو يختفي
- اضغط مرة أخرى لتشغيل → الفيديو يظهر

#### 3. Switch Camera 🔄
- اضغط → الكاميرا تتبدل (أمامية ↔ خلفية)

#### 4. Speaker Toggle 🔊
- اضغط → يتغير وضع السماعة (earpiece ↔ loudspeaker)

---

## 🎯 الاختبار 7: إنهاء المكالمة

### الخطوات:
1. **أحد الطرفين يضغط "End Call"** (الزر الأحمر)

### ما يجب أن يحدث:
```
1. يتم استدعاء endAgoraCall Cloud Function
2. Firebase Logs: "📞 endAgoraCall called"
3. Appointment status updated: "✅ Agora call ended for appointment ABC123"
4. كلا الطرفين يخرجان من الشاشة
5. الانتقال لشاشة سابقة
```

### Firebase Logs المتوقعة:
```
📞 endAgoraCall called
✅ Agora call ended for appointment ABC123
```

### التحقق من Firestore:
```javascript
appointments/{appointmentId}
- callStatus: "completed" ✅
- status: "completed" ✅
- callEndedAt: Timestamp ✅
```

---

## 🎯 الاختبار 8: مراجعة شاملة

### Firestore Final State:
```javascript
appointments/{appointmentId} {
  agoraChannelName: "appointment_XXX_123456",
  agoraToken: "006...",
  agoraUid: 1234567,
  doctorAgoraToken: "006...",
  doctorAgoraUid: 7890123,
  callStatus: "completed",
  status: "completed",
  meetingProvider: "agora",
  callStartedAt: Timestamp,
  callEndedAt: Timestamp
}
```

### Firebase Functions Logs:
```
✅ All logs show success
❌ No errors found
```

---

## ✅ Checklist النهائي

- [ ] الموعد تم إنشاؤه بنجاح
- [ ] startAgoraCall نجح (راجع Logs)
- [ ] Token تم توليده (راجع Logs)
- [ ] المريض استلم notification
- [ ] شاشة الفيديو فتحت للطرفين
- [ ] الفيديو يعمل (الطبيب يرى المريض والعكس)
- [ ] الصوت يعمل (ثنائي الاتجاه)
- [ ] جميع الكنترولات تعمل:
  - [ ] Microphone toggle
  - [ ] Camera toggle
  - [ ] Switch camera
  - [ ] Speaker toggle
- [ ] End call يعمل بنجاح
- [ ] endAgoraCall تم استدعاؤها (راجع Logs)
- [ ] Appointment status → completed

---

## 🐛 استكشاف الأخطاء

### المشكلة: "No VoIP notification received"
```bash
# الحلول:
1. تحقق من FCM token في Firestore
2. تأكد من notification permissions
3. راجع Firebase Logs: "✅ VoIP notification sent"
```

### المشكلة: "No video/audio"
```bash
# الحلول:
1. تحقق من Camera/Mic permissions
2. تأكد من Agora SDK initialized
3. راجع channel join logs
```

### المشكلة: "Token invalid"
```bash
# الحلول:
1. تحقق من .env file
2. تأكد من AGORA_APP_ID و AGORA_APP_CERTIFICATE صحيحين
3. راجع Firebase Logs: "❌ Agora credentials not configured"
```

---

## 📊 تقرير النتائج

بعد اكتمال جميع الاختبارات، أرسل لي:

```
✅ نجح / ❌ فشل
- الاختبار 1 (إنشاء موعد):
- الاختبار 2 (بدء مكالمة):
- الاختبار 3 (استقبال notification):
- الاختبار 4 (شاشة الفيديو):
- الاختبار 5 (فيديو/صوت):
- الاختبار 6 (الكنترولات):
- الاختبار 7 (إنهاء المكالمة):
- الاختبار 8 (Firestore update):

Firebase Logs: (انسخ أي errors إن وُجدت)
```

---

**جاهز للاختبار؟ ابدأ الآن! 🚀**
