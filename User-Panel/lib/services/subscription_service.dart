import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_user/core/constants/app_constants.dart';
import 'package:wavego_user/core/storage/local_storage_service.dart';
import 'package:wavego_user/data/subscription_plans.dart';

class SubscriptionService {
  SubscriptionService(this._storage);

  final LocalStorageService _storage;

  String getActivePlanId() =>
      _storage.getString(AppConstants.subscriptionPlanKey) ?? 'free';

  SubscriptionPlan getActivePlan() => subscriptionPlanById(getActivePlanId());

  Future<void> setActivePlan(String planId) async {
    await _storage.setString(AppConstants.subscriptionPlanKey, planId);
  }
}

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService(ref.watch(localStorageProvider));
});

final activeSubscriptionPlanProvider =
    StateNotifierProvider<ActiveSubscriptionNotifier, SubscriptionPlan>((ref) {
  return ActiveSubscriptionNotifier(ref.watch(subscriptionServiceProvider));
});

class ActiveSubscriptionNotifier extends StateNotifier<SubscriptionPlan> {
  ActiveSubscriptionNotifier(this._service)
      : super(_service.getActivePlan());

  final SubscriptionService _service;

  Future<void> selectPlan(String planId) async {
    await _service.setActivePlan(planId);
    state = subscriptionPlanById(planId);
  }
}
