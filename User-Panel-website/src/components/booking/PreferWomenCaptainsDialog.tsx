"use client";

import { UserRound } from "lucide-react";
import { Button } from "@/components/ui/button";

interface PreferWomenCaptainsDialogProps {
  open: boolean;
  onEnable: () => void;
  onSkip: () => void;
}

export function PreferWomenCaptainsDialog({
  open,
  onEnable,
  onSkip,
}: PreferWomenCaptainsDialogProps) {
  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/40 p-4 sm:items-center">
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby="prefer-women-captains-title"
        className="w-full max-w-md rounded-[24px] border border-border bg-card p-6 shadow-2xl"
      >
        <div className="mb-4 flex h-14 w-14 items-center justify-center rounded-full bg-primary/10">
          <UserRound className="h-7 w-7 text-primary" />
        </div>

        <h2
          id="prefer-women-captains-title"
          className="font-heading text-xl font-bold text-foreground"
        >
          Prefer women captains?
        </h2>
        <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
          Enable this to request women captains only for this ride. If disabled, your request will
          go to all nearby captains.
        </p>

        <div className="mt-6 flex flex-col gap-2.5">
          <Button
            type="button"
            onClick={onEnable}
            className="h-12 w-full rounded-[16px] text-base font-semibold"
          >
            Enable women captains
          </Button>
          <Button
            type="button"
            variant="ghost"
            onClick={onSkip}
            className="h-11 w-full rounded-[16px] text-sm font-medium text-muted-foreground"
          >
            Continue with any captain
          </Button>
        </div>
      </div>
    </div>
  );
}
