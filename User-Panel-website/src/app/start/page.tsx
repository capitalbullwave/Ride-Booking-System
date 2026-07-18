"use client";

import { Suspense, useEffect } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { buildLocationSearchUrl } from "@/lib/location-search";
import { buildBookUrl, isRideVehicleId, parseTripCoords } from "@/lib/ride-booking";
import { ROUTES } from "@/constants/routes";

function StartView() {
  const router = useRouter();
  const searchParams = useSearchParams();

  useEffect(() => {
    const pickup = searchParams.get("pickup") || "";
    const dropoff = searchParams.get("dropoff") || "";
    const tab = searchParams.get("tab") || "rides";
    const vehicle = searchParams.get("vehicle");
    const category = searchParams.get("category");
    const coords = parseTripCoords(searchParams);

    const safeVehicle = isRideVehicleId(vehicle) ? vehicle : undefined;
    const tripExtras = {
      pickupLat: coords.pickupLat,
      pickupLng: coords.pickupLng,
      dropoffLat: coords.dropoffLat,
      dropoffLng: coords.dropoffLng,
      categoryId: category || undefined,
    };

    if (!pickup) {
      router.replace(
        buildLocationSearchUrl({
          field: "pickup",
          returnTo: `${ROUTES.start}?tab=${encodeURIComponent(tab)}${safeVehicle ? `&vehicle=${encodeURIComponent(safeVehicle)}` : ""}${category ? `&category=${encodeURIComponent(category)}` : ""}`,
          pickup,
          dropoff,
          tab,
          coords: tripExtras,
        })
      );
      return;
    }

    if (!dropoff) {
      router.replace(
        buildLocationSearchUrl({
          field: "dropoff",
          returnTo: `${ROUTES.start}?tab=${encodeURIComponent(tab)}&pickup=${encodeURIComponent(pickup)}${safeVehicle ? `&vehicle=${encodeURIComponent(safeVehicle)}` : ""}${category ? `&category=${encodeURIComponent(category)}` : ""}`,
          pickup,
          dropoff,
          tab,
          coords: tripExtras,
        })
      );
      return;
    }

    router.replace(buildBookUrl(pickup, dropoff, tab, safeVehicle, tripExtras));
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
