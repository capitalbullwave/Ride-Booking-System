"use client";

import { useCallback, useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { CheckCircle2, Crown, Loader2 } from "lucide-react";
import { AppShell, PageHeader } from "@/components/layout";
import { Button } from "@/components/ui/button";
import {
  createSubscriptionCheckout,
  getUserSubscription,
  listSubscriptionPlans,
  type MembershipPlan,
  selectSubscriptionPlan,
  verifySubscriptionPayment,
} from "@/lib/membership-api";
import { cacheActiveMembershipPlan } from "@/lib/membership-sync";
import { openSubscriptionCheckout } from "@/lib/razorpay-checkout";
import { cn } from "@/lib/utils";

export function SubscriptionView() {
  const router = useRouter();
  const [plans, setPlans] = useState<MembershipPlan[]>([]);
  const [activeSlug, setActiveSlug] = useState("free");
  const [loading, setLoading] = useState(true);
  const [selectingSlug, setSelectingSlug] = useState<string | null>(null);
  const [error, setError] = useState("");

  const load = useCallback(async () => {
    setLoading(true);
    setError("");
    try {
      const [plansRes, subRes] = await Promise.all([
        listSubscriptionPlans(),
        getUserSubscription(),
      ]);
      setPlans(plansRes.plans);
      const slug = (subRes.subscription?.plan as { slug?: string })?.slug ?? "free";
      setActiveSlug(slug);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load plans");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  const handleSelect = async (slug: string, priceInr = 0) => {
    if (selectingSlug) return;
    setSelectingSlug(slug);
    setError("");
    try {
      if (priceInr <= 0 || slug === "free") {
        const res = await selectSubscriptionPlan(slug);
        const plan = res.subscription?.plan;
        if (plan?.slug) {
          cacheActiveMembershipPlan({
            name: plan.name,
            slug: plan.slug,
            benefits: plan.benefits,
          });
          setActiveSlug(plan.slug);
        } else {
          setActiveSlug(slug);
        }
      } else {
        const { checkout } = await createSubscriptionCheckout(slug);
        const payment = await openSubscriptionCheckout(checkout);
        const verified = await verifySubscriptionPayment({
          plan_slug: slug,
          ...payment,
        });
        const plan = verified.subscription?.plan;
        if (plan) {
          cacheActiveMembershipPlan({
            name: plan.name,
            slug: plan.slug,
            benefits: plan.benefits,
            ride_discount_percent: plan.ride_discount_percent,
          });
          setActiveSlug(plan.slug);
        } else {
          setActiveSlug(slug);
        }
      }
      await load();
      if (slug !== "free") router.back();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unable to update plan");
    } finally {
      setSelectingSlug(null);
    }
  };

  const activePlan = plans.find((plan) => plan.slug === activeSlug);

  if (loading) {
    return (
      <AppShell>
        <PageHeader title="Subscriptions" />
        <div className="flex flex-1 items-center justify-center text-muted-foreground">Loading…</div>
      </AppShell>
    );
  }

  return (
    <AppShell>
      <PageHeader title="Subscriptions" />

      <div className="w-full flex-1 px-6 py-6 md:px-12 lg:px-24">
        <div className="mb-6 rounded-[24px] bg-gradient-to-br from-secondary to-primary p-5 text-white shadow-lg shadow-primary/20">
          <div className="flex items-start gap-3">
            <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-white/15">
              <Crown className="h-6 w-6" />
            </div>
            <div>
              <h2 className="font-heading text-lg font-bold">Bull Wave rides Membership</h2>
              <p className="text-sm text-white/80">Ride smarter with exclusive perks</p>
              <p className="mt-3 text-sm font-semibold">
                Current plan: {activePlan?.name ?? "Free"}
              </p>
            </div>
          </div>
        </div>

        {error ? <p className="mb-4 text-sm text-destructive">{error}</p> : null}

        <h3 className="mb-3 font-heading text-lg font-bold text-foreground">Choose your plan</h3>

        <div className="flex flex-col gap-3">
          {plans.map((plan) => {
            const isActive = plan.slug === activeSlug;
            const isSelecting = selectingSlug === plan.slug;

            return (
              <div
                key={plan.id}
                className={cn(
                  "rounded-[20px] border bg-card p-5 shadow-sm",
                  isActive && "border-primary",
                  plan.is_popular && !isActive && "border-secondary/50"
                )}
              >
                <div className="flex items-start justify-between gap-4">
                  <div>
                    <div className="flex items-center gap-2">
                      <h4 className="font-heading text-lg font-bold">{plan.name}</h4>
                      {plan.is_popular ? (
                        <span className="rounded-full bg-secondary/20 px-2 py-0.5 text-[10px] font-bold uppercase text-secondary">
                          Popular
                        </span>
                      ) : null}
                      {isActive ? (
                        <span className="flex items-center gap-1 text-xs font-semibold text-primary">
                          <CheckCircle2 className="h-3.5 w-3.5" />
                          Active
                        </span>
                      ) : null}
                    </div>
                    <p className="mt-1 text-sm text-muted-foreground">
                      {plan.price_inr === 0 ? "Free" : `₹${plan.price_inr}/month`}
                      {plan.ride_discount_percent > 0
                        ? ` · ${plan.ride_discount_percent}% ride discount`
                        : ""}
                    </p>
                    <ul className="mt-3 space-y-1">
                      {plan.benefits.map((benefit) => (
                        <li key={benefit} className="text-sm text-foreground/80">
                          • {benefit}
                        </li>
                      ))}
                    </ul>
                  </div>
                </div>

                {!isActive ? (
                  <Button
                    className="mt-4 w-full"
                    disabled={!!selectingSlug}
                    onClick={() => void handleSelect(plan.slug, plan.price_inr)}
                  >
                    {isSelecting ? (
                      <>
                        <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                        Updating…
                      </>
                    ) : plan.price_inr > 0 ? (
                      `Pay ₹${plan.price_inr} & Subscribe`
                    ) : (
                      `Select ${plan.name}`
                    )}
                  </Button>
                ) : null}
              </div>
            );
          })}
        </div>
      </div>
    </AppShell>
  );
}
