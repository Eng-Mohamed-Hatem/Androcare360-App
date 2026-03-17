/// Result of an admin action performed on a doctor application.
library;

enum DoctorApplicationActionStatus {
  approved,
  rejected,
  alreadyApproved,
  alreadyRejected,
}

class DoctorApplicationActionResult {
  const DoctorApplicationActionResult({
    required this.status,
    required this.message,
  });

  final DoctorApplicationActionStatus status;
  final String message;

  bool get isSuccess =>
      status == DoctorApplicationActionStatus.approved ||
      status == DoctorApplicationActionStatus.rejected;

  bool get shouldRemoveFromPending => true;
}
