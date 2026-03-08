import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/features/doctor/medical_records/domain/entities/physiotherapy_emr.dart';
import 'package:flutter/foundation.dart';

/// Physical Therapy EMR Model for Firestore serialization
///
/// Handles conversion between Firestore documents and PhysiotherapyEMR entities
class PhysiotherapyEMRModel {
  /// Convert PhysiotherapyEMR entity to Firestore document
  static Map<String, dynamic> toFirestore(PhysiotherapyEMR emr) {
    return {
      'id': emr.id,
      'patientId': emr.patientId,
      'doctorId': emr.doctorId,
      'doctorName': emr.doctorName,
      'appointmentId': emr.appointmentId,
      'visitDate': Timestamp.fromDate(emr.visitDate),
      'createdAt': Timestamp.fromDate(emr.createdAt),

      // 8 Checklist Sections
      'basics': emr.basics,
      'painAssessment': emr.painAssessment,
      'functionalAssessment': emr.functionalAssessment,
      'systemsReview': emr.systemsReview,
      'rangeOfMotion': emr.rangeOfMotion,
      'strengthAssessment': emr.strengthAssessment,
      'devicesEquipment': emr.devicesEquipment,
      'treatmentPlan': emr.treatmentPlan,

      // Unified Text Fields
      'primaryDiagnosis': emr.primaryDiagnosis,
      'managementPlan': emr.managementPlan,

      // Metadata
      'specialization': emr.specialization,
    };
  }

  /// Convert Firestore document to PhysiotherapyEMR entity
  static PhysiotherapyEMR fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    // Null safety checks for snapshot and data
    if (!snapshot.exists) {
      throw ArgumentError('Document does not exist');
    }

    final data = snapshot.data();
    if (data == null) {
      throw ArgumentError('Document data is null');
    }

    // Debug logging
    if (kDebugMode) {
      debugPrint('📄 [PhysiotherapyEMRModel] Parsing document: ${snapshot.id}');
      debugPrint('   Data keys: ${data.keys.join(", ")}');
    }

    try {
      return PhysiotherapyEMR(
        id: data['id'] as String,
        patientId: data['patientId'] as String,
        doctorId: data['doctorId'] as String,
        doctorName: data['doctorName'] as String,
        appointmentId: data['appointmentId'] as String,
        visitDate: (data['visitDate'] as Timestamp).toDate(),
        createdAt: (data['createdAt'] as Timestamp).toDate(),

        // 8 Checklist Sections
        basics: _parseMap(data['basics']),
        painAssessment: _parseMap(data['painAssessment']),
        functionalAssessment: _parseMap(data['functionalAssessment']),
        systemsReview: _parseMap(data['systemsReview']),
        rangeOfMotion: _parseMap(data['rangeOfMotion']),
        strengthAssessment: _parseMap(data['strengthAssessment']),
        devicesEquipment: _parseMap(data['devicesEquipment']),
        treatmentPlan: _parseMap(data['treatmentPlan']),

        // Unified Text Fields
        primaryDiagnosis: data['primaryDiagnosis'] as String?,
        managementPlan: data['managementPlan'] as String?,

        // Metadata
        specialization:
            data['specialization'] as String? ??
            'عيادة العلاج الطبيعي والتأهيل',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [PhysiotherapyEMRModel] Error parsing document: $e');
        debugPrint('   Document data: $data');
      }
      rethrow;
    }
  }

  /// Helper to parse Map<String, List<String>> from Firestore
  static Map<String, List<String>> _parseMap(dynamic data) {
    if (data == null) return <String, List<String>>{};

    final map = data as Map<String, dynamic>;
    return map.map(
      (key, value) => MapEntry(
        key,
        (value as List<dynamic>).map((e) => e as String).toList(),
      ),
    );
  }
}
