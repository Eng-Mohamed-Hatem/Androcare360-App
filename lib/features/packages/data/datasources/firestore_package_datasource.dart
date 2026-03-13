/// FirestorePackageDatasource — مصدر بيانات Firestore للباقات (Data Layer)
///
/// يُنفِّذ جميع عمليات القراءة والكتابة في Firestore المتعلقة بالباقات.
/// **لا يحتوي على أي منطق Firebase Storage** — ذلك مفصول في [FirebaseStoragePackageDatasource].
///
/// **English**: Data-layer Firestore datasource (R5 — SRP). Handles only
/// Firestore operations for clinic packages, patient purchases, and document
/// metadata. Delegates Storage uploads to [FirebaseStoragePackageDatasource].
///
/// All queries are scoped by `clinicId` (Clinic Isolation rule).
/// Uses injected `FirebaseFirestore` (databaseId: 'elajtech' — never .instance).
///
/// **Spec**: tasks.md T016a, plan.md §Datasource split (R5).
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/core/di/firebase_module.dart' show FirebaseModule;
import 'package:elajtech/features/packages/data/datasources/firebase_storage_package_datasource.dart'
    show FirebaseStoragePackageDatasource;
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Firestore-only datasource for all package-related collections.
///
/// **English**
/// Annotated `@lazySingleton`. Injected `FirebaseFirestore` is the one
/// configured for `databaseId: 'elajtech'` via [FirebaseModule].
///
/// All query limits follow CHK049:
/// - Patient category list: `limit(50)`
/// - Admin lists: `limit(20)` with cursor-based pagination
/// - Documents: `limit(50)`
///
/// **Arabic**
/// مصدر بيانات Firestore حصرًا. يُحقَن تلقائيًا عبر GetIt.
/// جميع حدود الاستعلامات موثَّقة في CHK049.
@lazySingleton
class FirestorePackageDatasource {
  /// Creates a [FirestorePackageDatasource] with the injected Firestore instance.
  ///
  /// يُنشئ مصدر البيانات مع نسخة Firestore المُحقَنة (databaseId: 'elajtech').
  FirestorePackageDatasource(this._firestore);

  final FirebaseFirestore _firestore;

  // ── Collection path helpers ────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> _clinicPackages(String clinicId) =>
      _firestore.collection('clinics').doc(clinicId).collection('packages');

  CollectionReference<Map<String, dynamic>> _patientPackages(
    String patientId,
  ) => _firestore.collection('patients').doc(patientId).collection('packages');

  CollectionReference<Map<String, dynamic>> _patientDocuments(
    String patientId,
    String patientPackageId,
  ) => _firestore
      .collection('patients')
      .doc(patientId)
      .collection('packages')
      .doc(patientPackageId)
      .collection('documents');

  // ── Clinic Packages ────────────────────────────────────────────────────────

  /// Creates a new clinic package document.
  /// Returns the document ID.
  Future<String> createClinicPackage({
    required String clinicId,
    required Map<String, dynamic> data,
    String? packageId,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '[FirestorePackageDatasource] createClinicPackage clinicId=$clinicId pkgId=$packageId',
      );
    }
    final collection = _clinicPackages(clinicId);
    if (packageId != null && packageId.isNotEmpty) {
      await collection.doc(packageId).set(data);
      return packageId;
    } else {
      final doc = await collection.add(data);
      return doc.id;
    }
  }

  /// Updates an existing clinic package document.
  Future<void> updateClinicPackage({
    required String clinicId,
    required String packageId,
    required Map<String, dynamic> data,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '[FirestorePackageDatasource] updateClinicPackage clinicId=$clinicId pkgId=$packageId',
      );
    }
    await _clinicPackages(clinicId).doc(packageId).update(data);
  }

  /// Fetches a single clinic package document by [packageId].
  ///
  /// **Arabic**: يجلب مستند باقة واحدة من `clinics/{clinicId}/packages/{packageId}`.
  Future<DocumentSnapshot<Map<String, dynamic>>> fetchPackageById({
    required String clinicId,
    required String packageId,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '[FirestorePackageDatasource] fetchPackageById clinicId=$clinicId pkgId=$packageId',
      );
    }
    return _clinicPackages(clinicId).doc(packageId).get();
  }

  /// Fetches all ACTIVE packages for [clinicId] in [category] — patient view.
  ///
  /// Ordered by `isFeatured` DESC then `displayOrder` ASC, limit 50.
  /// Uses Index 1: `clinicId + category + status + displayOrder`.
  ///
  /// **Arabic**: يجلب الباقات النشطة للمريض. الحد الأقصى 50 (Index 1).
  Future<QuerySnapshot<Map<String, dynamic>>> fetchCategoryPackages({
    required String clinicId,
    required String category,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '[FirestorePackageDatasource] fetchCategoryPackages $clinicId/$category',
      );
    }
    return _clinicPackages(clinicId)
        .where('category', isEqualTo: category)
        .where('status', isEqualTo: 'ACTIVE')
        .orderBy('isFeatured', descending: true)
        .orderBy('displayOrder')
        .limit(50)
        .get();
  }

  /// Fetches all packages for [clinicId] with cursor pagination — admin view.
  ///
  /// Includes all statuses. Page size = [limit] (default 20, CHK049).
  ///
  /// **Arabic**: جميع الباقات للأدمن مع ترقيم صفحات. حجم الصفحة 20.
  Future<QuerySnapshot<Map<String, dynamic>>> fetchClinicPackagesForAdmin({
    required String clinicId,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '[FirestorePackageDatasource] fetchClinicPackagesForAdmin $clinicId '
        'cursor=${lastDocument?.id}',
      );
    }
    var query = _clinicPackages(
      clinicId,
    ).orderBy('displayOrder').limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    return query.get();
  }

  // ── Patient Packages ───────────────────────────────────────────────────────

  /// Creates a new patient package purchase document.
  ///
  /// Returns the new document ID on success.
  ///
  /// **Arabic**: يُنشئ سجل شراء جديد للمريض ويُعيد معرف المستند الجديد.
  Future<String> createPatientPackage({
    required String patientId,
    required Map<String, dynamic> data,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '[FirestorePackageDatasource] createPatientPackage patientId=$patientId '
        'pkgId=${data['packageId']} txn=${data['paymentTransactionId']}',
      );
    }
    final ref = await _patientPackages(patientId).add(data);
    return ref.id;
  }

  /// Fetches all patient packages for [patientId] — raw snapshots.
  ///
  /// **Arabic**: يجلب جميع مشتريات المريض (snapshots خام).
  Future<QuerySnapshot<Map<String, dynamic>>> fetchPatientPackages({
    required String patientId,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '[FirestorePackageDatasource] fetchPatientPackages patientId=$patientId',
      );
    }
    return _patientPackages(
      patientId,
    ).orderBy('purchaseDate', descending: true).get();
  }

  /// Fetches a single patient package — raw snapshot (projection applied in
  /// model layer).
  ///
  /// **Arabic**: يجلب سجل شراء واحد (snapshot خام — التصفية في طبقة النماذج).
  Future<DocumentSnapshot<Map<String, dynamic>>> fetchPatientPackageByIdRaw({
    required String patientId,
    required String patientPackageId,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '[FirestorePackageDatasource] fetchPatientPackageByIdRaw '
        'patientId=$patientId ppId=$patientPackageId',
      );
    }
    return _patientPackages(patientId).doc(patientPackageId).get();
  }

  /// Checks for an ACTIVE or PENDING purchase of [packageId] by [patientId].
  ///
  /// Used by `PurchasePackageUseCase` for the duplicate-purchase guard (CHK023).
  /// Uses Index 5: `patientId + packageId + status`.
  ///
  /// **Arabic**: يبحث عن سجل نشط أو معلَّق للباقة للحماية من الشراء المكرر.
  Future<QuerySnapshot<Map<String, dynamic>>> findActiveOrPendingByPackageId({
    required String patientId,
    required String packageId,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '[FirestorePackageDatasource] findActiveOrPendingByPackageId '
        'patientId=$patientId pkgId=$packageId',
      );
    }
    return _patientPackages(patientId)
        .where('packageId', isEqualTo: packageId)
        .where('status', whereIn: ['ACTIVE', 'PENDING'])
        .limit(1)
        .get();
  }

  /// Fetches paginated patient packages — admin view.
  ///
  /// Page size = [limit] (default 20, CHK049).
  ///
  /// **Arabic**: قائمة مُقسَّمة لمشتريات المريض للأدمن.
  Future<QuerySnapshot<Map<String, dynamic>>> fetchPatientPackagesForAdmin({
    required String patientId,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '[FirestorePackageDatasource] fetchPatientPackagesForAdmin '
        'patientId=$patientId cursor=${lastDocument?.id}',
      );
    }
    var query = _patientPackages(
      patientId,
    ).orderBy('purchaseDate', descending: true).limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    return query.get();
  }

  /// Updates the notes field for a specific patient package.
  ///
  /// **Arabic**: يُحدِّث حقل الملاحظات لسجل شراء مريض محدد.
  Future<void> updatePatientPackageNotes({
    required String patientId,
    required String patientPackageId,
    required String notes,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '[FirestorePackageDatasource] updatePatientPackageNotes '
        'patientId=$patientId ppId=$patientPackageId',
      );
    }
    await _patientPackages(patientId).doc(patientPackageId).update({
      'notes': notes,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Package Documents ──────────────────────────────────────────────────────

  /// Creates a package document metadata record in Firestore.
  ///
  /// Called after the file is successfully uploaded to Storage.
  ///
  /// **Arabic**: يُنشئ سجل بيانات واصفة للمستند بعد رفع الملف إلى Storage.
  Future<DocumentReference<Map<String, dynamic>>> createDocumentRecord({
    required String patientId,
    required String patientPackageId,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '[FirestorePackageDatasource] createDocumentRecord '
        'patientId=$patientId type=${data['documentType']}',
      );
    }
    final docRef = _patientDocuments(patientId, patientPackageId).doc(
      documentId,
    );
    await docRef.set(data);
    return docRef;
  }

  /// Fetches all documents for [patientPackageId] of [patientId].
  ///
  /// Uses Index 6: `patientId + patientPackageId`. Limit = 50.
  ///
  /// **Arabic**: يجلب جميع مستندات سجل الشراء (Index 6). الحد 50.
  Future<QuerySnapshot<Map<String, dynamic>>> fetchDocumentsByPatientPackage({
    required String patientId,
    required String patientPackageId,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '[FirestorePackageDatasource] fetchDocumentsByPatientPackage '
        'patientId=$patientId ppId=$patientPackageId',
      );
    }
    return _patientDocuments(patientId, patientPackageId)
        .orderBy('uploadedAt', descending: true)
        .limit(50)
        .get();
  }

  /// Streams all documents for [patientPackageId] of [patientId].
  ///
  /// **English**: Realtime stream for admin and patient views under canonical
  /// path `patients/{patientId}/packages/{patientPackageId}/documents`.
  ///
  /// **Arabic**: بث لحظي لمستندات الباقة من المسار القياسي داخل
  /// `patients/{patientId}/packages/{patientPackageId}/documents`.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamDocumentsByPatientPackage({
    required String patientId,
    required String patientPackageId,
  }) {
    return _patientDocuments(patientId, patientPackageId)
        .orderBy('uploadedAt', descending: true)
        .limit(50)
        .snapshots();
  }
}
