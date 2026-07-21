"use client";

import { useEffect, useRef, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { motion } from "framer-motion";
import { ArrowLeft, Loader2, LocateFixed, MapPin } from "lucide-react";
import {
  buildReturnUrlWithLocations,
  getLocationSearchCopy,
  type LocationFieldType,
} from "@/lib/location-search";
import {
  resolvePlaceDetails,
  reverseGeocode,
  searchPlaces,
  type PlaceSuggestion,
  type SelectedPlace,
} from "@/lib/places-api";
import { MAX_STOPS, parseStopsFromParams, type TripStop } from "@/lib/trip-stops";
import { cn } from "@/lib/utils";
import { ROUTES } from "@/constants/routes";

function SuggestionList({
  title,
  items,
  isPickup,
  isLoading,
  onSelect,
}: {
  title: string;
  items: PlaceSuggestion[];
  isPickup: boolean;
  isLoading?: boolean;
  onSelect: (place: PlaceSuggestion) => void;
}) {
  if (!isLoading && items.length === 0) return null;

  return (
    <section className="mb-6">
      <div className="mb-2.5 flex items-center gap-2 px-1">
        <MapPin
          className={cn("h-4 w-4", isPickup ? "text-primary" : "text-destructive")}
        />
        <h2 className="font-heading text-sm font-bold text-foreground">{title}</h2>
      </div>
      {isLoading ? (
        <div className="flex justify-center rounded-[var(--radius-card)] border border-border bg-card py-8">
          <Loader2 className="h-5 w-5 animate-spin text-primary" />
        </div>
      ) : (
        <ul className="divide-y divide-border overflow-hidden rounded-[var(--radius-card)] border border-border bg-card">
          {items.map((item) => (
            <li key={item.id}>
              <button
                type="button"
                onClick={() => onSelect(item)}
                className="flex w-full items-start gap-3 px-4 py-3.5 text-left transition-colors hover:bg-muted/60"
              >
                <MapPin
                  className={cn(
                    "mt-0.5 h-4 w-4 shrink-0",
                    isPickup ? "text-primary" : "text-destructive"
                  )}
                />
                <span className="min-w-0">
                  <span className="block text-sm font-semibold text-foreground">
                    {item.name}
                  </span>
                  <span className="mt-0.5 block text-sm text-muted-foreground">
                    {item.address}
                  </span>
                </span>
              </button>
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}

function parseField(raw: string | null): LocationFieldType {
  if (raw === "dropoff") return "dropoff";
  if (raw === "stop") return "stop";
  return "pickup";
}

export function LocationSearchView() {
  const router = useRouter();
  const searchParams = useSearchParams();

  const field = parseField(searchParams.get("field"));
  const returnTo = searchParams.get("return") || ROUTES.home;
  const tab = searchParams.get("tab");
  const savedPickup = searchParams.get("pickup") || "";
  const savedDropoff = searchParams.get("dropoff") || "";
  const savedPlat = searchParams.get("plat");
  const savedPlng = searchParams.get("plng");
  const savedDlat = searchParams.get("dlat");
  const savedDlng = searchParams.get("dlng");
  const existingStops = parseStopsFromParams(searchParams);
  const stopIndexRaw = searchParams.get("stopIndex");
  const stopIndex =
    stopIndexRaw != null && stopIndexRaw !== ""
      ? Math.min(Math.max(Number(stopIndexRaw) || 0, 0), MAX_STOPS - 1)
      : existingStops.length;

  const initialQuery =
    searchParams.get("q") ||
    (field === "pickup"
      ? savedPickup
      : field === "dropoff"
        ? savedDropoff
        : existingStops[stopIndex]?.label) ||
    "";

  const [query, setQuery] = useState(initialQuery);
  const [results, setResults] = useState<PlaceSuggestion[]>([]);
  const [isSearching, setIsSearching] = useState(false);
  const [isResolving, setIsResolving] = useState(false);
  const [locateError, setLocateError] = useState<string | null>(null);
  const inputRef = useRef<HTMLInputElement>(null);
  const isPickup = field === "pickup";
  const copy = getLocationSearchCopy(field, tab, stopIndex);

  useEffect(() => {
    setQuery(initialQuery);
    const timer = window.setTimeout(() => inputRef.current?.focus(), 80);
    return () => window.clearTimeout(timer);
  }, [initialQuery]);

  useEffect(() => {
    const trimmed = query.trim();
    if (trimmed.length < 2) {
      setResults([]);
      setIsSearching(false);
      return;
    }

    let cancelled = false;
    setIsSearching(true);
    const timer = window.setTimeout(async () => {
      try {
        const places = await searchPlaces(trimmed);
        if (!cancelled) setResults(places);
      } catch {
        if (!cancelled) setResults([]);
      } finally {
        if (!cancelled) setIsSearching(false);
      }
    }, 280);

    return () => {
      cancelled = true;
      window.clearTimeout(timer);
    };
  }, [query]);

  const baseCoords = {
    pickupLat: savedPlat != null ? Number(savedPlat) : undefined,
    pickupLng: savedPlng != null ? Number(savedPlng) : undefined,
    dropoffLat: savedDlat != null ? Number(savedDlat) : undefined,
    dropoffLng: savedDlng != null ? Number(savedDlng) : undefined,
  };

  const navigateWithPlace = (place: SelectedPlace) => {
    let nextPickup = savedPickup;
    let nextDropoff = savedDropoff;
    const nextStops = [...existingStops];
    const coords = { ...baseCoords };

    if (field === "pickup") {
      nextPickup = place.label;
      coords.pickupLat = place.latitude;
      coords.pickupLng = place.longitude;
    } else if (field === "dropoff") {
      nextDropoff = place.label;
      coords.dropoffLat = place.latitude;
      coords.dropoffLng = place.longitude;
    } else {
      const stop: TripStop = {
        label: place.label,
        latitude: place.latitude,
        longitude: place.longitude,
      };
      if (stopIndex < nextStops.length) {
        nextStops[stopIndex] = stop;
      } else if (nextStops.length < MAX_STOPS) {
        nextStops.push(stop);
      } else {
        nextStops[MAX_STOPS - 1] = stop;
      }
    }

    router.push(
      buildReturnUrlWithLocations(
        returnTo,
        nextPickup,
        nextDropoff,
        tab,
        coords,
        nextStops
      )
    );
  };

  const handleBack = () => {
    router.push(
      buildReturnUrlWithLocations(
        returnTo,
        savedPickup,
        savedDropoff,
        tab,
        baseCoords,
        existingStops
      )
    );
  };

  const handleSelect = async (suggestion: PlaceSuggestion) => {
    setIsResolving(true);
    setLocateError(null);
    try {
      const place = await resolvePlaceDetails(suggestion);
      navigateWithPlace(place);
    } catch {
      setLocateError("Unable to resolve this location. Try another place.");
      setIsResolving(false);
    }
  };

  const handleCurrentLocation = () => {
    if (!navigator.geolocation) {
      setLocateError("Location is not supported on this device.");
      return;
    }

    setIsResolving(true);
    setLocateError(null);
    navigator.geolocation.getCurrentPosition(
      async (position) => {
        try {
          const place = await reverseGeocode(
            position.coords.latitude,
            position.coords.longitude
          );
          navigateWithPlace(place);
        } catch {
          setLocateError("Unable to fetch current location.");
          setIsResolving(false);
        }
      },
      () => {
        setLocateError("Location permission denied. Enable GPS and try again.");
        setIsResolving(false);
      },
      { enableHighAccuracy: true, timeout: 15000 }
    );
  };

  const showSearchResults = query.trim().length >= 2;
  const showCurrentLocation = field === "pickup" || field === "stop";

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.25 }}
      className="flex min-h-screen flex-col bg-background font-sans"
    >
      <header className="flex shrink-0 items-center gap-3 border-b border-border px-4 py-4 sm:px-6">
        <button
          type="button"
          onClick={handleBack}
          className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full text-foreground transition-colors hover:bg-muted"
          aria-label="Go back"
        >
          <ArrowLeft className="h-5 w-5" />
        </button>
        <h1 className="font-heading text-lg font-bold text-foreground sm:text-xl">
          {copy.title}
        </h1>
      </header>

      <div className="shrink-0 px-4 pt-5 sm:px-6">
        <motion.div
          initial={{ opacity: 0, y: 8 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3, delay: 0.05 }}
          className="flex items-center gap-3 rounded-[var(--radius-input)] border-2 border-primary bg-card px-4 py-3.5 shadow-sm transition-shadow focus-within:shadow-md focus-within:shadow-primary/10"
        >
          <span
            className={cn(
              "h-2.5 w-2.5 shrink-0 rounded-full",
              isPickup ? "bg-success" : field === "stop" ? "bg-warning" : "bg-destructive"
            )}
            aria-hidden
          />
          <input
            ref={inputRef}
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder={copy.placeholder}
            className="w-full bg-transparent text-base font-medium text-foreground outline-none placeholder:font-normal placeholder:text-muted-foreground"
            autoComplete="off"
            spellCheck={false}
            disabled={isResolving}
          />
        </motion.div>
        <p className="mt-3 text-sm text-muted-foreground">
          {showSearchResults
            ? "Showing matching locations"
            : "Search a place, or use your current location"}
        </p>
        {locateError ? (
          <p className="mt-2 text-sm text-destructive">{locateError}</p>
        ) : null}
      </div>

      <div className="min-h-0 flex-1 overflow-y-auto px-4 pb-8 pt-5 sm:px-6">
        {isResolving ? (
          <div className="flex flex-col items-center gap-3 py-16 text-muted-foreground">
            <Loader2 className="h-6 w-6 animate-spin text-primary" />
            <p className="text-sm">Resolving location…</p>
          </div>
        ) : (
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.35, delay: 0.1 }}
          >
            {showCurrentLocation && !showSearchResults && (
              <section className="mb-6">
                <button
                  type="button"
                  onClick={handleCurrentLocation}
                  className="flex w-full items-center gap-3 rounded-[var(--radius-card)] border border-border bg-card px-4 py-3.5 text-left transition-colors hover:bg-muted/60"
                >
                  <LocateFixed className="h-5 w-5 text-success" />
                  <span>
                    <span className="block text-sm font-semibold text-foreground">
                      Use current location
                    </span>
                    <span className="mt-0.5 block text-sm text-muted-foreground">
                      Detect from GPS
                    </span>
                  </span>
                </button>
              </section>
            )}

            {showSearchResults && (
              <SuggestionList
                title="Search results"
                items={results}
                isPickup={isPickup}
                isLoading={isSearching}
                onSelect={handleSelect}
              />
            )}

            {showSearchResults && !isSearching && results.length === 0 && (
              <p className="px-1 text-sm text-muted-foreground">No locations found</p>
            )}
          </motion.div>
        )}
      </div>
    </motion.div>
  );
}
