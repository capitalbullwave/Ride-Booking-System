import type { RideVehicleId } from "@/data/ride-options";
import type { VehicleCategory } from "@/lib/home-api";
import { getApiBaseUrl, resolveMediaUrl } from "@/lib/api";
import { ROUTES } from "@/constants/routes";

/** Maps backend vehicle category slugs to frontend ride vehicle ids when available. */
export const CATEGORY_SLUG_TO_VEHICLE: Record<string, RideVehicleId> = {
  bike: "bike",
  "bike-taxi": "bike",
  auto: "auto",
  "electric-auto": "auto",
  "e-rickshaw": "auto",
  erickshaw: "auto",
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
  if (normalized.includes("rickshaw") || normalized.includes("auto")) {
    return "/images/services/auto.png";
  }
  if (normalized.includes("parcel")) return "/images/services/parcel.png";
  if (normalized.includes("travel")) return "/images/services/travel.png";
  if (normalized.includes("ambulance")) return "/images/services/ambulance.png";
  return "/images/services/car.png";
}

/** Normalize admin / legacy labels (e.g. Bike-Taxi → Bike). */
export function displayVehicleName(name: string | null | undefined, slug?: string | null): string {
  const raw = (name || slug || "").trim();
  if (!raw) return "Ride";
  const key = raw.toLowerCase().replace(/[\s_]+/g, "-");
  if (key === "bike-taxi" || key === "biketaxi" || key === "bike") return "Bike";
  if (key === "electric-auto" || key === "e-auto" || key === "auto") return "Electric Auto";
  if (key === "e-rickshaw" || key === "erickshaw") return "Electric Auto";
  // Strip trailing "-taxi" / " taxi" for bike-style names
  if (key.endsWith("-taxi") && key.includes("bike")) return "Bike";
  return raw.replace(/bike[\s-]?taxi/gi, "Bike");
}

/**
 * Prefer admin-uploaded icon from vehicle types API.
 * `/uploads/...` stays same-origin so Next.js rewrite proxies to Backend.
 * Absolute admin/CDN URLs are kept as-is.
 * Electric Auto always uses the white local service art.
 */
export function vehicleImageForCategory(category: VehicleCategory): string {
  const slug = (category.slug || category.name || "").toLowerCase();
  if (slug.includes("auto") || slug.includes("rickshaw")) {
    return "/images/services/auto.png";
  }

  const raw = (category.icon_url || (category as { image_url?: string | null }).image_url)?.trim();
  if (raw) {
    if (raw.startsWith("/uploads/")) {
      // Same-origin rewrite → Backend uploads (see next.config.ts)
      return raw;
    }
    const resolved = resolveMediaUrl(raw);
    if (resolved) return resolved;
  }
  return vehicleImageForSlug(category.slug || category.name || "");
}

/** Absolute URL helper when an <img> must hit Backend directly. */
export function absoluteVehicleImageUrl(category: VehicleCategory): string {
  const src = vehicleImageForCategory(category);
  if (src.startsWith("http://") || src.startsWith("https://") || src.startsWith("data:")) {
    return src;
  }
  if (src.startsWith("/uploads/")) {
    return `${getApiBaseUrl().replace(/\/$/, "")}${src}`;
  }
  return src;
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
