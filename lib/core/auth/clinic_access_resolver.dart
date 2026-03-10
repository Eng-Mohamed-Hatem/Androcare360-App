/// ClinicAccessResolver — محدِّد صلاحية الوصول إلى العيادات
///
/// يحدد هذه الخدمة قائمة العيادات التي يُسمح للمستخدم الحالي بالوصول إليها
/// بناءً على Claims المخصصة من Firebase Auth أو من Firestore كـ fallback.
///
/// **English**: Domain helper service (R4) that reads Firebase Auth custom
/// claims to derive the list of clinic IDs accessible to the current user.
///
/// Claim schema expected (set server-side via Cloud Functions):
/// ```json
/// { "role": "ADMIN_GLOBAL" }                   → all 5 clinics
/// { "role": "ADMIN_CLINIC", "allowedClinics": ["andrology"] }
/// { "role": "DOCTOR_ANDROLOGY", "allowedClinics": ["andrology"] }
/// { "role": "PATIENT" }                         → [] (empty — no clinic admin)
/// ```
///
/// **Fallback** (when claims absent / stale):
/// Reads `users/{uid}.userType` from Firestore:
/// - `ADMIN_GLOBAL` → [ClinicIds.all]
/// - other roles   → [] (deny)
///
/// **Arabic**:
/// خدمة مساعدة (R4) تقرأ Claims المخصصة لـ Firebase Auth لتحديد العيادات
/// المسموح بالوصول إليها. عند غياب Claims تُراجع `users/{uid}.userType`.
///
/// **Spec**: spec.md §7.7, tasks.md T090.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/features/packages/data/constants/clinic_ids.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Resolves which clinic IDs the current Firebase Auth user may access.
///
/// **English**
/// Annotated `@lazySingleton` — registered in GetIt via injectable.
/// Call [getAllowedClinics] to get the resolved list.
///
/// **Arabic**
/// خدمة مُسجَّلة كـ `@lazySingleton`. استخدم [getAllowedClinics] للحصول
/// على قائمة العيادات المسموح بها.
///
/// **Usage / الاستخدام**:
/// ```dart
/// final resolver = getIt<ClinicAccessResolver>();
/// final clinics  = await resolver.getAllowedClinics();
/// if (clinics.isEmpty) { /* deny */ }
/// ```
@lazySingleton
class ClinicAccessResolver {
  /// Creates a [ClinicAccessResolver] with injected Firebase instances.
  ///
  /// يُنشئ مُحدِّد الصلاحية مع خدمات Firebase المُحقَنة.
  ClinicAccessResolver(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// Returns the list of clinic IDs the current user may access.
  ///
  /// **English**
  /// Priority:
  /// 1. Firebase Auth custom claims (fastest).
  /// 2. Firestore `users/{uid}.userType` fallback (slightly slower).
  /// 3. Returns [] on any error or when user is unauthenticated.
  ///
  /// **Arabic**
  /// الأولوية: Claims أولًا، ثم Firestore كـ fallback، ثم قائمة فارغة
  /// عند الخطأ أو عدم المصادقة.
  Future<List<String>> getAllowedClinics() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) {
          debugPrint('[ClinicAccessResolver] No authenticated user → []');
        }
        return [];
      }

      // 1️⃣ Read custom claims (fast path)
      final idTokenResult = await user.getIdTokenResult();
      final claims = idTokenResult.claims ?? {};
      final role = claims['role'] as String?;

      if (kDebugMode) {
        debugPrint(
          '[ClinicAccessResolver] uid=${user.uid} role=$role claims=$claims',
        );
      }

      if (role != null) {
        return _resolveFromRole(role, claims);
      }

      // 2️⃣ Fallback to Firestore users/{uid} document
      if (kDebugMode) {
        debugPrint(
          '[ClinicAccessResolver] No role claim — falling back to Firestore',
        );
      }
      return await _resolveFromFirestore(user.uid);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[ClinicAccessResolver] Error resolving clinics: $e');
        debugPrint('$st');
      }
      return [];
    }
  }

  /// Checks if [clinicId] is accessible to the current user.
  ///
  /// يُعيد `true` إذا كان المستخدم مُصرَّحًا له بالوصول إلى [clinicId].
  Future<bool> canAccessClinic(String clinicId) async {
    final allowed = await getAllowedClinics();
    return allowed.contains(clinicId);
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Derives the clinic list from a role claim string.
  List<String> _resolveFromRole(String role, Map<String, dynamic> claims) {
    if (role == 'ADMIN_GLOBAL') {
      if (kDebugMode) {
        debugPrint(
          '[ClinicAccessResolver] ADMIN_GLOBAL → all ${ClinicIds.all.length} clinics',
        );
      }
      return List.unmodifiable(ClinicIds.all);
    }

    // ADMIN_CLINIC, DOCTOR_* — use allowedClinics claim
    final raw = claims['allowedClinics'];
    if (raw is List) {
      final list = raw.whereType<String>().toList();
      if (kDebugMode) {
        debugPrint('[ClinicAccessResolver] role=$role → clinics=$list');
      }
      // Validate each ID against known constants
      final valid = list.where((id) => ClinicIds.all.contains(id)).toList();
      return List.unmodifiable(valid);
    }

    if (kDebugMode) {
      debugPrint('[ClinicAccessResolver] Unknown role=$role → []');
    }
    return const [];
  }

  /// Fallback: reads userType from Firestore when claims are absent/stale.
  ///
  /// Fallback: يقرأ `userType` من Firestore عند غياب Claims.
  Future<List<String>> _resolveFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return const [];

      final userTypeRaw = doc.data()!['userType'] as String?;
      final userType = userTypeRaw?.toUpperCase();

      if (userType == 'ADMIN_GLOBAL' || userType == 'ADMIN') {
        if (kDebugMode) {
          debugPrint(
            '[ClinicAccessResolver] Firestore fallback SUCCESS: userType=$userTypeRaw → all access',
          );
        }
        return List.unmodifiable(ClinicIds.all);
      }

      if (kDebugMode) {
        debugPrint(
          '[ClinicAccessResolver] Firestore fallback: userType=$userType → []',
        );
      }
      return const [];
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[ClinicAccessResolver] Firestore fallback error: $e');
        debugPrint('$st');
      }
      return const [];
    }
  }
}
