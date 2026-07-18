import { authFetch } from "@/lib/api";

export interface RideCoupon {
  id: string;
  code: string;
  title: string;
  description?: string | null;
  discount_type?: string;
  discount_value?: number;
  discount_percent?: number | null;
}

export interface AppliedCoupon {
  coupon: RideCoupon;
  discount_amount: number;
  final_amount: number;
}

export function listCoupons(): Promise<RideCoupon[]> {
  return authFetch<RideCoupon[] | { items?: RideCoupon[]; data?: RideCoupon[] }>(
    "/coupons",
    undefined,
    "Unable to load offers"
  ).then((res) => {
    if (Array.isArray(res)) return res;
    if (Array.isArray(res.items)) return res.items;
    if (Array.isArray(res.data)) return res.data;
    return [];
  });
}

export function validateCoupon(code: string, orderAmount: number): Promise<AppliedCoupon> {
  return authFetch<AppliedCoupon>(
    "/coupons/validate",
    {
      method: "POST",
      body: JSON.stringify({ code, order_amount: orderAmount }),
    },
    "Unable to apply coupon"
  );
}
