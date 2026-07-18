"use client";

import { useCallback, useEffect, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { motion } from "framer-motion";
import {
  ChevronLeft,
  Loader2,
  MapPin,
  MessageCircle,
  Navigation2,
  Phone,
  Share2,
  Siren,
  Star,
  XCircle,
} from "lucide-react";
import { CancelRideSheet } from "@/components/booking/CancelRideSheet";
import { RateRideDialog } from "@/components/booking/RateRideDialog";
import { RideChatSheet } from "@/components/booking/RideChatSheet";
import { RideTrackingMap } from "@/components/booking/RideTrackingMap";
import { Button } from "@/components/ui/button";
import { ROUTES } from "@/constants/routes";
import { RIDE_VEHICLE_OPTIONS } from "@/data/ride-options";
import {
  buildLiveRideShareText,
  cancelRide,
  getActiveRide,
  getRide,
  getRideDriver,
  isRideTerminal,
  triggerRideSos,
  type Ride,
} from "@/lib/ride-api";
import { getRideRealtimeClient } from "@/lib/ride-realtime";
import { formatFare, isRideVehicleId } from "@/lib/ride-booking";

function statusLabel(status: string): string {
  switch (status.toUpperCase()) {
    case "DRIVER_ASSIGNED":
      return "Captain assigned • heading to pickup";
    case "DRIVER_ARRIVED":
      return "Captain has arrived";
    case "OTP_VERIFIED":
    case "STARTED":
    case "IN_PROGRESS":
      return "Trip in progress";
    case "COMPLETED":
      return "Trip completed";
    case "CANCELLED":
      return "Trip cancelled";
    default:
      return status.replace(/_/g, " ").toLowerCase();
  }
}

export function RideTrackingView() {
  const router = useRouter();
  const searchParams = useSearchParams();

  const pickupParam = searchParams.get("pickup") || "";
  const dropoffParam = searchParams.get("dropoff") || "";
  const vehicleParam = searchParams.get("vehicle");
  const rideId = searchParams.get("rideId");
  const vehicle = isRideVehicleId(vehicleParam) ? vehicleParam : "bike";

  const [ride, setRide] = useState<Ride | null>(null);
  const [isLoading, setIsLoading] = useState(Boolean(rideId));
  const [cancelOpen, setCancelOpen] = useState(false);
  const [chatOpen, setChatOpen] = useState(false);
  const [rateOpen, setRateOpen] = useState(false);
  const [sosLoading, setSosLoading] = useState(false);
  const [toast, setToast] = useState<string | null>(null);

  const vehicleOption = RIDE_VEHICLE_OPTIONS.find((v) => v.id === vehicle);
  const pickup = ride?.pickup_address || pickupParam;
  const dropoff = ride?.dropoff_address || dropoffParam;
  const status = ride?.status ?? "";
  const canCancel =
    Boolean(rideId) &&
    !isRideTerminal(status) &&
    !["STARTED", "IN_PROGRESS", "OTP_VERIFIED"].includes(status.toUpperCase());
  const canSos = Boolean(rideId) && !isRideTerminal(status);
  const etaMinutes = ride?.estimated_duration_min
    ? Math.max(1, Math.round(ride.estimated_duration_min))
    : null;
  const fare = ride?.fare_final ?? ride?.fare_estimate ?? null;
  const driverName = ride?.driver?.name || "Captain";
  const driverPhone = ride?.driver?.phone || "";
  const driverRating = ride?.driver?.rating ?? 0;
  const vehicleNumber =
    ride?.vehicle_number || ride?.driver?.vehicle_number || vehicleOption?.name || "Ride";
  const startCode = ride?.start_code;

  const refreshRide = useCallback(async () => {
    if (!rideId) return;
    try {
      const [detail, active] = await Promise.all([
        getRide(rideId).catch(() => null),
        getActiveRide().catch(() => null),
      ]);
      let next =
        active && active.id === rideId
          ? active
          : detail;

      if (next && isDriverAssignedStatus(next.status)) {
        try {
          const driver = await getRideDriver(rideId);
          next = {
            ...next,
            driver: {
              id: driver.id,
              name: driver.name,
              phone: driver.phone,
              rating: driver.rating,
              photo_url: driver.photo_url,
              vehicle_number: driver.vehicle_number,
            },
            vehicle_number: driver.vehicle_number || next.vehicle_number,
          };
        } catch {
          // Driver endpoint 404 while still searching is fine.
        }
      }

      if (next) {
        setRide(next);
        if (next.status.toUpperCase() === "COMPLETED") {
          setRateOpen(true);
        }
      }
    } finally {
      setIsLoading(false);
    }
  }, [rideId]);

  useEffect(() => {
    if (!rideId && (!pickupParam || !dropoffParam)) {
      router.replace(ROUTES.home);
    }
  }, [rideId, pickupParam, dropoffParam, router]);

  useEffect(() => {
    if (!rideId) {
      setIsLoading(false);
      return;
    }

    void refreshRide();
    const poll = window.setInterval(() => {
      void refreshRide();
    }, 2000);

    const client = getRideRealtimeClient();
    client.connect();
    client.subscribeRide(rideId);
    const unsub = client.onMessage((msg) => {
      const event = String(msg.event ?? "");
      if (
        event === "ride_accepted" ||
        event === "ride_status" ||
        event === "driver_location" ||
        event === "ride_completed" ||
        event === "ride_cancelled" ||
        event === "ride_sos"
      ) {
        void refreshRide();
      }
    });

    return () => {
      window.clearInterval(poll);
      unsub();
      client.unsubscribeRide(rideId);
    };
  }, [rideId, refreshRide]);

  const showToast = (message: string) => {
    setToast(message);
    window.setTimeout(() => setToast(null), 3500);
  };

  const handleCancelRide = async (reason: string) => {
    if (!rideId) return;
    await cancelRide(rideId, reason);
    router.push(ROUTES.home);
  };

  const handleShare = async () => {
    if (!ride) return;
    const text = buildLiveRideShareText(ride, etaMinutes);
    try {
      if (navigator.share) {
        await navigator.share({ title: "Live ride tracking", text });
      } else {
        await navigator.clipboard.writeText(text);
        showToast("Trip details copied");
      }
    } catch {
      try {
        await navigator.clipboard.writeText(text);
        showToast("Trip details copied");
      } catch {
        showToast("Unable to share trip");
      }
    }
  };

  const handleSos = async () => {
    if (!rideId || sosLoading) return;
    const confirmed = window.confirm(
      "Send SOS alert? We will notify your emergency contacts and support with your live location and captain details."
    );
    if (!confirmed) return;

    setSosLoading(true);
    try {
      let lat = ride?.driver_lat ?? ride?.pickup_lat ?? undefined;
      let lng = ride?.driver_lng ?? ride?.pickup_lng ?? undefined;
      if (navigator.geolocation) {
        try {
          const pos = await new Promise<GeolocationPosition>((resolve, reject) => {
            navigator.geolocation.getCurrentPosition(resolve, reject, {
              enableHighAccuracy: true,
              timeout: 4000,
            });
          });
          lat = pos.coords.latitude;
          lng = pos.coords.longitude;
        } catch {
          // keep ride coords
        }
      }
      const result = await triggerRideSos(rideId, { lat, lng });
      showToast(
        result.message ||
          (result.emergency_sms_sent
            ? "SOS sent. Emergency contacts and support notified."
            : "SOS sent to support.")
      );
      void refreshRide();
    } catch (err) {
      showToast(err instanceof Error ? err.message : "Unable to send SOS");
    } finally {
      setSosLoading(false);
    }
  };

  if (!rideId && (!pickupParam || !dropoffParam)) {
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
          <RideTrackingMap
            pickupLat={ride?.pickup_lat}
            pickupLng={ride?.pickup_lng}
            dropoffLat={ride?.dropoff_lat}
            dropoffLng={ride?.dropoff_lng}
            driverLat={ride?.driver_lat}
            driverLng={ride?.driver_lng}
            vehicleImage={vehicleOption?.image}
            vehicleName={vehicleOption?.name}
          />

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
                onClick={() => void handleShare()}
                className="flex h-11 w-11 items-center justify-center rounded-full bg-card shadow-md transition-colors hover:bg-muted"
                aria-label="Share ride"
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
              <h2 className="font-heading text-3xl font-bold text-foreground">
                {etaMinutes != null ? `${etaMinutes} min` : "On trip"}
              </h2>
              <p className="text-sm font-semibold text-muted-foreground">
                {statusLabel(status)}
              </p>
            </div>
            {fare != null && (
              <p className="font-heading text-xl font-bold text-foreground">
                {formatFare(fare)}
              </p>
            )}
          </div>

          {startCode ? (
            <div className="mb-4 rounded-[18px] border border-primary/30 bg-primary/10 px-4 py-3">
              <p className="text-xs font-semibold uppercase tracking-wide text-primary">
                Start code
              </p>
              <p className="mt-1 font-heading text-2xl font-bold tracking-[0.2em] text-foreground">
                {startCode}
              </p>
            </div>
          ) : null}

          <div className="mb-4 flex items-center gap-4 rounded-[24px] border border-border bg-muted/30 p-4">
            <div className="flex h-14 w-14 items-center justify-center rounded-full bg-primary text-lg font-bold text-primary-foreground">
              {driverName.charAt(0).toUpperCase()}
            </div>
            <div className="min-w-0 flex-1">
              <p className="font-heading text-lg font-bold text-foreground">{driverName}</p>
              <div className="mt-1 flex flex-wrap items-center gap-2 text-sm text-muted-foreground">
                {driverRating > 0 ? (
                  <>
                    <Star className="h-4 w-4 fill-primary text-primary" />
                    <span className="font-semibold text-foreground">
                      {Number(driverRating).toFixed(1)}
                    </span>
                  </>
                ) : null}
                <span>• {vehicleNumber}</span>
              </div>
            </div>
            {driverPhone ? (
              <a
                href={`tel:${driverPhone.replace(/\s/g, "")}`}
                className="flex h-12 w-12 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-md"
                aria-label="Call captain"
              >
                <Phone className="h-5 w-5" />
              </a>
            ) : null}
          </div>

          <div className="mb-6 grid grid-cols-3 gap-2">
            <Button
              type="button"
              variant="outline"
              className="h-11 rounded-xl"
              onClick={() => setChatOpen(true)}
              disabled={!rideId}
            >
              <MessageCircle className="h-4 w-4" />
              Chat
            </Button>
            <Button
              type="button"
              variant="outline"
              className="h-11 rounded-xl"
              onClick={() => void handleShare()}
            >
              <Share2 className="h-4 w-4" />
              Share
            </Button>
            <Button
              type="button"
              variant="destructive"
              className="h-11 rounded-xl"
              disabled={!canSos || sosLoading}
              onClick={() => void handleSos()}
            >
              {sosLoading ? (
                <Loader2 className="h-4 w-4 animate-spin" />
              ) : (
                <Siren className="h-4 w-4" />
              )}
              SOS
            </Button>
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

        {toast ? (
          <div className="fixed bottom-6 left-1/2 z-50 max-w-sm -translate-x-1/2 rounded-full bg-foreground px-4 py-2 text-center text-sm text-background shadow-lg">
            {toast}
          </div>
        ) : null}
      </motion.div>

      <CancelRideSheet
        open={cancelOpen}
        onOpenChange={setCancelOpen}
        onConfirm={handleCancelRide}
      />

      {rideId ? (
        <RideChatSheet
          open={chatOpen}
          rideId={rideId}
          onClose={() => setChatOpen(false)}
        />
      ) : null}

      {rideId ? (
        <RateRideDialog
          open={rateOpen}
          rideId={rideId}
          driverName={driverName}
          onDone={() => {
            setRateOpen(false);
            router.push(ROUTES.home);
          }}
        />
      ) : null}
    </>
  );
}

function isDriverAssignedStatus(status: string) {
  return [
    "DRIVER_ASSIGNED",
    "DRIVER_ARRIVED",
    "OTP_VERIFIED",
    "STARTED",
    "IN_PROGRESS",
    "COMPLETED",
  ].includes(status.toUpperCase());
}
