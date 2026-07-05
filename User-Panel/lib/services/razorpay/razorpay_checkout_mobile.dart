import 'dart:async';

import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:wavego_user/models/membership_models.dart';

import 'razorpay_checkout_stub.dart';

Future<RazorpayCheckoutResult> openRazorpayCheckout(
  SubscriptionCheckoutSession checkout, {
  RazorpayCheckoutOpened? onOpened,
  RazorpayPaymentSuccess? onPaymentSuccess,
}) async {
  if (checkout.keyId.isEmpty) {
    throw StateError('Razorpay key is missing. Please restart the backend server.');
  }

  final razorpay = Razorpay();
  final completer = Completer<RazorpayCheckoutResult>();

  void cleanup() {
    razorpay.clear();
  }

  void onSuccess(PaymentSuccessResponse response) {
    cleanup();
    final orderId = response.orderId ?? checkout.orderId;
    final paymentId = response.paymentId;
    final signature = response.signature;
    if (orderId.isEmpty || paymentId.isEmpty || signature.isEmpty) {
      if (!completer.isCompleted) {
        completer.completeError('Payment response incomplete');
      }
      return;
    }
    if (!completer.isCompleted) {
      final result = RazorpayCheckoutResult(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
      );
      onPaymentSuccess?.call(result);
      completer.complete(result);
    }
  }

  void onError(PaymentFailureResponse response) {
    cleanup();
    if (completer.isCompleted) return;
    final message = response.message?.trim();
    completer.completeError(
      message != null && message.isNotEmpty ? message : 'Payment cancelled',
    );
  }

  razorpay
    ..on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess)
    ..on(Razorpay.EVENT_PAYMENT_ERROR, onError);

  final options = <String, dynamic>{
    'key': checkout.keyId,
    'amount': checkout.amount,
    'currency': checkout.currency,
    'order_id': checkout.orderId,
    'name': 'Fast Bull',
    'description': checkout.planName,
    'prefill': {
      if (checkout.contact != null) 'contact': checkout.contact,
      if (checkout.email != null) 'email': checkout.email,
      if (checkout.customerName != null) 'name': checkout.customerName,
    },
  };

  try {
    razorpay.open(options);
    onOpened?.call();
  } catch (error) {
    cleanup();
    if (!completer.isCompleted) {
      completer.completeError(error);
    }
  }

  return completer.future;
}
