import type { RideVehicleId } from "@/data/ride-options";
import { RIDE_VEHICLE_IDS } from "@/data/ride-options";
import { ROUTES } from "@/constants/routes";
import type { PaymentMethod } from "@/lib/ride-api";
import {
  parseStopsFromParams,
  writeStopsToParams,
  type TripStop,
} from "@/lib/trip-stops";

export interface TripLocationParams {
  pickup: string;
  dropoff: string;
  pickupLat?: number;
  pickupLng?: number;
  dropoffLat?: number;
  dropoffLng?: number;
  distanceKm?: number;
  durationMin?: number;
  payment?: PaymentMethod;
  tab?: string;
  vehicle?: string;
  categoryId?: string;
  preferWomenRiders?: boolean;
  stops?: TripStop[];
  promoCode?: string;
  scheduledAt?: string;
}

function setCoordParams(
  params: URLSearchParams,
  trip: Omit<
    TripLocationParams,
    "pickup" | "dropoff" | "tab" | "vehicle" | "categoryId" | "preferWomenRiders" | "payment" | "stops"
  >
) {
  if (trip.pickupLat != null) params.set("plat", String(trip.pickupLat));
  if (trip.pickupLng != null) params.set("plng", String(trip.pickupLng));
  if (trip.dropoffLat != null) params.set("dlat", String(trip.dropoffLat));
  if (trip.dropoffLng != null) params.set("dlng", String(trip.dropoffLng));
  if (trip.distanceKm != null) params.set("distance_km", String(trip.distanceKm));
  if (trip.durationMin != null) params.set("duration_min", String(trip.durationMin));
}

function applyExtras(
  params: URLSearchParams,
  extras?: Omit<TripLocationParams, "pickup" | "dropoff" | "tab" | "vehicle">
) {
  if (!extras) return;
  setCoordParams(params, extras);
  if (extras.payment) params.set("payment", extras.payment);
  if (extras.categoryId) params.set("categoryId", extras.categoryId);
  if (extras.preferWomenRiders) params.set("preferWomen", "1");
  if (extras.stops) writeStopsToParams(params, extras.stops);
  if (extras.promoCode) params.set("promo", extras.promoCode);
  if (extras.scheduledAt) params.set("scheduled_at", extras.scheduledAt);
}

export function parseTripCoords(searchParams: {
  get(name: string): string | null;
}): {
  pickupLat?: number;
  pickupLng?: number;
  dropoffLat?: number;
  dropoffLng?: number;
  distanceKm?: number;
  durationMin?: number;
  payment?: PaymentMethod;
  stops: TripStop[];
} {
  const num = (key: string) => {
    const raw = searchParams.get(key);
    if (raw == null || raw === "") return undefined;
    const value = Number(raw);
    return Number.isFinite(value) ? value : undefined;
  };

  const paymentRaw = searchParams.get("payment");
  const payment =
    paymentRaw === "CASH" || paymentRaw === "UPI" || paymentRaw === "WALLET" || paymentRaw === "CARD"
      ? paymentRaw
      : undefined;

  return {
    pickupLat: num("plat"),
    pickupLng: num("plng"),
    dropoffLat: num("dlat"),
    dropoffLng: num("dlng"),
    distanceKm: num("distance_km"),
    durationMin: num("duration_min"),
    payment,
    stops: parseStopsFromParams(searchParams),
  };
}

export function buildRideQueryParams(
  pickup: string,
  dropoff: string,
  vehicle: string,
  tab = "rides",
  extras?: Omit<TripLocationParams, "pickup" | "dropoff" | "tab" | "vehicle">
) {
  const params = new URLSearchParams({ pickup, dropoff, vehicle, tab });
  applyExtras(params, extras);
  return params;
}

export function buildBookUrl(
  pickup: string,
  dropoff: string,
  tab = "rides",
  vehicle?: string,
  extras?: Omit<TripLocationParams, "pickup" | "dropoff" | "tab" | "vehicle">
) {
  const params = new URLSearchParams({ pickup, dropoff, tab });
  if (vehicle) params.set("vehicle", vehicle);
  if (extras) {
    setCoordParams(params, extras);
    if (extras.payment) params.set("payment", extras.payment);
    if (extras.categoryId) params.set("category", extras.categoryId);
    if (extras.stops) writeStopsToParams(params, extras.stops);
    if (extras.promoCode) params.set("promo", extras.promoCode);
    if (extras.scheduledAt) params.set("scheduled_at", extras.scheduledAt);
  }
  return `${ROUTES.book}?${params.toString()}`;
}

export function buildSearchingUrl(
  pickup: string,
  dropoff: string,
  vehicle: string,
  tab = "rides",
  categoryId?: string,
  preferWomenRiders = false,
  extras?: Omit<
    TripLocationParams,
    "pickup" | "dropoff" | "tab" | "vehicle" | "categoryId" | "preferWomenRiders"
  >
) {
  const params = buildRideQueryParams(pickup, dropoff, vehicle, tab, {
    ...extras,
    categoryId,
    preferWomenRiders,
  });
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

export function mapEmbedUrl(pickupLat?: number, pickupLng?: number, dropoffLat?: number, dropoffLng?: number) {
  if (
    pickupLat != null &&
    pickupLng != null &&
    dropoffLat != null &&
    dropoffLng != null
  ) {
    return `https://maps.google.com/maps?saddr=${pickupLat},${pickupLng}&daddr=${dropoffLat},${dropoffLng}&output=embed`;
  }
  return "https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d14008.114827184203!2d77.216721!3d28.6328!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x390cfd37b741d057%3A0xc46ce4427b231eb5!2sConnaught%20Place%2C%20New%20Delhi%2C%20Delhi%20110001!5e0!3m2!1sen!2sin!4v1700000000000!5m2!1sen!2sin";
}
