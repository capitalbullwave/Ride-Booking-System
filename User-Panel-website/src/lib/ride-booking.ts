import type { RideVehicleId } from "@/data/ride-options";
import { RIDE_VEHICLE_IDS } from "@/data/ride-options";
import { ROUTES } from "@/constants/routes";

export function buildRideQueryParams(
  pickup: string,
  dropoff: string,
  vehicle: string,
  tab = "rides"
) {
  const params = new URLSearchParams({ pickup, dropoff, vehicle, tab });
  return params;
}

export function buildBookUrl(
  pickup: string,
  dropoff: string,
  tab = "rides",
  vehicle?: string
) {
  const params = new URLSearchParams({ pickup, dropoff, tab });
  if (vehicle) params.set("vehicle", vehicle);
  return `${ROUTES.book}?${params.toString()}`;
}

export function buildSearchingUrl(
  pickup: string,
  dropoff: string,
  vehicle: string,
  tab = "rides",
  categoryId?: string
) {
  const params = buildRideQueryParams(pickup, dropoff, vehicle, tab);
  if (categoryId) params.set("categoryId", categoryId);
  return `${ROUTES.bookSearching}?${params.toString()}`;
}

export function buildTrackingUrl(
  pickup: string,
  dropoff: string,
  vehicle: RideVehicleId,
  tab = "rides",
  rideId?: string
) {
  const params = buildRideQueryParams(pickup, dropoff, vehicle, tab);
  if (rideId) params.set("rideId", rideId);
  return `${ROUTES.bookTracking}?${params.toString()}`;
}

export function formatFare(amount: number) {
  return `₹ ${amount.toLocaleString("en-IN")}`;
}

export function isRideVehicleId(value: string | null): value is RideVehicleId {
  return value !== null && RIDE_VEHICLE_IDS.includes(value as RideVehicleId);
}
