import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

bool isProfileEditMode(BuildContext context) {
  return GoRouterState.of(context).uri.queryParameters['from'] == 'profile';
}

void finishOnboardingStep(
  BuildContext context, {
  required String defaultRoute,
  bool useGo = false,
}) {
  if (isProfileEditMode(context)) {
    context.pop();
    return;
  }
  if (useGo) {
    context.go(defaultRoute);
  } else {
    context.push(defaultRoute);
  }
}

String? onboardingDocType(BuildContext context) {
  return GoRouterState.of(context).uri.queryParameters['type'];
}
