"use client";

import { useEffect, useMemo, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { motion } from "framer-motion";
import { ArrowLeft, Banknote, CalendarClock, ChevronRight, Loader2, Plus, Tag, X } from "lucide-react";
import { Button } from "@/components/ui/button";
import { ROUTES } from "@/constants/routes";
import { PAYMENT_METHODS } from "@/data/ride-options";
import { getVehicleCategories, type VehicleCategory } from "@/lib/home-api";
import { getProfile } from "@/lib/profile-api";
import {
  estimateRideFares,
  getRideDirections,
  type PaymentMethod,
} from "@/lib/ride-api";
import type { AppliedCoupon } from "@/lib/coupons-api";
import { getProtectedPath, isAuthenticated } from "@/lib/auth-session";
import { buildLocationSearchUrl } from "@/lib/location-search";
import {
  buildBookUrl,
  buildSearchingUrl,
  formatFare,
  mapEmbedUrl,
  parseTripCoords,
} from "@/lib/ride-booking";
import { canAddStop, MAX_STOPS } from "@/lib/trip-stops";
import {
  categoryVehicleId,
  displayVehicleName,
  vehicleImageForCategory,
} from "@/lib/vehicle-map";
import { cn } from "@/lib/utils";
import { BookingOffersSheet } from "@/components/booking/BookingOffersSheet";
import { PreferWomenCaptainsDialog } from "@/components/booking/PreferWomenCaptainsDialog";
import { VehicleOptionImage } from "@/components/booking/VehicleOptionImage";

interface BookableOption {
  id: string;
  categoryId: string;
  name: string;
  eta: string;
  price: number;
  originalPrice?: number | null;
  image: string;
}

function filterCategoriesForTab(categories: VehicleCategory[], tab: string) {
  return categories.filter((category) => {
    const slug = category.slug.toLowerCase();
    const group = (category.service_group ?? "ride").toLowerCase();
    if (group === "rental") return false;
    if (tab === "parcel") return slug.includes("parcel");
    if (tab === "ambulance") return slug.includes("ambulance");
    return !slug.includes("parcel");
  });
}

export function RideBookingView() {
  const router = useRouter();
  const searchParams = useSearchParams();

  const pickup = searchParams.get("pickup") || "";
  const dropoff = searchParams.get("dropoff") || "";
  const tab = searchParams.get("tab") || "rides";
  const vehicleParam = searchParams.get("vehicle");
  const categoryParam = searchParams.get("category");
  const tripCoords = parseTripCoords(searchParams);
  const stops = tripCoords.stops;
  const stopsSignature = stops
    .map((s) => `${s.label}|${s.latitude ?? ""}|${s.longitude ?? ""}`)
    .join(";");

  const [options, setOptions] = useState<BookableOption[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [selectedVehicle, setSelectedVehicle] = useState<string>("");
  const [paymentIndex, setPaymentIndex] = useState(0);
  const [memberDiscountPercent, setMemberDiscountPercent] = useState(0);
  const [userGender, setUserGender] = useState<string | null>(null);
  const [preferWomenOpen, setPreferWomenOpen] = useState(false);
  const [offersOpen, setOffersOpen] = useState(false);
  const [appliedCoupon, setAppliedCoupon] = useState<AppliedCoupon | null>(null);
  const [scheduledAt, setScheduledAt] = useState(searchParams.get("scheduled_at") || "");
  const [reloadKey, setReloadKey] = useState(0);
  const [routeMeta, setRouteMeta] = useState({
    pickupLat: tripCoords.pickupLat,
    pickupLng: tripCoords.pickupLng,
    dropoffLat: tripCoords.dropoffLat,
    dropoffLng: tripCoords.dropoffLng,
    distanceKm: tripCoords.distanceKm,
    durationMin: tripCoords.durationMin,
  });

  const payment = PAYMENT_METHODS[paymentIndex] ?? PAYMENT_METHODS[0];

  useEffect(() => {
    if (tripCoords.payment) {
      const idx = PAYMENT_METHODS.findIndex((m) => m.id === tripCoords.payment);
      if (idx >= 0) setPaymentIndex(idx);
    }
  }, [tripCoords.payment]);

  useEffect(() => {
    async function loadProfile() {
      try {
        const profile = await getProfile();
        setUserGender(profile.gender);
      } catch {
        // Booking can continue without profile metadata.
      }
    }
    void loadProfile();
  }, []);

  useEffect(() => {
    if (!pickup || !dropoff) {
      router.replace(ROUTES.home);
    }
  }, [pickup, dropoff, router]);

  useEffect(() => {
    async function load() {
      if (!pickup || !dropoff) return;

      setIsLoading(true);
      setLoadError(null);

      try {
        const categories = filterCategoriesForTab(
          await getVehicleCategories("ride"),
          tab
        );

        const routeStops = tripCoords.stops;
        const directions = await getRideDirections(
          {
            label: pickup,
            latitude: tripCoords.pickupLat,
            longitude: tripCoords.pickupLng,
          },
          {
            label: dropoff,
            latitude: tripCoords.dropoffLat,
            longitude: tripCoords.dropoffLng,
          },
          routeStops
        );

        const fareResult = await estimateRideFares({
          pickup_lat: directions.pickup_lat,
          pickup_lng: directions.pickup_lng,
          dropoff_lat: directions.dropoff_lat,
          dropoff_lng: directions.dropoff_lng,
          distance_km: directions.distance_km,
          duration_min: directions.duration_min,
          service_group: "ride",
          stops: routeStops,
        });

        setRouteMeta({
          pickupLat: directions.pickup_lat,
          pickupLng: directions.pickup_lng,
          dropoffLat: directions.dropoff_lat,
          dropoffLng: directions.dropoff_lng,
          distanceKm: fareResult.distance_km ?? directions.distance_km,
          durationMin: fareResult.duration_min ?? directions.duration_min,
        });
        setMemberDiscountPercent(fareResult.discount_percent ?? 0);

        const apiOptions: BookableOption[] = [];

        for (const [index, category] of categories.entries()) {
          const quote = fareResult.quotes[category.id.toLowerCase()];
          if (!quote) continue;

          const mappedId = categoryVehicleId(category);
          apiOptions.push({
            id: String(mappedId),
            categoryId: category.id,
            name: displayVehicleName(category.name, category.slug),
            eta: `${Math.max(3, Math.round((fareResult.duration_min ?? directions.duration_min) / Math.max(categories.length, 1)) + index)} mins`,
            price: quote.estimated_fare,
            originalPrice: quote.original_fare ?? null,
            image: vehicleImageForCategory(category),
          });
        }

        if (apiOptions.length === 0) {
          throw new Error("No fare quotes available for this route");
        }

        setOptions(apiOptions);
        const preferred =
          (categoryParam && apiOptions.find((o) => o.categoryId === categoryParam)?.id) ||
          (vehicleParam && apiOptions.find((o) => o.id === vehicleParam)?.id) ||
          apiOptions[0].id;
        setSelectedVehicle(preferred);
      } catch (err) {
        setOptions([]);
        setLoadError(
          err instanceof Error ? err.message : "Unable to load fares for this route"
        );
      } finally {
        setIsLoading(false);
      }
    }

    void load();
    // Coords/stops from URL are intentional inputs for directions.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [pickup, dropoff, categoryParam, vehicleParam, tab, reloadKey, stopsSignature]);

  const rideOptions = useMemo(() => options, [options]);

  if (!pickup || !dropoff) {
    return null;
  }

  const selectedOption =
    rideOptions.find((v) => v.id === selectedVehicle) ?? rideOptions[0];

  const tripExtras = {
    pickupLat: routeMeta.pickupLat,
    pickupLng: routeMeta.pickupLng,
    dropoffLat: routeMeta.dropoffLat,
    dropoffLng: routeMeta.dropoffLng,
    distanceKm: routeMeta.distanceKm,
    durationMin: routeMeta.durationMin,
    payment: payment.id as PaymentMethod,
    stops,
    promoCode: appliedCoupon?.coupon.code,
    scheduledAt: scheduledAt || undefined,
  };

  /** Preserve selection so after login user returns to the same book screen. */
  const bookReturnPath = selectedOption
    ? buildBookUrl(pickup, dropoff, tab, selectedVehicle, {
        ...tripExtras,
        categoryId: selectedOption.categoryId,
      })
    : (() => {
        const qs = searchParams.toString();
        return qs ? `${ROUTES.book}?${qs}` : ROUTES.book;
      })();

  const displayFare =
    appliedCoupon != null
      ? appliedCoupon.final_amount
      : selectedOption?.price ?? 0;

  const openLocation = (field: "pickup" | "dropoff" | "stop", stopIndex?: number) => {
    router.push(
      buildLocationSearchUrl({
        field,
        returnTo: buildBookUrl(pickup, dropoff, tab, selectedVehicle, tripExtras),
        pickup,
        dropoff,
        tab,
        coords: {
          pickupLat: routeMeta.pickupLat,
          pickupLng: routeMeta.pickupLng,
          dropoffLat: routeMeta.dropoffLat,
          dropoffLng: routeMeta.dropoffLng,
        },
        stops,
        stopIndex,
      })
    );
  };

  const removeStop = (index: number) => {
    const next = stops.filter((_, i) => i !== index);
    router.replace(
      buildBookUrl(pickup, dropoff, tab, selectedVehicle, {
        ...tripExtras,
        stops: next,
      })
    );
  };

  const cyclePayment = () => {
    setPaymentIndex((prev) => (prev + 1) % PAYMENT_METHODS.length);
  };

  const proceedToSearching = (preferWomenRiders = false) => {
    if (!selectedOption) return;
    if (!isAuthenticated()) {
      router.replace(getProtectedPath(bookReturnPath));
      return;
    }
    if (
      routeMeta.pickupLat == null ||
      routeMeta.pickupLng == null ||
      routeMeta.dropoffLat == null ||
      routeMeta.dropoffLng == null
    ) {
      setLoadError("Route coordinates missing. Please reselect pickup and drop.");
      return;
    }

    const searchingUrl = buildSearchingUrl(
      pickup,
      dropoff,
      selectedVehicle,
      tab,
      selectedOption.categoryId,
      preferWomenRiders,
      tripExtras
    );
    // Searching / book-ride requires auth (middleware + API).
    router.push(getProtectedPath(searchingUrl));
  };

  const handleBook = () => {
    if (!isAuthenticated()) {
      router.replace(getProtectedPath(bookReturnPath));
      return;
    }
    if ((userGender ?? "").toLowerCase() === "female") {
      setPreferWomenOpen(true);
      return;
    }
    proceedToSearching(false);
  };

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.25 }}
      className="flex min-h-screen w-full flex-col bg-card font-sans"
    >
      <header className="sticky top-0 z-30 flex items-center border-b border-border bg-card px-4 py-3">
        <button
          type="button"
          onClick={() => router.push(ROUTES.home)}
          className="flex h-10 w-10 items-center justify-center rounded-full text-foreground transition-colors hover:bg-muted"
          aria-label="Go back"
        >
          <ArrowLeft className="h-5 w-5" />
        </button>
      </header>

      <div className="bg-card px-4 py-3">
        <div className="relative flex flex-col gap-3">
          <div className="absolute top-10 bottom-10 left-[1.15rem] w-px border-l border-dashed border-muted-foreground/40" />

          <button
            type="button"
            onClick={() => openLocation("pickup")}
            className="flex w-full items-start gap-3 rounded-[18px] border border-border bg-card px-4 py-3.5 text-left shadow-sm transition-colors hover:bg-muted/30"
          >
            <span className="mt-1 h-2.5 w-2.5 shrink-0 rounded-full bg-success" />
            <span className="min-w-0 flex-1">
              <span className="block text-sm font-semibold text-success">Pickup</span>
              <span className="mt-0.5 block text-sm leading-snug text-foreground">{pickup}</span>
            </span>
          </button>

          {stops.map((stop, index) => (
            <div
              key={`book-stop-${index}-${stop.label}`}
              className="flex w-full items-start gap-3 rounded-[18px] border border-border bg-card px-4 py-3.5 shadow-sm"
            >
              <button
                type="button"
                onClick={() => openLocation("stop", index)}
                className="flex min-w-0 flex-1 items-start gap-3 text-left"
              >
                <span className="mt-1 h-2.5 w-2.5 shrink-0 rounded-full bg-warning" />
                <span className="min-w-0 flex-1">
                  <span className="block text-sm font-semibold text-warning">
                    Stop {index + 1}
                  </span>
                  <span className="mt-0.5 block text-sm leading-snug text-foreground">
                    {stop.label}
                  </span>
                </span>
              </button>
              <button
                type="button"
                onClick={() => removeStop(index)}
                className="mt-0.5 flex h-7 w-7 shrink-0 items-center justify-center rounded-full text-muted-foreground hover:bg-muted hover:text-foreground"
                aria-label={`Remove stop ${index + 1}`}
              >
                <X className="h-4 w-4" />
              </button>
            </div>
          ))}

          <button
            type="button"
            onClick={() => openLocation("dropoff")}
            className="flex w-full items-start gap-3 rounded-[18px] border border-border bg-card px-4 py-3.5 text-left shadow-sm transition-colors hover:bg-muted/30"
          >
            <span className="mt-1 h-2.5 w-2.5 shrink-0 rounded-full bg-destructive" />
            <span className="min-w-0 flex-1">
              <span className="block text-sm font-semibold text-destructive">Drop</span>
              <span className="mt-0.5 block text-sm leading-snug text-foreground">{dropoff}</span>
            </span>
          </button>
        </div>
        {canAddStop(stops) ? (
          <button
            type="button"
            onClick={() => openLocation("stop", stops.length)}
            className="mt-3 flex w-full items-center justify-center gap-2 rounded-[14px] border border-dashed border-border px-3 py-2.5 text-sm font-semibold text-primary transition-colors hover:bg-primary/5"
          >
            <Plus className="h-4 w-4" />
            Add stop ({stops.length}/{MAX_STOPS})
          </button>
        ) : null}
        {memberDiscountPercent > 0 ? (
          <p className="mt-3 rounded-xl bg-primary/10 px-3 py-2 text-sm font-semibold text-primary">
            {Math.round(memberDiscountPercent)}% member discount applied
          </p>
        ) : null}
        {routeMeta.distanceKm != null ? (
          <p className="mt-2 text-xs text-muted-foreground">
            {routeMeta.distanceKm.toFixed(1)} km
            {routeMeta.durationMin != null
              ? ` · ~${Math.round(routeMeta.durationMin)} min`
              : ""}
          </p>
        ) : null}
      </div>

      <div className="shrink-0 bg-card px-4 py-3">
        <div className="overflow-hidden rounded-[20px] border border-border shadow-sm">
          <iframe
            src={mapEmbedUrl(
              routeMeta.pickupLat,
              routeMeta.pickupLng,
              routeMeta.dropoffLat,
              routeMeta.dropoffLng
            )}
            width="100%"
            height="100%"
            style={{ border: 0 }}
            allowFullScreen={false}
            loading="lazy"
            referrerPolicy="no-referrer-when-downgrade"
            className="h-[200px] w-full sm:h-[240px]"
            title="Ride route map"
          />
        </div>
      </div>

      <div className="flex-1 space-y-2 bg-card px-4 py-3">
        {isLoading ? (
          <div className="flex justify-center py-10">
            <Loader2 className="h-8 w-8 animate-spin text-primary" />
          </div>
        ) : loadError ? (
          <div className="rounded-[18px] border border-destructive/30 bg-destructive/5 px-4 py-6 text-center">
            <p className="text-sm font-medium text-destructive">{loadError}</p>
            <Button
              type="button"
              variant="outline"
              className="mt-4"
              onClick={() => setReloadKey((k) => k + 1)}
            >
              Retry
            </Button>
          </div>
        ) : (
          rideOptions.map((option) => {
            const isSelected = selectedVehicle === option.id;
            const isAmbulance = option.id === "ambulance";
            return (
              <button
                key={option.categoryId}
                type="button"
                onClick={() => setSelectedVehicle(option.id)}
                className={cn(
                  "flex w-full items-center gap-3 rounded-[18px] border px-4 py-4 text-left shadow-sm transition-all",
                  isSelected
                    ? isAmbulance
                      ? "border-destructive/40 bg-destructive/5"
                      : "border-primary/40 bg-muted/50"
                    : "border-border bg-card hover:border-primary/20 hover:bg-muted/20"
                )}
              >
                <VehicleOptionImage src={option.image} alt={option.name} />
                <p className="min-w-0 flex-1 text-base font-medium text-foreground">
                  {option.name}
                  <span className="text-muted-foreground"> · {option.eta}</span>
                </p>
                <div className="shrink-0 text-right">
                  {option.originalPrice != null && option.originalPrice > option.price ? (
                    <p className="text-sm text-muted-foreground line-through">
                      {formatFare(option.originalPrice)}
                    </p>
                  ) : null}
                  <p className="text-base font-semibold text-foreground">
                    {formatFare(option.price)}
                  </p>
                </div>
              </button>
            );
          })
        )}
      </div>

      <div className="sticky bottom-0 z-30 border-t border-border bg-card px-4 py-4 shadow-[0_-4px_20px_-10px_rgba(0,0,0,0.12)]">
        <div className="mb-3 space-y-2">
          <button
            type="button"
            onClick={cyclePayment}
            className="flex w-full items-center justify-between gap-2 text-sm text-muted-foreground transition-colors hover:text-foreground"
          >
            <span className="flex items-center gap-2">
              <Banknote className="h-4 w-4" />
              <span>Pay by {payment.label}</span>
            </span>
            <ChevronRight className="h-4 w-4" />
          </button>
          <button
            type="button"
            onClick={() => setOffersOpen(true)}
            className="flex w-full items-center justify-between gap-2 text-sm text-muted-foreground transition-colors hover:text-foreground"
          >
            <span className="flex items-center gap-2">
              <Tag className="h-4 w-4" />
              <span>
                {appliedCoupon
                  ? `Offer ${appliedCoupon.coupon.code} (−${formatFare(appliedCoupon.discount_amount)})`
                  : "Apply offers"}
              </span>
            </span>
            <ChevronRight className="h-4 w-4" />
          </button>
          <label className="flex w-full items-center justify-between gap-2 text-sm text-muted-foreground">
            <span className="flex items-center gap-2">
              <CalendarClock className="h-4 w-4" />
              <span>Schedule (optional)</span>
            </span>
            <input
              type="datetime-local"
              value={scheduledAt ? scheduledAt.slice(0, 16) : ""}
              onChange={(e) => {
                const value = e.target.value;
                setScheduledAt(value ? new Date(value).toISOString() : "");
              }}
              className="max-w-[180px] rounded-lg border border-border bg-background px-2 py-1 text-xs text-foreground"
            />
          </label>
        </div>
        <Button
          onClick={handleBook}
          disabled={isLoading || !selectedOption || !!loadError}
          className="h-14 w-full rounded-[16px] bg-primary text-base font-bold text-primary-foreground shadow-md hover:bg-primary/90"
        >
          {scheduledAt ? "Schedule" : "Book"} {selectedOption?.name ?? "Ride"}
          {selectedOption ? ` · ${formatFare(displayFare)}` : ""}
        </Button>
      </div>

      <PreferWomenCaptainsDialog
        open={preferWomenOpen}
        onEnable={() => {
          setPreferWomenOpen(false);
          proceedToSearching(true);
        }}
        onSkip={() => {
          setPreferWomenOpen(false);
          proceedToSearching(false);
        }}
      />

      <BookingOffersSheet
        open={offersOpen}
        orderAmount={selectedOption?.price ?? 0}
        appliedCode={appliedCoupon?.coupon.code}
        onClose={() => setOffersOpen(false)}
        onApply={setAppliedCoupon}
        onClear={() => setAppliedCoupon(null)}
      />
    </motion.div>
  );
}
