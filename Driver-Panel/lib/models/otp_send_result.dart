import 'package:wavego_driver/models/api_response.dart';

class OtpSendResult {
  const OtpSendResult({
    required this.response,
    this.devOtpHint,
  });

  final OtpResponse response;
  final String? devOtpHint;
}
