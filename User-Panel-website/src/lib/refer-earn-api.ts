import { authFetch } from "@/lib/api";

export type ReferEarnDashboard = {
  enabled: boolean;
  inviteCode: string;
  shareMessage: string;
  hasAppliedCode?: boolean;
  program: {
    title: string;
    description?: string | null;
    terms?: string | null;
    requiredRides: number;
    rewardAmount: number;
    isEnabled: boolean;
  } | null;
  stats: {
    totalReferrals: number;
    pendingReferrals: number;
    totalEarned: number;
  };
  referrals: Array<{
    id: string;
    status: string;
    requiredRides: number;
    ridesCompleted: number;
    rewardAmount: number;
  }>;
};

export function getReferEarn(): Promise<ReferEarnDashboard> {
  return authFetch("/refer-earn");
}

export function applyReferEarnCode(code: string): Promise<ReferEarnDashboard> {
  return authFetch("/refer-earn/apply", {
    method: "POST",
    body: JSON.stringify({ code }),
  });
}
