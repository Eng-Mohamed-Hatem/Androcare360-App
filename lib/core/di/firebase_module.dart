import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';

/// Firebase Module - تسجيل Firebase instances في GetIt container
///
/// يوفر هذا الـ Module نسخاً مركزية من Firebase services
/// لاستخدامها في جميع أنحاء التطبيق عبر Dependency Injection
@module
abstract class FirebaseModule {
  /// تسجيل FirebaseAuth instance كـ Singleton
  ///
  /// يُستخدم للمصادقة وإدارة المستخدمين
  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  /// تسجيل FirebaseFirestore instance كـ Singleton
  ///
  /// يُستخدم لقراءة وكتابة البيانات في Cloud Firestore
  /// متصل بقاعدة البيانات المخصصة: elajtech
  @lazySingleton
  FirebaseFirestore get firebaseFirestore => FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'elajtech',
  )..settings = const Settings(persistenceEnabled: true);

  /// تسجيل FirebaseFunctions instance كـ Singleton
  ///
  /// يُستخدم لاستدعاء Cloud Functions
  /// متصل بمنطقة europe-west1 (CRITICAL: جميع Cloud Functions منشورة في هذه المنطقة)
  @lazySingleton
  FirebaseFunctions get firebaseFunctions =>
      FirebaseFunctions.instanceFor(region: 'europe-west1');

  /// تسجيل FirebaseStorage instance كـ Singleton
  @lazySingleton
  FirebaseStorage get firebaseStorage => FirebaseStorage.instance;
}
