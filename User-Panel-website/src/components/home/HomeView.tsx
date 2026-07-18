"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { Bell, ChevronRight, Menu, Sparkles } from "lucide-react";
import { ROUTES } from "@/constants/routes";
import { LocationCard } from "@/components/home/LocationCard";
import { ServiceImage } from "@/components/home/ServiceImage";
import { BottomNav } from "@/components/layout/BottomNav";
import { Sidebar } from "@/components/layout/Sidebar";
import { homeServices } from "@/constants/services";
import { useAuthUser } from "@/hooks/useAuthUser";
import { useHomeDashboard } from "@/hooks/useHomeDashboard";
import { reverseGeocode } from "@/lib/places-api";
import { buildTrackingUrl } from "@/lib/ride-booking";
import { isRideInProgress } from "@/lib/ride-api";
import { parseStopsFromParams, type TripStop } from "@/lib/trip-stops";
import {
  displayVehicleName,
  homeRouteForCategory,
  vehicleImageForCategory,
} from "@/lib/vehicle-map";
import { cn } from "@/lib/utils";

export function HomeView() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [pickup, setPickup] = useState("");
  const [dropoff, setDropoff] = useState("");
  const [pickupLat, setPickupLat] = useState<number | undefined>();
  const [pickupLng, setPickupLng] = useState<number | undefined>();
  const [dropoffLat, setDropoffLat] = useState<number | undefined>();
  const [dropoffLng, setDropoffLng] = useState<number | undefined>();
  const [stops, setStops] = useState<TripStop[]>([]);
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const user = useAuthUser();
  const { data: dashboard, unreadCount } = useHomeDashboard();
  const displayName = dashboard?.greeting_name || user.name;

  const rideCategories =
    dashboard?.vehicle_categories?.filter(
      (category) => (category.service_group ?? "ride") !== "rental"
    ) ?? [];

  const services =
    rideCategories.length > 0
      ? rideCategories.map((category) => ({
          key: category.id,
          name: displayVehicleName(category.name, category.slug),
          description:
            category.description ??
            `Book ${displayVehicleName(category.name, category.slug)} instantly`,
          image: vehicleImageForCategory(category),
          route: homeRouteForCategory(category),
          isAmbulance: category.slug.toLowerCase().includes("ambulance"),
        }))
      : homeServices.map((service) => ({
          key: service.name,
          name: displayVehicleName(service.name),
          description: service.description,
          image: service.image,
          route: service.route,
          isAmbulance: service.name === "Ambulance",
        }));

  const rentalServices =
    dashboard?.rental_categories && dashboard.rental_categories.length > 0
      ? dashboard.rental_categories.map((category) => ({
          key: category.id,
          name: category.name,
          description: category.description ?? "Daily rental package",
          image: vehicleImageForCategory(category),
        }))
      : [
          {
            key: "rental-bike",
            name: "Rental Bike",
            description: "Rent a bike by the day",
            image: "/images/services/bike.png",
          },
          {
            key: "rental-car",
            name: "Rental Car",
            description: "Flexible car rental packages",
            image: "/images/services/car.png",
          },
        ];

  useEffect(() => {
    const urlPickup = searchParams.get("pickup");
    const urlDropoff = searchParams.get("dropoff");
    const plat = searchParams.get("plat");
    const plng = searchParams.get("plng");
    const dlat = searchParams.get("dlat");
    const dlng = searchParams.get("dlng");

    if (urlPickup) setPickup(urlPickup);
    if (urlDropoff) setDropoff(urlDropoff);
    if (plat != null && plat !== "") setPickupLat(Number(plat));
    if (plng != null && plng !== "") setPickupLng(Number(plng));
    if (dlat != null && dlat !== "") setDropoffLat(Number(dlat));
    if (dlng != null && dlng !== "") setDropoffLng(Number(dlng));
    setStops(parseStopsFromParams(searchParams));
  }, [searchParams]);

  useEffect(() => {
    const hasUrlPickup = Boolean(searchParams.get("pickup"));
    if (hasUrlPickup || !navigator.geolocation) return;

    let cancelled = false;
    navigator.geolocation.getCurrentPosition(
      async (position) => {
        try {
          const place = await reverseGeocode(
            position.coords.latitude,
            position.coords.longitude
          );
          if (cancelled) return;
          setPickup((current) => current || place.label);
          setPickupLat((current) => current ?? place.latitude);
          setPickupLng((current) => current ?? place.longitude);
        } catch {
          // Keep empty pickup; user can select manually.
        }
      },
      () => {
        // Permission denied — user can pick manually.
      },
      { enableHighAccuracy: true, timeout: 12000 }
    );

    return () => {
      cancelled = true;
    };
  }, [searchParams]);

  const handleSwap = () => {
    setPickup(dropoff);
    setDropoff(pickup);
    setPickupLat(dropoffLat);
    setPickupLng(dropoffLng);
    setDropoffLat(pickupLat);
    setDropoffLng(pickupLng);
  };

  return (
    <div className="flex min-h-screen w-full flex-col bg-background pb-24">
      <Sidebar isOpen={isSidebarOpen} onClose={() => setIsSidebarOpen(false)} />

      <div className="relative overflow-hidden bg-primary px-4 pb-10 pt-10 text-white sm:px-6 md:px-12 md:pb-12 md:pt-14 lg:px-24">
        <div className="absolute -right-16 -top-16 h-48 w-48 rounded-full bg-white/5 blur-3xl" />
        <div className="absolute -left-8 top-24 h-32 w-32 rounded-full bg-secondary/20 blur-2xl" />

        <div className="relative z-10 mx-auto flex w-full max-w-6xl items-center justify-between">
          <div className="flex items-center gap-3">
            <button
              type="button"
              onClick={() => setIsSidebarOpen(true)}
              className="flex h-11 w-11 items-center justify-center rounded-full bg-white/10 backdrop-blur-sm transition-all hover:bg-white/20 active:scale-95"
              aria-label="Open menu"
            >
              <Menu className="h-5 w-5" />
            </button>
            <div>
              <p className="text-sm font-medium text-white/75">Welcome back</p>
              <h1 className="font-heading text-2xl font-bold tracking-tight sm:text-3xl">
                {displayName}
              </h1>
            </div>
          </div>
          <Link
            href={ROUTES.notifications}
            className="relative flex h-11 w-11 items-center justify-center rounded-full bg-white/10 backdrop-blur-sm transition-all hover:bg-white/20 active:scale-95"
            aria-label="Notifications"
          >
            <Bell className="h-5 w-5" />
            {unreadCount > 0 && (
              <span className="absolute right-3 top-3 h-2.5 w-2.5 rounded-full border-2 border-primary bg-warning" />
            )}
          </Link>
        </div>
      </div>

      <div className="relative z-20 mx-auto w-full max-w-6xl flex-1 px-4 sm:px-6 md:px-12 lg:px-24">
        <div className="-mt-8 mb-6 md:-mt-10">
          <LocationCard
            pickup={pickup}
            dropoff={dropoff}
            onSwap={handleSwap}
            coords={{
              pickupLat,
              pickupLng,
              dropoffLat,
              dropoffLng,
            }}
            stops={stops}
            onRemoveStop={(index) =>
              setStops((prev) => prev.filter((_, i) => i !== index))
            }
          />
        </div>

        {dashboard?.active_ride && isRideInProgress(dashboard.active_ride.status) ? (
          <button
            type="button"
            onClick={() =>
              router.push(
                buildTrackingUrl(
                  dashboard.active_ride!.pickup_address,
                  dashboard.active_ride!.dropoff_address,
                  "bike",
                  "rides",
                  dashboard.active_ride!.id
                )
              )
            }
            className="mb-6 w-full rounded-[20px] border border-primary/30 bg-primary/10 p-4 text-left shadow-sm transition-colors hover:bg-primary/15"
          >
            <p className="text-xs font-semibold uppercase tracking-wide text-primary">
              Active ride
            </p>
            <p className="mt-1 font-heading text-base font-bold text-foreground">
              {dashboard.active_ride.status.replace(/_/g, " ")}
            </p>
            <p className="mt-1 truncate text-sm text-muted-foreground">
              {dashboard.active_ride.pickup_address} → {dashboard.active_ride.dropoff_address}
            </p>
            <p className="mt-2 text-sm font-semibold text-primary">Tap to track live</p>
          </button>
        ) : null}

        <div className="mb-6 overflow-hidden rounded-[20px] border border-secondary/30 bg-gradient-to-br from-secondary/20 via-card to-primary/5 p-4 shadow-sm sm:p-5">
          <div className="flex items-start gap-3">
            <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary">
              <Sparkles className="h-5 w-5" />
            </div>
            <div className="min-w-0 flex-1">
              <p className="font-heading text-sm font-bold text-foreground">
                {dashboard?.banners[0]?.title ?? "Ride smarter with Bull Wave Rides"}
              </p>
              <p className="mt-1 text-sm leading-relaxed text-muted-foreground">
                {dashboard?.banners[0]?.subtitle ??
                  "Book rides, send parcels, or request emergency ambulance — all in one app."}
              </p>
              {dashboard?.nearby_drivers_count ? (
                <p className="mt-2 text-xs font-semibold text-primary">
                  {dashboard.nearby_drivers_count} drivers nearby
                </p>
              ) : null}
            </div>
          </div>
        </div>

        <div className="mb-10">
          <div className="mb-4 flex items-end justify-between gap-3">
            <div>
              <h2 className="font-heading text-xl font-bold text-foreground">Choose Service</h2>
              <p className="mt-1 text-sm text-muted-foreground">
                Tap a service to get started
              </p>
            </div>
            <button
              type="button"
              onClick={() => router.push(ROUTES.bookings)}
              className="flex shrink-0 items-center gap-1 text-sm font-semibold text-primary transition-colors hover:text-primary/80"
            >
              My bookings
              <ChevronRight className="h-4 w-4" />
            </button>
          </div>

          <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
            {services.map((service) => {
              const isAmbulance = service.isAmbulance;
              return (
                <button
                  key={service.key}
                  type="button"
                  onClick={() => router.push(service.route)}
                  className={cn(
                    "group flex w-full items-center gap-4 rounded-[20px] border bg-card p-4 text-left shadow-sm transition-all duration-200 hover:-translate-y-0.5 hover:shadow-md active:scale-[0.99] sm:p-5",
                    isAmbulance
                      ? "border-destructive/20 hover:border-destructive/40 hover:shadow-destructive/10"
                      : "border-border hover:border-primary/30 hover:shadow-primary/5"
                  )}
                >
                  <div
                    className={cn(
                      "flex h-20 w-20 shrink-0 items-center justify-center overflow-hidden rounded-2xl transition-colors sm:h-24 sm:w-24",
                      isAmbulance
                        ? "bg-destructive/10 group-hover:bg-destructive/15"
                        : "bg-secondary/30 group-hover:bg-primary/10"
                    )}
                  >
                    <ServiceImage src={service.image} alt={service.name} />
                  </div>
                  <div className="min-w-0 flex-1">
                    <h3
                      className={cn(
                        "font-heading text-base font-bold transition-colors sm:text-lg",
                        isAmbulance
                          ? "text-destructive"
                          : "text-foreground group-hover:text-primary"
                      )}
                    >
                      {service.name}
                    </h3>
                    <p className="mt-1 text-sm leading-snug text-muted-foreground">
                      {service.description}
                    </p>
                  </div>
                  <ChevronRight
                    className={cn(
                      "h-5 w-5 shrink-0 text-muted-foreground/40 transition-all group-hover:translate-x-0.5",
                      isAmbulance ? "group-hover:text-destructive" : "group-hover:text-primary"
                    )}
                  />
                </button>
              );
            })}
          </div>
        </div>

        <div className="mb-10">
          <div className="mb-4">
            <h2 className="font-heading text-xl font-bold text-foreground">Vehicle Rental</h2>
            <p className="mt-1 text-sm text-muted-foreground">
              Rent bikes and cars by the day
            </p>
          </div>

          <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
            {rentalServices.map((service) => (
              <button
                key={service.key}
                type="button"
                onClick={() => {
                  const params = new URLSearchParams();
                  if (pickup) params.set("pickup", pickup);
                  if (pickupLat != null) params.set("plat", String(pickupLat));
                  if (pickupLng != null) params.set("plng", String(pickupLng));
                  const query = params.toString();
                  router.push(query ? `${ROUTES.rental}?${query}` : ROUTES.rental);
                }}
                className="group flex w-full items-center gap-4 rounded-[20px] border border-border bg-card p-4 text-left shadow-sm transition-all duration-200 hover:-translate-y-0.5 hover:border-primary/30 hover:shadow-md active:scale-[0.99] sm:p-5"
              >
                <div className="flex h-20 w-20 shrink-0 items-center justify-center overflow-hidden rounded-2xl bg-secondary/30 transition-colors group-hover:bg-primary/10 sm:h-24 sm:w-24">
                  <ServiceImage src={service.image} alt={service.name} />
                </div>
                <div className="min-w-0 flex-1">
                  <h3 className="font-heading text-base font-bold text-foreground transition-colors group-hover:text-primary sm:text-lg">
                    {service.name}
                  </h3>
                  <p className="mt-1 text-sm leading-snug text-muted-foreground">
                    {service.description}
                  </p>
                </div>
                <ChevronRight className="h-5 w-5 shrink-0 text-muted-foreground/40 transition-all group-hover:translate-x-0.5 group-hover:text-primary" />
              </button>
            ))}
          </div>
        </div>
      </div>

      <BottomNav />
    </div>
  );
}
