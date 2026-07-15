"use client";

import { useCallback, useEffect, useState } from "react";
import { Copy, Gift, Loader2 } from "lucide-react";
import { AppShell, PageHeader } from "@/components/layout";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { applyReferEarnCode, getReferEarn, type ReferEarnDashboard } from "@/lib/refer-earn-api";

export function ReferEarnView() {
  const [data, setData] = useState<ReferEarnDashboard | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [code, setCode] = useState("");
  const [applying, setApplying] = useState(false);
  const [copied, setCopied] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    setError("");
    try {
      setData(await getReferEarn());
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  const copy = async (text: string) => {
    await navigator.clipboard.writeText(text);
    setCopied(true);
    setTimeout(() => setCopied(false), 1500);
  };

  const apply = async () => {
    if (!code.trim()) return;
    setApplying(true);
    setError("");
    try {
      setData(await applyReferEarnCode(code.trim()));
      setCode("");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Could not apply code");
    } finally {
      setApplying(false);
    }
  };

  return (
    <AppShell>
      <PageHeader title="Refer & Earn" />
      <div className="w-full flex-1 px-6 py-6 md:px-12 lg:px-24">
        {loading ? (
          <div className="flex items-center justify-center py-20 text-muted-foreground">
            <Loader2 className="mr-2 h-5 w-5 animate-spin" />
            Loading…
          </div>
        ) : !data?.enabled ? (
          <p className="text-muted-foreground">Refer & Earn is not available right now.</p>
        ) : (
          <div className="mx-auto max-w-xl space-y-6">
            <div className="rounded-[24px] bg-gradient-to-br from-secondary to-primary p-5 text-white shadow-lg shadow-primary/20">
              <div className="flex items-start gap-3">
                <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-white/15">
                  <Gift className="h-6 w-6" />
                </div>
                <div>
                  <h2 className="font-heading text-lg font-bold">{data.program?.title ?? "Refer & Earn"}</h2>
                  <p className="mt-1 text-sm text-white/85">
                    {data.program?.description ||
                      `Earn ₹${data.program?.rewardAmount ?? 0} when friends complete ${data.program?.requiredRides ?? 0} rides.`}
                  </p>
                </div>
              </div>
            </div>

            <div className="grid grid-cols-3 gap-3">
              <div className="rounded-2xl border border-border/80 bg-muted/40 p-3 text-center">
                <p className="text-lg font-bold">₹{data.stats.totalEarned}</p>
                <p className="text-xs text-muted-foreground">Earned</p>
              </div>
              <div className="rounded-2xl border border-border/80 bg-muted/40 p-3 text-center">
                <p className="text-lg font-bold">{data.stats.totalReferrals}</p>
                <p className="text-xs text-muted-foreground">Referrals</p>
              </div>
              <div className="rounded-2xl border border-border/80 bg-muted/40 p-3 text-center">
                <p className="text-lg font-bold">{data.stats.pendingReferrals}</p>
                <p className="text-xs text-muted-foreground">Pending</p>
              </div>
            </div>

            <div className="space-y-2">
              <p className="text-sm font-semibold">Your invite code</p>
              <div className="flex items-center gap-2 rounded-2xl border border-border bg-background px-4 py-3">
                <span className="flex-1 text-xl font-bold tracking-wide">{data.inviteCode}</span>
                <Button
                  variant="ghost"
                  size="icon"
                  onClick={() => void copy(data.inviteCode)}
                  aria-label="Copy code"
                >
                  <Copy className="h-4 w-4" />
                </Button>
              </div>
              {data.shareMessage ? (
                <div className="rounded-2xl border border-border/80 bg-muted/40 p-3">
                  <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
                    Share message preview
                  </p>
                  <p className="mt-1 text-sm leading-relaxed">{data.shareMessage}</p>
                </div>
              ) : null}
              <Button
                variant="outline"
                className="w-full"
                onClick={() => void copy(data.shareMessage || `Join with my code ${data.inviteCode}`)}
              >
                {copied ? "Copied" : "Copy invite message"}
              </Button>
              <p className="text-sm font-medium text-muted-foreground">
                Reward: ₹{data.program?.rewardAmount ?? 0} after {data.program?.requiredRides ?? 0}{" "}
                completed rides
              </p>
            </div>

            {!data.hasAppliedCode ? (
              <div className="space-y-2">
                <p className="text-sm font-semibold">Have a referral code?</p>
                <div className="flex gap-2">
                  <Input
                    value={code}
                    onChange={(e) => setCode(e.target.value.toUpperCase())}
                    placeholder="Enter code"
                  />
                  <Button onClick={() => void apply()} disabled={applying}>
                    {applying ? <Loader2 className="h-4 w-4 animate-spin" /> : "Apply"}
                  </Button>
                </div>
              </div>
            ) : null}

            {error ? <p className="text-sm text-destructive">{error}</p> : null}
            {data.program?.terms ? (
              <p className="text-xs text-muted-foreground">{data.program.terms}</p>
            ) : null}
          </div>
        )}
      </div>
    </AppShell>
  );
}
