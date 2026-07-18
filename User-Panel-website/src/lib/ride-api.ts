import { apiFetch, authFetch } from "@/lib/api";
import { directionsQuery, type SelectedPlace } from "@/lib/places-api";
import {
  stopsToApiPayload,
  stopsToWaypointsQuery,
  type TripStop,
} from "@/lib/trip-stops";

export interface RideDriver {
  id?: string;
  name?: string | null;
  phone?: string | null;
  rating?: number | null;
  photo_url?: string | null;
  vehicle_number?: string | null;
}

export interface Ride {
  id: string;
  public_id?: string | null;
  pickup_address: string;
  dropoff_address: string;
  status: string;
  fare_estimate: number | null;
  fare_final: number | null;
  cancelled_reason?: string | null;
  created_at: string;
  prefer_women_riders?: boolean;
  allow_all_riders?: boolean;
  women_riders_available?: boolean;
  requires_rider_preference_choice?: boolean;
  women_safety_enabled?: boolean;
  message?: string;
  driver?: RideDriver | null;
  start_code?: string | null;
  vehicle_number?: string | null;
  vehicle_type_name?: string | null;
  pickup_lat?: number | null;
  pickup_lng?: number | null;
  dropoff_lat?: number | null;
  dropoff_lng?: number | null;
  driver_lat?: number | null;
  driver_lng?: number | null;
  estimated_duration_min?: number | null;
  payment_method?: string | null;
  is_emergency?: boolean;
}

interface BackendRide {
  id: string;
  public_id?: string | null;
  pickup_address: string;
  dropoff_address: string;
  status: string;
  estimated_fare?: number;
  final_fare?: number | null;
  fare_estimate?: number | null;
  fare_final?: number | null;
  cancellation_reason?: string | null;
  created_at: string;
  prefer_women_riders?: boolean;
  allow_all_riders?: boolean;
  women_riders_available?: boolean;
  requires_rider_preference_choice?: boolean;
  women_safety_enabled?: boolean;
  message?: string;
  driver?: RideDriver | null;
  start_code?: string | null;
  vehicle_number?: string | null;
  vehicle_type_name?: string | null;
  pickup_lat?: number | null;
  pickup_lng?: number | null;
  dropoff_lat?: number | null;
  dropoff_lng?: number | null;
  driver_lat?: number | null;
  driver_lng?: number | null;
  estimated_duration_min?: number | null;
  payment_method?: string | null;
  is_emergency?: boolean;
}

function mapRide(ride: BackendRide): Ride {
  return {
    id: ride.id,
    public_id: ride.public_id,
    pickup_address: ride.pickup_address,
    dropoff_address: ride.dropoff_address,
    status: ride.status,
    fare_estimate: ride.fare_estimate ?? ride.estimated_fare ?? null,
    fare_final: ride.fare_final ?? ride.final_fare ?? null,
    cancelled_reason: ride.cancellation_reason ?? null,
    created_at: ride.created_at,
    prefer_women_riders: ride.prefer_women_riders,
    allow_all_riders: ride.allow_all_riders,
    women_riders_available: ride.women_riders_available,
    requires_rider_preference_choice: ride.requires_rider_preference_choice,
    women_safety_enabled: ride.women_safety_enabled,
    message: ride.message,
    driver: ride.driver,
    start_code: ride.start_code,
    vehicle_number: ride.vehicle_number,
    vehicle_type_name: ride.vehicle_type_name,
    pickup_lat: ride.pickup_lat,
    pickup_lng: ride.pickup_lng,
    dropoff_lat: ride.dropoff_lat,
    dropoff_lng: ride.dropoff_lng,
    driver_lat: ride.driver_lat,
    driver_lng: ride.driver_lng,
    estimated_duration_min: ride.estimated_duration_min,
    payment_method: ride.payment_method,
    is_emergency: ride.is_emergency,
  };
}

export interface RideHistoryResponse {
  items: Ride[];
  total: number;
  page: number;
  page_size: number;
  pages: number;
}

export interface FareEstimate {
  category_id: string;
  estimated_fare: number;
  original_fare?: number | null;
  member_discount?: number;
  discount_percent?: number;
  currency: string;
}

export interface RideDirections {
  pickup_lat: number;
  pickup_lng: number;
  dropoff_lat: number;
  dropoff_lng: number;
  distance_km: number;
  duration_min: number;
  pickup_address?: string;
  dropoff_address?: string;
}

export async function getRideDirections(
  pickup: SelectedPlace | string,
  dropoff: SelectedPlace | string,
  stops: TripStop[] = []
): Promise<RideDirections> {
  const pickupPlace: SelectedPlace =
    typeof pickup === "string" ? { label: pickup } : pickup;
  const dropoffPlace: SelectedPlace =
    typeof dropoff === "string" ? { label: dropoff } : dropoff;

  const params = new URLSearchParams({
    pickup: directionsQuery(pickupPlace),
    dropoff: directionsQuery(dropoffPlace),
  });
  const waypoints = stopsToWaypointsQuery(stops);
  if (waypoints) params.set("waypoints", waypoints);

  const data = await apiFetch<{
    pickup: { lat: number; lng: number; address?: string };
    dropoff: { lat: number; lng: number; address?: string };
    distance_km: number;
    duration_min: number;
  }>(`/public/places/directions?${params.toString()}`, undefined, "Unable to load route");

  return {
    pickup_lat: data.pickup.lat,
    pickup_lng: data.pickup.lng,
    dropoff_lat: data.dropoff.lat,
    dropoff_lng: data.dropoff.lng,
    distance_km: data.distance_km,
    duration_min: data.duration_min,
    pickup_address: data.pickup.address,
    dropoff_address: data.dropoff.address,
  };
}

interface VehicleFareQuote {
  vehicle_type_id: string;
  estimated_fare: number;
  original_fare?: number | null;
  member_discount?: number;
  discount_percent?: number;
}

export async function estimateRideFares(payload: {
  pickup_lat: number;
  pickup_lng: number;
  dropoff_lat: number;
  dropoff_lng: number;
  distance_km?: number;
  duration_min?: number;
  service_group?: "ride" | "rental";
  stops?: TripStop[];
}): Promise<{
  discount_percent: number | null;
  distance_km?: number;
  duration_min?: number;
  quotes: Record<string, VehicleFareQuote>;
}> {
  const stopsPayload = payload.stops ? stopsToApiPayload(payload.stops) : [];
  const res = await authFetch<{
    vehicle_types: VehicleFareQuote[];
    discount_percent?: number | null;
    distance_km?: number;
    duration_min?: number;
  }>(
    "/rides/estimate",
    {
      method: "POST",
      body: JSON.stringify({
        service_group: payload.service_group ?? "ride",
        pickup_lat: payload.pickup_lat,
        pickup_lng: payload.pickup_lng,
        dropoff_lat: payload.dropoff_lat,
        dropoff_lng: payload.dropoff_lng,
        ...(payload.distance_km != null ? { distance_km: payload.distance_km } : {}),
        ...(payload.duration_min != null ? { duration_min: payload.duration_min } : {}),
        ...(stopsPayload.length > 0 ? { stops: stopsPayload } : {}),
      }),
    },
    "Unable to estimate fare"
  );

  const quotes: Record<string, VehicleFareQuote> = {};
  for (const item of res.vehicle_types ?? []) {
    quotes[item.vehicle_type_id.toLowerCase()] = item;
  }

  return {
    discount_percent: res.discount_percent ?? null,
    distance_km: res.distance_km,
    duration_min: res.duration_min,
    quotes,
  };
}

export function estimateFare(payload: {
  vehicle_category_id: string;
  pickup_lat: number;
  pickup_lng: number;
  dropoff_lat: number;
  dropoff_lng: number;
  distance_km?: number;
  duration_min?: number;
}): Promise<FareEstimate> {
  return estimateRideFares({
    pickup_lat: payload.pickup_lat,
    pickup_lng: payload.pickup_lng,
    dropoff_lat: payload.dropoff_lat,
    dropoff_lng: payload.dropoff_lng,
    distance_km: payload.distance_km,
    duration_min: payload.duration_min,
  }).then((res) => {
    const match =
      res.quotes[payload.vehicle_category_id.toLowerCase()] ??
      Object.values(res.quotes)[0];
    return {
      category_id: match?.vehicle_type_id ?? payload.vehicle_category_id,
      estimated_fare: match?.estimated_fare ?? 0,
      original_fare: match?.original_fare ?? null,
      member_discount: match?.member_discount ?? 0,
      discount_percent: match?.discount_percent ?? res.discount_percent ?? 0,
      currency: "INR",
    };
  });
}

export type PaymentMethod = "CASH" | "UPI" | "WALLET" | "CARD";

export function bookRide(payload: {
  pickup_address: string;
  dropoff_address: string;
  pickup_lat: number;
  pickup_lng: number;
  dropoff_lat: number;
  dropoff_lng: number;
  vehicle_category_id?: string;
  payment_method?: PaymentMethod;
  promo_code?: string;
  rental_hours?: number;
  scheduled_at?: string;
  women_safety_enabled?: boolean;
  prefer_women_riders?: boolean;
  distance_km?: number;
  duration_min?: number;
  stops?: TripStop[];
}): Promise<Ride> {
  const stopsPayload = payload.stops ? stopsToApiPayload(payload.stops) : [];
  return authFetch<BackendRide>(
    "/book-ride",
    {
      method: "POST",
      body: JSON.stringify({
        pickup_address: payload.pickup_address,
        dropoff_address: payload.dropoff_address,
        pickup_lat: payload.pickup_lat,
        pickup_lng: payload.pickup_lng,
        dropoff_lat: payload.dropoff_lat,
        dropoff_lng: payload.dropoff_lng,
        payment_method: payload.payment_method ?? "CASH",
        women_safety_enabled: payload.women_safety_enabled ?? false,
        prefer_women_riders: payload.prefer_women_riders ?? false,
        ...(payload.vehicle_category_id
          ? { vehicle_category_id: payload.vehicle_category_id }
          : {}),
        ...(payload.promo_code ? { promo_code: payload.promo_code } : {}),
        ...(payload.rental_hours != null ? { rental_hours: payload.rental_hours } : {}),
        ...(payload.scheduled_at ? { scheduled_at: payload.scheduled_at } : {}),
        ...(payload.distance_km != null ? { distance_km: payload.distance_km } : {}),
        ...(payload.duration_min != null ? { duration_min: payload.duration_min } : {}),
        ...(stopsPayload.length > 0 ? { stops: stopsPayload } : {}),
      }),
    },
    "Unable to book ride"
  ).then(mapRide);
}

export function continueWithAllRiders(rideId: string): Promise<Ride> {
  return authFetch<BackendRide>(
    "/continue-with-all-riders",
    { method: "POST", body: JSON.stringify({ ride_id: rideId }) },
    "Unable to continue ride search"
  ).then(mapRide);
}

export function getActiveRide(): Promise<Ride | null> {
  return authFetch<{ active: BackendRide | null }>("/rides", undefined, "Unable to load active ride").then(
    (res) => (res.active ? mapRide(res.active) : null)
  );
}

export function getRideHistory(page = 1, pageSize = 20): Promise<RideHistoryResponse> {
  return authFetch<{ items: BackendRide[]; page: number; page_size: number }>(
    `/rides?page=${page}&page_size=${pageSize}`,
    undefined,
    "Unable to load ride history"
  ).then((res) => ({
    items: res.items.map(mapRide),
    total: res.items.length,
    page: res.page,
    page_size: res.page_size,
    pages: 1,
  }));
}

export function getRide(rideId: string): Promise<Ride> {
  return authFetch<BackendRide>(`/ride/${rideId}`, undefined, "Unable to load ride").then(mapRide);
}

export function getRideStatus(rideId: string): Promise<{ status: string }> {
  return authFetch<BackendRide>(`/ride/${rideId}`, undefined, "Unable to load ride status").then((r) => ({
    status: r.status,
  }));
}

export function cancelRide(rideId: string, reason?: string): Promise<Ride> {
  return authFetch<BackendRide>(
    "/cancel-ride",
    { method: "POST", body: JSON.stringify({ ride_id: rideId, reason: reason || "User cancelled" }) },
    "Unable to cancel ride"
  ).then(mapRide);
}

export function getRideTracking(rideId: string): Promise<Record<string, unknown>> {
  return authFetch<Record<string, unknown>>(`/ride/${rideId}`, undefined, "Unable to load tracking");
}

export function rateRide(
  rideId: string,
  rating: number,
  comment?: string
): Promise<{ ride_id: string; rating: number }> {
  return authFetch<{ ride_id: string; rating: number }>(
    `/ride/${rideId}/rate`,
    {
      method: "POST",
      body: JSON.stringify({ rating, comment: comment ?? null }),
    },
    "Unable to submit rating"
  );
}

export function isDriverAssigned(status: string | null | undefined): boolean {
  if (!status) return false;
  const assigned = new Set([
    "DRIVER_ASSIGNED",
    "DRIVER_ARRIVED",
    "OTP_VERIFIED",
    "STARTED",
    "IN_PROGRESS",
  ]);
  return assigned.has(status.toUpperCase());
}

export function isRideTerminal(status: string | null | undefined): boolean {
  if (!status) return false;
  const terminal = new Set(["COMPLETED", "CANCELLED"]);
  return terminal.has(status.toUpperCase());
}

export function isRideInProgress(status: string | null | undefined): boolean {
  if (!status) return false;
  const active = new Set([
    "SEARCHING",
    "SEARCHING_DRIVER",
    "DRIVER_ASSIGNED",
    "DRIVER_ARRIVED",
    "OTP_VERIFIED",
    "STARTED",
    "IN_PROGRESS",
  ]);
  return active.has(status.toUpperCase());
}

export interface RideDriverDetails {
  id: string;
  name: string;
  phone: string;
  rating: number;
  vehicle_number: string;
  photo_url?: string | null;
}

export function getRideDriver(rideId: string): Promise<RideDriverDetails> {
  return authFetch<RideDriverDetails>(
    `/ride/${rideId}/driver`,
    undefined,
    "Unable to load driver"
  );
}

export function triggerRideSos(
  rideId: string,
  payload?: { lat?: number; lng?: number; message?: string }
): Promise<{
  message?: string;
  emergency_sms_sent?: boolean;
  ticket_id?: string;
}> {
  return authFetch(
    `/ride/${rideId}/sos`,
    {
      method: "POST",
      body: JSON.stringify({
        lat: payload?.lat ?? null,
        lng: payload?.lng ?? null,
        message: payload?.message ?? "Passenger triggered SOS",
      }),
    },
    "Unable to send SOS"
  );
}

export interface RideChatMessage {
  id: string;
  message: string;
  sender_type: string;
  created_at: string;
  sender_id?: string;
}

export function listRideMessages(rideId: string): Promise<RideChatMessage[]> {
  return authFetch<{ success?: boolean; data?: RideChatMessage[] } | RideChatMessage[]>(
    `/ride/${rideId}/messages`,
    undefined,
    "Unable to load chat"
  ).then((res) => {
    if (Array.isArray(res)) return res;
    return res.data ?? [];
  });
}

export function sendRideMessage(rideId: string, message: string): Promise<RideChatMessage> {
  return authFetch<{ success?: boolean; data?: RideChatMessage } | RideChatMessage>(
    `/ride/${rideId}/messages`,
    { method: "POST", body: JSON.stringify({ message }) },
    "Unable to send message"
  ).then((res) => {
    if (res && typeof res === "object" && "data" in res && res.data) return res.data;
    return res as RideChatMessage;
  });
}

export function buildLiveRideShareText(ride: Ride, etaMinutes?: number | null): string {
  const driver = (ride.driver?.name ?? "Captain").trim();
  const vehicle = (ride.vehicle_number ?? ride.driver?.vehicle_number ?? "—").trim();
  const lat = ride.driver_lat ?? ride.pickup_lat;
  const lng = ride.driver_lng ?? ride.pickup_lng;
  const maps =
    lat != null && lng != null ? `https://www.google.com/maps?q=${lat},${lng}` : null;
  const eta = etaMinutes != null ? `${etaMinutes} min` : "Updating…";
  const rideRef = ride.public_id?.trim() || ride.id;

  return [
    "Bull Wave Rides — Live Trip Share",
    `Driver: ${driver}`,
    `Vehicle: ${vehicle}`,
    `Destination: ${ride.dropoff_address}`,
    `ETA: ${eta}`,
    ...(maps ? [`Live location: ${maps}`] : []),
    `Ride: ${rideRef}`,
  ].join("\n");
}

export function getNearbyDrivers(): Promise<{ count: number; eta_minutes: number }> {
  return Promise.resolve({ count: 3, eta_minutes: 5 });
}
