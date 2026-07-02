"use client";

import { useState } from "react";
import { Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetFooter,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import { cn } from "@/lib/utils";

export const CANCEL_RIDE_REASONS = [
  "Changed my mind",
  "Captain is taking too long",
  "Booked by mistake",
  "Found another ride",
  "Other",
] as const;

interface CancelRideSheetProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onConfirm: (reason: string) => Promise<void>;
  title?: string;
  description?: string;
}

export function CancelRideSheet({
  open,
  onOpenChange,
  onConfirm,
  title = "Cancel ride?",
  description = "Please tell us why you want to cancel. This helps us improve your experience.",
}: CancelRideSheetProps) {
  const [selectedReason, setSelectedReason] = useState<string>(CANCEL_RIDE_REASONS[0]);
  const [isCancelling, setIsCancelling] = useState(false);
  const [error, setError] = useState("");

  const handleConfirm = async () => {
    setError("");
    setIsCancelling(true);
    try {
      await onConfirm(selectedReason);
      onOpenChange(false);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unable to cancel ride. Please try again.");
    } finally {
      setIsCancelling(false);
    }
  };

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent side="bottom" className="rounded-t-[28px] px-6 pb-8">
        <SheetHeader className="px-0 pt-2 text-left">
          <SheetTitle className="font-heading text-xl font-bold">{title}</SheetTitle>
          <SheetDescription>{description}</SheetDescription>
        </SheetHeader>

        <div className="mt-2 space-y-2">
          {CANCEL_RIDE_REASONS.map((reason) => {
            const selected = selectedReason === reason;
            return (
              <button
                key={reason}
                type="button"
                onClick={() => setSelectedReason(reason)}
                className={cn(
                  "flex w-full items-center justify-between rounded-2xl border px-4 py-3.5 text-left text-sm font-medium transition-colors",
                  selected
                    ? "border-destructive/40 bg-destructive/5 text-foreground"
                    : "border-border bg-card text-foreground hover:bg-muted/40"
                )}
              >
                <span>{reason}</span>
                <span
                  className={cn(
                    "h-4 w-4 rounded-full border-2",
                    selected ? "border-destructive bg-destructive" : "border-muted-foreground/40"
                  )}
                />
              </button>
            );
          })}
        </div>

        {error && <p className="mt-3 text-sm text-destructive">{error}</p>}

        <SheetFooter className="mt-6 gap-3 px-0 sm:flex-col">
          <Button
            type="button"
            variant="destructive"
            size="lg"
            className="h-12 w-full rounded-2xl bg-destructive text-destructive-foreground hover:bg-destructive/90"
            disabled={isCancelling}
            onClick={() => void handleConfirm()}
          >
            {isCancelling ? (
              <span className="inline-flex items-center gap-2">
                <Loader2 className="h-4 w-4 animate-spin" />
                Cancelling...
              </span>
            ) : (
              "Yes, cancel ride"
            )}
          </Button>
          <Button
            type="button"
            variant="outline"
            size="lg"
            className="h-12 w-full rounded-2xl"
            disabled={isCancelling}
            onClick={() => onOpenChange(false)}
          >
            Keep ride
          </Button>
        </SheetFooter>
      </SheetContent>
    </Sheet>
  );
}
