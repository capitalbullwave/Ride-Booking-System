import 'package:wavego_user/models/membership_models.dart';

class RazorpayCheckoutResult {
  const RazorpayCheckoutResult({
    required this.orderId,
    required this.paymentId,
    required this.signature,
  });

  final String orderId;
  final String paymentId;
  final String signature;
}

typedef RazorpayCheckoutOpened = void Function();
typedef RazorpayPaymentSuccess = void Function(RazorpayCheckoutResult payment);

Future<RazorpayCheckoutResult> openRazorpayCheckout(
  SubscriptionCheckoutSession checkout, {
  RazorpayCheckoutOpened? onOpened,
  RazorpayPaymentSuccess? onPaymentSuccess,
}) {
  throw UnsupportedError('Razorpay checkout is not available on this platform');
}
