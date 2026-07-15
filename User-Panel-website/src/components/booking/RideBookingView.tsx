"use client";

import { useEffect, useMemo, useState } from "react";
import Image from "next/image";
import { useRouter, useSearchParams } from "next/navigation";
import { motion } from "framer-motion";
import { ArrowLeft, Banknote, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { ROUTES } from "@/constants/routes";
import {
  PAYMENT_METHODS,
  RIDE_VEHICLE_OPTIONS,
} from "@/data/ride-options";
import { getVehicleCategories } from "@/lib/home-api";
import { getProfile } from "@/lib/profile-api";
import { estimateRideFares, getRideDirections } from "@/lib/ride-api";
import { buildLocationSearchUrl } from "@/lib/location-search";
import { buildBookUrl, buildSearchingUrl, formatFare } from "@/lib/ride-booking";
import {
  categoryVehicleId,
  vehicleImageForCategory,
} from "@/lib/vehicle-map";
import { cn } from "@/lib/utils";
import { PreferWomenCaptainsDialog } from "@/components/booking/PreferWomenCaptainsDialog";

const MAP_EMBED_URL =
  "https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d14008.114827184203!2d77.216721!3d28.6328!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x390cfd37b741d057%3A0xc46ce4427b231eb5!2sConnaught%20Place%2C%20New%20Delhi%2C%20Delhi%20110001!5e0!3m2!1sen!2sin!4v1700000000000!5m2!1sen!2sin";

interface BookableOption {
  id: string;
  categoryId: string;
  name: string;
  eta: string;
  price: number;
  originalPrice?: number | null;
  image: string;
}

export function RideBookingView() {
  const router = useRouter();
  const searchParams = useSearchParams();

  const pickup = searchParams.get("pickup") || "";
  const dropoff = searchParams.get("dropoff") || "";
  const tab = searchParams.get("tab") || "rides";
  const vehicleParam = searchParams.get("vehicle");
  const categoryParam = searchParams.get("category");

  const [options, setOptions] = useState<BookableOption[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [selectedVehicle, setSelectedVehicle] = useState<string>("");
  const [payment] = useState(PAYMENT_METHODS[0]);
  const [memberDiscountPercent, setMemberDiscountPercent] = useState(0);
  const [userGender, setUserGender] = useState<string | null>(null);
  const [preferWomenOpen, setPreferWomenOpen] = useState(false);

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

      try {
        const categories = await getVehicleCategories("ride");
        const directions = await getRideDirections(pickup, dropoff);
        const fareResult = await estimateRideFares({
          pickup_lat: directions.pickup_lat,
          pickup_lng: directions.pickup_lng,
          dropoff_lat: directions.dropoff_lat,
          dropoff_lng: directions.dropoff_lng,
          distance_km: directions.distance_km,
          duration_min: directions.duration_min,
        });

        setMemberDiscountPercent(fareResult.discount_percent ?? 0);

        const apiOptions: BookableOption[] = [];

        for (const [index, category] of categories.entries()) {
          const quote = fareResult.quotes[category.id.toLowerCase()];
          let price = category.base_fare;
          const billableKm = Math.max(0, directions.distance_km - (category.included_distance_km ?? 0));
          if (!quote) {
            price = category.base_fare + category.per_km_rate * billableKm;
          }
          let originalPrice: number | null = null;

          if (quote) {
            price = quote.estimated_fare;
            originalPrice = quote.original_fare ?? null;
          } else if ((fareResult.discount_percent ?? 0) > 0) {
            originalPrice = price;
            price = Math.round(price * (1 - (fareResult.discount_percent ?? 0) / 100));
          }

          const mappedId = categoryVehicleId(category);
          const staticMeta = RIDE_VEHICLE_OPTIONS.find((v) => v.id === mappedId);
          apiOptions.push({
            id: String(mappedId),
            categoryId: category.id,
            name: category.name,
            eta: staticMeta?.eta ?? `${4 + index} mins`,
            price,
            originalPrice,
            image: vehicleImageForCategory(category),
          });
        }

        setOptions(apiOptions);
        if (apiOptions.length > 0) {
          const preferred =
            (categoryParam && apiOptions.find((o) => o.categoryId === categoryParam)?.id) ||
            (vehicleParam && apiOptions.find((o) => o.id === vehicleParam)?.id) ||
            apiOptions[0].id;
          setSelectedVehicle(preferred);
        }
      } catch {
        setOptions(
          RIDE_VEHICLE_OPTIONS.map((v) => ({
            id: v.id,
            categoryId: v.id,
            name: v.name,
            eta: v.eta,
            price: v.price,
            image: v.image,
          }))
        );
        setSelectedVehicle(vehicleParam ?? RIDE_VEHICLE_OPTIONS[0].id);
      } finally {
        setIsLoading(false);
      }
    }

    void load();
  }, [pickup, dropoff, categoryParam, vehicleParam]);

  const rideOptions: BookableOption[] = useMemo(
    () =>
      options.length
        ? options
        : RIDE_VEHICLE_OPTIONS.map((v) => ({
            id: v.id,
            categoryId: v.id,
            name: v.name,
            eta: v.eta,
            price: v.price,
            image: v.image,
          })),
    [options]
  );

  if (!pickup || !dropoff) {
    return null;
  }

  const selectedOption =
    rideOptions.find((v) => v.id === selectedVehicle) ?? rideOptions[0];

  const openLocation = (field: "pickup" | "dropoff") => {
    router.push(
      buildLocationSearchUrl({
        field,
        returnTo: buildBookUrl(pickup, dropoff, tab, selectedVehicle),
        pickup,
        dropoff,
        tab,
      })
    );
  };

  const proceedToSearching = (preferWomenRiders = false) => {
    router.push(
      buildSearchingUrl(
        pickup,
        dropoff,
        selectedVehicle,
        tab,
        selectedOption.categoryId,
        preferWomenRiders
      )
    );
  };

  const handleBook = () => {
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
        {memberDiscountPercent > 0 ? (
          <p className="mt-3 rounded-xl bg-primary/10 px-3 py-2 text-sm font-semibold text-primary">
            {Math.round(memberDiscountPercent)}% member discount applied
          </p>
        ) : null}
      </div>

      <div className="shrink-0 bg-card px-4 py-3">
        <div className="overflow-hidden rounded-[20px] border border-border shadow-sm">
          <iframe
            src={MAP_EMBED_URL}
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
        ) : (
          rideOptions.map((option) => {
            const isSelected = selectedVehicle === option.id;
            const isAmbulance = option.id === "ambulance";
            return (
              <button
                key={option.id}
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
                <div className="relative h-10 w-10 shrink-0">
                  <Image
                    src={option.image}
                    alt={option.name}
                    fill
                    className="object-contain"
                    sizes="40px"
                  />
                </div>
                <p className="min-w-0 flex-1 text-base font-medium text-foreground">
                  {option.name}
                  <span className="text-muted-foreground"> • {option.eta}</span>
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
        <button
          type="button"
          className="mb-3 flex items-center gap-2 text-sm text-muted-foreground transition-colors hover:text-foreground"
        >
          <Banknote className="h-4 w-4" />
          <span>{payment.label}</span>
        </button>
        <Button
          onClick={handleBook}
          disabled={isLoading}
          className="h-14 w-full rounded-[16px] bg-primary text-base font-bold text-primary-foreground shadow-md hover:bg-primary/90"
        >
          Book {selectedOption.name}
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
    </motion.div>
  );
}
