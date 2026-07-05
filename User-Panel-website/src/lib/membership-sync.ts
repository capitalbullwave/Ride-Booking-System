export interface CachedMembershipPlan {
  name: string;
  slug: string;
  benefits?: string[];
  ride_discount_percent?: number;
}

const STORAGE_KEY = "active_membership_plan";
export const MEMBERSHIP_UPDATED_EVENT = "membership-updated";

export function cacheActiveMembershipPlan(plan: CachedMembershipPlan) {
  if (typeof window === "undefined") return;
  sessionStorage.setItem(STORAGE_KEY, JSON.stringify(plan));
  window.dispatchEvent(new Event(MEMBERSHIP_UPDATED_EVENT));
}

export function readCachedMembershipPlan(): CachedMembershipPlan | null {
  if (typeof window === "undefined") return null;
  const raw = sessionStorage.getItem(STORAGE_KEY);
  if (!raw) return null;
  try {
    return JSON.parse(raw) as CachedMembershipPlan;
  } catch {
    return null;
  }
}

export function applyMembershipPlanToState(
  plan: CachedMembershipPlan | null | undefined,
  setters: {
    setActivePlanName: (name: string) => void;
    setActivePlanBenefit: (benefit: string) => void;
    setIsFreePlan: (isFree: boolean) => void;
  }
) {
  if (!plan?.name) return;
  setters.setActivePlanName(plan.name);
  const slug = plan.slug ?? "free";
  setters.setIsFreePlan(slug === "free");
  const benefits = Array.isArray(plan.benefits) ? plan.benefits : [];
  if (benefits[0]) setters.setActivePlanBenefit(benefits[0]);
}
