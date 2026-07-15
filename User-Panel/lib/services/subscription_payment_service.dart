import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_user/models/membership_models.dart';
import 'package:wavego_user/services/cashfree/cashfree_checkout.dart';
import 'package:wavego_user/services/membership_service.dart';

class SubscriptionPaymentController {
  SubscriptionPaymentController(this._service);

  final MembershipSubscriptionService _service;

  Future<SubscriptionPlanModel> purchasePlan(
    SubscriptionPlanModel plan, {
    void Function()? onCheckoutOpened,
  }) async {
    if (plan.isFree) {
      return _service.selectPlan(plan.slug);
    }

    final checkout = await _service.createCheckout(plan.slug);
    if (!checkout.isReady) {
      throw StateError('Unable to start payment. Please try again.');
    }

    final payment = await openCashfreeCheckout(
      checkout,
      onOpened: onCheckoutOpened,
    );

    return _service.verifyPayment(
      planSlug: plan.slug,
      orderId: payment.orderId,
    );
  }
}

final subscriptionPaymentControllerProvider =
    Provider<SubscriptionPaymentController>((ref) {
  return SubscriptionPaymentController(
    ref.watch(membershipSubscriptionServiceProvider),
  );
});
