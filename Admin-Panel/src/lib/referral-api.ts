import { apiFetch } from "@/lib/api";

export type ReferralAudience = "USER" | "DRIVER";
export type ReferralRewardStatus = "PENDING" | "PAID" | "CANCELLED";

export type ReferralProgram = {
  id: string;
  audience: ReferralAudience;
  isEnabled: boolean;
  requiredRides: number;
  rewardAmount: number;
  title: string;
  description?: string | null;
  terms?: string | null;
  shareMessage?: string | null;
  updatedAt?: string | null;
};

export type UpdateReferralProgramPayload = {
  isEnabled?: boolean;
  requiredRides?: number;
  rewardAmount?: number;
  title?: string;
  description?: string;
  terms?: string;
  shareMessage?: string;
};

export type ReferralPerson = {
  id: string;
  name: string;
  phone: string;
  inviteCode: string;
};

export type ReferralReward = {
  id: string;
  audience: ReferralAudience;
  status: ReferralRewardStatus;
  requiredRides: number;
  ridesCompleted: number;
  ridesRemaining: number;
  rewardAmount: number;
  willCreditWhen: string;
  referrer: ReferralPerson;
  referee: ReferralPerson;
  createdAt?: string | null;
  paidAt?: string | null;
  updatedAt?: string | null;
};

export type ReferralRewardsResponse = {
  items: ReferralReward[];
  summary: {
    total: number;
    pending: number;
    paid: number;
    cancelled: number;
    totalPaidAmount: number;
  };
};

export type UpdateReferralRewardPayload = {
  requiredRides?: number;
  rewardAmount?: number;
  action?: "refresh" | "pay_now" | "cancel" | "reopen";
  status?: ReferralRewardStatus;
};

export function listReferralPrograms(): Promise<ReferralProgram[]> {
  return apiFetch<ReferralProgram[]>("/api/v1/admin/referral-programs");
}

export function updateReferralProgram(
  audience: ReferralAudience,
  payload: UpdateReferralProgramPayload,
): Promise<ReferralProgram> {
  return apiFetch<ReferralProgram>(`/api/v1/admin/referral-programs/${audience}`, {
    method: "PUT",
    body: JSON.stringify(payload),
  });
}

export function listReferralRewards(params?: {
  audience?: ReferralAudience | "ALL";
  status?: ReferralRewardStatus | "ALL";
}): Promise<ReferralRewardsResponse> {
  const search = new URLSearchParams();
  if (params?.audience && params.audience !== "ALL") search.set("audience", params.audience);
  if (params?.status && params.status !== "ALL") search.set("status", params.status);
  const qs = search.toString();
  return apiFetch<ReferralRewardsResponse>(
    `/api/v1/admin/referral-rewards${qs ? `?${qs}` : ""}`,
  );
}

export function updateReferralReward(
  rewardId: string,
  payload: UpdateReferralRewardPayload,
): Promise<ReferralReward> {
  return apiFetch<ReferralReward>(`/api/v1/admin/referral-rewards/${rewardId}`, {
    method: "PATCH",
    body: JSON.stringify(payload),
  });
}
