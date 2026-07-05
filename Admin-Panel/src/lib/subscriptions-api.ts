import { apiFetch } from "@/lib/api";

export interface SubscriptionPlanItem {
  id: string;
  slug: string;
  name: string;
  description: string;
  price: number;
  price_label: string;
  period_label: string;
  benefits: string[];
  ride_discount_percent: number;
  is_popular: boolean;
  is_active: boolean;
  sort_order: number;
  subscriber_count?: number;
}

export interface SubscriptionPlanBreakdown {
  plan_id: string;
  plan_name: string;
  slug: string;
  subscriber_count: number;
}

export interface SubscriptionPlansResponse {
  plans: SubscriptionPlanItem[];
  stats: {
    total_active_subscribers: number;
    plan_breakdown: SubscriptionPlanBreakdown[];
  };
}

export type SubscriptionPlanPayload = {
  slug?: string;
  name: string;
  description?: string;
  price: number;
  period_label: string;
  benefits: string[];
  ride_discount_percent: number;
  is_popular: boolean;
  is_active: boolean;
  sort_order: number;
};

export async function fetchSubscriptionPlans() {
  return apiFetch<SubscriptionPlansResponse>("/api/v1/admin/subscription-plans");
}

export async function createSubscriptionPlan(payload: SubscriptionPlanPayload) {
  return apiFetch<SubscriptionPlanItem>("/api/v1/admin/subscription-plans", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export async function updateSubscriptionPlan(planId: string, payload: Partial<SubscriptionPlanPayload>) {
  return apiFetch<SubscriptionPlanItem>(`/api/v1/admin/subscription-plans/${planId}`, {
    method: "PATCH",
    body: JSON.stringify(payload),
  });
}

export async function deleteSubscriptionPlan(planId: string) {
  return apiFetch<{ message: string }>(`/api/v1/admin/subscription-plans/${planId}`, {
    method: "DELETE",
  });
}

export interface SubscriptionSubscriber {
  id: string;
  user_id: string;
  name: string;
  phone: string;
  email: string;
  plan_id: string | null;
  plan_name: string;
  plan_slug: string;
  status: string;
  started_at?: string | null;
  expires_at?: string | null;
}

export async function fetchSubscriptionSubscribers(params?: {
  plan_id?: string;
  search?: string;
  page?: number;
  page_size?: number;
}) {
  const query = new URLSearchParams();
  if (params?.plan_id) query.set("plan_id", params.plan_id);
  if (params?.search) query.set("search", params.search);
  if (params?.page) query.set("page", String(params.page));
  if (params?.page_size) query.set("page_size", String(params.page_size));
  const suffix = query.toString() ? `?${query.toString()}` : "";
  return apiFetch<{
    items: SubscriptionSubscriber[];
    page: number;
    page_size: number;
    total: number;
  }>(`/api/v1/admin/subscription-subscribers${suffix}`);
}
