import 'package:wavego_driver/models/ride_model.dart';

class PaymentCompletionData {
  const PaymentCompletionData({
    required this.payment,
    required this.rideId,
    required this.passengerName,
  });

  final PaymentBreakdown payment;
  final String rideId;
  final String passengerName;
}
