import type { RideVehicleId } from "@/data/ride-options";

/** Maps backend vehicle category slugs to frontend ride vehicle ids. */
export const CATEGORY_SLUG_TO_VEHICLE: Record<string, RideVehicleId> = {
  "bike-taxi": "bike",
  "electric-auto": "auto",
  cab: "cab",
  ambulance: "ambulance",
};

export const VEHICLE_TO_CATEGORY_SLUG: Partial<Record<RideVehicleId, string>> = {
  bike: "bike-taxi",
  auto: "electric-auto",
  cab: "cab",
  ambulance: "ambulance",
};

export function vehicleImageForSlug(slug: string): string {
  const map: Record<string, string> = {
    "bike-taxi": "/images/services/bike.png",
    "electric-auto": "/images/services/auto.png",
    cab: "/images/services/car.png",
    ambulance: "/images/services/ambulance.png",
  };
  return map[slug] ?? "/images/services/car.png";
}

export function estimateDistanceKm(): number {
  return 5.2;
}

export function estimateDurationMin(): number {
  return 18;
}
