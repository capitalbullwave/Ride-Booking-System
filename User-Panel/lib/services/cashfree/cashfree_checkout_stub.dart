import 'cashfree_checkout_models.dart';

export 'cashfree_checkout_models.dart';

typedef CashfreeCheckoutOpened = void Function();
typedef CashfreePaymentSuccess = void Function(CashfreeCheckoutResult payment);

Future<CashfreeCheckoutResult> openCashfreeCheckout(
  CashfreeCheckoutSession checkout, {
  CashfreeCheckoutOpened? onOpened,
  CashfreePaymentSuccess? onPaymentSuccess,
}) {
  throw UnsupportedError('Cashfree checkout is not available on this platform');
}
