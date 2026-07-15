import 'dart:async';
import 'dart:js' as js;
import 'dart:html' as html;

import 'cashfree_checkout_models.dart';
import 'cashfree_checkout_stub.dart' show CashfreeCheckoutOpened, CashfreePaymentSuccess;

export 'cashfree_checkout_models.dart';
export 'cashfree_checkout_stub.dart' show CashfreeCheckoutOpened, CashfreePaymentSuccess;

Future<void> _ensureCashfreeScript() {
  if (js.context.hasProperty('Cashfree')) {
    return Future.value();
  }

  final existing = html.document.getElementById('cashfree-checkout-js');
  if (existing != null) {
    final completer = Completer<void>();
    // Script may still be loading
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (js.context.hasProperty('Cashfree')) {
        timer.cancel();
        if (!completer.isCompleted) completer.complete();
      }
    });
    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw StateError('Unable to load Cashfree checkout'),
    );
  }

  final completer = Completer<void>();
  final script = html.ScriptElement()
    ..id = 'cashfree-checkout-js'
    ..src = 'https://sdk.cashfree.com/js/v3/cashfree.js'
    ..async = true;
  script.onLoad.listen((_) => completer.complete());
  script.onError.listen(
    (_) => completer.completeError('Unable to load Cashfree checkout'),
  );
  html.document.body?.append(script);
  return completer.future;
}

Future<CashfreeCheckoutResult> openCashfreeCheckout(
  CashfreeCheckoutSession checkout, {
  CashfreeCheckoutOpened? onOpened,
  CashfreePaymentSuccess? onPaymentSuccess,
}) async {
  if (!checkout.isReady) {
    throw StateError('Cashfree checkout session is incomplete. Please try again.');
  }

  await _ensureCashfreeScript();

  final cashfreeFn = js.context['Cashfree'];
  if (cashfreeFn == null) {
    throw StateError('Cashfree checkout is unavailable');
  }

  final mode = checkout.environment == 'production' ? 'production' : 'sandbox';
  final cashfree = cashfreeFn.apply([
    js.JsObject.jsify({'mode': mode}),
  ]);

  onOpened?.call();

  final completer = Completer<CashfreeCheckoutResult>();
  final options = js.JsObject.jsify({
    'paymentSessionId': checkout.paymentSessionId,
    'redirectTarget': '_modal',
  });

  void succeed() {
    if (completer.isCompleted) return;
    final payment = CashfreeCheckoutResult(orderId: checkout.orderId);
    onPaymentSuccess?.call(payment);
    completer.complete(payment);
  }

  void fail(Object error) {
    if (!completer.isCompleted) {
      completer.completeError(error);
    }
  }

  try {
    final promise = cashfree.callMethod('checkout', [options]);
    promise.callMethod('then', [
      js.allowInterop((result) {
        try {
          if (result == null) {
            succeed();
            return;
          }
          final dyn = js.JsObject.fromBrowserObject(result);
          if (dyn.hasProperty('error') && dyn['error'] != null) {
            fail(StateError('Payment cancelled or failed'));
            return;
          }
          succeed();
        } catch (_) {
          succeed();
        }
      }),
    ]);
    promise.callMethod('catch', [
      js.allowInterop((_) {
        fail(StateError('Cashfree payment failed'));
      }),
    ]);
  } catch (e) {
    fail(e);
  }

  return completer.future;
}
