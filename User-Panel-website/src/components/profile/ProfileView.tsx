"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { AppShell, PageHeader } from "@/components/layout";
import { profileMenuItems } from "@/constants/profile-menu";
import { ROUTES } from "@/constants/routes";
import { clearAuthSession, getAuthSession } from "@/lib/auth-session";
import { logoutAccount } from "@/lib/profile-api";
import { getStudentPass, getUserSubscription } from "@/lib/membership-api";
import {
  applyMembershipPlanToState,
  MEMBERSHIP_UPDATED_EVENT,
  readCachedMembershipPlan,
} from "@/lib/membership-sync";
import { useAuthUser } from "@/hooks/useAuthUser";
import { ChevronRight, Crown, LogOut, Star } from "lucide-react";
import { cn } from "@/lib/utils";

export function ProfileView() {
  const router = useRouter();
  const user = useAuthUser();
  const [activePlanName, setActivePlanName] = useState("Free");
  const [activePlanBenefit, setActivePlanBenefit] = useState("Priority rides, ride discounts & more");
  const [isFreePlan, setIsFreePlan] = useState(true);
  const [studentPassStatus, setStudentPassStatus] = useState<string | null>(null);

  useEffect(() => {
    const loadMembership = async () => {
      try {
        const cached = readCachedMembershipPlan();
        if (cached) {
          applyMembershipPlanToState(cached, {
            setActivePlanName,
            setActivePlanBenefit,
            setIsFreePlan,
          });
        }

        const [passRes, subRes] = await Promise.all([getStudentPass(), getUserSubscription()]);
        setStudentPassStatus(passRes.application?.status ?? null);
        const plan = subRes.subscription?.plan as {
          name?: string;
          slug?: string;
          benefits?: string[];
        };
        if (plan?.name) {
          applyMembershipPlanToState(
            {
              name: plan.name,
              slug: plan.slug ?? "free",
              benefits: Array.isArray(plan.benefits) ? plan.benefits : [],
            },
            {
              setActivePlanName,
              setActivePlanBenefit,
              setIsFreePlan,
            }
          );
        }
      } catch {
        // Keep defaults when API is unavailable
      }
    };

    void loadMembership();

    const onMembershipUpdated = () => {
      void loadMembership();
    };
    window.addEventListener(MEMBERSHIP_UPDATED_EVENT, onMembershipUpdated);
    window.addEventListener("focus", onMembershipUpdated);
    return () => {
      window.removeEventListener(MEMBERSHIP_UPDATED_EVENT, onMembershipUpdated);
      window.removeEventListener("focus", onMembershipUpdated);
    };
  }, []);

  return (
    <AppShell>
      <PageHeader title="Profile" />

      <div className="w-full flex-1 px-6 py-6 md:px-12 lg:px-24">
        <button
          onClick={() => router.push(ROUTES.profileAccountSettings)}
          className="mb-8 flex w-full items-center gap-5 rounded-[24px] border border-border bg-card p-5 text-left shadow-sm transition-all hover:border-primary/40 hover:shadow-md"
        >
          <div className="flex h-20 w-20 shrink-0 items-center justify-center rounded-full bg-primary text-white shadow-md">
            <span className="font-heading text-3xl font-bold">{user.initial}</span>
          </div>
          <div className="flex flex-1 flex-col">
            <h2 className="font-heading text-xl font-bold text-foreground">{user.name}</h2>
            <p className="text-sm text-muted-foreground">{user.phone}</p>
            <div className="mt-2 flex w-fit items-center gap-1.5 rounded-full bg-secondary/30 px-3 py-1">
              <Star className="h-3.5 w-3.5 fill-primary text-primary" />
              <span className="text-xs font-bold text-primary">{user.rating} Rating</span>
            </div>
          </div>
          <ChevronRight className="h-5 w-5 shrink-0 text-muted-foreground/50" />
        </button>

        <button
          onClick={() => router.push(ROUTES.profileSubscription)}
          className="mb-6 flex w-full items-center gap-4 rounded-[24px] bg-gradient-to-br from-secondary to-primary p-5 text-left text-white shadow-lg shadow-primary/20 transition-all hover:opacity-95"
        >
          <div className="flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl bg-white/15">
            <Crown className="h-7 w-7" />
          </div>
          <div className="flex flex-1 flex-col">
            <h3 className="font-heading text-lg font-bold">
              {isFreePlan ? "Upgrade to Bull Wave Rides Plus" : `${activePlanName} Member`}
            </h3>
            <p className="text-sm text-white/85">
              {isFreePlan ? "Priority rides, ride discounts & more" : activePlanBenefit}
            </p>
          </div>
          <ChevronRight className="h-5 w-5 shrink-0 text-white/90" />
        </button>

        <div className="flex flex-col gap-3">
          {profileMenuItems.map((item) => {
            const Icon = item.icon;
            const statusBadge =
              item.id === "student-pass" && studentPassStatus
                ? studentPassStatus.charAt(0).toUpperCase() + studentPassStatus.slice(1)
                : null;
            return (
              <button
                key={item.id}
                onClick={() => router.push(item.route)}
                className="group flex items-center justify-between rounded-[20px] border border-border bg-card p-4 shadow-sm transition-all hover:border-primary/40 hover:shadow-md"
              >
                <div className="flex items-center gap-4">
                  <div className="flex h-12 w-12 items-center justify-center rounded-[14px] bg-muted text-muted-foreground transition-colors group-hover:bg-primary/10 group-hover:text-primary">
                    <Icon className="h-5 w-5" />
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="font-semibold text-foreground">{item.label}</span>
                    {statusBadge ? (
                      <span
                        className={cn(
                          "rounded-full px-2 py-0.5 text-[10px] font-bold uppercase",
                          studentPassStatus === "approved" && "bg-green-100 text-green-700",
                          studentPassStatus === "pending" && "bg-amber-100 text-amber-700",
                          studentPassStatus === "rejected" && "bg-red-100 text-red-700"
                        )}
                      >
                        {statusBadge}
                      </span>
                    ) : null}
                  </div>
                </div>
                <ChevronRight className="h-5 w-5 text-muted-foreground/50 transition-transform group-hover:translate-x-1 group-hover:text-primary" />
              </button>
            );
          })}

          <button
            onClick={async () => {
              const session = getAuthSession();
              if (session?.refreshToken) {
                try {
                  await logoutAccount(session.refreshToken);
                } catch {
                  // Clear local session even if API logout fails
                }
              }
              clearAuthSession();
              router.push(ROUTES.landing);
            }}
            className="group mt-4 flex items-center justify-between rounded-[20px] border border-destructive/20 bg-destructive/5 p-4 transition-all hover:border-destructive/30 hover:bg-destructive/10"
          >
            <div className="flex items-center gap-4">
              <div className="flex h-12 w-12 items-center justify-center rounded-[14px] bg-card text-destructive shadow-sm">
                <LogOut className="h-5 w-5" />
              </div>
              <span className="font-semibold text-destructive">Log Out</span>
            </div>
          </button>
        </div>
      </div>
    </AppShell>
  );
}
