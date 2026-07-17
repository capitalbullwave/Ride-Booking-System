import { authFetch } from "@/lib/api";

export interface StudentPassApplication {
  id: string;
  aadhar_number: string;
  college_name: string;
  aadhar_photo_url?: string | null;
  student_id_photo_url?: string | null;
  status: string;
  discount_percent: number;
  rejection_reason?: string | null;
  verified_at?: string | null;
}

export function getStudentPass(): Promise<{ application: StudentPassApplication | null }> {
  return authFetch("/user/student-pass");
}

export function submitStudentPass(payload: {
  aadhar_number: string;
  college_name: string;
  aadhar_photo: string;
  student_id_photo: string;
}) {
  return authFetch<{ application: StudentPassApplication; message: string }>("/user/student-pass", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export interface MembershipPlan {
  id: string;
  slug: string;
  name: string;
  price_inr: number;
  ride_discount_percent: number;
  benefits: string[];
  is_popular?: boolean;
}

function normalizeMembershipPlan(raw: Record<string, unknown>): MembershipPlan {
  return {
    id: String(raw.id ?? ""),
    slug: String(raw.slug ?? ""),
    name: String(raw.name ?? ""),
    price_inr: Number(raw.price_inr ?? raw.price ?? 0),
    ride_discount_percent: Number(raw.ride_discount_percent ?? 0),
    benefits: Array.isArray(raw.benefits)
      ? raw.benefits.filter((b): b is string => typeof b === "string")
      : [],
    is_popular: raw.is_popular === true,
  };
}

export async function listSubscriptionPlans() {
  const res = await authFetch<{ plans: Array<Record<string, unknown>> }>(
    "/user/subscription-plans"
  );
  return { plans: res.plans.map(normalizeMembershipPlan) };
}

export function getUserSubscription() {
  return authFetch<{ subscription: { plan: Record<string, unknown>; status: string } }>(
    "/user/subscription"
  );
}

export function selectSubscriptionPlan(planSlug: string) {
  return authFetch<{
    subscription: {
      plan: {
        name: string;
        slug: string;
        benefits?: string[];
        ride_discount_percent?: number;
      };
      status: string;
    };
    message: string;
  }>("/user/subscription", {
    method: "POST",
    body: JSON.stringify({ plan_slug: planSlug }),
  });
}

export interface SubscriptionCheckout {
  order_id: string;
  amount: number;
  currency: string;
  key_id: string;
  plan: { slug: string; name: string };
  prefill?: { name?: string; email?: string; contact?: string };
}

export function createSubscriptionCheckout(planSlug: string) {
  return authFetch<{ checkout: SubscriptionCheckout }>("/user/subscription/checkout", {
    method: "POST",
    body: JSON.stringify({ plan_slug: planSlug }),
  });
}

export function verifySubscriptionPayment(payload: {
  plan_slug: string;
  razorpay_order_id: string;
  razorpay_payment_id: string;
  razorpay_signature: string;
}) {
  return authFetch<{
    subscription: {
      plan: {
        name: string;
        slug: string;
        benefits?: string[];
        ride_discount_percent?: number;
      };
      status: string;
    };
    message: string;
  }>("/user/subscription/verify-payment", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

async function fileToDataUrl(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(String(reader.result));
    reader.onerror = () => reject(new Error("Unable to read file"));
    reader.readAsDataURL(file);
  });
}

export async function fileToUploadDataUrl(file: File | null) {
  if (!file) return null;
  return fileToDataUrl(file);
}
