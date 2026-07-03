import type { RideVehicleId } from "@/data/ride-options";
import type { VehicleCategory } from "@/lib/home-api";
import { resolveMediaUrl } from "@/lib/api";
import { ROUTES } from "@/constants/routes";

/** Maps backend vehicle category slugs to frontend ride vehicle ids when available. */
export const CATEGORY_SLUG_TO_VEHICLE: Record<string, RideVehicleId> = {
  bike: "bike",
  "bike-taxi": "bike",
  auto: "auto",
  "electric-auto": "auto",
  economy: "cab",
  comfort: "cab",
  premium: "cab",
  cab: "cab",
  xl: "cab",
  parcel: "parcel",
  travel: "travel",
  ambulance: "ambulance",
};

export const VEHICLE_TO_CATEGORY_SLUG: Partial<Record<RideVehicleId, string>> = {
  bike: "bike",
  auto: "auto",
  cab: "economy",
  ambulance: "ambulance",
};

export function vehicleImageForSlug(slug: string): string {
  const normalized = slug.toLowerCase();
  if (normalized.includes("bike")) return "/images/services/bike.png";
  if (normalized.includes("auto")) return "/images/services/auto.png";
  if (normalized.includes("parcel")) return "/images/services/parcel.png";
  if (normalized.includes("travel")) return "/images/services/travel.png";
  if (normalized.includes("ambulance")) return "/images/services/ambulance.png";
  return "/images/services/car.png";
}

export function vehicleImageForCategory(category: VehicleCategory): string {
  if (category.icon_url?.startsWith("/uploads/")) {
    return category.icon_url;
  }
  return resolveMediaUrl(category.icon_url) ?? vehicleImageForSlug(category.slug);
}

export function homeRouteForCategory(category: VehicleCategory): string {
  const slug = category.slug.toLowerCase();
  const serviceGroup = category.service_group ?? "ride";
  if (serviceGroup === "rental" || slug.startsWith("rental")) return ROUTES.rental;
  if (slug.includes("ambulance")) return ROUTES.ambulance;
  if (slug.includes("parcel")) return `${ROUTES.start}?tab=parcel&vehicle=parcel`;
  const vehicleId = CATEGORY_SLUG_TO_VEHICLE[slug];
  if (vehicleId) return `${ROUTES.start}?tab=rides&vehicle=${vehicleId}`;
  return `${ROUTES.start}?tab=rides&category=${category.id}`;
}

export function estimateDistanceKm(): number {
  return 5.2;
}

export function estimateDurationMin(): number {
  return 18;
}

export function categoryVehicleId(category: VehicleCategory): RideVehicleId | string {
  return CATEGORY_SLUG_TO_VEHICLE[category.slug] ?? category.id;
}
