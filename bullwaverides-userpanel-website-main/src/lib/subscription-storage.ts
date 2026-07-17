import { getSubscriptionPlan } from "@/data/subscription-plans";

const SUBSCRIPTION_PLAN_KEY = "wavego-subscription-plan";

export function getActiveSubscriptionPlanId(): string {
  if (typeof window === "undefined") return "free";
  return sessionStorage.getItem(SUBSCRIPTION_PLAN_KEY) ?? "free";
}

export function getActiveSubscriptionPlan() {
  return getSubscriptionPlan(getActiveSubscriptionPlanId());
}

export function setActiveSubscriptionPlan(planId: string) {
  if (typeof window === "undefined") return;
  sessionStorage.setItem(SUBSCRIPTION_PLAN_KEY, planId);
  window.dispatchEvent(new Event("wavego-subscription-update"));
}
