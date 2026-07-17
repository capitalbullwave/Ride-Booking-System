"use client";

import { useEffect, useMemo, useRef, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { motion } from "framer-motion";
import { ArrowLeft, Clock, LocateFixed, MapPin, Star } from "lucide-react";
import {
  CURRENT_LOCATION_SUGGESTION,
  filterLocationSuggestions,
  POPULAR_LOCATION_SUGGESTIONS,
  RECENT_LOCATION_SUGGESTIONS,
  type LocationSuggestion,
} from "@/data/locations";
import {
  buildReturnUrlWithLocations,
  getLocationSearchCopy,
  type LocationFieldType,
} from "@/lib/location-search";
import { cn } from "@/lib/utils";
import { ROUTES } from "@/constants/routes";

function SuggestionSection({
  title,
  icon: Icon,
  items,
  isPickup,
  onSelect,
}: {
  title: string;
  icon: typeof MapPin;
  items: LocationSuggestion[];
  isPickup: boolean;
  onSelect: (address: string) => void;
}) {
  if (items.length === 0) return null;

  return (
    <section className="mb-6">
      <div className="mb-2.5 flex items-center gap-2 px-1">
        <Icon
          className={cn(
            "h-4 w-4",
            isPickup ? "text-primary" : "text-destructive"
          )}
        />
        <h2 className="font-heading text-sm font-bold text-foreground">{title}</h2>
      </div>
      <ul className="divide-y divide-border overflow-hidden rounded-[var(--radius-card)] border border-border bg-card">
        {items.map((item) => (
          <li key={item.id}>
            <button
              type="button"
              onClick={() => onSelect(item.address)}
              className="flex w-full items-start gap-3 px-4 py-3.5 text-left transition-colors hover:bg-muted/60"
            >
              <MapPin
                className={cn(
                  "mt-0.5 h-4 w-4 shrink-0",
                  item.id === "current"
                    ? "text-success"
                    : isPickup
                      ? "text-primary"
                      : "text-destructive"
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
    </section>
  );
}

export function LocationSearchView() {
  const router = useRouter();
  const searchParams = useSearchParams();

  const field = (searchParams.get("field") === "dropoff" ? "dropoff" : "pickup") as LocationFieldType;
  const returnTo = searchParams.get("return") || ROUTES.landing;
  const tab = searchParams.get("tab");
  const savedPickup = searchParams.get("pickup") || "";
  const savedDropoff = searchParams.get("dropoff") || "";
  const initialQuery =
    searchParams.get("q") ||
    (field === "pickup" ? savedPickup : savedDropoff) ||
    "";

  const [query, setQuery] = useState(initialQuery);
  const inputRef = useRef<HTMLInputElement>(null);
  const isPickup = field === "pickup";
  const copy = getLocationSearchCopy(field, tab);

  useEffect(() => {
    setQuery(initialQuery);
    const timer = window.setTimeout(() => inputRef.current?.focus(), 80);
    return () => window.clearTimeout(timer);
  }, [initialQuery]);

  const searchResults = useMemo(() => filterLocationSuggestions(query), [query]);
  const isSearching = query.trim().length >= 4;
  const showDefaultSuggestions = !isSearching;

  const handleBack = () => {
    router.push(
      buildReturnUrlWithLocations(returnTo, savedPickup, savedDropoff, tab)
    );
  };

  const handleSelect = (location: string) => {
    const nextPickup = field === "pickup" ? location : savedPickup;
    const nextDropoff = field === "dropoff" ? location : savedDropoff;
    router.push(
      buildReturnUrlWithLocations(returnTo, nextPickup, nextDropoff, tab)
    );
  };

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
              isPickup ? "bg-success" : "bg-destructive"
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
          />
        </motion.div>
        <p className="mt-3 text-sm text-muted-foreground">
          {isSearching
            ? "Showing matching locations"
            : "Enter a minimum of 4 letters to search, or pick a suggestion below"}
        </p>
      </div>

      <div className="min-h-0 flex-1 overflow-y-auto px-4 pb-8 pt-5 sm:px-6">
        {showDefaultSuggestions && (
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.35, delay: 0.1 }}
          >
            {isPickup && (
              <SuggestionSection
                title="Quick action"
                icon={LocateFixed}
                items={[CURRENT_LOCATION_SUGGESTION]}
                isPickup={isPickup}
                onSelect={handleSelect}
              />
            )}

            <SuggestionSection
              title="Recent"
              icon={Clock}
              items={RECENT_LOCATION_SUGGESTIONS}
              isPickup={isPickup}
              onSelect={handleSelect}
            />

            <SuggestionSection
              title="Popular places"
              icon={Star}
              items={POPULAR_LOCATION_SUGGESTIONS}
              isPickup={isPickup}
              onSelect={handleSelect}
            />
          </motion.div>
        )}

        {isSearching && searchResults.length > 0 && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
          >
            <SuggestionSection
              title="Search results"
              icon={MapPin}
              items={searchResults}
              isPickup={isPickup}
              onSelect={handleSelect}
            />
          </motion.div>
        )}

        {isSearching && searchResults.length === 0 && (
          <p className="px-1 text-sm text-muted-foreground">No locations found</p>
        )}
      </div>
    </motion.div>
  );
}
