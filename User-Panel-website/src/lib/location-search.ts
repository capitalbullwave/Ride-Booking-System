import type { LandingBookingTab } from "@/constants/services";
import { ROUTES } from "@/constants/routes";
import {
  parseStopsFromParams,
  writeStopsToParams,
  type TripStop,
} from "@/lib/trip-stops";

export type LocationFieldType = "pickup" | "dropoff" | "stop";

const VALID_TABS: LandingBookingTab[] = ["rides", "parcel", "ambulance"];

export function isLandingBookingTab(value: string | null): value is LandingBookingTab {
  return value !== null && VALID_TABS.includes(value as LandingBookingTab);
}

export function getLocationSearchCopy(
  field: LocationFieldType,
  tab?: string | null,
  stopIndex?: number
) {
  if (field === "stop") {
    return {
      title: stopIndex != null ? `Add stop ${(stopIndex ?? 0) + 1}` : "Add stop",
      placeholder: "Enter stop location",
    };
  }

  if (field === "pickup") {
    return {
      title: "Enter pickup location",
      placeholder: "Enter pickup location",
    };
  }

  if (tab === "parcel") {
    return {
      title: "Enter delivery address",
      placeholder: "Enter delivery address",
    };
  }

  if (tab === "ambulance") {
    return {
      title: "Enter hospital or destination",
      placeholder: "Hospital or destination",
    };
  }

  return {
    title: "Enter dropoff location",
    placeholder: "Enter dropoff location",
  };
}

export interface LocationCoords {
  pickupLat?: number;
  pickupLng?: number;
  dropoffLat?: number;
  dropoffLng?: number;
}

export function buildLocationSearchUrl(options: {
  field: LocationFieldType;
  returnTo: string;
  pickup?: string;
  dropoff?: string;
  tab?: string;
  coords?: LocationCoords;
  stops?: TripStop[];
  stopIndex?: number;
}) {
  const params = new URLSearchParams({
    field: options.field,
    return: options.returnTo,
  });

  if (options.pickup) params.set("pickup", options.pickup);
  if (options.dropoff) params.set("dropoff", options.dropoff);
  if (options.tab) params.set("tab", options.tab);
  if (options.coords?.pickupLat != null) params.set("plat", String(options.coords.pickupLat));
  if (options.coords?.pickupLng != null) params.set("plng", String(options.coords.pickupLng));
  if (options.coords?.dropoffLat != null) params.set("dlat", String(options.coords.dropoffLat));
  if (options.coords?.dropoffLng != null) params.set("dlng", String(options.coords.dropoffLng));
  if (options.stops) writeStopsToParams(params, options.stops);
  if (options.field === "stop" && options.stopIndex != null) {
    params.set("stopIndex", String(options.stopIndex));
  }

  let currentValue: string | undefined;
  if (options.field === "pickup") currentValue = options.pickup;
  else if (options.field === "dropoff") currentValue = options.dropoff;
  else if (options.field === "stop" && options.stopIndex != null) {
    currentValue = options.stops?.[options.stopIndex]?.label;
  }
  if (currentValue) params.set("q", currentValue);

  return `${ROUTES.location}?${params.toString()}`;
}

export function buildReturnUrlWithLocations(
  returnTo: string,
  pickup: string,
  dropoff: string,
  tab?: string | null,
  coords?: LocationCoords,
  stops?: TripStop[]
) {
  const [pathname, existingQuery] = returnTo.split("?");
  const params = new URLSearchParams(existingQuery || "");

  if (pickup) params.set("pickup", pickup);
  else params.delete("pickup");
  if (dropoff) params.set("dropoff", dropoff);
  else params.delete("dropoff");
  if (tab) params.set("tab", tab);

  if (coords?.pickupLat != null) params.set("plat", String(coords.pickupLat));
  else params.delete("plat");
  if (coords?.pickupLng != null) params.set("plng", String(coords.pickupLng));
  else params.delete("plng");
  if (coords?.dropoffLat != null) params.set("dlat", String(coords.dropoffLat));
  else params.delete("dlat");
  if (coords?.dropoffLng != null) params.set("dlng", String(coords.dropoffLng));
  else params.delete("dlng");

  if (stops) writeStopsToParams(params, stops);
  else {
    // Preserve existing stops from return URL if not explicitly updated.
    const existing = parseStopsFromParams(params);
    if (existing.length > 0) writeStopsToParams(params, existing);
  }

  const query = params.toString();
  return query ? `${pathname}?${query}` : pathname;
}
