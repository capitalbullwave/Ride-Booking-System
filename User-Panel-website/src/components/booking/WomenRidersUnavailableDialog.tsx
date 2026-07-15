"use client";

import { UserSearch } from "lucide-react";
import { Button } from "@/components/ui/button";

interface WomenRidersUnavailableDialogProps {
  open: boolean;
  onContinue: () => void;
  onCancel: () => void;
  isLoading?: boolean;
}

export function WomenRidersUnavailableDialog({
  open,
  onContinue,
  onCancel,
  isLoading = false,
}: WomenRidersUnavailableDialogProps) {
  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/40 p-4 sm:items-center">
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby="women-riders-unavailable-title"
        className="w-full max-w-md rounded-[24px] border border-border bg-card p-6 shadow-2xl"
      >
        <div className="mb-4 flex h-14 w-14 items-center justify-center rounded-full bg-primary/10">
          <UserSearch className="h-7 w-7 text-primary" />
        </div>

        <h2
          id="women-riders-unavailable-title"
          className="font-heading text-xl font-bold text-foreground"
        >
          Women captains unavailable
        </h2>
        <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
          No women captains are available nearby right now. Would you like to continue with other
          captains?
        </p>

        <div className="mt-6 flex flex-col gap-2.5">
          <Button
            type="button"
            onClick={onContinue}
            disabled={isLoading}
            className="h-12 w-full rounded-[16px] text-base font-semibold"
          >
            {isLoading ? "Please wait..." : "Continue with other captains"}
          </Button>
          <Button
            type="button"
            variant="ghost"
            onClick={onCancel}
            disabled={isLoading}
            className="h-11 w-full rounded-[16px] text-sm font-medium text-muted-foreground"
          >
            Cancel ride
          </Button>
        </div>
      </div>
    </div>
  );
}
