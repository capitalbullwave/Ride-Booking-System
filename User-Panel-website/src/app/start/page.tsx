"use client";

import { Suspense, useEffect } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { buildLocationSearchUrl } from "@/lib/location-search";
import { buildBookUrl } from "@/lib/ride-booking";
import { ROUTES } from "@/constants/routes";
import { isRideVehicleId } from "@/lib/ride-booking";

function StartView() {
  const router = useRouter();
  const searchParams = useSearchParams();

  useEffect(() => {
    const pickup = searchParams.get("pickup") || "";
    const dropoff = searchParams.get("dropoff") || "";
    const tab = searchParams.get("tab") || "rides";
    const vehicle = searchParams.get("vehicle");

    const safeVehicle = isRideVehicleId(vehicle) ? vehicle : undefined;

    if (!pickup) {
      router.replace(
        buildLocationSearchUrl({
          field: "pickup",
          returnTo: `${ROUTES.start}?tab=${encodeURIComponent(tab)}${safeVehicle ? `&vehicle=${encodeURIComponent(safeVehicle)}` : ""}`,
          pickup,
          dropoff,
          tab,
        })
      );
      return;
    }

    if (!dropoff) {
      router.replace(
        buildLocationSearchUrl({
          field: "dropoff",
          returnTo: `${ROUTES.start}?tab=${encodeURIComponent(tab)}&pickup=${encodeURIComponent(pickup)}${safeVehicle ? `&vehicle=${encodeURIComponent(safeVehicle)}` : ""}`,
          pickup,
          dropoff,
          tab,
        })
      );
      return;
    }

    router.replace(buildBookUrl(pickup, dropoff, tab, safeVehicle));
  }, [router, searchParams]);

  return (
    <div className="flex min-h-screen items-center justify-center bg-background text-muted-foreground">
      Getting things ready…
    </div>
  );
}

function StartFallback() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-background text-muted-foreground">
      Loading…
    </div>
  );
}

export default function StartPage() {
  return (
    <Suspense fallback={<StartFallback />}>
      <StartView />
    </Suspense>
  );
}

