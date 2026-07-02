import 'package:wavego_user/models/user_models.dart';

class OtpSendResult {
  const OtpSendResult({
    required this.response,
    this.devOtpHint,
  });

  final OtpResponse response;
  final String? devOtpHint;
}
