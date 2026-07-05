import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_user/core/constants/api_endpoints.dart';
import 'package:wavego_user/core/network/dio_client.dart';
import 'package:wavego_user/models/membership_models.dart';
import 'package:wavego_user/services/base_api_service.dart';

class StudentPassService extends BaseApiService {
  StudentPassService(super.dio);

  Future<StudentPassApplication?> getApplication() async {
    if (useMock) return null;

    final data = await get<Map<String, dynamic>>(
      ApiEndpoints.studentPass,
      parser: (raw) => raw as Map<String, dynamic>,
    );
    final application = data['application'];
    if (application is! Map<String, dynamic>) return null;
    return StudentPassApplication.fromJson(application);
  }

  Future<StudentPassApplication> submitApplication({
    required String aadharNumber,
    required String collegeName,
    required String aadharPhoto,
    required String studentIdPhoto,
  }) async {
    if (useMock) {
      return StudentPassApplication(
        id: 'mock-student-pass',
        aadharNumber: aadharNumber,
        collegeName: collegeName,
        status: 'pending',
        discountPercent: 20,
      );
    }

    final data = await post<Map<String, dynamic>>(
      ApiEndpoints.studentPass,
      data: {
        'aadhar_number': aadharNumber,
        'college_name': collegeName,
        'aadhar_photo': aadharPhoto,
        'student_id_photo': studentIdPhoto,
      },
      parser: (raw) => raw as Map<String, dynamic>,
    );
    return StudentPassApplication.fromJson(
      data['application'] as Map<String, dynamic>,
    );
  }
}

class MembershipSubscriptionService extends BaseApiService {
  MembershipSubscriptionService(super.dio);

  Map<String, dynamic> _extractCheckoutMap(Map<String, dynamic> data) {
    final direct = data['checkout'];
    if (direct is Map<String, dynamic>) return direct;
    final nested = data['data'];
    if (nested is Map<String, dynamic>) {
      final checkout = nested['checkout'];
      if (checkout is Map<String, dynamic>) return checkout;
    }
    return {};
  }

  Future<List<SubscriptionPlanModel>> listPlans() async {
    if (useMock) {
      return const [
        SubscriptionPlanModel(
          id: 'free',
          slug: 'free',
          name: 'Free',
          description: 'Essential rides at standard rates',
          priceLabel: '₹0',
          periodLabel: 'forever',
          benefits: ['Book rides anytime', 'Standard pricing', 'In-app support'],
          rideDiscountPercent: 0,
        ),
        SubscriptionPlanModel(
          id: 'plus',
          slug: 'plus',
          name: 'Plus',
          description: 'Save more on every trip',
          priceLabel: '₹99',
          periodLabel: '/month',
          benefits: [
            '5% off on every ride',
            'Priority booking',
            'No peak-hour surge up to 10%',
            '24/7 chat support',
          ],
          rideDiscountPercent: 5,
          isPopular: true,
        ),
      ];
    }

    final data = await get<Map<String, dynamic>>(
      ApiEndpoints.subscriptionPlans,
      parser: (raw) => raw as Map<String, dynamic>,
    );
    final plans = data['plans'] as List<dynamic>? ?? [];
    return plans
        .map((e) => SubscriptionPlanModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SubscriptionPlanModel> getActivePlan() async {
    if (useMock) {
      return const SubscriptionPlanModel(
        id: 'free',
        slug: 'free',
        name: 'Free',
        description: 'Essential rides at standard rates',
        priceLabel: '₹0',
        periodLabel: 'forever',
        benefits: ['Book rides anytime'],
        rideDiscountPercent: 0,
      );
    }

    final data = await get<Map<String, dynamic>>(
      ApiEndpoints.userSubscription,
      parser: (raw) => raw as Map<String, dynamic>,
    );
    final subscription = data['subscription'] as Map<String, dynamic>? ?? {};
    final plan = subscription['plan'] as Map<String, dynamic>? ?? {};
    return SubscriptionPlanModel.fromJson(plan);
  }

  Future<SubscriptionPlanModel> selectPlan(String planSlug) async {
    if (useMock) {
      final plans = await listPlans();
      return plans.firstWhere((plan) => plan.slug == planSlug, orElse: () => plans.first);
    }

    final data = await post<Map<String, dynamic>>(
      ApiEndpoints.userSubscription,
      data: {'plan_slug': planSlug},
      parser: (raw) => raw as Map<String, dynamic>,
    );
    final subscription = data['subscription'] as Map<String, dynamic>? ?? {};
    final plan = subscription['plan'] as Map<String, dynamic>? ?? {};
    return SubscriptionPlanModel.fromJson(plan);
  }

  Future<SubscriptionCheckoutSession> createCheckout(String planSlug) async {
    if (useMock) {
      return SubscriptionCheckoutSession(
        orderId: 'order_mock',
        amount: 9900,
        currency: 'INR',
        keyId: 'rzp_test_mock',
        planSlug: planSlug,
        planName: planSlug,
      );
    }

    final data = await post<Map<String, dynamic>>(
      ApiEndpoints.subscriptionCheckout,
      data: {'plan_slug': planSlug},
      parser: (raw) => raw as Map<String, dynamic>,
    );
    final checkout = _extractCheckoutMap(data);
    final session = SubscriptionCheckoutSession.fromJson(checkout);
    if (session.orderId.isEmpty || session.keyId.isEmpty) {
      throw StateError('Payment gateway is not ready. Please try again.');
    }
    return session;
  }

  Future<SubscriptionPlanModel> verifyPayment({
    required String planSlug,
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    if (useMock) {
      return selectPlan(planSlug);
    }

    final data = await post<Map<String, dynamic>>(
      ApiEndpoints.subscriptionVerifyPayment,
      data: {
        'plan_slug': planSlug,
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
      },
      parser: (raw) => raw as Map<String, dynamic>,
    );
    final subscription = data['subscription'] as Map<String, dynamic>? ?? {};
    final plan = subscription['plan'] as Map<String, dynamic>? ?? {};
    return SubscriptionPlanModel.fromJson(plan);
  }
}

final studentPassServiceProvider = Provider<StudentPassService>((ref) {
  return StudentPassService(ref.watch(dioClientProvider).dio);
});

final membershipSubscriptionServiceProvider =
    Provider<MembershipSubscriptionService>((ref) {
  return MembershipSubscriptionService(ref.watch(dioClientProvider).dio);
});

final studentPassProvider = FutureProvider<StudentPassApplication?>((ref) async {
  return ref.watch(studentPassServiceProvider).getApplication();
});

final membershipPlansProvider = FutureProvider<List<SubscriptionPlanModel>>((ref) async {
  return ref.watch(membershipSubscriptionServiceProvider).listPlans();
});

final activeMembershipPlanProvider = FutureProvider<SubscriptionPlanModel>((ref) async {
  return ref.watch(membershipSubscriptionServiceProvider).getActivePlan();
});

/// Instant UI after payment before the next network refresh completes.
final activeMembershipPlanOverrideProvider =
    StateProvider<SubscriptionPlanModel?>((ref) => null);

final resolvedActiveMembershipPlanProvider = Provider<AsyncValue<SubscriptionPlanModel>>((ref) {
  final override = ref.watch(activeMembershipPlanOverrideProvider);
  if (override != null) {
    return AsyncData(override);
  }
  return ref.watch(activeMembershipPlanProvider);
});

void applyActiveMembershipPlan(WidgetRef ref, SubscriptionPlanModel plan) {
  ref.read(activeMembershipPlanOverrideProvider.notifier).state = plan;
  ref.invalidate(activeMembershipPlanProvider);
  ref.invalidate(rideDiscountPercentProvider);
  ref.invalidate(membershipPlansProvider);
}

Future<SubscriptionPlanModel> refreshActiveMembershipPlan(WidgetRef ref) async {
  final plan = await ref.read(membershipSubscriptionServiceProvider).getActivePlan();
  ref.read(activeMembershipPlanOverrideProvider.notifier).state = plan;
  ref.invalidate(activeMembershipPlanProvider);
  ref.invalidate(rideDiscountPercentProvider);
  return plan;
}

final rideDiscountPercentProvider = FutureProvider<double>((ref) async {
  try {
    final pass = await ref.watch(studentPassProvider.future);
    final plan = await ref.watch(activeMembershipPlanProvider.future);
    final studentDiscount = pass?.isApproved == true ? pass!.discountPercent : 0.0;
    final subscriptionDiscount = plan.rideDiscountPercent;
    return studentDiscount > subscriptionDiscount ? studentDiscount : subscriptionDiscount;
  } catch (_) {
    return 0;
  }
});
