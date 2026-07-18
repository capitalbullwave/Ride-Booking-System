"use client";

import { useEffect, useState } from "react";
import { AppShell, HeroHeader } from "@/components/layout";
import { Button } from "@/components/ui/button";
import { paymentMethods } from "@/constants/wallet";
import { openSubscriptionCheckout } from "@/lib/cashfree-checkout";
import {
  createWalletCheckout,
  getWalletSummary,
  getPaymentMethods,
  verifyWalletPayment,
  type WalletSummary,
} from "@/lib/wallet-api";
import { formatFare } from "@/lib/ride-booking";
import {
  Building2,
  Gift,
  Loader2,
  Plus,
  ShieldCheck,
  Sparkles,
} from "lucide-react";

const TOP_UP_AMOUNTS = [100, 200, 500, 1000];

export function WalletView() {
  const [summary, setSummary] = useState<WalletSummary | null>(null);
  const [savedMethods, setSavedMethods] = useState<
    { id: string; type: string; label: string; last_four: string | null }[]
  >([]);
  const [isLoading, setIsLoading] = useState(true);
  const [topUpAmount, setTopUpAmount] = useState(200);
  const [topUpLoading, setTopUpLoading] = useState(false);
  const [topUpError, setTopUpError] = useState<string | null>(null);
  const [topUpSuccess, setTopUpSuccess] = useState<string | null>(null);

  const reloadWallet = async () => {
    const [wallet, methods] = await Promise.all([
      getWalletSummary(),
      getPaymentMethods().catch(() => []),
    ]);
    setSummary(wallet);
    setSavedMethods(methods);
  };

  useEffect(() => {
    async function load() {
      try {
        await reloadWallet();
      } finally {
        setIsLoading(false);
      }
    }
    void load();
  }, []);

  const handleTopUp = async () => {
    setTopUpLoading(true);
    setTopUpError(null);
    setTopUpSuccess(null);
    try {
      const res = await createWalletCheckout(topUpAmount);
      const checkout = "checkout" in res && res.checkout ? res.checkout : (res as {
        order_id: string;
        payment_session_id: string;
        environment?: string;
        amount?: number;
      });
      const paid = await openSubscriptionCheckout(checkout);
      await verifyWalletPayment(paid.order_id);
      await reloadWallet();
      setTopUpSuccess(`₹${topUpAmount} added to wallet`);
    } catch (err) {
      setTopUpError(err instanceof Error ? err.message : "Unable to add money");
    } finally {
      setTopUpLoading(false);
    }
  };

  return (
    <AppShell>
      <HeroHeader
        eyebrow="Payments"
        title="Wallet"
        description="Manage balances, payouts, and how you pay for rides."
        icon={ShieldCheck}
      />

      <div className="relative z-10 w-full flex-1 px-6 md:px-12 lg:px-24">
        {isLoading ? (
          <div className="flex justify-center py-16">
            <Loader2 className="h-8 w-8 animate-spin text-primary" />
          </div>
        ) : (
          <>
            <div className="-mt-8 mb-10 grid grid-cols-1 gap-4 sm:grid-cols-2">
              <div className="group flex min-h-[240px] flex-col rounded-[24px] border border-border/60 bg-card p-6 shadow-lg shadow-primary/5 transition-all duration-300 hover:-translate-y-0.5 hover:shadow-xl hover:shadow-primary/10">
                <div className="flex items-start justify-between">
                  <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-primary/10 text-primary">
                    <Building2 className="h-5 w-5" />
                  </div>
                  <span className="rounded-full bg-muted px-3 py-1 text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
                    Payouts
                  </span>
                </div>
                <p className="mt-5 text-sm font-medium text-muted-foreground">Balance</p>
                <p className="mt-1 font-heading text-4xl font-bold tracking-tight text-foreground">
                  {formatFare(summary?.balance ?? 0)}
                </p>
                <p className="mt-3 flex-1 text-sm leading-relaxed text-muted-foreground">
                  {summary?.has_bank_account
                    ? `Payout to ${summary.bank?.bank_name ?? "saved account"} (${summary.bank?.account_number ?? ""})`
                    : "Add a bank / UPI account, then request withdrawal to your account"}
                </p>
                <Button
                  className="mt-5 w-fit rounded-full px-5 py-2.5 shadow-md shadow-primary/15 transition-transform group-hover:scale-[1.02]"
                  onClick={() => {
                    window.location.href = "/wallet/withdraw";
                  }}
                >
                  <Plus className="h-4 w-4" />
                  {summary?.has_bank_account ? "Withdraw" : "Add account & withdraw"}
                </Button>
              </div>

              <div className="group relative flex min-h-[240px] flex-col overflow-hidden rounded-[24px] border border-secondary/30 bg-card p-6 shadow-lg shadow-secondary/10 transition-all duration-300 hover:-translate-y-0.5 hover:shadow-xl hover:shadow-secondary/20">
                <div className="pointer-events-none absolute -right-10 -top-10 h-36 w-36 rounded-full bg-secondary/25 blur-2xl" />
                <div className="pointer-events-none absolute bottom-0 right-0 h-28 w-28 rounded-full bg-accent/15 blur-xl" />
                <div className="pointer-events-none absolute inset-0 bg-gradient-to-br from-secondary/10 via-transparent to-accent/5" />
                <div className="relative flex items-start justify-between">
                  <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-secondary/25 text-primary">
                    <Sparkles className="h-5 w-5" />
                  </div>
                  <span className="rounded-full bg-secondary/20 px-3 py-1 text-[11px] font-semibold uppercase tracking-wide text-primary">
                    Rewards
                  </span>
                </div>
                <p className="relative mt-5 text-sm font-medium text-muted-foreground">Bull Wave Rides Cash</p>
                <p className="relative mt-1 font-heading text-4xl font-bold tracking-tight text-foreground">
                  {formatFare(summary?.bonus_balance ?? 0)}
                </p>
                <p className="relative mt-3 flex-1 text-sm leading-relaxed text-muted-foreground">
                  Total wallet value: {formatFare(summary?.total ?? 0)}
                </p>
                <Button className="relative mt-5 w-fit rounded-full px-5 py-2.5 shadow-md shadow-primary/15 transition-transform group-hover:scale-[1.02]">
                  <Gift className="h-4 w-4" />
                  Gift card
                </Button>
              </div>
            </div>

            <div className="mb-10 rounded-[24px] border border-border bg-card p-5 shadow-sm">
              <h2 className="font-heading text-lg font-bold text-foreground">Add money</h2>
              <p className="mt-1 text-sm text-muted-foreground">
                Top up via Cashfree — same checkout as the app
              </p>
              <div className="mt-4 flex flex-wrap gap-2">
                {TOP_UP_AMOUNTS.map((amount) => (
                  <button
                    key={amount}
                    type="button"
                    onClick={() => setTopUpAmount(amount)}
                    className={`rounded-full px-4 py-2 text-sm font-semibold ${
                      topUpAmount === amount
                        ? "bg-primary text-primary-foreground"
                        : "bg-muted text-muted-foreground"
                    }`}
                  >
                    ₹{amount}
                  </button>
                ))}
              </div>
              {topUpError ? <p className="mt-3 text-sm text-destructive">{topUpError}</p> : null}
              {topUpSuccess ? <p className="mt-3 text-sm text-success">{topUpSuccess}</p> : null}
              <Button
                className="mt-4 rounded-full"
                disabled={topUpLoading}
                onClick={() => void handleTopUp()}
              >
                {topUpLoading ? (
                  <Loader2 className="h-4 w-4 animate-spin" />
                ) : (
                  <>
                    <Plus className="h-4 w-4" />
                    Add {formatFare(topUpAmount)}
                  </>
                )}
              </Button>
            </div>

            <div>
              <div className="mb-5 flex items-end justify-between gap-4">
                <div>
                  <h2 className="font-heading text-xl font-bold text-foreground">Payment Methods</h2>
                  <p className="mt-1 text-sm text-muted-foreground">Choose how you want to pay for rides</p>
                </div>
              </div>

              {savedMethods.length > 0 && (
                <div className="mb-4 flex flex-col gap-3">
                  {savedMethods.map((method) => (
                    <div
                      key={method.id}
                      className="rounded-[20px] border border-border bg-card p-4 shadow-sm"
                    >
                      <p className="font-semibold text-foreground">{method.label}</p>
                      <p className="text-sm text-muted-foreground">
                        {method.type}
                        {method.last_four ? ` • ****${method.last_four}` : ""}
                      </p>
                    </div>
                  ))}
                </div>
              )}

              <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                {paymentMethods.map((method) => {
                  const Icon = method.icon;
                  const isCash = method.variant === "cash";

                  return (
                    <button
                      key={method.id}
                      className={`group relative overflow-hidden rounded-[24px] p-5 text-left transition-all duration-300 active:scale-[0.98] ${
                        isCash
                          ? "min-h-[148px] border border-success/20 bg-gradient-to-br from-success to-success/85 text-primary-foreground shadow-lg shadow-success/20 hover:brightness-105 hover:shadow-xl hover:shadow-success/25"
                          : "min-h-[148px] border border-border bg-card shadow-sm hover:-translate-y-0.5 hover:border-primary/30 hover:shadow-lg hover:shadow-primary/5"
                      }`}
                    >
                      {isCash && (
                        <div className="pointer-events-none absolute -right-6 -top-6 h-24 w-24 rounded-full bg-white/10" />
                      )}
                      <div className="relative flex items-start justify-between gap-3">
                        <div className="min-w-0 flex-1">
                          <div className="flex flex-wrap items-center gap-2">
                            <span className="font-heading text-base font-bold">{method.title}</span>
                            {method.badge && (
                              <span className="rounded-full bg-card px-2.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-muted-foreground">
                                {method.badge}
                              </span>
                            )}
                          </div>
                          <p className={`mt-2 text-sm leading-snug ${isCash ? "text-primary-foreground/85" : "text-muted-foreground"}`}>
                            {method.description}
                          </p>
                        </div>
                        <div
                          className={`flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl transition-transform group-hover:scale-105 ${
                            isCash
                              ? "bg-primary-foreground/15 backdrop-blur-sm"
                              : "bg-primary text-primary-foreground shadow-md shadow-primary/20"
                          }`}
                        >
                          <Icon className="h-5 w-5" />
                        </div>
                      </div>
                    </button>
                  );
                })}
              </div>
            </div>
          </>
        )}

        <div className="mt-8 flex items-start gap-3 rounded-[20px] border border-border bg-card/80 p-4 shadow-sm">
          <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary">
            <ShieldCheck className="h-5 w-5" />
          </div>
          <div>
            <p className="text-sm font-semibold text-foreground">Secure payments</p>
            <p className="mt-1 text-sm leading-relaxed text-muted-foreground">
              Your payment details are encrypted and never shared with drivers.
            </p>
          </div>
        </div>
      </div>
    </AppShell>
  );
}
