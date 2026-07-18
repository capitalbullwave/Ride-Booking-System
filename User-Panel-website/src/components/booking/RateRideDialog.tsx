"use client";

import { useState } from "react";
import { Loader2, Star } from "lucide-react";
import { Button } from "@/components/ui/button";
import { rateRide } from "@/lib/ride-api";
import { cn } from "@/lib/utils";

interface RateRideDialogProps {
  open: boolean;
  rideId: string;
  driverName?: string;
  onDone: () => void;
}

export function RateRideDialog({
  open,
  rideId,
  driverName,
  onDone,
}: RateRideDialogProps) {
  const [rating, setRating] = useState(5);
  const [comment, setComment] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  if (!open) return null;

  const handleSubmit = async () => {
    setLoading(true);
    setError(null);
    try {
      await rateRide(rideId, rating, comment.trim() || undefined);
      onDone();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unable to submit rating");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
      <div className="w-full max-w-md rounded-[24px] bg-card p-6 shadow-xl">
        <h2 className="font-heading text-xl font-bold text-foreground">Rate your trip</h2>
        <p className="mt-1 text-sm text-muted-foreground">
          How was your ride with {driverName || "your captain"}?
        </p>

        <div className="mt-5 flex justify-center gap-2">
          {[1, 2, 3, 4, 5].map((value) => (
            <button
              key={value}
              type="button"
              onClick={() => setRating(value)}
              className="p-1"
              aria-label={`${value} stars`}
            >
              <Star
                className={cn(
                  "h-8 w-8",
                  value <= rating
                    ? "fill-primary text-primary"
                    : "text-muted-foreground"
                )}
              />
            </button>
          ))}
        </div>

        <textarea
          value={comment}
          onChange={(e) => setComment(e.target.value)}
          placeholder="Optional feedback"
          rows={3}
          className="mt-5 w-full rounded-xl border border-border bg-background px-3 py-2 text-sm outline-none focus:border-primary"
        />

        {error ? <p className="mt-2 text-sm text-destructive">{error}</p> : null}

        <div className="mt-5 flex gap-2">
          <Button type="button" variant="outline" className="flex-1" onClick={onDone}>
            Skip
          </Button>
          <Button
            type="button"
            className="flex-1"
            disabled={loading}
            onClick={() => void handleSubmit()}
          >
            {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : "Submit"}
          </Button>
        </div>
      </div>
    </div>
  );
}
