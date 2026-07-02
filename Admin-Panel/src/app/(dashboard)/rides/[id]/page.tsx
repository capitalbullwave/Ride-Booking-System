"use client";

import { notFound } from "next/navigation";
import { use, useCallback, useEffect, useState } from "react";
import { ArrowLeft, MapPin, Navigation, Clock, IndianRupee } from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { StatusBadge } from "@/components/shared/status-badge";
import { ButtonLink } from "@/components/ui/button-link";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { Ride, RideStatus } from "@/types";
import { formatCurrency, formatDateTime, formatShortId, capitalize } from "@/lib/format";
import { fetchRideById } from "@/lib/rides-api";
import { toast } from "sonner";
import { useAuth } from "@/components/providers/auth-provider";

const timelineSteps: { status: RideStatus; label: string }[] = [
  { status: "requested", label: "Ride Requested" },
  { status: "driver_assigned", label: "Driver Assigned" },
  { status: "driver_arrived", label: "Driver Arrived" },
  { status: "ride_started", label: "Ride Started" },
  { status: "ride_completed", label: "Ride Completed" },
];

export default function RideDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const { isAuthenticated, isLoading: authLoading } = useAuth();
  const [ride, setRide] = useState<Ride | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [notFoundState, setNotFoundState] = useState(false);

  const loadRide = useCallback(async () => {
    setIsLoading(true);
    setNotFoundState(false);

    try {
      const data = await fetchRideById(id);
      setRide(data);
    } catch (error) {
      const message = error instanceof Error ? error.message : "Failed to load ride";
      if (message.toLowerCase().includes("not found")) {
        setNotFoundState(true);
      } else {
        toast.error(message);
      }
      setRide(null);
    } finally {
      setIsLoading(false);
    }
  }, [id]);

  useEffect(() => {
    if (authLoading) return;
    if (!isAuthenticated) {
      setRide(null);
      setIsLoading(false);
      return;
    }
    void loadRide();
  }, [loadRide, authLoading, isAuthenticated]);

  if (notFoundState) notFound();

  if (isLoading || !ride) {
    return (
      <div className="space-y-6">
        <div className="flex items-center gap-4">
          <ButtonLink variant="ghost" size="icon" href="/rides">
            <ArrowLeft className="h-4 w-4" />
          </ButtonLink>
          <PageHeader title="Ride details" description="Loading ride information..." />
        </div>
        <Card>
          <CardContent className="py-12 text-center text-sm text-muted-foreground">
            Fetching ride data from the server...
          </CardContent>
        </Card>
      </div>
    );
  }

  const statusIndex = timelineSteps.findIndex((s) => s.status === ride.status);
  const activeIndex = statusIndex >= 0 ? statusIndex : 0;

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <ButtonLink variant="ghost" size="icon" href="/rides">
          <ArrowLeft className="h-4 w-4" />
        </ButtonLink>
        <PageHeader
          title={`Ride ${formatShortId(ride.id)}`}
          description={formatDateTime(ride.date)}
        >
          <StatusBadge status={ride.status} />
        </PageHeader>
      </div>

      <div className="grid gap-6 lg:grid-cols-3">
        <div className="lg:col-span-2 space-y-6">
          <Card>
            <CardHeader><CardTitle>Live Map</CardTitle></CardHeader>
            <CardContent>
              <div className="flex h-64 items-center justify-center rounded-lg bg-muted/50 border-2 border-dashed">
                <div className="text-center">
                  <MapPin className="mx-auto h-12 w-12 text-primary/50" />
                  <p className="mt-2 text-sm font-medium">Route Map Placeholder</p>
                  <p className="text-xs text-muted-foreground">
                    {ride.pickupLocation} → {ride.dropLocation}
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader><CardTitle>Route Information</CardTitle></CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-start gap-3">
                <div className="mt-1 h-3 w-3 rounded-full bg-emerald-500" />
                <div>
                  <p className="text-xs text-muted-foreground">Pickup</p>
                  <p className="font-medium">{ride.pickupLocation}</p>
                </div>
              </div>
              <div className="ml-1.5 border-l-2 border-dashed border-muted-foreground/30 h-8" />
              <div className="flex items-start gap-3">
                <div className="mt-1 h-3 w-3 rounded-full bg-red-500" />
                <div>
                  <p className="text-xs text-muted-foreground">Drop</p>
                  <p className="font-medium">{ride.dropLocation}</p>
                </div>
              </div>
              <Separator />
              <div className="grid grid-cols-3 gap-4 text-center">
                <div>
                  <Navigation className="mx-auto h-5 w-5 text-muted-foreground" />
                  <p className="mt-1 text-lg font-bold">{ride.distance} km</p>
                  <p className="text-xs text-muted-foreground">Distance</p>
                </div>
                <div>
                  <Clock className="mx-auto h-5 w-5 text-muted-foreground" />
                  <p className="mt-1 text-lg font-bold">{ride.duration ?? "—"} min</p>
                  <p className="text-xs text-muted-foreground">Duration</p>
                </div>
                <div>
                  <IndianRupee className="mx-auto h-5 w-5 text-muted-foreground" />
                  <p className="mt-1 text-lg font-bold">{formatCurrency(ride.fare)}</p>
                  <p className="text-xs text-muted-foreground">Fare</p>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader><CardTitle>Ride Timeline</CardTitle></CardHeader>
            <CardContent>
              <div className="space-y-4">
                {timelineSteps.map((step, i) => {
                  const isActive = ride.status === "cancelled" ? false : i <= activeIndex;
                  const isCurrent = i === activeIndex && ride.status !== "cancelled";
                  return (
                    <div key={step.status} className="flex items-center gap-4">
                      <div
                        className={`flex h-8 w-8 items-center justify-center rounded-full text-xs font-bold ${
                          isActive
                            ? "bg-primary text-primary-foreground"
                            : "bg-muted text-muted-foreground"
                        } ${isCurrent ? "ring-4 ring-primary/20" : ""}`}
                      >
                        {i + 1}
                      </div>
                      <div className="flex-1">
                        <p className={`text-sm font-medium ${!isActive && "text-muted-foreground"}`}>
                          {step.label}
                        </p>
                      </div>
                      {isCurrent && <StatusBadge status={ride.status} />}
                    </div>
                  );
                })}
                {ride.status === "cancelled" && (
                  <div className="flex items-center gap-4">
                    <div className="flex h-8 w-8 items-center justify-center rounded-full bg-destructive text-destructive-foreground text-xs font-bold">
                      ✕
                    </div>
                    <div className="flex-1">
                      <p className="text-sm font-medium">Ride Cancelled</p>
                    </div>
                    <StatusBadge status="cancelled" />
                  </div>
                )}
              </div>
            </CardContent>
          </Card>
        </div>

        <div className="space-y-6">
          <Card>
            <CardHeader><CardTitle>Ride Information</CardTitle></CardHeader>
            <CardContent className="space-y-3">
              {[
                ["Ride ID", formatShortId(ride.id)],
                ["Vehicle Type", capitalize(ride.vehicleType)],
                ["Payment", capitalize(ride.paymentMethod)],
                ["Status", capitalize(ride.status)],
              ].map(([label, value]) => (
                <div key={label} className="flex justify-between gap-4">
                  <span className="text-sm text-muted-foreground">{label}</span>
                  <span className="text-sm font-medium text-right" title={label === "Ride ID" ? ride.id : undefined}>
                    {value}
                  </span>
                </div>
              ))}
            </CardContent>
          </Card>

          <Card>
            <CardHeader><CardTitle>User Information</CardTitle></CardHeader>
            <CardContent className="space-y-3">
              <div className="flex justify-between gap-4">
                <span className="text-sm text-muted-foreground">Name</span>
                <span className="text-sm font-medium">{ride.userName}</span>
              </div>
              <div className="flex justify-between gap-4">
                <span className="text-sm text-muted-foreground">User ID</span>
                <span className="text-sm font-mono" title={ride.userId}>
                  {formatShortId(ride.userId)}
                </span>
              </div>
            </CardContent>
          </Card>

          {ride.driverName && (
            <Card>
              <CardHeader><CardTitle>Driver Information</CardTitle></CardHeader>
              <CardContent className="space-y-3">
                <div className="flex justify-between gap-4">
                  <span className="text-sm text-muted-foreground">Name</span>
                  <span className="text-sm font-medium">{ride.driverName}</span>
                </div>
                {ride.driverId && (
                  <div className="flex justify-between gap-4">
                    <span className="text-sm text-muted-foreground">Driver ID</span>
                    <span className="text-sm font-mono" title={ride.driverId}>
                      {formatShortId(ride.driverId)}
                    </span>
                  </div>
                )}
              </CardContent>
            </Card>
          )}

          <Card>
            <CardHeader><CardTitle>Fare</CardTitle></CardHeader>
            <CardContent>
              <div className="flex justify-between font-bold">
                <span>Total</span>
                <span className="text-primary">{formatCurrency(ride.fare)}</span>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
