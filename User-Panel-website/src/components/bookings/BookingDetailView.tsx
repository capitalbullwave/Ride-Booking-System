"use client";

import { useEffect, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { ArrowLeft, Loader2, MapPin, Navigation2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { ROUTES } from "@/constants/routes";
import { buildTrackingUrl, formatFare, isRideVehicleId } from "@/lib/ride-booking";
import { getRide, isDriverAssigned, isRideInProgress, type Ride } from "@/lib/ride-api";

export function BookingDetailView() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const rideId = searchParams.get("id") || "";
  const [ride, setRide] = useState<Ride | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!rideId) {
      router.replace(ROUTES.bookings);
      return;
    }
    let cancelled = false;
    void getRide(rideId)
      .then((data) => {
        if (!cancelled) setRide(data);
      })
      .catch((err) => {
        if (!cancelled) {
          setError(err instanceof Error ? err.message : "Unable to load booking");
        }
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [rideId, router]);

  if (loading) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    );
  }

  if (!ride) {
    return (
      <div className="flex min-h-screen flex-col items-center justify-center gap-3 px-6">
        <p className="text-sm text-destructive">{error || "Booking not found"}</p>
        <Button onClick={() => router.push(ROUTES.bookings)}>Back to bookings</Button>
      </div>
    );
  }

  const canTrack = isRideInProgress(ride.status) || isDriverAssigned(ride.status);

  return (
    <div className="min-h-screen bg-background font-sans">
      <header className="flex items-center gap-3 border-b border-border px-4 py-4">
        <button
          type="button"
          onClick={() => router.push(ROUTES.bookings)}
          className="flex h-10 w-10 items-center justify-center rounded-full hover:bg-muted"
        >
          <ArrowLeft className="h-5 w-5" />
        </button>
        <h1 className="font-heading text-lg font-bold">Booking details</h1>
      </header>

      <div className="mx-auto max-w-xl space-y-4 px-4 py-6">
        <div className="rounded-[20px] border border-border bg-card p-4">
          <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
            Status
          </p>
          <p className="mt-1 font-heading text-xl font-bold text-foreground">
            {ride.status.replace(/_/g, " ")}
          </p>
          <p className="mt-2 text-sm text-muted-foreground">
            {new Date(ride.created_at).toLocaleString("en-IN")}
          </p>
          {ride.public_id ? (
            <p className="mt-1 text-xs text-muted-foreground">ID: {ride.public_id}</p>
          ) : null}
        </div>

        <div className="space-y-3 rounded-[20px] border border-border bg-card p-4">
          <div className="flex items-start gap-3">
            <MapPin className="mt-0.5 h-4 w-4 text-success" />
            <div>
              <p className="text-xs font-semibold text-success">Pickup</p>
              <p className="text-sm text-foreground">{ride.pickup_address}</p>
            </div>
          </div>
          <div className="flex items-start gap-3">
            <Navigation2 className="mt-0.5 h-4 w-4 text-destructive" />
            <div>
              <p className="text-xs font-semibold text-destructive">Drop</p>
              <p className="text-sm text-foreground">{ride.dropoff_address}</p>
            </div>
          </div>
        </div>

        <div className="rounded-[20px] border border-border bg-card p-4">
          <p className="text-sm text-muted-foreground">Fare</p>
          <p className="font-heading text-2xl font-bold">
            {formatFare(ride.fare_final ?? ride.fare_estimate ?? 0)}
          </p>
          {ride.payment_method ? (
            <p className="mt-1 text-sm text-muted-foreground">
              Paid via {ride.payment_method}
            </p>
          ) : null}
          {ride.driver?.name ? (
            <p className="mt-2 text-sm text-foreground">Captain: {ride.driver.name}</p>
          ) : null}
        </div>

        {canTrack ? (
          <Button
            className="h-12 w-full rounded-2xl"
            onClick={() =>
              router.push(
                buildTrackingUrl(
                  ride.pickup_address,
                  ride.dropoff_address,
                  isRideVehicleId(null) ? "bike" : "bike",
                  "rides",
                  ride.id
                )
              )
            }
          >
            Open live tracking
          </Button>
        ) : null}
      </div>
    </div>
  );
}
