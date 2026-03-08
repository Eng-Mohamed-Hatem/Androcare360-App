/// Mock generation configuration for test suite
///
/// This file defines all the classes that need mock implementations
/// for testing. Run the following command to generate mocks:
///
/// ```bash
/// flutter pub run build_runner build --delete-conflicting-outputs
/// ```
///
/// Generated mocks will be available in mocks.mocks.dart
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:elajtech/core/services/token_refresh_service.dart';
import 'package:elajtech/core/services/fcm_service.dart';
import 'package:elajtech/core/services/voip_call_service.dart';
import 'package:elajtech/core/services/call_monitoring_service.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  // Firebase Firestore mocks
  FirebaseFirestore,
  DocumentReference,
  CollectionReference,
  QuerySnapshot,
  DocumentSnapshot,
  QueryDocumentSnapshot,
  Query,

  // Firebase Auth mocks
  FirebaseAuth,
  User,
  UserCredential,

  // Agora RTC mocks
  RtcEngine,

  // Cloud Functions mocks
  FirebaseFunctions,
  HttpsCallable,
  HttpsCallableResult,

  // Core Services mocks
  TokenRefreshService,
  FCMService,
  VoIPCallService,
  CallMonitoringService,
])
void main() {}
