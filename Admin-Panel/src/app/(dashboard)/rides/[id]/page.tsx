"use client";

import { notFound } from "next/navigation";
import { use } from "react";
import { ArrowLeft, MapPin, Navigation, Clock, IndianRupee } from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { StatusBadge } from "@/components/shared/status-badge";
import { Button } from "@/components/ui/button";
import { ButtonLink } from "@/components/ui/button-link";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { getRideById } from "@/data/mock-data";
import { formatCurrency, formatDateTime, capitalize } from "@/lib/format";

const timelineSteps = [
  { status: "requested", label: "Ride Requested", time: "10:28 AM" },
  { status: "driver_assigned", label: "Driver Assigned", time: "10:29 AM" },
  { status: "driver_arrived", label: "Driver Arrived", time: "10:35 AM" },
  { status: "ride_started", label: "Ride Started", time: "10:37 AM" },
  { status: "ride_completed", label: "Ride Completed", time: "10:55 AM" },
];

export default function RideDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const ride = getRideById(id);

  if (!ride) notFound();

  const statusIndex = timelineSteps.findIndex((s) => s.status === ride.status);

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <ButtonLink variant="ghost" size="icon" href="/rides">
          <ArrowLeft className="h-4 w-4" />
        </ButtonLink>
        <PageHeader title={`Ride ${ride.id}`} description={formatDateTime(ride.date)}>
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
                  const isActive = i <= statusIndex;
                  const isCurrent = i === statusIndex;
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
                        {isActive && (
                          <p className="text-xs text-muted-foreground">{step.time}</p>
                        )}
                      </div>
                      {isCurrent && <StatusBadge status={ride.status} />}
                    </div>
                  );
                })}
              </div>
            </CardContent>
          </Card>
        </div>

        <div className="space-y-6">
          <Card>
            <CardHeader><CardTitle>Ride Information</CardTitle></CardHeader>
            <CardContent className="space-y-3">
              {[
                ["Ride ID", ride.id],
                ["Vehicle Type", capitalize(ride.vehicleType)],
                ["Payment", ride.paymentMethod],
                ["Status", capitalize(ride.status)],
              ].map(([label, value]) => (
                <div key={label} className="flex justify-between">
                  <span className="text-sm text-muted-foreground">{label}</span>
                  <span className="text-sm font-medium">{value}</span>
                </div>
              ))}
            </CardContent>
          </Card>

          <Card>
            <CardHeader><CardTitle>User Information</CardTitle></CardHeader>
            <CardContent className="space-y-3">
              <div className="flex justify-between">
                <span className="text-sm text-muted-foreground">Name</span>
                <span className="text-sm font-medium">{ride.userName}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-muted-foreground">User ID</span>
                <span className="text-sm font-mono">{ride.userId}</span>
              </div>
            </CardContent>
          </Card>

          {ride.driverName && (
            <Card>
              <CardHeader><CardTitle>Driver Information</CardTitle></CardHeader>
              <CardContent className="space-y-3">
                <div className="flex justify-between">
                  <span className="text-sm text-muted-foreground">Name</span>
                  <span className="text-sm font-medium">{ride.driverName}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-muted-foreground">Driver ID</span>
                  <span className="text-sm font-mono">{ride.driverId}</span>
                </div>
              </CardContent>
            </Card>
          )}

          <Card>
            <CardHeader><CardTitle>Fare Breakdown</CardTitle></CardHeader>
            <CardContent className="space-y-3">
              {[
                ["Base Fare", 35],
                ["Distance Charge", ride.fare - 35 - 10],
                ["Waiting Charge", 0],
                ["Surge", 10],
              ].map(([label, amount]) => (
                <div key={label as string} className="flex justify-between">
                  <span className="text-sm text-muted-foreground">{label}</span>
                  <span className="text-sm">{formatCurrency(amount as number)}</span>
                </div>
              ))}
              <Separator />
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
