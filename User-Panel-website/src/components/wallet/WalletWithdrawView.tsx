"use client";

import { FormEvent, useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { AppShell, HeroHeader } from "@/components/layout";
import { Button } from "@/components/ui/button";
import {
  getWalletSummary,
  requestWalletWithdraw,
  saveWalletBank,
  type WalletSummary,
} from "@/lib/wallet-api";
import { formatFare } from "@/lib/ride-booking";
import { ArrowLeft, Loader2, Wallet } from "lucide-react";

export function WalletWithdrawView() {
  const router = useRouter();
  const [summary, setSummary] = useState<WalletSummary | null>(null);
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  const [message, setMessage] = useState("");
  const [amount, setAmount] = useState("");
  const [payoutType, setPayoutType] = useState<"bank" | "upi">("bank");
  const [holder, setHolder] = useState("");
  const [account, setAccount] = useState("");
  const [ifsc, setIfsc] = useState("");
  const [bankName, setBankName] = useState("");
  const [upi, setUpi] = useState("");

  async function reload() {
    const wallet = await getWalletSummary();
    setSummary(wallet);
  }

  useEffect(() => {
    void reload().finally(() => setLoading(false));
  }, []);

  async function onSaveBank(e: FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError("");
    try {
      await saveWalletBank(
        payoutType === "upi"
          ? {
              payment_type: "upi",
              account_holder_name: holder,
              upi_id: upi,
            }
          : {
              payment_type: "bank",
              account_holder_name: holder,
              account_number: account,
              ifsc_code: ifsc,
              bank_name: bankName,
            }
      );
      setMessage("Payout account saved");
      await reload();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to save account");
    } finally {
      setBusy(false);
    }
  }

  async function onWithdraw(e: FormEvent) {
    e.preventDefault();
    const value = Number(amount);
    if (!value || value < 1) {
      setError("Enter a valid amount");
      return;
    }
    setBusy(true);
    setError("");
    try {
      const res = await requestWalletWithdraw(value);
      setMessage(res.message || "Withdrawal requested");
      setAmount("");
      await reload();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Withdrawal failed");
    } finally {
      setBusy(false);
    }
  }

  const hasBank = Boolean(summary?.has_bank_account && summary.bank);

  return (
    <AppShell>
      <HeroHeader
        eyebrow="Wallet"
        title="Withdraw"
        description="Send wallet balance to your bank or UPI. Admin approves and pays."
        icon={Wallet}
      />
      <div className="relative z-10 mx-auto w-full max-w-xl flex-1 px-6 pb-16 md:px-12">
        <Button variant="ghost" className="mb-4 -ml-2" onClick={() => router.push("/wallet")}>
          <ArrowLeft className="h-4 w-4" />
          Back
        </Button>

        {loading ? (
          <div className="flex justify-center py-16">
            <Loader2 className="h-8 w-8 animate-spin text-primary" />
          </div>
        ) : (
          <div className="space-y-6 rounded-2xl border border-border bg-card p-6">
            <div>
              <p className="text-sm text-muted-foreground">Available balance</p>
              <p className="font-heading text-3xl font-bold">{formatFare(summary?.balance ?? 0)}</p>
            </div>

            {error ? <p className="text-sm text-destructive">{error}</p> : null}
            {message ? <p className="text-sm text-emerald-600">{message}</p> : null}

            {!hasBank ? (
              <form className="space-y-3" onSubmit={onSaveBank}>
                <p className="font-medium">Add payout account first</p>
                <div className="flex gap-2">
                  <Button type="button" variant={payoutType === "bank" ? "default" : "outline"} onClick={() => setPayoutType("bank")}>
                    Bank
                  </Button>
                  <Button type="button" variant={payoutType === "upi" ? "default" : "outline"} onClick={() => setPayoutType("upi")}>
                    UPI
                  </Button>
                </div>
                <input className="w-full rounded-lg border px-3 py-2" placeholder="Account holder name" value={holder} onChange={(e) => setHolder(e.target.value)} required />
                {payoutType === "upi" ? (
                  <input className="w-full rounded-lg border px-3 py-2" placeholder="UPI ID" value={upi} onChange={(e) => setUpi(e.target.value)} required />
                ) : (
                  <>
                    <input className="w-full rounded-lg border px-3 py-2" placeholder="Account number" value={account} onChange={(e) => setAccount(e.target.value)} required />
                    <input className="w-full rounded-lg border px-3 py-2" placeholder="IFSC" value={ifsc} onChange={(e) => setIfsc(e.target.value)} required />
                    <input className="w-full rounded-lg border px-3 py-2" placeholder="Bank name" value={bankName} onChange={(e) => setBankName(e.target.value)} required />
                  </>
                )}
                <Button type="submit" disabled={busy}>{busy ? "Saving…" : "Save account"}</Button>
              </form>
            ) : (
              <>
                <div className="rounded-xl border p-4 text-sm">
                  <p className="font-medium">{summary?.bank?.account_holder}</p>
                  <p>{summary?.bank?.upi_id || summary?.bank?.account_number}</p>
                  {!summary?.bank?.upi_id ? (
                    <p className="text-muted-foreground">
                      {summary?.bank?.bank_name} · {summary?.bank?.ifsc}
                    </p>
                  ) : null}
                </div>
                <form className="space-y-3" onSubmit={onWithdraw}>
                  <input
                    className="w-full rounded-lg border px-3 py-2"
                    placeholder="Amount (₹)"
                    value={amount}
                    onChange={(e) => setAmount(e.target.value)}
                    inputMode="decimal"
                    required
                  />
                  <Button type="submit" disabled={busy || (summary?.balance ?? 0) < 1}>
                    {busy ? "Submitting…" : "Request withdrawal"}
                  </Button>
                </form>
              </>
            )}
          </div>
        )}
      </div>
    </AppShell>
  );
}
