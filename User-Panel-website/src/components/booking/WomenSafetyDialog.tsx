"use client";

import { ShieldCheck } from "lucide-react";
import { Button } from "@/components/ui/button";

interface WomenSafetyDialogProps {
  open: boolean;
  emergencyPhone?: string | null;
  onEnable: () => void;
  onSkip: () => void;
}

export function WomenSafetyDialog({
  open,
  emergencyPhone,
  onEnable,
  onSkip,
}: WomenSafetyDialogProps) {
  if (!open) return null;

  const maskedPhone = emergencyPhone?.trim() || null;

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/40 p-4 sm:items-center">
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby="women-safety-title"
        className="w-full max-w-md rounded-[24px] border border-border bg-card p-6 shadow-2xl"
      >
        <div className="mb-4 flex h-14 w-14 items-center justify-center rounded-full bg-primary/10">
          <ShieldCheck className="h-7 w-7 text-primary" />
        </div>

        <h2 id="women-safety-title" className="font-heading text-xl font-bold text-foreground">
          Enable Women Safety?
        </h2>
        <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
          Turn on Women Safety to alert your emergency contact
          {maskedPhone ? ` (${maskedPhone})` : ""} and our admin team about this ride. You will
          also receive a confirmation on your phone.
        </p>

        <div className="mt-6 flex flex-col gap-2.5">
          <Button
            type="button"
            onClick={onEnable}
            className="h-12 w-full rounded-[16px] text-base font-semibold"
          >
            Enable &amp; book ride
          </Button>
          <Button
            type="button"
            variant="ghost"
            onClick={onSkip}
            className="h-11 w-full rounded-[16px] text-sm font-medium text-muted-foreground"
          >
            Continue without safety
          </Button>
        </div>
      </div>
    </div>
  );
}
