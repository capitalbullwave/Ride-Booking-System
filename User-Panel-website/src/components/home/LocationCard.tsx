"use client";

import { useRouter } from "next/navigation";
import { ArrowDownUp } from "lucide-react";
import { Button } from "@/components/ui/button";
import { buildLocationSearchUrl, type LocationFieldType } from "@/lib/location-search";
import { buildBookUrl } from "@/lib/ride-booking";
import { ROUTES } from "@/constants/routes";

interface LocationCardProps {
  pickup: string;
  dropoff: string;
  onSwap: () => void;
  returnTo?: string;
}

export function LocationCard({
  pickup,
  dropoff,
  onSwap,
  returnTo = ROUTES.home,
}: LocationCardProps) {
  const router = useRouter();

  const openLocationSearch = (field: LocationFieldType) => {
    router.push(
      buildLocationSearchUrl({
        field,
        returnTo,
        pickup,
        dropoff,
      })
    );
  };

  const handleFindRide = () => {
    if (!pickup || !dropoff) {
      openLocationSearch(!pickup ? "pickup" : "dropoff");
      return;
    }
    router.push(buildBookUrl(pickup, dropoff));
  };

  return (
    <div className="rounded-[20px] border border-border bg-card p-4 shadow-md">
      <div className="relative flex flex-col gap-3">
        <div className="absolute top-10 bottom-10 left-[1.15rem] w-px border-l border-dashed border-muted-foreground/40" />

        <button
          type="button"
          onClick={() => openLocationSearch("pickup")}
          className="flex w-full items-start gap-3 rounded-[18px] border border-border bg-card px-4 py-3.5 text-left shadow-sm transition-colors hover:bg-muted/30"
        >
          <span className="mt-1 h-2.5 w-2.5 shrink-0 rounded-full bg-success" />
          <span className="min-w-0 flex-1 pr-8">
            <span className="block text-sm font-semibold text-success">Pickup</span>
            <span
              className={`mt-0.5 block truncate text-sm leading-snug ${
                pickup ? "font-medium text-foreground" : "text-muted-foreground"
              }`}
            >
              {pickup || "Current Location"}
            </span>
          </span>
        </button>

        <button
          type="button"
          onClick={() => openLocationSearch("dropoff")}
          className="flex w-full items-start gap-3 rounded-[18px] border border-border bg-card px-4 py-3.5 text-left shadow-sm transition-colors hover:bg-muted/30"
        >
          <span className="mt-1 h-2.5 w-2.5 shrink-0 rounded-full bg-destructive" />
          <span className="min-w-0 flex-1 pr-8">
            <span className="block text-sm font-semibold text-destructive">Drop</span>
            <span
              className={`mt-0.5 block truncate text-sm leading-snug ${
                dropoff ? "font-medium text-foreground" : "text-muted-foreground"
              }`}
            >
              {dropoff || "Where are you going?"}
            </span>
          </span>
        </button>

        <button
          type="button"
          onClick={onSwap}
          className="absolute top-1/2 right-1 z-10 flex h-8 w-8 -translate-y-1/2 items-center justify-center rounded-full border border-border bg-card text-muted-foreground shadow-sm transition-all hover:bg-muted hover:text-foreground active:scale-95"
          aria-label="Swap pickup and drop"
        >
          <ArrowDownUp className="h-4 w-4" />
        </button>
      </div>

      <Button
        type="button"
        onClick={handleFindRide}
        className="mt-4 h-14 w-full rounded-[16px] text-base font-bold shadow-md shadow-primary/15 transition-all active:scale-[0.98]"
      >
        Find a Ride
      </Button>
    </div>
  );
}
