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
  return authFetch("/student-pass");
}

export function submitStudentPass(payload: {
  aadhar_number: string;
  college_name: string;
  aadhar_photo: string;
  student_id_photo: string;
}) {
  return authFetch<{ application: StudentPassApplication; message: string }>("/student-pass", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export function listSubscriptionPlans() {
  return authFetch<{ plans: Array<Record<string, unknown>> }>("/subscription-plans");
}

export function getUserSubscription() {
  return authFetch<{ subscription: { plan: Record<string, unknown>; status: string } }>(
    "/subscription"
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
  }>("/subscription", {
    method: "POST",
    body: JSON.stringify({ plan_slug: planSlug }),
  });
}

export interface SubscriptionCheckout {
  order_id: string;
  payment_session_id: string;
  environment?: string;
  amount: number;
  currency: string;
  plan: { slug: string; name: string };
  prefill?: { name?: string; email?: string; contact?: string };
}

export function createSubscriptionCheckout(planSlug: string) {
  return authFetch<{ checkout: SubscriptionCheckout }>("/subscription/checkout", {
    method: "POST",
    body: JSON.stringify({ plan_slug: planSlug }),
  });
}

export function verifySubscriptionPayment(payload: {
  plan_slug: string;
  order_id: string;
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
  }>("/subscription/verify-payment", {
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

async function compressImage(file: File, maxDim = 1600, quality = 0.82): Promise<string> {
  const dataUrl = await fileToDataUrl(file);
  if (typeof window === "undefined") return dataUrl;

  return new Promise((resolve, reject) => {
    const image = new Image();
    image.onload = () => {
      const scale = Math.min(1, maxDim / Math.max(image.width, image.height));
      const width = Math.max(1, Math.round(image.width * scale));
      const height = Math.max(1, Math.round(image.height * scale));
      const canvas = document.createElement("canvas");
      canvas.width = width;
      canvas.height = height;
      const ctx = canvas.getContext("2d");
      if (!ctx) {
        resolve(dataUrl);
        return;
      }
      ctx.drawImage(image, 0, 0, width, height);
      resolve(canvas.toDataURL("image/jpeg", quality));
    };
    image.onerror = () => reject(new Error("Unable to process image"));
    image.src = dataUrl;
  });
}

export async function fileToUploadDataUrl(file: File | null) {
  if (!file) return null;
  try {
    return await compressImage(file);
  } catch {
    return fileToDataUrl(file);
  }
}
