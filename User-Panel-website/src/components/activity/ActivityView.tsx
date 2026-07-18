"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { AppShell, PageHeader } from "@/components/layout";
import { RideCard } from "@/components/home/RideCard";
import { ROUTES } from "@/constants/routes";
import { getRideHistory, type Ride } from "@/lib/ride-api";
import { formatFare } from "@/lib/ride-booking";
import type { ActivityTab } from "@/types/activity";
import { Ambulance, Car, Loader2, Package } from "lucide-react";

const tabs: { id: ActivityTab; icon: typeof Car }[] = [
  { id: "Rides", icon: Car },
  { id: "Deliveries", icon: Package },
  { id: "Emergency", icon: Ambulance },
];

function formatRideDate(iso: string) {
  return new Date(iso).toLocaleString("en-IN", {
    day: "numeric",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function mapStatus(status: string): "Completed" | "Cancelled" | "Upcoming" {
  const upper = status.toUpperCase();
  if (upper === "COMPLETED") return "Completed";
  if (upper === "CANCELLED") return "Cancelled";
  return "Upcoming";
}

export function ActivityView() {
  const router = useRouter();
  const [activeTab, setActiveTab] = useState<ActivityTab>("Rides");
  const [rides, setRides] = useState<Ride[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    if (activeTab !== "Rides") {
      setIsLoading(false);
      return;
    }

    async function load() {
      setIsLoading(true);
      try {
        const data = await getRideHistory();
        setRides(data.items);
      } catch {
        setRides([]);
      } finally {
        setIsLoading(false);
      }
    }
    void load();
  }, [activeTab]);

  const currentActivities =
    activeTab === "Rides"
      ? rides.map((ride) => ({
          id: ride.id,
          title: `${ride.pickup_address} → ${ride.dropoff_address}`,
          address: ride.dropoff_address,
          date: formatRideDate(ride.created_at),
          price: ride.fare_final ?? ride.fare_estimate ?? 0,
          status: mapStatus(ride.status),
        }))
      : [];

  return (
    <AppShell>
      <PageHeader title="My Bookings" />

      <div className="w-full flex-1 px-6 py-6 md:px-12 lg:px-24">
        <div className="mb-6 flex gap-2 overflow-x-auto pb-2">
          {tabs.map((tab) => {
            const Icon = tab.icon;
            const isActive = activeTab === tab.id;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`flex shrink-0 items-center gap-2 rounded-full px-5 py-2.5 text-sm font-semibold transition-all ${
                  isActive
                    ? "bg-primary text-white shadow-md"
                    : "bg-muted text-muted-foreground hover:bg-muted/80"
                }`}
              >
                <Icon className="h-4 w-4" />
                {tab.id}
              </button>
            );
          })}
        </div>

        {isLoading ? (
          <div className="flex justify-center py-16">
            <Loader2 className="h-8 w-8 animate-spin text-primary" />
          </div>
        ) : (
          <div className="flex flex-col gap-4">
            {currentActivities.length > 0 ? (
              currentActivities.map((activity) => (
                <RideCard
                  key={activity.id}
                  title={activity.title}
                  address={activity.address}
                  date={activity.date}
                  price={formatFare(activity.price)}
                  status={activity.status}
                  onClick={() =>
                    router.push(`${ROUTES.bookingDetail}?id=${encodeURIComponent(activity.id)}`)
                  }
                />
              ))
            ) : (
              <div className="mt-12 flex flex-col items-center justify-center text-center">
                <div className="mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-muted text-muted-foreground/50">
                  <Car className="h-8 w-8" />
                </div>
                <h3 className="font-heading text-lg font-bold text-foreground">No Bookings Yet</h3>
                <p className="mt-1 text-sm text-muted-foreground">
                  You don&apos;t have any {activeTab.toLowerCase()} bookings yet.
                </p>
              </div>
            )}
          </div>
        )}
      </div>
    </AppShell>
  );
}
