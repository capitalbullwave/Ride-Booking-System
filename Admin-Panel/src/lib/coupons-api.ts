import { apiFetch } from "@/lib/api";
import { Coupon, CouponStatus, DiscountType } from "@/types";

export interface CreateCouponPayload {
  code: string;
  discountType: DiscountType;
  discountValue: number;
  maxDiscount: number;
  expiryDate: string;
  usageLimit: number;
  status?: CouponStatus;
}

export interface UpdateCouponPayload {
  code?: string;
  discountType?: DiscountType;
  discountValue?: number;
  maxDiscount?: number;
  expiryDate?: string;
  usageLimit?: number;
  status?: CouponStatus;
}

export function listCoupons(): Promise<Coupon[]> {
  return apiFetch<Coupon[]>("/api/v1/admin/coupons");
}

export function createCoupon(payload: CreateCouponPayload): Promise<Coupon> {
  return apiFetch<Coupon>("/api/v1/admin/coupons", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export function updateCoupon(
  id: string,
  payload: UpdateCouponPayload,
): Promise<Coupon> {
  return apiFetch<Coupon>(`/api/v1/admin/coupons/${id}`, {
    method: "PATCH",
    body: JSON.stringify(payload),
  });
}

export function deleteCoupon(
  id: string,
): Promise<{ success: boolean; deactivated?: boolean }> {
  return apiFetch<{ success: boolean; deactivated?: boolean }>(
    `/api/v1/admin/coupons/${id}`,
    {
      method: "DELETE",
    },
  );
}
