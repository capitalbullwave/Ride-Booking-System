"use client";

import { notFound, useSearchParams } from "next/navigation";
import { use, useCallback, useEffect, useState } from "react";
import { ArrowLeft, Navigation, Clock, IndianRupee, MessageSquare, Building2 } from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { StatusBadge } from "@/components/shared/status-badge";
import { RideRouteMap } from "@/components/rides/ride-route-map";
import { ButtonLink } from "@/components/ui/button-link";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { Ride, RideStatus } from "@/types";
import { formatCurrency, formatDateTime, formatPublicId, capitalize } from "@/lib/format";
import { fetchRideById, fetchRideMessages, RideChatMessage } from "@/lib/rides-api";
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
  const searchParams = useSearchParams();
  const fromCorporate = searchParams.get("from") === "corporate";
  const backHref = fromCorporate ? "/corporate/rides" : "/rides";
  const { isAuthenticated, isLoading: authLoading } = useAuth();
  const [ride, setRide] = useState<Ride | null>(null);
  const [messages, setMessages] = useState<RideChatMessage[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [notFoundState, setNotFoundState] = useState(false);

  const loadRide = useCallback(async () => {
    setIsLoading(true);
    setNotFoundState(false);

    try {
      const [data, chat] = await Promise.all([
        fetchRideById(id),
        fetchRideMessages(id).catch(() => [] as RideChatMessage[]),
      ]);
      setRide(data);
      setMessages(chat);
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
          <ButtonLink variant="ghost" size="icon" href={backHref}>
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
  const stops = (ride.stops ?? []).filter((s) => s.address.trim());
  const isCorporate = (ride.rideType ?? "").toUpperCase() === "CORPORATE";

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <ButtonLink variant="ghost" size="icon" href={backHref}>
          <ArrowLeft className="h-4 w-4" />
        </ButtonLink>
        <PageHeader
          title={`Ride ${formatPublicId(ride.publicId, ride.id)}`}
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
              <RideRouteMap
                pickupLocation={ride.pickupLocation}
                dropLocation={ride.dropLocation}
                pickupLat={ride.pickupLat}
                pickupLng={ride.pickupLng}
                dropLat={ride.dropLat}
                dropLng={ride.dropLng}
                stops={stops}
              />
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
              {stops.map((stop, index) => (
                <div key={`${stop.lat}-${stop.lng}-${index}`}>
                  <div className="ml-1.5 border-l-2 border-dashed border-muted-foreground/30 h-6" />
                  <div className="flex items-start gap-3">
                    <div className="mt-0.5 flex h-4 w-4 shrink-0 items-center justify-center rounded-sm bg-violet-600 text-[9px] font-bold text-white rotate-45">
                      <span className="-rotate-45">{index + 1}</span>
                    </div>
                    <div>
                      <p className="text-xs text-violet-600 font-medium">
                        Stop {index + 1}
                      </p>
                      <p className="font-medium">{stop.address}</p>
                    </div>
                  </div>
                </div>
              ))}
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
              {stops.length > 0 && (
                <p className="text-center text-xs text-muted-foreground">
                  {stops.length} intermediate stop{stops.length > 1 ? "s" : ""} on this trip
                </p>
              )}
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

          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <MessageSquare className="h-5 w-5" />
                Ride Conversation
              </CardTitle>
            </CardHeader>
            <CardContent>
              {messages.length === 0 ? (
                <p className="text-sm text-muted-foreground text-center py-6">
                  No messages between passenger and driver for this ride.
                </p>
              ) : (
                <div className="space-y-3 max-h-80 overflow-y-auto">
                  {messages.map((msg) => (
                    <div
                      key={msg.id}
                      className={`rounded-lg border p-3 ${
                        msg.sender_type === "driver"
                          ? "border-primary/20 bg-primary/5"
                          : "border-muted bg-muted/30"
                      }`}
                    >
                      <div className="flex items-center justify-between gap-2 mb-1">
                        <span className="text-xs font-semibold capitalize">
                          {msg.sender_name ?? msg.sender_type}
                        </span>
                        {msg.created_at && (
                          <span className="text-[10px] text-muted-foreground">
                            {formatDateTime(msg.created_at)}
                          </span>
                        )}
                      </div>
                      <p className="text-sm whitespace-pre-wrap">{msg.message}</p>
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>
        </div>

        <div className="space-y-6">
          <Card>
            <CardHeader><CardTitle>Ride Information</CardTitle></CardHeader>
            <CardContent className="space-y-3">
              {[
                ["Ride ID", formatPublicId(ride.publicId, ride.id)],
                ["Type", isCorporate ? "Corporate" : "Personal"],
                ["Vehicle Type", capitalize(ride.vehicleType)],
                [
                  "Payment",
                  isCorporate ? "Paid by Company" : capitalize(ride.paymentMethod),
                ],
                ["Status", capitalize(ride.status)],
                ...(stops.length > 0
                  ? [["Stops", String(stops.length)] as const]
                  : []),
              ].map(([label, value]) => (
                <div key={label} className="flex justify-between gap-4">
                  <span className="text-sm text-muted-foreground">{label}</span>
                  <span
                    className="text-sm font-medium text-right"
                    title={label === "Ride ID" ? ride.id : undefined}
                  >
                    {value}
                  </span>
                </div>
              ))}
            </CardContent>
          </Card>

          {isCorporate && (
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Building2 className="h-5 w-5" />
                  Corporate
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                {[
                  ["Company", ride.companyName || "—"],
                  ["Company Code", ride.companyCode || "—"],
                  ["Employee Code", ride.employeeCode || "—"],
                  ["Department", ride.employeeDepartment || "—"],
                  ["Designation", ride.employeeDesignation || "—"],
                  ["Payment Source", ride.paymentSource || "COMPANY"],
                ].map(([label, value]) => (
                  <div key={label} className="flex justify-between gap-4">
                    <span className="text-sm text-muted-foreground">{label}</span>
                    <span className="text-sm font-medium text-right">{value}</span>
                  </div>
                ))}
                {ride.companyId && (
                  <ButtonLink
                    href={`/corporate/companies/${ride.companyId}`}
                    variant="outline"
                    size="sm"
                    className="w-full"
                  >
                    View company
                  </ButtonLink>
                )}
              </CardContent>
            </Card>
          )}

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
                  {formatPublicId(ride.userPublicId, ride.userId)}
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
                      {formatPublicId(ride.driverPublicId, ride.driverId)}
                    </span>
                  </div>
                )}
              </CardContent>
            </Card>
          )}

          <Card>
            <CardHeader><CardTitle>Fare & Commission</CardTitle></CardHeader>
            <CardContent className="space-y-3">
              <div className="flex justify-between">
                <span className="text-sm text-muted-foreground">Total Ride Fare</span>
                <span className="text-sm font-semibold">{formatCurrency(ride.fare)}</span>
              </div>
              {ride.status === "ride_completed" && ride.driverEarning != null ? (
                <>
                  <div className="flex justify-between">
                    <span className="text-sm text-muted-foreground">
                      Driver Commission
                      {ride.driverCommissionPercentage != null
                        ? ` (${ride.driverCommissionPercentage}%)`
                        : ""}
                    </span>
                    <span className="text-sm font-semibold text-emerald-600">
                      {formatCurrency(ride.driverEarning)}
                    </span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-sm text-muted-foreground">Company Revenue</span>
                    <span className="text-sm font-semibold text-primary">
                      {formatCurrency(ride.companyEarning ?? ride.fare - ride.driverEarning)}
                    </span>
                  </div>
                </>
              ) : (
                <p className="text-xs text-muted-foreground">
                  Commission breakdown is available after the ride is completed.
                </p>
              )}
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
