import type { LandingBookingTab } from "@/constants/services";
import { ROUTES } from "@/constants/routes";

export type LocationFieldType = "pickup" | "dropoff";

const VALID_TABS: LandingBookingTab[] = ["rides", "parcel", "ambulance"];

export function isLandingBookingTab(value: string | null): value is LandingBookingTab {
  return value !== null && VALID_TABS.includes(value as LandingBookingTab);
}

export function getLocationSearchCopy(
  field: LocationFieldType,
  tab?: string | null
) {
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

export function buildLocationSearchUrl(options: {
  field: LocationFieldType;
  returnTo: string;
  pickup?: string;
  dropoff?: string;
  tab?: string;
}) {
  const params = new URLSearchParams({
    field: options.field,
    return: options.returnTo,
  });

  if (options.pickup) params.set("pickup", options.pickup);
  if (options.dropoff) params.set("dropoff", options.dropoff);
  if (options.tab) params.set("tab", options.tab);

  const currentValue =
    options.field === "pickup" ? options.pickup : options.dropoff;
  if (currentValue) params.set("q", currentValue);

  return `${ROUTES.location}?${params.toString()}`;
}

export function buildReturnUrlWithLocations(
  returnTo: string,
  pickup: string,
  dropoff: string,
  tab?: string | null
) {
  const [pathname, existingQuery] = returnTo.split("?");
  const params = new URLSearchParams(existingQuery || "");

  if (pickup) params.set("pickup", pickup);
  if (dropoff) params.set("dropoff", dropoff);
  if (tab) params.set("tab", tab);

  const query = params.toString();
  return query ? `${pathname}?${query}` : pathname;
}
