/// بيانات التحقق من الهاتف التي تحتوي على معرّف التحقق ورمز إعادة الإرسال.
/// Phone verification data containing verification ID and resend token.
class PhoneVerificationData {
  const PhoneVerificationData({
    required this.verificationId,
    this.resendToken,
    this.isAutoVerified = false,
  });
  final String verificationId;
  final int? resendToken;
  final bool isAutoVerified;
}
