"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { ChevronLeft, Loader2 } from "lucide-react";
import { VehicleOptionImage } from "@/components/booking/VehicleOptionImage";
import { ROUTES } from "@/constants/routes";
import { getProtectedPath, isAuthenticated } from "@/lib/auth-session";
import { getRentalCategories, type VehicleCategory } from "@/lib/home-api";
import { bookRide } from "@/lib/ride-api";
import { vehicleImageForCategory } from "@/lib/vehicle-map";
import { cn } from "@/lib/utils";

const FALLBACK_RENTALS: VehicleCategory[] = [
  {
    id: "rental-bike",
    slug: "rental-bike",
    name: "Rental Bike",
    description: "Rent a bike by the day",
    base_fare: 199,
    per_km_rate: 8,
    icon_url: null,
    service_group: "rental",
  },
  {
    id: "rental-car",
    slug: "rental-car",
    name: "Rental Car",
    description: "Flexible car rental packages",
    base_fare: 999,
    per_km_rate: 12,
    icon_url: null,
    service_group: "rental",
  },
];

export function RentalView() {
  const router = useRouter();
  const [categories, setCategories] = useState<VehicleCategory[]>([]);
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [rentalHours, setRentalHours] = useState(4);
  const [pickup, setPickup] = useState("");
  const [pickupLat, setPickupLat] = useState<number | undefined>();
  const [pickupLng, setPickupLng] = useState<number | undefined>();
  const [isLoading, setIsLoading] = useState(true);
  const [isBooking, setIsBooking] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const hourOptions = [2, 4, 6, 8, 12];

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    setPickup(params.get("pickup") || "");
    const plat = params.get("plat");
    const plng = params.get("plng");
    if (plat != null && plat !== "") setPickupLat(Number(plat));
    if (plng != null && plng !== "") setPickupLng(Number(plng));
  }, []);

  useEffect(() => {
    let cancelled = false;

    async function load() {
      setIsLoading(true);
      setError(null);
      try {
        const items = await getRentalCategories();
        if (!cancelled) {
          setCategories(items.length > 0 ? items : FALLBACK_RENTALS);
        }
      } catch (err) {
        if (!cancelled) {
          setCategories(FALLBACK_RENTALS);
          setError(err instanceof Error ? err.message : "Unable to load rental options");
        }
      } finally {
        if (!cancelled) setIsLoading(false);
      }
    }

    void load();
    return () => {
      cancelled = true;
    };
  }, []);

  const selected = categories.find((c) => c.id === selectedId) ?? null;

  async function handleConfirm() {
    if (!selected) return;
    if (!isAuthenticated()) {
      router.replace(getProtectedPath(ROUTES.rental));
      return;
    }
    if (!pickup.trim()) {
      setError("Please set a pickup location from the home screen first.");
      return;
    }
    if (pickupLat == null || pickupLng == null) {
      setError("Pickup coordinates missing. Set pickup from home using current location or search.");
      return;
    }

    setIsBooking(true);
    setError(null);
    try {
      const ride = await bookRide({
        pickup_address: pickup,
        dropoff_address: pickup,
        pickup_lat: pickupLat,
        pickup_lng: pickupLng,
        dropoff_lat: pickupLat,
        dropoff_lng: pickupLng,
        vehicle_category_id: selected.id,
        payment_method: "CASH",
        rental_hours: rentalHours,
      });
      const params = new URLSearchParams({
        rideId: ride.id,
        pickup,
        dropoff: pickup,
        plat: String(pickupLat),
        plng: String(pickupLng),
        dlat: String(pickupLat),
        dlng: String(pickupLng),
        tab: "rides",
        vehicle: "cab",
      });
      router.push(`${ROUTES.bookSearching}?${params.toString()}`);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unable to confirm rental");
    } finally {
      setIsBooking(false);
    }
  }

  return (
    <div className="flex min-h-screen w-full flex-col bg-background pb-24">
      <div className="rounded-b-[32px] bg-primary px-6 pb-8 pt-12 text-white md:px-12 lg:px-24">
        <div className="mx-auto flex w-full max-w-3xl items-center gap-4">
          <button
            type="button"
            onClick={() => router.back()}
            className="flex h-11 w-11 items-center justify-center rounded-full bg-white/20 transition-all hover:bg-white/30 active:scale-95"
            aria-label="Go back"
          >
            <ChevronLeft className="h-6 w-6" />
          </button>
          <div>
            <h1 className="font-heading text-xl font-bold">Vehicle Rental</h1>
            <p className="text-sm text-white/80">Rent bikes and cars by the day</p>
          </div>
        </div>
      </div>

      <div className="mx-auto w-full max-w-3xl flex-1 px-6 py-6 md:px-12 lg:px-24">
        <div className="mb-6 rounded-[20px] border border-border bg-card p-4">
          <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
            Pickup location
          </p>
          <p className="mt-1 font-semibold text-foreground">
            {pickup || "Set pickup on home screen"}
          </p>
          <p className="mt-2 text-sm text-muted-foreground">
            Packages are configured by admin and synced from the vehicle management panel.
          </p>
        </div>

        <div className="mb-6 rounded-[20px] border border-border bg-card p-4">
          <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
            Rental hours
          </p>
          <div className="mt-3 flex flex-wrap gap-2">
            {hourOptions.map((hours) => (
              <button
                key={hours}
                type="button"
                onClick={() => setRentalHours(hours)}
                className={cn(
                  "rounded-full px-4 py-2 text-sm font-semibold transition-colors",
                  rentalHours === hours
                    ? "bg-primary text-primary-foreground"
                    : "bg-muted text-muted-foreground hover:bg-muted/80"
                )}
              >
                {hours} hrs
              </button>
            ))}
          </div>
        </div>

        {isLoading ? (
          <div className="flex items-center justify-center py-16">
            <Loader2 className="h-8 w-8 animate-spin text-primary" />
          </div>
        ) : (
          <div className="space-y-3">
            {categories.map((category) => {
              const isSelected = selectedId === category.id;
              const image = vehicleImageForCategory(category);

              return (
                <button
                  key={category.id}
                  type="button"
                  onClick={() => setSelectedId(category.id)}
                  className={cn(
                    "flex w-full items-center gap-4 rounded-[20px] border bg-card p-4 text-left transition-all",
                    isSelected
                      ? "border-primary shadow-md ring-2 ring-primary/20"
                      : "border-border hover:border-primary/30"
                  )}
                >
                  <div className="relative h-16 w-16 shrink-0 overflow-hidden rounded-xl bg-secondary/30">
                    <VehicleOptionImage
                      src={image}
                      alt={category.name}
                      className="h-16 w-16"
                    />
                  </div>
                  <div className="min-w-0 flex-1">
                    <h3 className="font-heading text-base font-bold">{category.name}</h3>
                    <p className="mt-1 text-sm text-muted-foreground">
                      {category.description ?? "Daily rental package"}
                    </p>
                    <p className="mt-2 text-sm font-bold text-primary">
                      ₹{Math.round(category.base_fare)}/day
                    </p>
                    <p className="text-xs text-muted-foreground">
                      Minimum {Math.round(category.included_hours ?? 4)} hrs · ₹
                      {Math.round(category.per_hour_rate ?? 0)}/extra hr
                    </p>
                  </div>
                </button>
              );
            })}
          </div>
        )}

        {error ? <p className="mt-4 text-sm text-destructive">{error}</p> : null}

        <button
          type="button"
          disabled={!selected || isBooking}
          onClick={() => void handleConfirm()}
          className="mt-8 w-full rounded-[16px] bg-primary py-4 font-bold text-white shadow-lg transition-all hover:bg-primary/90 disabled:cursor-not-allowed disabled:opacity-50"
        >
          {isBooking ? "Booking..." : "Confirm Rental"}
        </button>
      </div>
    </div>
  );
}
