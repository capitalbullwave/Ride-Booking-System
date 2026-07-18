"use client";

import { useEffect, useState } from "react";
import { Loader2, Tag, X } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  listCoupons,
  validateCoupon,
  type AppliedCoupon,
  type RideCoupon,
} from "@/lib/coupons-api";
import { formatFare } from "@/lib/ride-booking";

interface BookingOffersSheetProps {
  open: boolean;
  orderAmount: number;
  appliedCode?: string | null;
  onClose: () => void;
  onApply: (applied: AppliedCoupon) => void;
  onClear: () => void;
}

export function BookingOffersSheet({
  open,
  orderAmount,
  appliedCode,
  onClose,
  onApply,
  onClear,
}: BookingOffersSheetProps) {
  const [coupons, setCoupons] = useState<RideCoupon[]>([]);
  const [loading, setLoading] = useState(false);
  const [applying, setApplying] = useState<string | null>(null);
  const [manualCode, setManualCode] = useState("");
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!open) return;
    let cancelled = false;
    setLoading(true);
    setError(null);
    void listCoupons()
      .then((rows) => {
        if (!cancelled) setCoupons(rows);
      })
      .catch(() => {
        if (!cancelled) setCoupons([]);
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [open]);

  if (!open) return null;

  const applyCode = async (code: string) => {
    const trimmed = code.trim();
    if (!trimmed) return;
    setApplying(trimmed.toUpperCase());
    setError(null);
    try {
      const applied = await validateCoupon(trimmed, orderAmount);
      onApply(applied);
      onClose();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Invalid coupon");
    } finally {
      setApplying(null);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/40 sm:items-center sm:p-4">
      <div className="max-h-[80vh] w-full max-w-lg overflow-hidden rounded-t-[24px] bg-card shadow-xl sm:rounded-[24px]">
        <div className="flex items-center justify-between border-b border-border px-4 py-3">
          <h2 className="font-heading text-lg font-bold">Offers</h2>
          <button
            type="button"
            onClick={onClose}
            className="flex h-9 w-9 items-center justify-center rounded-full hover:bg-muted"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        <div className="space-y-4 overflow-y-auto p-4">
          <div className="flex gap-2">
            <input
              value={manualCode}
              onChange={(e) => setManualCode(e.target.value.toUpperCase())}
              placeholder="Enter promo code"
              className="h-11 flex-1 rounded-xl border border-border bg-background px-3 text-sm outline-none focus:border-primary"
            />
            <Button
              type="button"
              disabled={!!applying || !manualCode.trim()}
              onClick={() => void applyCode(manualCode)}
            >
              {applying === manualCode.trim().toUpperCase() ? (
                <Loader2 className="h-4 w-4 animate-spin" />
              ) : (
                "Apply"
              )}
            </Button>
          </div>

          {appliedCode ? (
            <button
              type="button"
              onClick={() => {
                onClear();
                onClose();
              }}
              className="w-full rounded-xl border border-primary/30 bg-primary/10 px-3 py-2 text-left text-sm font-semibold text-primary"
            >
              Applied: {appliedCode} · Tap to remove
            </button>
          ) : null}

          {error ? <p className="text-sm text-destructive">{error}</p> : null}

          {loading ? (
            <div className="flex justify-center py-8">
              <Loader2 className="h-6 w-6 animate-spin text-primary" />
            </div>
          ) : coupons.length === 0 ? (
            <p className="py-6 text-center text-sm text-muted-foreground">
              No offers available right now
            </p>
          ) : (
            <ul className="space-y-2">
              {coupons.map((coupon) => (
                <li key={coupon.id || coupon.code}>
                  <button
                    type="button"
                    onClick={() => void applyCode(coupon.code)}
                    disabled={!!applying}
                    className="flex w-full items-start gap-3 rounded-xl border border-border px-3 py-3 text-left hover:bg-muted/40"
                  >
                    <Tag className="mt-0.5 h-4 w-4 text-primary" />
                    <span className="min-w-0 flex-1">
                      <span className="block text-sm font-bold text-foreground">
                        {coupon.code}
                      </span>
                      <span className="mt-0.5 block text-sm text-muted-foreground">
                        {coupon.title}
                        {coupon.discount_value != null
                          ? ` · Save ${formatFare(coupon.discount_value)}`
                          : ""}
                      </span>
                    </span>
                    {applying === coupon.code.toUpperCase() ? (
                      <Loader2 className="h-4 w-4 animate-spin text-primary" />
                    ) : null}
                  </button>
                </li>
              ))}
            </ul>
          )}
        </div>
      </div>
    </div>
  );
}
