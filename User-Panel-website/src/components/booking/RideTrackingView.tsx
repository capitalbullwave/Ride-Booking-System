"use client";

import { useEffect, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { motion } from "framer-motion";
import { ChevronLeft, Loader2, MapPin, Navigation2, Phone, Share2, Star, XCircle } from "lucide-react";
import { CancelRideSheet } from "@/components/booking/CancelRideSheet";
import { RideTrackingMap } from "@/components/booking/RideTrackingMap";
import { Button } from "@/components/ui/button";
import { ROUTES } from "@/constants/routes";
import { RIDE_VEHICLE_OPTIONS } from "@/data/ride-options";
import { cancelRide, getRide, getRideTracking } from "@/lib/ride-api";
import { formatFare, isRideVehicleId } from "@/lib/ride-booking";
import { authFetch } from "@/lib/api";

interface DriverInfo {
  name: string;
  rating: number;
  vehicle: string;
}

export function RideTrackingView() {
  const router = useRouter();
  const searchParams = useSearchParams();

  const pickup = searchParams.get("pickup") || "";
  const dropoff = searchParams.get("dropoff") || "";
  const vehicleParam = searchParams.get("vehicle");
  const rideId = searchParams.get("rideId");
  const vehicle = isRideVehicleId(vehicleParam) ? vehicleParam : "bike";

  const [driver, setDriver] = useState<DriverInfo>({
    name: "Captain Demo",
    rating: 4.9,
    vehicle: "Bike Taxi",
  });
  const [etaMinutes, setEtaMinutes] = useState(4);
  const [fare, setFare] = useState<number | null>(null);
  const [rideStatus, setRideStatus] = useState<string>("confirmed");
  const [isLoading, setIsLoading] = useState(Boolean(rideId));
  const [cancelOpen, setCancelOpen] = useState(false);

  const vehicleOption = RIDE_VEHICLE_OPTIONS.find((v) => v.id === vehicle)!;
  const canCancel = Boolean(rideId) && !["cancelled", "completed"].includes(rideStatus);

  useEffect(() => {
    if (!pickup || !dropoff) {
      router.replace(ROUTES.landing);
    }
  }, [pickup, dropoff, router]);

  useEffect(() => {
    if (!rideId) return;

    const id = rideId;

    async function loadRide() {
      try {
        const [ride, tracking, driverData] = await Promise.all([
          getRide(id),
          getRideTracking(id),
          authFetch<DriverInfo>(`/ride/${id}/driver`, undefined, "Unable to load driver"),
        ]);
        setDriver(driverData);
        setFare(ride.fare_estimate);
        setRideStatus(ride.status);
        if (typeof tracking.eta_minutes === "number") {
          setEtaMinutes(tracking.eta_minutes);
        }
      } finally {
        setIsLoading(false);
      }
    }

    void loadRide();
  }, [rideId]);

  const handleCancelRide = async (reason: string) => {
    if (!rideId) return;
    const ride = await cancelRide(rideId, reason);
    setRideStatus(ride.status);
    router.push(ROUTES.home);
  };

  if (!pickup || !dropoff) {
    return null;
  }

  if (isLoading) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    );
  }

  return (
    <>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        className="min-h-screen w-full bg-background font-sans"
      >
        <div className="relative">
          <RideTrackingMap vehicleImage={vehicleOption.image} vehicleName={vehicleOption.name} />

          <div className="absolute top-0 right-0 left-0 z-20 p-4">
            <div className="flex items-center justify-between">
              <button
                type="button"
                onClick={() => router.push(ROUTES.home)}
                className="flex h-11 w-11 items-center justify-center rounded-full bg-card shadow-md transition-colors hover:bg-muted"
              >
                <ChevronLeft className="h-6 w-6" />
              </button>

              <div className="flex items-center gap-2 rounded-full bg-card px-4 py-2 shadow-md">
                <span className="h-2 w-2 animate-pulse rounded-full bg-success" />
                <span className="text-sm font-bold text-foreground">Live tracking</span>
              </div>

              <button
                type="button"
                className="flex h-11 w-11 items-center justify-center rounded-full bg-card shadow-md transition-colors hover:bg-muted"
              >
                <Share2 className="h-5 w-5" />
              </button>
            </div>
          </div>
        </div>

        <div className="-mt-5 rounded-t-[32px] border-t border-border bg-card px-6 pt-6 pb-10 shadow-[0_-10px_40px_rgba(49,82,110,0.1)]">
          <div className="mx-auto mb-5 h-1.5 w-12 rounded-full bg-border" />

          <div className="mb-6 flex items-end justify-between gap-4">
            <div>
              <h2 className="font-heading text-3xl font-bold text-foreground">{etaMinutes} min</h2>
              <p className="text-sm font-semibold text-muted-foreground">away • heading to pickup</p>
            </div>
            {fare !== null && (
              <p className="font-heading text-xl font-bold text-foreground">{formatFare(fare)}</p>
            )}
          </div>

          <div className="mb-6 flex items-center gap-4 rounded-[24px] border border-border bg-muted/30 p-4">
            <div className="flex h-14 w-14 items-center justify-center rounded-full bg-primary text-lg font-bold text-primary-foreground">
              {driver.name.charAt(0)}
            </div>
            <div className="flex-1">
              <p className="font-heading text-lg font-bold text-foreground">{driver.name}</p>
              <div className="mt-1 flex items-center gap-2 text-sm text-muted-foreground">
                <Star className="h-4 w-4 fill-primary text-primary" />
                <span className="font-semibold text-foreground">{driver.rating}</span>
                <span>• {driver.vehicle}</span>
              </div>
            </div>
            <button
              type="button"
              className="flex h-12 w-12 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-md"
            >
              <Phone className="h-5 w-5" />
            </button>
          </div>

          <div className="space-y-3">
            <div className="flex items-start gap-3 rounded-[18px] border border-border bg-card p-4">
              <MapPin className="mt-0.5 h-5 w-5 shrink-0 text-success" />
              <div>
                <p className="text-xs font-semibold uppercase tracking-wide text-success">Pickup</p>
                <p className="mt-1 text-sm text-foreground">{pickup}</p>
              </div>
            </div>
            <div className="flex items-start gap-3 rounded-[18px] border border-border bg-card p-4">
              <Navigation2 className="mt-0.5 h-5 w-5 shrink-0 text-destructive" />
              <div>
                <p className="text-xs font-semibold uppercase tracking-wide text-destructive">Drop</p>
                <p className="mt-1 text-sm text-foreground">{dropoff}</p>
              </div>
            </div>
          </div>

          {canCancel && (
            <Button
              type="button"
              variant="destructive"
              size="lg"
              className="mt-8 h-12 w-full rounded-2xl border border-destructive/20 bg-destructive/10 text-base font-semibold text-destructive hover:bg-destructive/15"
              onClick={() => setCancelOpen(true)}
            >
              <XCircle className="h-5 w-5" />
              Cancel ride
            </Button>
          )}
        </div>
      </motion.div>

      <CancelRideSheet
        open={cancelOpen}
        onOpenChange={setCancelOpen}
        onConfirm={handleCancelRide}
      />
    </>
  );
}
