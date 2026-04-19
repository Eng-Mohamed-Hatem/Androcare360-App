import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/core/constants/app_constants.dart';
import 'package:elajtech/features/patient/self_assessment/data/models/quiz_models.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

class AssessmentReferralTrackingService {
  AssessmentReferralTrackingService({FirebaseFirestore? firestore})
    : _firestore = firestore;

  factory AssessmentReferralTrackingService.maybeCreate() {
    if (!GetIt.I.isRegistered<FirebaseFirestore>()) {
      return AssessmentReferralTrackingService();
    }

    return AssessmentReferralTrackingService(
      firestore: GetIt.I<FirebaseFirestore>(),
    );
  }

  final FirebaseFirestore? _firestore;

  Future<void> logEvent({
    required AssessmentReferralContext context,
    required String eventName,
    required String stage,
    String status = 'in_progress',
    Map<String, dynamic>? metadata,
  }) async {
    if (_firestore == null) {
      return;
    }

    final now = DateTime.now();
    final timestamp = Timestamp.fromDate(now);

    final payload = <String, dynamic>{
      'id': context.referralSessionId,
      'referralSessionId': context.referralSessionId,
      'patientId': context.patientId,
      'assessmentId': context.assessmentId,
      'assessmentTitle': context.assessmentTitle,
      'resultBand': context.resultBand,
      'rawScore': context.rawScore,
      'referralTargetKey': context.referralTargetKey,
      'sourceScreen': context.sourceScreen,
      'specializationHints': context.specializationHints,
      'assessmentCompletedAt': Timestamp.fromDate(context.completedAt),
      'status': status,
      'currentStage': stage,
      'updatedAt': timestamp,
      'events': FieldValue.arrayUnion([
        <String, dynamic>{
          'eventName': eventName,
          'stage': stage,
          'status': status,
          'timestamp': timestamp,
          if (metadata != null && metadata.isNotEmpty) 'metadata': metadata,
        },
      ]),
      ..._stageFields(
        eventName: eventName,
        stage: stage,
        timestamp: timestamp,
        metadata: metadata,
      ),
    };

    try {
      await _firestore
          .collection(AppConstants.collections.assessmentReferralEvents)
          .doc(context.referralSessionId)
          .set(payload, SetOptions(merge: true));
    } on Exception catch (error, stackTrace) {
      debugPrint(
        'AssessmentReferralTrackingService log failed: $error\n$stackTrace',
      );
    }
  }

  Map<String, dynamic> _stageFields({
    required String eventName,
    required String stage,
    required Timestamp timestamp,
    Map<String, dynamic>? metadata,
  }) {
    switch (eventName) {
      case 'landing_viewed':
        return {'landingViewedAt': timestamp};
      case 'continue_to_doctors':
        return {'doctorSelectionStartedAt': timestamp};
      case 'doctor_selection_viewed':
        return {'doctorSelectionViewedAt': timestamp};
      case 'doctor_selected':
        return {
          'doctorSelectedAt': timestamp,
          if (metadata != null && metadata['doctorId'] != null)
            'selectedDoctorId': metadata['doctorId'],
          if (metadata != null && metadata['doctorName'] != null)
            'selectedDoctorName': metadata['doctorName'],
        };
      case 'booking_viewed':
        return {'bookingViewedAt': timestamp};
      case 'booking_completed':
        return {
          'bookingCompletedAt': timestamp,
          'status': 'completed',
          if (metadata != null && metadata['appointmentId'] != null)
            'appointmentId': metadata['appointmentId'],
        };
      case 'referral_abandoned':
        return {
          'abandonedAt': timestamp,
          'abandonedStage': stage,
          'status': 'abandoned',
        };
    }

    return <String, dynamic>{};
  }
}
