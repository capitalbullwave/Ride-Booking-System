import 'dart:async';

import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

import 'cashfree_checkout_models.dart';
import 'cashfree_checkout_stub.dart' show CashfreeCheckoutOpened, CashfreePaymentSuccess;

export 'cashfree_checkout_models.dart';
export 'cashfree_checkout_stub.dart' show CashfreeCheckoutOpened, CashfreePaymentSuccess;

Future<CashfreeCheckoutResult> openCashfreeCheckout(
  CashfreeCheckoutSession checkout, {
  CashfreeCheckoutOpened? onOpened,
  CashfreePaymentSuccess? onPaymentSuccess,
}) async {
  if (!checkout.isReady) {
    throw StateError('Cashfree checkout session is incomplete. Please try again.');
  }

  final completer = Completer<CashfreeCheckoutResult>();
  final gateway = CFPaymentGatewayService();

  void finishSuccess(String orderId) {
    if (completer.isCompleted) return;
    final result = CashfreeCheckoutResult(orderId: orderId);
    onPaymentSuccess?.call(result);
    completer.complete(result);
  }

  void finishError(Object error) {
    if (completer.isCompleted) return;
    completer.completeError(error);
  }

  gateway.setCallback(
    (orderId) => finishSuccess(orderId),
    (CFErrorResponse errorResponse, String orderId) {
      finishError(
        StateError(errorResponse.getMessage() ?? 'Cashfree payment failed'),
      );
    },
  );

  try {
    final environment = checkout.environment == 'production'
        ? CFEnvironment.PRODUCTION
        : CFEnvironment.SANDBOX;

    final session = CFSessionBuilder()
        .setEnvironment(environment)
        .setOrderId(checkout.orderId)
        .setPaymentSessionId(checkout.paymentSessionId)
        .build();

    final payment = CFWebCheckoutPaymentBuilder().setSession(session).build();
    onOpened?.call();
    gateway.doPayment(payment);
  } on CFException catch (e) {
    finishError(StateError(e.message ?? 'Unable to open Cashfree checkout'));
  } catch (e) {
    finishError(e);
  }

  return completer.future;
}
