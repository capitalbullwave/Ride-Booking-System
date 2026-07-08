import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as js_util;

import 'package:wavego_user/models/membership_models.dart';

import 'razorpay_checkout_stub.dart';

Future<void> _ensureRazorpayScript() {
  if (js.context.hasProperty('Razorpay')) {
    return Future.value();
  }

  final existing = html.document.getElementById('razorpay-checkout-js');
  if (existing != null) {
    return Future.value();
  }

  final completer = Completer<void>();
  final script = html.ScriptElement()
    ..id = 'razorpay-checkout-js'
    ..src = 'https://checkout.razorpay.com/v1/checkout.js'
    ..async = true;
  script.onLoad.listen((_) => completer.complete());
  script.onError.listen((_) => completer.completeError('Unable to load Razorpay checkout'));
  html.document.body?.append(script);
  return completer.future;
}

Map<String, String> _responseFields(dynamic response) {
  try {
    final dartified = js_util.dartify(response);
    if (dartified is Map) {
      return dartified.map(
        (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
      );
    }
  } catch (_) {}

  const keys = [
    'razorpay_order_id',
    'razorpay_payment_id',
    'razorpay_signature',
  ];
  final fields = <String, String>{};
  for (final key in keys) {
    final value = js_util.getProperty(response, key);
    if (value != null) {
      fields[key] = value.toString();
    }
  }
  return fields;
}

RazorpayCheckoutResult? _parsePaymentResponse(
  dynamic response,
  String fallbackOrderId,
) {
  final fields = _responseFields(response);
  final orderId = (fields['razorpay_order_id'] ?? '').trim().isNotEmpty
      ? fields['razorpay_order_id']!.trim()
      : fallbackOrderId;
  final paymentId = fields['razorpay_payment_id']?.trim();
  final signature = fields['razorpay_signature']?.trim();
  if (paymentId == null ||
      paymentId.isEmpty ||
      signature == null ||
      signature.isEmpty) {
    return null;
  }
  return RazorpayCheckoutResult(
    orderId: orderId,
    paymentId: paymentId,
    signature: signature,
  );
}

Future<RazorpayCheckoutResult> openRazorpayCheckout(
  SubscriptionCheckoutSession checkout, {
  RazorpayCheckoutOpened? onOpened,
  void Function(RazorpayCheckoutResult payment)? onPaymentSuccess,
}) async {
  if (checkout.keyId.isEmpty) {
    throw StateError('Razorpay key is missing. Please restart the backend server.');
  }

  await _ensureRazorpayScript();

  final completer = Completer<RazorpayCheckoutResult>();
  var paymentSucceeded = false;
  Timer? dismissTimer;

  void completeSuccess(RazorpayCheckoutResult result) {
    if (paymentSucceeded) return;
    paymentSucceeded = true;
    dismissTimer?.cancel();
    onPaymentSuccess?.call(result);
    if (!completer.isCompleted) {
      completer.complete(result);
    }
  }

  void completeFailure(String message) {
    if (paymentSucceeded || completer.isCompleted) return;
    completer.completeError(message);
  }

  final options = js.JsObject.jsify({
    'key': checkout.keyId,
    'amount': checkout.amount,
    'currency': checkout.currency,
    'order_id': checkout.orderId,
    'name': 'Bull Wave Rides',
    'description': checkout.planName,
    'prefill': {
      if (checkout.contact != null) 'contact': checkout.contact,
      if (checkout.email != null) 'email': checkout.email,
      if (checkout.customerName != null) 'name': checkout.customerName,
    },
  });

  options['handler'] = js_util.allowInterop((response) {
    try {
      final parsed = _parsePaymentResponse(response, checkout.orderId);
      if (parsed == null) {
        completeFailure('Payment response incomplete');
        return;
      }
      completeSuccess(parsed);
    } catch (error) {
      completeFailure('Payment response error: $error');
    }
  });

  options['modal'] = js.JsObject.jsify({
    'ondismiss': js_util.allowInterop(() {
      dismissTimer?.cancel();
      dismissTimer = Timer(const Duration(seconds: 2), () {
        completeFailure('Payment cancelled');
      });
    }),
  });

  final razorpayCtor = js.context['Razorpay'];
  if (razorpayCtor == null) {
    throw StateError('Razorpay checkout is unavailable');
  }

  final instance = js.JsObject(razorpayCtor, [options]);
  instance.callMethod('open');
  onOpened?.call();

  return completer.future;
}
