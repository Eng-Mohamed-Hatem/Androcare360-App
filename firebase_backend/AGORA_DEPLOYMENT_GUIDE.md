# 🚀 Cloud Functions Deployment Guide - Agora Integration

## 📋 Pre-Deployment Checklist

### 1️⃣ Install Dependencies
```bash
cd firebase_backend/functions
npm install agora-access-token@^2.0.4
```

### 2️⃣ Configure Firebase Environment Variables
Run these commands to set your Agora credentials:

```bash
firebase functions:config:set agora.app_id="f9ff6f5ab52c43d0ab7ba76fcee25dbf"
firebase functions:config:set agora.app_certificate="YOUR_PRIMARY_CERTIFICATE_HERE"
```

> ⚠️ **مهم جداً**: استبدل `YOUR_PRIMARY_CERTIFICATE_HERE` بالـ Primary Certificate الفعلي من Agora Console

### 3️⃣ Update index.js

Add the Agora import at the top of `index.js` (after line 2):
```javascript
const {RtcTokenBuilder, RtcRole} = require('agora-access-token');
```

Then append the content from `agora_additions.txt` to the end of `index.js` file.

---

## 🔥 Deployment Steps

### Step 1: Deploy Cloud Functions
```bash
cd firebase_backend
firebase deploy --only functions
```

### Step 2: Verify Deployment
Check Firebase Console > Functions to confirm:
- ✅ `startAgoraCall` - deployed successfully
- ✅ `endAgoraCall` - deployed successfully

### Step 3: Test Token Generation
```bash
# في Firebase Console > Functions > Logs
# ابحث عن: "✅ Agora token generated"
```

---

## 🧪 Testing the System

### Test 1: Doctor Initiates Call
1. الطبيب يضغط على "بدء الاتصال" في `DoctorAppointmentsScreen`
2. يتم استدعاء `startAgoraCall` Cloud Function
3. يتم توليد Tokens للطبيب والمريض
4. يتم تحديث Firestore بـ `agoraChannelName`, `agoraToken`, `agoraUid`
5. يتم إرسال VoIP notification للمريض

**Expected Logs:**
```
📞 startAgoraCall called
✅ Agora token generated for channel: appointment_XXX_YYY, uid: 123456
✅ Agora call data saved for appointment ABC123
✅ Agora VoIP notification sent to patient XYZ
✅ Agora call started successfully for appointment ABC123
```

### Test 2: Patient Receives Call
1. المريض يستلم notification
2. يظهر incoming call screen
3. يضغط على "Accept"
4. يتم فتح `AgoraVideoCallScreen` مع البيانات الصحيحة

### Test 3: End Call
1. أي طرف يضغط "End Call"
2. يتم استدعاء `endAgoraCall`
3. يتم تحديث status إلى `completed`

---

## ⚙️ Environment Configuration Details

### Agora App ID
```
f9ff6f5ab52c43d0ab7ba76fcee25dbf
```

### Primary Certificate
```
احصل عليه من: Agora Console > Project > Config > Primary Certificate
```

### Firebase Region
```
europe-west1
```

---

## 🔍 Troubleshooting

### Error: "Agora credentials not configured"
**الحل:**
```bash
firebase functions:config:get
# تحقق من وجود agora.app_id و agora.app_certificate
```

### Error: "Cannot find module 'agora-access-token'"
**الحل:**
```bash
cd firebase_backend/functions
npm install
```

### Error: "Failed to generate token"
**الأسباب المحتملة:**
1. App Certificate خطأ
2. Channel name غير صالح
3. UID = 0 (يجب أن يكون > 0)

---

## 📊 Monitoring

### Cloud Functions Logs
```bash
firebase functions:log --only startAgoraCall
firebase functions:log --only endAgoraCall
```

### Expected Success Flow
```
1. Doctor → startAgoraCall → 200 OK + tokens
2. Firestore → appointment updated with Agora data
3. Patient → FCM notification received
4. Patient → joins call with token
5. Call ends → endAgoraCall → status=completed
```

---

## ✅ Completion Checklist

- [ ] npm install agora-access-token completed
- [ ] Firebase config variables set (app_id + app_certificate)
- [ ] index.js updated with Agora import
- [ ] agora_additions.txt content appended to index.js
- [ ] firebase deploy --only functions successful
- [ ] Functions visible in Firebase Console
- [ ] Test call initiated by doctor
- [ ] Patient receives VoIP notification
- [ ] Video call connects successfully
- [ ] Call ends and status updates

---

## 🎯 Next Steps After Deployment

1. **اختبار أول مكالمة حقيقية**
   - قم بإنشاء موعد تجريبي
   - سجل دخول كطبيب في جهاز
   - سجل دخول كمريض في جهاز آخر
   - ابدأ المكالمة وتحقق من الرنين

2. **مراقبة Logs**
   - افتح Firebase Console > Functions > Logs
   - راقب كل خطوة من خطوات المكالمة

3. **تقرير النتائج**
   - إذا نجحت: أبلغني بنجاح أول مكالمة! 🎉
   - إذا فشلت: أرسل logs الأخطاء لتحليلها

---

**Created:** 2026-02-04  
**Version:** 1.0.0  
**Status:** Ready for Deployment ✅
