// Extracted Code Examples from Documentation
// This file is auto-generated for syntax verification
// DO NOT EDIT MANUALLY

// ignore_for_file: unused_import, unused_local_variable, dead_code
// ignore_for_file: unnecessary_import, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_functions/firebase_functions.dart';

// Placeholder types for examples
class AppointmentModel {}
class UserModel {}
class NutritionEMREntity {}
class PhysiotherapyEMR {}
class AgoraService {}
class VoIPCallService {}
class CallMonitoringService {}
class DeviceInfoService {}
class EncryptionService {}
class NotificationService {}
class VideoConsultationService {}
class FCMService {}
class TokenRefreshService {}
class BackgroundService {}

// Placeholder for getIt
class GetIt {
  T call<T>() => throw UnimplementedError();
}
final getIt = GetIt();

void main() {
  // This file is for syntax verification only
  print('Code examples extracted successfully');
}

// ============================================================================
// EXTRACTED CODE EXAMPLES
// ============================================================================


// ============================================================================
// Example from: agora_service.dart (Dart Source)
// ============================================================================

void example_1() {
  // Example code:
/// // Production usage (uses default instances)
/// final service = AgoraService();
///
/// // Test usage (inject mocks)
/// final service = AgoraService(
///   callMonitoringService: mockCallMonitoring,
/// );
///
}


// ============================================================================
// Example from: agora_service.dart (Dart Source)
// ============================================================================

void example_2() {
  // Example code:
/// await agoraService.initialize('your_agora_app_id');
  ///
}


// ============================================================================
// Example from: agora_service.dart (Dart Source)
// ============================================================================

void example_3() {
  // Example code:
/// await agoraService.joinChannel(
  ///   token: 'generated_token',
  ///   channelName: 'appointment_123',
  ///   uid: 0,
  ///   appointmentId: 'appt_123',
  ///   userId: 'user_456',
  /// );
  ///
}


// ============================================================================
// Example from: agora_service.dart (Dart Source)
// ============================================================================

void example_4() {
  // Example code:
/// await agoraService.leaveChannel();
  ///
}


// ============================================================================
// Example from: agora_service.dart (Dart Source)
// ============================================================================

void example_5() {
  // Example code:
/// await agoraService.toggleMicrophone();
  /// print('Microphone muted: ${agoraService.isLocalAudioMuted}');
  ///
}


// ============================================================================
// Example from: agora_service.dart (Dart Source)
// ============================================================================

void example_6() {
  // Example code:
/// await agoraService.toggleCamera();
  /// print('Camera muted: ${agoraService.isLocalVideoMuted}');
  ///
}


// ============================================================================
// Example from: agora_service.dart (Dart Source)
// ============================================================================

void example_7() {
  // Example code:
/// await agoraService.switchCamera();
  ///
}


// ============================================================================
// Example from: agora_service.dart (Dart Source)
// ============================================================================

void example_8() {
  // Example code:
/// await agoraService.setEnableSpeakerphone(enabled: true);
  ///
}


// ============================================================================
// Example from: agora_service.dart (Dart Source)
// ============================================================================

void example_9() {
  // Example code:
/// await agoraService.dispose();
  ///
}


// ============================================================================
// Example from: voip_call_service.dart (Dart Source)
// ============================================================================

void example_10() {
  // Example code:
/// // Initialize service at app startup
/// await VoIPCallService().initialize();
///
/// // Show incoming call
/// await VoIPCallService().showIncomingCall(
///   callerName: 'Dr. Ahmed',
///   callerAvatar: 'https://...',
///   appointmentId: 'appt_123',
///   agoraToken: 'token',
///   agoraChannelName: 'channel_123',
/// );
///
/// // Listen to call events
/// VoIPCallService().callEventStream.listen((event) {
///   if (event.type == VoIPCallEventType.accepted) {
///     // Navigate to video call screen
///   }
/// });
///
}


// ============================================================================
// Example from: voip_call_service.dart (Dart Source)
// ============================================================================

void example_11() {
  // Example code:
/// await VoIPCallService().initialize();
  ///
}


// ============================================================================
// Example from: voip_call_service.dart (Dart Source)
// ============================================================================

void example_12() {
  // Example code:
/// await VoIPCallService().showIncomingCall(
  ///   callerName: 'Dr. Ahmed',
  ///   callerAvatar: 'https://example.com/avatar.jpg',
  ///   appointmentId: 'appt_123',
  ///   agoraToken: 'generated_token',
  ///   agoraChannelName: 'appointment_123',
  ///   agoraUid: 12345,
  /// );
  ///
}


// ============================================================================
// Example from: voip_call_service.dart (Dart Source)
// ============================================================================

void example_13() {
  // Example code:
/// final appointmentId = await VoIPCallService().cleanupAfterCall();
  /// if (appointmentId != null) {
  ///   // Navigate to appointment details
  /// }
  ///
}


// ============================================================================
// Example from: voip_call_service.dart (Dart Source)
// ============================================================================

void example_14() {
  // Example code:
/// await VoIPCallService().endCall();
  ///
}


// ============================================================================
// Example from: voip_call_service.dart (Dart Source)
// ============================================================================

void example_15() {
  // Example code:
/// await VoIPCallService().endAllCalls();
  ///
}


// ============================================================================
// Example from: call_monitoring_service.dart (Dart Source)
// ============================================================================

void example_16() {
  // Example code:
/// // Production usage (uses default instances)
/// final service = CallMonitoringService();
///
/// // Test usage (inject mocks)
/// final service = CallMonitoringService(
///   firestore: mockFirestore,
///   deviceInfoService: mockDeviceInfo,
/// );
///
/// // Log call attempt
/// await service.logCallAttempt(
///   appointmentId: 'appt_123',
///   userId: 'user_456',
/// );
///
/// // Log call error
/// await service.logCallError(
///   appointmentId: 'appt_123',
///   userId: 'user_456',
///   errorType: 'token_generation_failed',
///   errorMessage: 'Invalid Agora token',
/// );
///
}


// ============================================================================
// Example from: call_monitoring_service.dart (Dart Source)
// ============================================================================

void example_17() {
  // Example code:
/// await callMonitoring.logCallAttempt(
  ///   appointmentId: 'appt_123',
  ///   userId: 'user_456',
  /// );
  ///
}


// ============================================================================
// Example from: call_monitoring_service.dart (Dart Source)
// ============================================================================

void example_18() {
  // Example code:
/// await callMonitoring.logCallSuccess(
  ///   appointmentId: 'appt_123',
  ///   userId: 'user_456',
  ///   channelName: 'appointment_123',
  ///   metadata: {'uid': 12345},
  /// );
  ///
}


// ============================================================================
// Example from: call_monitoring_service.dart (Dart Source)
// ============================================================================

void example_19() {
  // Example code:
/// await callMonitoring.logCallError(
  ///   appointmentId: 'appt_123',
  ///   userId: 'user_456',
  ///   errorType: 'agora_join_failed',
  ///   errorMessage: 'Invalid token',
  ///   stackTrace: stackTrace.toString(),
  /// );
  ///
}


// ============================================================================
// Example from: call_monitoring_service.dart (Dart Source)
// ============================================================================

void example_20() {
  // Example code:
/// await callMonitoring.logConnectionFailure(
  ///   appointmentId: 'appt_123',
  ///   userId: 'user_456',
  ///   reason: 'Connection state: failed',
  ///   metadata: {'connectionState': 'FAILED'},
  /// );
  ///
}


// ============================================================================
// Example from: call_monitoring_service.dart (Dart Source)
// ============================================================================

void example_21() {
  // Example code:
/// await callMonitoring.logMediaDeviceError(
  ///   appointmentId: 'appt_123',
  ///   userId: 'user_456',
  ///   deviceType: 'camera',
  ///   errorMessage: 'Camera failed: permission denied',
  /// );
  ///
}


// ============================================================================
// Example from: call_monitoring_service.dart (Dart Source)
// ============================================================================

void example_22() {
  // Example code:
/// await callMonitoring.logCallEnded(
  ///   appointmentId: 'appt_123',
  ///   userId: 'user_456',
  ///   duration: 1800, // 30 minutes
  /// );
  ///
}


// ============================================================================
// Example from: call_monitoring_service.dart (Dart Source)
// ============================================================================

void example_23() {
  // Example code:
/// final logs = await callMonitoring.getLogsForAppointment('appt_123');
  /// for (final log in logs) {
  ///   print('${log.eventType}: ${log.timestamp}');
  /// }
  ///
}


// ============================================================================
// Example from: call_monitoring_service.dart (Dart Source)
// ============================================================================

void example_24() {
  // Example code:
/// final logs = await callMonitoring.getLogsForUser('user_456', limit: 100);
  ///
}


// ============================================================================
// Example from: call_monitoring_service.dart (Dart Source)
// ============================================================================

void example_25() {
  // Example code:
/// final errorLogs = await callMonitoring.getErrorLogs(limit: 50);
  /// for (final log in errorLogs) {
  ///   print('Error: ${log.errorCode} - ${log.errorMessage}');
  /// }
  ///
}


// ============================================================================
// Example from: device_info_service.dart (Dart Source)
// ============================================================================

void example_26() {
  // Example code:
/// // Get complete device information
/// final deviceInfo = await DeviceInfoService().getDeviceInfo();
/// print('Device: ${deviceInfo.deviceModel}');
/// print('OS: ${deviceInfo.osVersion}');
/// print('App Version: ${deviceInfo.appVersion}');
///
/// // Get specific information
/// final model = await DeviceInfoService().getDeviceModel();
/// final connection = await DeviceInfoService().getConnectionType();
///
}


// ============================================================================
// Example from: device_info_service.dart (Dart Source)
// ============================================================================

void example_27() {
  // Example code:
/// final info = await DeviceInfoService().getDeviceInfo();
  /// print('Running on ${info.deviceModel} with ${info.osVersion}');
  /// print('Connection: ${info.connectionType}');
  ///
}


// ============================================================================
// Example from: device_info_service.dart (Dart Source)
// ============================================================================

void example_28() {
  // Example code:
/// final model = await DeviceInfoService().getDeviceModel();
  ///
}


// ============================================================================
// Example from: device_info_service.dart (Dart Source)
// ============================================================================

void example_29() {
  // Example code:
/// final osVersion = await DeviceInfoService().getOSVersion();
  ///
}


// ============================================================================
// Example from: device_info_service.dart (Dart Source)
// ============================================================================

void example_30() {
  // Example code:
/// final version = await DeviceInfoService().getAppVersion();
  ///
}


// ============================================================================
// Example from: device_info_service.dart (Dart Source)
// ============================================================================

void example_31() {
  // Example code:
/// final connection = await DeviceInfoService().getConnectionType();
  /// if (connection == 'none') {
  ///   print('No internet connection');
  /// }
  ///
}


// ============================================================================
// Example from: device_info_service.dart (Dart Source)
// ============================================================================

void example_32() {
  // Example code:
/// DeviceInfoService().clearCache();
  /// final freshInfo = await DeviceInfoService().getDeviceInfo();
  ///
}


// ============================================================================
// Example from: encryption_service.dart (Dart Source)
// ============================================================================

void example_33() {
  // Example code:
/// // In main.dart
/// await EncryptionService.instance.initialize();
///
/// // Encrypt sensitive message
/// final encrypted = EncryptionService.instance.encrypt('Patient diagnosis: ...');
/// await firestore.collection('messages').add({'content': encrypted});
///
/// // Decrypt received message
/// final decrypted = EncryptionService.instance.decrypt(encryptedMessage);
/// print('Message: $decrypted');
///
}


// ============================================================================
// Example from: encryption_service.dart (Dart Source)
// ============================================================================

void example_34() {
  // Example code:
/// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await EncryptionService.instance.initialize();
  ///   runApp(MyApp());
  /// }
  ///
}


// ============================================================================
// Example from: encryption_service.dart (Dart Source)
// ============================================================================

void example_35() {
  // Example code:
/// final service = EncryptionService.instance;
  /// final encrypted = service.encrypt('Patient has diabetes type 2');
  /// // Store encrypted in Firestore
  /// await firestore.collection('messages').add({
  ///   'content': encrypted,
  ///   'timestamp': FieldValue.serverTimestamp(),
  /// });
  ///
}


// ============================================================================
// Example from: encryption_service.dart (Dart Source)
// ============================================================================

void example_36() {
  // Example code:
/// final service = EncryptionService.instance;
  /// // Retrieve encrypted message from Firestore
  /// final doc = await firestore.collection('messages').doc(messageId).get();
  /// final encryptedContent = doc.data()?['content'] as String;
  ///
  /// // Decrypt the message
  /// final decrypted = service.decrypt(encryptedContent);
  /// print('Decrypted message: $decrypted');
  ///
}


// ============================================================================
// Example from: encryption_service.dart (Dart Source)
// ============================================================================

void example_37() {
  // Example code:
/// // In test file
  /// test('should generate new key on first initialization', () async {
  ///   await EncryptionService.instance.reset();
  ///   await EncryptionService.instance.initialize();
  ///   expect(EncryptionService.instance.isInitialized, true);
  /// });
  ///
}


// ============================================================================
// Example from: notification_service.dart (Dart Source)
// ============================================================================

void example_38() {
  // Example code:
/// // Initialize service at app startup
/// await NotificationService().init();
///
/// // Show immediate notification
/// await NotificationService().showNotification(
///   id: 1,
///   title: 'Appointment Reminder',
///   body: 'Your appointment is in 30 minutes',
/// );
///
/// // Schedule notification
/// await NotificationService().scheduleNotification(
///   id: 2,
///   title: 'Upcoming Appointment',
///   body: 'Appointment with Dr. Ahmed tomorrow',
///   scheduledDate: DateTime.now().add(Duration(hours: 24)),
/// );
///
}


// ============================================================================
// Example from: notification_service.dart (Dart Source)
// ============================================================================

void example_39() {
  // Example code:
/// await NotificationService().init();
  ///
}


// ============================================================================
// Example from: notification_service.dart (Dart Source)
// ============================================================================

void example_40() {
  // Example code:
/// await NotificationService().showNotification(
  ///   id: 1,
  ///   title: 'New Message',
  ///   body: 'You have a new message from Dr. Ahmed',
  /// );
  ///
}


// ============================================================================
// Example from: notification_service.dart (Dart Source)
// ============================================================================

void example_41() {
  // Example code:
/// await NotificationService().scheduleNotification(
  ///   id: 2,
  ///   title: 'Appointment Reminder',
  ///   body: 'Your appointment is in 1 hour',
  ///   scheduledDate: DateTime.now().add(Duration(hours: 1)),
  /// );
  ///
}


// ============================================================================
// Example from: notification_service.dart (Dart Source)
// ============================================================================

void example_42() {
  // Example code:
/// await NotificationService().cancelNotification(1);
  ///
}


// ============================================================================
// Example from: notification_service.dart (Dart Source)
// ============================================================================

void example_43() {
  // Example code:
/// await NotificationService().cancelAll();
  ///
}


// ============================================================================
// Example from: video_consultation_service.dart (Dart Source)
// ============================================================================

void example_44() {
  // Example code:
/// class VideoConsultationService {
///   factory VideoConsultationService() => _instance;
///   VideoConsultationService._internal();
///   static final VideoConsultationService _instance = VideoConsultationService._internal();
/// }
///
}


// ============================================================================
// Example from: video_consultation_service.dart (Dart Source)
// ============================================================================

void example_45() {
  // Example code:
/// final service = VideoConsultationService();
///
/// // Start a video consultation
/// final result = await service.startVideoCall(
///   appointmentId: 'apt_123',
///   doctorId: 'doc_456',
/// );
///
/// if (result.success) {
///   // Join Agora channel with returned credentials
///   await agoraEngine.joinChannel(
///     token: result.agoraToken!,
///     channelId: result.agoraChannelName!,
///     uid: result.agoraUid!,
///   );
/// } else {
///   print('Error: ${result.error}');
/// }
///
}


// ============================================================================
// Example from: video_consultation_service.dart (Dart Source)
// ============================================================================

void example_46() {
  // Example code:
/// try {
  ///   final result = await videoConsultationService.startVideoCall(
  ///     appointmentId: 'apt_20240212_001',
  ///     doctorId: 'doc_123',
  ///   );
  ///
  ///   if (result.success) {
  ///     print('Channel: ${result.agoraChannelName}');
  ///     print('Token: ${result.agoraToken}');
  ///     // Proceed to join Agora channel
  ///   } else {
  ///     showError(result.error ?? 'Failed to start call');
  ///   }
  /// } catch (e) {
  ///   print('Unexpected error: $e');
  /// }
  ///
}


// ============================================================================
// Example from: video_consultation_service.dart (Dart Source)
// ============================================================================

void example_47() {
  // Example code:
/// StartCallResult(
///   success: true,
///   agoraChannelName: 'channel_apt_123',
///   agoraToken: 'eyJhbGc...',
///   agoraUid: 12345,
///   message: 'ØªÙ… Ø¨Ø¯Ø¡ Ø§Ù„Ø§ØªØµØ§Ù„ Ø¨Ù†Ø¬Ø§Ø­',
/// )
///
}


// ============================================================================
// Example from: video_consultation_service.dart (Dart Source)
// ============================================================================

void example_48() {
  // Example code:
/// StartCallResult(
///   success: false,
///   error: 'Ø­Ø¯Ø« Ø®Ø·Ø£ Ø£Ø«Ù†Ø§Ø¡ Ø¨Ø¯Ø¡ Ø§Ù„Ù…ÙƒØ§Ù„Ù…Ø©',
/// )
///
}


// ============================================================================
// Example from: fcm_service.dart (Dart Source)
// ============================================================================

void example_49() {
  // Example code:
/// {
///   'type': 'incoming_call',
///   'callerName': 'Dr. Ahmed',
///   'callerAvatar': 'https://...',
///   'appointmentId': 'appt123',
///   'agoraToken': 'token...',
///   'agoraChannelName': 'channel123',
///   'agoraUid': '12345'
/// }
///
}


// ============================================================================
// Example from: fcm_service.dart (Dart Source)
// ============================================================================

void example_50() {
  // Example code:
/// // In main.dart
/// await FCMService().init();
///
/// // Get FCM token for user registration
/// final token = await FCMService().getToken();
/// await userRepo.updateFCMToken(userId, token);
///
/// // Subscribe to topic
/// await FCMService().subscribeToTopic('doctors');
///
/// // Listen to incoming calls
/// FCMService().incomingCallStream.listen((callData) {
///   print('Incoming call from: ${callData.callerName}');
/// });
///
}


// ============================================================================
// Example from: token_refresh_service.dart (Dart Source)
// ============================================================================

void example_51() {
  // Example code:
/// // Injection setup (handled by injectable)
/// @lazySingleton
/// class TokenRefreshService {
///   TokenRefreshService(this._firebaseAuth);
///   final FirebaseAuth _firebaseAuth;
/// }
///
}


// ============================================================================
// Example from: token_refresh_service.dart (Dart Source)
// ============================================================================

void example_52() {
  // Example code:
/// // Inject the service
/// final tokenRefreshService = getIt<TokenRefreshService>();
///
/// // Before saving EMR record
/// final refreshed = await tokenRefreshService.forceRefreshToken();
/// if (refreshed) {
///   // Token is fresh, proceed with save
///   await emrRepository.saveRecord(record);
/// } else {
///   // Token refresh failed, handle error
///   return Left(AuthFailure('Failed to refresh authentication'));
/// }
///
/// // Get fresh token for API calls
/// final token = await tokenRefreshService.getFreshToken();
/// if (token != null) {
///   // Use token in API request
///   final response = await apiClient.post('/save', token: token);
/// }
///
/// // Validate token before operation
/// final isValid = await tokenRefreshService.validateAndRefreshTokenIfNeeded();
/// if (isValid) {
///   // Proceed with operation
/// }
///
}


// ============================================================================
// Example from: background_service.dart (Dart Source)
// ============================================================================

void example_53() {
  // Example code:
/// FirebaseFirestore.instanceFor(
///   app: Firebase.app(),
///   databaseId: 'elajtech',
/// )
///
}


// ============================================================================
// Example from: background_service.dart (Dart Source)
// ============================================================================

void example_54() {
  // Example code:
/// // WorkManager calls this function automatically
/// // Task: 'checkNotifications'
/// // 1. Initialize Firebase
/// // 2. Get user ID from SharedPreferences
/// // 3. Fetch notifications from Firestore
/// // 4. Display unread notifications from last 15 minutes
/// // 5. Return true
///
}


// ============================================================================
// Example from: background_service.dart (Dart Source)
// ============================================================================

void example_55() {
  // Example code:
/// await BackgroundService.init();
/// await BackgroundService.registerPeriodicTask();
///
}


// ============================================================================
// Example from: background_service.dart (Dart Source)
// ============================================================================

void example_56() {
  // Example code:
/// // In main.dart (mobile only)
/// if (!kIsWeb) {
///   await BackgroundService.init();
/// }
///
/// // In auth_provider.dart after login
/// if (!kIsWeb) {
///   await BackgroundService.registerPeriodicTask();
/// }
///
}


// ============================================================================
// Example from: background_service.dart (Dart Source)
// ============================================================================

void example_57() {
  // Example code:
/// FirebaseFirestore.instanceFor(
///   app: Firebase.app(),
///   databaseId: 'elajtech',
/// )
///
}


// ============================================================================
// Example from: background_service.dart (Dart Source)
// ============================================================================

void example_58() {
  // Example code:
/// // In main.dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///
  ///   if (!kIsWeb) {
  ///     await BackgroundService.init();
  ///   }
  ///
  ///   runApp(MyApp());
  /// }
  ///
}


// ============================================================================
// Example from: background_service.dart (Dart Source)
// ============================================================================

void example_59() {
  // Example code:
/// // In auth_provider.dart after login
  /// Future<void> login(String email, String password) async {
  ///   // ... login logic ...
  ///
  ///   if (!kIsWeb) {
  ///     await BackgroundService.registerPeriodicTask();
  ///   }
  /// }
  ///
}


// ============================================================================
// Example from: background_service.dart (Dart Source)
// ============================================================================

void example_60() {
  // Example code:
/// await Workmanager().cancelByUniqueName('periodic-notification-check');
  ///
}


// ============================================================================
// Example from: appointment_model.dart (Dart Source)
// ============================================================================

void example_61() {
  // Example code:
/// final appointment = AppointmentModel(
///   id: 'apt_123',
///   patientId: 'patient_456',
///   patientName: 'Ahmed Ali',
///   patientPhone: '+966500000001',
///   doctorId: 'doctor_789',
///   doctorName: 'Dr. Sarah Ahmed',
///   specialization: 'Nutrition',
///   appointmentDate: DateTime(2024, 3, 15),
///   timeSlot: '10:00 Øµ',
///   type: AppointmentType.video,
///   status: AppointmentStatus.confirmed,
///   fee: 150.0,
///   createdAt: DateTime.now(),
///   agoraChannelName: 'appointment_123',
///   meetingProvider: 'agora',
/// );
///
}


// ============================================================================
// Example from: user_model.dart (Dart Source)
// ============================================================================

void example_62() {
  // Example code:
/// final specialty = user.specializations?.isNotEmpty == true
///     ? user.specializations!.first
///     : 'General';
///
}


// ============================================================================
// Example from: user_model.dart (Dart Source)
// ============================================================================

void example_63() {
  // Example code:
/// // Creating a doctor user
/// final doctor = UserModel(
///   id: 'doctor_123',
///   email: 'doctor@example.com',
///   fullName: 'Dr. Sarah Ahmed',
///   userType: UserType.doctor,
///   phoneNumber: '+966500000001',
///   licenseNumber: 'MED-12345',
///   specializations: ['Nutrition', 'Dietetics'],
///   consultationFee: 150.0,
///   consultationTypes: ['video', 'clinic'],
///   createdAt: DateTime.now(),
/// );
///
/// // Creating a patient user
/// final patient = UserModel(
///   id: 'patient_456',
///   email: 'patient@example.com',
///   fullName: 'Ahmed Ali',
///   userType: UserType.patient,
///   phoneNumber: '+966500000002',
///   createdAt: DateTime.now(),
/// );
///
}


// ============================================================================
// Example from: user_model.dart (Dart Source)
// ============================================================================

void example_64() {
  // Example code:
/// final specialty = user.specializations?.isNotEmpty == true
  ///     ? user.specializations!.first
  ///     : 'General';
  ///
}


// ============================================================================
// Example from: user_model.dart (Dart Source)
// ============================================================================

void example_65() {
  // Example code:
/// {
  ///   'Sunday': ['09:00 Øµ', '10:00 Øµ', '11:00 Øµ'],
  ///   'Monday': ['09:00 Øµ', '10:00 Øµ'],
  /// }
  ///
}


// ============================================================================
// Example from: user_model.dart (Dart Source)
// ============================================================================

void example_66() {
  // Example code:
/// [
  ///   {'degree': 'MD', 'institution': 'King Saud University', 'year': '2015'},
  ///   {'degree': 'PhD', 'institution': 'Harvard Medical School', 'year': '2020'},
  /// ]
  ///
}


// ============================================================================
// Example from: user_model.dart (Dart Source)
// ============================================================================

void example_67() {
  // Example code:
/// [
  ///   {'name': 'Board Certified Nutritionist', 'issuer': 'Saudi Commission', 'year': '2018'},
  /// ]
  ///
}


// ============================================================================
// Example from: user_model.dart (Dart Source)
// ============================================================================

void example_68() {
  // Example code:
/// if (user.userType == UserType.doctor) {
///   // Show doctor-specific features
/// }
///
}


// ============================================================================
// Example from: physiotherapy_emr.dart (Dart Source)
// ============================================================================

void example_69() {
  // Example code:
/// // Creating a new physiotherapy EMR
/// final emr = PhysiotherapyEMR(
///   id: 'emr_123',
///   patientId: 'patient_456',
///   doctorId: 'doctor_789',
///   doctorName: 'Dr. Ahmed Ali',
///   appointmentId: 'apt_123',
///   visitDate: DateTime.now(),
///   createdAt: DateTime.now(),
///   basics: {
///     'Identity Verification': ['Patient identity verified'],
///     'Consent': ['Informed consent obtained'],
///   },
///   painAssessment: {
///     'Pain Location': ['Lower back', 'Right knee'],
///     'Pain Intensity': ['Moderate (4-6/10)'],
///   },
///   functionalAssessment: {
///     'ADL': ['Difficulty with stairs', 'Limited walking distance'],
///   },
///   systemsReview: {},
///   rangeOfMotion: {},
///   strengthAssessment: {},
///   devicesEquipment: {},
///   treatmentPlan: {
///     'Interventions': ['Manual therapy', 'Therapeutic exercises'],
///   },
///   primaryDiagnosis: 'Chronic lower back pain with radiculopathy',
///   managementPlan: 'Progressive strengthening program over 6 weeks...',
/// );
///
/// // Accessing checklist data
/// final painLocations = emr.painAssessment['Pain Location'] ?? [];
/// print('Pain locations: ${painLocations.join(", ")}');
///
/// // Checking if section has data
/// final hasPainData = emr.painAssessment.isNotEmpty;
///
}


// ============================================================================
// Example from: auth_repository_impl.dart (Dart Source)
// ============================================================================

void example_70() {
  // Example code:
/// final authRepository = getIt<AuthRepository>();
///
}


// ============================================================================
// Example from: auth_repository_impl.dart (Dart Source)
// ============================================================================

void example_71() {
  // Example code:
/// final result = await authRepository.signIn(
///   email: 'user@example.com',
///   password: 'password123',
/// );
/// result.fold(
///   (failure) => showError(failure.message),
///   (user) => navigateToHome(user),
/// );
///
}


// ============================================================================
// Example from: auth_repository_impl.dart (Dart Source)
// ============================================================================

void example_72() {
  // Example code:
/// final result = await authRepository.signUp(
  ///   email: 'doctor@example.com',
  ///   password: 'SecurePass123!',
  ///   fullName: 'Dr. Ahmed Ali',
  ///   userType: UserType.doctor,
  ///   phoneNumber: '+966500000001',
  ///   licenseNumber: 'MED-12345',
  ///   specializations: ['Nutrition'],
  /// );
  ///
}


// ============================================================================
// Example from: auth_repository_impl.dart (Dart Source)
// ============================================================================

void example_73() {
  // Example code:
/// final result = await authRepository.signIn(
  ///   email: 'user@example.com',
  ///   password: 'password123',
  /// );
  ///
}


// ============================================================================
// Example from: auth_repository_impl.dart (Dart Source)
// ============================================================================

void example_74() {
  // Example code:
/// final result = await authRepository.signOut();
  /// result.fold(
  ///   (failure) => showError('ÙØ´Ù„ ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø®Ø±ÙˆØ¬'),
  ///   (_) => navigateToLogin(),
  /// );
  ///
}


// ============================================================================
// Example from: auth_repository_impl.dart (Dart Source)
// ============================================================================

void example_75() {
  // Example code:
/// final result = await authRepository.getCurrentUser();
  /// result.fold(
  ///   (failure) => showLoginScreen(),
  ///   (user) => displayProfile(user),
  /// );
  ///
}


// ============================================================================
// Example from: auth_repository_impl.dart (Dart Source)
// ============================================================================

void example_76() {
  // Example code:
/// final result = await authRepository.resetPassword('user@example.com');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (_) => showSuccess('ØªÙ… Ø¥Ø±Ø³Ø§Ù„ Ø±Ø§Ø¨Ø· Ø¥Ø¹Ø§Ø¯Ø© ØªØ¹ÙŠÙŠÙ† ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±'),
  /// );
  ///
}


// ============================================================================
// Example from: auth_repository_impl.dart (Dart Source)
// ============================================================================

void example_77() {
  // Example code:
/// final result = await authRepository.deleteAccount();
  /// result.fold(
  ///   (failure) {
  ///     if (failure.message == 'requires-recent-login') {
  ///       // Prompt user to re-authenticate
  ///       showReAuthDialog();
  ///     } else {
  ///       showError(failure.message);
  ///     }
  ///   },
  ///   (_) => navigateToWelcomeScreen(),
  /// );
  ///
}


// ============================================================================
// Example from: auth_repository_impl.dart (Dart Source)
// ============================================================================

void example_78() {
  // Example code:
/// final updatedUser = currentUser.copyWith(
  ///   fullName: 'New Name',
  ///   phoneNumber: '+966500000001',
  /// );
  /// final result = await authRepository.updateUser(updatedUser);
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (_) => showSuccess('ØªÙ… ØªØ­Ø¯ÙŠØ« Ø§Ù„Ù…Ù„Ù Ø§Ù„Ø´Ø®ØµÙŠ'),
  /// );
  ///
}


// ============================================================================
// Example from: appointment_repository_impl.dart (Dart Source)
// ============================================================================

void example_79() {
  // Example code:
/// final appointmentRepository = getIt<AppointmentRepository>();
///
}


// ============================================================================
// Example from: appointment_repository_impl.dart (Dart Source)
// ============================================================================

void example_80() {
  // Example code:
/// final appointment = AppointmentModel(...);
/// final result = await appointmentRepository.saveAppointment(appointment);
/// result.fold(
///   (failure) => showError(failure.message),
///   (_) => showSuccess('ØªÙ… Ø­Ø¬Ø² Ø§Ù„Ù…ÙˆØ¹Ø¯ Ø¨Ù†Ø¬Ø§Ø­'),
/// );
///
}


// ============================================================================
// Example from: appointment_repository_impl.dart (Dart Source)
// ============================================================================

void example_81() {
  // Example code:
/// final appointment = AppointmentModel(
  ///   id: 'apt_123',
  ///   patientId: 'patient_456',
  ///   doctorId: 'doctor_789',
  ///   appointmentDate: DateTime(2024, 3, 15),
  ///   timeSlot: '10:00 Øµ',
  ///   status: AppointmentStatus.pending,
  ///   // ... other fields
  /// );
  /// final result = await repository.saveAppointment(appointment);
  ///
}


// ============================================================================
// Example from: appointment_repository_impl.dart (Dart Source)
// ============================================================================

void example_82() {
  // Example code:
/// final result = await repository.getAppointmentsForPatient('patient_123');
  /// result.fold(
  ///   (failure) => showError('ÙØ´Ù„ ØªØ­Ù…ÙŠÙ„ Ø§Ù„Ù…ÙˆØ§Ø¹ÙŠØ¯'),
  ///   (appointments) => displayAppointments(appointments),
  /// );
  ///
}


// ============================================================================
// Example from: appointment_repository_impl.dart (Dart Source)
// ============================================================================

void example_83() {
  // Example code:
/// final result = await repository.getAppointmentsForDoctor('doctor_789');
  /// result.fold(
  ///   (failure) => showError('ÙØ´Ù„ ØªØ­Ù…ÙŠÙ„ Ø§Ù„Ù…ÙˆØ§Ø¹ÙŠØ¯'),
  ///   (appointments) => displayDoctorSchedule(appointments),
  /// );
  ///
}


// ============================================================================
// Example from: appointment_repository_impl.dart (Dart Source)
// ============================================================================

void example_84() {
  // Example code:
/// final result = await _executeQueryWithRetry(
  ///   query,
  ///   queryName: 'Patient Conflict Check',
  /// );
  ///
}


// ============================================================================
// Example from: appointment_repository_impl.dart (Dart Source)
// ============================================================================

void example_85() {
  // Example code:
/// final result = await repository.checkAppointmentConflict(
  ///   patientId: 'patient_123',
  ///   newAppointment: appointment,
  /// );
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (hasConflict) {
  ///     if (hasConflict) {
  ///       showError('ÙŠÙˆØ¬Ø¯ ØªØ¹Ø§Ø±Ø¶ ÙÙŠ Ø§Ù„Ù…ÙˆØ§Ø¹ÙŠØ¯');
  ///     } else {
  ///       proceedWithBooking();
  ///     }
  ///   },
  /// );
  ///
}


// ============================================================================
// Example from: appointment_repository_impl.dart (Dart Source)
// ============================================================================

void example_86() {
  // Example code:
/// final result = await repository.getActiveAppointmentsForPatient('patient_123');
  /// result.fold(
  ///   (failure) => showError('ÙØ´Ù„ ØªØ­Ù…ÙŠÙ„ Ø§Ù„Ù…ÙˆØ§Ø¹ÙŠØ¯ Ø§Ù„Ù†Ø´Ø·Ø©'),
  ///   (appointments) => displayUpcomingAppointments(appointments),
  /// );
  ///
}


// ============================================================================
// Example from: appointment_repository_impl.dart (Dart Source)
// ============================================================================

void example_87() {
  // Example code:
/// final today = DateTime.now();
  /// final result = await repository.getActiveAppointmentsForDate(today);
  /// result.fold(
  ///   (failure) => showError('ÙØ´Ù„ ØªØ­Ù…ÙŠÙ„ Ù…ÙˆØ§Ø¹ÙŠØ¯ Ø§Ù„ÙŠÙˆÙ…'),
  ///   (appointments) => displayDailySchedule(appointments),
  /// );
  ///
}


// ============================================================================
// Example from: nutrition_emr_repository_impl.dart (Dart Source)
// ============================================================================

void example_88() {
  // Example code:
/// final repository = getIt<NutritionEMRRepository>();
///
}


// ============================================================================
// Example from: nutrition_emr_repository_impl.dart (Dart Source)
// ============================================================================

void example_89() {
  // Example code:
/// final repository = getIt<NutritionEMRRepository>();
///
/// // Save EMR
/// final result = await repository.saveEMR(emrEntity);
/// result.fold(
///   (failure) => showError(failure.message),
///   (_) => showSuccess('EMR saved successfully'),
/// );
///
/// // Get EMR by appointment
/// final emrResult = await repository.getEMRByAppointmentId(appointmentId);
/// emrResult.fold(
///   (failure) => handleError(failure),
///   (emr) => emr != null ? displayEMR(emr) : showNotFound(),
/// );
///
}


// ============================================================================
// Example from: nutrition_emr_repository_impl.dart (Dart Source)
// ============================================================================

void example_90() {
  // Example code:
/// final emr = NutritionEMREntity(
  ///   id: 'emr_123',
  ///   appointmentId: 'apt_456',
  ///   patientId: 'patient_789',
  ///   nutritionistId: 'doctor_101',
  ///   nutritionistName: 'Dr. Ahmed',
  ///   // ... other fields
  /// );
  ///
  /// final result = await repository.saveEMR(emr);
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (_) => showSuccess('EMR saved successfully'),
  /// );
  ///
}


// ============================================================================
// Example from: nutrition_emr_repository_impl.dart (Dart Source)
// ============================================================================

void example_91() {
  // Example code:
/// final result = await repository.getEMRByAppointmentId('apt_456');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (emr) {
  ///     if (emr != null) {
  ///       displayEMR(emr);
  ///     } else {
  ///       showMessage('No EMR found for this appointment');
  ///     }
  ///   },
  /// );
  ///
}


// ============================================================================
// Example from: nutrition_emr_repository_impl.dart (Dart Source)
// ============================================================================

void example_92() {
  // Example code:
/// final result = await repository.getEMRsByPatientId('patient_789');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (emrs) {
  ///     if (emrs.isEmpty) {
  ///       showMessage('No EMRs found for this patient');
  ///     } else {
  ///       displayEMRList(emrs); // Shows ${emrs.length} records
  ///     }
  ///   },
  /// );
  ///
}


// ============================================================================
// Example from: nutrition_emr_repository_impl.dart (Dart Source)
// ============================================================================

void example_93() {
  // Example code:
/// final result = await repository.lockEMR('emr_123');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (_) => showSuccess('EMR locked successfully'),
  /// );
  ///
}


// ============================================================================
// Example from: nutrition_emr_repository_impl.dart (Dart Source)
// ============================================================================

void example_94() {
  // Example code:
/// final result = await repository.isAppointmentExpired('apt_456');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (isExpired) {
  ///     if (isExpired) {
  ///       showMessage('Cannot edit: 24-hour window expired');
  ///     } else {
  ///       allowEditing();
  ///     }
  ///   },
  /// );
  ///
}


// ============================================================================
// Example from: nutrition_emr_repository_impl.dart (Dart Source)
// ============================================================================

void example_95() {
  // Example code:
/// final result = await repository.watchEMR('emr_123');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (stream) {
  ///     stream.listen(
  ///       (emr) => updateUI(emr),
  ///       onError: (error) => handleStreamError(error),
  ///     );
  ///   },
  /// );
  ///
}


// ============================================================================
// Example from: doctor_repository_impl.dart (Dart Source)
// ============================================================================

void example_96() {
  // Example code:
/// final repository = getIt<DoctorRepository>();
///
}


// ============================================================================
// Example from: doctor_repository_impl.dart (Dart Source)
// ============================================================================

void example_97() {
  // Example code:
/// final repository = getIt<DoctorRepository>();
///
/// // Get all doctors
/// final result = await repository.getDoctors();
/// result.fold(
///   (failure) => showError(failure.message),
///   (doctors) => displayDoctorList(doctors),
/// );
///
/// // Get doctor by ID
/// final doctorResult = await repository.getDoctorById('doctor_123');
/// doctorResult.fold(
///   (failure) => handleError(failure),
///   (doctor) => displayDoctorProfile(doctor),
/// );
///
/// // Watch doctors stream
/// repository.getDoctorsStream().listen(
///   (doctors) => updateDoctorList(doctors),
/// );
///
}


// ============================================================================
// Example from: doctor_repository_impl.dart (Dart Source)
// ============================================================================

void example_98() {
  // Example code:
/// final result = await repository.getDoctors();
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (doctors) {
  ///     if (doctors.isEmpty) {
  ///       showMessage('No doctors available');
  ///     } else {
  ///       displayDoctorList(doctors); // Shows ${doctors.length} doctors
  ///     }
  ///   },
  /// );
  ///
}


// ============================================================================
// Example from: doctor_repository_impl.dart (Dart Source)
// ============================================================================

void example_99() {
  // Example code:
/// final stream = repository.getDoctorsStream();
  /// stream.listen(
  ///   (doctors) => updateDoctorList(doctors),
  ///   onError: (error) => handleStreamError(error),
  /// );
  ///
}


// ============================================================================
// Example from: doctor_repository_impl.dart (Dart Source)
// ============================================================================

void example_100() {
  // Example code:
/// final result = await repository.getDoctorById('doctor_123');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (doctor) {
  ///     displayDoctorProfile(doctor);
  ///     print('Doctor: ${doctor.fullName}');
  ///     print('Specialization: ${doctor.specializations.first}');
  ///   },
  /// );
  ///
}


// ============================================================================
// Example from: README.md (Markdown)
// ============================================================================

void example_101() {
  // Example code:
// Pattern: methodName_stateUnderTest_expectedBehavior
test('signIn_withValidCredentials_returnsUser', () { ... });
test('signIn_withInvalidCredentials_returnsFailure', () { ... });
test('joinChannel_withExpiredToken_throwsException', () { ... });
}


// ============================================================================
// Example from: README.md (Markdown)
// ============================================================================

void example_102() {
  // Example code:
// In test setup
void main() {
  setUpAll(() async {
    // Connect to Firestore emulator
    FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'elajtech',
    ).useFirestoreEmulator('localhost', 8080);
    
    // Connect to Auth emulator
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    
    // Connect to Functions emulator
    FirebaseFunctions.instanceFor(region: 'europe-west1')
      .useFunctionsEmulator('localhost', 5001);
  });
}
}


// ============================================================================
// Example from: README.md (Markdown)
// ============================================================================

void example_103() {
  // Example code:
// Tokens are generated server-side via Cloud Functions

// Client receives:

// - agoraToken: JWT token with 1-hour expiration

// - agoraChannelName: Unique channel identifier

// - agoraUid: User ID within the channel
}


// ============================================================================
// Example from: README.md (Markdown)
// ============================================================================

void example_104() {
  // Example code:
VideoEncoderConfiguration(

&nbsp; dimensions: VideoDimensions(width: 640, height: 480),

&nbsp; frameRate: 15,

&nbsp; bitrate: 0, // Auto-adjust

&nbsp; orientationMode: OrientationMode.orientationModeAdaptive,

)
}


// ============================================================================
// Example from: README.md (Markdown)
// ============================================================================

void example_105() {
  // Example code:
// Check for pending calls on app startup

await \_checkActiveCallsOnStartup();



// Restore call data from CallKit/ConnectionService

final activeCalls = await FlutterCallkitIncoming.activeCalls();

if (activeCalls.isNotEmpty) {

&nbsp; final callData = activeCalls.last\['extra'];

&nbsp; // Restore agoraToken, channelName, appointmentId

}
}


// ============================================================================
// Example from: README.md (Markdown)
// ============================================================================

void example_106() {
  // Example code:
// Automatic logging on connection state changes

onConnectionStateChanged: (connection, state, reason) async {

&nbsp; if (state == ConnectionStateType.connectionStateFailed) {

&nbsp;   await \_callMonitoringService.logConnectionFailure(

&nbsp;     appointmentId: \_currentAppointmentId!,

&nbsp;     userId: \_currentUserId!,

&nbsp;     reason: 'Connection state: $state, Reason: $reason',

&nbsp;     metadata: {

&nbsp;       'connectionState': state.toString(),

&nbsp;       'connectionReason': reason.toString(),

&nbsp;     },

&nbsp;   );

&nbsp; }

}
}


// ============================================================================
// Example from: README.md (Markdown)
// ============================================================================

void example_107() {
  // Example code:
class DeviceInfoModel {

&nbsp; final String platform;           // 'android' or 'ios'

&nbsp; final String deviceModel;        // e.g., 'Samsung Galaxy S21'

&nbsp; final String manufacturer;       // e.g., 'Samsung', 'Apple'

&nbsp; final String osVersion;          // e.g., 'Android 13', 'iOS 16.5'

&nbsp; final String appVersion;         // e.g., '1.0.0'

&nbsp; final String appBuildNumber;     // e.g., '1'

&nbsp; final String connectionType;     // 'wifi', 'mobile', 'none'

&nbsp; final int? availableMemoryMB;    // Optional

&nbsp; final String screenResolution;   // e.g., '1080x2400'

}
}


// ============================================================================
// Example from: README.md (Markdown)
// ============================================================================

void example_108() {
  // Example code:
// Automatically collected when logging errors

await \_callMonitoringService.logCallError(

&nbsp; appointmentId: appointmentId,

&nbsp; userId: userId,

&nbsp; errorType: 'join\_channel\_failed',

&nbsp; errorMessage: e.toString(),

&nbsp; // deviceInfo is auto-collected if not provided

);
}


// ============================================================================
// Example from: README.md (Markdown)
// ============================================================================

void example_109() {
  // Example code:
final settings = await \_messaging.requestPermission(

&nbsp; criticalAlert: true,  // Essential for VoIP calls

);
}


// ============================================================================
// Example from: README.md (Markdown)
// ============================================================================

void example_110() {
  // Example code:
Future<String> \_getConnectionType() async {

&nbsp; final dynamic result = await \_connectivity.checkConnectivity();

&nbsp; 

&nbsp; // Handle both single value and list return types

&nbsp; List<ConnectivityResult> results;

&nbsp; if (result is List<ConnectivityResult>) {

&nbsp;   results = result;

&nbsp; } else if (result is ConnectivityResult) {

&nbsp;   results = \[result];

&nbsp; } else {

&nbsp;   return 'unknown';

&nbsp; }

&nbsp; 

&nbsp; // Check for connection types

&nbsp; if (results.contains(ConnectivityResult.wifi)) return 'wifi';

&nbsp; if (results.contains(ConnectivityResult.mobile)) return 'mobile';

&nbsp; // ...

}
}


// ============================================================================
// Example from: README.md (Markdown)
// ============================================================================

void example_111() {
  // Example code:
@override

void didChangeAppLifecycleState(AppLifecycleState state) {

&nbsp; if (state == AppLifecycleState.resumed) {

&nbsp;   unawaited(\_checkAndCleanupCalls());

&nbsp; }

}



Future<void> \_checkAndCleanupCalls() async {

&nbsp; // Clean up CallKit/ConnectionService notifications

&nbsp; final appointmentId = await VoIPCallService().cleanupAfterCall();

&nbsp; 

&nbsp; if (appointmentId != null \&\& user.userType == UserType.doctor) {

&nbsp;   // Show confirmation dialog for doctor

&nbsp;   await \_showDoctorSessionEndDialog(appointmentId);

&nbsp; } else {

&nbsp;   // Auto-complete for patient

&nbsp;   await completeAppointment(appointmentId);

&nbsp; }

}
}


// ============================================================================
// Example from: README.md (Markdown)
// ============================================================================

void example_112() {
  // Example code:
final view = ui.PlatformDispatcher.instance.views.first;

final physicalSize = view.physicalSize;

screenResolution = '${physicalSize.width.toInt()}x${physicalSize.height.toInt()}';
}


// ============================================================================
// Example from: README.md (Markdown)
// ============================================================================

void example_113() {
  // Example code:
void \_onCallTimeout(CallEvent event) {

&nbsp; // Notify server of missed call

&nbsp; \_notifyServerMissedCall(appointmentId);

}



void \_onCallDeclined(CallEvent event) {

&nbsp; // Notify server of declined call

&nbsp; \_notifyServerCallDeclined(appointmentId);

}
}


// ============================================================================
// Example from: README.md (Markdown)
// ============================================================================

void example_114() {
  // Example code:
// Retrieve all error logs for debugging

final errorLogs = await CallMonitoringService().getErrorLogs(limit: 100);

for (final log in errorLogs) {

&nbsp; print('Error: ${log.errorCode} - ${log.errorMessage}');

&nbsp; print('Device: ${log.deviceInfo?.deviceModel}');

}
}


// ============================================================================
// Example from: README.md (Markdown)
// ============================================================================

void example_115() {
  // Example code:
/// Ø®Ø¯Ù…Ø© Ø¥Ø¯Ø§Ø±Ø© Ø§Ù„Ù…ÙƒØ§Ù„Ù…Ø§Øª Ø§Ù„Ù…Ø±Ø¦ÙŠØ© Ø¹Ø¨Ø± Agora
/// 
/// Video call management service using Agora RTC Engine
///
/// This service handles:
/// - Agora RTC Engine initialization
/// - Channel join/leave operations
/// - Audio/video control (mute, unmute, camera switch)
/// - Connection state monitoring
/// - Error handling and logging
///
/// **Usage Example:**
///
}


// ============================================================================
// Example from: README.md (Markdown)
// ============================================================================

void example_116() {
  // Example code:
// Initialize with correct region
final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

// Start video call
final result = await functions.httpsCallable('startAgoraCall').call({
  'appointmentId': 'apt_123',
  'doctorId': 'doctor_456',
});

// Use returned tokens
final agoraToken = result.data['agoraToken'];
final channelName = result.data['agoraChannelName'];
}


// ============================================================================
// Example from: README.md (Markdown)
// ============================================================================

void example_117() {
  // Example code:
// âœ… CORRECT
final firestore = FirebaseFirestore.instanceFor(
  app: Firebase.app(),
  databaseId: 'elajtech',
);

// âŒ WRONG
final firestore = FirebaseFirestore.instance;
}


// ============================================================================
// Example from: README.md (Markdown)
// ============================================================================

void example_118() {
  // Example code:
// âœ… CORRECT
final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

// âŒ WRONG
final functions = FirebaseFunctions.instance;
}


// ============================================================================
// Example from: CONTRIBUTING.md (Markdown)
// ============================================================================

void example_119() {
  // Example code:
// Via dependency injection (PREFERRED)
@LazySingleton(as: MyRepository)
class MyRepositoryImpl implements MyRepository {
  MyRepositoryImpl(this._firestore); // Injected instance
  final FirebaseFirestore _firestore;
  
  Future<void> saveData() async {
    await _firestore.collection('my_collection').add({...});
  }
}

// Direct instantiation (ONLY in firebase_module.dart)
@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'elajtech',
  );
}
}


// ============================================================================
// Example from: CONTRIBUTING.md (Markdown)
// ============================================================================

void example_120() {
  // Example code:
// DON'T DO THIS!
final firestore = FirebaseFirestore.instance; // âŒ WRONG!

// This will use the default database, not 'elajtech'
await FirebaseFirestore.instance.collection('users').get(); // âŒ WRONG!
}


// ============================================================================
// Example from: CONTRIBUTING.md (Markdown)
// ============================================================================

void example_121() {
  // Example code:
// After creating this class, run build_runner
@freezed
class UserModel with _$UserModel {
  factory UserModel({
    required String id,
    required String fullName,
  }) = _UserModel;
  
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
}


// ============================================================================
// Example from: CONTRIBUTING.md (Markdown)
// ============================================================================

void example_122() {
  // Example code:
final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

final result = await functions.httpsCallable('startAgoraCall').call({
  'appointmentId': 'apt_123',
  'doctorId': 'doctor_456',
});
}


// ============================================================================
// Example from: CONTRIBUTING.md (Markdown)
// ============================================================================

void example_123() {
  // Example code:
// This will fail with "NOT_FOUND" error
final functions = FirebaseFunctions.instance; // âŒ WRONG!
}


// ============================================================================
// Example from: CONTRIBUTING.md (Markdown)
// ============================================================================

void example_124() {
  // Example code:
@override
Widget build(BuildContext context, WidgetRef ref) {
  final user = ref.watch(authProvider).user;
  
  if (user == null) {
    return const LoadingWidget();
  }
  
  // Now safe to use user.id, user.fullName, etc.
  return Text('Welcome, ${user.fullName}');
}
}


// ============================================================================
// Example from: CONTRIBUTING.md (Markdown)
// ============================================================================

void example_125() {
  // Example code:
// DON'T DO THIS!
final user = ref.watch(authProvider).user!; // âŒ WRONG!
// This will crash if user is null
}


// ============================================================================
// Example from: CONTRIBUTING.md (Markdown)
// ============================================================================

void example_126() {
  // Example code:
@override
Future<Either<Failure, UserModel>> getUser(String id) async {
  try {
    final doc = await _firestore.collection('users').doc(id).get();
    
    if (doc.exists && doc.data() != null) {
      return Right(UserModel.fromJson(doc.data()!));
    } else {
      return const Left(ServerFailure('User not found'));
    }
  } on FirebaseException catch (e) {
    return Left(ServerFailure(e.message ?? 'Unknown error'));
  } on Exception catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
}


// ============================================================================
// Example from: CONTRIBUTING.md (Markdown)
// ============================================================================

void example_127() {
  // Example code:
factory UserModel.fromFirestore(DocumentSnapshot snapshot) {
  if (!snapshot.exists || snapshot.data() == null) {
    throw Exception('Document does not exist or has no data');
  }
  
  try {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserModel.fromJson(data);
  } catch (e, stackTrace) {
    debugPrint('Error parsing UserModel: $e');
    debugPrint('StackTrace: $stackTrace');
    rethrow;
  }
}
}


// ============================================================================
// Example from: CONTRIBUTING.md (Markdown)
// ============================================================================

void example_128() {
  // Example code:
Future<Either<Failure, Unit>> saveAppointment(AppointmentModel appointment) async {
  try {
    if (kDebugMode) {
      debugPrint('Saving appointment: ${appointment.id}');
      debugPrint('Patient ID: ${appointment.patientId}');
      debugPrint('Doctor ID: ${appointment.doctorId}');
    }
    
    await _firestore
        .collection('appointments')
        .doc(appointment.id)
        .set(appointment.toJson());
    
    if (kDebugMode) {
      debugPrint('Appointment saved successfully: ${appointment.id}');
    }
    
    return const Right(unit);
  } on Exception catch (e) {
    if (kDebugMode) {
      debugPrint('Error saving appointment: $e');
    }
    return Left(ServerFailure(e.toString()));
  }
}
}


// ============================================================================
// Example from: CONTRIBUTING.md (Markdown)
// ============================================================================

void example_129() {
  // Example code:
/// Authentication Repository implementation for the AndroCare360 system.
/// Ù…Ø³ØªÙˆØ¯Ø¹ Ø§Ù„Ù…ØµØ§Ø¯Ù‚Ø© Ù„Ù†Ø¸Ø§Ù… AndroCare360.
///
/// This repository implements the [AuthRepository] interface and handles
/// all Firebase Authentication operations.
/// ÙŠÙ‚ÙˆÙ… Ù‡Ø°Ø§ Ø§Ù„Ù…Ø³ØªÙˆØ¯Ø¹ Ø¨ØªÙ†ÙÙŠØ° ÙˆØ§Ø¬Ù‡Ø© [AuthRepository] ÙˆÙŠØªØ¹Ø§Ù…Ù„ Ù…Ø¹ Ø¬Ù…ÙŠØ¹
/// Ø¹Ù…Ù„ÙŠØ§Øª Ø§Ù„Ù…ØµØ§Ø¯Ù‚Ø© ÙÙŠ Firebase.
///
/// **CRITICAL DATABASE RULES:**
/// - Must use `databaseId: 'elajtech'` for ALL Firestore operations
/// - Never use FirebaseFirestore.instance directly
///
/// **Dependency Injection:**
/// Registered as @LazySingleton with injectable package. Access via:
///
}


// ============================================================================
// Example from: CONTRIBUTING.md (Markdown)
// ============================================================================

void example_130() {
  // Example code:
/// final result = await repository.signIn(email, password);
/// result.fold(
///   (failure) => showError(failure.message),
///   (user) => navigateToHome(user),
/// );
///
}


// ============================================================================
// Example from: CONTRIBUTING.md (Markdown)
// ============================================================================

void example_131() {
  // Example code:
/// Sign in a user with email and password.
/// ØªØ³Ø¬ÙŠÙ„ Ø¯Ø®ÙˆÙ„ Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… Ø¨Ø§Ø³ØªØ®Ø¯Ø§Ù… Ø§Ù„Ø¨Ø±ÙŠØ¯ Ø§Ù„Ø¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠ ÙˆÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±.
///
/// Authenticates the user with Firebase Auth and retrieves their profile
/// from Firestore.
/// ÙŠÙ‚ÙˆÙ… Ø¨Ù…ØµØ§Ø¯Ù‚Ø© Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… Ù…Ø¹ Firebase Auth ÙˆØ§Ø³ØªØ±Ø¬Ø§Ø¹ Ù…Ù„ÙÙ‡ Ø§Ù„Ø´Ø®ØµÙŠ
/// Ù…Ù† Firestore.
///
/// Parameters:
/// - email: User's email address (required)
/// - password: User's password (required)
///
/// Returns:
/// - Right(UserModel): User authenticated successfully
/// - Left(ServerFailure): Authentication failed
///
/// Example:
///
}


// ============================================================================
// Example from: CONTRIBUTING.md (Markdown)
// ============================================================================

void example_132() {
  // Example code:
// Good examples
test('signIn_withValidCredentials_returnsUser', () { ... });
test('signIn_withInvalidCredentials_returnsFailure', () { ... });
test('signIn_withNetworkError_returnsNetworkFailure', () { ... });

// Bad examples
test('test sign in', () { ... }); // Too vague
test('signIn', () { ... }); // Missing context
}


// ============================================================================
// Example from: CONTRIBUTING.md (Markdown)
// ============================================================================

void example_133() {
  // Example code:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('AuthRepository', () {
    late AuthRepositoryImpl repository;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      repository = AuthRepositoryImpl(mockAuth, mockFirestore);
    });

    test('signIn_withValidCredentials_returnsUser', () async {
      // Arrange
      when(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await repository.signIn('test@example.com', 'password');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (user) => expect(user.email, 'test@example.com'),
      );
    });
  });
}
}


// ============================================================================
// Example from: CONTRIBUTING.md (Markdown)
// ============================================================================

void example_134() {
  // Example code:
test('voipService_showIncomingCall_handlesNativeAPI', () async {
  try {
    await voipService.showIncomingCall(callData);
    // Test passes if no exception
  } on MissingPluginException {
    // Expected in test environment without native platform
    // Test still passes
  }
});
}


// ============================================================================
// Example from: CONTRIBUTING.md (Markdown)
// ============================================================================

void example_135() {
  // Example code:
@LazySingleton(as: MyRepository)
   class MyRepositoryImpl implements MyRepository {
     // Run build_runner after this
   }
}


// ============================================================================
// Example from: CONTRIBUTING.md (Markdown)
// ============================================================================

void example_136() {
  // Example code:
@injectable
   class MyService {
     // Run build_runner after this
   }
}


// ============================================================================
// Example from: CONTRIBUTING.md (Markdown)
// ============================================================================

void example_137() {
  // Example code:
@freezed
   class MyModel with _$MyModel {
     // Run build_runner after modifying this
   }
}


// ============================================================================
// Example from: CONTRIBUTING.md (Markdown)
// ============================================================================

void example_138() {
  // Example code:
@JsonSerializable()
   class MyModel {
     // Run build_runner after this
   }
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_139() {
  // Example code:
// Initialize Firebase Functions with correct region
final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_140() {
  // Example code:
// Auth token is automatically included
final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

try {
  final result = await functions.httpsCallable('startAgoraCall').call({
    'appointmentId': 'apt_123',
    'doctorId': 'doctor_456',
  });
  // Process result
} on FirebaseFunctionsException catch (e) {
  // Handle error
}
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_141() {
  // Example code:
try {
  final result = await functions.httpsCallable('startAgoraCall').call(data);
} on FirebaseFunctionsException catch (e) {
  if (e.code == 'unauthenticated') {
    // User not signed in or token expired
    // Redirect to login screen
    Navigator.pushReplacementNamed(context, '/login');
  } else if (e.code == 'permission-denied') {
    // User doesn't have required permissions
    showError('You do not have permission to perform this action');
  }
}
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_142() {
  // Example code:
final user = FirebaseAuth.instance.currentUser;
   if (user == null) {
     // User not signed in
   }
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_143() {
  // Example code:
await FirebaseAuth.instance.currentUser?.getIdToken(true);
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_144() {
  // Example code:
// Always specify the region
final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

// Use the configured instance for all calls
final result = await functions.httpsCallable('startAgoraCall').call(data);
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_145() {
  // Example code:
// DON'T DO THIS! Will result in NOT_FOUND error
final functions = FirebaseFunctions.instance; // âŒ WRONG!

// This will fail because it uses the default region
final result = await functions.httpsCallable('startAgoraCall').call(data);
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_146() {
  // Example code:
final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

try {
  final result = await functions.httpsCallable('startAgoraCall').call({
    'appointmentId': 'apt_123456',
    'doctorId': 'doctor_789',
    'deviceInfo': {
      'platform': 'android',
      'deviceModel': 'Samsung Galaxy S21',
      'osVersion': 'Android 13',
    },
  });

  final data = result.data;
  print('Agora Token: ${data['agoraToken']}');
  print('Channel Name: ${data['agoraChannelName']}');
  print('UID: ${data['agoraUid']}');
  
  // Use the token to join Agora channel
  await agoraService.joinChannel(
    token: data['agoraToken'],
    channelName: data['agoraChannelName'],
    uid: data['agoraUid'],
  );
} on FirebaseFunctionsException catch (e) {
  print('Error: ${e.code} - ${e.message}');
  // Handle specific error codes
  if (e.code == 'permission-denied') {
    showError('You are not authorized to start this call');
  } else if (e.code == 'not-found') {
    showError('Appointment not found');
  }
}
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_147() {
  // Example code:
final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

try {
  await functions.httpsCallable('endAgoraCall').call({
    'appointmentId': 'apt_123456',
  });
  
  print('Call ended successfully');
  
  // Leave the Agora channel
  await agoraService.leaveChannel();
  
  // Navigate to completion screen
  Navigator.pushReplacementNamed(context, '/call-completed');
} on FirebaseFunctionsException catch (e) {
  print('Error ending call: ${e.code} - ${e.message}');
  
  if (e.code == 'not-found') {
    showError('Appointment not found');
  }
}
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_148() {
  // Example code:
final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

try {
  await functions.httpsCallable('completeAppointment').call({
    'appointmentId': 'apt_123456',
  });
  
  print('Appointment marked as completed');
  
  // Show success message
  showSuccess('Appointment completed successfully');
  
  // Navigate to appointments list
  Navigator.pushReplacementNamed(context, '/appointments');
} on FirebaseFunctionsException catch (e) {
  print('Error completing appointment: ${e.code} - ${e.message}');
  
  if (e.code == 'not-found') {
    showError('Appointment not found');
  } else if (e.code == 'permission-denied') {
    showError('You do not have permission to complete this appointment');
  }
}
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_149() {
  // Example code:
try {
  final result = await functions.httpsCallable('functionName').call(data);
  // Handle success
} on FirebaseFunctionsException catch (e) {
  switch (e.code) {
    case 'unauthenticated':
      // Redirect to login
      Navigator.pushReplacementNamed(context, '/login');
      break;
    case 'permission-denied':
      showError('You do not have permission to perform this action');
      break;
    case 'not-found':
      showError('Resource not found');
      break;
    case 'unavailable':
      // Retry logic
      await Future.delayed(Duration(seconds: 2));
      // Retry the call
      break;
    default:
      showError('An error occurred: ${e.message}');
  }
} catch (e) {
  // Handle unexpected errors
  showError('Unexpected error: $e');
}
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_150() {
  // Example code:
// Make sure you're using europe-west1
   final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_151() {
  // Example code:
final user = FirebaseAuth.instance.currentUser;
   if (user == null) {
     // User not signed in - redirect to login
     Navigator.pushReplacementNamed(context, '/login');
   }
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_152() {
  // Example code:
try {
     await FirebaseAuth.instance.currentUser?.getIdToken(true);
     // Retry the function call
   } catch (e) {
     // Token refresh failed - user needs to sign in again
   }
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_153() {
  // Example code:
await FirebaseAuth.instance.signOut();
   // Navigate to login screen
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_154() {
  // Example code:
final user = ref.watch(authProvider).user;
   if (user?.userType != 'doctor') {
     showError('Only doctors can start video calls');
     return;
   }
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_155() {
  // Example code:
// For startAgoraCall, doctorId must match authenticated user
   final doctorId = FirebaseAuth.instance.currentUser?.uid;
   await functions.httpsCallable('startAgoraCall').call({
     'appointmentId': appointmentId,
     'doctorId': doctorId, // Must match current user
   });
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_156() {
  // Example code:
// Monitor call duration
   final callStartTime = DateTime.now();
   
   // Check if approaching 1 hour
   Timer.periodic(Duration(minutes: 50), (timer) {
     final duration = DateTime.now().difference(callStartTime);
     if (duration.inMinutes >= 50) {
       // Warn user about approaching time limit
       showWarning('Call will end in 10 minutes due to time limit');
     }
   });
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_157() {
  // Example code:
Future<T> retryFunction<T>(
     Future<T> Function() function, {
     int maxAttempts = 3,
     Duration delay = const Duration(seconds: 2),
   }) async {
     for (int attempt = 1; attempt <= maxAttempts; attempt++) {
       try {
         return await function();
       } catch (e) {
         if (attempt == maxAttempts) rethrow;
         await Future.delayed(delay);
       }
     }
     throw Exception('Max retry attempts reached');
   }
   
   // Usage
   final result = await retryFunction(() =>
     functions.httpsCallable('startAgoraCall').call(data)
   );
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_158() {
  // Example code:
final connectivity = await Connectivity().checkConnectivity();
   if (connectivity == ConnectivityResult.none) {
     showError('No internet connection');
     return;
   }
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_159() {
  // Example code:
try {
     final result = await functions
       .httpsCallable('startAgoraCall')
       .call(data)
       .timeout(
         Duration(seconds: 30),
         onTimeout: () {
           throw TimeoutException('Function call timed out');
         },
       );
   } on TimeoutException {
     showError('Request timed out. Please check your connection.');
   }
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_160() {
  // Example code:
// In main.dart (debug mode only)
   if (kDebugMode) {
     FirebaseFunctions.instanceFor(region: 'europe-west1')
       .useFunctionsEmulator('localhost', 5001);
   }
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_161() {
  // Example code:
// Query recent error logs
   final errorLogs = await FirebaseFirestore.instanceFor(
     app: Firebase.app(),
     databaseId: 'elajtech',
   )
     .collection('call_logs')
     .where('eventType', isEqualTo: 'call_error')
     .orderBy('timestamp', descending: true)
     .limit(10)
     .get();
   
   for (final doc in errorLogs.docs) {
     print('Error: ${doc.data()}');
   }
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_162() {
  // Example code:
try {
     final result = await functions.httpsCallable('startAgoraCall').call(data);
     // Process result
   } on FirebaseFunctionsException catch (e) {
     // Handle Firebase Functions specific errors
     _handleFunctionsError(e);
   } on TimeoutException catch (e) {
     // Handle timeout errors
     showError('Request timed out');
   } catch (e) {
     // Handle unexpected errors
     debugPrint('Unexpected error: $e');
     showError('An unexpected error occurred');
   }
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_163() {
  // Example code:
void _handleFunctionsError(FirebaseFunctionsException e) {
     final message = switch (e.code) {
       'unauthenticated' => 'Please sign in to continue',
       'permission-denied' => 'You do not have permission to perform this action',
       'not-found' => 'The requested resource was not found',
       'unavailable' => 'Service temporarily unavailable. Please try again.',
       _ => 'An error occurred: ${e.message}',
     };
     
     showError(message);
   }
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_164() {
  // Example code:
try {
     final result = await functions.httpsCallable('startAgoraCall').call(data);
   } on FirebaseFunctionsException catch (e, stackTrace) {
     // Log to Firebase Crashlytics or monitoring service
     if (kDebugMode) {
       debugPrint('Function error: ${e.code} - ${e.message}');
       debugPrint('Stack trace: $stackTrace');
     }
     
     // Log to call monitoring service
     await CallMonitoringService().logCallError(
       appointmentId: appointmentId,
       userId: userId,
       errorType: 'cloud_function_error',
       errorMessage: '${e.code}: ${e.message}',
       stackTrace: stackTrace.toString(),
     );
   }
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_165() {
  // Example code:
Future<T> retryWithBackoff<T>(
     Future<T> Function() function, {
     int maxAttempts = 3,
     Duration initialDelay = const Duration(seconds: 1),
   }) async {
     Duration delay = initialDelay;
     
     for (int attempt = 1; attempt <= maxAttempts; attempt++) {
       try {
         return await function();
       } on FirebaseFunctionsException catch (e) {
         // Don't retry on client errors
         if (e.code == 'invalid-argument' ||
             e.code == 'permission-denied' ||
             e.code == 'unauthenticated') {
           rethrow;
         }
         
         if (attempt == maxAttempts) rethrow;
         
         // Exponential backoff
         await Future.delayed(delay);
         delay *= 2;
       }
     }
     throw Exception('Max retry attempts reached');
   }
   
   // Usage
   final result = await retryWithBackoff(() =>
     functions.httpsCallable('startAgoraCall').call(data)
   );
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_166() {
  // Example code:
bool isRetryableError(String code) {
     return code == 'unavailable' ||
            code == 'deadline-exceeded' ||
            code == 'internal';
   }
   
   Future<T> smartRetry<T>(Future<T> Function() function) async {
     try {
       return await function();
     } on FirebaseFunctionsException catch (e) {
       if (isRetryableError(e.code)) {
         // Wait and retry once
         await Future.delayed(Duration(seconds: 2));
         return await function();
       }
       rethrow;
     }
   }
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_167() {
  // Example code:
// Short timeout for quick operations
   final result = await functions
     .httpsCallable('endAgoraCall')
     .call(data)
     .timeout(Duration(seconds: 10));
   
   // Longer timeout for complex operations
   final result = await functions
     .httpsCallable('startAgoraCall')
     .call(data)
     .timeout(Duration(seconds: 30));
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_168() {
  // Example code:
try {
     final result = await functions
       .httpsCallable('startAgoraCall')
       .call(data)
       .timeout(
         Duration(seconds: 30),
         onTimeout: () async {
           // Log timeout
           await CallMonitoringService().logCallError(
             appointmentId: appointmentId,
             userId: userId,
             errorType: 'timeout',
             errorMessage: 'Function call timed out after 30 seconds',
           );
           
           throw TimeoutException('Call initiation timed out');
         },
       );
   } on TimeoutException {
     showError('Request timed out. Please check your connection and try again.');
   }
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_169() {
  // Example code:
Future<T> callFunctionWithLogging<T>(
     String functionName,
     Map<String, dynamic> data,
   ) async {
     if (kDebugMode) {
       debugPrint('Calling function: $functionName');
       debugPrint('Parameters: $data');
     }
     
     final startTime = DateTime.now();
     
     try {
       final result = await functions.httpsCallable(functionName).call(data);
       
       final duration = DateTime.now().difference(startTime);
       if (kDebugMode) {
         debugPrint('Function $functionName completed in ${duration.inMilliseconds}ms');
       }
       
       return result.data as T;
     } catch (e) {
       final duration = DateTime.now().difference(startTime);
       if (kDebugMode) {
         debugPrint('Function $functionName failed after ${duration.inMilliseconds}ms: $e');
       }
       rethrow;
     }
   }
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_170() {
  // Example code:
// Always log call attempts
   await CallMonitoringService().logCallAttempt(
     appointmentId: appointmentId,
     userId: userId,
     deviceInfo: await DeviceInfoService().getDeviceInfo(),
   );
   
   try {
     final result = await functions.httpsCallable('startAgoraCall').call(data);
     
     // Log successful call start
     await CallMonitoringService().logCallStarted(
       appointmentId: appointmentId,
       userId: userId,
       channelName: result.data['agoraChannelName'],
     );
   } catch (e) {
     // Log call error
     await CallMonitoringService().logCallError(
       appointmentId: appointmentId,
       userId: userId,
       errorType: 'call_initiation_failed',
       errorMessage: e.toString(),
     );
   }
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_171() {
  // Example code:
// In a service or provider
   class CloudFunctionsService {
     static final _functions = FirebaseFunctions.instanceFor(
       region: 'europe-west1',
     );
     
     Future<Map<String, dynamic>> startAgoraCall({
       required String appointmentId,
       required String doctorId,
     }) async {
       final result = await _functions.httpsCallable('startAgoraCall').call({
         'appointmentId': appointmentId,
         'doctorId': doctorId,
       });
       
       return result.data as Map<String, dynamic>;
     }
   }
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_172() {
  // Example code:
// Only send required data
   await functions.httpsCallable('startAgoraCall').call({
     'appointmentId': appointmentId,
     'doctorId': doctorId,
     // Don't send unnecessary data
   });
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_173() {
  // Example code:
// If operations are independent, run them in parallel
   final results = await Future.wait([
     functions.httpsCallable('endAgoraCall').call({'appointmentId': id1}),
     functions.httpsCallable('completeAppointment').call({'appointmentId': id2}),
   ]);
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_174() {
  // Example code:
// âŒ DON'T DO THIS
   await functions.httpsCallable('startAgoraCall').call({
     'appointmentId': appointmentId,
     'agoraCertificate': 'secret_key', // âŒ NEVER send secrets from client
   });
   
   // âœ… DO THIS
   await functions.httpsCallable('startAgoraCall').call({
     'appointmentId': appointmentId,
     'doctorId': doctorId,
     // Server generates tokens using stored secrets
   });
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_175() {
  // Example code:
// Check permissions before calling function
   final user = ref.watch(authProvider).user;
   if (user?.userType != 'doctor') {
     showError('Only doctors can start video calls');
     return;
   }
   
   // Proceed with function call
   await functions.httpsCallable('startAgoraCall').call(data);
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_176() {
  // Example code:
// Monitor token expiration
   final tokenExpirationTime = DateTime.now().add(Duration(hours: 1));
   
   // Warn user before expiration
   Timer(Duration(minutes: 50), () {
     showWarning('Call will end in 10 minutes');
   });
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_177() {
  // Example code:
// In main.dart (debug mode only)
   if (kDebugMode) {
     FirebaseFunctions.instanceFor(region: 'europe-west1')
       .useFunctionsEmulator('localhost', 5001);
   }
}


// ============================================================================
// Example from: API_DOCUMENTATION.md (Markdown)
// ============================================================================

void example_178() {
  // Example code:
// In test file
   class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}
   
   test('startAgoraCall returns valid token', () async {
     final mockFunctions = MockFirebaseFunctions();
     
     when(mockFunctions.httpsCallable('startAgoraCall').call(any))
       .thenAnswer((_) async => HttpsCallableResult(data: {
         'agoraToken': 'mock_token',
         'agoraChannelName': 'mock_channel',
         'agoraUid': 12345,
       }));
     
     // Test your code
   });
}

