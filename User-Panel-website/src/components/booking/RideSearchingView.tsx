"use client";

import { useEffect, useRef, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { motion } from "framer-motion";
import { XCircle } from "lucide-react";
import { CancelRideSheet } from "@/components/booking/CancelRideSheet";
import { WomenRidersUnavailableDialog } from "@/components/booking/WomenRidersUnavailableDialog";
import { ServiceImage } from "@/components/home/ServiceImage";
import { Button } from "@/components/ui/button";
import { WaveGoLogo } from "@/components/layout/WaveGoLogo";
import { ROUTES } from "@/constants/routes";
import { RIDE_VEHICLE_OPTIONS } from "@/data/ride-options";
import { bookRide, cancelRide, continueWithAllRiders } from "@/lib/ride-api";
import { buildBookUrl, buildTrackingUrl, isRideVehicleId } from "@/lib/ride-booking";
import { VEHICLE_TO_CATEGORY_SLUG } from "@/lib/vehicle-map";
import { getVehicleCategories } from "@/lib/home-api";

export function RideSearchingView() {
  const router = useRouter();
  const searchParams = useSearchParams();

  const pickup = searchParams.get("pickup") || "";
  const dropoff = searchParams.get("dropoff") || "";
  const tab = searchParams.get("tab") || "rides";
  const vehicleParam = searchParams.get("vehicle");
  const categoryIdParam = searchParams.get("categoryId");
  const preferWomenRiders = searchParams.get("preferWomen") === "1";
  const vehicle = isRideVehicleId(vehicleParam) ? vehicleParam : "bike";

  const [progress, setProgress] = useState(10);
  const [status, setStatus] = useState("Finding nearby captains...");
  const [cancelOpen, setCancelOpen] = useState(false);
  const [preferenceOpen, setPreferenceOpen] = useState(false);
  const [preferenceLoading, setPreferenceLoading] = useState(false);
  const rideIdRef = useRef<string | null>(null);
  const bookingStarted = useRef(false);
  const trackingTimers = useRef<number[]>([]);

  const vehicleOption = RIDE_VEHICLE_OPTIONS.find((v) => v.id === vehicle);
  const vehicleName = vehicleOption?.name ?? "Ride";

  const clearTrackingTimers = () => {
    trackingTimers.current.forEach((id) => window.clearTimeout(id));
    trackingTimers.current = [];
  };

  const proceedAfterMatch = (rideId: string) => {
    clearTrackingTimers();
    setProgress(60);
    setStatus("Searching for nearby captains...");

    trackingTimers.current.push(
      window.setTimeout(() => {
        setProgress(100);
        setStatus("Captain found!");
      }, 1500)
    );

    trackingTimers.current.push(
      window.setTimeout(() => {
        router.push(buildTrackingUrl(pickup, dropoff, vehicle, tab, rideId));
      }, 2500)
    );
  };

  useEffect(() => {
    if (!pickup || !dropoff) {
      router.replace(ROUTES.landing);
      return;
    }

    if (bookingStarted.current) return;
    bookingStarted.current = true;

    async function startBooking() {
      try {
        let categoryId = categoryIdParam ?? undefined;
        if (!categoryId) {
          const slug = VEHICLE_TO_CATEGORY_SLUG[vehicle];
          if (slug) {
            const categories = await getVehicleCategories();
            categoryId = categories.find((c) => c.slug === slug)?.id;
          }
        }

        const ride = await bookRide({
          pickup_address: pickup,
          dropoff_address: dropoff,
          vehicle_category_id: categoryId,
          prefer_women_riders: preferWomenRiders,
        });
        rideIdRef.current = ride.id;

        if (ride.requires_rider_preference_choice) {
          setStatus("Waiting for your confirmation...");
          setPreferenceOpen(true);
          return;
        }

        proceedAfterMatch(ride.id);
      } catch {
        setStatus("Unable to book ride. Please try again.");
        bookingStarted.current = false;
      }
    }

    const timer1 = window.setTimeout(() => {
      setProgress(35);
      setStatus("Matching your ride...");
    }, 800);

    void startBooking();

    return () => {
      window.clearTimeout(timer1);
      clearTrackingTimers();
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [pickup, dropoff, vehicle, tab, categoryIdParam, preferWomenRiders, router]);

  const handleCancelRide = async (reason: string) => {
    if (rideIdRef.current) {
      await cancelRide(rideIdRef.current, reason);
    }
    router.push(buildBookUrl(pickup, dropoff, tab, vehicle));
  };

  const handlePreferenceContinue = async () => {
    const rideId = rideIdRef.current;
    if (!rideId) return;
    setPreferenceLoading(true);
    try {
      await continueWithAllRiders(rideId);
      setPreferenceOpen(false);
      proceedAfterMatch(rideId);
    } catch {
      setStatus("Unable to continue search. Please try again.");
    } finally {
      setPreferenceLoading(false);
    }
  };

  const handlePreferenceCancel = async () => {
    const rideId = rideIdRef.current;
    setPreferenceLoading(true);
    try {
      if (rideId) {
        await cancelRide(rideId, "Cancelled — women captains unavailable");
      }
    } catch {
      // Still return the user to booking.
    } finally {
      setPreferenceLoading(false);
      setPreferenceOpen(false);
      router.push(buildBookUrl(pickup, dropoff, tab, vehicle));
    }
  };

  return (
    <>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        className="flex min-h-screen w-full flex-col items-center justify-center bg-background px-6 font-sans"
      >
        <WaveGoLogo size="md" className="mb-10" />

        <div className="relative mb-12 flex h-36 w-36 items-center justify-center">
          <div className="absolute inset-0 animate-ping rounded-full bg-primary/15" />
          <div className="absolute inset-3 animate-pulse rounded-full bg-secondary/35" />
          <div className="relative flex h-24 w-24 items-center justify-center overflow-hidden rounded-full border-4 border-card bg-card shadow-xl shadow-primary/25">
            {vehicleOption && (
              <ServiceImage
                src={vehicleOption.image}
                alt={vehicleOption.name}
                imageClassName="object-contain p-2.5"
              />
            )}
          </div>
        </div>

        <h1 className="mb-2 font-heading text-2xl font-bold text-foreground">
          Finding your {vehicleName}
        </h1>
        <p className="mb-8 animate-pulse text-center text-sm font-medium text-muted-foreground">
          {status}
        </p>

        <div className="h-2 w-full max-w-xs overflow-hidden rounded-full bg-muted">
          <div
            className="h-full bg-primary transition-all duration-1000 ease-out"
            style={{ width: `${progress}%` }}
          />
        </div>

        <p className="mt-8 text-center text-xs text-muted-foreground">
          Estimated matching time: &lt; 1 min
        </p>

        <Button
          type="button"
          variant="destructive"
          size="lg"
          className="mt-12 h-12 rounded-2xl border border-destructive/20 bg-destructive/10 px-8 text-base font-semibold text-destructive hover:bg-destructive/15"
          onClick={() => setCancelOpen(true)}
        >
          <XCircle className="h-5 w-5" />
          Cancel ride
        </Button>
      </motion.div>

      <WomenRidersUnavailableDialog
        open={preferenceOpen}
        isLoading={preferenceLoading}
        onContinue={handlePreferenceContinue}
        onCancel={handlePreferenceCancel}
      />

      <CancelRideSheet
        open={cancelOpen}
        onOpenChange={setCancelOpen}
        onConfirm={handleCancelRide}
        title="Cancel request?"
        description="Your captain search will stop. You can book again anytime."
      />
    </>
  );
}
